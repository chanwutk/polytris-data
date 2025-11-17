#!/bin/bash

# Script to clone a GitHub repo, combine split files, and verify checksums
# Usage: ./download.sh <username/repo_name> <filename>
# Example: ./download.sh chanwutk/polytris-data retinanet_b3d.pth

if [ $# -lt 2 ]; then
    echo "Usage: $0 <username/repo_name> <filename>" >&2
    echo "Example: $0 chanwutk/polytris-data retinanet_b3d.pth" >&2
    exit 1
fi

REPO="$1"
FILENAME="$2"

# Clone the repository
echo "Cloning repository: $REPO..."
REPO_NAME=$(basename "$REPO")
if [ -d "$REPO_NAME" ]; then
    echo "Repository directory already exists: $REPO_NAME"
    echo "Pulling latest changes..."
    cd "$REPO_NAME"
    git pull
    cd ..
else
    if ! git clone "https://github.com/${REPO}.git"; then
        echo "Error: Failed to clone repository"
        exit 1
    fi
fi

cd "$REPO_NAME"

# Find all split files
echo "Finding split files for $FILENAME..."
SPLIT_FILES=("${FILENAME}".*)
# Filter out .md5 file
SPLIT_FILES=($(ls "${FILENAME}".[0-9][0-9] 2>/dev/null || true))

if [ ${#SPLIT_FILES[@]} -eq 0 ]; then
    echo "Error: No split files found matching ${FILENAME}.*"
    exit 1
fi

echo "Found ${#SPLIT_FILES[@]} split files"

# Combine the files
echo "Combining files into $FILENAME..."
cat "${FILENAME}".[0-9][0-9] > "$FILENAME"

echo "Done! File $FILENAME created successfully."
echo "File size: $(du -h "$FILENAME" | cut -f1)"

# Verify MD5 checksum
MD5_FILE="${FILENAME}.md5"
if [ ! -f "$MD5_FILE" ]; then
    echo "Warning: MD5 checksum file not found: $MD5_FILE"
    exit 1
fi

echo "Verifying MD5 checksum..."
EXPECTED_MD5=$(cat "$MD5_FILE")
ACTUAL_MD5=$(md5sum "$FILENAME" | awk '{print $1}')

if [ "$EXPECTED_MD5" = "$ACTUAL_MD5" ]; then
    echo "Success! File integrity verified."
    echo "MD5: $ACTUAL_MD5"
else
    echo "Error: MD5 checksum verification failed!"
    echo "Expected: $EXPECTED_MD5"
    echo "Actual:   $ACTUAL_MD5"
    exit 1
fi