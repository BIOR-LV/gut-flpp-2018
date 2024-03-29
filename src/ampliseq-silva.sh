#!/bin/bash
#PBS -l walltime=192:00:00
#PBS -l nodes=1:ppn=1,pmem=5g
#PBS -q long
#PBS -j oe
#PBS -o logs/$PBS_JOBNAME.$PBS_JOBID.log

source activate nf
module load singularity/3.11.4

cd $PBS_O_WORKDIR #so that all paths are interpreted relative to project root

JOB_BASENAME=$(echo $PBS_JOBNAME | cut -d . -f 1) # dots are not allowed in nf run names
RUN_NAME="$JOB_BASENAME"-retry-00

SAMPLESHEET=data/metadata/ampliseq-samplesheet.tsv

OUTDIR=results/$JOB_BASENAME
PARAMS_FILE=src/nf.params.ampliseq.silva.json
CONFIG_FILE=src/nf.config.ampliseq
NF_WORKDIR=temp/nf_work_$JOB_BASENAME

export NXF_SINGULARITY_CACHEDIR=bin/nf_singularity_cache

# launch nf-core/ampliseq pipeline
nextflow run nf-core/ampliseq \
	-r 2.8.0 \
	-name $RUN_NAME \
	-profile singularity \
	-params-file $PARAMS_FILE \
	-c $CONFIG_FILE \
	-work-dir $NF_WORKDIR \
	-resume \
	-ansi-log false \
	--input $SAMPLESHEET \
	--outdir $OUTDIR
