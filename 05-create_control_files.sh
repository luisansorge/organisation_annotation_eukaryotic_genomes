#!/bin/bash
#SBATCH --job-name=createcontrolfiles
#SBATCH --partition=pibu_el8 
#SBATCH --cpus-per-task=20 
#SBATCH --mem=64G 
#SBATCH --time=2-00:00

# User-editable variables
WORKDIR=/data/users/lansorge/organisation_annotation/gene_annotation_directory

cd $WORKDIR

apptainer exec --bind /data \
    /data/courses/assembly-annotation-course/CDS_annotation/containers/MAKER_3.01.03.sif \
    maker -CTL      # -CTL flag generates control files
