#!/bin/bash

LOG_FILE="logs/gameframe.log"

DEPENDENCIES=("vulkaninfo" "glxinfo" "python3" "cargo" "npm" "lspci" "jq" "nvidia-smi" "xrandr" "pkg-config")
for cmd in "${DEPENDENCIES[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "[$(date)] ERROR: Missing dependency: $cmd" >> "$LOG_FILE"
        exit 1
    fi
    echo "[$(date)] Found dependency: $cmd" >> "$LOG_FILE"
done

if [ ! -f "/usr/share/vulkan/icd.d/nvidia_icd.json" ] && [ ! -f "/usr/share/vulkan/icd.d/radeon_icd.json" ] && [ ! -f "/usr/share/vulkan/icd.d/intel_icd.json" ]; then
    echo "[$(date)] ERROR: No Vulkan drivers found" >> "$LOG_FILE"
    exit 1
fi
echo "[$(date)] Vulkan drivers detected" >> "$LOG_FILE"

if [ ! -d "/usr/lib/dri" ]; then
    echo "[$(date)] ERROR: No OpenGL drivers found" >> "$LOG_FILE"
    exit 1
fi
echo "[$(date)] OpenGL drivers detected" >> "$LOG_FILE"

# Check wlroots and Gamescope dependencies
if ! pkg-config --exists wlroots; then
    echo "[$(date)] ERROR: wlroots not found" >> "$LOG_FILE"
    exit 1
fi
echo "[$(date)] wlroots detected" >> "$LOG_FILE"

for lib in libdrm libliftoff libinput; do
    if ! pkg-config --exists "$lib"; then
        echo "[$(date)] ERROR: $lib not found" >> "$LOG_FILE"
        exit 1
    fi
    echo "[$(date)] $lib detected" >> "$LOG_FILE"
done

echo "[$(date)] All dependencies satisfied" >> "$LOG_FILE"
