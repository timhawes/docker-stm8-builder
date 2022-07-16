FROM ubuntu:22.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential flex bison wget ca-certificates texinfo file libboost-dev libz-dev \
    && cd /usr/src \
    && wget https://sourceforge.net/projects/stm8-binutils-gdb/files/stm8-binutils-gdb-sources-2021-07-18.tar.gz/download -O stm8-binutils-gdb-sources-2021-07-18.tar.gz \
    && tar xf stm8-binutils-gdb-sources-2021-07-18.tar.gz \
    && cd stm8-binutils-gdb-sources \
    && ./patch_binutils.sh \
    && ./configure_binutils.sh \
    && cd binutils-2.30 \
    && make -j$(nproc) \
    && make install \
    && cd - \
    && rm -rf stm8-binutils-gdb-sources-2021-07-18.tar.gz stm8-binutils-gdb-sources \
    && wget https://sourceforge.net/projects/gputils/files/gputils/1.5.0/gputils-1.5.2.tar.bz2/download -O gputils-1.5.2.tar.bz2 \
    && tar xf gputils-1.5.2.tar.bz2 \
    && cd gputils-1.5.2 \
    && ./configure \
    && make -j$(nproc) \
    && make install \
    && cd - \
    && rm -rf gputils-1.5.2.tar.bz2 gputils-1.5.2 \
    && wget https://sourceforge.net/projects/sdcc/files/sdcc/4.2.0/sdcc-src-4.2.0.tar.bz2/download -O sdcc-src-4.2.0.tar.bz2 \
    && tar xf sdcc-src-4.2.0.tar.bz2 \
    && cd sdcc-4.2.0 \
    && ./configure \
    && make -j$(nproc) \
    && make install \
    && cd - \
    && rm -rf sdcc-src-4.2.0.tar.bz2 sdcc-4.2.0 \
    && rm -rf /var/lib/apt/lists/*
