ngstools
========

# **fastq_detect.pl**

A perl script parsing n-lines of fastQ data to identify teh rang eof ascii score used and mathicng them to what is expected for the main flavors known today. The result is a list of compatible fastQ versions.

# **avgQdist2linePlot.R**

A R script taking output from the popular [fastx toolkit](http://hannonlab.cshl.edu/fastx_toolkit/) to plot a normalized line graph (PDF) of base frequencies. This once was needed to identify base bias across reads. One example output is saved [here](pictures/avgQdist2linePlot.png).

# **locus2genes**

A script using R packages to query biomaRt and fetch genes in a given locus (loci) before computing GO enrichment on the gene list. Please read the [dedicated page](locus2genes/README.md) for more info.


<h4>Please send comments and feedback to <a href="mailto:bits@vib.be">bits@vib.be</a></h4>

------------

![Creative Commons License](http://i.creativecommons.org/l/by-sa/3.0/88x31.png?raw=true)

This work is licensed under a [Creative Commons Attribution-ShareAlike 3.0 Unported License](http://creativecommons.org/licenses/by-sa/3.0/).
