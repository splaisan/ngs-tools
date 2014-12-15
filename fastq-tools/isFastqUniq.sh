#!/bin/bash

# isfastquniq.sh
# find duplicate names in fastQ passed by pipe
# Stéphane Plaisance - VIB-BITS - Mar-22-2012 v1

awk '{if (FNR%4==1) {
	cnt[$1]++;
	if (cnt[$1]>1) print $1;
	};
}' -
