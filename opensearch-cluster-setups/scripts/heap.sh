#!/bin/bash


# Output header
#echo "Timestamp,MemoryUsage(GB),CPUUtilization(%),AnnoRSS(in KB), FileRSS(in KB)"
# Loop to capture memory and CPU utilization at regular intervals
while true; do
    #timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    curl localhost:9200/_cat/nodes\?h=heap\*\&v
    sleep 2
    # cpu_utilization=$(get_cpu_utilization "$container_id" | tr -d '%')
    # anno_rss=$(get_rss_usage "$OS_PROCESS_ID" "RssAnon")
    # file_rss=$(get_rss_usage "$OS_PROCESS_ID" "RssFile")
    # echo "$timestamp,$memory_usage,$cpu_utilization,$anno_rss,$file_rss"
    # we don't need sleep time here as getting all above stats itself take like 4sec
done
