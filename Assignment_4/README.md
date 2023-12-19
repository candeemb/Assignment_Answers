# Assigment 4 - Use of BLAST to find the orthologue pairs between species Arabidopsis and S. pombe.

The objective of this assignment, proposed by Mark Wilkinson, is to detect orthologues using RBH technique and [BLAST](https://es.wikipedia.org/wiki/BLAST).

*"That is, you take protein X in Species A, and BLAST it against all proteins in Species B.  The top (significant!!) hit in Species B is then BLASTed against all proteins in Species A.  If it’s top (significant) hit is the Protein X, then those two proteins are considered to be Orthologue candidates."*


## How to run:

To run the program execute the following command:

```
$ ruby main.rb <arabidopsis_input_file.fa> <spombe_input_file.fa> <output_report_file.txt>
```

In our case:

```
$ ruby main.rb TAIR10_cds_20101214_updated.fa pep.fa BRH_report.txt
```

The script will create a directory for the databases and the report file with the results report.

The execution time of this process may take several minutes, or even hours, depending on the available hardware resources.

## Next steps:

Taking into account the characteristics and limitations of the technique and tools used, it would be advisable to carry out new tests and complementary analyses that would allow us to guarantee that the results obtained are true orthologues.

Some of these possible complementary tests are:

* Detection of paralogous genes
* Detection of xenologous genes
* Use of other techniques

With the information we have obtained from these analyses, a possible next step could be to perform phylogenetic analyses, as we have the information from the BLAST alignments. Also, following the line taken during Assignment 3 of this subject, we would look for the GO terms associated with the genes, as well as their KEGG Pathways, looking for synergies, common routes, and common uses that can facilitate the estimation of gene proximity.

* [Progress in quickly finding orthologs as reciprocal best hits: comparing blast, last, diamond and MMseqs2](https://bmcgenomics.biomedcentral.com/articles/10.1186/s12864-020-07132-6)
* [Reciprocal best structure hits: using AlphaFold models to discover distant homologues](https://academic.oup.com/bioinformaticsadvances/article/2/1/vbac072/6749558)

## Requirements:

1. *Ruby Gems*

* [bio 2.0.5](https://rubygems.org/gems/bio)

2. *Packages (Debian 12)*

* [ncbi-blast+ 2.12.0+ds-3](https://packages.debian.org/bookworm/ncbi-blast+)

* [ncbi-blast+-legacy 2.12.0+ds-3](https://packages.debian.org/bookworm/ncbi-blast+-legacy)


## References & Documentation:

* [An Introduction to Sequence Similarity (Homology) Searching](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3820096/)

* [Having a BLAST with bioinformatics (and avoiding BLASTphemy)](https://genomebiology.biomedcentral.com/articles/10.1186/gb-2001-2-10-reviews2002)

* [Homologue, orthologue and Paralogue-Bioinformatics](https://omicstutorials.com/homologue-orthologue-and-paralogue-bioinformatics/)

* [Alineamiento: Analisis computacional de secuencias](http://bioinf.ibun.unal.edu.co/cbib/estudiantes/1-07/alineamiento.pdf)

* [BioRuby](http://bioruby.org/rdoc/)

* [Building a BLAST database with your (local) sequences](https://www.ncbi.nlm.nih.gov/books/NBK569841/)

* [E-value & Bit-score](https://www.metagenomics.wiki/tools/blast/evalue)


## Credits:

For the analysis and development of this task I have collaborated with Álvaro Mellado. 

