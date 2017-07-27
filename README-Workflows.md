**Computational Field Guides**

Documenting my protocols for tricky tasks.

***Submitting an annotated whole genome sequence (WGS) to NCBI***

This was a substantial learning expedition for me. This field guide is intentionally verbose to aid my memory for the future and to help my students when they need to perform these same tasks.


Pieces you will need to submit:

Assembled WGS

Raw .fastq(s) (preferably zipped, so .fastq.gz(s)) with your DNA sequences used in assembly and your mRNA sequences used in annotation

.gff with annotated genes 




Pieces you will generate to submit (aka NCBI-specific files):

BioSample #

BioProject #

Locus-tag prefix

Sequence Read Archive library descriptions .txt

submission template .sbt

sequence file .sqn


1. The first step is registering your project with NCBI. You will need to register both a BioSample https://submit.ncbi.nlm.nih.gov/subs/biosample/ for the physical organism/tissue and a BioProject https://submit.ncbi.nlm.nih.gov/subs/bioproject/ for the data generated from that BioSample. NCBI will also give you a locus-tag prefix that will be assigned to every annotated gene. For example, my locus-tag prefix was FL81 and the first annotated gene in my WGS was FL81_00001, the second FL81_00002, etc. This will be different from your accession number, and your accession number will not be assigned until you have passed all NCBI checks. 

2. Once you have these you can start a new WGS submission https://submit.ncbi.nlm.nih.gov/subs/genome/. I recommend uploading the .fasta BEFORE annotating the assembled sequence in case there are issues with the assembly.

3. If there are issues with the assembly it will most likely be sequencing adapters that may have made it through your sequencing-trimming-filtering-assembling pipeline. Full lists of possible sequences can be found here:
  
    https://github.com/tomdeman-bio/Sequence-scripts/blob/master/adapters.fasta and
    http://bioinformatics.cvr.ac.uk/blog/illumina-adapter-and-primer-sequences/
    
    I've had problems with the adapter sequences that people **think** they used vs. the ones that were actually used and have found it useful to search a small sequence that is common to many adapters, for example
    
          > grep -c 'AGATGTGTATAAGAGA' file.fastq 

  The exact number that constitutes 'adapter contamination' is subjective and depends on how many sequences you are analyzing. A few hundred is probably random chance but definitely a few million needs to be dealt with. I use TrimGalore for adapter trimming https://github.com/FelixKrueger/TrimGalore
  
  If you have aggressively eliminated adapters there may still be small sequences that are flagged as problematic. I had a few of these     but they were very small (for example, 13bp) and identified as possibly coming from 'multiple sources.' NCBI does a large-scale screen for every possible known adapter and it is likely these short sequences are similar to known adapters due to random chance. I was not able to find the identified sequences in our raw DNA sequences and I chose to mask these sequences and resubmit the WGS. I generated a .bed file of the possible adapter sequences with this format (tab-separated)

          Contig1 738395  738408  adapter

  and I masked these regions with bedtools maskfasta http://bedtools.readthedocs.io/en/latest/content/tools/maskfasta.html. This masked WGS was accepted. 

4. Once the WGS is approved, you can email the NCBI staff and ask to add the protein-coding annotations. They will enable the 'fix' button for you which will allow you to add a .sqn file to your submission. It's a little futzy to do it this way but it saves you time re-annotating a slightly different WGS. 

5. Start your protein-coding annotations. I used the MAKER2 software package http://gmod.org/wiki/MAKER. There is a great guide to getting started with MAKER2 annotation here https://github.com/sujaikumar/assemblage/blob/master/README-annotation.md. 

6. Annotation takes a little while. While your annotations are running, create a new Sequence Read Archive (SRA) submission for your raw DNA and mRNA sequences https://submit.ncbi.nlm.nih.gov/subs/sra/. New submissions require a lot of information about the sequences and I found it easiest to download the NCBI Excel template, fill in, save as a tab-delimited file, and upload. Each type of DNA sequence gets its own line and multiple files can go on a single line. For example, we had 3 sets of mate pair sequences with the same insert size and all 6 files went on one line. 

  You will be transferring very large files and the easiest way to do this is through the NCBI FTP server. Under 'FTP Upload' on the page linked above you can request an FTP folder. NCBI will then give you a set of instructions to access your FTP folder. I don't use FTP much- at all, really- and I had to google how to use FTP. It's very limited compared to any other connection mechanism and doesn't have much functionality. From your data directory type 
  
      > ftp ftp-private.ncbi.nlm.nih.gov
          
  (I imagine that ftp server is static although yours may be different) and you will be prompted for your assigned username and password. Once you have navigated to your upload folder you can use 
  
      > mput file1.fastq.gz 
      
  instead of the 'put' that NCBI suggests. 'mput' will go through each file in your data directory and ask if you want to transfer that file or not making it much easier to transfer multiple files at one time. Once your files are transferred go back to the SRA submission wizard and complete your submission. 

If your files get stopped and marked with errors it may be an error on your side or it may be a bug on the NCBI side. For example, my submission came up with several pairs of sequences that it said could not be appropriately matched. I searched these in my files and compared them every which way and couldn't find a problem. I emailed NCBI and the staff replied that it was probably a bug on their side. They reply within a few hours but it is these kind of things that made this a long process. So try to not put in too much effort before you ask them for guidance. 

7. When your protein-coding annotations are finished you will need to compile the results and format them for NCBI. I also use a program called SOBAcl to calculate some basic statistics on the annotation files. I use the pbs/bash script below for this with a .fasta called genome_SeqID_headers.fasta and an NCBI-assigned ID of FL81:

          #!/bin/bash

          module load maker #pbs command to load maker2 package
          module load SOBA  #pbs command to load SOBAcl package

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

If you want to know about the quality of your annotations you can evaluate your Annotation Edit Distance (AED) and edited (eAED) values. For example, I used this line 

      cat *.all.maker.proteins.fasta | grep '>' | sed 's/eAED\:/\t/g' | sed 's/ e//g' | cut -f 2 | awk '{ sum += $1 } END {print sum/NR }'

to quickly get the average and compare between annotation runs with different parameters. 

8. The resulting MAKER2 .gff will have some glitches and inconsistencies. In particular NCBI requires that all introns > 10bp for submission. A lot of the MAKER2 introns that don't meet this requirement are 10bp inclusive but 9bp exclusive, for example an intron from bases 1725-1735. I think this might be a glitch in the MAKER2 vs. NCBI set computations and it affects <<<1% of the genes but NCBI will still reject the entire file. 

9. I used the Genome Annotation Generator (GAG https://github.com/genomeannotation/GAG/blob/master/gag.py) to correct intron errors and other glitches. Funannotate https://github.com/nextgenusfs/funannotate is also recommended but I found it tossed a bunch of gene models without verbose output on why and didn't use it. It was very easy to install and use through homebrew though https://brew.sh/ and it actually installed a bunch of other useful software for me that I had previously had problems installing, funny enough. 

One thing to note - GAG gets rid of the MAKER2 annotated UTR's in its resulting genome.gff file but you can add these back in if you want. I did not add them back in and NCBI accepted the file.  

10. GAG creates a .gff file and a .tbl file which can be used to generate a .sqn file for NCBI submission with the NCBI program tbl2asn https://www.ncbi.nlm.nih.gov/genbank/tbl2asn2/. There is also a table2asn program which generates a .sqn from a .gff but I couldn't figure out how to add in some of the features that NCBI required and did not end up using this. I actually can't find the link now and can only find other people reporting problems and asking how to use it so maybe it is still in beta (i.e., testing version). 

11. You will need to create a template file for submission information https://www.ncbi.nlm.nih.gov/genbank/tbl2asn2/. 

12. I created a .sqn file like this

        tbl2asn -V v -c fx -i genome.fsa -t template.sbt -M n -a r10k -l paired_ends -Z discrep -j "[organism=Caenorhabditis latens][strain=PX534]"

The .gff has to have the same name as the genome file (here genome.fsa) and here I'm giving the locus tags the organism and strain names. These are required for NCBI submission.

13. tbl2asn generates a number of files that will theoretically tell you if your files are NCBI-compliant. This is actually the part that took me quite a while to figure out and ended up in a lot of back and forth with the NCBI staff. tbl2asn will generate three information files that will tell you about possible inconsistencies that will cause your files to fail NCBI checks. These are the discrepancy report (in the line above I have asked tbl2asn to generate it with the -Z flag and called it 'discrep'), the abbreviated error report error.val and the verbose error report genome.val. The problem is that the abbreviated error report is so short you can't get useful information out of it, the discrepancy report is a flow-of-consciousness file with headers that are not associated with the lines below and so impossible to search (for example, mine was 157,754 lines), the verbose error report can be searched if you already know what to search for (mine was 168,217 lines), and all 3 of these are peppered with 'this might be okay if your gene/genome falls under XYZ categories but it might not be okay if not.' According to NCBI you can run another program, asndisc https://www.ncbi.nlm.nih.gov/genbank/asndisc/, which will collate this information but it still gives you the 'maybe/maybe not' category for many genes. For example, the OVERLAPPING_CDS flag indicates that two CDSs overlap which NCBI says is not biologically valid UNLESS the genes are ABC-type transporters in which case that is common. A super nerdy interdisciplinary science joke is that if you ask a biologist a question the answer will always be "Well, it depends." The problem here is the time it takes to check each of these 'maybe/maybe not situations.'

14. 
