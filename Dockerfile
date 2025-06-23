FROM debian:12 AS build

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential flex bison wget ca-certificates texinfo file libboost-dev libz-dev git pkg-config libusb-1.0-0-dev

RUN cd /usr/src \
    && wget https://sourceforge.net/projects/stm8-binutils-gdb/files/stm8-binutils-gdb-sources-2021-07-18.tar.gz/download -O stm8-binutils-gdb-sources-2021-07-18.tar.gz \
    && wget https://ftp.gnu.org/gnu/binutils/binutils-2.30.tar.xz \
    && wget https://ftp.gnu.org/gnu/gdb/gdb-8.1.tar.xz \
    && wget https://sourceforge.net/projects/gputils/files/gputils/1.5.0/gputils-1.5.2.tar.bz2/download -O gputils-1.5.2.tar.bz2 \
    && wget https://sourceforge.net/projects/sdcc/files/sdcc/4.4.0/sdcc-src-4.4.0.tar.bz2/download -O sdcc-src-4.4.0.tar.bz2 \
    && git clone https://github.com/vdudouyt/stm8flash.git \
    && cd stm8flash \
    && git checkout 0d84fad229a23813fcf3ef69ba2693f1a53c55fd

# COPY gputils-1.5.2.tar.bz2 stm8-binutils-gdb-sources-2021-07-18.tar.gz binutils-2.30.tar.xz gdb-8.1.tar.xz sdcc-src-4.4.0.tar.bz2 /usr/src/

RUN cd /usr/src && sha256sum -c - <<EOF
6e46b8aeae2f727a36f0bd9505e405768a72218f1796f0d09757d45209871ae6  binutils-2.30.tar.xz
af61a0263858e69c5dce51eab26662ff3d2ad9aa68da9583e8143b5426be4b34  gdb-8.1.tar.xz
8fb8820b31d7c1f7c776141ccb3c4f06f40af915da6374128d752d1eee3addf2  gputils-1.5.2.tar.bz2
ae8c12165eb17680dff44b328d8879996306b7241efa3a83b2e3b2d2f7906a75  sdcc-src-4.4.0.tar.bz2
8ef9a699deb18ec0f2d457b1e476b1afd751446e3344bc54a969b7d6393c907a  stm8-binutils-gdb-sources-2021-07-18.tar.gz
EOF

RUN cd /usr/src/stm8flash \
    && make -j$(nproc) \
    && make install \
    && make clean \
    && cd /tmp \
    && tar xf /usr/src/stm8-binutils-gdb-sources-2021-07-18.tar.gz \
    && cd stm8-binutils-gdb-sources \
    && mkdir -p binutils-2.30 \
    && tar xf /usr/src/gdb-8.1.tar.xz --strip-components=1 --directory=binutils-2.30 \
    && tar xf /usr/src/binutils-2.30.tar.xz \
    && for f in ./binutils_patches/*.patch; do patch -N -p 1 -d binutils-2.30 <$f; done \
    && ./configure_binutils.sh \
    && cd binutils-2.30 \
    && make -j$(nproc) \
    && make install \
    && cd ../.. \
    && rm -rf stm8-binutils-gdb-sources \
    && tar xf /usr/src/gputils-1.5.2.tar.bz2 \
    && cd gputils-1.5.2 \
    && ./configure \
    && make -j$(nproc) \
    && make install \
    && cd - \
    && rm -rf gputils-1.5.2 \
    && tar xf /usr/src/sdcc-src-4.4.0.tar.bz2 \
    && cd sdcc-4.4.0 \
    && ./configure \
    && make -j$(nproc) \
    && make install \
    && cd - \
    && rm -rf sdcc-4.4.0

FROM debian:12-slim
COPY --from=build /usr/local /usr/local
RUN apt-get update \
    && apt-get install -y --no-install-recommends binutils libusb-1.0-0 make \
    && rm -rf /var/lib/apt/lists/*
