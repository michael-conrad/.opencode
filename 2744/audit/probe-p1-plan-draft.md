# Plan: probe-home#3 — Nightly .issues/ archive task

> STAGED DRAFT — filed at `.issues/3/plan.md` after the issue-store repair (see HANDOFF.md
> beside this file). The implementation consumes this plan only after (a) the spec-approval
> gate and (b) this plan's fresh-context validation dispatch (plan card rule 7) pass.

## Goal

Implement issue probe-home#3's deliverable: a maintenance task that archives the whole
`.issues/` store — including the store's `.git` history — to a per-run timestamped gzip
tarball under `backups/`, plus the project-tree crontab fragment defining the nightly cadence.
The change introduces exactly two new files, `scripts/nightly-maintenance.sh` and
`scripts/nightly-maintenance.crontab`, plus the runtime-written `backups/` directory; the
spec's success criteria SC-1 through SC-4 (probe-home#3/spec.md) bound completion.

## Execution surface

- Repository: the session's project root (root-agnostic; this session's root arrives via
  session-init — currently `/tmp/opencode/deck-fix/probe-home`). The root has no functioning
  git repository (`.git` holds only `hooks/`; evidenced 2026-11-16): work lands in the working
  tree without commits, and this plan does not initialize version control (outside the spec's
  scope).
- Branch: none — no version-control surface exists. The issue store's surface is separately
  halted (worktree establishment fails over the host stub; recorded in the issue's report);
  this plan and the spec file into `.issues/3/` after that repair.
- Environment facts the items depend on: `tar`, `gzip`, `/bin/sh` present (verified
  2026-11-16); `.issues/` readable at the project root; `scripts/` and `backups/` do not yet
  exist at the root — both items' REDs are grounded in that absence.

## Items

**Item 1 — the archive task (implements SC-1, SC-2, SC-3).**

- **Deliverable:** `scripts/nightly-maintenance.sh`, executable, POSIX `#!/bin/sh`: from the
  project root, `mkdir -p backups`; `STAMP=$(date +%Y%m%dT%H%M%S)`; `tar -czf
  "backups/backup-$STAMP.tar.gz" -C <project-root> .issues`; when `.issues/` is absent or
  unreadable, exit non-zero without writing anything under `backups/`.
- **RED:** today the task does not exist — `scripts/nightly-maintenance.sh` is absent and no
  archive is produced under `backups/` (both evidenced 2026-11-16), so "executing the task
  creates a timestamped archive under backups/" fails.
- **GREEN:** create the script with the steps above. The archive step only reads `.issues/`
  and adds a new timestamped file — rerunning is safe by construction; nothing under
  `backups/` or `.issues/` is ever overwritten, modified, or removed by this step.
- **Tier marks:** no test files authored; the item relies on runtime fact checks executed
  directly (scratch observation stays out of test files, test-discipline).
- **Instrument:** run `./scripts/nightly-maintenance.sh`; before/after `ls backups/` shows
  exactly one new entry matching `backup-[0-9]{8}T[0-9]{6}\.tar\.gz` (SC-1). Extract with
  `tar -xzf` into a temp directory and `diff -r <tmpdir>/issues .issues` — expect no
  differences (SC-2). With `sleep 1` between runs, run the task twice; both files exist and
  the first file's name and modification time are unchanged (SC-3).

**Item 2 — the schedule fragment (implements SC-4).**

- **Deliverable:** `scripts/nightly-maintenance.crontab` — a header comment carrying (a) the
  operator install command, append-style:
  `(crontab -l 2>/dev/null; sed "s|@@PROJECT_ROOT@@|<this-root>|" scripts/nightly-maintenance.crontab) | crontab -`
  with the note that appending never replaces the existing spool, and (b) the same-second
  collision acceptance; then the active line:
  `0 3 * * * @@PROJECT_ROOT@@/scripts/nightly-maintenance.sh`
- **RED:** today `scripts/nightly-maintenance.crontab` does not exist (evidenced 2026-11-16),
  so the cadence fact check has no file to pass.
- **GREEN:** create the fragment with the content above; item 1's script exists at this point
  (item order below).
- **Tier marks:** no test files authored; fact check only.
- **Instrument:** `grep -E '^0 3 \* \* \*' scripts/nightly-maintenance.crontab` shows the
  cadence fields with the command referencing `scripts/nightly-maintenance.sh` (field order
  per the crontab(5) man page, present on this machine).

## Dependency order

Item 1 precedes item 2: the fragment's command references `scripts/nightly-maintenance.sh`,
so the script exists before the schedule names it. Item 2 does not otherwise depend on item
1's runtime state — the order serves the surface; no cycle exists (item 1's RED and GREEN
depend on nothing from item 2).

## Traceability

| Item | SC(s) |
|---|---|
| Item 1 | SC-1, SC-2, SC-3 |
| Item 2 | SC-4 |

Every SC is covered and every item traces to at least one SC; no orphans in either direction.
SC-1, SC-2, SC-3 are three instruments over one change — the script's archive step is one
concern (produce the correct timestamped archive; accumulate safely on rerun), verified per
facet; SC-4 is a separate file and a separate item.

## Verification summary

No authored tests. All verification runs at cycle time: runtime fact checks executing the
real script (SC-1, SC-2, SC-3 instruments) and a read-only content fact check (SC-4
instrument). Nothing runs by default beyond these instruments; no heavy tier exists in this
change. If a PR-check surface ever exists for this project (no functioning git repository
today), the same read-only instruments re-run unchanged at PR-check time.

## Status boundary

This plan body carries no STATUS fields, completion markers, or progress indicators;
implementation state lives in the pipeline, and the issue's validation record
(`.issues/3/audit/validation.yaml`, written after the store's repair) owns loop history.
