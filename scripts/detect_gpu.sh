#!/bin/bash

LOG_FILE="logs/gameframe.log"

if ! command -v lspci &> /dev/null; then
    echo "[$(date)] ERROR: lspci not found" >> "$LOG_FILE"
    exit 1
fi

GPU_INFO=$(lspci | grep -iE 'VGA|3D')
if echo "$GPU_INFO" | grep -i nvidia > /dev/null; then
    VENDOR="nvidia"
    MODEL=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null || echo "Unknown NVIDIA GPU")
elif echo "$GPU_INFO" | grep -i amd > /dev/null; then
    VENDOR="amd"
    MODEL=$(lspci | grep -i amd | awk -F': ' '{print $2}' | head -n 1)
elif echo "$GPU_INFO" | grep -i intel > /dev/null; then
    VENDOR="intel"
    MODEL=$(lspci | grep -i intel | awk -F': ' '{print $2}' | head -n 1)
else
    VENDOR="unknown"
    MODEL="Unknown GPU"
fi

DRIVER_VERSION=""
if [ "$VENDOR" = "nvidia" ]; then
    DRIVER_VERSION=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null || echo "Unknown")
elif [ "$VENDOR" = "amd" ]; then
    DRIVER_VERSION=$(glxinfo | grep "OpenGL version" | awk '{print $4}' 2>/dev/null || echo "Unknown")
elif [ "$VENDOR" = "intel" ]; then
    DRIVER_VERSION=$(glxinfo | grep "OpenGL version" | awk '{print $4}' 2>/dev/null || echo "Unknown")
fi

VULKAN_VERSION=$(vulkaninfo --summary 2>/dev/null | grep 'apiVersion' | awk '{print $3}' || echo "Not supported")
OPENGL_VERSION=$(glxinfo | grep "OpenGL version" | awk '{print $4}' 2>/dev/null || echo "Not supported")

echo "{\"vendor\":\"$VENDOR\",\"model\":\"$MODEL\",\"driver_version\":\"$DRIVER_VERSION\",\"vulkan_version\":\"$VULKAN_VERSION\",\"opengl_version\":\"$OPENGL_VERSION\"}" >> "$LOG_FILE"
echo "{\"vendor\":\"$VENDOR\",\"model\":\"$MODEL\",\"driver_version\":\"$DRIVER_VERSION\",\"vulkan_version\":\"$VULKAN_VERSION\",\"opengl_version\":\"$OPENGL_VERSION\"}"
