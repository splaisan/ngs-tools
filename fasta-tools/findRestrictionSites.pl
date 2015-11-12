#!/usr/bin/perl -w

# http://seqanswers.com/forums/showthread.php?t=7906

use strict;
use Data::Dumper;
use Getopt::Long;

my $genome_version = '';
my $chromosome = '';
my $re_site = '';

GetOptions ('genome_version=s'=>\$genome_version, 'chromosome=s'=>\$chromosome, 're_site=s'=>\$re_site);
unless ($genome_version && $chromosome && $re_site){
  print "\n\nUsage:\nfindRestrictionSites.pl --genome_version=hg19  --chromosome=22  --re_site=GAATTC\n\n";
  exit();
}

#Get a chromosome sequence from UCSC for testing purposes - if it has already been downloaded, don't download again
my $chr_sequence;
my $chr_file = "chr$chromosome".".fa.gz";
unless (-e $chr_file){
  system("wget http://hgdownload.cse.ucsc.edu/goldenPath/$genome_version/chromosomes/chr"."$chromosome".".fa.gz");
}
{
  local($/);
  open(my $fh, "zcat $chr_file |") or die "\n\nFailed to open file handle\n";
  $chr_sequence = <$fh>;
}

#Get the reverse complement of the RE site - for RE sites that are not palindromes
my $re_site_r = reverse($re_site);
$re_site_r =~ tr/ACGTacgt/TGCAtgca/;

#Get all the positions within the chromosome sequence that match the RE site sequence - using the subroutine below to handle the regex
#Print each position as: chr:$start-end
my %positions;
&match_all_positions($re_site, $chr_sequence);
&match_all_positions($re_site_r, $chr_sequence);
foreach my $start (sort {$a <=> $b} keys %positions){
  print "$positions{$start}{pos}\n";
}
exit();


#Handy regex routine from: http://stackoverflow.com/questions/87380/how-can-i-find-the-location-of-a-regex-match-in-perl
sub match_all_positions {
  my ($regex, $string) = @_;
  while ($string =~ /$regex/g) {
    $positions{$-[0]}{pos} = "chr$chromosome:$-[0]-$+[0]";
  }
  return ();
}

