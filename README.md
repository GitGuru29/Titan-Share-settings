# ArchTitan Settings

A native Qt6/QML settings application for **ArchTitan OS** — a custom Arch Linux distribution with a Hyprland desktop environment.

## Features

| Page | Description |
|---|---|
| 🎨 **Appearance** | Theme selector, accent colors, glassmorphism toggle, panel opacity, icon themes, font size |
| 🖥 **Display** | Brightness, Night Light (wlsunset), resolution info, display scale factor |
| 📶 **Network** | Wi-Fi toggle, scan & connect to networks, connection details (nmcli) |
| 🔊 **Audio** | Output & microphone volume, mute controls, animated EQ visualizer (PipeWire/wpctl) |
| ⚡ **Power** | Power Saver / Balanced / Performance profiles, screen/suspend timeouts, live battery meter |
| 🔒 **Security** | Screen autolock, Titan Sandbox status, firewall status, quick lock action |
| ⚙ **System** | Live CPU/RAM/Disk meters (from /proc), hardware info, Titan service status |
| ◆ **About** | OS version, kernel, Qt version, credits |

## Tech Stack

- **Qt6** (6.11+) with **QML / Qt Quick Controls 2**
- **C++17** backend for system integration
- **D-Bus** for system service interaction
- **PipeWire** (`wpctl`) for audio
- **NetworkManager** (`nmcli`) for WiFi
- **Hyprland** (`hyprctl`) for display/scale
- **swww** for wallpaper management
- **brightnessctl** / **wlsunset** for display controls

## Building

```bash
chmod +x build.sh
./build.sh
```

**Requirements:** `qt6-base`, `qt6-declarative`, `qt6-quickcontrols2`, `cmake`, `ninja`/`make`

```bash
# Arch / ArchTitan:
sudo pacman -S qt6-base qt6-declarative qt6-quickcontrols2 cmake
```

## Directory Structure

```
archtitan-settings/
├── CMakeLists.txt          # Build configuration
├── build.sh                # Quick build script
├── src/
│   ├── main.cpp            # Entry point
│   ├── settingsbackend.*   # Persistent settings (QSettings)
│   ├── systeminfo.*        # /proc reader — CPU, RAM, disk, battery
│   ├── networkmanager.*    # nmcli Wi-Fi wrapper
│   ├── displaymanager.*    # Brightness, night light, scale
│   ├── audiobackend.*      # wpctl PipeWire wrapper
│   └── wallpapermanager.*  # swww wallpaper switcher
├── qml/
│   ├── Main.qml            # Root window (frameless, dark)
│   ├── components/         # Reusable UI components
│   │   ├── SidebarItem.qml
│   │   ├── SettingsCard.qml
│   │   ├── TitanSwitch.qml
│   │   ├── TitanSlider.qml
│   │   ├── TitanButton.qml
│   │   ├── SectionHeader.qml
│   │   └── StatusBadge.qml
│   └── pages/              # Settings pages
│       ├── AppearancePage.qml
│       ├── DisplayPage.qml
│       ├── NetworkPage.qml
│       ├── AudioPage.qml
│       ├── PowerPage.qml
│       ├── SecurityPage.qml
│       ├── SystemPage.qml
│       └── AboutPage.qml
└── assets/icons/           # SVG icons
```

## Status

> ⚠ Work in progress — not yet integrated into the main ISO build. This folder is excluded from the `custom-os-build` repo via `.gitignore`.

---

*ArchTitan OS — Final Year Project*
