#!/bin/bash

# create a picard list from a BED file and a dict file of the same genome
# Picard lists are 1-based closed coordinates
# while BED is 0-based open (hence +1 below)
#
# SP:NC+BITS 2014; v1.1

# check parameters

usage="Usage: bed2picard-list.sh -i <BED5 input> -d <genome.dict> -o <name>"

while getopts ":i:d:o:h" opt; do
  case $opt in
    i)
      bed=${OPTARG}
      ;;
    d)
      dict=${OPTARG}
      ;;
    o)
      out=${OPTARG}
      ;;
    h)
      echo ${usage} >&2
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    *)
      echo "this command requires arguments, try -h" >&2
      exit 1
      ;;
  esac
done

# test minimal arguments
if [ -z "${bed}" ]
then
   echo  ${usage}
   exit 1
fi

if [ -z "${dict}" ]
then
   echo  ${usage}
   exit 1
fi

# test input files
if [ ! -f ${bed} ]; then
    echo "${bed} file not found!";
    exit 1
fi

# test if BED is a BED5
ncol=$(awk '{print NF}' ${bed} | sort -nu | tail -n 1)

if [ ${ncol} != 5 ]; then
    echo "${bed} should be a 5-columns BED file!";
    exit 1
fi

if [ ! -f ${dict} ]; then
    echo "${dict} file not found!";
    exit 1
fi

# transform BED and add it to the dict header
# ignore BED track header line
(cat ${dict}; awk 'BEGIN{FS="\t"; OFS="\t"} {if (!/^track/) print $1, $2+1, $3, $4, $5}' ${bed}) > ${out}
