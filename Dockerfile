# This is used to build the DRAGMAP release docker image.
# it also include bcftools, samtools, tabix, sambamba and bbmap.
# $ git clone https://github.com/gambalab/DRAGMAP
# $ cd DRAGMAP
# $ sudo docker build -t dragmap .

FROM continuumio/miniconda3 AS conda_setup
RUN conda config --add channels defaults && \
    conda config --add channels bioconda && \
    conda config --add channels conda-forge
RUN conda create -y -n bio \
                    bioconda::bcftools=1.20 \
                    bioconda::samtools=1.20 \
                    bioconda::tabix=0.2.6 \
                    bioconda::sambamba=1.0.1 \
                    bioconda::bedtools=2.31.1 \
		    bioconda::bbmap=39.06 \
                    && conda clean -a

FROM ubuntu:24.04 AS builder

COPY --from=conda_setup /opt/conda /opt/conda

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libboost-all-dev \
        libgtest-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists

# Copying DeepVariant source code
COPY . /opt/dragmap_src

ENV HAS_GTEST=0
ENV STATIC=1

WORKDIR /opt/dragmap_src
RUN make -j4

WORKDIR /opt/dragmap/bin
RUN cp /opt/dragmap_src/build/release/dragen-os .
RUN cp /opt/dragmap_src/build/release/compare .
RUN cp /opt/dragmap_src/scripts/run_aln.sh .
RUN wget https://github.com/brentp/mosdepth/releases/download/v0.3.8/mosdepth_d4
RUN chmod +x /opt/dragmap/bin/*
RUN rm -rf /opt/dragmap_src/

ENV PATH="${PATH}":/opt/conda/bin:/opt/conda/envs/bio/bin:/opt/dragmap/bin

LABEL maintainer="https://github.com/gambalab/DRAGMAP/issues"

CMD ["/opt/dragmap/bin/dragen-os", "--help"]
