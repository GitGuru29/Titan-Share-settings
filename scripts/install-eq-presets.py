#!/usr/bin/env python3
import json
import os

PRESETS_DIR = os.path.expanduser("~/.config/easyeffects/output")
os.makedirs(PRESETS_DIR, exist_ok=True)

def generate_preset(name, bands):
    # bands is a list of tuples: (frequency, gain)
    left = {}
    right = {}
    for i, (freq, gain) in enumerate(bands):
        band = {
            "frequency": freq,
            "gain": gain,
            "mode": "RLC (BT)",
            "muting": False,
            "q": 1.0,
            "type": "Bell",
            "width": 4.0
        }
        left[f"band{i}"] = band
        right[f"band{i}"] = band

    preset = {
        "output": {
            "equalizer#0": {
                "balance": 0.0,
                "bypass": False,
                "input-gain": 0.0,
                "left": left,
                "right": right,
                "num-bands": len(bands),
                "pitch-left": 0.0,
                "pitch-right": 0.0,
                "split-channels": False
            },
            "plugins_order": [
                "equalizer#0"
            ]
        }
    }
    
    with open(os.path.join(PRESETS_DIR, f"{name}.json"), "w") as f:
        json.dump(preset, f, indent=4)
    print(f"Generated {name}.json")

# Bass Boost
generate_preset("Bass Boost", [
    (32.0, 6.0), (64.0, 4.0), (125.0, 2.0), 
    (250.0, 0.0), (500.0, 0.0), (1000.0, 0.0), 
    (2000.0, 0.0), (4000.0, 0.0), (8000.0, 0.0), (16000.0, 0.0)
])

# Vocal
generate_preset("Vocal", [
    (32.0, -2.0), (64.0, -2.0), (125.0, 0.0), 
    (250.0, 2.0), (500.0, 4.0), (1000.0, 4.0), 
    (2000.0, 4.0), (4000.0, 2.0), (8000.0, 0.0), (16000.0, -2.0)
])

# Electronic
generate_preset("Electronic", [
    (32.0, 4.0), (64.0, 4.0), (125.0, 2.0), 
    (250.0, 0.0), (500.0, -2.0), (1000.0, -2.0), 
    (2000.0, 0.0), (4000.0, 2.0), (8000.0, 4.0), (16000.0, 4.0)
])

# Acoustic
generate_preset("Acoustic", [
    (32.0, 0.0), (64.0, 2.0), (125.0, 2.0), 
    (250.0, 0.0), (500.0, 0.0), (1000.0, 0.0), 
    (2000.0, 2.0), (4000.0, 2.0), (8000.0, 2.0), (16000.0, 0.0)
])
