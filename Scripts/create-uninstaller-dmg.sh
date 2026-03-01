#!/bin/bash
set -euo pipefail

# ─────────────────────────────────────────────────────
# create-uninstaller-dmg.sh
# Creates a .dmg for Claude Code Nuclear Uninstaller
# Usage: ./Scripts/create-uninstaller-dmg.sh
# Output: dist/ClaudeCodeNuclearUninstaller.dmg
# ─────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_NAME="Claude Code Nuclear Uninstaller"
DIST_DIR="$PROJECT_DIR/dist"
APP_DIR="$DIST_DIR/$APP_NAME.app"
DMG_NAME="ClaudeCodeNuclearUninstaller"
DMG_PATH="$DIST_DIR/$DMG_NAME.dmg"
DMG_TEMP="$DIST_DIR/$DMG_NAME-temp.dmg"
STAGING_DIR="$DIST_DIR/uninstaller-dmg-staging"
VOLUME_NAME="Claude Code Nuclear Uninstaller"

cd "$PROJECT_DIR"

echo "╔══════════════════════════════════════════════╗"
echo "║  Nuclear Uninstaller — DMG Creator           ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Build if needed
if [ ! -d "$APP_DIR" ]; then
    echo "▸ No se encontró la .app — compilando primero..."
    bash "$SCRIPT_DIR/build-uninstaller.sh"
    echo ""
fi

# Staging
echo "▸ Preparando contenido del DMG..."
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"
cp -R "$APP_DIR" "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"
echo "✓ Staging preparado"

# Create DMG
echo "▸ Creando imagen de disco..."
rm -f "$DMG_TEMP" "$DMG_PATH"
hdiutil create -volname "$VOLUME_NAME" -srcfolder "$STAGING_DIR" -ov -format UDRW "$DMG_TEMP" -quiet
echo "✓ Imagen creada"

# Customize
echo "▸ Configurando apariencia..."
MOUNT_POINT="/Volumes/$VOLUME_NAME"
hdiutil attach -readwrite -noverify "$DMG_TEMP" -mountpoint "$MOUNT_POINT" 2>/dev/null || true
sleep 1

osascript <<APPLESCRIPT
tell application "Finder"
    tell disk "$VOLUME_NAME"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {100, 100, 640, 400}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 96
        set position of item "$APP_NAME.app" of container window to {140, 150}
        set position of item "Applications" of container window to {400, 150}
        close
        open
        update without registering applications
        delay 1
        close
    end tell
end tell
APPLESCRIPT

sync
hdiutil detach "$MOUNT_POINT" -quiet 2>/dev/null || true
echo "✓ Apariencia configurada"

# Compress
echo "▸ Comprimiendo DMG final..."
hdiutil convert "$DMG_TEMP" -format UDZO -imagekey zlib-level=9 -o "$DMG_PATH" -quiet
rm -f "$DMG_TEMP"
rm -rf "$STAGING_DIR"

echo ""
echo "═══════════════════════════════════════════════"
echo "✓ DMG creado exitosamente!"
echo ""
echo "  Archivo:  $DMG_PATH"
echo "  Tamaño:   $(du -sh "$DMG_PATH" | cut -f1)"
echo ""
echo "  Para probar:"
echo "    open \"$DMG_PATH\""
echo "═══════════════════════════════════════════════"
