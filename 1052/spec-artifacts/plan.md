# Plan: [#1052](https://github.com/michael-conrad/.opencode/issues/1052) — Remove instructional language from PR body format

## Overview

Single-phase fix: 4 exact string changes across 2 files in `.opencode/skills/git-workflow/tasks/`.

## Changes

| # | File | Location | Old | New |
|---|------|----------|-----|-----|
| 1 | `pr-creation/create-pr.md` Step 7.5 | Mandated format example | Remove `Wait for human to merge.` line from example | (omit) |
| 2 | `pr-creation/create-pr.md` Step 7.5 | Format requirements list | Remove `MUST include "Wait for human to merge"` | (omit) |
| 3 | `pr-creation.md` | Operating Protocol step 4 | `Wait for human to merge` | `No prompting for next steps` |
| 4 | `pr-creation.md` | Exit Criteria | `Agent HALTs waiting for human merge` | `Agent reports PR URL and HALTs — no prompting for next steps` |

## Pipeline Gates (Phase 1 — single phase)

| # | Gate | Exit Criterion |
|---|------|----------------|
| 1 | sc-coherence-gate | 4 changes match issue spec exactly; no scope creep |
| 2 | pre-red-baseline | Live grep confirms all 4 old strings exist |
| 3 | red-phase | Behavioral test: agent told "create PR" with instructional language → stderr shows old pattern |
| 4 | red-doublecheck | Failure is missing fix, not harness issue |
| 5 | green-phase | All 4 edits applied |
| 6 | checkpoint-commit | Edits committed |
| 7 | structural-checks | grep on `Wait for human` returns 0 matches in both files |
| 8 | green-doublecheck | RED test now PASSES — no instructional language |
| 9 | green-vbc | SC-1 through SC-4 verified |
| 10 | adversarial-audit | No other instructional language patterns remain in these files |
| 11 | cross-validate | Both auditors agree |
| 12 | regression-check | grep on `Wait for human` across entire `.opencode/skills/` returns 0 |
| 13 | review-prep | PR body drafted: 4 string changes summary |
| 14 | exec-summary | Phase complete |

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `create-pr.md` format example has no "Wait for human to merge." | `behavioral` |
| SC-2 | `create-pr.md` requirements have no "Wait for human to merge" | `string/grep` |
| SC-3 | `pr-creation.md` protocol says "No prompting for next steps" | `string/grep` |
| SC-4 | `pr-creation.md` exit says "Agent reports PR URL and HALTs" | `string/grep` |

## Dispatch Markers

| Phase | Marker |
|-------|--------|
| 1 | `pr-body-instructional-fix` |