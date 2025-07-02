#!/bin/bash

###########################################################################################
# Author: Paulo Jannig | https://github.com/paulojannig
###########################################################################################
source config.sh

###########################################################################################
#
# Script starts here
#
# Start logging ------------
echo " ========================================================================================== "
echo "Date: "`date`
echo "Experiment: ${EXPERIMENT}" - Prime-seq zUMIs
echo "========================================================================================== "
printf "\n"

# zUMIs mapping
~/github_resources/zUMIs/zUMIs.sh -c -y ~/github_resources/Prime-seq_G400/primeseq_zUMIs_$EXPERIMENT.yaml

echo " ==================== Organizing files ==================== " `date`
# Copy main zUMIs reports and results
cp -r ${PATH_EXPERIMENT}/Data/03.zUMI_mapping/zUMIs_output/stats/* ${PATH_EXPERIMENT}/00.reports/zUMIs/
cp -r ${PATH_EXPERIMENT}/Data/03.zUMI_mapping/zUMIs_output/*kept_barcodes_binned.txt ${PATH_EXPERIMENT}/00.reports/zUMIs/
cp -r ${PATH_EXPERIMENT}/Data/03.zUMI_mapping/zUMIs_output/expression/*.dgecounts.rds ${PATH_EXPERIMENT}/02.results/zUMIs/
cp -r ${PATH_EXPERIMENT}/Data/03.zUMI_mapping/zUMIs_output/expression/*.gene_names.txt ${PATH_EXPERIMENT}/02.results/zUMIs/

cp ~/github_resources/Prime-seq_G400/Primeseq_barcodes_samples.tsv ${PATH_EXPERIMENT}/01.metadata

# Copy log
cp ~/github_resources/Prime-seq_G400/log.02.primeseq_zUMIs.txt ${PATH_EXPERIMENT}/00.reports/

# move yaml file
cp ~/github_resources/Prime-seq_G400/primeseq_zUMIs_$EXPERIMENT.yaml ${PATH_EXPERIMENT}/scripts/
mv ~/github_resources/Prime-seq_G400/primeseq_zUMIs_$EXPERIMENT.run.yaml ${PATH_EXPERIMENT}/scripts/

echo " ========================================================================================== "
printf "\n"
echo "Done!" `date`