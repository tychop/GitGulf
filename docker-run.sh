#!/bin/bash
# Run GitGulf commands in Docker container

set -e

if [ $# -eq 0 ]; then
	echo "Usage: $0 <gitgulf-command> [args...]"
	echo ""
	echo "Examples:"
	echo "  $0 status"
	echo "  $0 fetch"
	echo "  $0 pull"
	echo "  $0 rebase"
	echo "  $0 -b feature/my-branch"
	echo "  $0 --version"
	exit 1
fi

echo "Building Docker image..."
docker-compose build

echo ""
echo "Running: gitgulf $@"
echo "========================================="
docker-compose run --rm gitgulf ./.build/debug/gitgulf "$@"
