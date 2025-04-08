#!/bin/bash

###########################################################################################
# Author: Paulo Jannig | https://github.com/paulojannig
#   mkdir ~/github_resources/
#   cd ~/github_resources/
#   git clone https://github.com/paulojannig/Prime-seq_preprocessing.git
#
# DESCRIPTION:
#   Copy G400 fastq files, merge multiple lanes and run QC for Prime-seq data
#
# USAGE:
# 1. Go to ~/github_resources/Prime-seq_G400/
# 2. Run using:
#       nohup ./01_primeseq_QC.sh >> log.01_primeseq_QC.txt
#
# REQUIREMENTS:
# - the following repositories:
#   ~/github_resources/zUMIs/
#
# Prepare environment:
#   git clone https://github.com/brainfo/GeneralUtils.git
#   git clone https://github.com/brainfo/omics_utils.git
#   git clone https://github.com/sdparekh/zUMIs.git
#
###########################################################################################
source config.sh

###########################################################################################
#
# Script starts here
#
# Start logging ------------
echo " ========================================================================================== "
echo "Date: "`date`
echo "Experiment: ${EXPERIMENT}" - Prime-seq QC
echo "========================================================================================== "
printf "\n"

## Create dependencies
mkdir -p ${PATH_EXPERIMENT}
cd ${PATH_EXPERIMENT}

# Prep environment for Prime-seq analysis
## the folders below can be moved out of the server, since files are not that big
mkdir -p \
    00.reports/zUMIs/ \
    01.metadata/ \
    02.results/deseq2/ \
    03.figures/ \
    04.supplements/ \
    05.miscellaneous/

cp ~/github_resources/Prime-seq_G400/templates/primeseq_zUMIs.yaml ~/${EXPERIMENT}/
cp -r ~/github_resources/Prime-seq_G400/scripts ${PATH_EXPERIMENT}
cp -r ~/github_resources/Prime-seq_G400/templates/sampleInfo.xlsx ${PATH_EXPERIMENT}/01.metadata/
cp -r ~/github_resources/Prime-seq_G400/miscellaneous/pathways_names_replacements.txt ${PATH_EXPERIMENT}/05.miscellaneous/

mkdir ${PATH_STORAGE}
mkdir -p \
    ${PATH_STORAGE}/Data/00.reports/G400_QC \
    ${PATH_STORAGE}/Data/00.reports/Untrimmed/FastQC_untrimmed_output \
    ${PATH_STORAGE}/Data/01.RawData/multiple_lanes/${FLOWCELL}_${BARCODE} \
    ${PATH_STORAGE}/Data/02.TrimmedData \
    ${PATH_STORAGE}/Data/00.reports/Trimmed/FastQC_trimmed_output

## Copy files
echo " ==================== Copying G400 Fastq files and reports ==================== " `date`
cp ${PATH_RAW_G400_DATA}/${FLOWCELL}/L0*/*${BARCODE}*.fq.gz ${PATH_STORAGE}/Data/01.RawData/multiple_lanes/${FLOWCELL}_${BARCODE}
cp ${PATH_RAW_G400_DATA}/${FLOWCELL}/L0*/*${BARCODE}*.fq.fqStat.txt ${PATH_STORAGE}/Data/00.reports/G400_QC
cp ${PATH_RAW_G400_DATA}/${FLOWCELL}/L0*/*${BARCODE}*.report.html ${PATH_STORAGE}/Data/00.reports/G400_QC
printf "\n"

## Merge multiple lanes
echo " ==================== Merging Fastq files from multiple lanes ==================== " `date`
python ~/github_resources/Prime-seq_G400/scripts/merge_fqs.py -n 10 -i ${PATH_STORAGE}/Data/01.RawData/multiple_lanes/ -o ${PATH_STORAGE}/Data/01.RawData/merged/
printf "\n"

## QC on merged fastq files
echo " ==================== Quality control of merged Fastq files ==================== " `date`
fastqc ${PATH_STORAGE}/Data/01.RawData/merged/${FLOWCELL}_${BARCODE}/*fq.gz -o ${PATH_STORAGE}/Data/00.reports/Untrimmed/FastQC_untrimmed_output
multiqc --force ${PATH_STORAGE}/Data/00.reports/Untrimmed/FastQC_untrimmed_output --outdir ${PATH_STORAGE}/Data/00.reports/Untrimmed/MultiQC_untrimmed_output

# Trimming the Primeseq .fastq
echo " ==================== Trimming Fastq files ==================== " `date`
python ~/github_resources/Prime-seq_G400/scripts/trim_r1A_r2i.py -n 16 -i ${PATH_STORAGE}/Data/01.RawData/merged/${FLOWCELL}_${BARCODE} -t ${PATH_STORAGE}/Data/02.TrimmedData/

# Quality control of cutadapt trimmed .fastq
echo " ==================== Quality control of cutadapt trimmed Fastq files ==================== " `date`
fastqc ${PATH_STORAGE}/Data/02.TrimmedData/${FLOWCELL}_${BARCODE}/*fastq.gz -o ${PATH_STORAGE}/Data/00.reports/Trimmed/FastQC_trimmed_output
multiqc --force ${PATH_STORAGE}/Data/00.reports/Trimmed/FastQC_trimmed_output --outdir ${PATH_STORAGE}/Data/00.reports/Trimmed/MultiQC_trimmed_output

ln -s ${PATH_STORAGE}/Data ${PATH_EXPERIMENT}/
cp -r ${PATH_STORAGE}/Data/00.reports/* ${PATH_EXPERIMENT}/00.reports/

# Backup log
mv ~/github_resources/Prime-seq_G400/log.primeseq_script1.txt ${PATH_EXPERIMENT}/00.reports/
cp ${PATH_EXPERIMENT}/00.reports/log.primeseq_script1.txt ${PATH_STORAGE}

# Backup script
cp ~/github_resources/Prime-seq_G400/primeseq_script2.sh ${PATH_EXPERIMENT}/scripts/
cp ~/github_resources/Prime-seq_G400/primeseq_script2.sh ${PATH_STORAGE}/

echo " ========================================================================================== "
printf "\n"
echo "Done!" `date`