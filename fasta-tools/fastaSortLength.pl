#!/usr/bin/perl -w

# Sort multifasta by size (decr or incr)
# loads the full data into RAM for ease, please check your specs!
# supports compressed files (zip, gzip, bgzip)
#
# Stephane Plaisance (VIB-NC+BITS) 2015/06/21; v1.0
# add min and max and zipping; v1.1
#
# Stephane Plaisance (VIB-NC+BITS) 2016/06/01; v2.0
# fixed errors
#
# visit our Git: https://github.com/BITS-VIB

use strict;
use File::Basename;
use Bio::SeqIO;
use Getopt::Std;
use File::Tee qw(tee);
use POSIX qw(strftime);

my $version = "2.0";
my $date = strftime "%m/%d/%Y", localtime;

my $usage="## Usage: fastaSortlength.pl <-i fasta-file> 
# <-o size-order ('i'=increasing | 'd'=decreasing)>
# script version:".$version."
# Additional optional parameters are:
# <-m minsize (undef)>
# <-x maxsize (undef)>
# <-z zip results (default OFF)>
# <-h to display this help>";

# disable buffering to get output during long process (loop)
$|=1;

####################
# declare variables
####################
getopts('i:o:m:x:zh');
our($opt_i, $opt_o, $opt_m, $opt_x, $opt_z, $opt_h);

my $infile = $opt_i || die $usage."\n";
my $order = $opt_o || die $usage."\n";
$order =~ /^(i|d)$/ || die "# order should be 'i'=increasing | 'd'=decreasing !";
my $minlen = $opt_m || undef;
my $maxlen = $opt_x || undef;
my $zipit = defined($opt_z) || undef;
defined($opt_h) && die $usage."\n";

# define filehandlers
my $outpath = dirname($infile);
my @sufx = (
	".fa", ".fasta", ".fsa", ".fna",
	".fa.gz", ".fasta.gz", ".fsa.gz", ".fna.gz",
	".fa.zip", ".fasta.zip", ".fsa.zip", ".fna.zip",
	".fa.bz2", ".fasta.bz2", ".fsa.bz2", ".fna.bz2", 
	);
my $outbase = basename( $infile, @sufx );
my $outfile = $outpath."/".$order."_".$outbase.".fa";

# bioperl filehandles
my $in = OpenArchiveFile($infile);
my $out;

# add zipping option
if ( defined($zipit) ) {
	my $bgzip = `which bgzip`;
	die "No bgzip command available\n" unless ( $bgzip );
	chomp($bgzip);
	my $fh;
	open $fh,  " | $bgzip -c >  $outfile\.gz" || die $!;
	$out = Bio::SeqIO->new( -format => 'Fasta', -fh => $fh);
} else {
	$out = Bio::SeqIO -> new( -format => 'Fasta', -file => ">$outfile" );
}

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
print STDERR "# Fasta sorting & filtering (fastaSortLength.pl v".$version."), ".$date."\n";
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
		seqlen => $len
		};
	}

# width values
my $totmb = $width/1000000;
my $keptmb = $kept_width/1000000;
my $keptpc = 100*$keptmb/$totmb;

# counts
print STDERR "# processed: ".$count." sequences\n";
print STDERR "# tot-width: ".sprintf("%.3f",$totmb)." Mb\n";
print STDERR "# kept: ".$kept." sequences\n";
print STDERR "# kept width: ".sprintf("%.3f",$keptmb)." Mb (".sprintf("%.2f",$keptpc)."%)\n";
print STDERR "# too short: ".$shorter." sequences\n";
print STDERR "# too long: ".$longer." sequences\n";

# sort AoH by length
print STDERR "# .. sorting sequences\n";

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
print STDERR "#\n# sorted ".$kept." records out of ".$count."\n\n";

exit 0;

#### Subs ####
sub OpenArchiveFile {
    my $infile = shift;
    my $FH;
    if ($infile =~ /.fa$|.fasta$|.fna$/) {
    $FH = Bio::SeqIO -> new(-file => "$infile", -format => 'Fasta');
    }
    elsif ($infile =~ /.bz2$/) {
    $FH = Bio::SeqIO -> new(-file => "bzip2 -c $infile |", -format => 'Fasta');
    }
    elsif ($infile =~ /.gz$/) {
    $FH = Bio::SeqIO -> new(-file => "bgzip -cd $infile |", -format => 'Fasta');
    }
    elsif ($infile =~ /.zip$/) {
    $FH = Bio::SeqIO -> new(-file => "unzip -p $infile |", -format => 'Fasta');
    } else {
	die ("$!: do not recognise file type $infile");
	# if this happens add, the file type with correct opening proc
    }
    return $FH;
}
