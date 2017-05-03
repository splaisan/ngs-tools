#!/usr/bin/perl -w

# fasta2chromsizes.pl
# Create a table of chromosome lengths from a multifasta file
#
# Stephane Plaisance (VIB-NC+BITS) 2015/11/11; v1.00b
# 1.1 allow compressed input and report total size
# print to STDOUT to allow pipe
#
# visit our Git: https://github.com/BITS-VIB

use warnings;
use strict;
use Bio::SeqIO;
use File::Basename;
use Getopt::Std;

############################
# handle command parameters
############################
getopts('i:l:h');
our ( $opt_i, $opt_l, $opt_h );

my $usage = "## Usage: fasta2chromsizes.pl <-i fasta-file>
# Additional optional parameters are:
# <-l minimal length for dna sequence (20000)>
# <-h to display this help>";

my $infile = $opt_i || die $usage . "\n";
my $minlen = $opt_l || 20000;
defined($opt_h) && die $usage . "\n";

# handle IO
my $inpath = dirname($infile);
my @sufx = (
	".fa", ".fasta", ".fsa", ".fna",
	".fa.gz", ".fasta.gz", ".fsa.gz", ".fna.gz",
	".fa.zip", ".fasta.zip", ".fsa.zip", ".fna.zip",
	".fa.bz2", ".fasta.bz2", ".fsa.bz2", ".fna.bz2", 
	);
my $name = basename( $infile, @sufx );

# bioperl filehandles
my $in = OpenArchiveFile($infile);
my $totlen = 0;

# loop through sequences and search motifs
while ( my $seq = $in->next_seq() ) {
	my $title = $seq->id;
	print STDERR "# processing $title\n";
	my $chrlen = $seq->length;
	# test if long enough
	$chrlen >= $minlen || next;
	print STDOUT $title."\t".$chrlen."\n";
	$totlen+=$chrlen;
	}

print STDERR "# Total length (filtered)\t".$totlen."\n";

# end
#close OUT;
exit 0;

#### Subs ####
sub OpenArchiveFile {
    my $infile = shift;
    my $FH;
    if ($infile =~ /.fa$|.fasta$|.fna$/) {
    $FH = Bio::SeqIO -> new(-file => "$infile", -format => 'Fasta');
    }
    elsif ($infile =~ /.gz$/) {
    $FH = Bio::SeqIO -> new(-file => "bgzip -cd $infile| ", -format => 'Fasta');
    }
    elsif ($infile =~ /.bz2$/) {
    $FH = Bio::SeqIO -> new(-file => "bzip2 -c $infile| ", -format => 'Fasta');
    }
    elsif ($infile =~ /.zip$/) {
    $FH = Bio::SeqIO -> new(-file => "unzip -p $infile| ", -format => 'Fasta');
    } else {
	die ("$!: do not recognise file type $infile");
	# if this happens, add the file type with correct opening proc
    }
    return $FH;
}

