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
DURATION=${JFR_DURATION:-60}
OUTPUT_DIR=./metrics/jfr/${JFR_OUTPUT_DIR:-./jfr}

mkdir -p "$OUTPUT_DIR"
sudo chown -R $(id -u):$(id -g) "$OUTPUT_DIR"
sudo chmod -R 755 "$OUTPUT_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
JFR_FILE="opensearch_${TIMESTAMP}.jfr"

echo "Starting JFR recording for $DURATION seconds..."
echo "Container: $CONTAINER_NAME"
echo "Output: $OUTPUT_DIR/$JFR_FILE"

# Get Java PID
JAVA_PID=$(docker exec $CONTAINER_NAME pgrep -f "org.opensearch.bootstrap.OpenSearch")

if [ -z "$JAVA_PID" ]; then
  echo "Error: Could not find OpenSearch Java process"
  exit 1
fi

echo "Java PID: $JAVA_PID"

# Start JFR recording
docker exec $CONTAINER_NAME jcmd $JAVA_PID JFR.start name=opensearch-recording duration=${DURATION}s filename=/tmp/$JFR_FILE settings=profile

echo "Recording in progress... waiting $DURATION seconds"
sleep $DURATION

# Copy JFR file from container
docker cp $CONTAINER_NAME:/tmp/$JFR_FILE "$OUTPUT_DIR/$JFR_FILE"

echo "JFR recording saved to: $OUTPUT_DIR/$JFR_FILE"
echo "Analyze with: jdk.jfr.FlightRecorder or JDK Mission Control"
