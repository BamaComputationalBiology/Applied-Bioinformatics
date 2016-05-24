#!/bin/bash

# using unix tools to query your sam files

$1 = FILE

# How do I...

# Calculate the size of my genome from a .sam file

cat $FILE | grep "^@" | cut -f 3 | sed 's/LN://g' | sort -nr | grep "^[0-9]" | awk '{sum+=$1} END {print sum}'

# Calculate the average scaffold size

cat $FILE | grep "^@" | cut -f 3 | sed 's/LN://g' | sort -nr | grep "^[0-9]" | awk '{sum+=$1} END {print sum/NR}'

# Calculate the average aligned insert

cat $FILE | grep -v "^@" | cut -f 9 | grep "^[0-9]" | awk '{sum+=$1} END {print sum/NR}'

# or

cat $FILE | grep -v "^@" | cut -f 9 | grep -v "^-" | awk '{sum+=$1} END {print sum/NR}'

# get the most common bitwise flags to identify alignment issues

cat $FILE | grep -v "^@" | cut -f 2 | sort | uniq -c | sort -nr | head -20

# get the most common CIGAR strings to identify alignment issues

cat $FILE | grep -v "^@" | cut -f 6 | sort | uniq -c | sort -nr | head -20
