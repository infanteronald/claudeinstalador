#!/bin/bash
set -euo pipefail

# ─────────────────────────────────────────────────────
# build-app.sh
# Compiles ClaudeInstaller and packages it as a .app bundle
# Usage: ./Scripts/build-app.sh
# Output: dist/Claude Code Installer.app
# ─────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_NAME="Claude Code Installer"
BUNDLE_ID="com.claudeinstaller.app"
VERSION="1.0.0"
DIST_DIR="$PROJECT_DIR/dist"
APP_DIR="$DIST_DIR/$APP_NAME.app"

cd "$PROJECT_DIR"

echo "╔══════════════════════════════════════════════╗"
echo "║   Claude Code Installer — Build Script       ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Step 1: Build release binary
echo "▸ Compilando en modo release..."
swift build -c release 2>&1 | tail -3

BINARY_PATH=".build/release/ClaudeInstaller"
if [ ! -f "$BINARY_PATH" ]; then
    echo "✗ Error: No se encontró el binario en $BINARY_PATH"
    exit 1
fi
echo "✓ Binario compilado"

# Step 2: Create .app bundle structure
echo "▸ Creando bundle $APP_NAME.app..."
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# Step 3: Copy binary
cp "$BINARY_PATH" "$APP_DIR/Contents/MacOS/ClaudeInstaller"
echo "✓ Binario copiado"

# Step 4: Copy Info.plist
cp "$PROJECT_DIR/Info.plist" "$APP_DIR/Contents/Info.plist"
echo "✓ Info.plist copiado"

# Step 5: Copy icon
if [ -f "$PROJECT_DIR/AppIcon.icns" ]; then
    cp "$PROJECT_DIR/AppIcon.icns" "$APP_DIR/Contents/Resources/AppIcon.icns"
    echo "✓ Ícono copiado"
else
    echo "⚠ No se encontró AppIcon.icns — generando..."
    swift "$SCRIPT_DIR/generate-icon.swift" "$APP_DIR/Contents/Resources/AppIcon.icns"
    echo "✓ Ícono generado"
fi

# Step 6: Copy resources
for res in DefaultClaudeMD.json DefaultGitignore.txt DefaultClaudeignore.txt; do
    SRC="$PROJECT_DIR/Sources/ClaudeInstaller/Resources/$res"
    if [ -f "$SRC" ]; then
        cp "$SRC" "$APP_DIR/Contents/Resources/"
    fi
done
echo "✓ Recursos copiados"

# Step 7: Create PkgInfo
echo "APPL????" > "$APP_DIR/Contents/PkgInfo"

# Step 8: Verify
echo ""
echo "═══════════════════════════════════════════════"
echo "✓ Build completado!"
echo ""
echo "  App:     $APP_DIR"
echo "  Tamaño:  $(du -sh "$APP_DIR" | cut -f1)"
echo ""
echo "  Para probar:"
echo "    open \"$APP_DIR\""
echo ""
echo "  Para crear .dmg:"
echo "    ./Scripts/create-dmg.sh"
echo "═══════════════════════════════════════════════"
