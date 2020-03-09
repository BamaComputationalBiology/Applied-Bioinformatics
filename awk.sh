#!/bin/bash

FILE = $1

# How do I... 

# get rid of duplicate entries in a file

awk '!_[$1]++' $FILE # here, selecting the first entry of a set of duplicates based on the value in column 1

# format a fastq to a fasta

awk ' NR%4 == 1 {print ">" substr($0, 2)} NR%4 == 2 {print} ' $FILE 

# calculate a column average

cat $FILE | cut -f 2 | awk '{sum=sum+$1} END {print sum/NR; sum = 0}' 

# calculate a column sum

cat $FILE | cut -f 2 | awk '{sum=sum+$1} END {print sum; sum = 0}' 

# sum across columns

awk '{ for(i=1; i<=NF;i++) j+=$i; print j; j=0 }' $FILE

# turn a row-formatted dataset into a column-formatted dataset

awk -F'\t' 'NF>1{a[$1] = a[$1]"\t"$2"\t"$3"\t"$4}END{for(i in a){print i""a[i]}}' # turning 4 rows into 4 columns - can do this more generally...

# select lines that match a condition

awk '$2 > 100' $FILE # selecting all lines where column 2 is greater than 100





