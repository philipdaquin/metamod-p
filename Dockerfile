FROM ubuntu:22.04

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc-multilib \
        g++-multilib \
        make \
        libc6-dev-i386 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY . /build

RUN make clean && make

RUN ls -la dlls/*.so 2>/dev/null || find . -name "*.so" -type f

CMD ["bash"]