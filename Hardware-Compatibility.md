Community-reported test results, one row per hardware and system combination. **Edit this page to add your results.**

For the per-model table (device types, channel counts, verification scope) see [Supported Devices](Supported-Devices).

## Verified working

| Model | Connection | Distro | Kernel | Playback | Capture | Preamps | Reported by | Notes |
|-------|-----------|--------|--------|----------|---------|---------|-------------|-------|
| Apollo x4 | Thunderbolt 4 | Ubuntu 24.04 | 6.17 (HWE) | ✅ | ✅ | ✅ | maintainer | Primary test device. Analog I/O only; S/PDIF, ADAT, virtual channels unverified |
| Apollo x4 | Thunderbolt | Arch Linux | 6.19.9 | ✅ | ✅ | ✅ | maintainer | Verified for v1.1.0 (buffer-size fix for kernels 6.18+) |
| Apollo x8p | Thunderbolt | Fedora 44 | 7.1.4 | ✅ | ✅ | ✅ | @Skrypt | 48 kHz only. Tested before the driver exposed 34/32 channels; the extra channels are unverified. Rear inputs 3–8 default to Mic |
| Apollo Solo USB | USB 3.0 | Ubuntu Studio 24.04 | 6.17 | ✅ | ✅ | ✅ | @stoneiboyz-sys | Intel Tiger Lake-H. PipeWire capture and Discord confirmed |
| Apollo Solo USB | USB 3.0 | CachyOS | 6.19 | ✅ | ⚠️ | ✅ | @ariahello | AMD. Full init crashes at packet 28 on this firmware build; playback works, capture does not |

## Needs testing

| Model | Connection | Issue |
|-------|-----------|-------|
| Apollo Twin (USB) | USB-C | [#1](https://github.com/rolotrealanis98/open-apollo/issues/1) |
| Apollo Twin X (TB) | Thunderbolt | [#1](https://github.com/rolotrealanis98/open-apollo/issues/1) |
| Apollo Solo (TB) | Thunderbolt | [#2](https://github.com/rolotrealanis98/open-apollo/issues/2) |
| Apollo x6 | Thunderbolt | [#3](https://github.com/rolotrealanis98/open-apollo/issues/3) |
| Apollo x8 | Thunderbolt | [#4](https://github.com/rolotrealanis98/open-apollo/issues/4) |
| Apollo x16 | Thunderbolt | [#5](https://github.com/rolotrealanis98/open-apollo/issues/5) |
| Apollo Rack | TB upgrade card | [#6](https://github.com/rolotrealanis98/open-apollo/issues/6) |

Thunderbolt 2 models (Apollo Twin, Apollo 8, Apollo 16, Duo, Quad) are not expected to work. Linux does not enumerate Thunderbolt 2 PCIe devices in most configurations, even through an Apple TB2-to-TB3 adapter.

## How to report

1. Run `sudo ./tools/contribute/device-probe.sh` (Thunderbolt) and submit the report, or follow [Submitting Data](Submitting-Data)
2. Comment on the matching issue above with your results
3. Add a row to the table on this page: model, connection, distro, kernel, what works and what does not
