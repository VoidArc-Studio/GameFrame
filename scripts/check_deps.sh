#!/bin/bash

LOG_FILE="logs/gameframe.log"

# Detect package manager
if command -v apt-get &> /dev/null; then
    PKG_MANAGER="apt"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
elif command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
else
    echo "[$(date)] ERROR: No supported package manager found (apt, dnf, pacman)" >> "$LOG_FILE"
    exit 1
fi
echo "[$(date)] Detected package manager: $PKG_MANAGER" >> "$LOG_FILE"

# Core dependencies
DEPENDENCIES=("vulkaninfo" "glxinfo" "python3" "cargo" "npm" "lspci" "jq" "xrandr" "pkg-config" "Xwayland")
for cmd in "${DEPENDENCIES[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "[$(date)] WARNING: Missing dependency: $cmd" >> "$LOG_FILE"
        if [[ "$cmd" == "Xwayland" ]]; then
            echo "[$(date)] XWayland not found, X11 apps may not work" >> "$LOG_FILE"
        else
            echo "[$(date)] ERROR: Required dependency $cmd missing" >> "$LOG_FILE"
            exit 1
        fi
    fi
    echo "[$(date)] Found dependency: $cmd" >> "$LOG_FILE"
done

# Check Vulkan drivers
VULKAN_DRIVERS=("/usr/share/vulkan/icd.d/nvidia_icd.json" "/usr/share/vulkan/icd.d/radeon_icd.json" "/usr/share/vulkan/icd.d/intel_icd.json")
VULKAN_FOUND=false
for driver in "${VULKAN_DRIVERS[@]}"; do
    if [ -f "$driver" ]; then
        VULKAN_FOUND=true
        echo "[$(date)] Found Vulkan driver: $driver" >> "$LOG_FILE"
    fi
done
if ! $VULKAN_FOUND; then
    echo "[$(date)] WARNING: No Vulkan drivers found, falling back to OpenGL" >> "$LOG_FILE"
fi

# Check OpenGL drivers
if [ -d "/usr/lib/dri" ] || [ -d "/usr/lib64/dri" ]; then
    echo "[$(date)] OpenGL drivers detected" >> "$LOG_FILE"
else
    echo "[$(date)] ERROR: No OpenGL drivers found" >> "$LOG_FILE"
    exit 1
fi

# Check wlroots
if ! pkg-config --exists wlroots; then
    echo "[$(date)] ERROR: wlroots not found" >> "$LOG_FILE"
    exit 1
fi
echo "[$(date)] wlroots detected" >> "$LOG_FILE"

# Check Gamescope dependencies
for lib in libdrm libliftoff libinput; do
    if ! pkg-config --exists "$lib"; then
        echo "[$(date)] ERROR: $lib not found" >> "$LOG_FILE"
        exit 1
    fi
    echo "[$(date)] $lib detected" >> "$LOG_FILE"
done

echo "[$(date)] All critical dependencies satisfied" >> "$LOG_FILE"
