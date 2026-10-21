#!/bin/bash
#
# Submit the DRAM2 run for a directory of scaffold FASTAs.
#
#   bash 01_dram2_submit.sh <scaffold_dir> [run_dir]
#
DRAM=/share/home/stxy1yyc2sxt/.nextflow/assets/BortonWrightonLabs/DRAM
ENV=env_nf
QUEUE=x86_64_4cpu
TIME=168:00:00
PATTERN='*_clean_scaffolds.fasta'
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

IN=$(readlink -f "$1")
RUN=$(readlink -f "${2:-./dram2_run}")
mkdir -p "$RUN"/{input,results,work}
find "$RUN/input" -type l -delete

# One symlink per sample; DRAM2 uses the file stem as the sample name.
for f in "$IN"/$PATTERN; do
    sample="${f##*/}"
    sample="${sample%_clean_scaffolds.fasta}"
    ln -sfn "$f" "$RUN/input/$sample.fasta"
done

JOB_ID=$(sbatch --parsable --job-name=dram2 --partition="$QUEUE" --cpus-per-task=1 \
    --time="$TIME" --chdir="$RUN" "$SCRIPT_DIR/02_dram2_run.sh" "$RUN")

echo "submitted $JOB_ID ($(ls "$RUN"/input | wc -l) input files)"
echo "  results $RUN/results"
