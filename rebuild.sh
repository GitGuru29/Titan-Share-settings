#!/usr/bin/env bash
# Run this in your terminal: bash rebuild.sh
set -e
cd "$(dirname "$0")"

# Find the most recently modified PNG in Downloads and copy it
NEWEST_PNG=$(ls -t ~/Downloads/*.png 2>/dev/null | head -n 1)
if [ -n "$NEWEST_PNG" ]; then
    echo "Found transparent PNG: $NEWEST_PNG"
    cp "$NEWEST_PNG" assets/icons/archtitan-logo.png
else
    echo "No PNG found in Downloads. Creating a placeholder to prevent build error."
    touch assets/icons/archtitan-logo.png
fi
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -Wno-dev
make -j$(nproc)
echo "BUILD DONE"
echo "Run: cd $(dirname "$0")/build && ./archtitan-settings"
