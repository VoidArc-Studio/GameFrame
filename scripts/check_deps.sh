#!/bin/bash

LOG_FILE="logs/gameframe.log"

# List of required commands
DEPENDENCIES=("vulkaninfo" "glxinfo" "python3" "cargo" "npm" "lspci" "jq" "nvidia-smi")

# Check each dependency
for cmd in "${DEPENDENCIES[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "[$(date)] ERROR: Missing dependency: $cmd" >> "$LOG_FILE"
        exit 1
    fi
    echo "[$(date)] Found dependency: $cmd" >> "$LOG_FILE"
done

# Check Vulkan drivers
if [ ! -f "/usr/share/vulkan/icd.d/nvidia_icd.json" ] && [ ! -f "/usr/share/vulkan/icd.d/radeon_icd.json" ] && [ ! -f "/usr/share/vulkan/icd.d/intel_icd.json" ]; then
    echo "[$(date)] ERROR: No Vulkan drivers found" >> "$LOG_FILE"
    exit 1
fi
echo "[$(date)] Vulkan drivers detected" >> "$LOG_FILE"

# Check OpenGL drivers
if [ ! -d "/usr/lib/dri" ]; then
    echo "[$(date)] ERROR: No OpenGL drivers found" >> "$LOG_FILE"
    exit 1
fi
echo "[$(date)] OpenGL drivers detected" >> "$LOG_FILE"

echo "[$(date)] All dependencies satisfied" >> "$LOG_FILE"
