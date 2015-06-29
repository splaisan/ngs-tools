#!/usr/bin/perl

# Filter multifasta file by min and max sequence lengths
# adapted from http://seqanswers.com/forums/archive/index.php/t-13966.html
#
# Stephane Plaisance (VIB-NC+BITS) 2015/02/18; v1.0
# 2015/06/21; v1.1
# supports compressed files (zip, gzip, bgzip)
#
# visit our Git: https://github.com/BITS-VIB

use warnings;
use strict;
use Bio::SeqIO;
use Getopt::Std;

my $usage="## Usage: fastaFiltLength.pl <-i fasta_file (required)>
# Additional optional parameters are:
# <-o outfile_name (filtered_)>
# <-m minsize (undef)>
# <-x maxsize (undef)>
# <-h to display this help>";

####################
# declare variables
####################
getopts('i:o:m:x:h');
our ($opt_i, $opt_o, $opt_m, $opt_x, $opt_h);

my $infile = $opt_i || die $usage."\n";
my $outfile = $opt_o || "filtered_".$infile;
my $minlen = $opt_m || undef;
my $maxlen = $opt_x || undef;
defined($opt_h) && die $usage."\n";

# right limits
if ( defined $minlen && defined $maxlen && $maxlen < $minlen) {
	print $usage;
	exit();
}

# filehandles
my $seq_in = OpenArchiveFile($infile);
my $seq_out = Bio::SeqIO -> new( -format => 'Fasta', -file => ">$outfile" );

# counters
my $count = 0;
my $kept = 0;
my $shorter = 0;
my $longer = 0;

while( my $seq = $seq_in -> next_seq() ) {
	$count++;
	my $lseq = $seq->length;

	# filter by size
	if (defined $minlen && $lseq < $minlen) {
		$shorter++;
		next;
		}

	if (defined $maxlen && $lseq > $minlen){
		$longer++;
		next;
		}

	# otherwise print out
	$kept++;
	$seq_out -> write_seq($seq);
}

# print counts to stderr
print STDERR "# processed: ".$count." sequences\n";
print STDERR "# too short: ".$shorter." sequences\n";
print STDERR "# too long: ".$longer." sequences\n";
print STDERR "# kept: ".$kept." sequences\n";

exit 0;

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
    $FH = Bio::SeqIO -> new(-file => "unzip -c $infile |", -format => 'Fasta');
    } else {
	die ("$!: do not recognise file type $infile");
	# if this happens add, the file type with correct opening proc
    }
