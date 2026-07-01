#!/usr/bin/env bash
# Regenerate the ATS résumé PDF from its HTML source.
#
# The downloadable PDF (../Robin-Widjaja-Resume-2026.pdf) is a hand-curated,
# ATS-friendly 2-page document — it is NOT a print of the gamified index.html.
# Its source is pdf-src/resume-ats.html. To update the PDF: edit that HTML,
# then run this script. (Keeping the source in-repo avoids rebuilding from
# scratch every time — which is what happened before it was committed.)
#
# Usage:  ./pdf-src/build-pdf.sh
set -euo pipefail

cd "$(dirname "$0")/.."
SRC="pdf-src/resume-ats.html"
OUT="Robin-Widjaja-Resume-2026.pdf"

# Find a Chrome/Chromium binary (headless print -> Skia/PDF, matches the original).
CHROME=""
for c in \
  "$HOME/.cache/ms-playwright/chromium-1228/chrome-linux64/chrome" \
  "$HOME/.cache/puppeteer"/chrome/*/chrome-linux*/chrome \
  "$HOME/shai/browsers/chrome-linux64/chrome" \
  "$(command -v google-chrome || true)" \
  "$(command -v chromium || true)" \
  "$(command -v chromium-browser || true)"; do
  if [ -n "$c" ] && [ -x "$c" ]; then CHROME="$c"; break; fi
done
if [ -z "$CHROME" ]; then
  echo "No Chrome/Chromium found. Install one, e.g.: npx --yes puppeteer browsers install chrome" >&2
  exit 1
fi

echo "Rendering $SRC -> $OUT  (via $CHROME)"
"$CHROME" --headless=new --no-sandbox --disable-gpu --no-pdf-header-footer \
  --print-to-pdf="$OUT" "file://$PWD/$SRC" 2>/dev/null

# Report result (page count if pdfinfo is available).
if command -v pdfinfo >/dev/null; then
  pdfinfo "$OUT" | grep -iE 'pages|producer'
fi
echo "Done: $OUT ($(du -h "$OUT" | cut -f1))"
