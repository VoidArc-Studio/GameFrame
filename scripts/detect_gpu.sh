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
    DRIVER_VERSION=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null || echo "Unknown")
    VULKAN_VERSION=$(vulkaninfo --summary 2>/dev/null | grep 'apiVersion' | awk '{print $3}' || echo "1.0")
    OPENGL_VERSION=$(glxinfo 2>/dev/null | grep "OpenGL version" | awk '{print $4}' || echo "4.6")
elif echo "$GPU_INFO" | grep -i amd > /dev/null; then
    VENDOR="amd"
    MODEL=$(lspci | grep -i amd | awk -F': ' '{print $2}' | head -n 1)
    DRIVER_VERSION=$(glxinfo 2>/dev/null | grep "OpenGL version" | awk '{print $4}' || echo "Unknown")
    VULKAN_VERSION=$(vulkaninfo --summary 2>/dev/null | grep 'apiVersion' | awk '{print $3}' || echo "1.2")
    OPENGL_VERSION=$(glxinfo 2>/dev/null | grep "OpenGL version" | awk '{print $4}' || echo "4.5")
elif echo "$GPU_INFO" | grep -i intel > /dev/null; then
    VENDOR="intel"
    MODEL=$(lspci | grep -i intel | awk -F': ' '{print $2}' | head -n 1)
    DRIVER_VERSION=$(glxinfo 2>/dev/null | grep "OpenGL version" | awk '{print $4}' || echo "Unknown")
    VULKAN_VERSION=$(vulkaninfo --summary 2>/dev/null | grep 'apiVersion' | awk '{print $3}' || echo "1.0")
    OPENGL_VERSION=$(glxinfo 2>/dev/null | grep "OpenGL version" | awk '{print $4}' || echo "4.5")
else
    VENDOR="unknown"
    MODEL="Unknown GPU"
    DRIVER_VERSION="Unknown"
    VULKAN_VERSION="1.0"
    OPENGL_VERSION="2.1"
fi

echo "{\"vendor\":\"$VENDOR\",\"model\":\"$MODEL\",\"driver_version\":\"$DRIVER_VERSION\",\"vulkan_version\":\"$VULKAN_VERSION\",\"opengl_version\":\"$OPENGL_VERSION\"}" >> "$LOG_FILE"
echo "{\"vendor\":\"$VENDOR\",\"model\":\"$MODEL\",\"driver_version\":\"$DRIVER_VERSION\",\"vulkan_version\":\"$VULKAN_VERSION\",\"opengl_version\":\"$OPENGL_VERSION\"}"
