#!/bin/bash

# Script to download and combine split retinanet_b3d.pth files
# Usage: ./download.sh <base_url>
# Example: ./download.sh https://example.com/path/to/files

DEFAULT_BASE_URL="https://github.com/chanwutk/polytris-data/raw/refs/heads/main/retinanet_b3d/"

if [ -z "$1" ]; then
    echo "No base URL provided, using default: $DEFAULT_BASE_URL"
    BASE_URL="$DEFAULT_BASE_URL"
else
    BASE_URL="$1"
fi

# Remove trailing slash if present
BASE_URL="${BASE_URL%/}"

# Function to download a file, trying wget first, then curl
download_file() {
    local url="$1"
    local output="$2"

    if command -v wget &> /dev/null; then
        wget -c "$url" -O "$output"
    elif command -v curl &> /dev/null; then
        curl -L -C - -o "$output" "$url"
    else
        echo "Error: Neither wget nor curl is installed"
        return 1
    fi
}

# Array of file suffixes
SUFFIXES=("aa" "ab" "ac" "ad" "ae")

echo "Downloading split files from: $BASE_URL"

# Download all parts
for suffix in "${SUFFIXES[@]}"; do
    FILE="retinanet_b3d.pth.$suffix"
    URL="$BASE_URL/$FILE"

    echo "Downloading $FILE..."
    if ! download_file "$URL" "$FILE"; then
        echo "Error: Failed to download $FILE"
        exit 1
    fi
done

echo "All parts downloaded successfully!"

# Combine the files
echo "Combining files into retinanet_b3d.pth..."
cat retinanet_b3d.pth.aa retinanet_b3d.pth.ab retinanet_b3d.pth.ac retinanet_b3d.pth.ad retinanet_b3d.pth.ae > retinanet_b3d.pth

echo "Done! File retinanet_b3d.pth created successfully."
echo "File size: $(du -h retinanet_b3d.pth | cut -f1)"

# Download MD5 checksum file
echo "Downloading MD5 checksum file..."
MD5_URL="$BASE_URL/retinanet_b3d.pth.md5"
if ! download_file "$MD5_URL" "retinanet_b3d.pth.md5"; then
    echo "Error: Failed to download MD5 checksum file"
    exit 1
fi

# Verify MD5 checksum
echo "Verifying MD5 checksum..."
if md5sum -c retinanet_b3d.pth.md5; then
    echo "Success! File integrity verified."
else
    echo "Error: MD5 checksum verification failed!"
    exit 1
fi
