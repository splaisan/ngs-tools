#!/usr/bin/perl -w
use strict;

# Script name: uniq_mappings.pl (v1.0)
#
# Description: 
#  filter a name-sorted BAM file containing multiple mapping reads
#  save uniquely mapped reads to 'unique_mappers.sam/bam' 
#  save multi-mappers to 'multiple_mappers.sam/bam'
#
# Requirements:
# 'queryname' sorted input (e.g. samtools sort file.bam sorted-file)
#
# Example usage
# samtools view -h sorted-file.bam | uniq_mappings.pl
#
# Stéphane Plaisance - VIB-BITS - February-26-2014 

# write directly, do not buffer
$|=1;

# define @PG string for commenting SAM/BAM output
my $pgustring = join("\t","\@PG","ID:uniq_mappings.pl","PN:uniq_mappings.pl","VN:1.0","DS:unique-mappers\n");
my $pgmstring = join("\t","\@PG","ID:uniq_mappings.pl","PN:uniq_mappings.pl","VN:1.0","DS:multi-mappers\n");

# create two output SAM files
#open (UNI, "> unique_mappers.sam") || die "cannot create output file!";
#open (MULT, "> multiple_mappers.sam") || die "cannot create output file!";

# create BAM files (requires samtools in your PATH)
open (UNI, "| samtools view -Sb - > unique_mappers.bam") || die "cannot create output file!";
open (MULT, "| samtools view -Sb - > multiple_mappers.bam") || die "cannot create output file!";

# flag for files with multiple mappers# > 2
my $fl=0;
my $firstread = 1;

# read counters
my $count = 0;
my $ucount = 0;
my $mcount = 0;

# read first line from stream
print STDERR "# starting filtering reads ('.'=100'000)\n";
my $line = <>;

# test for sorting mode
$line =~ m/SO\:queryname/ || die "## Run aborted: input does not report SO:queryname!\n please sort by queryname or make sure the header was passed to this script\n\n\n";
 
my @lfields = split("\t", $line);

# parse file
while (my $next = <>) {
my @nfields = split("\t", $next);

# unique read name?
if ($line =~ /^@/) {
	# header line
	printout($line, "h");
} else {
	# first read line, add @PG lines to both files
	if ($firstread == 1) {
		printout($pgustring, "u");
		printout($pgmstring, "m");
		$firstread = 0;
	} elsif ($nfields[0] ne $lfields[0]) {
		# first time? print @PG line
		$count ++;
		# read name is different 'unique mapper' or 'last in multiple group'
		if ($fl == 0) {
			# truely uniq
			printout($line,"u");
			$ucount ++;
		} else {
			# last in group
			$mcount ++;
			printout($line,"m");
			# reset flag	
			$fl=0;
		}
	} else {
		$count ++;
		# read name is identical to previous
		$fl = 1;
		printout($line,"m");
		$mcount ++;
	}
}
			
# pop and loop
$line = $next;
@lfields = @nfields;
$count =~ /00000$/ && print STDERR ".";
$count =~ /000000$/ && print STDERR "|";
}

print "\n# finished filtering $count reads\n";
print "#   of which $ucount unique reads\n";
print "#   and $mcount reads with multiple mappings\n";
exit 0;

#### Subs ####
sub printout {
my $li = shift;
my $ty = shift;

if ($ty eq "u") {
	print UNI $li;
} elsif ($ty eq "m") {
	print MULT $li;
} elsif ($ty eq "h") {
	# this is a header line and should be saved in both files
	print UNI $li;
	print MULT $li;
} else {
	# yet unsupported type
}
# end sub
}
