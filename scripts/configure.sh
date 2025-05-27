#!/bin/bash

# Konfiguracja vkBasalt
mkdir -p ~/.config/vkBasalt
cp /usr/share/vkBasalt/vkBasalt.conf.example ~/.config/vkBasalt/vkBasalt.conf

# Konfiguracja MangoHud
mkdir -p ~/.config/MangoHud
cat <<EOL > ~/.config/MangoHud/MangoHud.conf
fps
cpu_stats
gpu_stats
position=top-left
EOL
