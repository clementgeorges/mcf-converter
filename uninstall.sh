#!/usr/bin/env bash
# MCF Converter — remove completely.
set -uo pipefail

ID="superseed.mcf-converter"
DEST="$HOME/.config/omarchy/plugins/$ID"

if command -v omarchy >/dev/null 2>&1; then
  omarchy plugin disable "$ID" 2>/dev/null || true
  omarchy plugin remove "$ID" --yes 2>/dev/null || true
fi

if [ -n "$ID" ] && [ -d "$DEST" ]; then
  rm -rf "$DEST"
fi

command -v omarchy-shell >/dev/null 2>&1 && omarchy-shell shell rescanPlugins 2>/dev/null || true

echo "MCF Converter removed."
