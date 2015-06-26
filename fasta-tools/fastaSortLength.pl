#!/usr/bin/perl -w

# Sort multifasta by size (decr or incr)
# loads the full data into RAM for ease, please check your specs!
# supports compressed files (zip, gzip, bgzip)
#
# Stephane Plaisance (VIB-NC+BITS) 2015/06/21; v1.0
# add min and max; v1.1
#
# visit our Git: https://github.com/BITS-VIB

use strict;
use File::Basename;
use Bio::SeqIO;
use Getopt::Std;
use File::Tee qw(tee);

my $usage="## Usage: fastaSortlength.pl <-i fasta-file> <-o size-order ('i'=increasing | 'd'=decreasing)>
# Additional optional parameters are:
# <-m minsize (undef)>
# <-x maxsize (undef)>
# <-h to display this help>";

# disable buffering to get output during long process (loop)
$|=1;

####################
# declare variables
####################
getopts('i:o:m:x:h');
our($opt_i, $opt_o, $opt_m, $opt_x, $opt_h);

my $fastain = $opt_i || die $usage."\n";
my $order = $opt_o || die $usage."\n";
$order =~ /^(i|d)$/ || die "# order should be 'i'=increasing | 'd'=decreasing !";
my $minlen = $opt_m || undef;
my $maxlen = $opt_x || undef;
defined($opt_h) && die $usage."\n";

# define filehandlers
my $in = OpenArchiveFile($fastain);
my $fastaout = $order."_".$fastain;
my $out = Bio::SeqIO -> new(-file => ">$fastaout", -format => 'Fasta');

# variables
our $count = 0;
our $kept = 0;
our $shorter = 0;
our $longer = 0;
our $width = 0;
our $kept_width = 0;
our @AoH = ();
our @sorted = ();

# load full fasta into array
print STDERR "# loading sequences in RAM\n";

while( my $seq_obj = $in->next_seq() ) {
	# count
	$count ++;

	# get sequence length
	my $len = $seq_obj->length;
	$width += $len;

	# filter by size
	if (defined $minlen && $len < $minlen) {
		$shorter++;
		next;
		}

	if (defined $maxlen && $len > $minlen){
		$longer++;
		next;
		}

	# else proceed
	$kept++;
	$kept_width += $len;
	push @AoH, {
		seqobj => $seq_obj,
		seqlen => $seq_obj->length
		};
	}

my $totkb = printf( "%.3f", ($width/1000) );
my $keptkb = printf( "%.3f", ($kept_width/1000) );

# counts
print STDERR "# processed: ".$count." sequences\n";
print STDERR "# tot-width: ".$totkb." kb\n";
print STDERR "# kept: ".$kept." sequences\n";
print STDERR "# kept width: ".$keptkb." kb\n";
print STDERR "# too short: ".$shorter." sequences\n";
print STDERR "# too long: ".$longer." sequences\n";

# sort AoH by length
print STDERR "# .... sorting sequences\n";

if ($order eq "i") {
	@sorted =  sort { $a->{seqlen} <=> $b->{seqlen} } @AoH;
	} else {
		@sorted =  sort { $b->{seqlen} <=> $a->{seqlen} } @AoH;
		}

# output sorted data to file
print STDERR "# .... saving sorted sequences to new file\n";

foreach my $hash_ref (@sorted) {
	$out->write_seq($hash_ref->{seqobj});
	}

# output sorted data to file
print STDERR "# sorted ".$kept." records out of ".$count."\n\n";

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
    elsif ($infile =~ /.gz$|.zip$/) {
    $FH = Bio::SeqIO -> new(-file => "gzip -cd $infile |", -format => 'Fasta');
    } else {
	die ("$!: do not recognise file type $infile");
	# if this happens add, the file type with correct opening proc
    }
    return $FH;
}
