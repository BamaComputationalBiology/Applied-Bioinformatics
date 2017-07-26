**Workflows**

Documented workflows for tricky tasks.

*Submitting an annotated whole genome sequence (WGS) to NCBI*

This was a major stumbling block for me!

1. The first step is registering your project with NCBI. You will need to register both a BioSample https://submit.ncbi.nlm.nih.gov/subs/biosample/ for the physical organism/tissue and a BioProject https://submit.ncbi.nlm.nih.gov/subs/bioproject/ for the data generated from that BioSample. 

2. Once you have these you can start a new WGS submission https://submit.ncbi.nlm.nih.gov/subs/genome/. I recommend uploading the .fasta BEFORE annotating the assembled sequence in case there are issues with the assembly.

3. If there are issues with the assembly it will most likely be sequencing adapters that may have made it through your sequencing-trimming-filtering-assembling pipeline. Full lists of possible sequences can be found here:
  
    https://github.com/tomdeman-bio/Sequence-scripts/blob/master/adapters.fasta and
    http://bioinformatics.cvr.ac.uk/blog/illumina-adapter-and-primer-sequences/
    
    I've had problems with the adapter sequences that people **think** they used vs. the ones that were actually used and have found iT useful to search a small sequence that is common to many adapters, for example
    
          grep -c 'AGATGTGTATAAGAGA' 

If you have aggressively eliminated adapters there may still be small sequences that are flagged as problematic. I had a few of these but they were very small (for example, 13bp) and identified as possibly coming from 'multiple sources.' NCBI does a large-scale screen for every possible known adapter and it is likely these short sequences are similar to known adapters due to random chance. I was not able to find the identified sequences in our raw DNA sequences and I chose to mask these sequences and resubmit the WGS. I generated a .bed file of the possible adapter sequences with this format (tab-separated)

              Contig1 738395  738408  adapter

and I masked these regions with bedtools maskfasta http://bedtools.readthedocs.io/en/latest/content/tools/maskfasta.html. This masked WGS was accepted. 

4. Once the WGS is approved, you can email the NCBI staff and ask to add the protein-coding annotations. They will enable the 'fix' button for you which will allow you to add a .sqn file to your submission. It's a little futzy to do it this way but it saves you time re-annotating a slightly different WGS. 

5. Start your protein-coding annotations. I used the MAKER2 software package http://gmod.org/wiki/MAKER. There is a great guide to getting started with MAKER2 annotation here https://github.com/sujaikumar/assemblage/blob/master/README-annotation.md. 

6. Annotation takes a little while. While your annotations are running, create a new Sequence Read Archive (SRA) submission for your raw DNA sequences https://submit.ncbi.nlm.nih.gov/subs/sra/. New submissions require a lot of information about the DNA sequences and I found it easiest to download the NCBI Excel template, save it as a tab-delimited file, and upload. Each type of DNA sequence gets its own line and multiple files can go on a single line. For example, we had 3 sets of mate pair sequences with the same insert size and all 6 files went on one line. 

You will be transferring very large files and the easiest way to do this is through the NCBI FTP server. Under 'FTP Upload' on the page linked above you can request an FTP folder. NCBI will then give you a set of instructions to access your FTP folder. I don't use FTP much- at all, really- and I had to google how to use FTP. It's very limited compared to any other connection mechanism and doesn't have much functionality. From your data directory type 'ftp ftp-private.ncbi.nlm.nih.gov' (I imagine that ftp server is static although your may be different) and you will be prompted for your assigned username and password. Once you have navigated to your upload folder you can use 'mput file1.fastq.gz' instead of the 'put' that NCBI suggests. 'mput' will go through each file in your data directory and add if you want to transfer that file or not making it much easier to transfer multiple files at one time. Once your files are transferred go back to the SRA submission wizard and complete your submission. 

If your files get stopped and marked with errors it may be an error on your side or it may be a bug on the NCBI side. For example, my submission came up with several pairs of sequences that it said could not be appropriately matched. I searched these in my files and compared them every which way and couldn't find a problem. I emailed NCBI and the staff replied that it was probably a bug on their side. They reply promptly but it is these kind of things that made this a long process. So try to not put in too much effort before you ask them for guidance. 

7. When your protein-coding annotations are finished you will need to compile the results and format them for NCBI. I also use a program called SOBAcl to calculate some basic statistics on the annotation files. I use the pbs script below for this with a .fasta called genome_SeqID_headers.fasta and an NCBI-assigned ID of FL81:

          #!/bin/bash

          module load maker
          module load SOBA

          base=genome_SeqID_headers

          gff3_merge -d ./$base\_master_datastore_index.log 
          gff3_merge -d ./$base\_master_datastore_index.log -o $base\_no_evidence -g
          SOBAcl ./$base\.all.gff > SOBA.txt
          fasta_merge -d $base\_master_datastore_index.log

          maker_map_ids --prefix FL81_ --justify 5 ./$base\.all.gff > genome.id.map
          map_gff_ids genome.id.map ./$base\.all.gff 

          map_fasta_ids genome.id.map ./$base\.all.maker.augustus_masked.proteins.fasta 
          map_fasta_ids genome.id.map ./$base\.all.maker.proteins.fasta 
          map_fasta_ids genome.id.map ./$base\.all.maker.transcripts.fasta 

If you want to know about the quality of your annotations you can evaluate your Annotation Edit Distance (AED) and edited (eAED) values. For example, I use this line 

      cat *.all.maker.proteins.fasta | grep '>' | sed 's/eAED\:/\t/g' | sed 's/ e//g' | cut -f 2 | awk '{ sum += $1 } END {print sum/NR }'

to quickly get the average and compare between annotation runs with different parameters. 

8. The resulting MAKER2 .gff will have some glitches and inconsistencies. In particular NCBI requires that all introns > 10bp for submission. A lot of the MAKER2 introns that don't meet this requirement are 10bp inclusive but 9bp exclusive, for example an intron from bases 1725-1735. I think this might be a glitch in the MAKER2 vs. NCBI set computations and it affects <<<1% of the genes but NCBI will still jettison the entire file. 

9. I use the Genome Annotation Generator (GAG https://github.com/genomeannotation/GAG/blob/master/gag.py) to correct intron errors and other glitches. Funannotate https://github.com/nextgenusfs/funannotate is also recommended but I found it tossed a bunch of gene models without verbose output on why and didn't use it. It was very easy to install and use through homebrew though https://brew.sh/ and it actually installed a bunch of other useful software for me that I had previously had problems installing, funny enough. 

One thing to note - GAG gets rid of the MAKER2 annotated UTR's in its resulting genome.gff file but you can add these back in if you want. I did not add them back in and NCBI accepted the file.  

10. GAG creates a .gff file and a .tbl file which can be used to generate a .sqn file for NCBI submission with the NCBI program tbl2asn https://www.ncbi.nlm.nih.gov/genbank/tbl2asn2/. There is also a table2asn program which generates a .sqn from a .gff but I couldn't figure out how to add in some of the features that NCBI required and did not end up using this. I actually can't find the link now and can only find other people reporting problems and asking how to use it so maybe it is still in beta. 

11. You will need to create a template file for submission information https://www.ncbi.nlm.nih.gov/genbank/tbl2asn2/. 

12. I created a .sqn file like this

        tbl2asn -V v -c fx -i genome.fsa -t template.sbt -M n -a r10k -l paired_ends -Z discrep -j "[organism=Caenorhabditis latens][strain=PX534]"

The .gff has to have the same name as the genome file (here genome.fsa) and here I'm giving the locus tags the organism and strain names. These are required for NCBI submission.

13. tbl2asn generates a number of files that will theoretically tell you if your files are NCBI-compliant. This is actually the part that took me quite a while to figure out because some errors were marked as "FATAL" 
