#!/usr/bin/env python3

import json
import sys

if len(sys.argv) < 3:
    print("Usage: python3 parse-benchmark-results.py <results_file> <output_dir>")
    sys.exit(1)

results_file = sys.argv[1]
output_dir = sys.argv[2]

with open(results_file, 'r') as f:
    data = json.load(f)

# Find prod-queries operation
for result in data.get('results', {}).get('op_metrics', []):
    if result.get('task') == 'prod-queries':
        metrics = result
        
        # Extract latency percentiles
        latency = metrics.get('latency', {})
        throughput = metrics.get('throughput', {})
        
        summary = {
            'operation': 'prod-queries',
            'throughput_min': throughput.get('min'),
            'throughput_max': throughput.get('max'),
            'throughput_median': throughput.get('median'),
            'throughput_mean': throughput.get('mean'),
            'latency_p50': latency.get('50'),
            'latency_p90': latency.get('90'),
            'latency_p95': latency.get('95'),
            'latency_p99': latency.get('99'),
            'latency_p100': latency.get('100')
        }
        
        with open(f'{output_dir}/prod_queries_summary.json', 'w') as out:
            json.dump(summary, out, indent=2)
        
        print('Prod-queries Summary:')
        print(json.dumps(summary, indent=2))
        break
