# Post-Install Setup

## Apollo Initialization

The driver initializes the Apollo automatically when it detects the hardware on the Thunderbolt bus. This includes:

1. **Firmware handshake** (ACEFACE) — establishes communication with the DSP
2. **Mixer settings** — loads default monitor routing
3. **Transport start** — enables DMA for audio playback/capture
4. **Clock configuration** — sets sample rate and enables capture routing

You don't need to run any init script — this all happens when the kernel module loads.

## PipeWire Virtual Devices

By default, the Apollo appears as a single 24-channel output / 22-channel input device in pro-audio mode. The `apollo-setup-io` script creates user-friendly virtual devices:

| Device | Type | Channels |
|--------|------|----------|
| Apollo Mic 1 | Source (mono) | AUX0 |
| Apollo Mic 2 | Source (mono) | AUX1 |
| Apollo Mic 1+2 | Source (stereo) | AUX0-1 |
| Apollo Mic 3 | Source (mono) | AUX2 |
| Apollo Mic 4 | Source (mono) | AUX3 |
| Apollo Line In 3+4 | Source (stereo) | AUX2-3 |
| Apollo Monitor L/R | Sink (stereo) | AUX0-1 |
| Apollo Line Out 1+2 | Sink (stereo) | AUX2-3 |
| Apollo Line Out 3+4 | Sink (stereo) | AUX4-5 |

### Running manually
```bash
apollo-setup-io
```

### Making it automatic
The installer sets up a systemd user service that runs after PipeWire starts. If it doesn't trigger automatically, enable it:
```bash
systemctl --user enable --now apollo-setup-io.service
```

## Pro-Audio Profile

The Apollo requires the "pro-audio" PipeWire profile for multi-channel access. The setup script handles this, but if you need to set it manually:

```bash
# Find Apollo device ID
wpctl status | grep "Apollo x4"

# Set pro-audio profile (replace 42 with your device ID)
wpctl set-profile 42 1
```

## Setting Default Audio Device

To make Apollo your default output:
```bash
# Find Monitor L/R sink ID
wpctl status | grep "Apollo Monitor"

# Set as default (replace 67 with your sink ID)
wpctl set-default 67
```

Or just click it in GNOME Sound Settings.
