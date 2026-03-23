# Installation Guide

## Prerequisites

- Linux with kernel 5.15+ (tested on 6.17)
- Thunderbolt 3 or 4 port
- PipeWire + WirePlumber (default on Ubuntu 22.04+, Fedora 34+, Arch)
- `iommu=pt` in your GRUB kernel command line

## Step 1: Set up IOMMU

Edit `/etc/default/grub`:
```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash iommu=pt"
```
Then:
```bash
sudo update-grub   # Ubuntu/Debian
# or
sudo grub2-mkconfig -o /boot/grub2/grub.cfg   # Fedora
```
Reboot.

## Step 2: Power off Apollo

Turn off your Apollo before running the installer. The install script builds the kernel module and loading it while the Apollo is connected can cause issues.

## Step 3: Clone and install

```bash
git clone https://github.com/rolotrealanis98/open-apollo.git
cd open-apollo
sudo bash scripts/install.sh
```

The installer will:
- Detect your distro and install dependencies
- Build the kernel module
- Set up DKMS (auto-rebuilds on kernel updates)
- Deploy PipeWire/WirePlumber configs
- Install the system tray indicator

## Step 4: Power on Apollo

After install completes, power on your Apollo and wait ~30 seconds for Thunderbolt enumeration.

## Step 5: Verify

```bash
# Check driver loaded
lsmod | grep ua_apollo

# Check ALSA card
aplay -l | grep Apollo

# Check PipeWire
wpctl status | grep Apollo
```

If you see "Apollo x4" (or your model) in all three, you're good.

## Step 6: Set up virtual I/O devices

```bash
apollo-setup-io
```

This creates named audio devices (Mic 1-4, Monitor L/R, Line Out, etc.) in your Sound Settings. A systemd service tries to do this automatically, but you may need to run it manually the first time.

## Uninstall

```bash
sudo dkms remove ua_apollo/0.1.0 --all
sudo rm /etc/modules-load.d/ua_apollo.conf
sudo rm /etc/udev/rules.d/91-ua-apollo.rules
sudo rm /usr/local/bin/apollo-setup-io
sudo rm /usr/local/bin/open-apollo-profile-setup
```
