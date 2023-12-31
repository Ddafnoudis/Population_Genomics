# Library preparation
library("vcfR")
library("DEMEtics")
library("adegenet")
library("ade4")
library("ggplot2")
library("ape")
library("StAMPP")


# Upload data
samplesInfo <- read.table("SamplesInfo.txt", sep = "\t", header = TRUE)
sitesInfo <- read.table("SitesInfo.txt", sep = "\t", header = TRUE)

head(samplesInfo)
head(sitesInfo, 8)

# Before we use the chrV.vcf we can use the two .txt files in order to
# provide insights about our data.
# Merging the two .txt files by the Site column
merge_data <- merge(samplesInfo, sitesInfo, by = "Site")


# Find the mean of Length and Body_weight based on the site of the merged_data
site_means <- aggregate(cbind(samplesInfo$Length, samplesInfo$Body_weight) ~ Site, merge_data, mean)
colnames(site_means) <- c("Site","Length","Body_Weight")
site_means


# Visualization of Length and Body_Weight per Landscape
ggplot(site_means, aes(x=Site, y = Length)) +
  geom_bar(colour="blue", stat = "identity")

ggplot(site_means, aes(x=Site, y = Body_Weight)) +
  geom_bar(colour="red", stat = "identity")   


# Subset the samplesInfo by Site
L01 <- subset(samplesInfo, Site =="L01")
L02 <- subset(samplesInfo, Site =="L02")
L03 <- subset(samplesInfo, Site =="L03")
L05 <- subset(samplesInfo, Site =="L05")
L07 <- subset(samplesInfo, Site =="L07")
L09 <- subset(samplesInfo, Site =="L09")
L10 <- subset(samplesInfo, Site =="L10")
L12 <- subset(samplesInfo, Site =="L12")


# Brackishwater and freshwater
brackishwater <- c(L01, L02, L03, L05)
freshwater <- c(L07, L09, L10, L12)


# Brackishwater and freshwater by length
boxplot(brackishwater$Length.cm., freshwater$Length.cm.,
        names = c("brackishwater", "freshwater"),
        col = c("blue", "red"),
        ylab = "Length(cm)",
        main = "Group")


# Brackishwater and freshwater by Body Weight
boxplot(brackishwater$Body_weight.g., freshwater$Body_weight.g.,
        names = c("brackishwater", "freshwater"),
        col = c("blue", "red"),
        ylab = "Body Weight",
        main = "Group")


# subset the chromosome V from the ThreeSpined.vcf.gz file
vcf<- readLines("ThreeSpined.vcf.gz")
head(lines, 50)
filtered_vcf <- vcf[grep("^##|^#CHROM|^chrV\t", vcf)]
writeLines(filtered_vcf, "chrV.vcf")


# Information about chromosome V
chrV <- read.vcfR("chrV.vcf")
str(chrV)


# Visual overview of the SNP data
dna_file <- read.dna("RefGenome/ncbi_dataset/data/GCF_016920845.1/GCF_016920845.1_GAculeatus_UGA_version5_genomic.fasta",format="fasta")
chrom <- create.chromR(name = "chrV", vcf = chrV, seq = dna_file, verbose = TRUE)
chrom <- proc.chromR(chrom, verbose = TRUE,win.size=10)


# summarize the data from our fasta and vcf files
chromoqc(chrom)


# Quick check read depth distribution per individual
dp <- extract.gt(chrV, element='DP', as.numeric=TRUE)
boxplot(dp, las=3, col=c("#C0C0C0", "#808080"), ylab="Read Depth (DP)", cex=0.4, cex.axis=0.5,xlim=c(1,10))


# Genlight objects
genlight.data <- vcfR2genlight(chrV)


# Content of the genlight objects
getClassDef("genlight")
indNames(genlight.data)
nLoc(genlight.data) # number of SNPs


# Adding information about the population membership
# and the ploidy of each sample.
pops <- as.factor(c(
  "L12", "L12", "L03", "L07", "L12", "L01",
  "L07", "L12", "L01", "L07", "L12", "L01",
  "L07", "L01", "L03", "L01", "L03", "L07",
  "L03", "L07", "L02", "L07", "L02", "L03",
  "L03", "L09", "L01", "L03", "L09", "L09",
  "L10", "L01", "L03", "L09", "L12", "L09",
  "L10", "L03", "L09", "L10", "L10", "L12",
  "L03", "L01", "L02", "L12", "L03", "L03",
  "L12", "L03", "L02", "L12", "L02", "L09",
  "L09", "L12", "L03", "L10", "L12", "L01",
  "L03", "L03", "L03", "L01", "L12", "L01",
  "L01", "L12", "L09", "L01", "L09", "L03",
  "L09", "L03", "L09", "L12", "L09", "L01",
  "L01", "L10", "L12", "L05", "L01", "L12",
  "L05", "L12", "L05", "L01", "L03", "L02",
  "L05", "L03", "L02", "L02", "L02", "L03",
  "L03", "L02", "L02", "L02", "L03", "L05",
  "L02", "L02", "L05", "L10", "L05", "L02",
  "L05", "L05", "L10", "L10", "L05", "L05",
  "L10", "L05", "L05", "L02", "L10", "L07",
  "L07", "L05", "L10", "L07", "L05", "L12",
  "L05", "L01", "L05", "L10", "L02", "L07",
  "L12", "L02", "L07", "L02", "L07", "L02",
  "L05", "L12", "L05", "L10", "L01", "L10",
  "L05", "L01", "L05", "L01", "L07", "L07",
  "L05", "L07", "L01", "L01", "L01", "L02",
  "L05", "L02", "L07", "L09", "L09", "L02",
  "L09", "L10", "L07", "L02", "L07", "L10",
  "L09", "L07", "L10", "L07", "L10", "L07",
  "L10", "L09", "L07", "L10", "L10", "L10",
  "L09", "L12", "L10", "L12", "L05", "L09",
  "L12", "L09", "L09", "L07", "L09", "L09"
))

pop(genlight.data) <- pops
ploidyvalues <- rep(2,192)
ploidy(genlight.data) <- ploidyvalues
as.matrix(genlight.data)[20:30,1:5]
# We also do this in order to calculate the Fst Values

# graphical overview of alternative alleles and missing data (in white)
glPlot(genlight.data, posi="topleft")


# Assess the position of the polymorphic sites within a scaffold graphically
snpposi.plot(position(genlight.data[,genlight.data$chromosome=="chrV"]),genome.size=3000000,codon=FALSE)


# Allele frequency spectrum
# plot total AFS of the dataset
mySum <- glSum(genlight.data, alleleAsUnit = TRUE) # Computes the sum of second alleles for each SNP.
barplot(table(mySum), col="blue", space=0, xlab="Allele counts",
        main="Distribution of ALT allele counts in total dataset")


# Genetic Differentiation
genlight.data.reduced <- genlight.data[,sample(1:127403, 50000)]

genlight.data.reduced #checking basic information


# Fst (now we will use the StAMPP library)
# nboots: refers to the number of bootstraps to perform across loci
#         to generate confidence intervals and p-values.
# percent: refers to the percentile to calculate the confidence interval around
FstValues <- stamppFst(genlight.data.reduced, nboots = 100, percent = 95)
FstValues$Fsts


# library(ape) # required package to visualize the tree using the "nj" function
Tree <- nj(as.dist(FstValues$Fsts)) # conversion of the Fst values to a tree object
plot.phylo(Tree,type="unrooted",show.tip.label=TRUE,edge.width=1,rotate.tree=100)
??plot.phylo()

# Heterozygosity. We will use the adegenet package
genind.data <- vcfR2genind(chrV)


# Specify the populations
pops <- as.factor(c(
  "L12", "L12", "L03", "L07", "L12", "L01",
  "L07", "L12", "L01", "L07", "L12", "L01",
  "L07", "L01", "L03", "L01", "L03", "L07",
  "L03", "L07", "L02", "L07", "L02", "L03",
  "L03", "L09", "L01", "L03", "L09", "L09",
  "L10", "L01", "L03", "L09", "L12", "L09",
  "L10", "L03", "L09", "L10", "L10", "L12",
  "L03", "L01", "L02", "L12", "L03", "L03",
  "L12", "L03", "L02", "L12", "L02", "L09",
  "L09", "L12", "L03", "L10", "L12", "L01",
  "L03", "L03", "L03", "L01", "L12", "L01",
  "L01", "L12", "L09", "L01", "L09", "L03",
  "L09", "L03", "L09", "L12", "L09", "L01",
  "L01", "L10", "L12", "L05", "L01", "L12",
  "L05", "L12", "L05", "L01", "L03", "L02",
  "L05", "L03", "L02", "L02", "L02", "L03",
  "L03", "L02", "L02", "L02", "L03", "L05",
  "L02", "L02", "L05", "L10", "L05", "L02",
  "L05", "L05", "L10", "L10", "L05", "L05",
  "L10", "L05", "L05", "L02", "L10", "L07",
  "L07", "L05", "L10", "L07", "L05", "L12",
  "L05", "L01", "L05", "L10", "L02", "L07",
  "L12", "L02", "L07", "L02", "L07", "L02",
  "L05", "L12", "L05", "L10", "L01", "L10",
  "L05", "L01", "L05", "L01", "L07", "L07",
  "L05", "L07", "L01", "L01", "L01", "L02",
  "L05", "L02", "L07", "L09", "L09", "L02",
  "L09", "L10", "L07", "L02", "L07", "L10",
  "L09", "L07", "L10", "L07", "L10", "L07",
  "L10", "L09", "L07", "L10", "L10", "L10",
  "L09", "L12", "L10", "L12", "L05", "L09",
  "L12", "L09", "L09", "L07", "L09", "L09"
))

pop(genlight.data) <- pops


# Use the Hs function
# to obtain the average heterozygosity for each population
Hs(genind.data)


# Principal Component Analysis (PCA)
# when nf=2 (number of retained factors) is not specified,
# the function displays the barplot of eigenvalues
# of the analysis and asks the user for a number of
# retained principal components.
pca.1 <- glPca(genlight.data.reduced, nf=2)
pca.1$eig[1]/sum(pca.1$eig) # proportion of variation explained by 1st principal component
pca.1$eig[2]/sum(pca.1$eig) # proportion of variation explained by 2nd principal component


# plot the samples along the first two principle components showing groups
s.class(pca.1$scores, pop(genlight.data.reduced), col=colors()[c(131,132,133,134)])
