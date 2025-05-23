#!/bin/bash

LOG_FILE="logs/gameframe.log"

# Ensure XDG_RUNTIME_DIR
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
mkdir -p "$XDG_RUNTIME_DIR"
chmod 0700 "$XDG_RUNTIME_DIR"
echo "[$(date)] Set XDG_RUNTIME_DIR: $XDG_RUNTIME_DIR" >> "$LOG_FILE"

# Check for wlroots and Xwayland
if ! pkg-config --exists wlroots; then
    echo "[$(date)] ERROR: wlroots not found" >> "$LOG_FILE"
    exit 1
fi
if ! command -v Xwayland &> /dev/null; then
    echo "[$(date)] ERROR: Xwayland not found" >> "$LOG_FILE"
    exit 1
fi
echo "[$(date)] wlroots and Xwayland detected" >> "$LOG_FILE"

# Start Xwayland
Xwayland :0 -retro -noreset > /dev/null 2>> "$LOG_FILE" &
XWAYLAND_PID=$!
sleep 1
if ! ps -p $XWAYLAND_PID > /dev/null; then
    echo "[$(date)] ERROR: Failed to start Xwayland" >> "$LOG_FILE"
    exit 1
fi
export DISPLAY=:0
echo "[$(date)] Started Xwayland on $DISPLAY" >> "$LOG_FILE"

# Set Wayland display
export WAYLAND_DISPLAY="wayland-0"
echo "[$(date)] Set WAYLAND_DISPLAY: $WAYLAND_DISPLAY" >> "$LOG_FILE"
