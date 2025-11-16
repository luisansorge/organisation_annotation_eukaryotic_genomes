#!/bin/bash
#SBATCH --job-name=te_annot
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=20 
#SBATCH --mem=200G 
#SBATCH --time=2-00:00 

# User-editable variables
WORKDIR=/data/users/lansorge/organisation_annotation
# Path to EDTA singularity container (v2.2)
CONTAINER=/data/courses/assembly-annotation-course/CDS_annotation/containers/EDTA2.2.sif
# Input genome assembly (Hifiasm) in FASTA format
INPUT_FASTA=/data/users/lansorge/assembly_annotation_course/hifiasm_assembly/Abd-0.asm.bp.p_ctg.fa
OUTDIR=$WORKDIR/results/EDTA_annotation

mkdir -p "$OUTDIR"
cd "$OUTDIR"

apptainer run --bind /data \
    "$CONTAINER" \  
    EDTA.pl \
    --genome $INPUT_FASTA \
    --species others \       # Generic TE library (not species-specific)
    --step all \        # Run all annotation steps (LTR, TIR, Helitron, etc.)
    --sensitive 1 \      # Sensitive mode for better TE detection
    --cds "/data/courses/assembly-annotation-course/CDS_annotation/data/TAIR10_cds_20110103_representative_gene_model_updated" \        # Provide CDS sequences to avoid misclassifying genes as TEs
    --anno 1 \      # Genome-wide TE annotation (intact and fragmented TEs)
    --threads 20
