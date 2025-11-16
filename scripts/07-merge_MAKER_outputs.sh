#!/bin/bash
#SBATCH --job-name=mergegff
#SBATCH --partition=pibu_el8 
#SBATCH --cpus-per-task=20 
#SBATCH --mem=64G
#SBATCH --time=2-00:00 

COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"

# MAKER output directory containing the datastore and index file
OUTDIR="/data/users/lansorge/organisation_annotation/gene_annotation_directory/Abd-0.asm.bp.p_ctg.maker.output"

cd $OUTDIR

# Path to MAKER utility scripts
MAKERBIN="$COURSEDIR/softwares/Maker_v3.01.03/src/bin"

# Merge GFF3 files with sequences embedded
# -s : include sequences in GFF3 
# -d : path to datastore index log file
$MAKERBIN/gff3_merge -s -d /data/users/lansorge/organisation_annotation/gene_annotation_directory/Abd-0.asm.bp.p_ctg.maker.output/Abd-0.asm.bp.p_ctg_master_datastore_index.log > assembly.all.maker.gff

# Merge GFF3 files without sequences 
# -n : no sequences in GFF3 
# -s : sorted output
$MAKERBIN/gff3_merge -n -s -d /data/users/lansorge/organisation_annotation/gene_annotation_directory/Abd-0.asm.bp.p_ctg.maker.output/Abd-0.asm.bp.p_ctg_master_datastore_index.log > assembly.all.maker.noseq.gff

# Merge FASTA files proteins and transcripts
$MAKERBIN/fasta_merge -d /data/users/lansorge/organisation_annotation/gene_annotation_directory/Abd-0.asm.bp.p_ctg.maker.output/Abd-0.asm.bp.p_ctg_master_datastore_index.log -o assembly
