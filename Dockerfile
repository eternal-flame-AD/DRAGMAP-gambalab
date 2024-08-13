# This is used to build the DRAGMAP release docker image.
# it also include bcftools, samtools, tabix and sambamba.
# $ git clone https://github.com/gambalab/DRAGMAP
# $ cd DRAGMAP
# $ sudo docker build -t dragmap .

FROM continuumio/miniconda3 AS conda_setup
RUN conda config --add channels defaults && \
    conda config --add channels bioconda && \
    conda config --add channels conda-forge
RUN conda create -n bio \
                    bioconda::bcftools=1.20 \
                    bioconda::samtools=1.20 \
                    bioconda::tabix=0.2.6 \
                    bioconda::sambamba=1.0.1 \
    && conda clean -a

FROM ubuntu:18.04 AS builder

COPY --from=conda_setup /opt/conda /opt/conda

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        build-essential \
        pkg-config \
        cmake \
        libboost-all-dev \
        libgtest-dev \
        valgrind \
        libpcsclite-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists

# Copying DeepVariant source code
COPY . /opt/dragmap

ENV HAS_GTEST=0
ENV STATIC=1

WORKDIR /opt/dragmap
RUN make -j4

WORKDIR /opt/dragmap/bin
RUN cp /opt/dragmap/build/release/dragen-os .
RUN cp /opt/dragmap/build/release/compare .
RUN chmod +x /opt/dragmap/bin/*

ENV PATH="${PATH}":/opt/conda/bin:/opt/conda/envs/bio/bin:/opt/dragmap/bin

CMD ["/opt/dragmap/bin/dragen-os", "--help"]

