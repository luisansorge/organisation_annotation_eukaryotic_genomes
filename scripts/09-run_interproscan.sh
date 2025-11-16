#!/bin/bash
#SBATCH --job-name=interproscan
#SBATCH --partition=pibu_el8 
#SBATCH --cpus-per-task=20 
#SBATCH --mem=64G 
#SBATCH --time=2-00:00 

# Input protein file (renamed MAKER proteins)
protein="assembly.all.maker.proteins.fasta.renamed.fasta"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
WORKDIR="/data/users/lansorge/organisation_annotation/gene_annotation_directory/Abd-0.asm.bp.p_ctg.maker.output/final"

cd $WORKDIR

# Run InterProScan using Apptainer
apptainer exec --bind /data --bind $SCRATCH:/temp --bind $COURSEDIR/data/interproscan-5.70-102.0/data:/opt/interproscan/data \
    $COURSEDIR/containers/interproscan_latest.sif \
    /opt/interproscan/interproscan.sh \
    # Pfam database for protein family domains, TSV output format
    -appl pfam --disable-precalc -f TSV \
    # Include Gene Ontology term annotations and InterPro entry annotations, protein sequence type
    --goterms --iprlookup --seqtype p \
    -i $protein -o output.iprscan
