# OpenSearch Single Node Benchmarking Scripts

This directory contains scripts for running comparative benchmarks between baseline and candidate OpenSearch configurations.

## Prerequisites

- Docker and Docker Compose
- Python 3 with pandas and matplotlib: `pip install pandas matplotlib`
- sudo access (for setting directory permissions)

## Quick Start: Baseline vs Candidate Benchmarking

### Step 1: Configure Baseline and Candidate

Create two environment files with your configurations:

**baseline.env** - Your baseline/control configuration
```bash
OPENSEARCH_VERSION=3.3.2
CONTAINER_NAME=baseline-opensearch
CLUSTER_NAME=baseline-opensearch
NODE_NAME=baseline-opensearch-node
DISCOVERY_HOSTS=baseline-opensearch-node
CLUSTER_MANAGER_NODES=baseline-opensearch-node
HEAP_SIZE=8g
MEMORY_LIMIT=16g
DATA_PATH=./opensearch-data-baseline
METRICS_OUTPUT_DIR=./baseline-metrics
JFR_OUTPUT_DIR=./baseline-jfr
METRICS_INTERVAL=5
JFR_DURATION=60
```

**candidate.env** - Your candidate/test configuration
```bash
OPENSEARCH_VERSION=3.3.2
CONTAINER_NAME=candidate-opensearch
CLUSTER_NAME=candidate-opensearch
NODE_NAME=candidate-opensearch-node
DISCOVERY_HOSTS=candidate-opensearch-node
CLUSTER_MANAGER_NODES=candidate-opensearch-node
HEAP_SIZE=12g
MEMORY_LIMIT=24g
DATA_PATH=./opensearch-data-candidate
METRICS_OUTPUT_DIR=./candidate-metrics
JFR_OUTPUT_DIR=./candidate-jfr
METRICS_INTERVAL=5
JFR_DURATION=60
```

### Step 2: Run Baseline Benchmark

**Terminal 1 - Start Baseline OpenSearch:**
```bash
bash run-opensearch.sh baseline.env
```

**Terminal 2 - Collect Baseline Metrics:**
```bash
bash collect-metrics.sh baseline.env
# Keep running during your workload
```

**Terminal 3 - Run Your Workload:**
```bash
# Run your benchmark workload against http://localhost:9200
# Example: opensearch-benchmark, custom scripts, etc.
```

**Terminal 4 - Capture Baseline JFR (optional):**
```bash
bash capture-jfr.sh baseline.env
```

**When workload completes:**
- Stop metrics collection (Ctrl+C in Terminal 2)
- Stop OpenSearch:
```bash
bash stop-opensearch.sh
```

### Step 3: Run Candidate Benchmark

**Terminal 1 - Start Candidate OpenSearch:**
```bash
bash run-opensearch.sh candidate.env
```

**Terminal 2 - Collect Candidate Metrics:**
```bash
bash collect-metrics.sh candidate.env
# Keep running during your workload
```

**Terminal 3 - Run Your Workload:**
```bash
# Run the SAME benchmark workload against http://localhost:9200
```

**Terminal 4 - Capture Candidate JFR (optional):**
```bash
bash capture-jfr.sh candidate.env
```

**When workload completes:**
- Stop metrics collection (Ctrl+C in Terminal 2)
- Stop OpenSearch:
```bash
bash stop-opensearch.sh
```

### Step 4: Generate Comparison Graphs

```bash
# Generate baseline graphs
python3 plot-metrics.py ./metrics/baseline-metrics baseline_performance.png

# Generate candidate graphs
python3 plot-metrics.py ./metrics/candidate-metrics candidate_performance.png
```

### Step 5: Compare Results

Compare the generated graphs side-by-side:
- `baseline_performance.png` - Baseline performance metrics
- `candidate_performance.png` - Candidate performance metrics

Review metrics:
- CPU usage patterns
- Memory consumption
- Page fault rates
- JFR profiles (if captured)

## Environment Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| `OPENSEARCH_VERSION` | OpenSearch Docker image version | `3.3.2` |
| `CONTAINER_NAME` | Docker container name | `baseline-opensearch` |
| `CLUSTER_NAME` | OpenSearch cluster name | `baseline-opensearch` |
| `NODE_NAME` | OpenSearch node name | `baseline-opensearch-node` |
| `HEAP_SIZE` | JVM heap size (50% of MEMORY_LIMIT) | `8g` |
| `MEMORY_LIMIT` | Total container memory limit | `16g` |
| `DATA_PATH` | Host path for OpenSearch data | `./opensearch-data-baseline` |
| `METRICS_OUTPUT_DIR` | Directory for metrics output | `./baseline-metrics` |
| `JFR_OUTPUT_DIR` | Directory for JFR recordings | `./baseline-jfr` |
| `METRICS_INTERVAL` | Seconds between metric samples | `5` |
| `JFR_DURATION` | JFR recording duration (seconds) | `60` |

## Scripts Reference

### run-opensearch.sh
Starts OpenSearch container with configuration from env file.
```bash
bash run-opensearch.sh <env-file>
```

### stop-opensearch.sh
Stops the running OpenSearch container.
```bash
bash stop-opensearch.sh
```

### collect-metrics.sh
Collects performance metrics continuously. Press Ctrl+C to stop.
```bash
bash collect-metrics.sh <env-file>
```

**Metrics collected:**
- CPU usage, Memory usage, Network I/O, Block I/O
- Minor/major page faults
- Process memory (RSS, VmSize, VmPeak)
- OpenSearch JVM stats, Cluster health

### capture-jfr.sh
Captures Java Flight Recorder profile for performance analysis.
```bash
bash capture-jfr.sh <env-file>
```

### plot-metrics.py
Generates visualization graphs from collected metrics.
```bash
python3 plot-metrics.py <metrics-directory> [output-file]
```

## Best Practices

1. **Consistent Workloads**: Run identical workloads for baseline and candidate
2. **Warm-up Period**: Allow 5-10 minutes warm-up before collecting metrics
3. **Multiple Runs**: Run each configuration 3-5 times and average results
4. **Clean State**: Use separate data directories for each run
5. **Resource Isolation**: Ensure no other heavy processes during benchmarks
6. **Document Changes**: Note configuration differences between baseline and candidate

## Example Benchmark Scenarios

### Scenario 1: Memory Configuration Comparison
- **Baseline**: 8GB heap, 16GB container
- **Candidate**: 12GB heap, 24GB container
- **Goal**: Measure impact of increased memory

### Scenario 2: Version Comparison
- **Baseline**: OpenSearch 3.0.0
- **Candidate**: OpenSearch 3.3.2
- **Goal**: Measure performance improvements in new version

### Scenario 3: JVM Settings Comparison
- **Baseline**: Default JVM settings
- **Candidate**: Custom GC settings via OPENSEARCH_JAVA_OPTS
- **Goal**: Optimize garbage collection

## Troubleshooting

**Port already in use:**
- Ensure previous container is stopped: `bash stop-opensearch.sh`
- Check for running containers: `docker ps`

**Permission denied on data directory:**
- Scripts automatically set permissions
- Manually fix: `sudo chown -R $(id -u):$(id -g) <data-path>`

**Metrics collection shows errors:**
- Verify container is running: `docker ps | grep opensearch`
- Test OpenSearch: `curl http://localhost:9200`

**JFR capture fails:**
- Ensure OpenSearch is fully started
- Check Java process: `docker exec <container-name> pgrep -f opensearch`

## Output Files

After running benchmarks, you'll have:

```
metrics/
  ├── baseline-metrics/
  │   ├── docker_stats_<timestamp>.csv
  │   ├── page_faults_<timestamp>.csv
  │   ├── process_memory_<timestamp>.log
  │   ├── opensearch_stats_<timestamp>.json
  │   └── cluster_health_<timestamp>.json
  │
  └── candidate-metrics/
      ├── docker_stats_<timestamp>.csv
      ├── page_faults_<timestamp>.csv
      ├── process_memory_<timestamp>.log
      ├── opensearch_stats_<timestamp>.json
      └── cluster_health_<timestamp>.json

baseline_performance.png
candidate_performance.png

baseline-jfr/
  └── opensearch_<timestamp>.jfr

candidate-jfr/
  └── opensearch_<timestamp>.jfr
```
