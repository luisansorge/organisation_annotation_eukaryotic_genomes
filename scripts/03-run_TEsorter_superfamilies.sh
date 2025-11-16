#!/bin/bash
#SBATCH --job-name=tesorter
#SBATCH --partition=pibu_el8 
#SBATCH --cpus-per-task=4 
#SBATCH --mem=10G 
#SBATCH --time=0-02:00

# User-editable variables
WORKDIR=/data/users/lansorge/organisation_annotation
OUTDIR=$WORKDIR/results/TEsorter

cd "$OUTDIR"

module load SeqKit/2.6.1

# Extract all Copia superfamily sequences from EDTA's final TE library
seqkit grep -r -p "Copia" /data/users/lansorge/organisation_annotation/results/EDTA_annotation/Abd-0.asm.bp.p_ctg.fa.mod.EDTA.TElib.fa > Copia_sequences.fa

# Extract all Gypsy superfamily sequences from EDTA's final TE library
seqkit grep -r -p "Gypsy" /data/users/lansorge/organisation_annotation/results/EDTA_annotation/Abd-0.asm.bp.p_ctg.fa.mod.EDTA.TElib.fa > Gypsy_sequences.fa

# Classify Copia elements into clades using TEsorter
apptainer exec --bind /data \
    /data/courses/assembly-annotation-course/CDS_annotation/containers/TEsorter_1.3.0.sif \
    TEsorter Copia_sequences.fa -db rexdb-plant

# Classify Gypsy elements into clades using TEsorter
apptainer exec --bind /data \
    /data/courses/assembly-annotation-course/CDS_annotation/containers/TEsorter_1.3.0.sif \
    TEsorter Gypsy_sequences.fa -db rexdb-plant
