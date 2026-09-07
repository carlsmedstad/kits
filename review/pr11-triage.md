# PR 11 triage, second round

- Triage: Claude-Code:claude-fable-5-1@high (driver, seat t1)
- SHA reviewed: b2f01a9019189a836044b9b36eded7fb2cac70f3
- Date: 2026-09-07

## T1 — r1-F1 — fix

A SIGINT discards worker results that finished but were not yet merged:
12 finished, 3 merged, 9 lost in the reviewer's probe, reproduced by the
driver. A worker renames its entry into place only when complete, so the
fix is a sweep on exit: trap INT and EXIT in the main script, and before
the temp directory is removed, merge every completed entry under
entries/ that the loop did not reach. Workers still in flight die with
the process group and leave only .tmp files, which the sweep ignores.

## T2 — r1-F2 — fix

A pkgbase name that is not itself a pkgname still claims ownership of
that name, so a real package providing it is ignored. Dependencies only
ever name pkgnames or provides, never pkgbases. Register owners from
pkgname lines only; keep the pkgbase line for tracking the current base.

## T3 — r1-F3 — reject

An empty NO_COLOR still colours. That is the no-color.org contract:
colour is suppressed when the variable is "present and not an empty
string". The brief's "unset" was loose wording and is corrected to
match the standard; the code already does.

## T4 — r1-F4 — fix

The cycle parser reads tsort's English message, so under a translated
locale it emits `-:` as a member and merges unrelated cycles. Run tsort
under LC_ALL=C; the parsed text is then fixed.

## T5 — r2-F1 — fix

A positional pkgbase containing a slash, a tab-completed `hiredis/` say,
makes the worker's redirect fail, the worker still announces the
package, merge fails on the missing file and the result file is
truncated. Validate positional arguments before anything runs: a
pkgbase is one path component with no slash; reject with a message and
exit 1 before the file is touched. A worker must announce a package only
after its entry is in place.

## T6 — r2-F2 — fix

write_result renames its temp file over the result file even when the
jq feeding it failed, so any producer error empties the file. Run the
producer to the temp file directly and rename only on success; on
failure report the package on stderr and continue, since a failed merge
of one entry must not end the run or damage the file.

## T7 — r2-F3 — fix

A zero-byte or non-array result file makes every later run a silent
no-op that exits 0, --cached included. Validate the old file when
loading it: if it is not a JSON array, refuse loudly for --cached, and
for a checking run warn and start from an empty array so the file is
rebuilt.

## T8 — r2-F4 — defer

No automated coverage for the merge invariant. Same ruling as the first
round: the repository has no harness for any script and the brief keeps
tests out of scope; the want is already recorded there. The
self-enforcing guards the reviewer suggests are T6 and T7.

## Notes recorded, no verdict

- r2-F5: an arch-ls answer of zero packages prunes the file to `[]`. The
  brief sanctions that for a maintainer with no packages; the next good
  run repopulates it.
- r2-F6: a cycle member placed in the earliest batch shows no deciding
  dependency. The stderr warning names the cycle and --deps shows the
  edge.
- r2-F7: gawk builtins are used and gawk is not in depends. gawk is a
  dependency of the base metapackage, which kits never declare, the same
  as coreutils and util-linux.

## Outside the findings

The subject of commit b2f01a9 is 73 columns, one over the house limit;
the implementer noticed after pushing. Amending pushed commits needs the
maintainer's instruction, so this is handed to them rather than fixed.
