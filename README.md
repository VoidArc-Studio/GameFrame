GameFrame: A High-Performance Gaming Compositor for Linux
GameFrame is a modern, lightweight compositor designed to enhance gaming performance on Linux, surpassing tools like Gamescope. It supports Wayland with XWayland, optimizes for older GPUs (e.g., NVIDIA GTX 1060, Intel UHD Graphics), and provides system isolation, telemetry, and a flexible configuration system. GameFrame integrates C++ (rendering), Rust (core logic), Python (configuration and TTY UI), JavaScript (GUI), and Bash (system detection) for a robust gaming experience in environments like Steam Gamepad UI.
This guide provides step-by-step instructions for compiling, running, and integrating GameFrame with Wayland sessions on Ubuntu, Fedora, Fedora Silverblue, openSUSE, Arch Linux, and other Linux distributions. It’s written for beginners, with detailed explanations and troubleshooting tips.

Table of Contents

Prerequisites
Directory Structure
Installation Instructions by Distribution
Ubuntu
Fedora
Fedora Silverblue
openSUSE
Arch Linux
Other Distributions


Compiling GameFrame
Running GameFrame
Adding GameFrame to Wayland Sessions
Troubleshooting
Contributing
License


Prerequisites
Before starting, ensure your system meets these requirements:

Hardware:
CPU: Any modern x86_64 processor (e.g., Intel i3 or AMD Ryzen).
GPU: Supports Vulkan (preferred) or OpenGL 2.1+ (e.g., NVIDIA GTX 1060, Intel UHD Graphics).
RAM: Minimum 4 GB (8 GB recommended for gaming).
Disk Space: ~2 GB for dependencies and build artifacts.


Software:
Linux kernel 5.15+ for Wayland and namespace support.
A Wayland-compatible desktop environment (e.g., GNOME, KDE Plasma, Sway).
XWayland for running X11 applications (e.g., Steam).


Network: Internet access for downloading dependencies.

Common Dependencies
Install these tools and libraries on all distributions:

Build Tools: cmake, make, gcc, g++, git.
Rust: rustup or distribution-specific Rust package.
Python: Python 3.8+ with pip.
Node.js: For the JavaScript GUI (Node.js 16+ and npm).
Libraries:
Wayland: libwayland-dev, wayland-protocols.
Vulkan/OpenGL: libvulkan-dev, mesa-vulkan-drivers, libgl1-mesa-dev.
X11/XWayland: libx11-dev, xorg-xwayland.
Others: jq, libxrandr-dev, libxkbcommon-dev, libinput-dev, libudev-dev.


Optional:
firejail for stricter isolation (used by isolation.py).
inquirer for Python TTY UI (pip install inquirer).



Specific installation commands are provided per distribution below.

Directory Structure
Here’s the GameFrame project structure for reference:
GameFrame/
├── src/
│   ├── cpp/                # C++ rendering (compositor, Vulkan/OpenGL)
│   │   ├── frame_timer.hpp
│   │   ├── compositor.hpp
│   │   ├── vulkan_renderer.hpp
│   │   ├── opengl_renderer.hpp
│   │   ├── wayland_backend.hpp
│   ├── rust/               # Rust core logic
│   │   ├── main.rs
│   │   ├── cli.rs
│   │   ├── system.rs
│   │   ├── isolation.rs
│   │   ├── telemetry.rs
│   │   ├── config.rs
│   ├── python/             # Python configuration and TTY UI
│   │   ├── config_parser.py
│   │   ├── system_info.py
│   │   ├── telemetry.py
│   │   ├── tty_ui.py
│   │   ├── isolation.py
│   ├── js/                # JavaScript GUI (Electron)
│   │   ├── index.html
│   │   ├── main.js
│   │   ├── renderer.js
│   │   ├── config_manager.js
│   ├── scripts/            # Bash scripts for setup and detection
│   │   ├── launch.sh
│   │   ├── setup_env.sh
│   │   ├── check_deps.sh
│   │   ├── detect_gpu.sh
│   │   ├── detect_resolutions.sh
├── config/                # Configuration files
│   ├── gameframe.conf
│   ├── profiles/
├── logs/                  # Log files
│   └── gameframe.log
├── CMakeLists.txt         # C++ build configuration
├── Cargo.toml             # Rust build configuration
├── package.json           # JavaScript dependencies
├── README.md              # This file
├── LICENSE


Installation Instructions by Distribution
Ubuntu
Tested on Ubuntu 22.04 LTS and 24.04 LTS.

Update System:
sudo apt update && sudo apt upgrade -y


Install Dependencies:
sudo apt install -y build-essential cmake make gcc g++ git python3 python3-pip nodejs npm \
libwayland-dev wayland-protocols libvulkan-dev mesa-vulkan-drivers libgl1-mesa-dev \
libx11-dev xorg-dev libxrandr-dev libxkbcommon-dev libinput-dev libudev-dev jq firejail


Install Rust:
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env


Install Python TTY UI Dependency:
pip3 install inquirer


Clone GameFrame Repository:
git clone https://github.com/VoidArc-Studio/GameFrame.git
cd GameFrame


Install Node.js Dependencies:
cd src/js
npm install
cd ../..


Verify Dependencies:
bash scripts/check_deps.sh

If errors occur, install missing packages listed in the output.


Fedora
Tested on Fedora 40 Workstation.

Update System:
sudo dnf update -y


Install Dependencies:
sudo dnf install -y gcc gcc-c++ make cmake git python3 python3-pip nodejs npm \
wayland-devel wayland-protocols-devel libvulkan-devel mesa-vulkan-drivers \
libglvnd-devel libX11-devel xorg-x11-server-Xwayland-devel libXrandr-devel \
libxkbcommon-devel libinput-devel libudev-devel jq firejail


Install Rust:
sudo dnf install -y rust cargo


Install Python TTY UI Dependency:
pip3 install inquirer


Clone GameFrame Repository:
git clone https://github.com/VoidArc-Studio/GameFrame.git
cd GameFrame


Install Node.js Dependencies:
cd src/js
npm install
cd ../..


Verify Dependencies:
bash scripts/check_deps.sh



Fedora Silverblue
Fedora Silverblue is immutable, so we use rpm-ostree for system packages and containers for development tools.

Update System:
rpm-ostree upgrade


Install Dependencies:
rpm-ostree install -y gcc gcc-c++ make cmake git python3 python3-pip nodejs npm \
wayland-devel wayland-protocols-devel vulkan-devel mesa-vulkan-drivers \
libglvnd-devel libX11-devel xorg-x11-server-Xwayland-devel libXrandr-devel \
libxkbcommon-devel libinput-devel systemd-devel jq firejail


Reboot:
systemctl reboot


Install Rust in a Container:
toolbox create
toolbox enter
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
exit


Install Python TTY UI Dependency:
pip3 install inquirer --user


Clone GameFrame Repository:
git clone https://github.com/VoidArc-Studio/GameFrame.git
cd GameFrame


Install Node.js Dependencies:
cd src/js
npm install
cd ../..


Verify Dependencies:
bash scripts/check_deps.sh



openSUSE
Tested on openSUSE Tumbleweed.

Update System:
sudo zypper refresh
sudo zypper update -y


Install Dependencies:
sudo zypper install -y gcc gcc-c++ make cmake git python3 python3-pip nodejs \
libwayland-client0 libwayland-server0 wayland-protocols-devel libvulkan1 \
Mesa-libVulkan1 Mesa-libGL1 libX11-devel xorg-x11-server libXrandr-devel \
libxkbcommon-devel libinput-devel libudev-devel jq firejail


Install Rust:
sudo zypper install -y rust cargo


Install Python TTY UI Dependency:
pip3 install inquirer


Clone GameFrame Repository:
git clone https://github.com/VoidArc-Studio/GameFrame.git
cd GameFrame


Install Node.js Dependencies:
cd src/js
npm install
cd ../..


Verify Dependencies:
bash scripts/check_deps.sh



Arch Linux
Tested on Arch Linux (rolling release).

Update System:
sudo pacman -Syu


Install Dependencies:
sudo pacman -S base-devel cmake make gcc git python python-pip nodejs npm \
wayland wayland-protocols vulkan-headers vulkan-tools mesa libglvnd \
libx11 xorg-xwayland libxrandr libxkbcommon libinput systemd-libs jq firejail


Install Rust:
sudo pacman -S rust


Install Python TTY UI Dependency:
pip install inquirer


Clone GameFrame Repository:
git clone https://github.com/VoidArc-Studio/GameFrame.git
cd GameFrame


Install Node.js Dependencies:
cd src/js
npm install
cd ../..


Verify Dependencies:
bash scripts/check_deps.sh



Other Distributions
For distributions like Debian, Manjaro, or Pop!_OS, adapt the package names to your package manager (apt, pacman, etc.). The core dependencies are:

Build Tools: cmake, make, gcc, g++, git.
Languages: python3, nodejs, rust (via rustup if not in repos).
Libraries: libwayland, wayland-protocols, libvulkan, mesa, libx11, xwayland, libxrandr, libxkbcommon, libinput, libudev, jq.
Optional: firejail.

Steps:

Update your system (e.g., sudo apt update && sudo apt upgrade for Debian-based).
Install dependencies using your package manager.
Install Rust via rustup:curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env


Install Python inquirer:pip3 install inquirer


Clone the repository and install Node.js dependencies as above.
Run bash scripts/check_deps.sh to verify.

If your distribution lacks a package, search its repository or install from source (e.g., for wayland-protocols).

Compiling GameFrame

Navigate to Project Directory:
cd GameFrame


Setup Environment:Run the setup script to configure paths and check dependencies:
bash scripts/setup_env.sh


Compile C++ Components:
mkdir build
cd build
cmake ..
make -j$(nproc)
sudo make install
cd ..

This builds and installs the C++ compositor, renderers, and Wayland backend.

Compile Rust Components:
cargo build --release --features wayland

This builds the Rust binary, including CLI, isolation, and telemetry.

Verify Build:Ensure the binary exists:
ls target/release/gameframe


Test Python Components:
python3 src/python/config_parser.py

This should output the default gameframe.conf in JSON format.

Test JavaScript GUI:
cd src/js
npm start

This launches the Electron GUI. Close it after testing.



Running GameFrame
GameFrame can be run in three modes: CLI, TTY UI, or GUI.
CLI Mode
Run GameFrame with specific options (e.g., OpenGL, 1920x1080, Steam Gamepad UI):
bash scripts/launch.sh -opengl 1920x1080 -steam


Options:
-opengl or -vulkan: Rendering backend.
1920x1080: Resolution (supports 1280x720, 2560x1440, 3840x2160).
-steam: Environment (also supports gnome, kde, heroic, lutris).



TTY UI Mode
Interactive text-based interface for TTY:
python3 src/python/tty_ui.py


Select options (e.g., backend, resolution) using arrow keys.
Choose “Launch” to start GameFrame.
Logs are saved to logs/gameframe.log.

GUI Mode
Graphical interface via Electron:
cd src/js
npm start


Configure settings in the GUI.
Click “Launch” to start GameFrame.

Configuration
GameFrame uses config/gameframe.conf (JSON format). Edit manually or use the TTY UI/GUI. Example:
{
  "environment": "steam-gamepadui",
  "resolution": "1920x1080",
  "fullscreen": true,
  "refresh_rate": 60,
  "scaling_mode": "bilinear",
  "hdr": false,
  "display_backend": "wayland",
  "rendering": {
    "backend": "vulkan",
    "vsync": true,
    "max_fps": 144,
    "filter": "bilinear"
  },
  "gpu": {
    "vendor": "nvidia",
    "opengl_version": "4.6",
    "vulkan_version": "1.2"
  }
}


Adding GameFrame to Wayland Sessions
To integrate GameFrame as a Wayland session, create a .desktop file for your display manager (e.g., GDM, SDDM). This allows GameFrame to appear in the session menu at login.
Steps for All Distributions

Create Wayland Session File:
sudo mkdir -p /usr/share/wayland-sessions
sudo nano /usr/share/wayland-sessions/gameframe.desktop

Add the following content:
[Desktop Entry]
Name=GameFrame
Comment=A high-performance gaming compositor
Exec=/usr/local/bin/gameframe --wayland
Type=Application
DesktopNames=GameFrame

Save and exit.

Ensure GameFrame Binary is Installed:The sudo make install step during compilation installs the Rust binary to /usr/local/bin/gameframe. Verify:
ls /usr/local/bin/gameframe


Set Permissions:
sudo chmod 755 /usr/share/wayland-sessions/gameframe.desktop


Verify Display Manager:

GDM (GNOME, Ubuntu, Fedora): Supports Wayland sessions by default.
SDDM (KDE, openSUSE): Ensure Wayland is enabled:sudo nano /etc/sddm.conf.d/wayland.conf

Add:[General]
DisplayServer=wayland


Other Display Managers: Check documentation (e.g., LightDM may require additional configuration).


Reboot:
sudo systemctl reboot


Select GameFrame Session:

At the login screen, click the gear icon (GDM) or session menu (SDDM).
Choose “GameFrame” and log in.
GameFrame launches with default settings (gameframe.conf).



Distribution-Specific Notes

Ubuntu (GDM):

GDM supports Wayland by default since Ubuntu 21.04.
If Wayland is disabled, enable it:sudo nano /etc/gdm3/custom.conf

Uncomment or add:WaylandEnable=true

Restart GDM:sudo systemctl restart gdm




Fedora (GDM):

Wayland is default for GNOME. No changes needed.
For KDE, install plasma-workspace-wayland:sudo dnf install plasma-workspace-wayland




Fedora Silverblue:

Same as Fedora, but use rpm-ostree for package installation.
Rebase to a Wayland-enabled image if issues occur (e.g., ublue-os/bazzite).


openSUSE (SDDM):

SDDM defaults to X11 in some configurations. Ensure Wayland is enabled as above.
Install plasma5-workspace-wayland for KDE Wayland support:sudo zypper install plasma5-workspace-wayland




Arch Linux:

Supports GDM, SDDM, or lightweight compositors like Sway.
For Sway, add GameFrame to ~/.config/sway/config:exec /usr/local/bin/gameframe --wayland




Other Distributions:

Check your display manager’s Wayland support.
Install wayland-protocols and xorg-xwayland if not already present.



XWayland Integration
GameFrame uses XWayland for X11 applications (e.g., Steam). Ensure XWayland is installed:

Ubuntu: xorg-xwayland
Fedora: xorg-x11-server-Xwayland
openSUSE: xorg-x11-server
Arch: xorg-xwayland

Verify XWayland:
XDG_SESSION_TYPE=wayland gameframe --wayland

Steam should launch in XWayland mode.

Troubleshooting
Compilation Errors

Missing Dependencies:
Run bash scripts/check_deps.sh to identify missing packages.
Install them using your package manager (e.g., sudo apt install libvulkan-dev).


CMake Errors:
Ensure cmake is version 3.16+ (cmake --version).
Delete build/ and retry: rm -rf build && mkdir build && cd build && cmake ...


Rust Errors:
Update Rust: rustup update.
Check Cargo.toml for version conflicts.



Runtime Errors

Wayland Not Starting:
Verify WAYLAND_DISPLAY is set: echo $WAYLAND_DISPLAY.
Switch to X11 temporarily: bash scripts/launch.sh -x11.


GPU Issues:
For NVIDIA, install proprietary drivers:
Ubuntu: sudo ubuntu-drivers autoinstall
Fedora: sudo dnf install akmod-nvidia
Arch: sudo pacman -S nvidia nvidia-utils


For Intel, ensure mesa is updated.


Steam Not Launching:
Ensure steam is installed and updated.
Check logs: cat logs/gameframe.log.



Wayland Session Issues

GameFrame Not in Session Menu:
Verify /usr/share/wayland-sessions/gameframe.desktop exists and is readable.
Restart display manager:sudo systemctl restart gdm  # or sddm




Artifacts in Games:
Switch to OpenGL: bash scripts/launch.sh -opengl.
Update GPU drivers.
Test in X11 mode: bash scripts/launch.sh -x11.



Logs

Check logs/gameframe.log for errors.
Enable verbose logging:export RUST_LOG=debug
bash scripts/launch.sh




Contributing

Fork the repository.
Create a branch: git checkout -b feature/your-feature.
Commit changes: git commit -m "Add your feature".
Push to your fork: git push origin feature/your-feature.
Open a pull request.

Report issues on the GitHub Issues page.

License
GameFrame is licensed under the MIT License. See LICENSE for details.
