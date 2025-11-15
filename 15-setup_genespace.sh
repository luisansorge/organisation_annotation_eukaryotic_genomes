#!/usr/bin/env bash
#SBATCH --job-name=setup_genespace
#SBATCH --partition=pibu_el8
#SBATCH --time=02:00:00
#SBATCH --cpus-per-task=12
#SBATCH --mem=16G

set -e

# Paths
WORK_DIR="/data/users/lansorge/organisation_annotation/results"
ANNOTATION_DIR="/data/users/lansorge/organisation_annotation/gene_annotation_directory/Abd-0.asm.bp.p_ctg.maker.output/final/"
GENESPACE_DIR="${WORK_DIR}/genespace"
COURSE_DATA="/data/courses/assembly-annotation-course/CDS_annotation/data"
LIAN_GFF="${COURSE_DATA}/Lian_et_al/gene_gff/selected"
LIAN_PROTEIN="${COURSE_DATA}/Lian_et_al/protein/selected"

# Accession names, underscores for GENESPACE compatibility
MY_ACCESSION="Abd_0"
OTHER_ACCESSIONS=("Etna_2" "Ice_1" "Taz_0")

# Create GENESPACE directory structure
mkdir -p "${GENESPACE_DIR}/peptide" # peptide FASTA files
mkdir -p "${GENESPACE_DIR}/bed"     # bed files for gene locations

# Process Abd_0 (own assembly)
GFF_FILE="/data/users/lansorge/organisation_annotation/gene_annotation_directory/Abd-0.asm.bp.p_ctg.maker.output/final/filtered.genes.renamed.gff3"
PROTEIN_FILE="/data/users/lansorge/organisation_annotation/gene_annotation_directory/Abd-0.asm.bp.p_ctg.maker.output/final/assembly.all.maker.proteins.fasta.renamed.fasta.filtered.longest.fasta"

# Create bed file from GFF3 (chr, start, end, gene_name)
grep -P "\tgene\t" "${GFF_FILE}" | \
awk 'BEGIN{OFS="\t"} {
    split($9, a, ";");
    split(a[1], b, "=");
    gene_id = b[2];
    gsub(/[:.-]/, "_", gene_id);
    print $1, $4-1, $5, gene_id
}' | sort -k1,1 -k2,2n > "${GENESPACE_DIR}/bed/${MY_ACCESSION}.bed"

# Create peptide FASTA file with cleaned IDs
awk '
/^>/ {
    if(seq != "") {
        print seq;
    }
    id = substr($1, 2);
    sub(/-R.*/, "", id);
    sub(/\.[0-9]+$/, "", id);
    gsub(/[:.-]/, "_", id);
    print ">" id;
    seq = "";
    next;
}
{
    gsub(/[^A-Za-z*]/, "", $0);
    seq = seq $0;
}
END {
    if(seq != "") {
        print seq;
    }
}
' "${PROTEIN_FILE}" > "${GENESPACE_DIR}/peptide/${MY_ACCESSION}.fa"

# Process TAIR10 reference genome, clean IDs
awk 'BEGIN{OFS="\t"} {
    gene_id = $4;
    sub(/\.[0-9]+$/, "", gene_id);
    gsub(/[:.-]/, "_", gene_id);
    print $1, $2, $3, gene_id;
}' "${COURSE_DATA}/TAIR10.bed" | sort -k1,1 -k2,2n > "${GENESPACE_DIR}/bed/TAIR10.bed"

# Clean TAIR10 peptide FASTA (same cleaning as above)
awk '
/^>/ {
    if(seq != "") {
        print seq;
    }
    id = substr($1, 2);
    sub(/\.[0-9]+$/, "", id);
    gsub(/[:.-]/, "_", id);
    print ">" id;
    seq = "";
    next;
}
{
    gsub(/[^A-Za-z*]/, "", $0);
    seq = seq $0;
}
END {
    if(seq != "") {
        print seq;
    }
}
' "${COURSE_DATA}/TAIR10.fa" > "${GENESPACE_DIR}/peptide/TAIR10.fa"

# Process other accessions from Lian et al. dataset
for ACC in "${OTHER_ACCESSIONS[@]}"; do
    ACC_DASH="${ACC//_/-}"
    
    GFF="${LIAN_GFF}/${ACC_DASH}.*.gff"
    GFF=$(ls ${GFF} 2>/dev/null | head -n 1)
    
    PROT="${LIAN_PROTEIN}/${ACC_DASH}.protein.faa"
    PROT=$(ls ${PROT} 2>/dev/null | head -n 1)
    
    if [[ -z "${GFF}" ]] || [[ -z "${PROT}" ]]; then
        continue
    fi
    
    grep -P "\tgene\t" "${GFF}" | \
    awk 'BEGIN{OFS="\t"} {
        split($9, a, ";");
        split(a[1], b, "=");
        gene_id = b[2];
        gsub(/[:.-]/, "_", gene_id);
        print $1, $4-1, $5, gene_id
    }' | sort -k1,1 -k2,2n > "${GENESPACE_DIR}/bed/${ACC}.bed"
    
    awk '
    /^>/ {
        if(seq != "") {
            print seq;
        }
        id = substr($1, 2);
        sub(/-R.*/, "", id);
        sub(/\.[0-9]+$/, "", id);
        gsub(/[:.-]/, "_", id);
        print ">" id;
        seq = "";
        next;
    }
    {
        gsub(/[^A-Za-z*]/, "", $0);
        seq = seq $0;
    }
    END {
        if(seq != "") {
            print seq;
        }
    }
    ' "${PROT}" > "${GENESPACE_DIR}/peptide/${ACC}.fa"
done

echo "Done"