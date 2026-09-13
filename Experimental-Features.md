Things that exist in the repository but are **not supported**. They are incomplete, unverified on hardware, or research scaffolding that was never meant to ship. They stay in the tree because they document how the hardware was reverse engineered and may become real features later. Bug reports against them are welcome but will not be prioritized.

Features that are not implemented at all (virtual/monitor loopback, multi-device support, UAD plugins) are listed in the [README](https://github.com/rolotrealanis98/open-apollo#not-yet-implemented).

---

## Console web UI (`console-web/`)

A Svelte 5 mixer UI that talks to the daemon over TCP:4710 and WS:4721: faders, meters, device status. Tracked in the repo, not installed by either installer. The settings page is a read-only mock and the preamp relay controls are flagged as hardware-unverified. If you want to try it:

```bash
cd console-web && npm install && npm run dev
```

## Plugin chain replay

After every ACEFACE connect the driver replays 1,317 ring-buffer commands captured from the Windows UAD driver, substituting Linux DMA addresses into the `DMA_REF` entries. The goal is to load the DSP programs that forward PAD, 48V, and Mic/Line writes to the ARM MCU relays. It is **on by default**.

| Where | What |
|-------|------|
| `driver/ua_dsp.c` | `ua_dsp_activate_plugin_chain()`, payload loading, address substitution |
| `driver/ua_plugin_chain.h` | the captured command list |
| `configs/firmware/ua-apollo-plugin-chain.bin` | DMA payload blob, installed by `make firmware-install` |
| `tools/build-plugin-chain-firmware.py` | packs the blob from a capture |

Module parameters: `no_plugins=1` skips the chain; `skip_bus_coeff=1` (default) skips the 745 `BUS_COEFF` entries because sending them has deadlocked the sequence counter and their encoding is still unknown. Consequence: fader, pan, and send coefficients are cached by the daemon but never sent to the DSP from Linux. Details in [DSP Protocol](DSP-Protocol#plugin-chain-activation).

## Talkback

The ALSA `Monitor Talkback Switch` toggles the DSP flag. The talkback mic capture path (record channels AUX20-21) needs a DSP `MODULE_ACTIVATE` command that is not implemented, so no talkback audio reaches a DAW or cue mix. `tools/test-talkback-bus.py` is a raw-ioctl probe used to investigate this; it is not a user tool.

## Output metering

The daemon computes input meters from ALSA capture. Output (playback) meters always return silence. See [Protocol Reference](Protocol-Reference#metering-data).

## Digital and virtual channels (Thunderbolt)

S/PDIF, ADAT, and the eight virtual (DAW playback) channels are exposed as ALSA channels but have never been verified. `apollo-setup-io` also creates "Apollo S/PDIF In" and "Apollo S/PDIF Out" PipeWire nodes; the script marks both as untested.

## Firmware for DSPs 1–3

Only DSP 0 receives mixer firmware. Windows warm-boot traces show hundreds of commands going to DSPs 1–3, but loading the same firmware into them crashes the FPGA. `driver/ua_core.c` carries the TODO.

## DMA reference format probe

`ua_dsp_test_dma_ref()` in `driver/ua_dsp.c` is a ten-case harness that was used to discover the `DMA_REF` entry format. It is reachable only through the `UA_IOCTL_DSP_TEST_DMA` debug ioctl and is not part of normal initialization.

## macOS DTrace capture (`tools/contribute/macos/`)

Work in progress. It captures the IORegistry dump and several IOKit selectors (171, 130, 131, 113, 129) for routing research. [Device Capture (macOS)](Device-Capture-macOS) describes what it does today.

## USB reverse-engineering tools

`tools/usb-re/` and the `tools/usb-*.py` scripts are capture parsers, replay tools, and register probes for contributors doing USB captures. The USB installer ships only `fx3-load.py`, `usb-full-init.py`, `usb-dsp-init.py`, and `init-bulk-sequence.bin`. The EP6 drain daemon mode of `usb-dsp-init.py` is no longer part of the supported stack; the one-shot full init replaced it. See [Device Capture (Windows)](Device-Capture-Windows) and [USB Apollo Reverse Engineering](USB-Apollo-Reverse-Engineering).

## PipeWire configs that nothing deploys

- `configs/pipewire/50-apollo-pulse-rules.conf` — per-application quantum rules for Firefox, Chromium, and Discord so browser capture matches the Apollo quantum. Not deployed by any installer; copy it to `/etc/pipewire/pipewire-pulse.conf.d/` yourself if you want it.
- `configs/pipewire/filter-chain/apollo-io-map.conf` — an earlier filter-chain based I/O map, superseded by the loopback modules that `apollo-setup-io` generates.

`scripts/uninstall.sh` removes both paths even though nothing creates them.
