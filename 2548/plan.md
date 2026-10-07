# PLAN: `.opencode#2548` — worktree-store operational friction

Derived entirely from `spec.md` in this directory. One item per SC, dependency
ordered. Branch: `feature/2548-issues-store-friction` (base b2f357f7).
Behavioral SCs execute in a sandbox copy under `/tmp/opencode/sbx2548/` — the
tool is copied to `sbx/.opencode/tools/local-issues` so `PROJECT_DIR` resolves
to the sandbox root (script location derivation, local-issues:41-47).

## Item 1 — C1 → SC-1 (stop empty sync commits)

- Deliverable: `_fetch_issues_branch` (local-issues:1717-1735) skips
  add/commit when `git status --porcelain` is empty.
- RED: sandbox: run `local-issues sync` twice; `git -C .issues rev-list
  --count HEAD` increases on an up-to-date store. Fails today (spec F1).
- GREEN: reuse the `_stage_issues_changes` early-return check (931-941) in the
  fetch path; commit only when there are staged changes.
- Verify: spec SC-1 instrument — counts unchanged after two syncs; no new
  `auto: sync` commits in `git -C .issues log --oneline -3`.

## Item 2 — C2 → SC-2 (push-failure visibility + one retry)

- Deliverable: `_push_issues_changes` (969-998) and
  `_push_issues_branch_safe` (1757-1769) retry once on transient-looking
  failures; `cmd_sync`/`cmd_init` (1800-1817) exit non-zero when any repo
  status is not `ok`.
- RED: sandbox: point origin at an unreachable URL, run `local-issues sync; echo $?` → 0 today.
- GREEN: bounded retry (one attempt after first failure, transient-classified
  stderr only); after YAML print, `sys.exit(1)` when any entry status ∈
  {push_failed, conflict, timeout, rebase_in_progress, add_failed,
  commit_failed}. YAML output unchanged.
- Verify: spec SC-2 instrument — non-zero exit with `status: push_failed` in
  YAML; restore origin → exit 0.

## Item 3 — C3 → SC-3 (mid-rebase detection)

- Deliverable: rebase-state detection (`rebase-merge`/`rebase-apply` under the
  worktree's git dir) before `_rebase_issues_branch` runs and at `_sync_repo`
  entry; `status: rebase_in_progress` with `git rebase --abort` / resolve +
  `--continue` guidance replacing the pull-again `conflict_hint` (1738-1754,
  1787).
- RED: sandbox: create divergent commits, trigger a `pull --rebase` stop, run
  `sync` → hint says `pull --rebase` today (spec F3).
- GREEN: detection helper + new status/hint; conflict hint updated.
- Verify: spec SC-3 instrument — YAML `status: rebase_in_progress`, hint names
  abort/continue, never `pull --rebase`.
- Doc rider: update the conflict guidance bullet in
  `skills/issues/references/sync-mirroring.md` (deck governance with item 8).

## Item 4 — C4 → SC-4 (bootstrap disambiguation)

- Deliverable: `_bootstrap_from_remote` (566-632) distinguishes "fetch failed"
  from "remote ref absent" (`git ls-remote origin issues-data` /
  `refs/remotes/origin/issues-data` verify); on fetch failure with a
  possibly-existing remote branch, fail fatal via `_fail_worktree` (749-764)
  instead of falling through to `_create_orphan_branch` (525-563).
- RED: sandbox clone with unreachable origin and no local `issues-data`: `init`
  mints an empty orphan today (spec F4).
- GREEN: fetch-failure → fatal error naming remediation (retry when network
  recovers); only verified-absent remote proceeds to orphan creation.
- Verify: spec SC-4 instrument — non-zero exit, remediation in stderr, no
  local `issues-data` minted.

## Item 5 — C5 → SC-5, SC-6 (legacy remediation + unmute)

- Deliverable: (a) remediate both live stores: remove `open/`, `closed/`,
  top-level `NNN-slug` dirs; preserve non-colliding content under a name
  `_parse_number` rejects (e.g. `_legacy/`); collision twins (`4`, `9`,
  `1158` root store) resolved by explicit content comparison before deletion;
  remove committed `.legacy-warned` sentinels. (b) `_check_legacy_formats`
  (2221-2260): warn every run, drop the sentinel write. (c) Align
  `.opencode/.issues/AGENTS.md` "Directory Layout" — remove `open/`/`closed/`.
- RED: structural — legacy dirs exist today; `grep legacy-warned` shows the
  sentinel write path; sentinel committed in branch history.
- GREEN: store hygiene (authorization-free per hygiene mandate) + code change
  + guide edit.
- Verify: spec SC-5 + SC-6 instruments verbatim.

## Item 6 — C6 → SC-7 (duplicate detection honors _parse_number)

- Deliverable: `_check_duplicate_issue` (1023-1036) refuses when any dir in
  the target store parses to the requested number (via `_parse_number`),
  not only exact `{N}`.
- RED: pre-remediation sandbox with a `NNN-slug` dir: `create` passes
  duplicate detection (spec F5.1). (Live root store evidence: `list` shows
  `opencode-config#1075` while `read` errors not-found.)
- GREEN: scan store entries with `_parse_number`; exit 1 on any match.
- Verify: spec SC-7 instrument — loop over `list` rows, `read` each → zero
  not-found (post-remediation this is the safety-net confirmation).

## Item 7 — C8 → SC-8 (deck protection language)

- Deliverable: `issues-data` reserved-ref protection text in
  `git-workflow-cleanup/SKILL.md` and `git-workflow-branch/SKILL.md`.
- Deck-governance-gated edit (skill-creator card loads first).
- Verify: spec SC-8 instrument — grep, ≥1 protective-context match per file.

## Item 8 — C10 → SC-9 (sync-mirroring init description)

- Deliverable: `skills/issues/references/sync-mirroring.md` describes `init`
  as ensure-worktrees + commit + pull-rebase + push.
- Deck-governance-gated edit.
- Verify: spec SC-9 instrument.

## Item 9 — C11 → SC-10 (nesting-quirk documentation)

- Deliverable: canonical guide (`.opencode/.issues/AGENTS.md`) gains a short
  "Git display quirks" note: (a) submodule `git worktree list` gitdir display,
  (b) `git submodule status` `+` meaning, (c) guide readability bootstrap
  order. Issue-data hygiene territory.
- Verify: spec SC-10 instrument.

Dependency order: 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 (each builds on verified
prior state; store remediation precedes the duplicate-guard confirmation).
