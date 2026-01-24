# Dockerfile para compilar metamod-p
# Gera metamod.so (Linux) e metamod.dll (Windows)

FROM debian:bullseye

# Instalar dependências de compilação
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
        build-essential \
        gcc-multilib \
        g++-multilib \
        mingw-w64 \
        make \
        && rm -rf /var/lib/apt/lists/*

# Diretório de trabalho
WORKDIR /build

# Copiar código fonte
COPY . /build/

# Limpar builds anteriores e compilar
RUN cd /build/metamod && \
    make cleanall || true && \
    make XASH3D=1 linux_opt && \
    make XASH3D=1 OS=windows win32_opt

# Strip debug symbols e copiar para output
RUN mkdir -p /output && \
    strip --strip-all /build/dlls/metamod.so -o /output/metamod.so && \
    strip --strip-all /build/dlls/metamod.dll -o /output/metamod.dll

# Output final em /output
CMD ["ls", "-la", "/output/"]
