# Population_Genomics

The aim of this assignment is to explore the morphological and genetic differentiation of the 8
populations of the three-spined stickleback species (Gasterosteus aculeatus Linnaeus, 1758) as
the heterozygosity. In order to achieve these goals, we'll use a vcf file and analyze the
chromosome 5 (chromosome V) based on the single-nucleotide polymorphisms (SNPs). In
addition we'll use a reference genome from the NCBI
(https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_016920845.1/).


The VCF file contains 192 samples from three-spined stickleback. There are eight populations.
The L01, L02, L03, L05 are from brackish water and the L07, L09, L10, L12 are from the fresh
water habitats and from each site approximately 24 individuals have been sequenced using
WGS. Samples have been taken from the Belgian-Dutch lowlands. In this VCF file we have
removed monomorphic SNPs to exclude all sites at which no alternative alleles are called for any
of the samples and all sites at which only alternative alleles are called (all samples differ from
the reference genome). Furthermore, multiallelic and low allele frequency (AF < 0.01) SNPs have
also been removed.
