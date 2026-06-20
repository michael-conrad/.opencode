# Plan — `local-issues` Legacy Slug Detection and Remediation

**Spec:** [michael-conrad/.opencode#1309](https://github.com/michael-conrad/.opencode/issues/1309)
**Goal:** Detect legacy slug-format issue directories and warn AI agents for manual remediation; then remediate all skill task files to use `{N}` flat path.
**Architecture:** 2-phase: tool detection → skill task file remediation.
**Tech Stack:** Python 3.12+ (tool side), Markdown (skill task files).

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Dependency Order

**Phase 1 → Phase 2.** Phase 1 (tool detection) must be implemented first because Phase 2 (task file remediation) removes the slug formats that Phase 1 detects. Phase 1 also validates the strict `{N}` lookup before task files reference it.

Confirmed SAT: `phase_1 = 1, phase_2 = 2`. Solve contract at `.issues/1309/dependency-ordering-verification/ordering.yaml`.

---

## Phase 1: Tool Detection + Strict Lookup

**Concern:** Core tool changes — add legacy format detection, warning logic, strict `{N}` lookup.
**Files:** `.opencode/tools/local-issues`
**SCs covered:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7

### Pre-RED Common

- [ ] 1. **Read approved spec** (**inline**). Read spec at [michael-conrad/.opencode#1309](https://github.com/michael-conrad/.opencode/issues/1309) Phase 1 SCs. Confirm all 7 SCs before implementation. → SC-1 through SC-7
- [ ] 2. **Read target tool** (**inline**). Read `.opencode/tools/local-issues` to understand:
  - Main dispatch loop (`main()`, `command_map`)
  - `_find_issue_dir()` and `_find_issue_dir_in_repo()` (slug/padded lookup patterns to remove)
  - Current `cmd_close()` (no `open/`/`closed/` subdirectory handling)
  - Any existing sentinel/warning mechanism
  → SC-1, SC-2, SC-5, SC-7

### Per-Item RED+green Chains

- [ ] 3. **TDD-1: Legacy slug/symlink detection and generic warning** (SC-1, SC-2)
  - [ ] 3a. **RED: No warning exists for legacy formats** (**inline**). Run `local-issues list` in a repo with `.issues/open/` subdirectory or `.issues/1309-legacy-slug/` dir. Confirm zero stderr output about legacy formats.
  - [ ] 3b. **GREEN: Add legacy detection to dispatch** (**clean-room**). In `main()` (or a helper called at the start of every command), add logic to scan `.issues/` for:
    - `.issues/open/` or `.issues/closed/` subdirectories → generic warning
    - Any directory matching `{N}-{slug}` pattern (regex: `^\d+-.+`) → generic warning
    Warning text: generic, non-prescriptive (SC-3). → SC-1, SC-2

- [ ] 4. **TDD-2: Non-prescriptive warning language** (SC-3)
  - [ ] 4a. **RED: Warning prescribes fix steps** (**inline**). After TDD-1 GREEN, verify the warning tells the AI agent what to do (inspection step), not how. If it uses `run X` or `execute Y`, that is prescriptive.
  - [ ] 4b. **GREEN: Make warning generic** (**clean-room**). Rewrite warning to state the facts and direct the AI agent to inspect and remediate manually. Example: "Warning: Legacy issue directory format detected in .issues/. AI agent must inspect and remediate manually." No specific fix steps. → SC-3

- [ ] 5. **TDD-3: Silent ignore for non-legacy dirs** (SC-4)
  - [ ] 5a. **RED: Non-legacy dirs trigger warning** (**inline**). Run `local-issues list` in a repo with `.issues/research-cards/`, `.issues/templates/`, non-numeric dirs, and files. Confirm no warning fires for these.
  - [ ] 5b. **GREEN: Add ignore filter** (**clean-room**). Ensure detection logic skips:
    - Directories without numeric prefix (e.g., `research-cards/`, `templates/`)
    - Files (not directories)
    - `.issues/open/` (the subdirectory itself is structural, not a legacy issue)
    → SC-4

- [ ] 6. **TDD-4: Strict `{N}` lookup** (SC-5)
  - [ ] 6a. **RED: `_find_issue_dir()` accepts padded/slug variants** (**inline**). Confirm current `_find_issue_dir()` matches `1309-*` and `001-*` patterns via `startswith()`.
  - [ ] 6b. **GREEN: Strip slug/padded lookup** (**clean-room**). Remove padded (`{N:03d}`) and slug (`{N}-{title}`) prefix matching from `_find_issue_dir()` and `_find_issue_dir_in_repo()`. Keep only strict `{N}` exact match (line 68-72: `issues_dir / prefix`). Remove `open/` subdirectory traversal. → SC-5

- [ ] 7. **TDD-5: Once-per-session sentinel** (SC-6)
  - [ ] 7a. **RED: Warning fires on every command** (**inline**). Run `local-issues list` twice. Confirm warning fires both times (no sentinel).
  - [ ] 7b. **GREEN: Add sentinel file** (**clean-room**). After first warning emission, write `.issues/.legacy-warned` sentinel file. Check for sentinel before emitting warning on subsequent commands. → SC-6

- [ ] 8. **TDD-6: No warning on help/version** (SC-7)
  - [ ] 8a. **RED: Warning fires on `help`/`version`** (**inline**). Run `local-issues --help` and `local-issues --version` (or equivalent). If warning fires, RED passes.
  - [ ] 8b. **GREEN: Gate detection behind non-help/version commands** (**clean-room**). Add early return in `main()` for help/version before legacy detection runs. → SC-7

### Post-RED/green

- [ ] 9. **Verification before completion** (**clean-room**). Run `verification-before-completion` to verify all Phase 1 SCs (SC-1 through SC-7):
  - SC-1: Legacy `.issues/open/` subdirectory triggers warning
  - SC-2: Legacy `{N}-{slug}` directory triggers warning
  - SC-3: Warning is generic, non-prescriptive
  - SC-4: Non-issue dirs silently ignored
  - SC-5: `_find_issue_dir()` does not match padded/slug variants
  - SC-6: Warning fires at most once per session
  - SC-7: No warning on `help`/`version`
- [ ] 10. **Finishing checklist** (**clean-room**). Run `finishing-a-development-branch` — git status clean, lint/typecheck pass.
- [ ] 11. **Review prep** (**clean-room**). Run `requesting-code-review` — prepare PR with summary, outcome, and compare URL.

---

## Phase 2: Skill Task File Remediation

**Concern:** Documentation — update all skill task files to reference `{N}` flat path instead of slug/subdirectory patterns.
**Files:**
- `.opencode/skills/issue-operations/platforms/local/SKILL.md`
- `.opencode/skills/issue-operations/platforms/local/tasks/close.md`
- `.opencode/skills/issue-operations/platforms/local/tasks/delete.md`
- `.opencode/skills/issue-operations/tasks/import-remote.md`
- `.opencode/skills/issue-operations/tasks/creation.md`
- `.opencode/skills/issue-operations/tasks/body-edit.md`
- `.opencode/skills/issue-operations/tasks/sync-pull-to-local.md`

**SCs covered:** SC-8, SC-9, SC-10, SC-11, SC-12, SC-13, SC-14

### Pre-RED Common

- [ ] 1. **Read approved spec** (**inline**). Read spec at [michael-conrad/.opencode#1309](https://github.com/michael-conrad/.opencode/issues/1309) Phase 2 SCs. Confirm all 7 SCs before implementation. → SC-8 through SC-14
- [ ] 2. **Glob affected task files** (**inline**). List all task files in `.opencode/skills/issue-operations/` to confirm the 7 target files and check for any new file additions since spec creation.

### Per-Item RED+green Chains

- [ ] 3. **TDD-7: `platforms/local/SKILL.md` architecture diagram** (SC-8)
  - [ ] 3a. **RED: Diagram shows slug/zero-pad** (**inline**). Grep `platforms/local/SKILL.md` for `001-slug`, `NNN-slug`, `{N:03d}`, or any slug/zero-padded patterns in the architecture diagram section.
  - [ ] 3b. **GREEN: Update diagram to `{N}`** (**clean-room**). Replace all slug and zero-padded references in the architecture diagram with `{N}/` flat path. → SC-8

- [ ] 4. **TDD-8: `platforms/local/tasks/close.md`** (SC-9)
  - [ ] 4a. **RED: Grep for slug/subdir patterns** (**inline**). Grep for `NNN-slug`, `{N}-{slug}`, `open/`, `closed/`, and slug-related references in `close.md`.
  - [ ] 4b. **GREEN: Replace with `{N}`** (**clean-room**). Replace all slug-based, open/closed subdirectory references with `{N}` flat path. → SC-9

- [ ] 5. **TDD-9: `platforms/local/tasks/delete.md`** (SC-10)
  - [ ] 5a. **RED: Grep for slug/subdir patterns** (**inline**). Grep for `NNN-slug`, `open/`, `closed/` in `delete.md`.
  - [ ] 5b. **GREEN: Replace with `{N}`** (**clean-room**). Replace all slug-based, open/closed subdirectory references with `{N}` flat path. → SC-10

- [ ] 6. **TDD-10: `tasks/import-remote.md`** (SC-11)
  - [ ] 6a. **RED: Grep for slug/subdir patterns** (**inline**). Grep for "first 5 words, kebab-cased", `{N}-{slug}`, `NNN-slug`, `open/` in `import-remote.md`.
  - [ ] 6b. **GREEN: Remove slug algorithm, update paths** (**clean-room**). Remove the "first 5 words, kebab-cased" slug algorithm. Replace all `{N}-{slug}` → `{N}`, `NNN-slug` → `{N}`, `open/` → flat `.issues/`. → SC-11

- [ ] 7. **TDD-11: `tasks/creation.md`** (SC-12)
  - [ ] 7a. **RED: Grep for slug patterns** (**inline**). Grep for `{N}-{slug}`, `NNN-slug` in `creation.md`.
  - [ ] 7b. **GREEN: Replace with `{N}`** (**clean-room**). Replace all slug references with `{N}`. → SC-12

- [ ] 8. **TDD-12: `tasks/body-edit.md`** (SC-13)
  - [ ] 8a. **RED: Grep for `{N}-{slug}` pattern** (**inline**). Grep for `N-slug`, `{N}-{slug}` in `body-edit.md`.
  - [ ] 8b. **GREEN: Replace with `{N}`** (**clean-room**). Replace `N-slug` → `{N}`. → SC-13

- [ ] 9. **TDD-13: `tasks/sync-pull-to-local.md`** (SC-14)
  - [ ] 9a. **RED: Grep for slug patterns** (**inline**). Grep for `{N}-{slug}`, `NNN-slug` in `sync-pull-to-local.md`.
  - [ ] 9b. **GREEN: Replace with `{N}`** (**clean-room**). Replace all slug references with `{N}`. → SC-14

### Post-RED/green

- [ ] 10. **Phase 2 regression verification** (**clean-room**). Verify all task files are free of slug/subdirectory patterns. Grep each file for remaining `{N}-{slug}`, `NNN-slug`, `open/` context paths, and slug algorithm references.
- [ ] 11. **Verification before completion** (**clean-room**). Run `verification-before-completion` to verify all Phase 2 SCs (SC-8 through SC-14).
- [ ] 12. **Finishing checklist** (**clean-room**). Run `finishing-a-development-branch` — git status clean, lint/typecheck pass.
- [ ] 13. **Review prep** (**clean-room**). Run `requesting-code-review` — prepare PR with summary, outcome, and compare URL.

---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## SC-ID Mapping

| SC-ID | Plan Phase | TDD Item | Evidence Type |
|-------|-----------|----------|---------------|
| SC-1 | Phase 1 | TDD-1 (step 3) | behavioral |
| SC-2 | Phase 1 | TDD-1 (step 3) | behavioral |
| SC-3 | Phase 1 | TDD-2 (step 4) | string |
| SC-4 | Phase 1 | TDD-3 (step 5) | behavioral |
| SC-5 | Phase 1 | TDD-4 (step 6) | behavioral |
| SC-6 | Phase 1 | TDD-5 (step 7) | string |
| SC-7 | Phase 1 | TDD-6 (step 8) | behavioral |
| SC-8 | Phase 2 | TDD-7 (step 3) | string |
| SC-9 | Phase 2 | TDD-8 (step 4) | string |
| SC-10 | Phase 2 | TDD-9 (step 5) | string |
| SC-11 | Phase 2 | TDD-10 (step 6) | string |
| SC-12 | Phase 2 | TDD-11 (step 7) | string |
| SC-13 | Phase 2 | TDD-12 (step 8) | string |
| SC-14 | Phase 2 | TDD-13 (step 9) | string |

**Plan:** See [plan.md](.issues/1309/plan.md) for the implementation plan.
