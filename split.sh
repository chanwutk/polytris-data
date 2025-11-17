#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <file-to-split> [chunk-size]" >&2
  echo "Example: $0 retinanet_b3d.pth 50M" >&2
  exit 2
fi

file="$1"
size="${2:-50M}"

if [ ! -f "$file" ]; then
  echo "File not found: $file" >&2
  exit 3
fi

split -a 2 -d -b 50M -- "$file" "${file}."

# Calculate and save MD5 checksum
md5sum "$file" | awk '{print $1}' > "${file}.md5"
echo "MD5 checksum saved to ${file}.md5"