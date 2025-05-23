#!/bin/bash

LOG_FILE="logs/gameframe.log"

# Set up Vulkan and OpenGL libraries
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json:/usr/share/vulkan/icd.d/radeon_icd.json:/usr/share/vulkan/icd.d/intel_icd.json
export LIBGL_DRIVERS_PATH=/usr/lib/dri
echo "[$(date)] Set Vulkan and OpenGL library paths" >> "$LOG_FILE"

# GPU-specific optimizations
GPU_VENDOR=$(bash ./scripts/detect_gpu.sh | jq -r '.vendor')
if [ "$GPU_VENDOR" = "nvidia" ]; then
    # NVIDIA power management
    nvidia-smi -pm 1 > /dev/null 2>> "$LOG_FILE"
    if [ $? -eq 0 ]; then
        echo "[$(date)] Enabled NVIDIA persistence mode" >> "$LOG_FILE"
    else
        echo "[$(date)] WARNING: Failed to enable NVIDIA persistence mode" >> "$LOG_FILE"
    fi
elif [ "$GPU_VENDOR" = "amd" ]; then
    # AMD performance profile
    echo "performance" > /sys/class/drm/card0/device/power_dpm_force_performance_level 2>> "$LOG_FILE"
    if [ $? -eq 0 ]; then
        echo "[$(date)] Set AMD GPU to performance mode" >> "$LOG_FILE"
    else
        echo "[$(date)] WARNING: Failed to set AMD performance mode" >> "$LOG_FILE"
    fi
elif [ "$GPU_VENDOR" = "intel" ]; then
    # Intel power management (basic)
    echo "0" > /sys/class/drm/card0/device/power_dpm_force_performance_level 2>> "$LOG_FILE"
    if [ $? -eq 0 ]; then
        echo "[$(date)] Set Intel GPU to balanced mode" >> "$LOG_FILE"
    else
        echo "[$(date)] WARNING: Failed to set Intel GPU mode" >> "$LOG_FILE"
    fi
fi

# Ensure Rust binary is executable
if [ -f "./build/gameframe" ]; then
    chmod +x ./build/gameframe
    echo "[$(date)] Ensured Rust binary is executable" >> "$LOG_FILE"
else
    echo "[$(date)] ERROR: Rust binary not found at ./build/gameframe" >> "$LOG_FILE"
    exit 1
fi

# Set up X11/Wayland environment
if [ -n "$WAYLAND_DISPLAY" ]; then
    export DISPLAY_BACKEND="wayland"
    echo "[$(date)] Detected Wayland session" >> "$LOG_FILE"
else
    export DISPLAY_BACKEND="x11"
    echo "[$(date)] Detected X11 session" >> "$LOG_FILE"
fi
