Workflows

Documented workflows for tricky tasks.

Submitting an annotated whole genome sequence (WGS) to NCBI

This was a major stumbling block for me and I'm writing up the protocol and associated scripts in the hopes it can help others.

1. The first step is registering your project with NCBI. You will need to register both a BioSample https://submit.ncbi.nlm.nih.gov/subs/biosample/ for the physical organism/tissue and a BioProject https://submit.ncbi.nlm.nih.gov/subs/bioproject/ for the data generated from that BioSample. 

2. Once you have these you can start a new WGS submission https://submit.ncbi.nlm.nih.gov/subs/genome/. I recommend uploading the .fasta BEFORE annotating the assembled sequence in case there are issues with the assembly.

3. If there are issues with the assembly it will most likely be sequencing adapters that may have made it through your sequencing-trimming-filtering-assembling pipeline. I had a few of these but they were very small (for example, 13bp) and identified as possibly coming from 'multiple sources.' NCBI does a large-scale screen for every possible known adapter and it is likely these short sequences are similar to known adapters due to random chance. I was not able to find the identified sequences in our raw DNA sequences and I chose to mask these sequences and resubmit the WGS. I generated a .bed file of the possible adapter sequences with this format

Contig1 738395  738408  possible.adapter

and I masked these regions with bedtools maskfasta http://bedtools.readthedocs.io/en/latest/content/tools/maskfasta.html. 

  3a. 

