Documentation for **Open Apollo**, the open-source Linux driver and mixer daemon for Universal Audio Apollo Thunderbolt and USB interfaces. Built through clean-room reverse engineering.

This wiki is the single place where the documentation is maintained. Current status, known issues, and app compatibility live in the repository [README](https://github.com/rolotrealanis98/open-apollo#readme).

## Start here

- [Installation](Installation) — build and load the driver, set up PipeWire, USB install
- [Supported Devices](Supported-Devices) — model table and what "verified" means
- [Hardware Compatibility](Hardware-Compatibility) — community test results by system
- [Troubleshooting](Troubleshooting) — symptoms, causes, and fixes

## Driver

- [Building from Source](Building-from-Source)
- [Driver Configuration](Driver-Configuration) — module parameters, PipeWire, UCM2, ALSA controls
- [Sample Rates](Sample-Rates)

## Mixer daemon

- [Daemon Setup](Daemon-Setup)
- [Daemon Configuration](Daemon-Configuration)
- [Protocol Reference](Protocol-Reference) — TCP:4710, TCP:4720, WS:4721

## Contributing

- [How to Contribute](How-to-Contribute)
- [Device Capture (macOS)](Device-Capture-macOS)
- [Device Capture (Windows)](Device-Capture-Windows)
- [Submitting Data](Submitting-Data)

## Architecture and reverse engineering

- [Architecture Overview](Architecture-Overview)
- [Register Map](Register-Map)
- [DSP Protocol](DSP-Protocol)
- [Initialization Sequence](Initialization-Sequence)
- [USB Apollo Reverse Engineering](USB-Apollo-Reverse-Engineering)
- [Experimental Features](Experimental-Features) — what is in the tree but not supported

## Legal

- [License](License)
- [Notice](Notice)

---

Found a mistake? Edit the page directly, or open an [issue](https://github.com/rolotrealanis98/open-apollo/issues).
