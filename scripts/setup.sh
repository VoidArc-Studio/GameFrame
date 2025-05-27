#!/bin/bash

# Sprawdzanie systemu
if ! command -v apt &> /dev/null; then
    echo "Ten skrypt działa tylko na systemach opartych na Debianie/Ubuntu."
    exit 1
fi

# Instalacja zależności
sudo apt update
sudo apt install -y build-essential git meson ninja-build libwayland-dev libvulkan-dev libx11-xcb-dev gamemoded mangohud vkbasalt systemd

# Instalacja Rust
if ! command -v cargo &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source $HOME/.cargo/env
fi

# Budowanie GameFrame
cd ..
cargo build --release
sudo cp target/release/gameframe /usr/local/bin/

# Kopiowanie konfiguracji
mkdir -p ~/.config/gameframe
cp config/* ~/.config/gameframe/

# Instalacja usługi systemd
sudo cp systemd/gameframe-tty.service /etc/systemd/system/
sudo systemctl enable gameframe-tty.service
