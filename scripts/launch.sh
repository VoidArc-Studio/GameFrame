#!/bin/bash

mkdir -p logs
LOG_FILE="logs/gameframe.log"
echo "[$(date)] Starting GameFrame launch" >> "$LOG_FILE"

source ./scripts/setup_env.sh >> "$LOG_FILE" 2>&1
if [ $? -ne 0 ]; then
    echo "[$(date)] ERROR: Failed to set up environment" >> "$LOG_FILE"
    exit 1
fi

bash ./scripts/check_deps.sh >> "$LOG_FILE" 2>&1
if [ $? -ne 0 ]; then
    echo "[$(date)] ERROR: Dependency check failed" >> "$LOG_FILE"
    exit 1
fi

GPU_VENDOR=$(bash ./scripts/detect_gpu.sh | jq -r '.vendor')
if [ -z "$GPU_VENDOR" ]; then
    echo "[$(date)] ERROR: Failed to detect GPU" >> "$LOG_FILE"
    exit 1
fi
echo "[$(date)] Detected GPU: $GPU_VENDOR" >> "$LOG_FILE"

export GPU_VENDOR
export LD_LIBRARY_PATH=/usr/lib:$LD_LIBRARY_PATH

CONFIG_PROFILE=${1:-default}
CONFIG_FILE="config/profiles/${CONFIG_PROFILE}.conf"
if [ "$CONFIG_PROFILE" != "default" ] && [ ! -f "$CONFIG_FILE" ]; then
    echo "[$(date)] ERROR: Configuration profile $CONFIG_PROFILE not found" >> "$LOG_FILE"
    exit 1
fi
if [ "$CONFIG_PROFILE" != "default" ]; then
    cp "$CONFIG_FILE" config/gameframe.conf
    echo "[$(date)] Using configuration profile: $CONFIG_PROFILE" >> "$LOG_FILE"
else
    echo "[$(date)] Using default configuration" >> "$LOG_FILE"
fi

ENVIRONMENT=$(grep '^environment=' config/gameframe.conf | cut -d'=' -f2)
VALID_ENVIRONMENTS=("gnome" "kde" "steam-gamepadui" "heroic" "lutris")
if [[ ! " ${VALID_ENVIRONMENTS[@]} " =~ " ${ENVIRONMENT} " ]]; then
    echo "[$(date)] ERROR: Invalid environment: $ENVIRONMENT" >> "$LOG_FILE"
    exit 1
fi
echo "[$(date)] Launching environment: $ENVIRONMENT" >> "$LOG_FILE"

./build/gameframe --config config/gameframe.conf >> "$LOG_FILE" 2>&1
if [ $? -ne 0 ]; then
    echo "[$(date)] ERROR: Failed to launch GameFrame" >> "$LOG_FILE"
    exit 1
fi

echo "[$(date)] GameFrame launched successfully" >> "$LOG_FILE"
