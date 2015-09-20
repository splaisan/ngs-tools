#!/usr/bin/perl -w
# de-duplicate multi.Fasta file based on the full sequence
# keeps the first instance of each sequence with its header
# adapted from dedupFasta.pl that looks at the header
# 2013-05-22: added archive support for input (HOWTO:SeqIO)
#
# Stephane Plaisance, BITS 2013-05-22

use strict;
use Bio::SeqIO;

@ARGV == 2 or die("usage: $0 <fasta_input file> <output file name>\n");

my $infile = $ARGV[0];
chomp($infile);
my $outfile= $ARGV[1];
chomp($outfile);

my $counter=0;
my $kept=0;
my %matching_hash = ();

my $in=OpenArchiveFile($infile);
my $out = Bio::SeqIO -> new(-file => ">$outfile", -format => 'Fasta');

while ( my $seq = $in->next_seq() ) {
$counter++;
	unless($matching_hash{$seq->seq()}){
		$kept++;
		$out->write_seq($seq);
		$matching_hash{$seq->seq()} = 1;
		$counter =~ m/00$/ && print STDERR ".";
	}
}

print STDERR "\n# done filtering ".$counter." lines from ".$infile." and keeping ".$kept." records\n";

#### Subs ####
sub OpenArchiveFile {
    my $infile = shift;
    my $FH;
    if ($infile =~ /.fa$|.fasta$/) {
    $FH = Bio::SeqIO -> new(-file => "$infile", -format => 'Fasta');
    }
    elsif ($infile =~ /.bz2$/) {
    $FH = Bio::SeqIO -> new(-file => "bgzip -c $infile |", -format => 'Fasta');
    }
    elsif ($infile =~ /.gz$/) {
    $FH = Bio::SeqIO -> new(-file => "gzip -cd $infile |", -format => 'Fasta');
    }
    elsif ($infile =~ /.zip$/) {
    $FH = Bio::SeqIO -> new(-file => "unzip -p $infile |", -format => 'Fasta');
    } else {
	die ("$!: do not recognise file type $infile");
	# if this happens add, the file type with correct opening proc
    }
