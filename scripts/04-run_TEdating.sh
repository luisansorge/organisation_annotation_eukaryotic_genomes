#!/bin/bash
#SBATCH --job-name=tedating
#SBATCH --partition=pibu_el8 
#SBATCH --cpus-per-task=4 
#SBATCH --mem=10G 
#SBATCH --time=0-02:00 

# Load BioPerl module (required by parseRM.pl script)
module add BioPerl/1.7.8-GCCcore-10.3.0

# -l: minimum length threshold (50bp) and behavior for fragments (1 = keep)
# -v: verbose output for tracking progress
perl 04a-parseRM.pl -i /data/users/lansorge/organisation_annotation/results/EDTA_annotation/Abd-0.asm.bp.p_ctg.fa.mod.EDTA.anno/Abd-0.asm.bp.p_ctg.fa.mod.out -l 50,1 -v
