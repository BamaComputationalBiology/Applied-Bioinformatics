**Computational Field Guides**

Documenting protocols for tricky tasks

*Excluding organisms from local (command-line) BLAST search*

Recently I submitted a manuscript to decontaminate assembled genome sequences and the reviewer suggested excluding the target organism from the BLAST search. In our lab we have local versions of the entire nt/nr database on both our University of Alabama server and my lab server. How can we exclude a single target organism from this large database without building custom databases?

1. Go to the NCBI nucleotide database https://www.ncbi.nlm.nih.gov/nuccore/

2. Type in the name of your target organism, here '*Caenorhabditis remanei*.'

3. NCBI will produce an exhaustive list of all nucleotide accessions associated with that organism or with those words in any field. In the top right-hand corner there will be a small arrow next to the words 'Send to:'

4. Click on the arrow -> under 'Choose Destination' select 'File' -> under 'Format' drop down and select 'GI List.'

5. NCBI will create a blacklist of individual sequence accessions; download this and rename it. Here, I have renamed it 'Cremanei.gi.'
        **Important**: NCBI regularly updates their databases and this blacklist is built off the most recent database version. Update your local BLAST database to get these synced. I did not do this and ended up with BLAST hits from old accessions that were deleted from the most recent BLAST database but present in our older version. 

6. In your local blast search include this blacklist under the 'negative_gilist' flag. For example, my slurm script is now:

        #!/bin/bash
        #SBATCH -J BLAST
        #SBATCH --qos main
        #SBATCH -p main
        #SBATCH -t 1-00:00:00
        #SBATCH -n 8
        #SBATCH -o %J.out
        #SBATCH -e %J.err
        # set up dotkit
        source /jlf/ncbi.db/source.sh
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
        -negative_gilist Cremanei.gi \
        -max_target_seqs 2 \
        -out blast.out

