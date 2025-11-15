#!/bin/bash
#SBATCH --job-name=genespace
#SBATCH --partition=pibu_el8 
#SBATCH --cpus-per-task=20 
#SBATCH --mem=64G 
#SBATCH --time=0-05:00

COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
WORKDIR="/data/users/lansorge/organisation_annotation/results/genespace"

# Directory containing R script for GENESPACE
SCRIPTDIR="/data/users/lansorge/organisation_annotation/scripts"

cd $WORKDIR

# Run GENESPACE using Apptainer and the 16a_genespace.R script
apptainer exec \
    --bind /data \
    --bind $SCRATCH:/temp \
    $COURSEDIR/containers/genespace_latest.sif Rscript $SCRIPTDIR/16a_genespace.R $WORKDIR