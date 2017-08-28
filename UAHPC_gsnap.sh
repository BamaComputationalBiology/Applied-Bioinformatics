#!/bin/bash

#SBATCH -J gsnap_align    # job name
#SBATCH -p main           # partition
#SBATCH --qos main        # quality of service
#SBATCH -t 24:00:00       # wall clock **note that the wall clock is computed against threads*time so a 4 core job given two hours will kill itself after 30 mins
#SBATCH -n 1              # number of tasks
#SBATCH -c 8              # cores/task
#SBATCH --mem-per-cpu 4G  # memory per cpu
#SBATCH -o %A.%a.out      # outfile name  
#SBATCH -e %A.%a.err      # error file name

# this script successfully launches gmap-gsnap with mpi support 
# note that the --mem-per-cpu 4G has been critical for me to get it going, otherwise it seems to throw strange errors with mpi

# set up dotkit
export DK_ROOT=/share/apps/dotkit
 
. /share/apps/dotkit/bash/.dk_init
 
use bioinfoGCC          

SCRIPT_DIR=$( pwd )

# Here I am building the gmap-gsnap genome index 
gmap_build -D /jlf/janna/bama_new/decision_examples/simulated/genome_indices -d PX356 $SCRIPT_DIR/final.assembly.fasta

# Here I am launching the alignment with mpi and 8 threads
srun --mpi=pmi2 gsnap -B 5 -t 8 -A sam -N 1 -n 1 -D /jlf/janna/bama_new/decision_examples/simulated/genome_indices -d PX356 /jlf/356_assembly_data/356_1.fq /jlf/356_assembly_data/356_2.fq > Cc.sam
