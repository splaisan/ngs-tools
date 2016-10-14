#!/usr/bin/perl

# Reverse-Complement multifasta file(s)
# output all in capital letters
#
# Stephane Plaisance (VIB-NC+BITS) 2016/10/14; v1.0
#
# visit our Git: https://github.com/BITS-VIB

use warnings;
use strict;
use Bio::SeqIO;
use Getopt::Std;
use File::Basename;

my $version = "1.0";

my $usage="## Usage: fastaRevComp.pl <-i fasta_file (required)>
# script version:".$version."
# Additional optional parameters are:
# <-o outfile_name (revcomp_)>
# <-z zip results (default OFF)>
# <-h to display this help>";

####################
# declare variables
####################
getopts('i:o:x:zh');
our ($opt_i, $opt_o, $opt_x, $opt_z, $opt_h);

my $infile = $opt_i || die $usage."\n";
my $outfile = $opt_o || undef;
my $zipit = defined($opt_z) || undef;
defined($opt_h) && die $usage."\n";

# bioperl filehandles
my $in = OpenArchiveFile($infile);
my $out;

# remove possible suffixes from filename
my @sufx = (
	".fa", ".fasta", ".fsa", ".fna",
	".fa.gz", ".fasta.gz", ".fsa.gz", ".fna.gz",
	".fa.zip", ".fasta.zip", ".fsa.zip", ".fna.zip",
	".fa.bz2", ".fasta.bz2", ".fsa.bz2", ".fna.bz2", 
	);

# ins and outs
my $outpath = dirname($infile);
my $outbase = basename($infile, @sufx);

if ( ! defined($outfile)) {
	$outfile = $outpath."/rev_comp-".$outbase.".fa";
}

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
	
# counters
my $count = 0;

while( my $seq_obj = $in->next_seq() ) {
	$count++;
	# rename header
	my $seqid = $seq_obj->id;
	$seq_obj->id("rev_comp-".$seqid);
	# rev comp sequence
	my $seq = $seq_obj->seq();
	# reverse sequence
	my $rev = reverse($seq);
	# reverse complement
	my $revcmp = $rev; 
	$revcmp =~ tr[ACGTNacgtn][TGCAN];
	$seq_obj->seq($revcmp);
	$out->write_seq($seq_obj);
}

# cleanup
undef $in;
undef $out;
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
