#!/bin/bash

REPO_URL="https://github.com/automazeio/ccpm.git"
TEMP_DIR="/tmp/ccpm"

echo "Cloning repository to temporary directory..."
git clone "$REPO_URL" "$TEMP_DIR"

if [ $? -eq 0 ]; then
    echo "Clone successful. Copying .claude directory..."
    cp -r "$TEMP_DIR/.claude" ./
    
    echo "Cleaning up temporary files..."
    rm -rf "$TEMP_DIR"
    echo "Installation complete. Only .claude directory has been copied."
else
    echo "Error: Failed to clone repository."
    exit 1
fi