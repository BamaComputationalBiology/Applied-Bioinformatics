#!/bin/bash

# This script generates the intersections between two bed files, for example miRNAs that occur in introns
# bed format is a tab-separated file with columns as contig"\t"start"\t"stop"\t"feature

samtools faidx *.fasta # make bed-formatted index for the .fasta file

cat *.fai | cut -f 1,2,3 | sort -k1,1 -k2,2n > lengths.txt # make a file with lengths for each contig

cat *.gff3 | grep "maker	gene" | cut -f 1,4,5 | sort | uniq | awk '{ print $1"\t"$2"\t"$3"\tgene" }' | sort -k1,1 -k2,2n > genes.bed # make a bed file with each gene location

mergeBed -i genes.bed > genes_merged.bed # merge genes that overlap

complementBed -i genes.bed -g *lengths.txt > genes_complement.bed # make a bed file with regions that aren't in genes (i.e., intergenic)

cat *.gff3 | grep "maker	exon" | cut -f 1,4,5 | sort | uniq | awk '{ print $1"\t"$2"\t"$3"\texon" }' | sort -k1,1 -k2,2n > exons.bed # make a bedfile with exon locations

mergeBed -i exons.bed > exons_merged.bed # merge overlapping exons

subtractBed -a genes.bed -b exons.bed | sort -k1,1 -k2,2n > introns.bed # make a bed file with regions that are in genes but not exons (i.e., introns)

mergeBed -i introns.bed > introns_merged.bed # merge any overlapping introns

cat *.gff3 | grep "repeatmasker" | cut -f 1,4,5 | sort | uniq | awk '{ print $1"\t"$2"\t"$3"\trepeat" }' | sort -k1,1 -k2,2n > repeats.bed # make a bed file with annotated repeats

mergeBed -i repeats.bed > repeats_merged.bed # merge any overlapping annotated repeats

cat *miRNA.bed | sort -k1,1 -k2,2n > miRNA_sorted.bed # miRNA bed file formatted as contig"\t"start"\t"end"\t"miRNA name

cat *tRNA.bed | sort -k1,1 -k2,2n > tRNA_sorted.bed # tRNA bed file formatted as contig"\t"start"\t"end"\t"tRNA name

intersectBed -b repeats_merged.bed -a miRNA_sorted.bed > miRNA_repeats_intersect.bed # intersection of the two files with the miRNA name printed at the end of the row

intersectBed -b tRNA_sorted.bed -a miRNA_sorted.bed > miRNA_tRNA_intersect.bed # intersection of the two files with the miRNA name printed at the end of the row

intersectBed -b introns_merged.bed -a miRNA_sorted.bed > miRNA_introns_merged.bed # intersection of the two files with the miRNA name printed at the end of the row

intersectBed -b introns.bed -a miRNA_sorted.bed > miRNA_introns.bed # intersection of the two files with the miRNA name printed at the end of the row
