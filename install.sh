#!/usr/bin/env bash
# MCF Converter — install into Omarchy 4 (Quattro) as a bar-widget plugin.
set -euo pipefail

ID="superseed.mcf-converter"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$HOME/.config/omarchy/plugins/$ID"

if ! command -v omarchy >/dev/null 2>&1 || ! command -v omarchy-shell >/dev/null 2>&1; then
  echo "This needs Omarchy 4 (Quattro): 'omarchy' and 'omarchy-shell' were not found." >&2
  exit 1
fi
command -v wl-copy >/dev/null 2>&1 || echo "Note: wl-copy not found — click-to-copy needs wl-clipboard (sudo pacman -S wl-clipboard)."

echo "Installing MCF Converter to $DEST"
rm -rf "$DEST"
mkdir -p "$DEST"
cp "$SRC"/manifest.json "$SRC"/*.qml "$SRC"/Converters.js "$SRC"/uninstall.sh "$DEST"/
[ -f "$SRC/README.md" ] && cp "$SRC/README.md" "$DEST"/
[ -f "$SRC/LICENSE" ] && cp "$SRC/LICENSE" "$DEST"/

omarchy plugin validate "$DEST"
omarchy-shell shell rescanPlugins
omarchy plugin enable "$ID"
omarchy bar move "$ID" --section right || true

echo
echo "Done. The MCF Converter icon is now in the right-hand side of your bar."
echo "Drag it next to the tray chevron to position it. Click it to start."
