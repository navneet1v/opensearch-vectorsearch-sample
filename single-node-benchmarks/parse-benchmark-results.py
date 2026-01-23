#!/usr/bin/env python3

import csv
import json
import sys

if len(sys.argv) < 3:
    print("Usage: python3 parse-benchmark-results.py <results_file.csv> <output_dir>")
    sys.exit(1)

results_file = sys.argv[1]
output_dir = sys.argv[2]

# Parse CSV results - format: Metric,Operation,Value,Unit
metrics = {}
with open(results_file, 'r') as f:
    reader = csv.reader(f)
    
    for row in reader:
        if len(row) >= 3 and len(row[1].strip()) > 0 and row[1].strip() == 'prod-queries':
            metric_name = row[0].strip()
            value = row[2].strip()
            
            try:
                metrics[metric_name] = float(value)
            except ValueError:
                metrics[metric_name] = value

# Build summary
summary = {
    'operation': 'prod-queries',
    'throughput_min': metrics.get('Min Throughput', 0),
    'throughput_mean': metrics.get('Mean Throughput', 0),
    'throughput_median': metrics.get('Median Throughput', 0),
    'throughput_max': metrics.get('Max Throughput', 0),
    'latency_p50': metrics.get('50th percentile latency', 0),
    'latency_p90': metrics.get('90th percentile latency', 0),
    'latency_p99': metrics.get('99th percentile latency', 0),
    'latency_p99_9': metrics.get('99.9th percentile latency', 0),
    'latency_p99_99': metrics.get('99.99th percentile latency', 0),
    'latency_p100': metrics.get('100th percentile latency', 0),
    'service_time_p50': metrics.get('50th percentile service time', 0),
    'service_time_p90': metrics.get('90th percentile service time', 0),
    'service_time_p99': metrics.get('99th percentile service time', 0),
    'service_time_p100': metrics.get('100th percentile service time', 0),
    'error_rate': metrics.get('error rate', 0),
    'recall_at_k': metrics.get('Mean recall@k', 0),
    'recall_at_1': metrics.get('Mean recall@1', 0)
}

with open(f'{output_dir}/prod_queries_summary.json', 'w') as out:
    json.dump(summary, out, indent=2)

print('Prod-queries Summary:')
print(json.dumps(summary, indent=2))
