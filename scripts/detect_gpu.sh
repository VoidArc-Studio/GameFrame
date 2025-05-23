#!/bin/bash

# Detect GPU vendor using lspci
if lspci | grep -i nvidia > /dev/null; then
    echo "nvidia"
elif lspci | grep -i amd > /dev/null; then
    echo "amd"
elif lspci | grep -i intel > /dev/null; then
    echo "intel"
else
    echo "unknown"
fi
