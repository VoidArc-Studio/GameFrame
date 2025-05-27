#!/bin/bash

# Parsowanie argumentów
SCALING="FSR"
FPS="60"
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --scaling) SCALING="$2"; shift ;;
        --fps) FPS="$2"; shift ;;
    esac
    shift
done

# Uruchomienie GameFrame z vkBasalt, MangoHud, GameMode
MANGOHUD=1 ENABLE_VKBASALT=1 gamemoderun gameframe -W 1920 -H 1080 -r $FPS --scaling $SCALING -- steam
