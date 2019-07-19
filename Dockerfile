FROM ubuntu:xenial
MAINTAINER Alexander Paul <alex.paul@wustl.edu>

LABEL \
  version="0.4" \
  description="CNVnator image to be used in cwl workflows"

RUN apt-get update && apt-get install -y \
  binutils \
  dpkg-dev \
  gcc \
  git \
  g++ \
  libbz2-dev \
  libcurl3-dev \
  libncurses5-dev \
  libxext-dev \
  libxft-dev \
  libxpm-dev \
  libx11-dev \
  liblzma-dev \
  make \
  perl \
  python \
  python-dev \
  wget

WORKDIR /tmp
RUN wget https://github.com/Kitware/CMake/releases/download/v3.15.0/cmake-3.15.0.tar.gz \
  && tar -zxvf cmake-3.15.0.tar.gz \
  && rm cmake-3.15.0.tar.gz

ENV CMAKE_INSTALL_DIR=/opt/cmake
RUN cd cmake-3.15.0 \
  && ./bootstrap \
  && ./configure --prefix=$CMAKE_INSTALL_DIR \
  && make -j4 \
  && make install \
  && cd .. \
  && rm -rf cmake-3.15.0

ENV PATH=/opt/cmake/bin:${PATH}

RUN wget https://root.cern/download/root_v6.18.00.source.tar.gz \
  && tar -zxvf root_v6.18.00.source.tar.gz \
  && rm root_v6.18.00.source.tar.gz

ENV ROOT_INSTALL_DIR=/opt/root
RUN mkdir build $ROOT_INSTALL_DIR \
  && cmake -S root-6.18.00 -B $ROOT_INSTALL_DIR \
  && cmake --build $ROOT_INSTALL_DIR \
  && rm -rf /tmp/root-6.18.00/

RUN echo 'source $ROOT_INSTALL_DIR/bin/thisroot.sh' >> ~/.bashrc
ENV ROOTSYS=$ROOT_INSTALL_DIR/
ENV PATH=$PATH:$ROOTSYS/bin

## add samtools
RUN cd /opt \
  && wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2 \
  && tar --bzip2 -xf samtools-1.9.tar.bz2 \
  && rm samtools-1.9.tar.bz2 \
  && cd samtools-1.9 \
  && make \
  && make install

ENV CNVNATOR_VERSION=0.4
RUN cd /opt \
  && wget https://github.com/abyzovlab/CNVnator/archive/v$CNVNATOR_VERSION.tar.gz \
  && tar -zxf v$CNVNATOR_VERSION.tar.gz \
  && rm v$CNVNATOR_VERSION.tar.gz \
  && cd CNVnator-$CNVNATOR_VERSION \
  && ln -s /opt/samtools-1.9 samtools \
  && make

RUN ln -s /opt/CNVnator-${CNVNATOR_VERSION}/cnvnator /usr/bin \
  && ln -s /opt/CNVnator-${CNVNATOR_VERSION}/cnvnator2VCF.pl /usr/bin

WORKDIR /
