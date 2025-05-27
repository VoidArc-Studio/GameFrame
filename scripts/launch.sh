#!/bin/bash

# Domyślne wartości
RESOLUTION="1920x1080"
QUALITY="4k"
OPTIONS=""
APP="steam -gamepadui"

# Parsowanie argumentów
while [[ "$#" -gt 0 ]]; do
    case $1 in
        [0-9]*x[0-9]*) RESOLUTION="$1" ;;
        4k|high|low) QUALITY="$1" ;;
        ++) OPTIONS="++" ;;
        +vk|+hud|+gm) OPTIONS="$OPTIONS $1" ;;
        *) APP="$*" ; break ;;
    esac
    shift
done

# Walidacja rozdzielczości
if ! [[ $RESOLUTION =~ ^[0-9]+x[0-9]+$ ]]; then
    echo "Błędny format rozdzielczości. Oczekiwano WxH, np. 1920x1080"
    exit 1
fi

# Ustawienie zmiennych środowiskowych
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export WAYLAND_DISPLAY=wayland-0
if [[ $OPTIONS == *"++"* || $OPTIONS == *"+vk"* ]]; then
    export ENABLE_VKBASALT=1
    export VKBASALT_CONFIG_FILE=~/.config/gameframe/vkbasalt.conf
fi
if [[ $OPTIONS == *"++"* || $OPTIONS == *"+hud"* ]]; then
    export MANGOHUD=1
    export MANGOHUD_CONFIG_FILE=~/.config/gameframe/mangohud.conf
fi

# Uruchomienie GameFrame
if [[ $OPTIONS == *"++"* || $OPTIONS == *"+gm"* ]]; then
    gamemoderun gameframe $RESOLUTION $QUALITY "$OPTIONS" "$APP"
else
    gameframe $RESOLUTION $QUALITY "$OPTIONS" "$APP"
fi
