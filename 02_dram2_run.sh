#!/bin/bash
#SBATCH --job-name=dram2
#SBATCH --partition=x86_64_4cpu
#SBATCH --cpus-per-task=1
#SBATCH --time=168:00:00

DRAM=/share/home/stxy1yyc2sxt/.nextflow/assets/BortonWrightonLabs/DRAM
ENV=env_nf
PROFILE=slurm,singularity
RUN=$(readlink -f "$1")

source ~/.bashrc
conda activate "$ENV"

export NXF_OFFLINE=true
export NXF_SINGULARITY_CACHEDIR=$HOME/.nextflow/singularity

cd "$RUN"

nextflow run "$DRAM" \
    -profile "$PROFILE" \
    -w "$RUN/work" \
    --input_fasta "$RUN/input/" \
    --outdir "$RUN/results" \
    -resume -ansi-log false
