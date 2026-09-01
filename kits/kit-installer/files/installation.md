# Installing Arch Linux with kits

`kit-installer` turns the [installation guide][] into one command. It creates
the disk layout `kit-base-system` expects, installs the kits, and configures
what a package cannot: hostname, locale, users and the boot loader.

## Installing

Boot the Arch ISO in UEFI mode and connect to the network, e.g. with `iwctl`
for wireless. Then add the repository and install the installer:

```sh
cat >> /etc/pacman.conf << 'EOF'

[kits]
Server = https://carlsmedstad.github.io/kits
EOF
pacman -Sy kit-installer
```

Run the installer against the disk to wipe. The generic kits are installed by
default:

```sh
kit-install --hostname <name> /dev/nvme0n1
```

My own systems add the bespoke kits and a user:

```sh
kit-install \
  --hostname <name> \
  --user carsme \
  --timezone Europe/Stockholm \
  --kits "kit-base-system kit-shell-environment kit-desktop-environment kit-editor kit-secrets" \
  /dev/nvme0n1
```

The installer shows the planned layout and asks for the disk path before
wiping anything. It refuses a disk with existing signatures unless given
`--force`. It then prompts for the LUKS passphrase, the root password and the
user's password. See `kit-install --help` for the sizes and settings that can
be changed.

Reboot when it says so. The system boots to `greetd`, which starts Sway after
login.

## Disk layout

```
nvme0n1
├─nvme0n1p1  1G    vfat, EFI system partition, mounted at /boot
└─nvme0n1p2  rest  LUKS2, opened as cryptlvm
  └─VolGroup       LVM
    ├─swap   RAM size, allows hibernation
    ├─root   64G, ext4
    └─home   rest, ext4
```

This is the [LVM on LUKS][] layout from the wiki. It is fixed rather than
configurable because `kit-base-system` renders `fstab` and
`crypttab.initramfs` from it and ships static boot loader entries for it.

The LUKS container is formatted with `--sector-size 4096`. Modern SSDs have 4K
physical sectors, and with the default 512 byte sectors every write goes
through read-modify-write in dm-crypt, which showed up as multi-second write
latency under load on a laptop. The sector size is set at format time and
cannot be changed later, so the installer verifies it with `luksDump` and
aborts on anything else. `kit-base-system` also warns about a 512 byte mapping
on every install and upgrade.

## Recovery

The stages can be run separately. `--only-disks` stops after the disk is
mounted under `/mnt`, and `--skip-disks` installs the system onto whatever is
mounted there.

To get into an installed system from the ISO:

```sh
cryptsetup open /dev/nvme0n1p2 cryptlvm
mount /dev/VolGroup/root /mnt
mount /dev/VolGroup/home /mnt/home
mount /dev/nvme0n1p1 /mnt/boot
arch-chroot /mnt
```

[installation guide]: https://wiki.archlinux.org/title/Installation_guide
[LVM on LUKS]: https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#LVM_on_LUKS
