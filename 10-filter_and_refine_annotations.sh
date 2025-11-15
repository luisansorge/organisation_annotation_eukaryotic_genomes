#!/bin/bash
#SBATCH --job-name=tasks
#SBATCH --partition=pibu_el8 
#SBATCH --cpus-per-task=20 
#SBATCH --mem=64G 
#SBATCH --time=2-00:00 

COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
MAKERBIN="$COURSEDIR/softwares/Maker_v3.01.03/src/bin"

# Working directory with renamed annotations and InterProScan results
WORKDIR="/data/users/lansorge/organisation_annotation/gene_annotation_directory/Abd-0.asm.bp.p_ctg.maker.output/final"

cd $WORKDIR

# Define input files
protein="assembly.all.maker.proteins.fasta.renamed.fasta"
transcript="assembly.all.maker.transcripts.fasta.renamed.fasta"
gff="assembly.all.maker.noseq.gff.renamed.gff"

# Update GFF3 with InterProScan functional annotations
$MAKERBIN/ipr_update_gff $gff output.iprscan > ${gff}.iprscan.gff

# Calculate AED values
perl $MAKERBIN/AED_cdf_generator.pl -b 0.025 $gff > assembly.all.maker.renamed.gff.AED.txt

# Quality filtering of gene models
# -s: Prints transcripts with an AED <1 and/or Pfam domain if in gff3
# Removes ab initio-only predictions without functional support
perl $MAKERBIN/quality_filter.pl -s ${gff}.iprscan.gff > ${gff}_iprscan_quality_filtered.gff


# Extract only gene-related features from GFF3
grep -P "\tgene\t|\tCDS\t|\texon\t|\tfive_prime_UTR\t|\tthree_prime_UTR\t|\tmRNA\t" ${gff}_iprscan_quality_filtered.gff > filtered.genes.renamed.gff3

# Verify feature types retained
cut -f3 filtered.genes.renamed.gff3 | sort | uniq

# Load required modules for sequence extraction
module load UCSC-Utils/448-foss-2021a
module load MariaDB/10.6.4-GCC-10.3.0

# Extract mRNA IDs from filtered GFF3
grep -P "\tmRNA\t" filtered.genes.renamed.gff3 | awk '{print $9}' | cut -d ';' -f1 | sed 's/ID=//g' > list.txt

# Extract filtered transcript sequences, corresponding to retained gene models
faSomeRecords ${transcript} list.txt ${transcript}.filtered.fasta

# Extract filtered protein sequences, corresponding to retained gene models
faSomeRecords ${protein} list.txt ${protein}.filtered.fasta