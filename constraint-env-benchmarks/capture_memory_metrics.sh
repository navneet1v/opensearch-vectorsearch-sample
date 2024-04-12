#!/bin/bash
# Function to get the memory usage of a Docker container
get_memory_usage() {
    container_id=$1
    memory_usage=$(docker stats --no-stream --format "{{.MemUsage}}" "$container_id" | tail -n 1)
    echo "$memory_usage"
}
# Function to get the CPU utilization of a Docker container
get_cpu_utilization() {
    container_id=$1
    cpu_utilization=$(docker stats --no-stream --format "{{.CPUPerc}}" "$container_id" | tail -n 1)
    echo "$cpu_utilization"
}
# Main script
if [ $# -ne 1 ]; then
    echo "Usage: $0 <container_id>"
    exit 1
fi
container_id=$1
# Output header
echo "Timestamp,MemoryUsage(GB),CPUUtilization(%)"
# Loop to capture memory and CPU utilization at regular intervals
while true; do
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    memory_usage=$(get_memory_usage "$container_id" | tr -d 'MiB')
    cpu_utilization=$(get_cpu_utilization "$container_id" | tr -d '%')
    echo "$timestamp,$memory_usage,$cpu_utilization"
    sleep 5  # Adjust interval as needed
done