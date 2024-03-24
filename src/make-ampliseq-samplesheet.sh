#!/bin/bash

# this script makes a samplesheet to be used as input for nf-core/ampliseq
# this script should work as long as the input metadata file has these columns:
# - run_accession
# - sampleID
# - run

INPUT=data/metadata/metadata_w_accesions.tsv
OUTPUT=data/metadata/ampliseq-samplesheet.tsv

awk -F'\t' '
    NR==1{
        for(i=1;i<=NF;i++){
            header[$i]=i;
        }
    }
    {
        print $header["run_accession"] "\t" $header["sampleID"] "\t" $header["run"];
    }
' $INPUT | awk -F'\t' '$1 != "NA" {print}' > temp/part1_samplesheet.tsv

echo "forwardReads" > temp/freads.tsv
echo "reverseReads" > temp/rreads.tsv

tail -n +2 temp/part1_samplesheet.tsv | while read run_accession other_columns
do
	find data/raw -type f -name "*${run_accession}_1.fastq.gz" -printf "%p\n" >> temp/freads.tsv
	find data/raw -type f -name "*${run_accession}_2.fastq.gz" -printf "%p\n" >> temp/rreads.tsv
done

paste temp/part1_samplesheet.tsv temp/freads.tsv temp/rreads.tsv | cut -f 2-5 > $OUTPUT

rm temp/part1_samplesheet.tsv temp/freads.tsv temp/rreads.tsv
