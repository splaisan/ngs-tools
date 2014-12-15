![ngstools](pictures/toolbox.png) - NGS-Tools
========
# Analysis tools

## **locus2genes**

A script using R packages to query biomaRt and fetch genes in a given locus (loci) before computing GO enrichment on the gene list. Please read the [dedicated page](locus2genes/README.md) for more info.

# Formatting tools for FASTA data

## **dedupFastaSeq.pl**

Will parse a multifasta file and keep only one copy of each sequence based on its name (no sequence comparison is operated). Requires BioPerl to work.

# Formatting tools for FASTQ data

## **fastq_detect.pl**

The perl script **[fastq_detect.pl](fastq-tools/fastq_detect.pl)** is parsing n-lines of fastQ data to identify the range of ascii score used and matching them to what is expected for the main flavors known today. The result is a list of compatible fastQ versions.

## **avgQdist2linePlot.R**

The R script **[avgQdist2linePlot.R](fastq-tools/avgQdist2linePlot.R)** is taking output from the popular [fastx toolkit](http://hannonlab.cshl.edu/fastx_toolkit/) to plot a normalized line graph (PDF) of base frequencies. This once was needed to identify base bias across reads. One example output is saved [here](pictures/avgQdist2linePlot.png).

## **isFastqUniq.sh**

The awk script **[isFastqUniq.sh](fastq-tools/isFastqUniq.sh)** is parsing fastQ data to identify duplicate read names and prints out names of reads present more than once. This is a very basic script.

## **deduplicateFastq.pl**

The perl script **[deduplicateFastq.pl](fastq-tools/deduplicateFastq.pl)** is parsing two paired fastQfiles (can be flat or .gz) and filters out reads found more than once based on their exact names. This script was developped for data extracted from BAM that presented the same reads multiple times due to alternate mapping results. The script will end if pair sync is not valid (same name for both mates) or if fastq 4-line structure is lost.

# Formatting tools for SAM / BAM data

## **uniq_mappings.pl**

The Perl **[uniq_mappings.pl](bam-tools/uniq_mappings.pl)** is reading from a **name-sorted** BAM file (*verified from the presence of 'SO:queryname' in the first header line*) and outputting 'uniquely mapped' and 'multiple-mapped' reads to two separate **SAM** files with adapted headers.

Usage: This script was created to extract uniquely mapped reads from a public BAM file and convert the mapping data back to FastQ. The obtained reads where then re-mapped to another reference genome build.

<h4>Please send comments and feedback to <a href="mailto:bits@vib.be">bits@vib.be</a></h4>

------------

![Creative Commons License](http://i.creativecommons.org/l/by-sa/3.0/88x31.png?raw=true)

This work is licensed under a [Creative Commons Attribution-ShareAlike 3.0 Unported License](http://creativecommons.org/licenses/by-sa/3.0/).
