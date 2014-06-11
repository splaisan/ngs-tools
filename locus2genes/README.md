**locus2genes.R**
===========

A standalone R scripts to get all genes in a given genomic region using **biomaRt** and optionally compute GO enrichment based on this list and a reference-set (or the full genome)

# Introduction

Users may identify a locus linked to a trait of interest and need to identify all genes present in that region. This can be done easily using the [BioMart GUI (http://www.biomart.org)](http://www.biomart.org).

The next step after identify the gene-list could be to ask wether this region presents enrichment in some gene ontology terms. It is indeed common that genes located in a genomic region are co-regulated by environmental conditions due to shared enhancers. Such genes may participate to a common biological process or belong to a common Molecular function in which case these annotations should be apparent when performing enrichment analysis of the gene list using GO.

This can again also be done using Biomart and their recent [Biomart GUI enrichment tool (http://central.biomart.org/enrichment/#/gui/Enrichment)](http://central.biomart.org/enrichment/#/gui/Enrichment). The WEB tool takes accession lists including entrezID lists or lists of ensemble genes, has less options than our version, but also reports genes that led to GO enriched terms (not implemented in our tool).

We provide this facility in the **locus2genes.R** R-script as detailed below. Our script works for human and mouse but can easily be adapted for more organisms for which ensemble and GO data exist.

We are aware that much more can be done using the bioconductor package topGO together with other packages and more R-code.

# Requirements

In order to use the **locus2genes.R** scripts, you will need [R] and RScript installed on your computer (done by most package installers including yum and apt-get).

You will also need the following [R] packages:

* **optparse** [http://cran.r-project.org/web/packages/optparse/](http://cran.r-project.org/web/packages/optparse/) to handle command line arguments.

* **biomaRt** [http://www.bioconductor.org/packages/release/bioc/html/biomaRt.html] to interact with ensembl online resources.

* **topGO** [http://www.bioconductor.org/packages/release/bioc/html/topGO.html] to compute GO enrichment on lists obtained from biomaRt.

You can install all the required packages with the following code in [R] or RStudio. The installation of the genome packages will take some time as these databases are quite large.

```
## while in R or RStudio with admin rights:
# connect to the BiocInstaller repo
source("http://bioconductor.org/biocLite.R")

# first install the basic bioconductor package set (can take some time!)
biocLite()

# then install required packages
biocLite("biomaRt")
biocLite("topGO")

# for enrichment analysis of human data
biocLite("org.Hs.eg.db")

# for enrichment analysis of mouse data
biocLite("org.Mm.eg.db")
```

# The locus2genes.R scripts manpage

Type **locus2genes.R -h** will list all available parameters

```
Usage: locus2genes.R [options]

Options:
	-r REGION, --region=REGION
		genomic region(s)
              	- format: 'chr:from:to<:strand>' eg: "1:1:100000"
              	- if multiple, comma-separated and no-space eg: "1:1:100000,2:1000:15000"

	-o ORGANISM, --organism=ORGANISM
		mouse=mm: (GRCm38.p2) or human=hs (GRCh37.p13) [default: hs]

	-e ENRICHMENT, --enrichment=ENRICHMENT
		compute MF/BP enrichment (yes/no) [default: no]

	-c ONTOLOGY, --ontology=ONTOLOGY
		Ontology class to be used for enrichment (BP/MF/CC) [default: BP]

	-n MINNODES, --minnodes=MINNODES
		keeping a GO term with minimum nodes of (5-10 for stringency) [default: 1]

	-b BACKGROUND, --background=BACKGROUND
		user provides a list of 'entrezID's as background, (yes/no) [default: no]

	-f BACKGROUNDFILE, --backgroundfile=BACKGROUNDFILE
		file with background 'entrezID' list for stats (one ID per line)


	-t TOPRESULTS, --topresults=TOPRESULTS
		return N top results from stat test [default: 10]

	-h, --help
		Show this help message and exit
```

# Examples

## A simple run to get all genes on human chromosome 3 in the region 2000000-4000000

The output of the run is stored in two files

* A file with some details about the 16 genes found in that locus
```
$> locus2genes.R -r 3:2000000:4000000

ensembl_gene_id  external_gene_id  entrezgene  chromosome_name  start_position  end_position  strand
ENSG00000225044  RP11-204C23.1     NA          3                2004065         2029154       -1
ENSG00000223040  RN7SKP144         NA          3                2130617         2130895       -1
ENSG00000144619  CNTN4             152330      3                2140497         3099645       1
ENSG00000227588  CNTN4-AS2         100873976   3                2152093         2185925       -1
ENSG00000230398  AC026882.1        NA          3                2403942         2404422       1
ENSG00000225310  DNAJC19P4         NA          3                3026915         3027259       -1
ENSG00000237990  CNTN4-AS1         NA          3                3080717         3102829       -1
ENSG00000091181  IL5RA             3568        3                3111233         3168297       -1
ENSG00000253049  SNORA43           NA          3                3144597         3144699       1
ENSG00000072756  TRNT1             51095       3                3168600         3192563       1
ENSG00000113851  CRBN              51185       3                3190676         3221394       -1
ENSG00000271870  RP11-97C16.1      NA          3                3194626         3195119       1
ENSG00000223727  AC026188.1        NA          3                3292371         3668980       -1
ENSG00000223036  AC024158.1        NA          3                3688140         3688262       1
ENSG00000144455  SUMF1             285362      3                3742498         4508965       -1
ENSG00000175928  LRRN1             57633       3                3841121         3889387       1
```

REM: As seen, **7** of the **16** genes in the locus have a NCBI **entrezID** and are potentially annotated with GO terms.

* A second file is saved with the list of entrezIDs (here 7 rows)

```
152330
100873976
3568
51095
51185
285362
57633
```

**NOTE:** This file/list can be used to upload to your favorite annotation software (DAVID, IPA, GeneGO) or use as background reference for a new locus2genes query with enrichment (BioMart enrichment GUI, or see below)


## An example with more than one locus provided as a comma delimited list

We search for genes on loci of chromosome 3 and chromosome 5.

```
$>locus2genes.R -r 3:3500000:4000000,5:1700000:1900000

ensembl_gene_id  external_gene_id  entrezgene  chromosome_name  start_position  end_position  strand
ENSG00000223727  AC026188.1        NA          3                3292371         3668980       -1
ENSG00000223036  AC024158.1        NA          3                3688140         3688262       1
ENSG00000144455  SUMF1             285362      3                3742498         4508965       -1
ENSG00000175928  LRRN1             57633       3                3841121         3889387       1
ENSG00000263746  MIR4277           100422966   5                1708900         1708983       -1
ENSG00000260066  CTD-2587M23.1     NA          5                1725264         1728287       1
ENSG00000171421  MRPL36            64979       5                1798500         1801480       -1
ENSG00000145494  NDUFS6            4726        5                1801514         1816719       1
ENSG00000249966  CTD-2194D22.1     NA          5                1851064         1851611       1
ENSG00000250417  CTD-2194D22.2     101929034   5                1856084         1856682       -1
ENSG00000113430  IRX4              50805       5                1877541         1887350       -1
ENSG00000249116  CTD-2194D22.3     NA          5                1884080         1884763       1
ENSG00000249326  CTD-2194D22.4     101929081   5                1887446         1900607       1
```

## The same query but looking also to the enrichment in GO:BP (default choice) against the whole genome

We use here all default settings and only ask to compute enrichment after retrieving the gene list ('-e yes').

```
$>locus2genes.R -r 3:3500000:4000000,5:1700000:1900000 -e yes
```

One additional file is created that contains results of enrichment in 'BP' (for: biological process) for the gene-list. Other GO categories ('MF' and 'CC') can be enriched with the '-c' parameters, the enrichment can be tuned in different ways using additional parameters (run locus2genes.R -h for more details).

The resulting file 'BP-enrichment_min-1_hs-3-3500000-4000000_5-1700000-1900000_vs_all.txt' contains information about the enrichment and the top 10 results (more can be obtained using the '-n' parameter).

```
#### locus2genes (©SP:BITS2014, v1.0), 2014-06-102014-06-10 16:28:20
### GO-BP enrichment results for locus: 3:3500000:4000000,5:1700000:1900000 (8 entrezIDs)
## against:'all' hs genes (25788 entrezIDs)
## organism :  hsapiens_gene_ensembl 

### GOdata summary:  

------------------------- topGOdata object -------------------------

 Description:
   -  Fisher enrichment test 

 Ontology:
   -  BP 

 25788 available genes (all genes from the array):
   - symbol:  115286 100873766 100506680 100506697 100873972  ...
   - 8  significant genes. 

 14850 feasible genes (genes that can be used in the analysis):
   - symbol:  115286 221178 685 2520 9001  ...
   - 4  significant genes. 

 GO graph (nodes with at least  1  genes):
   - a graph with directed edges
   - number of nodes = 12633 
   - number of edges = 29073 

------------------------- topGOdata object -------------------------


## results for Fisher

Description: Fisher enrichment test 
Ontology: BP 
'classic' algorithm with the 'fisher' test
12633 GO terms scored: 4 terms with p < 0.01
Annotation data:
    Annotated genes: 14850 
    Significant genes: 4 
    Min. no. of genes annotated to a GO: 1 
    Nontrivial nodes: 86 


### Enrichment results 


### Fisher test summary : 
 
        GO.ID                                        Term Annotated Significant
1  GO:0048561          establishment of organ orientation         2           1
2  GO:0048560 establishment of anatomical structure or...         3           1
3  GO:0070584                 mitochondrion morphogenesis        15           1
4  GO:0010259              multicellular organismal aging        30           1
5  GO:0006120 mitochondrial electron transport, NADH t...        39           1
6  GO:0042773    ATP synthesis coupled electron transport        50           1
7  GO:0042775 mitochondrial ATP synthesis coupled elec...        50           1
8  GO:0006687         glycosphingolipid metabolic process        62           1
9  GO:0006119                   oxidative phosphorylation        64           1
10 GO:0072358           cardiovascular system development       826           2
   Expected     Fis
1      0.00 0.00054
2      0.00 0.00081
3      0.00 0.00403
4      0.01 0.00806
5      0.01 0.01046
6      0.01 0.01340
7      0.01 0.01340
8      0.02 0.01660
9      0.02 0.01713
10     0.22 0.01720


---------
## REFERENCE: 
[1] "Adrian Alexa and Jorg Rahnenfuhrer (2010). topGO: topGO: Enrichment analysis for Gene Ontology. R package version 2.17.0. "
```

## An example with 'GO'-enrichment against a user-defined background (universe)

Computing enrichment against the full genome (default) can lead to underestimating interesting categories. Users may prefer to enrich a locus as compared to a larger region encompassing it (eg: the full chromosome!). This can be achieved by providing a custom background list of entrezIDs. This list can be built externally or obtained from an independent **locus2genes.R** run.

In our next example, we generate the full list of genes on chromosomes 3 and 5 as background set and use this list to look for enrichment in the 2 loci from the former example (rem: the length of chr3 and chr5 can be obtained from the web or estimated).

### Preparing the background set from two full chromosomes

```
$>locus2genes.R -r 3:1:198022430,5:1:180915260
```

The second file generated during this run reports all genes on chr3 and chr5, it is named 'entrezIDs_3-1-198022430_5-1-180915260_hs.txt' and contains **2593** entrezIDs.

### Using the custom background set for GO enrichment

```
$>locus2genes.R -r 3:3500000:4000000,5:1700000:1900000 -e yes -b yes -f entrezIDs_3-1-198022430_5-1-180915260_hs.txt
```

The results of the enrichment are slightly different from above, as expected with a more focussed background set. Thi sis obviously a toy example and you will need to build your own local background based on a relevant biological hypotheses.

```
#### locus2genes (©SP:BITS2014, v1.0), 2014-06-102014-06-10 16:47:59
### GO-BP enrichment results for locus: 3:3500000:4000000,5:1700000:1900000 (8 entrezIDs)
## against:'entrezIDs_3-1-198022430_5-1-180915260_hs.txt' (2593 entrezIDs)
## organism :  hsapiens_gene_ensembl 

### GOdata summary:  

------------------------- topGOdata object -------------------------

 Description:
   -  Fisher enrichment test 

 Ontology:
   -  BP 

 2593 available genes (all genes from the array):
   - symbol:  10752 101927193 101927215 27255 152330  ...
   - 8  significant genes. 

 1516 feasible genes (genes that can be used in the analysis):
   - symbol:  10752 27255 152330 3568 51095  ...
   - 4  significant genes. 

 GO graph (nodes with at least  1  genes):
   - a graph with directed edges
   - number of nodes = 7026 
   - number of edges = 15923 

------------------------- topGOdata object -------------------------


## results for Fisher

Description: Fisher enrichment test 
Ontology: BP 
'classic' algorithm with the 'fisher' test
7026 GO terms scored: 3 terms with p < 0.01
Annotation data:
    Annotated genes: 1516 
    Significant genes: 4 
    Min. no. of genes annotated to a GO: 1 
    Nontrivial nodes: 86 
    

### Enrichment results 


### Fisher test summary : 
 
        GO.ID                                        Term Annotated Significant
1  GO:0048560 establishment of anatomical structure or...         2           1
2  GO:0048561          establishment of organ orientation         2           1
3  GO:0070584                 mitochondrion morphogenesis         2           1
4  GO:0006120 mitochondrial electron transport, NADH t...         5           1
5  GO:0006119                   oxidative phosphorylation         6           1
6  GO:0010259              multicellular organismal aging         6           1
7  GO:0042773    ATP synthesis coupled electron transport         6           1
8  GO:0042775 mitochondrial ATP synthesis coupled elec...         6           1
9  GO:0044255            cellular lipid metabolic process        86           2
10 GO:0022900                    electron transport chain         9           1
   Expected    Fis
1      0.01 0.0053
2      0.01 0.0053
3      0.01 0.0053
4      0.01 0.0131
5      0.02 0.0158
6      0.02 0.0158
7      0.02 0.0158
8      0.02 0.0158
9      0.23 0.0177
10     0.02 0.0236


---------
## REFERENCE: 
[1] "Adrian Alexa and Jorg Rahnenfuhrer (2010). topGO: topGO: Enrichment analysis for Gene Ontology. R package version 2.17.0. "
```

**Please read the information about the other available optional parameters to tune this utility to best fit your needs.*


# REFERENCES

When using this code, please cite the makers of the different embedded packages.

------------
enjoy!

<h4>Please send comments, **error reports**, and feedback to <a href="mailto:bits@vib.be">bits@vib.be</a></h4>
------------

![Creative Commons License](http://i.creativecommons.org/l/by-sa/3.0/88x31.png?raw=true)

This work is licensed under a [Creative Commons Attribution-ShareAlike 3.0 Unported License](http://creativecommons.org/licenses/by-sa/3.0/).
