# Kits

A _kit_ is a sort of meta-package for Arch Linux that contains dependencies,
configuration files and scripts to fulfil a certain need. The goal is to
conveniently be able to provide a as close to fully featured experience
out-of-the-box.

## Kits in this repository

Kits installing fundamental stuff:

- kit-base-system: Installs e.g. the kernel and other fundamental stuff.

- kit-shell-environment: Installs my shell of choice, [fish][], along with some
  programs that are key to the command-line, such as Git and OpenSSH.

- kit-desktop-environment: Installs a desktop environment, [Sway][]. Fully
  featured with login manager, launcher, bar, theme, and so on. Comes with the
  terminal emulator [Alacritty][].

Kits installing applications:

- kit-editor: Installs the editor [Neovim][] along with some helper scripts.

- kit-mail: Installs the mail client [aerc][] and [Proton Mail Bridge][] to
  be able to connect to use [Proton Mail][].

Kits installing utilities:

- kit-secrets: Utilities for managing secrets, using [Bitwarden][] as vault
  with some secrets synced locally to a gopass store.

- kit-arch-development: Utilities for useful for Arch Linux development and
  packaging.

- kit-arch-user-repository: Utilities for downloading packages from the
  [Arch Linux User Repository (AUR)][], specifically [aurutils][].

- kit-development-utilities: Generic development utilities (kind of a
  catch-all).

- kit-system-maintenance: Utilities for performing system maintenance.

Consistent throughout the kits is the theme [Catppuccin][] Mocha.

[fish]: https://fishshell.com/
[Sway]: https://swaywm.org/
[Alacritty]: https://alacritty.org/
[Neovim]: https://neovim.io/
[aerc]: https://aerc-mail.org/
[Proton Mail]: https://proton.me/mail
[Proton Mail Bridge]: https://github.com/ProtonMail/proton-bridge
[Bitwarden]: https://bitwarden.com/
[Arch Linux User Repository (AUR)]: https://aur.archlinux.org/
[aurutils]: https://github.com/aurutils/aurutils
[Catppuccin]: https://catppuccin.com/

## Installation

Build and install a kit from this repository by running:

```sh
make install-<kit>
```

After installation, follow the post-installation steps declared in the notice.

Uninstall by running:

```sh
make uninstall-<kit>
```
