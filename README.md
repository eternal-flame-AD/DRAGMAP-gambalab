# Dragmap 

This is a fork prividing Dragmap binary file and docker/singularity image.

Dragmap is the Dragen mapper/aligner Open Source Software.

You can download the binary file in release, tt should work on any debian based distro. Otherwise a straightforward approach is to utilize the pre-built Docker/Singularity image I've created.

## Install with Singularity or Docker
This image also incorporates some useful tools such as **bcftools**, **samtools**, **tabix**, **sambamba**, **bedtools**, **mosdepth** and **bbmap** for added convenience. To install the DragMap Docker/Singularity image, run the following commands:

```bash
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

```bash
# Let's define e DRAGMAP_exec variable to excec the several commands 
DRAGMAP_exec="singularity exec --bind /usr/lib/locale/ path/to/dragmap_latest.sif"

# Build hash table of a reference fasta file
${DRAGMAP_exec} dragen-os \
    --build-hash-table true \
    --ht-reference reference.fasta \
    --output-directory ${ref_genome_dragmap}

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

### ALN PIPELINE
In the docker/singularity image there is also a one click pipeline we built. It starts from fastQ files and can evantually trim it before to alignment. It also removes dup reads using samtools markdup.

```bash
# Let's define e DRAGMAP_exec variable to excec the several commands 
DRAGMAP_exec="singularity exec --bind /usr/lib/locale/ path/to/dragmap_latest.sif"

# Let's see the help
${DRAGMAP_exec} run_aln.sh -h
```
```
This pipeline employs DragMap for efficient read alignment, incorporating optional preprocessing and post-processing steps.

Key Steps:

  1. Optional Trimming: If enabled, reads are initially trimmed using the BBduk tool to remove low-quality bases and adaptors.
  2. Alignment: The trimmed or original reads are aligned to the reference genome using DragMap.
  3. Duplicate Marking and Removal: Samtools markdup is utilized to identify and remove potential PCR duplicates from the aligned reads.
  4. Output Organization: Results are organized into three distinct folders:
	 4.1 aln: Contains the final aligned BAM file.
	 4.2 fastq: Stores the trimmed FASTQ files if trimming was performed.
	 4.3 stat: Provides statistical information about trimming (if applicable) and alignment coverage.

This streamlined workflow ensures accurate and efficient read alignment, while the organized output facilitates downstream analysis.

Syntax: run_dragen.sh [h|s|1|2|o|r|c|t]
options:
-h     Print this Help.
-c     Number of cpus to use.
-o     Output directory.
-s     Sample name.
-1     Path to the read1 FASTQ
-2     Path to the read2 FASTQ
-r     Path to the Dragmap reference folder.
-t     Trimming. Default false.
-b     BED file with regions will be used to compute coverage. Otherwise coverage stats are computed whole genome.
```
So a typical case of use will be something like this:
```bash
${DRAGMAP_exec} \
    run_aln.sh \
   -c 24 \
   -o /path/to/output_folder \
   -s ${SAMPLE} \
   -1 /path/to/fastQ_R1 \
   -2 /path/to/fastQ_R2 \
   -r /path/to/dragmap_idx_folder \
   -t "true"
```
At the end of alignmet output files are stored under /path/to/output_folder/${SAMPLE}

### Build from source a standalone dragen-os file

#### Install


The basic procedure is

    export HAS_GTEST=0
    export STATIC=1
    make -j 4

Binary will be generated in ./build/release/

Then optionally, to install to /usr/bin/

    make install
