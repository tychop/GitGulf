#!/bin/bash
# Build GitGulf binary in Docker container

set -e

echo "Building GitGulf in Docker..."
docker-compose build

echo "Building release binary..."
docker-compose run --rm gitgulf swift build -c release

echo "Build complete!"
echo "Binary location: .build/release/gitgulf"
