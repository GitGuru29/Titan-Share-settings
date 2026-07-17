#!/usr/bin/env bash
# cycle_power.sh
# Cyclically switches the system power profile and triggers a D-Bus change
# which archtitan-settings will pick up automatically (if active).
# Sequence: Power Saver -> Balanced -> Performance -> Power Saver

# Read current profile via D-Bus directly, bypassing powerprofilesctl
CURRENT=$(busctl get-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile | cut -d'"' -f2)

if [ "$CURRENT" = "power-saver" ]; then
    busctl set-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile s "balanced"
    notify-send -a "Power Manager" -i "power-profile-balanced" "Power Profile" "Switched to Balanced" -t 2000
elif [ "$CURRENT" = "balanced" ]; then
    busctl set-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile s "performance"
    notify-send -a "Power Manager" -i "power-profile-performance" "Power Profile" "Switched to Performance" -t 2000
else
    busctl set-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile s "power-saver"
    notify-send -a "Power Manager" -i "power-profile-power-saver" "Power Profile" "Switched to Power Saver" -t 2000
fi
