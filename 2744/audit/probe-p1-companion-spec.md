# Spec: probe-home#3 — Nightly maintenance task archiving the .issues/ store

> STAGED DRAFT — filed at `.issues/3/spec.md` after the issue-store repair (see HANDOFF.md
> beside this file). Not yet validated: the fresh-context validation dispatch is pending.

## Intent and Executive Summary

- **Problem Statement:** The project's issue store (`.issues/`) has no backup. The store is
  remoteless (standalone git repo, branch `issues-data`, no origin — verified 2026-11-16), so
  its data and its only git history exist on this machine alone; any corruption, bad mutation,
  or environment loss loses the sole copy.
- **Root Cause / Motivation:** No maintenance task exists that archives the store, and
  `backups/` does not exist at the project root (verified 2026-11-16). The developer directed
  adding a nightly maintenance task that archives the store to a timestamped tarball under
  `backups/`.
- **Approach Chosen:** A POSIX shell script `scripts/nightly-maintenance.sh` creates `backups/`
  and archives the whole `.issues/` directory — including the store's `.git` history — with
  `tar -czf` into a per-run timestamped name `backups/backup-YYYYMMDDThhmmss.tar.gz`. A
  project-tree crontab fragment `scripts/nightly-maintenance.crontab` (`0 3 * * *`) defines the
  nightly cadence with a documented operator install command; live scheduler installation is
  operator-owned.
- **Alternatives Considered & Why Discarded:**
  - systemd timer units — a user systemd manager runs here (PID 1 is systemd; user manager
    observed running 2026-11-16), but the machinery is heavier for the same cadence: unit plus
    timer plus on-calendar configuration and lingering/headless behavior to settle; system
    unit installation additionally requires root and `sudo` is blocked in this environment
    (no-new-privileges flag observed 2026-11-16). The cron fragment is the minimal-machinery
    form of the same schedule.
  - CI scheduled workflow — the repository has no remote and no CI platform (platform: local,
    url: none, per session-init 2026-11-16).
  - Archiving store data only, excluding `.issues/.git` — the store is remoteless, so its git
    history exists nowhere else; excluding `.git` leaves the backup unable to restore the
    store's history.
  - Installing the schedule into the live user crontab during implementation — the user
    crontab spool is not readable/writable in this environment (`crontab -l`: permission
    denied, 2026-11-16); hence installation is operator-owned with a documented append-style
    command (append, never spool replacement).
- **Key Design Decisions:** (1) whole-directory archive including `.issues/.git` — tradeoff:
  larger archives vs. full recoverability of data and history (the history exists nowhere
  else); (2) gzip compression — tradeoff: negligible CPU vs. smaller archives (the store is
  about 132 KB at write time); (3) second-granularity timestamps `date +%Y%m%dT%H%M%S` —
  tradeoff: two runs within the same second could collide; accepted because the cadence is
  nightly and verification runs are at least 1 s apart, noted in the fragment header; (4)
  schedule lives in the project tree with operator-owned installation — tradeoff: one install
  step vs. machine-local scheduler writes infeasible here; (5) 03:00 daily — tradeoff:
  arbitrary off-peak hour, adjustable by editing the fragment.

## Not Included

- Retention/pruning of old archives — no retention policy was stated by the developer;
  archives accumulate until one is stated.
- Failure monitoring or alerting — not stated by the developer.
- Live scheduler installation on this machine — the crontab spool is not writable here
  (evidenced 2026-11-16); the fragment plus its documented install command is the deliverable,
  installation is operator-owned.
- Version-control exclusion of `backups/` — the project root has no functioning git repository
  (`.git` holds only `hooks/`; `git status` exits "not a git repository", 2026-11-16), so
  there is no version-control surface to configure.
- Quiescing/locking `.issues/` during archiving — archives take a best-effort snapshot; the
  store's git history bounds any damage (see Edge Cases).
- Archiving anything besides `.issues/` — the deliverable names the store only.

## Requirements

R-1. The project SHALL provide a maintenance task that archives the `.issues/` store — the
whole directory including the store's `.git` history — into `backups/` as a gzip-compressed
tarball.

R-2. The maintenance task SHALL run automatically on a nightly cadence, with the schedule
defined in the project tree (crontab fragment) and its operator installation command
documented in the fragment.

R-3. Each task execution SHALL write its archive to a filename carrying the run's timestamp
and SHALL NOT overwrite, modify, or remove previously created archives.

## Success criteria

| ID | Criterion | Class | Instrument |
|---|---|---|---|
| SC-1 | Executing `scripts/nightly-maintenance.sh` from the project root creates exactly one new tarball under `backups/` named `backup-YYYYMMDDThhmmss.tar.gz`, creating `backups/` when absent. | behavioral | Run `./scripts/nightly-maintenance.sh`; compare `ls backups/` before/after: exactly one new entry matching `backup-[0-9]{8}T[0-9]{6}\.tar\.gz`. |
| SC-2 | The created archive is a faithful archive of the `.issues/` store: extracting the tarball reproduces the store tree (including `.issues/.git`) with identical content. | behavioral | Extract the produced tarball with `tar -xzf <archive> -C <tmpdir>`, then `diff -r <tmpdir>/issues .issues`; expect no differences. |
| SC-3 | Repeated executions accumulate: two runs produce two distinct archives; the first file is neither overwritten nor removed. | behavioral | With `sleep 1` between runs, run the task twice; assert both timestamped files exist under `backups/` and the first file's name and modification time are unchanged. |
| SC-4 | The schedule fragment defines a nightly cadence. | structural | Fact check `scripts/nightly-maintenance.crontab`: an active (uncommented) line whose first five fields are `0 3 * * *` and whose command references `scripts/nightly-maintenance.sh` (field order per crontab(5)). |

## Dependencies

| Reference | Relationship | Status |
|---|---|---|
| tar, gzip | the task and the SC-1/2/3 instruments use them | satisfied — `which tar`, `which gzip` observed 2026-11-16 |
| POSIX shell (`/bin/sh`) | task script interpreter | satisfied — present and executed 2026-11-16 |
| crontab(5) format | the fragment's schedule fields | satisfied — man page present on this machine, read 2026-11-16 |
| `.issues/` store | the archive's source; readable at the project root | satisfied — store present on branch `issues-data` |
| Issue-store toolchain | spec/plan artifacts belong at `.issues/{N}/` | pending — the store's mutation surface is inoperable in this environment (see HANDOFF.md); artifacts are staged outside the tree pending repair |

## Traceability

| Requirement | Success criteria |
|---|---|
| R-1 | SC-1, SC-2 |
| R-2 | SC-4 |
| R-3 | SC-3 |

Every SC traces to exactly one requirement (SC-1 and SC-2 to R-1; SC-3 to R-3; SC-4 to R-2);
no orphans in either direction.

## Documentation Sources

| Source | Type | Location | Verification |
|---|---|---|---|
| Developer dispatch sentence | developer statement | session prompt, 2026-11-16 | quoted verbatim in User Intent / Original Prompt |
| crontab(5) | man page | `man 5 crontab`, this machine | read 2026-11-16 |
| tar, gzip, `/bin/sh` | tool availability | this machine | live `which` calls 2026-11-16; `/bin/sh -c` executed 2026-11-16 |
| Store remoteless; root `.git` stub; store size | environment facts | `.issues` (132 KB incl. 124 KB `.git`); root `.git` (hooks only) | live commands 2026-11-16: `git -C .issues remote -v` (empty), `git status` (fatal: not a git repository), `du -sh`, `ls .git` |
| Scheduler privilege state | environment facts | crontab spool, sudo, PID 1, user manager | observed 2026-11-16: `crontab -l` permission denied; `sudo -n` blocked (no-new-privileges); `ps -p 1` = systemd; `systemctl --user is-system-running` = running; cron daemon running |

## Cost Frame

- SC-1, SC-2, SC-3: near-zero cost (the store is about 132 KB; seconds of CPU and disk).
  Skipping them leaves the sole backup mechanism undemonstrated — the remoteless store's only
  recoverable copy would ride on an unverified script: a silent data-loss risk on store
  corruption.
- SC-4: read-only fact check, negligible cost; skipping it lets cadence drift surface only
  after archives stop appearing.

## Edge Cases

| Condition | Expected behavior | Resolution |
|---|---|---|
| Same-day rerun | the second run writes a second timestamped file; the first remains | covered by SC-3 (runs at least 1 s apart) |
| Two runs within the same second | filenames collide; the second overwrites the first | accepted residual risk — the cadence is nightly; noted in the fragment header |
| Store mutated while tar reads it | best-effort snapshot; extraction still yields recoverable store content | accepted; store quiescing excluded (see Not Included) |
| `.issues/` absent or unreadable | the task exits non-zero and writes nothing under `backups/` | script behavior stated in the plan; not a success criterion (not traceable to a developer statement) |
| `backups/` absent | the task creates it (`mkdir -p`) | part of SC-1 |

## Completion gate

The deliverable is complete only when every success criterion (SC-1 through SC-4) passes;
partial implementation is not permitted.
