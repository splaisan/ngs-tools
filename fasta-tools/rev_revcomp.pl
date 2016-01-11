#!/usr/bin/perl -w
use strict;

# reverse and reverse-complement a list of sequences (one column)
# ©SP:NC 2016-01-11

# do not buffer stream
$| = 1;

# get input file
@ARGV == 1 or die("\nusage: rev_revcomp.pl <file=list of sequences> \n\n");
my $infile= $ARGV[0];

open (SEQS, $infile) or die $!;

while ( my $seq = <SEQS> ) {
	# trim spaces
	$seq =~ s/^\s+|\s+$//g;
	# do not process empty lines	
	next if $seq eq "";
	# process
	my @seq = split(/\b/, $seq);
	# reverse sequence
	my $rev = reverse($seq);
	#while (@seq) {
    #	$rev .= pop(@seq);
	#	}
	# reverse complement
	my $revcmp = $rev; 
	$revcmp =~ tr[ACGTacgt][tgca];
	# output
	print STDOUT "seq:".$seq.", rev:".$rev.", rev-compl :".uc($revcmp)."\n";

}

close SEQS;
