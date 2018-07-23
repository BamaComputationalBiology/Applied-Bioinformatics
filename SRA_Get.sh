#!/bin/bash

# There is probably a better way to do this but I feel like I've been needing this a lot lately
# SRR_Acc_List.txt is the list of accession numbers from the NCBI SRA
# Here, take the list and format it into a series of wget lines to download the data files
# create a wget script so you can trace your steps


cat SRR_Acc_List.txt | cut -c1-6 | while read line; do echo "wget ftp://ftp-trace.ncbi.nih.gov/sra/sra-instant/reads/ByRun/sra/SRR/$line/" ; done > 1.txt
paste 1.txt SRR_Acc_List.txt | sed 's/\sSRR/SRR/g' > 2.txt
paste 2.txt SRR_Acc_List.txt | sed 's/$/\.sra/g' | sed 's/\sSRR/\/SRR/g' > wget_script.sh
bash wget_script.sh
