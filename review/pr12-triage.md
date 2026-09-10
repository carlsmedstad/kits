# PR 12 — triage

- Triager: Claude-Code:claude-opus-5@high (t1, driver-held)
- SHA triaged: 1d2c06ef08fec996177d6b104d3b4eb5b6ff12ea
- Date: 2026-09-10

Six distinct defects across two reviewers. Both must-fix findings were reported
independently by both seats. Every finding was re-verified by the triager before
a verdict — r1 filed all three of its findings `by reasoning`, and all three
reproduce against a synthetic sync database built for this triage.

## T1 — r1-F1 + r2-F2 | must-fix | fix

`want` maps a provided name to a single target, so querying two packages that
provide the same name attributes every row through that name to whichever
provider the database stream yielded last.

Reproduced on a synthetic database where `provider-a` and `provider-b` both
provide `virtual-api` and `consumer` depends on it: queried separately each
target owns the row, queried together only `provider-b` survives. r2 reproduced
the same defect on live databases — `jack2` and `pipewire-jack` both provide
`jack`, and 467 of 527 rows claim the wrong target; `exim`, `opensmtpd` and
`postfix` all provide `smtp-server`, and `opensmtpd` disappears from the
`target` column entirely.

Provides is a relation, not a unique owner map. `want` holds a list of targets
per name and the match rule emits one row per member; rows that do not print
`target` collapse again in the existing `sort -u`.

## T2 — r1-F2 | must-fix | fix, narrowed

The dependency types are joined over the printed columns, so a projection that
drops the package identity reports a combination no package uses.

The narrow case is real and is fixed: `--columns type` alone leaves one empty
grouping key and prints `depend,makedepend,checkdepend`, which is a statement
about no package at all. `type` describes one package's relationship to a
target, so it now requires `pkgname` or `pkgbase` beside it.

The general remedy the finding asks for — aggregate per package, then project —
is **rejected**. It would make `--columns pkgbase,type` print `splitbase depend`
and `splitbase makedepend` as separate rows. Collapsing a pkgbase's split
packages into one row is a ruling of this effort, made when the requester saw
`adlplug extra depend` and `adlplug extra makedepend` on consecutive lines and
asked "We get duplicates, should we?"; the union at pkgbase level is the
answer that ruling chose, and it is a true statement about the pkgbase. The
finding treats an intended aggregate as an accident of ordering.

## T3 — r1-F3 + r2-F1 | must-fix | fix

`--repo` selects which databases are unpacked, and that one stream serves both
the provides-harvest pass and the match pass, so restricting the repositories
also discards the `%PROVIDES%` of any target outside them.

Reproduced on the synthetic database: `libfoo` in `core` provides `libfoo.so`,
`soname-user` in `extra` depends on it, and `--repo extra` drops `soname-user`
while direct `libfoo` dependents still match — the truncated answer looks
plausible. r2 measured the live case: `--repo extra bash` returns 575 rows
against 772, silently losing the 197 `extra` packages that depend on `sh`.

Brief requirement 2 is unconditional. Every synced database is read, and
`--repo` filters the rows that print.

## T4 — r2-F3 | should-fix | fix

`emit()` reconstructs `n + 1` fields from `n = split(key, fields, "\t")`, and
awk's `split("")` returns 0 rather than 1, so a single empty key field is
counted as none and the row prints as an empty line.

Reachable through `--nvcheck` with a hand-written `"local_version": ""`, which
`jq`'s `// "-"` does not catch. Reproduced. The join/split round-trip is
removed rather than guarded: the merge awk keeps the group's fields as it reads
them, which cannot miscount.

## T5 — r2-F4 | should-fix | fix

The two-stage type join needs all rows sharing a key to be adjacent after
`sort`, which holds only because TAB collates below every byte a key can carry.
Confirmed with `printf 'ab\t0\nab\t3\nab1\t0\n'`: `LC_ALL=C` keeps the two `ab`
rows adjacent, `en_US.UTF-8` splits them around `ab1`, which would silently
turn one row into three.

Latent, not live — the reviewer re-ran the whole tool under `en_US.UTF-8` and
got identical output. The repository has no test harness to pin it with, and
adding one is out of this PR's scope, so the invariant is recorded as a
comment. CLAUDE.md's comment policy names this case exactly: "a non-obvious
invariant needed to prevent a plausible regression".

## T6 — r2-F5 | note | recorded, not promoted

A trailing comma is accepted in `--columns`, `--deptype` and `--repo` while a
leading or doubled comma errors, and an empty `--deptype`/`--repo` means "all"
while an empty `--columns` is an error.

Accurate and cosmetic — no wrong output results. Left as filed: this round was
asked to hunt unnecessary complexity, and three more validation branches to
reject a trailing comma would add some for no user-visible gain.
