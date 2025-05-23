#!/bin/bash

# Source environment setup
source ./scripts/setup_env.sh

# Detect GPU
GPU_VENDOR=$(bash ./scripts/detect_gpu.sh)

# Set environment variables based on GPU
export GPU_VENDOR
export LD_LIBRARY_PATH=/usr/lib:$LD_LIBRARY_PATH

# Launch Rust binary with config
./build/gameframe --config ./config/gameframe.conf
