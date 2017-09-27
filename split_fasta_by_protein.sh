# bash script to split protein .fasta into individual proteins and create a new .fasta with protein from the target list
# requires a 'whitelist' of proteins to keep (here, GeneNames.txt) and a .fasta of proteins sequence (here, genome.proteins.fasta)


#!/bin/bash


awk '/^>protein/ {OUT=substr($0,2) ".fasta"}; OUT {print >OUT}' genome.proteins.fasta
cat GeneNames.txt | while read line; do cat "protein|"$line"-RA ID="$line"-RA|Parent="$line"|Name=.fasta"; done > kept_proteins.fasta
rm protein*.fasta


# And here is an example doing this on scaffolds from janna
# bash script to split wgs .fasta into individual scaffolds and create a new .fasta with scaffolds from the target organism
# requires a 'whitelist' of scaffolds to keep (here, scaffolds_to_keep.txt) and a .fasta of assembled sequence (here, final.assembly.fasta)


#!/bin/bash

awk '/^>scaffold/ {OUT=substr($0,2) ".fasta"}; OUT {print >OUT}' final.assembly.fasta
cat scaffolds_to_keep.txt | while read line; do cat "scaffold_"$line".fasta" ; done > kept_scaffolds.fasta
rm "scaffold"*".fasta"


# bash line for checking consistency between the whitelist and the new scaffolds file

cat kept_scaffolds.fasta | grep '^>' | tr -d '\>scaffold\_' | sort -n | diff - scaffolds_to_keep.txt 
