#!/bin/bash
#SBATCH --job-name=[your job name]
#SBATCH -p [highmem, owners, main, or long]
#SBATCH --qos jlfierst
#SBATCH -C m620 [only for highmem node]
#SBATCH -t [time in D-HH:MM:SS]
#SBATCH --mem-per-cpu=[your memory requirement / number of cpus]
#SBATCH -o %J.out
#SBATCH -e %J.err

# set up dotkit for "use" commands
export DK_ROOT=/share/apps/dotkit
. /share/apps/dotkit/bash/.dk_init

# your script goes here
