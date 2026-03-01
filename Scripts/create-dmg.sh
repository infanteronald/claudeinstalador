#!/bin/bash
set -euo pipefail

# ─────────────────────────────────────────────────────
# create-dmg.sh
# Creates a .dmg installer with drag-to-Applications
# Usage: ./Scripts/create-dmg.sh
# Output: dist/ClaudeCodeInstaller.dmg
# ─────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_NAME="Claude Code Installer"
DIST_DIR="$PROJECT_DIR/dist"
APP_DIR="$DIST_DIR/$APP_NAME.app"
DMG_NAME="ClaudeCodeInstaller"
DMG_PATH="$DIST_DIR/$DMG_NAME.dmg"
DMG_TEMP="$DIST_DIR/$DMG_NAME-temp.dmg"
STAGING_DIR="$DIST_DIR/dmg-staging"
VOLUME_NAME="Claude Code Installer"

cd "$PROJECT_DIR"

echo "╔══════════════════════════════════════════════╗"
echo "║   Claude Code Installer — DMG Creator        ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Step 0: Build the .app if it doesn't exist
if [ ! -d "$APP_DIR" ]; then
    echo "▸ No se encontró la .app — compilando primero..."
    bash "$SCRIPT_DIR/build-app.sh"
    echo ""
fi

# Step 1: Create staging area
echo "▸ Preparando contenido del DMG..."
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"

# Copy .app to staging
cp -R "$APP_DIR" "$STAGING_DIR/"

# Create Applications symlink (this is what makes drag-to-install work)
ln -s /Applications "$STAGING_DIR/Applications"

echo "✓ Staging preparado"

# Step 2: Create the DMG
echo "▸ Creando imagen de disco..."
rm -f "$DMG_TEMP" "$DMG_PATH"

# Create a read-write DMG first
hdiutil create \
    -volname "$VOLUME_NAME" \
    -srcfolder "$STAGING_DIR" \
    -ov \
    -format UDRW \
    "$DMG_TEMP" \
    -quiet

echo "✓ Imagen creada"

# Step 3: Customize DMG appearance
echo "▸ Configurando apariencia..."

# Mount the DMG
MOUNT_POINT="/Volumes/$VOLUME_NAME"
hdiutil attach -readwrite -noverify "$DMG_TEMP" -mountpoint "$MOUNT_POINT" 2>/dev/null || true

# Small delay to let the volume mount
sleep 1

# Apply Finder view settings via AppleScript
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
        -- Position the app icon on the left
        set position of item "$APP_NAME.app" of container window to {140, 150}
        -- Position the Applications shortcut on the right
        set position of item "Applications" of container window to {400, 150}
        close
        open
        update without registering applications
        delay 1
        close
    end tell
end tell
APPLESCRIPT

# Set custom background color (optional — white)
sync

# Unmount
hdiutil detach "$MOUNT_POINT" -quiet 2>/dev/null || true

echo "✓ Apariencia configurada"

# Step 4: Convert to compressed read-only DMG
echo "▸ Comprimiendo DMG final..."
hdiutil convert "$DMG_TEMP" \
    -format UDZO \
    -imagekey zlib-level=9 \
    -o "$DMG_PATH" \
    -quiet

# Cleanup
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
echo ""
echo "  Para compartir:"
echo "    Sube el archivo .dmg a GitHub Releases"
echo "    o compártelo directamente con tus amigos"
echo "═══════════════════════════════════════════════"
