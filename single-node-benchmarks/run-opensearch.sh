#!/bin/bash

ENV_FILE=${1:-.env}

if [ -f "$ENV_FILE" ]; then
  export $(cat "$ENV_FILE" | grep -v '^#' | xargs)
  echo "Loaded configuration from $ENV_FILE:"
  cat "$ENV_FILE" | grep -v '^#' | grep -v '^$'
else
  echo "Warning: $ENV_FILE not found, using defaults"
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
