#!/bin/bash

ENV_FILE=${1:-.env}

if [ -f "$ENV_FILE" ]; then
  export $(cat "$ENV_FILE" | grep -v '^#' | xargs)
  echo "Loaded configuration from $ENV_FILE:"
  cat "$ENV_FILE" | grep -v '^#' | grep -v '^$'
else
  echo "Warning: $ENV_FILE not found, using defaults"
fi

CONTAINER_NAME=${CONTAINER_NAME:-baseline-opensearch}
OUTPUT_DIR=./metrics/${METRICS_OUTPUT_DIR:-./metrics}
INTERVAL=${METRICS_INTERVAL:-5}

mkdir -p "$OUTPUT_DIR"
sudo chown -R $(id -u):$(id -g) "$OUTPUT_DIR"
sudo chmod -R 755 "$OUTPUT_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "Collecting metrics for container: $CONTAINER_NAME"
echo "Output directory: $OUTPUT_DIR"
echo "Interval: ${INTERVAL}s"
echo "Press Ctrl+C to stop"

while true; do
  CURRENT_TIME=$(date +%Y-%m-%d_%H:%M:%S)
  
  # Docker stats (CPU, Memory, Network, Block I/O)
  docker stats --no-stream --format "{{.Container}},{{.CPUPerc}},{{.MemUsage}},{{.MemPerc}},{{.NetIO}},{{.BlockIO}}" $CONTAINER_NAME >> "$OUTPUT_DIR/docker_stats_${TIMESTAMP}.csv"
  
  # Container process stats (page faults, RSS, etc)
  docker exec $CONTAINER_NAME cat /proc/1/status | grep -E "VmRSS|VmSize|VmPeak|Threads" >> "$OUTPUT_DIR/process_memory_${TIMESTAMP}.log"
  echo "---$CURRENT_TIME---" >> "$OUTPUT_DIR/process_memory_${TIMESTAMP}.log"
  
  # Page faults
  docker exec $CONTAINER_NAME cat /proc/1/stat | awk '{print $10","$12}' >> "$OUTPUT_DIR/page_faults_${TIMESTAMP}.csv"
  
  # OpenSearch JVM stats
  curl -s http://localhost:9200/_nodes/stats/jvm,os,process,fs?pretty >> "$OUTPUT_DIR/opensearch_stats_${TIMESTAMP}.json"
  
  # OpenSearch cluster health
  curl -s http://localhost:9200/_cluster/health?pretty >> "$OUTPUT_DIR/cluster_health_${TIMESTAMP}.json"
  
  sleep $INTERVAL
done
