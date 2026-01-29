#!/bin/bash
set -euxo pipefail

# Usage: bash run-opensearch.sh --env <env-file> [--heap <size>]
ENV_FILE=".env"
HEAP_SIZE_OVERRIDE=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --env|-e)
      ENV_FILE="$2"
      shift 2
      ;;
    --heap)
      HEAP_SIZE_OVERRIDE="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: bash run-opensearch.sh --env <env-file> [--heap <size>]"
      exit 1
      ;;
  esac
done

if [ -f "$ENV_FILE" ]; then
  export $(cat "$ENV_FILE" | grep -v '^#' | xargs)
  echo "Loaded configuration from $ENV_FILE:"
  cat "$ENV_FILE" | grep -v '^#' | grep -v '^$'
else
  echo "Warning: $ENV_FILE not found, using defaults"
  exit 1
fi

# Override heap size if provided as command line argument
if [ -n "$HEAP_SIZE_OVERRIDE" ]; then
  echo "Overriding HEAP_SIZE from : $HEAP_SIZE to $HEAP_SIZE_OVERRIDE"
  export HEAP_SIZE="$HEAP_SIZE_OVERRIDE"
  echo "New HEAP_SIZE is: $HEAP_SIZE"
fi

DATA_DIR=${DATA_PATH:-./opensearch-data}
mkdir -p "$DATA_DIR"
sudo chown -R $(id -u):$(id -g) "$DATA_DIR"
sudo chmod -R 777 "$DATA_DIR"

docker compose -f cluster.yml up -d

echo "Waiting for OpenSearch to start..."
for i in {1..12}; do
  if curl -s http://localhost:${REST_PORT:-9200} > /dev/null 2>&1; then
    echo "OpenSearch is running!"
    exit 0
  fi
  sleep 5
done

echo "OpenSearch failed to start within 60 seconds"
exit 1
