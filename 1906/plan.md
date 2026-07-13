# Plan #1906 — Stale [PLAN] remote-search references in guidelines

**Spec:** https://github.com/michael-conrad/.opencode/issues/1906
**Labels:** `spec-fix` `approved-for-pr`
**Branch:** `feature/1903-1905-spec-artifacts-blast-audit`

## Goal

Remove 4 stale references to `[PLAN]` as a GitHub Issue search filter across 3 files. Plans are local `.issues/{N}/plan.md` artifacts — not GitHub Issues — and agents following the stale instructions produce false negatives ("no plan found").

## Architecture

| Concern | Approach |
|---------|----------|
| D1: `020-go-prohibitions.md` | Split `[PLAN]` out of GitHub Issue search into a separate local-file search step |
| D2: `130-authority-source.md` | Add local `.issues/{N}/plan.md` alongside `[SPEC]/[SPEC-FIX]` references |
| D3: `check-cross-spec-overlap.md` exit criteria | Remove `[PLAN]` from issue query, add local plan file note |
| D4: `check-cross-spec-overlap.md` procedure step | Remove `[PLAN]` from filter, replace with local file glob reference |

## Affected Files

| File | Defects |
|------|---------|
| `.opencode/guidelines/020-go-prohibitions.md` | D1: line 206 |
| `.opencode/guidelines/130-authority-source.md` | D2: line 47 |
| `.opencode/skills/approval-gate/tasks/pre-impl/check-cross-spec-overlap.md` | D3: line 15, D4: line 31 |

## Phase Table

| Phase | Steps | Concern | Chain Dep |
|-------|-------|---------|-----------|
| 1 | 1–4 | Remove 4 stale `[PLAN]` references — all independent text substitutions | none |

## Implementation Steps

### Phase 1 — Remove Stale `[PLAN]` References (4 edits, 3 files)

**Step 1 (D1):** Edit `.opencode/guidelines/020-go-prohibitions.md` line 206

Split the stale single-line GitHub Issue search into two steps:
- Step 1: Search GitHub Issues for `[SPEC]`, `[SPEC-FIX]` (remove `[PLAN]`)
- New Step 2: Search local `.issues/{N}/plan.md` files for plan artifacts

**Step 2 (D2):** Edit `.opencode/guidelines/130-authority-source.md` line 47

Add local `.issues/{N}/plan.md` to the overlap detection instructions:
- Before: `` For each open `[SPEC]`/`[PLAN]`/`[SPEC-FIX]` issue, compare file paths. ``
- After: `` For each open `[SPEC]`/`[SPEC-FIX]` issue, and for each local `.issues/{N}/plan.md` file, compare file paths. ``

**Step 3 (D3):** Edit `check-cross-spec-overlap.md` line 15

- Before: `` All open `[SPEC]`, `[PLAN]`, and `[SPEC-FIX]` issues outside the batch queried ``
- After: `` All open `[SPEC]` and `[SPEC-FIX]` issues outside the batch queried, plus local `.issues/{N}/plan.md` files for plan overlap ``

**Step 4 (D4):** Edit `check-cross-spec-overlap.md` line 31

- Before: `` Select issues with `[SPEC]`, `[PLAN]`, or `[SPEC-FIX]` title prefix ``
- After: `` Select issues with `[SPEC]` or `[SPEC-FIX]` title prefix, and glob local `.issues/*/plan.md` for plan overlap ``

## Exit Criteria

- `grep '\[PLAN\]' .opencode/guidelines/020-go-prohibitions.md` returns empty
- `grep '\[PLAN\]' .opencode/guidelines/130-authority-source.md` returns empty
- `grep '\[PLAN\]' .opencode/skills/approval-gate/tasks/pre-impl/check-cross-spec-overlap.md` returns empty
- `020-go-prohibitions.md` contains `local` + `plan` reference in search section
- `check-cross-spec-overlap.md` contains local plan file glob reference

## Self-Review

After all 4 edits, verify with:
```bash
grep -n '\[PLAN\]' \
  .opencode/guidelines/020-go-prohibitions.md \
  .opencode/guidelines/130-authority-source.md \
  .opencode/skills/approval-gate/tasks/pre-impl/check-cross-spec-overlap.md
```
Expected: no matches.
