# PipeWire Tips

## Check your PipeWire version
```bash
pw-cli --version
wpctl --version
```

## View all Apollo audio nodes
```bash
wpctl status | grep Apollo
```

## Monitor audio levels in terminal
```bash
pw-top
```

## Record from a specific mic
```bash
# Record from Mic 1 (mono)
pw-record --target apollo_mic_1 --rate 48000 --channels 1 --format s32 mic1.wav

# Record from Mic 1+2 (stereo)
pw-record --target apollo_mic_stereo --rate 48000 --channels 2 --format s32 stereo.wav
```

## Play to a specific output
```bash
pw-play --target apollo_monitor /path/to/file.wav
```

## Latency tuning
The default buffer is 1024 frames at 48kHz (~21ms). For lower latency:
```bash
# Set PipeWire quantum (buffer size)
pw-metadata -n settings 0 clock.force-quantum 256
```
Warning: lower values increase CPU load and risk of xruns.

## Using with JACK applications
PipeWire provides a JACK compatibility layer. JACK apps should see Apollo devices automatically. If not:
```bash
# Check JACK is using PipeWire
pw-jack jack_lsp
```

## WirePlumber rules
The installer deploys `/etc/wireplumber/main.lua.d/51-ua-apollo.lua` which:
- Disables mmap (driver uses copy callbacks)
- Prevents device suspension
- Forces S32LE format at 48kHz
