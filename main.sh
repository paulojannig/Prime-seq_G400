#!/bin/bash

###########################################################################################
# Author: Paulo Jannig | https://github.com/paulojannig
#     
# DESCRIPTION:
#   - Download genome files
#   - build STAR index
#   - Quality control: FastQC and TrimGalore!
#   - Genome alignment: STAR
#   - Gene level counts: featureCounts
#
#   Run this script using the command: ./main.sh
#
# More details: README.md 
#
source config.sh
nohup ./01_primeseq_QC.sh >> log.01_primeseq_QC.txt


