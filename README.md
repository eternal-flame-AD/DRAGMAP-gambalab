# Dragmap 

This is a fork prividing Dragmap binary file and docker/singularity image.

Dragmap is the Dragen mapper/aligner Open Source Software.

You can download the binary file in release. It should work on any debian distro, otherwise a straightforward approach is to utilize the pre-built Docker/Singularity image I've created.

## Install with Singularity or Docker
This image also incorporates some useful tools such as **bcftools**, **samtools**, **tabix**, and **sambamba** for added convenience. To install the DragMap Docker/Singularity image, run the following commands:

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

Below is an example of how to use the image with Singularity. The Docker usage is similar, requiring only the appropriate mounting of input files using the -v argument.

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

