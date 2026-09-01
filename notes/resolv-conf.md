# Point /etc/resolv.conf at systemd-resolved

kit-base-system enables systemd-resolved, but programs using libc name
resolution only reach it if /etc/resolv.conf is the stub symlink:

    ln -sf ../run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

Without it, resolvectl and curl work while e.g. dirmngr (gpg keyservers)
fails, which is confusing to debug.

The filesystem package owns /etc/resolv.conf, so the kit cannot ship the
symlink as a file. It should be done in post_install: replace the file if it
is a regular file, leave it alone if it is already a symlink.
