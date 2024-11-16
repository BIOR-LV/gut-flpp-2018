#!/bin/bash
#PBS -l walltime=336:00:00
#PBS -l nodes=1:ppn=1,pmem=5g
#PBS -q long
#PBS -j oe
#PBS -A bior
#PBS -o logs/$PBS_JOBNAME.$PBS_JOBID.log

cd $PBS_O_WORKDIR #so that all paths are interpreted relative to project root

JOB_BASENAME=$(echo $PBS_JOBNAME | cut -d . -f 1) # dots are not allowed in nf run names
RUN_NAME="$JOB_BASENAME"-retry-02

source activate env/nextflow
module load singularity/3.11.4

SAMPLESHEET=data/metadata/ampliseq-samplesheet.tsv

OUTDIR=results/$JOB_BASENAME
PARAMS_FILE=src/nf.params.ampliseq.json
CONFIG_FILE=src/nf.config.ampliseq
NF_WORKDIR=temp/nf_work_$JOB_BASENAME

export NXF_SINGULARITY_CACHEDIR=bin/nf_singularity_cache

# launch nf-core/ampliseq pipeline
nextflow run nf-core/ampliseq \
	-r 2.12.0 \
	-name $RUN_NAME \
	-profile singularity \
	-params-file $PARAMS_FILE \
	-c $CONFIG_FILE \
	-work-dir $NF_WORKDIR \
	-resume \
	-ansi-log false \
	--input $SAMPLESHEET \
	--outdir $OUTDIR
