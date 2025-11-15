#!/usr/bin/env bash
#SBATCH --job-name=AGAT
#SBATCH --partition=pshort_el8
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G


WORKDIR="/data/users/lansorge/organisation_annotation/gene_annotation_directory/Abd-0.asm.bp.p_ctg.maker.output/final"
#LOGDIR="$WORKDIR/log"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"

cd $WORKDIR

# Input GFF3 file (final filtered annotations)
INPUTFILE="filtered.genes.renamed.gff3"
OUTDIR="$WORKDIR/agat_stats"

# Create directories if not present
#mkdir -p "$LOGDIR"
mkdir -p "$OUTDIR"

# Run AGAT Statistics Tool
apptainer exec --bind /data \
  $COURSEDIR/containers/agat_1.5.1--pl5321hdfd78af_0.sif \
  agat_sp_statistics.pl -i "$INPUTFILE" -o $OUTDIR/annotation.stat