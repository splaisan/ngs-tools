#! /usr/bin/env bash
## script: 'CLC-to-BAM.sh'
## ©SP-BITS, 2015 v1.0

# merge mapped BAM data with the unmapped paired and unmapped single reads (fastq.gz)
# BAM and unmapped reads were exported from CLC GWB separately
# final header is taken from the mapping file
# fastq splitter from https://gist.github.com/nathanhaigh/3521724

usage='# Usage: CLC-to-BAM.sh -m <mappings.bam> -p <paired_unmapped.fq(.gz)> -s <single_unmapped.fq(.gz)>'

while getopts "m:p:s:h" opt; do
  case $opt in
    m) mapped=${OPTARG} ;;
    p) paired=${OPTARG} ;;
    s) single=${OPTARG} ;;
    h) echo "${usage}" >&2; exit 0 ;;
    \?) echo "Invalid option: -${OPTARG}" >&2; exit 1 ;;
    *) echo "this command requires 3 arguments, try -h" >&2; exit 1 ;;
  esac
done

# check parameters
if [ -z "${mapped}" ]
then
   echo "# no mapping file provided!"
   echo "${usage}"
   exit 1
fi

if [ -z "${paired}" ]
then
   echo "# no paired unmapped read file provided!"
   echo "${usage}"
   exit 1
fi

if [ -z "${single}" ]
then
   echo "# no single unmapped read file provided!"
   echo "${usage}"
   exit 1
fi

echo
echo "# splitting paired unmapped reads"
gzip -cd ${paired} |
	paste - - - - - - - -  | \
	tee >(cut -f 1-4 | \
	tr "\t" "\n" | bgzip -c > left_unmapped.fq.gz) | \
	cut -f 5-8 | \
	tr "\t" "\n" | bgzip -c > right_unmapped.fq.gz ||
	(echo "# failed splitting paired reads"; exit 1)

echo
echo "# converting fastq to SAM for unmapped paired reads"
java -jar $PICARD/picard.jar FastqToSam \
	F1=left_unmapped.fq.gz \
	F2=right_unmapped.fq.gz \
	SM="paired" \
	O=unmapped_paired.sam

# cleanup or die
if [ $? = 0 ]; then
	rm left_unmapped.fq.gz right_unmapped.fq.gz
else
	echo "# conversion failed for unmapped paired reads"
	exit 1
fi

echo
echo "# converting fastq to SAM for unmapped single reads"
java -jar $PICARD/picard.jar FastqToSam \
	F1=${single} \
	SM="single" \
	O=unmapped_single.sam || \
	(echo "# conversion failed for unmapped single reads"; exit 1)

echo
echo "# merging mapped data with unmapped reads into one BAM file"
samtools merge -f -h ${mapped} \
	merged-${mapped} \
	${mapped} \
	unmapped_paired.sam \
	unmapped_single.sam || \
	(echo "# merge failed"; exit 1)

# cleanup or die
if [ $? = 0 ]; then
	rm unmapped_paired.sam unmapped_single.sam
else
	echo "# conversion failed for unmapped paired reads"
	exit 1
fi

# fix mate information
echo
echo "# fixing mate information with Picard"
java -jar $PICARD/picard.jar FixMateInformation \
	I=merged-${mapped} \
	O=merged-${mapped%%.bam}_fm.bam \
	SO=unsorted \
	&& mv merged-${mapped%%.bam}_fm.bam merged-${mapped}

# validate BAM
echo
echo "# validate the merged file with Picard"
java -jar $PICARD/picard.jar ValidateSamFile \
	I=merged-${mapped%%.bam}.bam  \
	M=SUMMARY
