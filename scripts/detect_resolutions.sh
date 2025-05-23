#!/bin/bash

LOG_FILE="logs/gameframe.log"

if ! command -v xrandr &> /dev/null; then
    echo "[$(date)] ERROR: xrandr not found" >> "$LOG_FILE"
    exit 1
fi

RESOLUTIONS=$(xrandr --current 2>/dev/null | grep -E '^[ ]*[0-9]+x[0-9]+' | awk '{print $1}' | sort -u)
REFRESH_RATES=$(xrandr --current 2>/dev/null | grep -E '^[ ]*[0-9]+x[0-9]+' | awk '{for(i=2;i<=NF;i++) if($i ~ /^[0-9]+\.[0-9]+/) print $i}' | sort -u | cut -d'.' -f1)

RESOLUTIONS_JSON=$(echo "$RESOLUTIONS" | jq -R . | jq -s .)
REFRESH_RATES_JSON=$(echo "$REFRESH_RATES" | jq -R . | jq -s .)
if [ $? -ne 0 ]; then
    echo "[$(date)] ERROR: Failed to parse resolutions/refresh rates with jq" >> "$LOG_FILE"
    exit 1
fi

echo "{\"resolutions\":$RESOLUTIONS_JSON,\"refresh_rates\":$REFRESH_RATES_JSON}" >> "$LOG_FILE"
echo "{\"resolutions\":$RESOLUTIONS_JSON,\"refresh_rates\":$REFRESH_RATES_JSON}"
