# Implementation Plan — fork-aware repo identity (#601)

Derived entirely from `.opencode/.issues/601/spec.md` (SC-1 … SC-8).
Implementation surface: `.opencode/tools/session_init/` (new `fork_stamp.py`
module) + `.opencode/tools/session-init` (spawn + emission). Tests in
`.opencode/tests/test_session_init/test_fork_stamp.py`.

## Item 1 — Stamp store (SC-5)

- **Deliverable:** `fork_stamp.py` — stamp file at
  `<git-common-dir>/opencode/fork.json`, keyed on origin URL; entries hold
  `fork`, `parent` (only when forked), `probed_at`, `result`
  (`fork` | `not_fork` | `parent_absent`); atomic write (temp + `os.replace`);
  reads drop entries older than 30-day TTL or with a changed/unparseable
  schema; corrupt file treated as absent.
- **RED:** no stamp module exists; loading from a prepared fixture path
  returns nothing and no file is created.
- **GREEN:** implement `stamp_path()`, `load_stamps()`, `save_stamps()`,
  `is_fresh()`.
- **Instrument:** pytest against a temp dir simulating `<git-common-dir>` —
  path shape, schema round-trip, atomic replace, TTL staleness, corrupt-file
  tolerance.

## Item 2 — Probe (SC-3, SC-8, SC-5 negative caching)

- **Deliverable:** `probe_target()` in `fork_stamp.py` — GitHub via
  `gh repo view <owner/repo> --json isFork,parent` (hard timeout); GitBucket
  via `gb api repos/<owner>/<repo>` (hard timeout). Negative result
  (`parent` absent while fork-true, or unreachable instance for GitBucket)
  recorded only when the API actually answered; CLI missing/non-zero without
  an answer writes nothing. No raw HTTP code anywhere.
- **RED:** module has no probe; a mocked CLI run produces no stamp.
- **GREEN:** implement probe + result classification.
- **Instrument:** pytest with mocked subprocess — fork-true with parent,
  not-a-fork, fork-true parent-absent (GitBucket), CLI failure (no stamp
  written), and grep of the module for absence of HTTP client imports.

## Item 3 — Fire-and-forget spawn (SC-2, SC-3)

- **Deliverable:** session-init gains a `--fork-probe` self-invocation mode
  and spawns itself detached (`start_new_session=True`, DEVNULL streams) with
  the deduplicated target list; spawn is skipped when every target already has
  a fresh stamp. session-init's synchronous path performs no network I/O.
- **RED:** session-init output has no stamp-derivable behavior; the probe
  mode does not exist.
- **GREEN:** implement detached spawn + probe mode entry point.
- **Instrument:** pytest asserting the spawn kwargs (detached, DEVNULL,
  timeout-carrying probe command shape); fixture run with endpoint unreachable
  completes promptly with unchanged output structure.

## Item 4 — Annotation exposure (SC-1, SC-8)

- **Deliverable:** when a fresh stamp says fork, the repo entry gains exactly
  one line `fork_of: <owner>/<repo>` after `url:`; all other entries
  byte-identical to current output.
- **RED:** fixture clone with a prepared stamp renders no `fork_of` line.
- **GREEN:** load stamps in `main()`, emit conditionally.
- **Instrument:** pytest on emission function with prepared stamp map; live
  run against this clone (GitHub, non-fork) asserting output identical to
  pre-change for all entries.

## Item 5 — Silent failure + scope (SC-4, SC-6, SC-7)

- **Deliverable:** every probe/read/write failure path is swallowed (no
  annotation, no warnings, unchanged stamp); stale stamp suppresses annotation
  and triggers re-probe; valid negative result suppresses re-probe; diff
  confined to session-init surface.
- **RED:** forced-failure fixture currently emits nothing only because the
  feature does not exist — assertion written against the new contract.
- **GREEN:** exception guards already established in items 1–3; verified here.
- **Instrument:** pytest (forced probe failure → output identical to
  stamp-absent case; backdated stamp → suppressed + re-probe; negative cache →
  zero probe invocations); `git diff --stat` scope check.
