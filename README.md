# Organisation and Annotation of Eukaryote Genomes

## Project Description

This project implements a comprehensive computational workflow for the assembly, annotation, and comparative analysis of eukaryotic genomes. Using *Arabidopsis thaliana* accessions as a model system, we perform de novo genome assembly from HiFi sequencing data, followed by systematic annotation of transposable elements (TEs) and protein-coding genes. The pipeline integrates multiple evidence sources including RNA-seq data, protein homology, and ab initio predictions to produce high-quality genome annotations. Finally, we conduct comparative genomics analysis to identify core, accessory, and unique genes across multiple accessions, revealing insights into genome evolution and structural variation.

## Goals

- **Genome Assembly**: Generate high-quality genome assemblies from HiFi sequencing reads
- **TE Annotation**: Identify and classify transposable elements to understand genome dynamics and evolutionary history
- **Gene Annotation**: Predict protein-coding genes using multiple lines of evidence (RNA-seq, protein homology, ab initio predictions)
- **Functional Annotation**: Assign putative functions to predicted genes using domain analysis and homology searches
- **Quality Assessment**: Evaluate annotation completeness and accuracy using standardized metrics
- **Comparative Genomics**: Identify orthogroups and syntenic regions across multiple genome accessions to define the pangenome structure

## Input Data / Datasets

### Primary Data
- **HiFi Sequencing Reads**: High-fidelity long reads for genome assembly
- **RNA-seq Data**: Paired-end Illumina reads for gene expression evidence
- **Reference Genome**: *Arabidopsis thaliana* TAIR10 for comparison and validation

### Reference Databases
- **TAIR10 CDS**: Coding sequences for masking during TE annotation
- **TAIR10 Proteins**: Reference proteins for homology-based gene prediction
- **UniProt Viridiplantae**: Curated plant proteins for functional annotation
- **Pfam**: Protein domain database (via InterProScan)
- **BUSCO Brassicales**: Conserved single-copy orthologs for quality assessment (~4,596 genes)
- **REXdb-plant**: Plant-specific TE protein domain database for TEsorter

### Additional Accessions
- Multiple *Arabidopsis* accessions from Lian et al. dataset for comparative genomics (Etna-2, Ice-1, Taz-0)

---

## Workflow Overview

### 1. Transposable Element Annotation

#### 1.1 TE Identification and Classification
**`01-run_edta.sh`** - EDTA Pipeline
- Identifies LTR retrotransposons, TIR/DNA transposons, and Helitrons
- Builds non-redundant TE library classified to superfamily level
- Masks gene sequences to avoid false positives
- Performs whole-genome TE annotation producing GFF3 files
- Generates summary statistics and RepeatMasker output

**Outputs**: TE library, genome-wide annotation (GFF3), intact TE annotations, summary statistics

#### 1.2 Clade-Level Classification
**`02-run_TEsorter.sh`** - TEsorter on Raw LTR-RTs
- Classifies full-length LTR retrotransposons into specific clades
- Uses REXdb plant database for protein domain analysis
- Provides Class → Order → Superfamily → Clade hierarchy

**`02a-full_length_LTRs_identity.R`** - LTR Identity Analysis
- Visualizes LTR identity distributions by clade (Copia and Gypsy)
- High identity (99-100%) = recent insertions; Low identity (80-90%) = ancient insertions
- Generates publication-ready plots

**`03-run_TEsorter_superfamilies.sh`** - Superfamily-Specific Classification
- Extracts Copia and Gypsy sequences separately from TE library
- Runs TEsorter independently on each superfamily
- Enables detailed clade abundance comparison

#### 1.3 TE Age Estimation
**`04-run_TEsorter_dating.sh`** / **`05a-parseRM.pl`** - TE Divergence Analysis
- Parses RepeatMasker output to calculate corrected divergence
- Accounts for CpG hypermutation
- Enables estimation of TE insertion age (T = K/2r)
- Low divergence = young TEs; High divergence = old TEs

---

### 2. Gene Annotation with MAKER

#### 2.1 MAKER Setup
**`05-create_control_files.sh`** - Generate Control Files
- Creates MAKER configuration templates (`maker_opts.ctl`, `maker_bopts.ctl`, etc.)
- Must be manually edited to specify genome, transcriptome, protein databases, and TE library

#### 2.2 Gene Prediction
**`06-run_MAKER.sh`** - MAKER Annotation Pipeline
- Integrates three evidence types:
  - **Ab initio predictions**: Augustus (pattern-based gene finding)
  - **RNA-seq evidence**: Transcriptome alignment
  - **Protein homology**: TAIR10 and UniProt alignments
- Masks transposable elements using EDTA library
- Predicts gene structures with exon-intron boundaries
- Detects alternative splice variants
- Runs with MPI parallelization (50 cores)

**Outputs**: Per-contig GFF3, protein, and transcript files

#### 2.3 Output Consolidation
**`07-merge_MAKER_outputs.sh`** - Merge Annotations
- Consolidates per-contig outputs into single genome-wide files
- Creates merged GFF3 (with/without sequences) and FASTA files
- Essential step before downstream processing

---

### 3. Annotation Refinement and Quality Control

#### 3.1 Gene Renaming
**`08-rename_maker_genes.sh`** - Systematic ID Assignment
- Replaces MAKER auto-generated IDs with clean, accession-specific identifiers
- Format: `Abd-0_0000001-RA` (prefix + number + isoform)
- Maintains consistency across GFF3, proteins, and transcripts

#### 3.2 Functional Annotation
**`09-run_interproscan.sh`** - Domain and GO Term Assignment
- Scans proteins for Pfam domains
- Assigns Gene Ontology (GO) terms
- Links to InterPro entries
- Provides functional characterization

#### 3.3 Quality Filtering
**`10-filter_and_refine_annotations.sh`** - Evidence-Based Filtering
- Integrates InterProScan results into GFF3
- Calculates AED (Annotation Edit Distance) scores
  - AED = 0.0: Perfect evidence support
  - AED = 1.0: No evidence (ab initio only)
- Filters genes requiring either:
  - AED < 1.0 (evidence support), OR
  - Pfam domain present (functional annotation)
- Extracts high-confidence gene models

#### 3.4 Isoform Selection
**`11-extract_longest_isoforms.sh`** - Longest Isoform per Gene
- Removes alternative splice variants
- Retains longest protein/transcript per gene
- Required for BUSCO and comparative genomics

---

### 4. Quality Assessment

#### 4.1 BUSCO Analysis
**`12-run_BUSCO.sh`** / **`12a-BUSCO_plot.sh`** - Annotation Completeness
- Searches for conserved single-copy orthologs (Brassicales dataset: ~4,596 BUSCOs)
- Metrics: Complete, Duplicated, Fragmented, Missing
- Runs on both proteins and transcripts
- Benchmark: >90-95% complete for high-quality annotations

#### 4.2 Annotation Statistics
**`13-generate_AGAT_statistics.sh`** - Comprehensive Metrics
- Gene/transcript/exon counts and lengths
- Distribution statistics (mean, median, min, max)
- Structural feature analysis (introns, UTRs, CDS)
- Enables cross-accession comparisons

---

### 5. Functional Annotation via Homology

**`14-blastp_functional_annotation.sh`** - BLAST Searches
- **UniProt BLASTP**: Transfers functional annotations from curated plant proteins
- **TAIR10 BLASTP**: Identifies *Arabidopsis* orthologs
- Integrates gene names and descriptions into GFF3 and FASTA headers
- Assesses annotation quality (proportion of genes with known homologs)

---

### 6. Comparative Genomics

#### 6.1 Input Preparation
**`15-prepare_genespace_inputs.sh`** - Format Files for GENESPACE
- Converts annotations to BED format (0-based coordinates)
- Extracts peptide sequences with clean IDs
- Processes multiple accessions (Abd-0, TAIR10, Etna-2, Ice-1, Taz-0)
- Critical: Replaces problematic characters (`:`, `.`, `-`) with `_`

#### 6.2 Orthology and Synteny Analysis
**`16-run_genespace.sh`** / **`16a_genespace.R`** - GENESPACE Pipeline
- **DIAMOND BLAST**: Fast protein similarity searches
- **OrthoFinder**: Identifies orthogroups (genes from common ancestor)
- **MCScanX**: Detects syntenic blocks (conserved gene order)
- Defines pangenome structure:
  - **Core genes**: Present in all accessions (essential, conserved)
  - **Accessory genes**: Present in some accessions (adaptive)
  - **Unique genes**: Present in one accession (lineage-specific)
- Generates dotplots (pairwise synteny) and riparian plots (multi-genome)

**Outputs**: Orthogroup assignments, syntenic coordinates, visualization plots, pangenome matrix

---

## Key Technologies and Tools

- **Assembly**: Hifiasm
- **TE Annotation**: EDTA, TEsorter, RepeatMasker
- **Gene Prediction**: MAKER, Augustus, GeneMark
- **Functional Annotation**: InterProScan, BLASTP
- **Quality Assessment**: BUSCO, AGAT
- **Comparative Genomics**: GENESPACE, OrthoFinder, MCScanX, DIAMOND
- **Visualization**: R (ggplot2, circlize), custom scripts
- **Infrastructure**: SLURM cluster, Apptainer/Singularity containers

---
