#!/usr/bin/env bash
# Run this in your terminal: bash rebuild.sh
set -e
cd "$(dirname "$0")/build"
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -Wno-dev
make -j$(nproc)
echo "BUILD DONE"
echo "Run: cd $(dirname "$0")/build && ./archtitan-settings"
