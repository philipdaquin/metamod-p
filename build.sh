#!/bin/bash
# Build script para metamod-p
# Compila metamod.so (Linux) e metamod.dll (Windows) com suporte Xash3D

set -e

IMAGE_NAME="metamod-build"
OUTPUT_DIR="$(pwd)/build_output"
BASE_COMMIT="0deea5a888bc44dc68f1ede29c291675cbbff059"

echo "=== Metamod-P Build Script ==="

# Calcular versão
GIT_COUNT=$(git rev-list --count ${BASE_COMMIT}..HEAD 2>/dev/null || echo "0")
VERSION="1.21p37-xash3d-git${GIT_COUNT}"
echo "Version: ${VERSION}"

# Criar diretório de output
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Build da imagem Docker
echo "[1/4] Building Docker image..."
docker build --platform linux/386 -t "$IMAGE_NAME" .

# Extrair binários
echo "[2/4] Extracting binaries..."
docker run --rm -v "$OUTPUT_DIR:/host" "$IMAGE_NAME" sh -c "cp -r /output/* /host/" 2>/dev/null || true

# Criar pacotes
echo "[3/4] Creating packages..."

# Linux (.tar.gz)
rm -f "$OUTPUT_DIR/addons/metamod/dlls/metamod.dll"
tar -czvf "metamod-${VERSION}-linux.tar.gz" -C "$OUTPUT_DIR" addons/

# Windows (.zip)
rm -f "$OUTPUT_DIR/addons/metamod/dlls/metamod.so"
docker run --rm -v "$OUTPUT_DIR:/host" "$IMAGE_NAME" sh -c "cp /output/addons/metamod/dlls/metamod.dll /host/addons/metamod/dlls/" 2>/dev/null || true
cd "$OUTPUT_DIR"
zip -r "../metamod-${VERSION}-windows.zip" addons/
cd ..

# Resultado
echo "[4/4] Build complete!"
echo ""
echo "Packages created:"
ls -la metamod-*.tar.gz metamod-*.zip
echo ""
echo "Structure inside packages:"
echo "  addons/metamod/dlls/metamod.so (Linux)"
echo "  addons/metamod/dlls/metamod.dll (Windows)"
echo "  addons/metamod/plugins.ini (empty)"
