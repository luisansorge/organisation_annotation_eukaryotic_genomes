# Load the circlize package

library(circlize)
library(tidyverse)
library(ComplexHeatmap)
library(BiocManager)

# Load the TE annotation GFF3 file
gff_file <- "Abd-0.asm.bp.p_ctg.fa.mod.EDTA.TEanno.gff3"
gff_data <- read.table(gff_file, header = FALSE, sep = "\t", stringsAsFactors = FALSE)

gene_annotation_file <- "filtered.genes.renamed.gff3"
gene_annotation <- read.table(gene_annotation_file, header = FALSE, sep = "\t", stringsAsFactors = FALSE)

# Swap coordinates where end larger than start
gene_annotation <- gene_annotation %>%
  mutate(
    start = pmin(V4, V5),
    end   = pmax(V4, V5)
  )

# Check the superfamilies present in the GFF3 file, and their counts
gff_data$V3 %>% table()
#helitron 8692
#LTR_retrotransposons 7112
#rRNA_gene 3965
#Gypsy_LTR_retrotransposon 3192
#Mutator_TIR_transposon 2602

# custom ideogram data
## To make the ideogram data, you need to know the lengths of the scaffolds.
## There is an index file that has the lengths of the scaffolds, the `.fai` file.
## To generate this file you need to run the following command in bash:
## samtools faidx assembly.fasta
## This will generate a file named assembly.fasta.fai
## You can then read this file in R and prepare the custom ideogram data

custom_ideogram <- read.table("Abd-0.asm.bp.p_ctg.fa.fai", header = FALSE, stringsAsFactors = FALSE)
custom_ideogram$chr <- custom_ideogram$V1
custom_ideogram$start <- 1
custom_ideogram$end <- custom_ideogram$V2
custom_ideogram <- custom_ideogram[, c("chr", "start", "end")]
custom_ideogram <- custom_ideogram[order(custom_ideogram$end, decreasing = T), ]
sum(custom_ideogram$end[1:20])

# Select only the first 20 longest scaffolds, You can reduce this number if you have longer chromosome scale scaffolds
custom_ideogram <- custom_ideogram[1:16, ]

# Function to filter GFF3 data based on Superfamily (You need one track per Superfamily)
filter_superfamily <- function(gff_data, superfamily, custom_ideogram) {
    filtered_data <- gff_data[gff_data$V3 == superfamily, ] %>%
        as.data.frame() %>%
        mutate(chrom = V1, start = V4, end = V5, strand = V6) %>%
        select(chrom, start, end, strand) %>%
        filter(chrom %in% custom_ideogram$chr)
    return(filtered_data)
}

pdf("02-TE_density.pdf", width = 10, height = 10)
gaps <- c(rep(1, length(custom_ideogram$chr) - 1), 5) # Add a gap between scaffolds, more gap for the last scaffold
circos.par(start.degree = 90, gap.after = 1, track.margin = c(0, 0), gap.degree = gaps)
# Initialize the circos plot with the custom ideogram
circos.genomicInitialize(custom_ideogram)

# add gene track to the plot
circos.genomicDensity(
  filter_superfamily(gene_annotation, "gene", custom_ideogram),
  count_by = "number",
  col = "black",
  track.height = 0.07,
  window.size = 1e5
)

# Plot te density
circos.genomicDensity(filter_superfamily(gff_data, "Gypsy_LTR_retrotransposon", custom_ideogram), count_by = "number", col = "green3", track.height = 0.07, window.size = 1e5)
circos.genomicDensity(filter_superfamily(gff_data, "CACTA_TIR_transposon", custom_ideogram), count_by = "number", col = "firebrick", track.height = 0.07, window.size = 1e5)
circos.genomicDensity(filter_superfamily(gff_data, "LTR_retrotransposon", custom_ideogram), count_by = "number", col = "dodgerblue", track.height = 0.07, window.size = 1e5)
circos.genomicDensity(filter_superfamily(gff_data, "rRNA_gene", custom_ideogram), count_by = "number", col = "purple", track.height = 0.07, window.size = 1e5)
circos.genomicDensity(filter_superfamily(gff_data, "Mutator_TIR_transposon", custom_ideogram), count_by = "number", col = "orange", track.height = 0.07, window.size = 1e5)
circos.genomicDensity(filter_superfamily(gff_data, "hAT_TIR_transposon", custom_ideogram), count_by = "number", col = "yellow", track.height = 0.07, window.size = 1e5)
circos.genomicDensity(filter_superfamily(gff_data, "PIF_Harbinger_TIR_transposon", custom_ideogram), count_by = "number", col = "hotpink", track.height = 0.07, window.size = 1e5)

circos.clear()

lgd <- Legend(
    title = "Superfamily", at = c("Gene_Annotation", "Gypsy_LTR_retrotransposon", "CACTA_TIR_transposon", "LTR_retrotransposon", "rRNA_gene", "Mutator_TIR_transposon", "hAT_TIR_transposon", "PIF_Harbinger_TIR_transposon"),
    legend_gp = gpar(fill = c( "black", "green3", "firebrick", "dodgerblue", "purple", "orange", "yellow", "hotpink"))
)
draw(lgd, x = unit(13, "cm"), y = unit(13, "cm"), just = c("center"))

dev.off()


# Now plot all your most abundant TE superfamilies in one plot

# Plot the distribution of Athila and CRM clades (known centromeric TEs in Brassicaceae).
# You need to run the TEsorter on TElib to get the clades classification from the TE library

# Extract IDs using sapply
extract_id <- function(line) {
  id_match <- regmatches(line, regexpr("TE_[0-9]+", line))
  return(id_match)
}

gff_data$id <- sapply(gff_data$V9, extract_id)

tsv_file = "Gypsy_sequences.fa.cp.rexdb-plant.cls.tsv"
tsv_data = read.table(tsv_file, header = TRUE, sep = "\t", stringsAsFactors = FALSE)

tsv_data$id <- substr(tsv_data$sTE, 1, 11)

clade_data <- tsv_data %>%
  filter(Clade == "Athila" | Clade == "CRM") %>%
  select(id, Clade)

new_data <- data.frame()
clades <- c()

for(i in seq_along(gff_data$id)){
  for(j in seq_along(clade_data$id)){
    if(clade_data$id[j] == gff_data$id[i]){
      new_data <- rbind(new_data, gff_data[i,])
      clades <- c(clades, clade_data$Clade[j])
    }
  }
}

new_data$clades <- clades

filter_clades <- function(new_data, clade, custom_ideogram) {
  filtered_data <- new_data[new_data$clades == clade, ] %>%
    as.data.frame() %>%
    mutate(chrom = V1, start = V4, end = V5, strand = V6) %>%
    select(chrom, start, end, strand) %>%
    filter(chrom %in% custom_ideogram$chr)
  return(filtered_data)
}

pdf("02-TE_density_clades.pdf", width = 10, height = 10)
gaps <- c(rep(1, length(custom_ideogram$chr) - 1), 5) # Add a gap between scaffolds, more gap for the last scaffold
circos.par(start.degree = 90, gap.after = 1, track.margin = c(0, 0), gap.degree = gaps)
# Initialize the circos plot with the custom ideogram
circos.genomicInitialize(custom_ideogram)

circos.genomicDensity(filter_clades(new_data, "CRM", custom_ideogram), count_by = "number", col = "dodgerblue", track.height = 0.07, window.size = 1e5)
circos.genomicDensity(filter_clades(new_data, "Athila", custom_ideogram), count_by = "number", col = "firebrick", track.height = 0.07, window.size = 1e5)

circos.clear()

lgd <- Legend(
  title = "Clades", at = c("CRM", "Athila"),
  legend_gp = gpar(fill = c("dodgerblue", "firebrick"))
)
draw(lgd, x = unit(12, "cm"), y = unit(12, "cm"), just = c("center"))

dev.off()

