#!/bin/bash

uptime_sec=$(cut -d. -f1 /proc/uptime)
days=$((uptime_sec/60/60/24))
hours=$(( (uptime_sec/60/60) % 24 ))
minutes=$(( (uptime_sec/60) % 60 ))

output=""
[ $days -gt 0 ] && output="${days}d"
[ $hours -gt 0 ] && output="${output:+$output-}${hours}h"
[ $minutes -gt 0 ] && output="${output:+$output-}${minutes}m"

echo "up:${output}"
