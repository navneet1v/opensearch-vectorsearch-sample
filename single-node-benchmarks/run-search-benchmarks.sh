#!/bin/bash
set -euxo pipefail

# Usage: bash run-search-benchmarks.sh <baseline|candidate> [--capture-jfr]
RUN_TYPE=${1:-baseline}
CAPTURE_JFR=${2:-}

if [[ "$RUN_TYPE" != "baseline" && "$RUN_TYPE" != "candidate" && "$RUN_TYPE" != "candidate-prefetch" ]]; then
  echo "Error: First argument must be 'baseline' or 'candidate' or 'candidate-prefetch'"
  echo "Usage: bash run-search-benchmarks.sh <baseline|candidate|candidate-prefetch> [--capture-jfr]"
  exit 1
fi

ENV_FILE="${RUN_TYPE}.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "Error: Environment file $ENV_FILE not found"
  exit 1
fi

echo "Starting $RUN_TYPE benchmark run..."

# Load environment variables to get output directory structure
source "$ENV_FILE"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
TEST_SCENARIO=${TEST_SCENARIO:-memory-${MEMORY_LIMIT:-16g}-test}
BENCHMARK_OUTPUT_DIR=./metrics/${TEST_SCENARIO}/${RUN_TYPE}/${TIMESTAMP}
mkdir -p "$BENCHMARK_OUTPUT_DIR"

# Start metrics collection in background
bash collect-metrics.sh "$ENV_FILE" > "$BENCHMARK_OUTPUT_DIR/collect-metrics.log" 2>&1 &
METRICS_PID=$!
echo "Metrics collection started (PID: $METRICS_PID, log: $BENCHMARK_OUTPUT_DIR/collect-metrics.log)"

# Start JFR capture if requested
if [[ "$CAPTURE_JFR" == "--capture-jfr" ]]; then
  bash capture-jfr.sh "$ENV_FILE" > "$BENCHMARK_OUTPUT_DIR/capture-jfr.log" 2>&1 &
  JFR_PID=$!
  echo "JFR capture started (PID: $JFR_PID, log: $BENCHMARK_OUTPUT_DIR/capture-jfr.log)"
fi

# Run the benchmark
export PARAMS_FILE=/home/ec2-user/opensearch-benchmark-workloads/vectorsearch/params/corpus/1million/faiss-cohere-768-dp.json
export WORKLOAD=/home/ec2-user/opensearch-benchmark-workloads/vectorsearch
export ENDPOINT=http://localhost:9200

echo "Running OpenSearch benchmark..."
BENCHMARK_RESULTS="$BENCHMARK_OUTPUT_DIR/benchmark_results.csv"
opensearch-benchmark run --target-hosts $ENDPOINT --workload $WORKLOAD --workload-params ${PARAMS_FILE} --pipeline benchmark-only --kill-running-processes --test-procedure=search-only --include-tasks "prod-queries" --results-format=csv --results-file="$BENCHMARK_RESULTS"

echo "Benchmark completed. Stopping metrics collection..."

# Parse benchmark results
if [ -f "$BENCHMARK_RESULTS" ]; then
  echo "Parsing benchmark results..."
  python3 parse-benchmark-results.py "$BENCHMARK_RESULTS" "$BENCHMARK_OUTPUT_DIR"
fi

# Stop metrics collection
kill $METRICS_PID 2>/dev/null || true

# Wait for JFR to complete if it was started
if [[ "$CAPTURE_JFR" == "--capture-jfr" ]]; then
  echo "Waiting for JFR capture to complete..."
  wait $JFR_PID 2>/dev/null || true
fi

echo "$RUN_TYPE benchmark run completed successfully!"