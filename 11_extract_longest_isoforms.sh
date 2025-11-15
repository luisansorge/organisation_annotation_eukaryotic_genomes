#!/bin/bash
#SBATCH --time=1:00:00
#SBATCH --partition=pibu_el8
#SBATCH --mem=8G
#SBATCH --cpus-per-task=1
#SBATCH --job-name=extract_longest


# General path
ANNODIR="/data/users/lansorge/organisation_annotation/gene_annotation_directory/Abd-0.asm.bp.p_ctg.maker.output/final"

# Change to final directory
cd "$ANNODIR" || exit 1

# Define file names
protein="assembly.all.maker.proteins.fasta.renamed.fasta.filtered.fasta"
transcript="assembly.all.maker.transcripts.fasta.renamed.fasta.filtered.fasta"

# Extract Longest Protein Isoforms
echo "========================================"
echo "Extracting longest protein isoforms..."
echo "========================================"

# AWK script:
# Parses FASTA headers (lines starting with >)
# Extracts gene name by removing isoform suffix (-RA, -RB, etc.)
# Tracks sequence length for each isoform
# Keeps only the longest isoform per gene
awk '/^>/ {
    if (seqlen > maxlen[gene]) {
        maxlen[gene] = seqlen
        seq[gene] = header "\n" sequence
    }
    header = $0
    gene = $0
    sub(/^>/, "", gene)
    sub(/-R.*/, "", gene)
    sequence = ""
    seqlen = 0
    next
}
{
    sequence = sequence $0
    seqlen += length($0)
}
END {
    if (seqlen > maxlen[gene]) {
        maxlen[gene] = seqlen
        seq[gene] = header "\n" sequence
    }
    for (g in seq) print seq[g]
}' "$protein" > "${protein%.fasta}.longest.fasta"

# Extract Longest Transcript Isoforms
echo "========================================"
echo "Extracting longest transcript isoforms..."
echo "========================================"

awk '/^>/ {
    if (seqlen > maxlen[gene]) {
        maxlen[gene] = seqlen
        seq[gene] = header "\n" sequence
    }
    header = $0
    gene = $0
    sub(/^>/, "", gene)
    sub(/-R.*/, "", gene)
    sequence = ""
    seqlen = 0
    next
}
{
    sequence = sequence $0
    seqlen += length($0)
}
END {
    if (seqlen > maxlen[gene]) {
        maxlen[gene] = seqlen
        seq[gene] = header "\n" sequence
    }
    for (g in seq) print seq[g]
}' "$transcript" > "${transcript%.fasta}.longest.fasta"