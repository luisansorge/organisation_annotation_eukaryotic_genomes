#!/bin/bash
#SBATCH --job-name=blast
#SBATCH --partition=pcoursea
#SBATCH --cpus-per-task=20 
#SBATCH --mem=64G 
#SBATCH --time=0-05:00 

# Load BLAST+ module
module load BLAST+/2.15.0-gompi-2021a

# Database paths
UNIPROT_DB="/data/courses/assembly-annotation-course/CDS_annotation/data/uniprot/uniprot_viridiplantae_reviewed.fa"
TAIR10_DB="/data/courses/assembly-annotation-course/CDS_annotation/data/TAIR10_pep_20110103_representative_gene_model"

# Results directory for BLAST outputs
RESULTS_DIR="/data/users/lansorge/organisation_annotation/results/blast/"

# filtered MAKER proteins and GFF3 input files
maker_proteins_fasta="/data/users/lansorge/organisation_annotation/gene_annotation_directory/Abd-0.asm.bp.p_ctg.maker.output/final/assembly.all.maker.proteins.fasta.renamed.fasta.filtered.fasta"
maker_gff="/data/users/lansorge/organisation_annotation/gene_annotation_directory/Abd-0.asm.bp.p_ctg.maker.output/final/filtered.genes.renamed.gff3"

# Output file paths
blastp_uniprot_output="/data/users/lansorge/organisation_annotation/results/blast/blastp_uniprot_output.out"
blastp_tair10_output="/data/users/lansorge/organisation_annotation/results/blast/blastp_tair10_output.out"

MAKERBIN="/data/courses/assembly-annotation-course/CDS_annotation/softwares/Maker_v3.01.03/src/bin"

# BLASTP against UniProt, search for homologs in curated plant proteins with known functions
blastp -query ${maker_proteins_fasta} -db ${UNIPROT_DB} -num_threads 20 -outfmt 6 -evalue 1e-5 -max_target_seqs 10 -out ${blastp_uniprot_output}

# Extract best UniProt hit per protein
sort -k1,1 -k12,12g ${blastp_uniprot_output} | sort -u -k1,1 --merge > ${blastp_uniprot_output}.besthits

# Integrate UniProt functional annotations into FASTA
cp ${maker_proteins_fasta} ${maker_proteins_fasta}.Uniprot
cp ${maker_gff} ${maker_gff}.Uniprot

# Update protein FASTA headers with UniProt annotations (gene names, functions)
$MAKERBIN/maker_functional_fasta ${UNIPROT_DB} ${blastp_uniprot_output}.besthits ${maker_proteins_fasta} > ${maker_proteins_fasta}.Uniprot

# Integrate UniProt functional annotations into GFF3
$MAKERBIN/maker_functional_gff ${UNIPROT_DB} ${blastp_uniprot_output} ${maker_gff} > ${maker_gff}.Uniprot.gff3

# BLASTP against TAIR10 (A. thaliana), identify Arabidopsis homologs
blastp -query ${maker_proteins_fasta} -db ${TAIR10_DB} -num_threads 20 -outfmt 6 -evalue 1e-5 -max_target_seqs 10 -out ${blastp_tair10_output}

# Extract best TAIR10 hit per protein
sort -k1,1 -k12,12g ${blastp_tair10_output} | sort -u -k1,1 --merge > ${blastp_tair10_output}.besthits