#!/bin/bash
#SBATCH --job-name=busco
#SBATCH --partition=pibu_el8 
#SBATCH --cpus-per-task=20
#SBATCH --mem=64G 
#SBATCH --time=0-10:00 

# Load BUSCO module
module load BUSCO/5.4.2-foss-2021a

WORKDIR="/data/users/lansorge/organisation_annotation/gene_annotation_directory/Abd-0.asm.bp.p_ctg.maker.output/final"
cd $WORKDIR

# Input files (longest isoforms only to avoid counting genes multiple times)
transcripts="assembly.all.maker.transcripts.fasta.renamed.fasta.filtered.longest.fasta"
proteins="assembly.all.maker.proteins.fasta.renamed.fasta.filtered.longest.fasta"

# Run BUSCO on protein sequences
# -l: lineage dataset
# -m: protein mode
busco -i $proteins -l brassicales_odb10 -o busco_output_proteins -m proteins

# Run BUSCO on transcript sequences
# -l: lineage dataset
# -m: transcriptome mode
busco -i $transcripts -l brassicales_odb10 -o busco_output_transcripts -m transcriptome
