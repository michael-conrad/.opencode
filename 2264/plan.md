---
plan_schema_version: "1.0"
issue: 2264
title: "Pre-commit hook per-submodule trunk lookup for stale-pointer check"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 7
---

# Implementation Plan — #2264 — Per-Submodule Trunk Lookup in Pre-commit Gate 2

**Issue:** [.opencode #2264](https://github.com/michael-conrad/.opencode/issues/2264)

**Goal:** Fix the pre-commit hook's stale-pointer check so each submodule's remote trunk tip is derived from that submodule's own `HEAD branch:` line, falling back to the parent trunk only on lookup failure, eliminating the false-positive block when a submodule's trunk differs from the parent's.

**Architecture:** Replace the single shared `DEFAULT_BRANCH`-based submodule rev-parse in `.opencode/hooks/pre-commit` Gate 2 with a per-submodule `SUBMODULE_TRUNK` extraction from `git -C "$sp" remote show origin`, with a parent-trunk fallback when the lookup yields no `HEAD branch:` line. Behavioral tests verify the different-trunk and shared-trunk cases; documentation references are updated; bug-only `SKIP_STALE_POINTER_CHECK=1` override uses are remediated.

**Files:**
- `.opencode/hooks/pre-commit`
- `.opencode/commands/submodule-tag-prework.md`
- `.opencode/` (repository-wide override-use search)

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Per-submodule trunk lookup | `test-driven-development` | `red` | `.opencode/hooks/pre-commit` Gate 2 | SC-1 | — |
| 2 — Parent-trunk fallback | `test-driven-development` | `red` | `.opencode/hooks/pre-commit` Gate 2 | SC-2 | 1 |
| 3 — Different-trunk submodule not falsely flagged | `test-driven-development` | `red` | `.opencode/hooks/pre-commit` Gate 2 | SC-3 | 1 |
| 4 — Shared-trunk submodule no regression | `test-driven-development` | `red` | `.opencode/hooks/pre-commit` Gate 2 | SC-4 | 1 |
| 5 — Documentation references updated | `test-driven-development` | `red` | `.opencode/commands/submodule-tag-prework.md` | SC-5 | 1 |
| 6 — Two-submodule behavioral verification | `test-driven-development` | `red` | `.opencode/hooks/pre-commit` Gate 2 | SC-6 | 3, 4 |
| 7 — Bug-only override uses removed | `test-driven-development` | `red` | `.opencode/` repository-wide | SC-7 | 1 |

---

## Phase Details

### Phase 1 — Per-submodule trunk lookup

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/hooks/pre-commit` Gate 2 |
| SCs | SC-1 |
| Depends On | — |

**Context:**
```yaml
file: .opencode/hooks/pre-commit
target_line: 54
current: 'REMOTE_SHA=$(git -C "$sp" rev-parse "origin/$DEFAULT_BRANCH" 2>/dev/null || true)'
replacement: 'SUBMODULE_TRUNK=$(git -C "$sp" remote show origin 2>/dev/null | sed -n "s/.*HEAD branch: //p")'
sc_ids: [SC-1]
```

### Phase 2 — Parent-trunk fallback

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/hooks/pre-commit` Gate 2 |
| SCs | SC-2 |
| Depends On | 1 |

**Context:**
```yaml
file: .opencode/hooks/pre-commit
target_line: 54
fallback: '[ -z "$SUBMODULE_TRUNK" ] && SUBMODULE_TRUNK="$DEFAULT_BRANCH"'
sc_ids: [SC-2]
```

### Phase 3 — Different-trunk submodule not falsely flagged

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/hooks/pre-commit` Gate 2 |
| SCs | SC-3 |
| Depends On | 1 |

**Context:**
```yaml
file: .opencode/hooks/pre-commit
scenario: submodule trunk=main, parent trunk=master, staged pointer at submodule's own trunk tip
expected: hook allows the commit
sc_ids: [SC-3]
```

### Phase 4 — Shared-trunk submodule no regression

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/hooks/pre-commit` Gate 2 |
| SCs | SC-4 |
| Depends On | 1 |

**Context:**
```yaml
file: .opencode/hooks/pre-commit
scenario: submodule sharing parent trunk (master), staged pointer at shared trunk tip
expected: hook allows the commit (no regression)
sc_ids: [SC-4]
```

### Phase 5 — Documentation references updated

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/commands/submodule-tag-prework.md` |
| SCs | SC-5 |
| Depends On | 1 |

**Context:**
```yaml
file: .opencode/commands/submodule-tag-prework.md
references: trunk-detection logic (DEFAULT_BRANCH usage in sync steps)
expected: docs describe per-submodule lookup and parent-trunk fallback
sc_ids: [SC-5]
```

### Phase 6 — Two-submodule behavioral verification

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/hooks/pre-commit` Gate 2 |
| SCs | SC-6 |
| Depends On | 3, 4 |

**Context:**
```yaml
file: .opencode/hooks/pre-commit
scenario: verify against SharedPojos (trunk=main) and a shared-trunk submodule (master)
expected: both pass without false positives
sc_ids: [SC-6]
```

### Phase 7 — Bug-only override uses removed

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/` repository-wide |
| SCs | SC-7 |
| Depends On | 1 |

**Context:**
```yaml
search: SKIP_STALE_POINTER_CHECK=1 across .opencode repository
criterion: no invocation attributable solely to this bug; legitimate uses carry a non-bug rationale comment
sc_ids: [SC-7]
```

---

## Exit Criteria

- [ ] C1. `.opencode/hooks/pre-commit` Gate 2 derives each submodule's `REMOTE_SHA` from the submodule's own `HEAD branch:` line, not the parent's `DEFAULT_BRANCH` (SC-1).
- [ ] C2. The hook falls back to `DEFAULT_BRANCH` only when the submodule trunk lookup fails (SC-2).
- [ ] C3. A different-trunk submodule (trunk=`main`, parent=`master`) is no longer falsely flagged as stale when its staged pointer is at its own trunk tip (SC-3).
- [ ] C4. A shared-trunk submodule continues to pass the stale-pointer check without regression (SC-4).
- [ ] C5. Documentation references to the trunk-detection logic describe the per-submodule lookup and parent-trunk fallback (SC-5).
- [ ] C6. The stale-pointer check is verified against at least 2 submodules with known-different trunks (SC-6).
- [ ] C7. No `SKIP_STALE_POINTER_CHECK=1` invocation remains attributable solely to this bug (SC-7).
