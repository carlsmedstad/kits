# Testing kits in a virtual machine

The installer and the kits it installs can be tried in QEMU with UEFI firmware
before they touch real hardware. Install `qemu-desktop` and `edk2-ovmf`.

## Serving unpublished kits

To test a branch before it is published, build and sign every kit, put them
in a local repository and serve it over HTTP:

```sh
make package-signed-all
make stage-packages REPODIR=repo
python -m http.server --directory repo 8000
```

With QEMU's user-mode networking the host is reachable from the VM at
`10.0.2.2`, so the VM adds this to `/etc/pacman.conf` instead of the published
repository. The packages are signed with the same key, so nothing else
changes:

```ini
[kits]
Server = http://10.0.2.2:8000
```

## Running the installer

Download the [Arch ISO][] and create a disk and a copy of the UEFI variables.
The disk must fit the installer's default layout, 64G root plus swap the size
of the VM's memory. A qcow2 image is sparse, so its size costs nothing until
written:

```sh
qemu-img create -f qcow2 arch.qcow2 128G
cp /usr/share/edk2/x64/OVMF_VARS.4m.fd .
qemu-system-x86_64 -enable-kvm -m 4G -smp 4 \
  -drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2/x64/OVMF_CODE.4m.fd \
  -drive if=pflash,format=raw,file=OVMF_VARS.4m.fd \
  -drive file=arch.qcow2,if=virtio \
  -cdrom archlinux-x86_64.iso -boot d \
  -device virtio-vga -display gtk,zoom-to-fit=off \
  -nic user,hostfwd=tcp::2222-:22
```

The GL-accelerated display, `virtio-vga-gl` with `gl=on`, stays black after the
initramfs switches video mode, so use the plain one.

Pasting into the QEMU window does not work, so use SSH. The ISO runs sshd
but root has no password. Set one in the VM with `passwd`, then from the
host:

```sh
ssh -p 2222 root@localhost
```

Then follow [installation.md](installation.md) with `/dev/vda` as the
disk. Drop the `-cdrom` and `-boot` arguments to boot the installed
system. The copied variables file keeps the boot entry `bootctl install`
wrote.

[Arch ISO]: https://archlinux.org/download/
