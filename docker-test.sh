#!/bin/bash
# Run GitGulf test suite in Docker container

set -e

echo "Building Docker image..."
docker-compose build

echo ""
echo "Running full test suite (90 tests)..."
echo "========================================="
docker-compose run --rm gitgulf swift test -v

echo ""
echo "========================================="
echo "Test suite complete!"
