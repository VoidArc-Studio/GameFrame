#!/bin/bash

# Tworzenie katalogu konfiguracyjnego
mkdir -p ~/.config/gameframe

# Konfiguracja vkBasalt
if [ -f /usr/share/vkBasalt/vkBasalt.conf.example ]; then
    cp /usr/share/vkBasalt/vkBasalt.conf.example ~/.config/gameframe/vkbasalt.conf
    sed -i 's/#casSharpness = 0.5/casSharpness = 0.7/' ~/.config/gameframe/vkbasalt.conf
fi

# Konfiguracja MangoHud
cat <<EOL > ~/.config/gameframe/mangohud.conf
fps
cpu_stats
gpu_stats
position=top-left
font_size=24
EOL

# Konfiguracja GameFrame
cat <<EOL > ~/.config/gameframe/gameframe.conf
default_resolution=1920x1080
default_quality=4k
default_options=++
EOL
