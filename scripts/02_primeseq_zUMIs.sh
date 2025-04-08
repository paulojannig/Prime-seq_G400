#!/bin/bash

###########################################################################################
# Author: Paulo Jannig | https://github.com/paulojannig
#   mkdir ~/github_resources/
#   cd ~/github_resources/
#   git clone https://github.com/paulojannig/Prime-seq_preprocessing.git
#
# DESCRIPTION:
#   Run zUMIs on Prime-seq data
#
# USAGE:
# 1. Make sure you run primeseq_script1.sh before, and that QC looks fine
# 2. Edit the yaml before running this script (primeseq_zUMIs.yaml)
# 3. Go to ~/github_resources/Prime-seq_preprocessing/
# 4. Run using:
#       nohup ./primeseq_script2.sh >> log.primeseq_script2.txt
#
# REQUIREMENTS:
# - the following repositories:
#   ~/github_resources/GeneralUtils/
#   ~/github_resources/omics_utils/
#   ~/github_resources/zUMIs/
#
# Prepare environment:
#   git clone https://github.com/brainfo/GeneralUtils.git
#   git clone https://github.com/brainfo/omics_utils.git
#   git clone https://github.com/sdparekh/zUMIs.git
#
###########################################################################################

# Adjust the following variables:
EXPERIMENT=54_DPJ54_Adipose_16wk_G400
PATH_EXPERIMENT=/mnt/data/paulo/${EXPERIMENT}
PATH_STORAGE=/mnt/storage/paulo/${EXPERIMENT}
PATH_RAW_G400_DATA=/mnt/storage/paulo/DPJ45_PrimeSeq_G400/
FLOWCELL=V350294081
BARCODE=IDTi52i7N702

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

## Create dependencies
mkdir -p \
    ${PATH_EXPERIMENT}/03.zUMI_mapping \
    ${PATH_EXPERIMENT}/02.results/zUMIs

# zUMIs mapping
~/github_resources/zUMIs/zUMIs.sh -c -y ${PATH_EXPERIMENT}/primeseq_zUMIs.yaml

echo " ==================== Copying files and transferring to storage ==================== " `date`
# Copy main zUMIs reports and results
cp -r ${PATH_EXPERIMENT}/03.zUMI_mapping/zUMIs_output/stats/* ${PATH_EXPERIMENT}/00.reports/zUMIs/
cp -r ${PATH_EXPERIMENT}/03.zUMI_mapping/zUMIs_output/expression/*.dgecounts.rds ${PATH_EXPERIMENT}/02.results/zUMIs
cp -r ${PATH_EXPERIMENT}/03.zUMI_mapping/zUMIs_output/expression/*.gene_names.txt ${PATH_EXPERIMENT}/02.results/zUMIs

## organize files
cp -r ${PATH_EXPERIMENT}/03.zUMI_mapping/ ${PATH_STORAGE}/Data/
rm -r ${PATH_EXPERIMENT}/03.zUMI_mapping/

# Backup log
mv ~/github_resources/Prime-seq_preprocessing/log.primeseq_script2.txt ${PATH_EXPERIMENT}/00.reports/
cp ${PATH_EXPERIMENT}/00.reports/log.primeseq_script2.txt ${PATH_STORAGE}

# Backup script
cp ~/github_resources/Prime-seq_preprocessing/primeseq_script2.sh ${PATH_EXPERIMENT}/scripts/
cp ~/github_resources/Prime-seq_preprocessing/primeseq_script2.sh ${PATH_STORAGE}/

echo " ========================================================================================== "
printf "\n"
echo "Done!" `date`