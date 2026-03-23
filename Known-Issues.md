# Known Issues

## Active

| Issue | Severity | Workaround |
|-------|----------|------------|
| Virtual I/O devices don't auto-appear on boot | Medium | Run `apollo-setup-io` manually after Apollo powers on |
| `alsactl restore` can freeze the system | High | Delete `/var/lib/alsa/asound.state` or remove Apollo entries |
| PCI address changes between Thunderbolt connections | Low | `apollo-setup-io` handles this automatically |
| Only tested on Apollo x4 | — | Other models may work but are unverified |
| No DSP plugin control | — | Plugins loaded on the device still process audio, just can't be configured from Linux |

## Fixed in v1.0.0

| Issue | Fix |
|-------|-----|
| PipeWire capture returns 0 frames | Fixed loopback module wiring (capture/playback sides were swapped) |
| Static PCI address in PipeWire config | Replaced with dynamic `apollo-setup-io` script |
| Kernel panic on PipeWire restart | Moved PCIe ASPM setup out of real-time audio thread |
| Pro-audio profile not set automatically | Added udev rule + systemd service |

## Won't Fix (Scope)

| Item | Reason |
|------|--------|
| DSP plugin licensing/PACE auth | Requires proprietary ARM firmware interaction |
| USB Apollo models (Solo USB, Twin USB) | Different hardware interface — needs separate USB driver |
| macOS/Windows support | This is a Linux-only project |
