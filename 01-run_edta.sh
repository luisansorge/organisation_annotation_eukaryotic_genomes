#!/bin/bash
#SBATCH --job-name=te_annot
#SBATCH --partition=pibu_el8 # IBU cluster partition
#SBATCH --cpus-per-task=20 # e.g. 20
#SBATCH --mem=64 # e.g. 64G or 200G
#SBATCH --time=2-00:00 # format D-HH:MM, e.g. 2-00:00

# User-editable variables
WORKDIR=/data/users/lansorge/organisation_annotation
CONTAINER=/data/courses/assembly-annotation-course/CDS_annotation/containers/EDTA2.2.sif
INPUT_FASTA=/data/users/lansorge/assembly_annotation_course/hifiasm_assembly/Abd-0.asm.bp.p_ctg.fa
OUTDIR=$WORKDIR/results/EDTA_annotation

mkdir -p "$OUTDIR"
cd "$OUTDIR"

apptainer run --bind /data \
    "$CONTAINER" \
    EDTA.pl \
    --genome $INPUT_FASTA \
    --species others \
    --step all \
    --sensitive 1 \
    --cds "/data/courses/assembly-annotation-course/CDS_annotation/data/TAIR10_cds_20110103_representative_gene_model_updated" \
    --anno 1 \
    --threads 20