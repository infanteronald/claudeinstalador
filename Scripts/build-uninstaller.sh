#!/bin/bash
set -euo pipefail

# ─────────────────────────────────────────────────────
# build-uninstaller.sh
# Compiles ClaudeUninstaller and packages it as a .app bundle
# Usage: ./Scripts/build-uninstaller.sh
# Output: dist/Claude Code Nuclear Uninstaller.app
# ─────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_NAME="Claude Code Nuclear Uninstaller"
DIST_DIR="$PROJECT_DIR/dist"
APP_DIR="$DIST_DIR/$APP_NAME.app"

cd "$PROJECT_DIR"

echo "╔══════════════════════════════════════════════╗"
echo "║  Claude Code Nuclear Uninstaller — Build     ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Step 1: Build release binary
echo "▸ Compilando en modo release..."
swift build -c release --product ClaudeUninstaller 2>&1 | tail -3

BINARY_PATH=".build/release/ClaudeUninstaller"
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
cp "$BINARY_PATH" "$APP_DIR/Contents/MacOS/ClaudeUninstaller"
echo "✓ Binario copiado"

# Step 4: Create Info.plist for uninstaller
cat > "$APP_DIR/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>Claude Code Nuclear Uninstaller</string>
    <key>CFBundleDisplayName</key>
    <string>Claude Code Nuclear Uninstaller</string>
    <key>CFBundleIdentifier</key>
    <string>com.claudeinstaller.uninstaller</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleExecutable</key>
    <string>ClaudeUninstaller</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIconName</key>
    <string>AppIcon</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.utilities</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright 2025 Ronald. MIT License.</string>
    <key>LSUIElement</key>
    <false/>
</dict>
</plist>
PLIST
echo "✓ Info.plist creado"

# Step 5: Generate uninstaller icon (red variant)
echo "▸ Generando ícono..."
swift "$SCRIPT_DIR/generate-uninstaller-icon.swift" "$APP_DIR/Contents/Resources/AppIcon.icns"
echo "✓ Ícono generado"

# Step 6: Create PkgInfo
echo "APPL????" > "$APP_DIR/Contents/PkgInfo"

# Step 7: Verify
echo ""
echo "═══════════════════════════════════════════════"
echo "✓ Build completado!"
echo ""
echo "  App:     $APP_DIR"
echo "  Tamaño:  $(du -sh "$APP_DIR" | cut -f1)"
echo ""
echo "  Para probar:"
echo "    open \"$APP_DIR\""
echo "═══════════════════════════════════════════════"
