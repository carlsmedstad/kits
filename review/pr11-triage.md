# PR 11 triage

- Triage: Claude-Code:claude-fable-5-1@high (driver, seat t1)
- SHA reviewed: 2b7387b28c5fce334e52cbba8a9e7aa8df704a77
- Date: 2026-09-07

## T1 — r1-F3 + r2-F1 — fix

A `provides` entry overwrites the pkgname-to-pkgbase mapping of a real
package of the same name, and glob order decides the winner. Reproduced
by both reviewers and by the driver; live in the cache today for
`aws-cli` and `python-h5py`. A real pkgname must win over a provides.

## T2 — r1-F2 + r2-F2 — fix

With no `.SRCINFO` in the cache directory the glob stays literal and awk
aborts with exit 2 before anything is listed. R6 requires warn and
continue, every todo package in batch 1. Reproduced by both reviewers
and by the driver.

## T3 — r2-F3 — fix

`walk()` records a `(via X)` for a dependency that is also direct when an
alphabetically earlier indirect path reaches the target first. The batch
placement is unaffected, the annotation states a relationship the brief
reserves for paths through unlisted packages. Live case
`aws-sdk-cpp (after: aws-c-io (via aws-c-auth))`. A direct edge takes
precedence over any collapsed path.

## T4 — r1-F1 + r2-F5 — fix

When xargs splits `pkgctl version check` into several invocations, the
merge reads only the first array and drops the rest silently. Driver
reproduction: 800 long names saved 689 entries. Needs pathological input
on this system (7 KB list against a 2 MB limit) but it is a silent data
loss and the fix is to concatenate every array before merging.

## T5 — r2-F4 — fix, scoped to git pull

One failing `git pull` makes xargs exit 123, the run aborts and the
result file is untouched, so a transient network failure repeats the
whole check. Fix: report a failed pull on stderr and continue, since
pkgctl then checks the clone as it stands. A failing `pkgctl repo clone`
stays fatal: pkgctl skips a missing directory silently, so continuing
would drop that package from the file without a word, and in positional
mode a pkgbase that cannot be cloned is user error that should be loud.

## T6 — r1-F4 — defer

The diff adds merge, freshness and ordering invariants with no automated
tests. The repository has no test harness for any of its scripts and the
brief asked for none, so adding one is a scope decision for the
maintainer, not a fix in this diff. Recorded as a want in the brief
(notes/nvcheck-nvtodo.md, "Out of scope for now"); every invariant named
was exercised by hand by the implementer, both reviewers and the driver.

## Notes recorded, no verdict

- r2-N1: `asort()` is gawk-only and byte-ordered, so within-batch order
  differs from locale collation. gawk is in Arch's base group; cosmetic.
- r2-N2: the renderer prints nothing for an empty result file. pkgctl has
  no listing for that case and the brief specifies none.
