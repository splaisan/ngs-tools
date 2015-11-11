#!/usr/bin/perl -w

# fasta2chromsizes.pl
# Create a table of chromosome lengths from a multifasta file
#
# Stephane Plaisance (VIB-NC+BITS) 2015/11/11; v1.00
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
my @sufx = ( ".fa", ".fasta", ".fsa" );
my $name = basename( $infile, @sufx );
my $outpath = $inpath."/".$name.".chrom.sizes";

# create output file
open(OUT, ">".$outpath) || die "Error: cannot create output file :$!\n";
my $seqIO = Bio::SeqIO->new(-file=>$infile, -format=>"Fasta");

# loop through sequences and search motifs
while ( my $seq = $seqIO->next_seq() ) {
	my $title = $seq->id;
	my $chrlen = $seq->length;
	# test if long enough
	$chrlen >= $minlen || next;
	print OUT $title."\t".$chrlen."\n";
	}

# end
close OUT;
exit 0;
