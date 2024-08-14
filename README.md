# Dragmap 

This is a fork prividing Dragmap docker/singularity image.
Dragmap is the Dragen mapper/aligner Open Source Software.

## Install with Singularity or Docker
The simplest solution is to use the docker/singularity image I created. The image also include some additional useful tools like **bcftools**, **samtools**, **tabix** and **sambamba** tools. You can install the dragmap docker image with the following command:

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

Below an example of how to use it with singularity. Docker will be similar you just have to mount the proper voluomes with with unput files using the -v argument. 
```
# Let's define e DRAGMAP_exec variable to excec the several commands 
DRAGMAP_exec="singularity exec --bind /usr/lib/locale/ path/to/dragmap_latest.sif"

# Build hash table of a reference fasta file
${DRAGMAP_exec} dragen-os \
    --build-hash-table true \
    --ht-reference reference.fasta \
    --output-directory /home/data/reference/

# Align paired-end reads
${DRAGMAP_exec} dragen-os \
    --preserve-map-align-order true \
    --num-threads ${cpus} \
    --RGID "${ID}" \
    --RGSM "${sample}" \
    --ref-dir ${ref_genome_dragmap} \
    --fastq-file1 ${fastqR1} --fastq-file2 ${fastqR2} | \
     ${DRAGMAP_exec} samtools view --threads 2 -bh -o ${BAM_OUT}
```
    
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

