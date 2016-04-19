#!/usr/bin/perl -w

# restrict2bed.pl
# Search for nicking enzyme sites in multifasta reference genomes
# report results in BED format to STDOUT for BedTools piping & manipulations
#
# Stephane Plaisance (VIB-NC+BITS) 2015/11/11; v1.00b
#
# write to STDOUT to allow pipes; v1.00b 
# added case insensitivity 2016-04-19; v1.01
#
# visit our Git: https://github.com/BITS-VIB

# examples: NEB Nickers for Bionanogenomics
# 	'Nt-BspQI' => 'GCTCTTC'
# 	'Nt-BbvCI' => 'CCTCAGC'
# 	'Nb-BsMI'  => 'GAATGC'
# 	'Nb-BsrDI' => 'GCAATG'
# 	'Nb-BssSI' => 'CACGAG'

use warnings;
use strict;
use Bio::SeqIO;
use File::Basename;
use Getopt::Std;

my $version="v1.01"; # 2016-04-19

############################
# handle command parameters
############################
getopts('i:n:l:h');
our ( $opt_i, $opt_n, $opt_l, $opt_h );

my $usage = "## Usage: restrict2bed.pl <-i fasta-file>
# <-n 'nicker(s) consensus', multiple allowed separated by ',')>
#  eg. 'Nt-BspQI' => 'GCTCTTC'
#  eg. 'Nt-BbvCI' => 'CCTCAGC'
#  eg. 'Nb-BsMI'  => 'GAATGC'
#  eg. 'Nb-BsrDI' => 'GCAATG'
#  eg. 'Nb-BssSI' => 'CACGAG'
# Additional optional parameters are:
# <-l minimal length for dna sequence (20000)>
# <-h to display this help>";

my $infile = $opt_i || die $usage . "\n";
my $nicker = $opt_n || die $usage . "\n";
my $minlen = $opt_l || 20000;
defined($opt_h) && die $usage . "\n";

# handle IO
my $inpath = dirname($infile);
my @sufx = ( ".fa", ".fasta", ".fsa", ".fna" );
my $name = basename( $infile, @sufx );
# my $outpath = $inpath."/".$name.".bed";

# create output file
#open(BED, ">".$outpath) || die "Error: cannot create output file :$!\n";
my $seqIO = Bio::SeqIO->new(-file=>$infile, -format=>"Fasta");

# prepare query list from multiple sequence motifs
my @plus = split(",", uc($nicker)); # take uppercase
my @min = map {revdnacomp($_)} @plus;
# combine both and remove duplicates (palindromes)
my @query = uniq(@plus,@min);
my $regex = join("|", @query);

# loop through sequences and search motifs
while ( my $seq = $seqIO->next_seq() ) {
	my $title = $seq->id;
	my $chrlen = $seq->length;
	# test if long enough
	$chrlen >= $minlen || next;
	my $dna = $seq->seq();
	print STDERR "processing: $title ($chrlen) query:\'$regex\'\n";

	#Get all the positions within the chromosome sequence
	# search upper strand
	my %sites = lookup($regex, $dna, $title);
	foreach my $hit (sort {$a <=> $b} keys %sites) {
		my $line = join("\t", $title, $sites{$hit}{result});
		print STDOUT $line."\n";
	}
}

# end
#close BED;
exit 0;

############ SUBS #############
# get the reverse complement of the RE site
sub revdnacomp {
  my $dna = shift;
  my $revcomp = reverse($dna);
  $revcomp =~ tr/NACGTnacgt/NTGCAntgca/;
  return $revcomp;
}

# find unique array elements
sub uniq {
    my %seen;
    grep !$seen{$_}++, @_;
}

# regex code adapted from: http://stackoverflow.com
# /questions/87380/how-can-i-find-the-location-of-a-regex-match-in-perl
sub lookup {
	my ($regex, $seq, $title) = @_;
	my %hits=();
	while ($seq =~ /($regex)/ig) {
		$hits{$-[0]}{result} = "$-[0]\t".($+[0]-1)."\t$1\t1\t+";
		}
	return %hits;
}
