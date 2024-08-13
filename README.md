# Dragmap 

Dragmap is the Dragen mapper/aligner Open Source Software.

## Installation

The simplest solution is to download the precompailed static version, it should be compatible with any debian OS based. For other OS I have never tested it.

## Install with Singularity or Docker
Another simple solution is to use the docker/singularity image I created. The image also include bcftools, samtools, tabix and sambamba tools. You can install the dragmap docker image with the following command:

```
# 1. Install with Singularity and test it
singularity pull docker://gambalab/dragmap

singularity exec --bind /usr/lib/locale/ \
    /path/to/dragmap_latest.sif \
    dragen-os --help

# 2. Install with Docker and test it
docker pull docker://gambalab/dragmap

docker run -u $(id -u):$(id -g) \
    gambalab/dragmap dragen-os --help
```
If you are used to docker the usage should be simple:
    
### Build from source

#### Install


The basic procedure is

    export HAS_GTEST=0
    export STATIC=1
    make -j 4

Binary will be generated in ./build/release/

Then optionally, to install to /usr/bin/

    make install


## Basic command line usage 

### Command line options 

    dragen-os --help


### Build hash table of a reference fasta file 

    dragen-os --build-hash-table true --ht-reference reference.fasta  --output-directory /home/data/reference/

### Build hash table using an alt-masked bed file

    dragen-os --build-hash-table true --ht-reference hg38.fa  --output-directory /home/data/reference/ --output-file-prefix=dragmap.hg38_alt_masked --ht-mask-bed=fasta_mask/hg38_alt_mask.bed

### Align paired-end reads :

Output result to standard output 

    dragen-os -r /home/data/reference/ -1 reads_1.fastq.gz -2 reads_2.fastq.gz >  result.sam

Or directly to a file :

    dragen-os -r /home/data/reference/ -1 reads_1.fastq.gz -2 reads_2.fastq.gz --output-directory /home/data/  --output-file-prefix result

### Align single-end reads :

    dragen-os -r /home/data/reference/ -1 reads_1.fastq.gz  >  result.sam

