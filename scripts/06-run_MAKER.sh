#!/bin/bash
#SBATCH --job-name=MAKER_annotation
#SBATCH --partition=pibu_el8
#SBATCH --mem=240G
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=50
#SBATCH --time=7-00:00

# User-editable variables
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"

# Working directory containing edited maker_opts.ctl and other control files
WORKDIR="/data/users/lansorge/organisation_annotation/gene_annotation_directory"

cd $WORKDIR

# RepeatMasker directory for TE masking during annotation
REPEATMASKER_DIR="/data/courses/assembly-annotation-course/CDS_annotation/softwares/RepeatMasker"

export PATH=$PATH:"/data/courses/assembly-annotation-course/CDS_annotation/softwares/RepeatMasker"

# Load required modules for MPI parallelization and Augustus ab initio gene prediction
module load OpenMPI/4.1.1-GCC-10.3.0
module load AUGUSTUS/3.4.0-foss-2021a

# Run MAKER with MPI across 50 parallel tasks
mpiexec --oversubscribe -n 50 apptainer exec \
    --bind $SCRATCH:/TMP --bind $COURSEDIR --bind $AUGUSTUS_CONFIG_PATH --bind $REPEATMASKER_DIR --bind /data \
    ${COURSEDIR}/containers/MAKER_3.01.03.sif \
    maker -mpi --ignore_nfs_tmp -TMP /TMP maker_opts.ctl maker_bopts.ctl maker_evm.ctl maker_exe.ctl
