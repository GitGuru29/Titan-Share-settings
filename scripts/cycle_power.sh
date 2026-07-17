#!/usr/bin/env bash
# cycle_power.sh
# Cyclically switches the system power profile and triggers a D-Bus change
# which archtitan-settings will pick up automatically (if active).
# Sequence: Power Saver -> Balanced -> Performance -> Power Saver

# Detect active power profiles service
SERVICE="org.freedesktop.UPower.PowerProfiles"
OBJ_PATH="/org/freedesktop/UPower/PowerProfiles"
IFACE="org.freedesktop.UPower.PowerProfiles"

if ! busctl status $SERVICE >/dev/null 2>&1; then
    SERVICE="net.hadess.PowerProfiles"
    OBJ_PATH="/net/hadess/PowerProfiles"
    IFACE="net.hadess.PowerProfiles"
fi

# Read current profile via D-Bus directly
CURRENT=$(busctl get-property $SERVICE $OBJ_PATH $IFACE ActiveProfile | cut -d'"' -f2)

if [ "$CURRENT" = "power-saver" ]; then
    busctl set-property $SERVICE $OBJ_PATH $IFACE ActiveProfile s "balanced"
    notify-send -a "Power Manager" -i "power-profile-balanced" "Power Profile" "Switched to Balanced" -t 2000
elif [ "$CURRENT" = "balanced" ]; then
    busctl set-property $SERVICE $OBJ_PATH $IFACE ActiveProfile s "performance"
    notify-send -a "Power Manager" -i "power-profile-performance" "Power Profile" "Switched to Performance" -t 2000
else
    busctl set-property $SERVICE $OBJ_PATH $IFACE ActiveProfile s "power-saver"
    notify-send -a "Power Manager" -i "power-profile-power-saver" "Power Profile" "Switched to Power Saver" -t 2000
fi
