#!/bin/bash
#SBATCH -J BLAST
#SBATCH --qos main
#SBATCH -p main
#SBATCH -t 1-00:00:00
#SBATCH -n 8
#SBATCH -o %J.out
#SBATCH -e %J.err

# set up dotkit
source /jlf/ncbi.db/source.sh # NCBI databases on /jlf drive
export DK_ROOT=/share/apps/dotkit

. /share/apps/dotkit/bash/.dk_init

use bioinfoGCC

echo $BLASTDB 

blastn \
-task megablast \
-query final.assembly.fasta \
-db nt \
-outfmt '6 qseqid qlen staxids bitscore std sscinames sskingdoms stitle' \
-num_threads 8 \
-evalue 1e-25 \
-max_target_seqs 2 \
-out blast.out
