#!/bin/bash
#SBATCH --job-name=tesorter
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=20 
#SBATCH --mem=64G 
#SBATCH --time=2-00:00 

# User-editable variables
WORKDIR=/data/users/lansorge/organisation_annotation
# Path to TEsorter singularity container (v1.3.0)
CONTAINER=/data/courses/assembly-annotation-course/CDS_annotation/containers/TEsorter_1.3.0.sif
# Raw full-legnth LTR retrotransposon sequences from EDTA
INPUT_LTR=/data/users/lansorge/organisation_annotation/results/EDTA_annotation/Abd-0.asm.bp.p_ctg.fa.mod.EDTA.raw/Abd-0.asm.bp.p_ctg.fa.mod.LTR.raw.fa
OUTDIR=$WORKDIR/results/TEsorter

mkdir -p "$OUTDIR"
cd "$OUTDIR"

apptainer run --bind /data \
    "$CONTAINER" \
    TEsorter \
    "$INPUT_LTR" \
    -db rexdb-plant \       # Plant-specific TE protein domain database (REXdb)

