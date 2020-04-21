# Command to create pseudorandom samples of paired end libraries. Used to create read sets for Sutton & Fierst simulations 

seqtk sample -s100 read1.fq 10000 > sub1.fq
seqtk sample -s100 read2.fq 10000 > sub2.fq
