#!/bin/bash
set -euo pipefail

BINARY=".build/release/HangulHUD"
ASSETS="assets"

if [ ! -f "$BINARY" ]; then
  echo "Error: Binary not found at $BINARY. Run 'swift build -c release' first."
  exit 1
fi

echo "Capturing dark + Style 1..."
"$BINARY" --screenshot dark "$ASSETS/dark_style1.png" --font style1

echo "Capturing light + Style 2..."
"$BINARY" --screenshot light "$ASSETS/light_style2.png" --font style2

echo "Done! Screenshots saved to $ASSETS/"
