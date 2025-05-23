#!/bin/bash

LOG_FILE="logs/gameframe.log"

# Set Vulkan and OpenGL library paths
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json:/usr/share/vulkan/icd.d/radeon_icd.json:/usr/share/vulkan/icd.d/intel_icd.json
export LIBGL_DRIVERS_PATH=/usr/lib/dri:/usr/lib64/dri
export LD_LIBRARY_PATH=/usr/lib:/usr/lib64:/usr/local/lib:/usr/local/lib64:$LD_LIBRARY_PATH
echo "[$(date)] Set Vulkan and OpenGL library paths" >> "$LOG_FILE"

# Detect GPU and optimize
GPU_INFO=$(bash ./scripts/detect_gpu.sh)
GPU_VENDOR=$(echo "$GPU_INFO" | jq -r '.vendor')
if [ "$GPU_VENDOR" = "nvidia" ]; then
    nvidia-smi -pm 1 > /dev/null 2>> "$LOG_FILE"
    if [ $? -eq 0 ]; then
        echo "[$(date)] Enabled NVIDIA persistence mode" >> "$LOG_FILE"
    else
        echo "[$(date)] WARNING: Failed to enable NVIDIA persistence mode" >> "$LOG_FILE"
    fi
    # Optimize for older NVIDIA GPUs (e.g., GTX 1060)
    nvidia-settings -a "[gpu:0]/GPUPowerMizerMode=1" > /dev/null 2>> "$LOG_FILE"
    echo "[$(date)] Set NVIDIA GPU to performance mode" >> "$LOG_FILE"
elif [ "$GPU_VENDOR" = "amd" ]; then
    echo "performance" > /sys/class/drm/card0/device/power_dpm_force_performance_level 2>> "$LOG_FILE"
    if [ $? -eq 0 ]; then
        echo "[$(date)] Set AMD GPU to performance mode" >> "$LOG_FILE"
    else
        echo "[$(date)] WARNING: Failed to set AMD performance mode" >> "$LOG_FILE"
    fi
elif [ "$GPU_VENDOR" = "intel" ]; then
    echo "0" > /sys/class/drm/card0/device/power_dpm_force_performance_level 2>> "$LOG_FILE"
    if [ $? -eq 0 ]; then
        echo "[$(date)] Set Intel GPU to balanced mode" >> "$LOG_FILE"
    else
        echo "[$(date)] WARNING: Failed to set Intel GPU mode" >> "$LOG_FILE"
    fi
fi
export GPU_VENDOR
echo "[$(date)] GPU vendor: $GPU_VENDOR" >> "$LOG_FILE"

# Ensure Rust binary is executable
if [ -f "./build/gameframe" ]; then
    chmod +x ./build/gameframe
    echo "[$(date)] Ensured Rust binary is executable" >> "$LOG_FILE"
else
    echo "[$(date)] ERROR: Rust binary not found at ./build/gameframe" >> "$LOG_FILE"
    exit 1
fi

# Detect display backend
if [ -n "$WAYLAND_DISPLAY" ]; then
    export DISPLAY_BACKEND="wayland"
    echo "[$(date)] Detected Wayland session" >> "$LOG_FILE"
elif [ -n "$DISPLAY" ]; then
    export DISPLAY_BACKEND="x11"
    echo "[$(date)] Detected X11 session" >> "$LOG_FILE"
else
    export DISPLAY_BACKEND="wayland"
    echo "[$(date)] No display detected, defaulting to Wayland with XWayland" >> "$LOG_FILE"
fi

# Set XWayland environment
if [[ "$DISPLAY_BACKEND" == "wayland" ]]; then
    export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
    if ! command -v Xwayland &> /dev/null; then
        echo "[$(date)] WARNING: Xwayland not found, X11 apps may not work" >> "$LOG_FILE"
    else
        echo "[$(date)] XWayland available for X11 compatibility" >> "$LOG_FILE"
    fi
fi

# Set wlroots and Gamescope dependencies
export PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/lib64/pkgconfig:/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig:$PKG_CONFIG_PATH
echo "[$(date)] Set wlroots and Gamescope library paths" >> "$LOG_FILE"
