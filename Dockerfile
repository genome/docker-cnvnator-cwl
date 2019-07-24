FROM ubuntu:xenial
MAINTAINER Alexander Paul <alex.paul@wustl.edu>

LABEL \
  version="0.4" \
  description="CNVnator image to be used in cwl workflows"

RUN apt-get update && apt-get install -y \
  dpkg-dev \
  gcc \
  git \
  g++ \
  libbz2-dev \
  libcurl3-dev \
  libncurses5-dev \
  liblzma-dev \
  libxft-dev \
  make \
  perl \
  python \
  python-dev \
  wget \
  zlib1g-dev

WORKDIR /opt

## add ROOT analysis framework
RUN wget https://root.cern/download/root_v6.18.00.Linux-ubuntu16-x86_64-gcc5.4.tar.gz \
  && tar -zxf root_v6.18.00.Linux-ubuntu16-x86_64-gcc5.4.tar.gz \
  && rm root_v6.18.00.Linux-ubuntu16-x86_64-gcc5.4.tar.gz

ENV ROOTSYS=/opt/root
ENV PATH=$PATH:$ROOTSYS/bin
RUN echo 'source $ROOTSYS/bin/thisroot.sh' >> ~/.bashrc

## add samtools
RUN wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2 \
  && tar -jxf samtools-1.9.tar.bz2 \
  && rm samtools-1.9.tar.bz2 \
  && cd samtools-1.9 \
  && make \
  && make install

ENV CNVNATOR_VERSION=0.4
RUN /bin/bash -c "source $ROOTSYS/bin/thisroot.sh \
  && wget https://github.com/abyzovlab/CNVnator/archive/v$CNVNATOR_VERSION.tar.gz \
  && tar -zxf v$CNVNATOR_VERSION.tar.gz \
  && rm v$CNVNATOR_VERSION.tar.gz \
  && cd CNVnator-$CNVNATOR_VERSION \
  && ln -s /opt/samtools-1.9 samtools \
  && make"

RUN ln -s /opt/CNVnator-$CNVNATOR_VERSION/cnvnator /usr/bin \
  && ln -s /opt/CNVnator-$CNVNATOR_VERSION/cnvnator2VCF.pl /usr/bin

WORKDIR /
