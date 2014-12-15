#!/usr/bin/perl

# Filter paired FastQ files (flat or gzipped)
# keep only pairs not found before in that file
# recompress output using bgzip (indexable)
#
# SP:BITS, 2014-12-15 v1.0

use strict;
use warnings;

# do not buffer writes
$|=1;

my $usage="deduplicateFastq.pl <first fastq file of a pair (name-1*)>";
@ARGV == 1 || die $usage."\n";

my $fastq1 = "${ARGV[0]}";
my $fastq2 = $fastq1;
$fastq2 =~ s/\-1/\-2/;

my $FQ1 = OpenArchiveFile ($fastq1);
my $FQ2 = OpenArchiveFile ($fastq2);

open (OUT1, " | bgzip > ".$fastq1."_unique.fq.gz") || die $!;
open (OUT2, " | bgzip > ".$fastq2."_unique.fq.gz") || die $!;
open (DUPLO, "> ".$fastq1."-duplos.txt") || die $!;

# declare variables
my $countrec=0;
my $countdup=0;
my %seenhash=();

# load 4 rows from FQ1 and 4 from FQ2
# extract ID of both rows (field1)
# (ID row#1 are identical) {OK} else stop async
# (ID row#1 are new) {OK} else duplo

# parse both files in //
my ($line1, $line2, $line);

while ($line1 = <$FQ1>) {
	my @read1=();
	my @read2=();
	$line2 = <$FQ2>;
	($line1 =~ /^@/ && $line2 =~ /^@/) || die "malformed fastq, no header row found.\n";
	($countrec++ =~ /000000$/) && print STDOUT "."; # every million
	push(@read1, $line1);
	push(@read2, $line2);
	# test for pairing
	($line1 eq $line2) || die "unpaired reads found.\n";
	# get three more lines from each
	for (my $r=0; $r<3; $r++) {
		$line = <$FQ1>;
		push(@read1, $line);
		$line = <$FQ2>;
		push(@read2, $line);
		}
	# test for deja-vu!
	$seenhash{$line1}++;
	if ($seenhash{$line1}>1) {
	 $countdup++;
	 print DUPLO $line1;
	 next;
	 }
	# purge reads to both OUT files
	print OUT1 map { "$_" } @read1;
	print OUT2 map { "$_" } @read2;
	}

undef $FQ1;
undef $FQ2;	
close OUT1;
close OUT2;
close DUPLO;

print STDOUT "# analyzed $countrec read pairs and removed $countdup duplicates\n";
print STDOUT "# the full list of duplicates was saved in ".$fastq1."-duplos.txt\n";

exit 0;

#### Subs ####
sub OpenArchiveFile
{
    # $Filename passed in, handle to file passed out
    my $File = shift; # filename
    my $FH; # file handle

    if ($File =~ /(fq.gz|fastq.gz)$/) #bgzipped
    {
	open ($FH, "gzip -dc $File | ") or die ("$!: can't open file $File");
    }
    elsif ($File =~ /(.fq|.fastq)$/) # not zipped
    {
	open ($FH, "cat $File | ") or die ("$!: can't open file $File");
    }
    else # another file type, not recognised for now, but easy to add another category
    {
	die ("$!: do not recognise file type $File");
    }
    return $FH;
}
