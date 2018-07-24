# Some of the awesome things you can do with paste

# Interleave two fastq files

paste <(paste - - - - < reads-1.fastq) <(paste - - - - < reads-2.fastq) | tr '\t' '\n' > reads-int.fastq

# Separate an interleaved fastq

paste - - - - - - - - < reads-int.fastq | tee >(cut -f 1-4 | tr '\t' '\n' > reads-1.fastq) | cut -f 5-8 | tr '\t' '\n' > reads-2.fastq

# Turn a fastq into a fasta

paste - - - - < in.fastq | cut -f 1,2 | sed 's/^@/>/' | tr "\t" "\n" > out.fasta

# Select lines longer than X, here 2145 characters

paste - - - - < in.fastq | awk 'length($0) > 2145' | tr "\t" "\n" > long.fastq

# Remove duplicate entries in a .fastq

paste - - - - < in.fastq | sort | uniq | tr "\t" "\n" > deduped.fastq
