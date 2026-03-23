# Troubleshooting

## Apollo not detected

**Symptom:** `lspci -d 1a00:` returns nothing

**Fixes:**
1. Check Thunderbolt cable is connected and Apollo is powered on
2. Wait 20-30 seconds after power-on for Thunderbolt enumeration
3. Verify `iommu=pt` is in your kernel cmdline: `cat /proc/cmdline | grep iommu`
4. Check `dmesg | grep thunderbolt` for connection errors
5. Try a different Thunderbolt port

## Driver loaded but no ALSA card

**Symptom:** `lsmod | grep ua_apollo` shows the module but `aplay -l` has no Apollo

**Fixes:**
1. Check `dmesg | grep ua_apollo` for errors
2. Look for "ACEFACE connect" — if missing, the firmware handshake failed
3. Look for "device unreachable" — means BAR0 reads 0xFFFFFFFF (Thunderbolt link issue)
4. Power cycle the Apollo and reboot

## No sound from Apollo

**Symptom:** Apollo appears in Sound Settings but no audio output

**Fixes:**
1. Make sure you selected "Apollo Monitor L/R" (not "Apollo x4 Pro") as the output
2. Check the physical volume knob on the Apollo isn't turned down
3. Verify pro-audio profile is set: `wpctl status | grep "Apollo x4 Pro"`
4. If no pro-audio nodes, run: `apollo-setup-io`

## pw-record returns empty file (44 bytes)

**Symptom:** Recording produces a WAV header with no audio data

**Fixes:**
1. Make sure pro-audio profile is set: `wpctl set-profile <device_id> 1`
2. If loopback modules are loaded, check their wiring — capture side must be `node.passive = true`
3. Test ALSA directly: `sudo arecord -D hw:x4 -f S32_LE -r 48000 -c 22 /tmp/test.wav` — if this works, the issue is PipeWire config
4. Run `apollo-setup-io` to regenerate the config

## System freeze or kernel panic

**Symptom:** System locks up during PipeWire restart or device access

**Known triggers:**
- `alsactl restore` can send ALSA mixer values that freeze the DSP — delete `/var/lib/alsa/asound.state` entries for Apollo
- `rmmod ua_apollo` while the device is on the Thunderbolt bus kills the TB link
- Rapid profile switching in pavucontrol

**Recovery:** Hold power button 5 seconds to force off. Power cycle the Apollo before rebooting.

## Virtual devices not appearing

**Symptom:** Only "Apollo x4 Pro" in Sound Settings, no Mic 1/Monitor L/R etc.

**Fix:** Run `apollo-setup-io` manually. The automatic systemd service has a timing issue where it runs before PipeWire discovers the Apollo.

## alsactl freeze

**Symptom:** System freezes after boot when alsactl tries to restore saved mixer state

**Fix:**
```bash
# Remove Apollo entries from saved state
sudo rm /var/lib/alsa/asound.state
# Or edit it to remove the ua_apollo card section
```
