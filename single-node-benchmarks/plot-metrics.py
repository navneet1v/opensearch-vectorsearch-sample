#!/usr/bin/env python3

import sys
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from pathlib import Path
import re
from datetime import datetime

def parse_docker_stats(file_path):
    data = []
    with open(file_path, 'r') as f:
        for line in f:
            parts = line.strip().split(',')
            if len(parts) >= 6:
                cpu = float(parts[1].replace('%', ''))
                mem_perc = float(parts[3].replace('%', ''))
                data.append({'cpu': cpu, 'mem_perc': mem_perc})
    return pd.DataFrame(data)

def parse_page_faults(file_path):
    data = []
    with open(file_path, 'r') as f:
        for line in f:
            parts = line.strip().split(',')
            if len(parts) >= 2:
                data.append({'minor': int(parts[0]), 'major': int(parts[1])})
    return pd.DataFrame(data)

def create_graphs(metrics_dir, output_file):
    metrics_path = Path(metrics_dir)
    
    # Find the latest metric files
    docker_stats = list(metrics_path.glob('docker_stats_*.csv'))
    page_faults = list(metrics_path.glob('page_faults_*.csv'))
    
    if not docker_stats or not page_faults:
        print("Error: Metric files not found")
        sys.exit(1)
    
    # Parse data
    df_stats = parse_docker_stats(docker_stats[0])
    df_faults = parse_page_faults(page_faults[0])
    
    # Create figure with subplots
    fig = plt.figure(figsize=(16, 10))
    gs = gridspec.GridSpec(2, 2, figure=fig, hspace=0.3, wspace=0.3)
    
    # CPU Usage
    ax1 = fig.add_subplot(gs[0, 0])
    ax1.plot(df_stats.index, df_stats['cpu'], color='blue', linewidth=2)
    ax1.set_title('CPU Usage Over Time', fontsize=14, fontweight='bold')
    ax1.set_xlabel('Sample Number')
    ax1.set_ylabel('CPU %')
    ax1.grid(True, alpha=0.3)
    
    # Memory Usage
    ax2 = fig.add_subplot(gs[0, 1])
    ax2.plot(df_stats.index, df_stats['mem_perc'], color='green', linewidth=2)
    ax2.set_title('Memory Usage Over Time', fontsize=14, fontweight='bold')
    ax2.set_xlabel('Sample Number')
    ax2.set_ylabel('Memory %')
    ax2.grid(True, alpha=0.3)
    
    # Minor Page Faults
    ax3 = fig.add_subplot(gs[1, 0])
    ax3.plot(df_faults.index, df_faults['minor'], color='orange', linewidth=2)
    ax3.set_title('Minor Page Faults', fontsize=14, fontweight='bold')
    ax3.set_xlabel('Sample Number')
    ax3.set_ylabel('Count')
    ax3.grid(True, alpha=0.3)
    
    # Major Page Faults
    ax4 = fig.add_subplot(gs[1, 1])
    ax4.plot(df_faults.index, df_faults['major'], color='red', linewidth=2)
    ax4.set_title('Major Page Faults', fontsize=14, fontweight='bold')
    ax4.set_xlabel('Sample Number')
    ax4.set_ylabel('Count')
    ax4.grid(True, alpha=0.3)
    
    # Add overall title
    fig.suptitle('OpenSearch Performance Metrics', fontsize=16, fontweight='bold', y=0.995)
    
    # Save figure
    plt.savefig(output_file, dpi=300, bbox_inches='tight')
    print(f"Graph saved to: {output_file}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 plot-metrics.py <metrics_directory> [output_file]")
        sys.exit(1)
    
    metrics_dir = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else "metrics_graph.png"
    
    create_graphs(metrics_dir, output_file)
