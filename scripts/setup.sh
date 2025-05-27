#!/bin/bash

# Instalacja zależności (Linux)
sudo apt update
sudo apt install -y build-essential git meson ninja-build libwayland-dev libvulkan-dev libx11-xcb-dev gamemoded mangohud vkbasalt

# Instalacja Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Klonowanie i budowanie GameFrame
cd ..
git clone https://github.com/your-repo/gameframe.git
cd gameframe
cargo build --release
sudo cp target/release/gameframe /usr/local/bin/
