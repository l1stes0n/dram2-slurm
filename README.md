# DRAM2 Slurm pipeline

DRAM2 (`dev`) annotation for a directory of scaffold FASTAs: one Nextflow run,
each per-sample and per-database task submitted as a Slurm job.

## Files

| file | what it does |
|---|---|
| `00_prepull_images.sh` | installs the `nf-schema` plugin and downloads the SIF images |
| `01_dram2_submit.sh` | stages the FASTAs as `input/<sample>.fasta` and submits `02_dram2_run.sh` |
| `02_dram2_run.sh` | the submitted job: `nextflow run …` |
| `nextflow.config` | replaces the `nextflow.config` of the DRAM checkout |
| `fegenie.hmm` | FeGenie HMM database in HMMER3/f format |

## Usage

```bash
bash 00_prepull_images.sh
cp nextflow.config /share/home/stxy1yyc2sxt/.nextflow/assets/BortonWrightonLabs/DRAM/nextflow.config
cp fegenie.hmm /share/home/stxy1yyc/database/DRAM_db/databases/fegenie/fegenie.hmm
# dbCAN databases, from
#   https://pro.unl.edu/dbCAN2/browse_download.php?path=run_dbCAN_database_total/db_v5-2_9-13-2025
# into /share/home/stxy1yyc/database/DRAM_db/databases/dbcan/:
#   CAZy.dmnd dbCAN.hmm dbCAN-sub.hmm fam-substrate-mapping.tsv
#   TCDB.dmnd TF.hmm TF.dmnd STP.hmm PUL.dmnd dbCAN-PUL.xlsx dbCAN-PUL.tar.gz
#   peptidase_db.dmnd sulfatlas_db.dmnd
#   (rename dbCAN_sub.hmm to dbCAN-sub.hmm, extract dbCAN-PUL.tar.gz)
bash 01_dram2_submit.sh <scaffold_dir> [run_dir]
```

Results: `<run_dir>/results`.
