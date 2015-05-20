#!/usr/bin/perl -w

# filter unpaired reads from a - read-name sorted - BAM file
# bam_re-pair.pl
# author: Stephane Plaisance (translated from python version by Devon Ryan
# http://seqanswers.com/forums/showthread.php?p=118936#post118936
# usage:
# samtools view -h <name_sorted.bam> | \
#	bam_re-pair.pl | \
#	samtools view -bSo <name_sorted.filtered.bam> -

use warnings;
use strict;

# variables
my $read = "";
my $read1 = "none";
my $read2 = "none";
my $name1 = "none";
my $name2 = "none";
my ($ln,$ok,$no)=(0,0,0);

while (my $read = <>) {

# forward header lines
if ($read =~ /^@/){
	print STDOUT $read;
	next;
	}

# process data
$ln++;
if( $name1 eq "none" ){
	$read1 = $read;
    $name1 = (split("\t", $read1))[0];
	} else {
		$name2 = (split("\t", $read))[0];
		if( $name1 eq $name2 ){
			# is paired
			$ok++;

			# add index to read names if absent
			if ($name1 !~ /\\1$/){
				$read1 =~ s/$name1/$name1\\1/;
				}
			if ($name2 !~ /\\2$/){
				$read =~ s/$name2/$name2\\2/;
				}

			print STDOUT sprintf("%s%s", $read1, $read);
			$read1 = "none";
			$name1 = "none";
			} else {
				# is not paired
				$no++;
				$read1 = $read;
				$name1 = (split("\t", $read1))[0];
				}
	}
}

# report counts with nice alignmenment
print STDERR "\n############################\n# Results\n";
print STDERR sprintf("%-18s%10d\n", "# processed:", $ln);
print STDERR sprintf("%-18s%10d\n", "# passed-pairs:", $ok);
print STDERR sprintf("%-18s%10d\n", "# failed-reads:", $no);
exit 0;
