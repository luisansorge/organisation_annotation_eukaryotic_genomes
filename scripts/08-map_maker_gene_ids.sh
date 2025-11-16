#!/bin/bash
#SBATCH --job-name=storeannot
#SBATCH --partition=pibu_el8 
#SBATCH --cpus-per-task=20 
#SBATCH --mem=64G 
#SBATCH --time=2-00:00 

# Define input files (merged MAKER outputs)
protein="assembly.all.maker.proteins.fasta"
transcript="assembly.all.maker.transcripts.fasta"
gff="assembly.all.maker.noseq.gff"

COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
MAKERBIN="$COURSEDIR/softwares/Maker_v3.01.03/src/bin"
WORKDIR="/data/users/lansorge/organisation_annotation/gene_annotation_directory/Abd-0.asm.bp.p_ctg.maker.output/"

cd $WORKDIR
mkdir final 

# Store renamed outputs separately to preserve original files
cp $gff final/${gff}.renamed.gff
cp $protein final/${protein}.renamed.fasta
cp $transcript final/${transcript}.renamed.fasta

cd final

# Generate ID mapping file, creates mapping from old IDs to new IDs with format
# --prefix  : Accession-specific prefix (Abd-0)
# --justify : Number of digits (7 = 0000001, allows up to 9,999,999 genes)
$MAKERBIN/maker_map_ids --prefix Abd-0 --justify 7 ${gff}.renamed.gff > id.map

# Apply ID mapping to GFF, protein FASTA, and transcript FASTA files
$MAKERBIN/map_gff_ids id.map ${gff}.renamed.gff
$MAKERBIN/map_fasta_ids id.map ${protein}.renamed.fasta
$MAKERBIN/map_fasta_ids id.map ${transcript}.renamed.fasta
