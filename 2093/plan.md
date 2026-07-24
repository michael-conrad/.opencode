---
plan_schema_version: "1.0"
issue: 2093
title: "local-issues: scope repo discovery to .gitmodules instead of filesystem glob"
authorization_scope: for_implementation
pr_strategy: stacked
phase_count: 2
---

# Implementation Plan — #2093 — Scope repo discovery to .gitmodules

**Goal:** Refactor `_discover_all_repos()` in `.opencode/tools/local-issues` to parse `.gitmodules` instead of using a filesystem glob pattern for child repo discovery.

**Architecture:** Replace the glob-based discovery (`*/.git/`, `*/.git` patterns) with `.gitmodules` parsing via `git config -f .gitmodules`. The root repo is always included first. Child repos come exclusively from `.gitmodules` entries. Worktree detection logic remains separate.

**Files:**
- `.opencode/tools/local-issues` — `_discover_all_repos()` function (lines 203-239)
- `.issues/AGENTS.md` — minor doc update
- `.opencode/.issues/AGENTS.md` — minor doc update

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Refactor `_discover_all_repos()` | `test-driven-development` | `green` | `.opencode/tools/local-issues` | SC-1, SC-2, SC-3, SC-4, SC-6 | — |
| 2 — Update AGENTS.md docs | `test-driven-development` | `green` | `.issues/AGENTS.md`, `.opencode/.issues/AGENTS.md` | SC-5 | 1 |

---

## Phase Details

### Phase 1 — Refactor `_discover_all_repos()`

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `.opencode/tools/local-issues` |
| SCs | SC-1, SC-2, SC-3, SC-4, SC-6 |
| Depends On | — |

**Context:**
```yaml
file: .opencode/tools/local-issues
function: _discover_all_repos() (lines 203-239)
approach:
  - Parse .gitmodules using `git config -f .gitmodules --list` or Python configparser
  - Root repo is always first entry (index 0)
  - Child repos appended in .gitmodules order
  - Worktree detection (_worktree_active, _ensure_worktree) remains separate
  - Current .gitmodules has one entry: .opencode
sc_ids:
  - SC-1: "_discover_all_repos() parses .gitmodules instead of filesystem glob"
  - SC-2: "Root repo is always included regardless of .gitmodules"
  - SC-3: "Child repos come exclusively from .gitmodules entries"
  - SC-4: ".issues/ worktrees are not treated as submodules"
  - SC-6: "_ensure_all_worktrees() creates worktrees only for repos discovered via .gitmodules"
```

### Phase 2 — Update AGENTS.md docs

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `.issues/AGENTS.md`, `.opencode/.issues/AGENTS.md` |
| SCs | SC-5 |
| Depends On | 1 |

**Context:**
```yaml
files:
  - .issues/AGENTS.md
  - .opencode/.issues/AGENTS.md
change: "Update any references to repo discovery mechanism if present"
sc_ids:
  - SC-5: "All existing commands continue to work with new discovery"
```

---

## Pre-Implementation

- [ ] 1. **Coherence gate (**clean-room**).** Verify spec #2093 is approved. Read the current `_discover_all_repos()` function to confirm the glob-based implementation. **→ pre-flight**
- [ ] 2. **Baseline check (**clean-room**).** Run `local-issues list` to capture current output. Run `cat .gitmodules` to confirm current submodule entries. **→ pre-flight**

---

## Phase 1 — Refactor `_discover_all_repos()`

**Concern:** Replace glob-based repo discovery with `.gitmodules`-based discovery.

**Files:**
- `.opencode/tools/local-issues`

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-6

**Dependencies:** None

**Entry Conditions:**
- Coherence gate passed
- Baseline check confirmed current behavior

**Exit Conditions:**
- `_discover_all_repos()` parses `.gitmodules` instead of glob
- Root repo always included first
- Child repos from `.gitmodules` only
- Worktree detection logic is separate from repo discovery

---

- [ ] 3. **GREEN (**sub-agent**).** Refactor `_discover_all_repos()` in `.opencode/tools/local-issues`: replace glob-based discovery with `.gitmodules` parsing using `git config -f .gitmodules --list` or Python configparser. Root repo is always first. Child repos from `.gitmodules` entries only. Keep worktree detection separate. **→ SC-1, SC-2, SC-3, SC-4, SC-6**
- [ ] 4. **GREEN doublecheck (**clean-room**).** Verify: grep for `*/.git` glob patterns removed from `_discover_all_repos()`. Verify root repo is always appended first. Verify `.gitmodules` parsing is present. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 5. **Behavioral check (**clean-room**).** Run `local-issues list` and verify output matches baseline (root repo + `.opencode` submodule). **→ SC-5**
- [ ] 6. **Checkpoint commit (**inline**).** Commit the refactored `_discover_all_repos()`.

#### Phase 1 VbC

- [ ] 7. **VbC (**clean-room**).** Verify all SCs: SC-1 (grep for `.gitmodules` parsing), SC-2 (root always included), SC-3 (child repos from `.gitmodules` only), SC-4 (worktree detection separate), SC-6 (worktrees only for root + `.opencode`). **→ SC-1, SC-2, SC-3, SC-4, SC-6**

---

## Phase 2 — Update AGENTS.md docs

**Concern:** Update documentation to reflect the new discovery mechanism.

**Files:**
- `.issues/AGENTS.md`
- `.opencode/.issues/AGENTS.md`

**SCs:** SC-5

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete and VbC passed

**Exit Conditions:**
- Documentation reflects `.gitmodules`-based discovery

---

- [ ] 8. **GREEN (**sub-agent**).** Update `.issues/AGENTS.md` and `.opencode/.issues/AGENTS.md` if they reference the old glob-based discovery mechanism. **→ SC-5**
- [ ] 9. **GREEN doublecheck (**clean-room**).** Verify docs are consistent with the new implementation. **→ SC-5**
- [ ] 10. **Checkpoint commit (**inline**).** Commit doc updates.

#### Phase 2 VbC

- [ ] 11. **VbC (**clean-room**).** Verify SC-5: `local-issues list` output matches baseline. **→ SC-5**

---

## Post-Implementation

- [ ] 12. **Structural checks (**sub-agent**).** Run lint/format checks on modified files. **→ post-flight**
- [ ] 13. **Audit (**sub-agent**).** Dispatch verification-audit for the refactor. **→ post-flight**
- [ ] 14. **Cross-validate (**clean-room**).** Verify audit findings against evidence artifacts. **→ post-flight**
- [ ] 15. **Review prep (**sub-agent**).** Prepare PR with summary of the refactor. **→ post-flight**
- [ ] 16. **Create PR (**sub-agent**).** Create pull request for the feature branch. **→ post-flight**
- [ ] 17. **Completion (**sub-agent**).** Report summary with PR URL. **→ post-flight**

---

## Exit Criteria

- [ ] C1. `_discover_all_repos()` parses `.gitmodules` instead of filesystem glob
- [ ] C2. Root repo is always included regardless of `.gitmodules`
- [ ] C3. Child repos come exclusively from `.gitmodules` entries
- [ ] C4. `.issues/` worktrees are not treated as submodules
- [ ] C5. All existing commands continue to work with the new discovery
- [ ] C6. `_ensure_all_worktrees()` creates worktrees only for repos discovered via `.gitmodules`
