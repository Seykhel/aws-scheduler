#!/bin/bash

# Exit immediately if any command fails
set -e

echo "Starting Lambda Layer build process..."

# Check if required commands are installed
check_dependency() {
    if ! command -v $1 &> /dev/null; then
        echo "Error: $1 is required but not installed. Please install it and try again."
        exit 1
    fi
}

# Check for required dependencies
echo "Checking system dependencies..."
check_dependency python3
check_dependency pip3
check_dependency zip

# Create a temporary directory for the layer
# This directory will contain all the Python dependencies
mkdir -p layer/python

echo "Installing Python dependencies from requirements.txt..."
# Install all required packages into the layer directory
# -t: Target directory for installation
# --no-cache-dir: Disable the cache to reduce layer size
# --upgrade: Ensure packages are up to date
pip3 install --no-cache-dir --upgrade -r requirements.txt -t layer/python/

# Check if the installation was successful
if [ $? -ne 0 ]; then
    echo "❌ Failed to install Python dependencies"
    exit 1
fi

echo "Creating layer.zip archive..."
# Navigate to the layer directory to avoid including parent directories in the zip
cd layer
# Create a zip file with all dependencies
# -r: Recursively include subdirectories
# -9: Maximum compression
# -q: Quiet mode to reduce output
zip -r9q ../layer.zip .
cd ..

# Verify the zip file was created
if [ ! -f "layer.zip" ]; then
    echo "❌ Failed to create layer.zip"
    exit 1
fi

echo "Cleaning up temporary files..."
# Remove the temporary directory
rm -rf layer

echo "✅ Lambda Layer successfully built: layer.zip"
echo "   Size: $(du -sh layer.zip | cut -f1)"
