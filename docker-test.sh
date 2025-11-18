#!/bin/bash
# Run GitGulf test suite in Docker container

set -e

# Timeout for tests (in seconds)
TIMEOUT=180

echo "Building Docker image..."
docker compose build

echo ""
echo "Running full test suite (90 tests) with ${TIMEOUT}s timeout..."
echo "========================================="

# Run tests with timeout (without -it to avoid TTY issues)
if command -v gtimeout >/dev/null 2>&1; then
    # Use gtimeout if available (typically on macOS with GNU coreutils)
    gtimeout ${TIMEOUT} docker compose run --rm -T gitgulf swift test
elif command -v timeout >/dev/null 2>&1; then
    # Use timeout if available (typically on Linux)
    timeout ${TIMEOUT} docker compose run --rm -T gitgulf swift test
else
    # Fallback without timeout
    docker compose run --rm -T gitgulf swift test
fi

echo ""
echo "========================================="
echo "Test suite complete!"
