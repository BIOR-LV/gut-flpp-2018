#!/bin/bash

source activate qiime2-amplicon-2023.9

PROJDIR=$HOME/seq/gut-flpp-2018
TESTRUN=$PROJDIR/results/test-12/qiime2/rel_abundance_tables
OBSTABLEIN=$TESTRUN/rel-table-6.tsv
OBSTABLEOUT=$TESTRUN/rel-table-6.qza
EVALVIZ=$TESTRUN/evcomp-zr-6.qzv
FILTERDATA=$PROJDIR/data/mock/samples-to-keep-zr.tsv
EXPTABLEIN=$PROJDIR/data/mock/zr-expected-rel-ftab.tsv
EXPTABLEOUT=$PROJDIR/data/mock/zr-expected-rel-ftab.qza

# prepare mock community expected composition table as qiime2 artefact

biom convert \
	-i $EXPTABLEIN \
	-o $TESTRUN/temp-ftab.biom \
	--table-type="OTU table" \
	--to-hdf5

qiime tools import \
	--type FeatureTable[RelativeFrequency] \
	--input-path $TESTRUN/temp-ftab.biom \
	--output-path $EXPTABLEOUT

rm $TESTRUN/temp-ftab.biom

# prepare observed feature table as qiime2 artefact

biom convert \
	-i $OBSTABLEIN \
	-o $TESTRUN/temp-ftab.biom \
	--table-type="OTU table" \
	--to-hdf5

qiime tools import \
	--type FeatureTable[RelativeFrequency] \
	--input-path $TESTRUN/temp-ftab.biom \
	--output-path $TESTRUN/temp-ftab.qza

rm $TESTRUN/temp-ftab.biom

qiime feature-table filter-samples \
	--i-table $TESTRUN/temp-ftab.qza \
	--m-metadata-file $FILTERDATA \
	--o-filtered-table $OBSTABLEOUT

rm $TESTRUN/temp-ftab.qza

# evaluate expected vs. observed composition

qiime quality-control evaluate-composition \
	--i-expected-features $EXPTABLEOUT \
	--i-observed-features $OBSTABLEOUT \
	--p-depth 6 \
	--o-visualization $EVALVIZ
