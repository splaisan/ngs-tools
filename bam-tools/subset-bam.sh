#! /usr/bin/env bash
## script: 'subset-bam.sh'
## ©SP-BITS, 2016-05-06
# take a subset of a bam file
#
# required:
# Picard Version: 2.1.0

usage='# Usage: subset-bam.sh -i <input.bam> -p <probability (0-1, eg. 0.1 for 10% subset)>'

while getopts "i:p:h" opt; do
  case $opt in
    i) input=${OPTARG} ;;
    p) prob=${OPTARG} ;;
    h) echo "${usage}" >&2; exit 0 ;;
    \?) echo "Invalid option: -${OPTARG}" >&2; exit 1 ;;
    *) echo "this command requires 2 arguments, try -h" >&2; exit 1 ;;
  esac
done

# check parameters
if [ -z "${input}" ]; then
   echo "# no BAM file provided!"
   echo "${usage}"
   exit 1
fi

if [ ! -f "${input}" ]; then
   echo "# BAM file not found!"
   echo "${usage}"
   exit 1
fi

if [[ ! "$prob" =~ ^[0-9\.]+$ ]]; then
   echo "# prob should be a decimal number between 0 and 1!"
   echo "${usage}"
   exit 1
fi

inname=$(basename ${input})
outfolder=$(dirname ${input})
outunsrt=${outfolder}"/unsrted_"${prob}"-"${inname}
outpath=${outfolder}"/"${prob}"-"${inname}

# P=0.1 should succeed with a 10% chance (produce a 10% subset)
java -jar $PICARD/picard.jar DownsampleSam \
	I=${input} \
	O=${outunsrt} \
	R=1 \
	P=${prob} \
	VALIDATION_STRINGENCY=LENIENT \
	QUIET=true \
	2>${outfolder}"/DownsampleSam_unsrted_"${prob}"-"${inname}.err


# reads are (re)-sorted by name to keep pairs together
java -jar $PICARD/picard.jar SortSam \
	I=${outunsrt} \
	O=${outpath} \
	SO=queryname \
	CREATE_INDEX=false \
	QUIET=true \
	VALIDATION_STRINGENCY=LENIENT \
	2>${outfolder}"/DownsampleSam_"${prob}"-"${inname}.err
