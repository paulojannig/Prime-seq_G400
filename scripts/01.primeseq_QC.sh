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
    02.results/zUMIs/ \
    03.figures/ \
    04.supplements/ \
    05.miscellaneous \
    scripts

## the folders below will contain big files and should be moved to /mnt/storage/USER/${EXPERIMENT} after you're done
mkdir -p \
    Data/00.reports/G400_QC \
    Data/00.reports/Untrimmed/FastQC_untrimmed_output \
    Data/00.reports/Trimmed/FastQC_trimmed_output \
    Data/01.RawData/multiple_lanes/${FLOWCELL}_${BARCODE} \
    Data/02.TrimmedData \
    Data/03.zUMI_mapping
    
## Copy template files and scripts
cp ~/github_resources/Prime-seq_G400/templates/primeseq_zUMIs.yaml ~/github_resources/Prime-seq_G400/primeseq_zUMIs_${EXPERIMENT}.yaml
cp ~/github_resources/Prime-seq_G400/templates/Template_Primeseq_barcodes_samples.tsv ~/github_resources/Prime-seq_G400/Primeseq_barcodes_samples.tsv

cp -r ~/github_resources/Prime-seq_G400/scripts/*.Rmd ${PATH_EXPERIMENT}/scripts/
cp -r ~/github_resources/Prime-seq_G400/scripts/*.R ${PATH_EXPERIMENT}/scripts/
cp -r ~/github_resources/Prime-seq_G400/templates/sampleInfo.xlsx ${PATH_EXPERIMENT}/01.metadata/
cp -r ~/github_resources/Prime-seq_G400/miscellaneous/pathways_names_replacements.txt ${PATH_EXPERIMENT}/05.miscellaneous/

## Copy Sequencing files
echo " ==================== Copying G400 Fastq files and reports ==================== " `date`
cp ${PATH_RAW_DATA}/${FLOWCELL}/L0*/*${BARCODE}*.fq.gz ${PATH_EXPERIMENT}/Data/01.RawData/multiple_lanes/${FLOWCELL}_${BARCODE}
cp ${PATH_RAW_DATA}/${FLOWCELL}/L0*/*${BARCODE}*.fq.fqStat.txt ${PATH_EXPERIMENT}/Data/00.reports/G400_QC
cp ${PATH_RAW_DATA}/${FLOWCELL}/L0*/*${BARCODE}*.report.html ${PATH_EXPERIMENT}/Data/00.reports/G400_QC
printf "\n"

## Merge multiple lanes
echo " ==================== Merging Fastq files from multiple lanes ==================== " `date`
python ~/github_resources/Prime-seq_G400/scripts/merge_fqs.py -n 10 -i ${PATH_EXPERIMENT}/Data/01.RawData/multiple_lanes/ -o ${PATH_EXPERIMENT}/Data/01.RawData/merged/
printf "\n"

## QC on merged fastq files
echo " ==================== Quality control of merged Fastq files ==================== " `date`
fastqc ${PATH_EXPERIMENT}/Data/01.RawData/merged/${FLOWCELL}_${BARCODE}/*.fq.gz -o ${PATH_EXPERIMENT}/Data/00.reports/Untrimmed/FastQC_untrimmed_output
multiqc --force ${PATH_EXPERIMENT}/Data/00.reports/Untrimmed/FastQC_untrimmed_output --outdir ${PATH_EXPERIMENT}/Data/00.reports/Untrimmed/MultiQC_untrimmed_output

# Trimming the Primeseq .fastq
echo " ==================== Trimming Fastq files ==================== " `date`
python ~/github_resources/Prime-seq_G400/scripts/trim_r1A_r2i.py -n 10 -i ${PATH_EXPERIMENT}/Data/01.RawData/merged/${FLOWCELL}_${BARCODE} -t ${PATH_EXPERIMENT}/Data/02.TrimmedData/

# Quality control of cutadapt trimmed .fastq
echo " ==================== Quality control of cutadapt trimmed Fastq files ==================== " `date`
fastqc ${PATH_EXPERIMENT}/Data/02.TrimmedData/${FLOWCELL}_${BARCODE}/*fastq.gz -o ${PATH_EXPERIMENT}/Data/00.reports/Trimmed/FastQC_trimmed_output
multiqc --force ${PATH_EXPERIMENT}/Data/00.reports/Trimmed/FastQC_trimmed_output --outdir ${PATH_EXPERIMENT}/Data/00.reports/Trimmed/MultiQC_trimmed_output

echo " ==================== Organizing files ==================== " `date`
# move log
mv ~/github_resources/Prime-seq_G400/log.01.primeseq_QC.txt ${PATH_EXPERIMENT}/00.reports/
# backup config.sh file
cp ~/github_resources/Prime-seq_G400/config.sh ${PATH_EXPERIMENT}/scripts/

echo " ========================================================================================== "
printf "\n"
echo "Done!" `date`