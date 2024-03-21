#!/bin/bash
#PBS -l walltime=96:00:00
#PBS -l nodes=1:ppn=1,pmem=5g
#PBS -q batch
#PBS -j oe
#PBS -o logs/$PBS_JOBNAME.$PBS_JOBID.log

source activate nf
module load singularity/3.11.4

cd $PBS_O_WORKDIR #so that all paths are interpreted relative to project root

JOB_BASENAME=$(echo $PBS_JOBNAME | cut -d . -f 1) # dots are not allowed in nf run names
RUN_NAME="$JOB_BASENAME"-retry-00

INPUT=data/metadata/metadata_w_accesions.tsv
RUN_LIST=temp/run_list.tsv
OUTDIR=data/raw/$JOB_BASENAME
CONFIG_FILE=src/nf.config.fetchngs
NF_WORKDIR=temp/nf_work_$JOB_BASENAME

export NXF_SINGULARITY_CACHEDIR=bin/nf_singularity_cache

# extract run accessions from metadata file
cut -f 2 $INPUT | grep ERR* > $RUN_LIST

# launch nf-core fetchngs pipeline
nextflow run nf-core/fetchngs \
	-r 1.12.0 \
	-name $RUN_NAME \
	-profile singularity \
	-c $CONFIG_FILE \
	-work-dir $NF_WORKDIR \
	-resume \
	-ansi-log false \
	--input $RUN_LIST \
	--download_method aspera \
	--outdir $OUTDIR

# clean the input file
rm $RUN_LIST
