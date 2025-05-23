#!/bin/bash

# Ensure logs directory exists
mkdir -p logs
LOG_FILE="logs/gameframe.log"
echo "[$(date)] Starting GameFrame launch" >> "$LOG_FILE"

# Default configuration
BACKEND="vulkan"
RESOLUTION="1920x1080"
REFRESH_RATE="60"
ENVIRONMENT=""
SCALING_MODE="bilinear"
HDR="false"
DISPLAY_BACKEND="wayland"
VSYNC="true"
MAX_FPS="144"
FILTER="bilinear"
GPU_VENDOR="auto"
OPENGL_VERSION="2.1"
VULKAN_VERSION="1.3"

# Parse CLI arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -opengl)
            BACKEND="opengl"
            shift
            ;;
        -vulkan)
            BACKEND="vulkan"
            shift
            ;;
        -steam)
            ENVIRONMENT="steam-gamepadui"
            shift
            if [[ "$1" == "gamepadui" ]]; then
                shift
            fi
            ;;
        -gnome|-kde|-heroic|-lutris)
            ENVIRONMENT="${1#-}"
            shift
            ;;
        [0-9]*x[0-9]*)
            RESOLUTION="$1"
            shift
            ;;
        *)
            echo "[$(date)] ERROR: Unknown argument: $1" >> "$LOG_FILE"
            echo "Usage: gameframe [-opengl|-vulkan] <resolution> [-steam [gamepadui]|-gnome|-kde|-heroic|-lutris]"
            exit 1
            ;;
    esac
done

# Validate inputs
if [[ -z "$ENVIRONMENT" ]]; then
    echo "[$(date)] ERROR: No environment specified" >> "$LOG_FILE"
    echo "Please specify an environment (e.g., -steam, -gnome)"
    exit 1
fi

# Auto-detect if not specified
if [[ "$RESOLUTION" == "1920x1080" ]]; then
    RESOLUTION_INFO=$(bash ./scripts/detect_resolutions.sh 2>/dev/null | jq -r '.resolutions[0]')
    if [[ -n "$RESOLUTION_INFO" ]]; then
        RESOLUTION="$RESOLUTION_INFO"
        echo "[$(date)] Auto-detected resolution: $RESOLUTION" >> "$LOG_FILE"
    fi
fi
if [[ "$REFRESH_RATE" == "60" ]]; then
    REFRESH_RATE_INFO=$(bash ./scripts/detect_resolutions.sh 2>/dev/null | jq -r '.refresh_rates[0]')
    if [[ -n "$REFRESH_RATE_INFO" ]]; then
        REFRESH_RATE="$REFRESH_RATE_INFO"
        echo "[$(date)] Auto-detected refresh rate: $REFRESH_RATE Hz" >> "$LOG_FILE"
    fi
fi

# Source environment setup
source ./scripts/setup_env.sh >> "$LOG_FILE" 2>&1
if [ $? -ne 0 ]; then
    echo "[$(date)] ERROR: Failed to set up environment" >> "$LOG_FILE"
    exit 1
fi

# Check dependencies
bash ./scripts/check_deps.sh >> "$LOG_FILE" 2>&1
if [ $? -ne 0 ]; then
    echo "[$(date)] ERROR: Dependency check failed" >> "$LOG_FILE"
    exit 1
fi

# Detect GPU
GPU_INFO=$(bash ./scripts/detect_gpu.sh)
GPU_VENDOR=$(echo "$GPU_INFO" | jq -r '.vendor')
if [ -z "$GPU_VENDOR" ]; then
    echo "[$(date)] ERROR: Failed to detect GPU" >> "$LOG_FILE"
    exit 1
fi
echo "[$(date)] Detected GPU: $GPU_VENDOR" >> "$LOG_FILE"

# Adjust for older GPUs
if [[ "$GPU_VENDOR" == "nvidia" ]]; then
    VULKAN_VERSION=$(echo "$GPU_INFO" | jq -r '.vulkan_version')
    if [[ "$VULKAN_VERSION" < "1.2" ]]; then
        BACKEND="opengl"
        echo "[$(date)] Falling back to OpenGL for older NVIDIA GPU" >> "$LOG_FILE"
    fi
elif [[ "$GPU_VENDOR" == "intel" ]]; then
    BACKEND="opengl"
    OPENGL_VERSION="4.5"
    echo "[$(date)] Using OpenGL for Intel GPU" >> "$LOG_FILE"
fi

# Generate configuration
CONFIG_FILE="config/gameframe.conf"
cat > "$CONFIG_FILE" << EOF
[General]
environment=$ENVIRONMENT
resolution=$RESOLUTION
fullscreen=true
refresh_rate=$REFRESH_RATE
scaling_mode=$SCALING_MODE
hdr=$HDR
display_backend=$DISPLAY_BACKEND

[Rendering]
backend=$BACKEND
vsync=$VSYNC
max_fps=$MAX_FPS
filter=$FILTER

[GPU]
vendor=$GPU_VENDOR
opengl_version=$OPENGL_VERSION
vulkan_version=$VULKAN_VERSION
EOF
echo "[$(date)] Generated configuration: $CONFIG_FILE" >> "$LOG_FILE"

# Run in TTY with isolation
if [[ -z "$DISPLAY" && -z "$WAYLAND_DISPLAY" ]]; then
    echo "[$(date)] Running in TTY mode" >> "$LOG_FILE"
    bash ./scripts/setup_xwayland.sh >> "$LOG_FILE" 2>&1
    if [ $? -ne 0 ]; then
        echo "[$(date)] ERROR: Failed to set up XWayland" >> "$LOG_FILE"
        exit 1
    fi
    DISPLAY_BACKEND="wayland"
    export WAYLAND_DISPLAY="wayland-0"
fi

# Isolate with unshare (network, mount, and PID namespaces)
if command -v unshare &> /dev/null; then
    echo "[$(date)] Running GameFrame in isolated namespace" >> "$LOG_FILE"
    unshare -nmupf --mount-proc bash -c "
        export LD_LIBRARY_PATH=/usr/lib:/usr/local/lib:\$LD_LIBRARY_PATH
        export WAYLAND_DISPLAY=$WAYLAND_DISPLAY
        export DISPLAY=$DISPLAY
        ./build/gameframe --config $CONFIG_FILE >> $LOG_FILE 2>&1
    "
else
    echo "[$(date)] WARNING: unshare not found, running without isolation" >> "$LOG_FILE"
    ./build/gameframe --config "$CONFIG_FILE" >> "$LOG_FILE" 2>&1
fi

if [ $? -ne 0 ]; then
    echo "[$(date)] ERROR: Failed to launch GameFrame" >> "$LOG_FILE"
    exit 1
fi

echo "[$(date)] GameFrame launched successfully" >> "$LOG_FILE"
