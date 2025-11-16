#!/usr/bin/env bash
#SBATCH --job-name=Busco_plot
#SBATCH --partition=pibu_el8
#SBATCH --time=05:00:00
#SBATCH --cpus-per-task=10
#SBATCH --mem=16G

# Define paths to BUSCO output directories
PROT_DIR="/data/users/lansorge/organisation_annotation/gene_annotation_directory/Abd-0.asm.bp.p_ctg.maker.output/final/busco_output_proteins"
TRANS_DIR="/data/users/lansorge/organisation_annotation/gene_annotation_directory/Abd-0.asm.bp.p_ctg.maker.output/final/busco_output_transcripts"
WORKDIR="/data/users/lansorge/organisation_annotation/gene_annotation_directory/Abd-0.asm.bp.p_ctg.maker.output/final"

cd $WORKDIR

# Load BUSCO module
module load BUSCO/5.4.2-foss-2021a

# Generate individual plots 
generate_plot.py -wd $PROT_DIR
generate_plot.py -wd $TRANS_DIR

# Generate combined plot
mkdir -p combined_summaries
cp $PROT_DIR/short_summary*.txt combined_summaries/
cp $TRANS_DIR/short_summary*.txt combined_summaries/
generate_plot.py -wd combined_summaries/
