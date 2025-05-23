#!/bin/bash

# Set up Vulkan and OpenGL libraries
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json:/usr/share/vulkan/icd.d/radeon_icd.json:/usr/share/vulkan/icd.d/intel_icd.json
export LIBGL_DRIVERS_PATH=/usr/lib/dri
