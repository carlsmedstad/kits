# Periodic TRIM with fstrim.timer

Nothing trims the SSD today. The fstab does not use the `discard` mount option
and fstrim.timer is not enabled, so the drive never learns which blocks the
filesystems have freed. Over time that costs write performance and flash wear.

The fix is to enable the weekly timer in the kit-base-system preset:

    enable fstrim.timer

The crypttab template already passes `discard` through LUKS, so TRIM reaches
the disk once the timer runs. No further change is needed.
