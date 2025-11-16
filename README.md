# Organisation and Annotation of Eukaryote Genomes

## Project Description

This project contains scripts for the annotation and comparative genomics of *Arabidopsis thaliana* accessions. A systematic annotation of transposable elements (TEs) and protein-coding genes is performed, integrating RNA-seq data, protein homology and ab initio predictions to produce genome annotations. Additionlly, comparative genomics analysis was conducted to identify orthogroups and syntenic regions across multiple accessions, revealing insights into genome evolution and structural variation. 

## Datasets

### Input Data
- **Assembly Data**: PacBio HiFi long reads fromo accession Abd-0 assembled with Hifiasm (v0.25.0)
- **RNA-seq Data**: Paired-end Illumina short reads for gene expression evidence from accession Sha assembled with Trinity (v2.15.1)
- **Reference Genome**: *Arabidopsis thaliana* TAIR10

### Citations
- Lian Q, et al. **A pan-genome of 69 Arabidopsis thaliana accessions reveals a conserved genome structure throughout the global species range** Nature Genetics. 2024;56:982-991. Available from: https://www.nature.com/articles/s41588-024-01715-9
- Jiao WB, Schneeberger K. **Chromosome-level assemblies of multiple Arabidopsis genomes reveal hotspots of rearrangements with altered evolutionary dynamics.** Nature Communications. 2020;11:1–10. Available from: http://dx.doi.org/10.1038/s41467-020-14779-y
  
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

#### 1.2 Clade-Level Classification
**`02-run_TEsorter.sh`** - TEsorter on Raw LTR-RTs
- Classifies full-length LTR retrotransposons into specific clades
- Uses REXdb plant database for protein domain analysis
- Provides Class, Order, Superfamily, Clade hierarchy

**`02a-full_length_LTRs_identity.R`** - LTR Identity Analysis
- Visualises LTR identity distributions by clade (Copia and Gypsy)
- Shows age distributions to determing recent and ancient insertions

**`02b-annotation_circlize.R`** - TE and Gene Density Visualisation
- Creates circular genome plots showing TE and gene distributions across scaffolds
- Visualises density of different TE superfamilies as colored tracks
- Generates clade-specific plots for centromeric TEs (Athila and CRM clades)
- Enables identification of TE-rich vs. gene-rich genomic regions
  
**`03-run_TEsorter_superfamilies.sh`** - Superfamily-Specific Classification
- Extracts Copia and Gypsy sequences separately from TE library
- Runs TEsorter independently on each superfamily
- Enables detailed clade abundance comparison

#### 1.3 TE Age Estimation
**`04-run_TEdating.sh`** / **`04a-parseRM.pl`** - TE Divergence Analysis
- Parses RepeatMasker output to calculate corrected divergence for each TE copy from its consensus sequence
- Enables TE insertion age estimation by quantifying how much each TE copy has diverged from its original sequence. 

**`04b-plot_div.R`** - TE Landscape Divergence
- Visualise temporal dynamics of TE accumulation
- Enabling comparison of recent vs. ancient TE expansion between Copia, Gypsy, and DNA transposon superfamilies

---

### 2. Gene Annotation with MAKER

#### 2.1 MAKER Setup
**`05-create_control_files.sh`** - Generate Control Files
- Creates MAKER configuration templates (`maker_opts.ctl`, `maker_bopts.ctl`, `maker_evm.ctl`, `maker_exe.ctl`)
- Must be manually edited to specify genome, transcriptome, protein databases, TE library etc.

#### 2.2 Gene Prediction
**`06-run_MAKER.sh`** - MAKER Annotation Pipeline
- Integrates ab initio predictions, RNA-seq evidence and Protein homology leading to consensus gene models
- Masks transposable elements using EDTA library
- Predicts gene structures with exon-intron boundaries and detects alternative splice variants
- Outputs per-contig GFF3, protein, and transcript files 

#### 2.3 Output Consolidation
**`07-merge_MAKER_outputs.sh`** - Merge Annotations
- Consolidates per-contig outputs into single genome-wide files
- Creates merged GFF3 (with and without sequences) and FASTA files

---

### 3. Annotation Refinement and Quality Control

#### 3.1 Gene Renaming
**`08-map_maker_gene_ids.sh`** - Systematic ID Assignment
- Replaces MAKER auto-generated IDs with clean, accession-specific identifiers
- Format: `Abd-0_0000001-RA` (accession prefix + number + isoform)
- Creates consistent gene identifiers across GFF3, proteins, and transcripts 

#### 3.2 Functional Annotation
**`09-run_interproscan.sh`** - Domain and GO Term Assignment
- Scans proteins for conserved Pfam domains
- Assigns Gene Ontology (GO) terms for biological function
- Links to InterPro entries that integrate multiple databases, with unified protein signature database IDs 
- Provides functional characterisation of predicted genes, identifying protein families and biological roles

#### 3.3 Quality Filtering
**`10-filter_and_refine_annotations.sh`** - Evidence-Based Filtering
- Updates GFF3 with InterProScan results (Pfam domains, GO terms, InterPro IDs) 
- Calculates AED (Annotation Edit Distance) scores
- Cleans GFF3 structure by removing auxiliary features, retaining only gene-structure elements (gene, mRNA, exon, CDS, UTRs)
- Produces final gene annotations by removing low-confidence predictions and ensuring genes have either empirical evidence support or functional characterisation  

#### 3.4 Isoform Selection
**`11-extract_longest_isoforms.sh`** - Longest Isoform per Gene
- Removes alternative splice variants
- Retains longest protein and transcript per gene
- Required for BUSCO and comparative genomics analyses

---

### 4. Quality Assessment

#### 4.1 BUSCO Analysis
**`12-run_BUSCO.sh`** / **`12a-BUSCO_plot.sh`** - Annotation Completeness
- Searches for conserved single-copy orthologs (Brassicales dataset: ~4,596 BUSCOs)
- Metrics: complete, duplicated, fragmented, missing BUSCOs
- Runs on both proteins and transcripts

#### 4.2 Annotation Statistics
**`13-run_AGAT.sh`** - Comprehensive Summary Metrics
- Gene, transcript, exon counts and lengths
- Distribution statistics and Structural feature analysis
- Provides detailed annotation statistics for quality assessment and comparison across genome accessions 

---

### 5. Functional Annotation via Homology

#### 5.1 Identifying Homologs with BLASTP

**`14-run_BLASTP.sh`** - BLAST Searches
- **UniProt BLASTP**: Transfers functional annotations from curated plant proteins
- **TAIR10 BLASTP**: Identifies *Arabidopsis* orthologs from reference proteins
- Integrates gene names and descriptions into GFF3 and FASTA headers
- Assesses annotation quality (proportion of genes with known homologs)

---

### 6. Comparative Genomics

#### 6.1 Input Preparation
**`15-setup_genespace.sh`** - Format Files for GENESPACE
- Converts annotations to BED format
- Extracts peptide sequences with clean IDs
- Processes multiple accessions (Abd-0, Etna-2, Ice-1, Taz-0)
- Replaces problematic characters (`:`, `.`, `-`) with `_`

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

**`16b-process_pangenome.sh`** - Pangenome Frequency Plot
- Reads `pangenome_matrix.rds` output from GENESPACE containing orthogroup assignments
- Quantifies pangenome architecture, conserved vs. variable gene content, assess genome-specific innovations and losses, and compare gene diversity across accessions

---

## Dependencies

### Tools

- **TE Annotation**: EDTA (v2.2), TEsorter (v1.3.0), SeqKit (v2.6.1), BioPerl (v1.7.8)
- **Gene Prediction**: MAKER (v3.01.03), OpenMPI (v4.1.1), Augustus (v3.4.0)
- **Functional Annotation**: InterProScan (v5.70-102.0), BLAST+ (v2.15.0)
- **Quality Assessment**: UCSC-Utils (v448), MariaDB (v10.6.4), BUSCO (v5.4.2), AGAT (v1.5.1)
- **Comparative Genomics**: GENESPACE

### R v(4.4.3) Packages

- tidyverse
- data.table
- cowplot
- circlize
- ComplexHeatmap
- dplyr
- reshape2
- GENESPACE
  
---
