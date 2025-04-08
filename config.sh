# RNA-Seq Analysis Configuration

# Adjust the following variables:

# Adjust the following variables:
EXPERIMENT=AB5_Primeseq_STZ_HFD_Liver_females
PATH_EXPERIMENT=/mnt/run/paulo/${EXPERIMENT}
PATH_STORAGE=/mnt/storage/paulo/${EXPERIMENT}
PATH_RAW_G400_DATA=/mnt/storage/paulo/AB3_STZ_HFD_Liver_Heart_DNB_G400/
FLOWCELL=V350294049
BARCODE=IDTi51i7N701

SPECIES=mouse # supports "mouse", "human", "pig" and "rat"
THREADN=16 # define number of threads to use
GENOME_FOLDER=/mnt/run/shared/genomes/ # Path to where you store genome files


## Check paths to index and annotation files ------------
MOUSE_STAR_INDEX=${GENOME_FOLDER}/mouse/star_index_149 # Path to STAR index
MOUSE_ANNOTATION=${GENOME_FOLDER}/mouse/Mus_musculus.GRCm38.102.chr.gtf # GTF file

HUMAN_STAR_INDEX=${GENOME_FOLDER}/human/star_149 # Path to STAR index
HUMAN_ANNOTATION=${GENOME_FOLDER}/human/Homo_sapiens.GRCh38.102.gtf # GTF file
