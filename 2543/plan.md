# Plan — local-issues consolidated defect repair (.opencode#2543)

Spec: `.issues/2543/spec.md`. Branch: `feature/2543-local-issues-defect-repair` (base tip 7de23819).

## Item 1 — Fail-fatal worktree contract (SC-1, SC-2)
- Deliverable: `_ensure_worktree()` and its helpers exit non-zero with a diagnostic + remediation command on failure; no False-returning degraded path; no plain `.issues/` creation on failure.
- RED: scratch repo with induced worktree failure; mutating command must exit non-zero, name failure + remediation, and leave no plain `.issues/`.
- Instrument: scratch-repo behavioral probe; grep source for no `return False` path in `_ensure_worktree` chain.

## Item 2 — Per-repo numbering, counter removal (SC-3, SC-4, SC-6)
- Deliverable: `_check_duplicate_issue()` per-repo only; `.counter`/`_next_number()` removed (incl. doctor counter marker); `cmd_create` calls `_ensure_worktree(repo_path=target)`.
- RED: create `R#N` with `N` present only in sibling repo must succeed; absent counter must not block create.
- Instrument: scratch two-repo probe; grep for `_next_number`/`.counter` absent.

## Item 3 — Plumbing init (SC-5)
- Deliverable: orphan branch via `hash-object -t tree /dev/null` → `commit-tree` → `update-ref`; temp-worktree functions and stale-temp cleanup removed; `cmd_create` scopes ensure to target repo.
- RED: scratch repo init produces zero-file `issues-data` tree; no `.issues-worktree-tmp` at any point; zero-commit repo also succeeds.
- Instrument: scratch-repo probe (`git ls-tree -r issues-data` empty; path check).

## Item 4 — Contract alignment (SC-7, SC-8, SC-9, SC-10)
- Deliverable: `_scan_issue_dir_errors` sweeps `**/*.yaml` (schema checks on canonical three, parse-validate on the rest); scoped validate-yaml on absent target exits 0 with `no-local-records`; `promote` removed; `url` subcommand added with `--artifacts` emitting `tree/issues-data/{N}/`.
- RED: malformed `artifacts/x.yaml` reported `invalid-yaml` exit 1; scoped validate on remote-only issue exits 0; `promote` unrecognized; `url`/`url --artifacts` correct paths.
- Instrument: scratch-repo probes.

## Item 5 — Tooling-doc consolidation (SC-11, SC-12, SC-13)
- Deliverable: `issues` skill card carries tooling contract inline + `references/` detail cards; `.opencode/.issues/AGENTS.md` sheds tool-usage docs, keeps workspace guide, points to skill card. Deck edit passes skill-creator admission gate.
- RED: grep finds no counter/promote references and no `local-issues` subcommand invocations in AGENTS.md; skill card references tool path and `repo#N` rule; detail cards cover CLI options/command behavior.
- Instrument: grep checks over the three surfaces.
