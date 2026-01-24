#!/bin/bash
# Build script para metamod-p
# Compila metamod.so (Linux) e metamod.dll (Windows) com suporte Xash3D

set -e

IMAGE_NAME="metamod-build"
OUTPUT_DIR="$(pwd)/build_output"

echo "=== Metamod-P Build Script ==="

# Criar diretório de output
mkdir -p "$OUTPUT_DIR"

# Build da imagem Docker
echo "[1/3] Building Docker image..."
docker build --platform linux/386 -t "$IMAGE_NAME" .

# Extrair binários
echo "[2/3] Extracting binaries..."
docker run --rm -v "$OUTPUT_DIR:/host" "$IMAGE_NAME" sh -c "cp /output/* /host/" 2>/dev/null || true

# Resultado
echo "[3/3] Build complete!"
echo ""
echo "Output files:"
ls -la "$OUTPUT_DIR"
echo ""
echo "Binaries saved to: $OUTPUT_DIR"
