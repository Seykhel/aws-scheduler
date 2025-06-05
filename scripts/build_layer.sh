#!/bin/bash
set -e

# Create layer directory structure
LAYER_DIR="lambda_layer"
ZIP_FILE="scheduler_layer.zip"

# Copy Python modules to layer directory
cp modules/scheduler_common.py "$LAYER_DIR/python/modules/"
cp modules/logger_config.py "$LAYER_DIR/python/modules/"

# Install dependencies
pip install -r requirements.txt -t "$LAYER_DIR/python/"

# Create zip file
cd "$LAYER_DIR"
zip -r "../$ZIP_FILE" python

# Clean up
rm -rf python
cd ..

echo "Layer package created: $ZIP_FILE"
