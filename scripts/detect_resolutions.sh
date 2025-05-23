#!/bin/bash

LOG_FILE="logs/gameframe.log"

# Default resolutions and refresh rates for TTY
DEFAULT_RESOLUTIONS=("1920x1080" "1280x720" "2560x1440")
DEFAULT_REFRESH_RATES=("60" "75" "120")

if [[ -z "$DISPLAY" && -z "$WAYLAND_DISPLAY" ]]; then
    echo "[$(date)] Running in TTY, using default resolutions" >> "$LOG_FILE"
    RESOLUTIONS_JSON=$(printf '%s\n' "${DEFAULT_RESOLUTIONS[@]}" | jq -R . | jq -s .)
    REFRESH_RATES_JSON=$(printf '%s\n' "${DEFAULT_REFRESH_RATES[@]}" | jq -R . | jq -s .)
else
    if ! command -v xrandr &> /dev/null; then
        echo "[$(date)] ERROR: xrandr not found, using default resolutions" >> "$LOG_FILE"
        RESOLUTIONS_JSON=$(printf '%s\n' "${DEFAULT_RESOLUTIONS[@]}" | jq -R . | jq -s .)
        REFRESH_RATES_JSON=$(printf '%s\n' "${DEFAULT_REFRESH_RATES[@]}" | jq -R . | jq -s .)
    else
        RESOLUTIONS=$(xrandr --current 2>/dev/null | grep -E '^[ ]*[0-9]+x[0-9]+' | awk '{print $1}' | sort -u)
        REFRESH_RATES=$(xrandr --current 2>/dev/null | grep -E '^[ ]*[0-9]+x[0-9]+' | awk '{for(i=2;i<=NF;i++) if($i ~ /^[0-9]+\.[0-9]+/) print $i}' | sort -u | cut -d'.' -f1)
        if [[ -z "$RESOLUTIONS" ]]; then
            echo "[$(date)] WARNING: No resolutions detected, using defaults" >> "$LOG_FILE"
            RESOLUTIONS_JSON=$(printf '%s\n' "${DEFAULT_RESOLUTIONS[@]}" | jq -R . | jq -s .)
            REFRESH_RATES_JSON=$(printf '%s\n' "${DEFAULT_REFRESH_RATES[@]}" | jq -R . | jq -s .)
        else
            RESOLUTIONS_JSON=$(echo "$RESOLUTIONS" | jq -R . | jq -s .)
            REFRESH_RATES_JSON=$(echo "$REFRESH_RATES" | jq -R . | jq -s .)
        fi
    fi
fi

echo "{\"resolutions\":$RESOLUTIONS_JSON,\"refresh_rates\":$REFRESH_RATES_JSON}" >> "$LOG_FILE"
echo "{\"resolutions\":$RESOLUTIONS_JSON,\"refresh_rates\":$REFRESH_RATES_JSON}"
