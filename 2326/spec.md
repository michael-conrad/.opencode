---
remote_issue: 2326
remote_url: https://github.com/michael-conrad/.opencode/issues/2326
promoted_at: 2026-08-26T03:24:33+00:00
---

> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2326/

## Problem

A skill named `spec-auditor` is referenced 22 times across 12 files in the agent deck, but no such skill exists on disk. It was deleted in commit `8feba0ad92060319ee11d62fc9906e674b0fafdf` ("feat(adversarial-audit): Consolidate auditor skills into unified architecture (#469)"), which replaced `skills/spec-auditor/`, `skills/coherence-auditor/`, and `skills/concern-separation-auditor/` with task cards under `skills/adversarial-audit/`; the successor was then renamed `adversarial-audit` → `audit` in commit `5bc22ae6`. The consolidation commits did not update the referring files, so agents following these references attempt to invoke a nonexistent skill, and pipeline gates that name `spec-auditor` as their audit entry point cannot be satisfied as written.

## Scope

- Remediate 18 live references across 9 files (dispatch entry points, Tier 1 guideline, README quality-skills table, skill lists)
- Repoint each live referer to the current on-disk dispatch target: the `audit` skill / `audit/tasks/spec-audit-{investigator,validator,evaluator,arbiter}.md` role chain — verifying intended semantics per site
- Treat the Quality-skills table in `.opencode/README.md` holistically: it lists four potentially stale entries on one row (`spec-auditor`, `guideline-auditor`, `coherence-auditor` from the same deletion; verify `code-size-enforcement`, `plan-fidelity-auditor` existence separately)
- Leave CHANGELOG.md historical entries unchanged (append-only log)

**Out of scope:** redesigning the audit pipeline architecture; content improvements to the successor cards themselves (tracked separately, e.g. #1365, #751); rewriting or reorganizing CHANGELOG history; changes to `docs/` historical records.

## Approach

Update each live referer to point at the verified on-disk successor — the `audit` skill with its `tasks/spec-audit-*` DiMo role-chain cards — choosing per-site semantics: invocation sites (e.g. `issue-operations-core/tasks/post-creation.md`, which invokes `spec-auditor --issue <number>` as the single audit entry point) get working dispatch strings, while listing/table sites get corrected names. Every replacement path must be existence-checked at fix time. Historical-record mentions (CHANGELOG.md, `docs/audit-sc6959-verification.md`) stay untouched.

## Impact

| Risk | Mitigation |
|------|------------|
| Live pipeline gates unfulfillable — e.g. post-creation audit invokes a nonexistent skill | Repoint to paths whose on-disk existence is verified during the fix (SC-2) |
| Mechanical rename breaks site intent — some sites mean "run a spec audit", others merely list skills | Per-site semantic review before each edit |
| Scope creep into adjacent stale names sharing the README row | Bundle only same-row stale entries; verify each directory independently |

Key dependencies: none external — all affected files live in this repository. Call to action: fix-scoping pass over the inventory below, then per-file remediation against the success criteria.

## Removal History (verified)

Deleted in commit `8feba0ad` (#469): `skills/spec-auditor/`, `skills/coherence-auditor/`, `skills/concern-separation-auditor/` → replaced by task cards under `skills/adversarial-audit/` (including `tasks/spec-audit.md`). Renamed `adversarial-audit` → `audit` in commit `5bc22ae6`. Functional successor today: the DiMo role-chain cards `skills/audit/tasks/spec-audit-{investigator,validator,evaluator,arbiter}.md`. CHANGELOG.md documents the skill's former capabilities (`principles` subtask via #791/#792/#793), consistent with removal-without-referer-update.

## Verified Reference Inventory (22 occurrences, 12 files)

Live referers requiring remediation (18 refs, 9 files):

| File | Lines (at triage) | Nature |
|------|-------|--------|
| `.opencode/README.md` | 102 | Quality-skills table lists `spec-auditor` (also lists removed `guideline-auditor`, `coherence-auditor` from same deletion) |
| `.opencode/guidelines/000-critical-rules.md` | 260 | Names `spec-auditor` as a quality gate of the spec-creation pipeline (Tier 1 guideline) |
| `.opencode/skills/issue-operations-core/tasks/post-creation.md` | 20, 27, 30, 42, 47, 57, 83 | Invokes `spec-auditor --issue <number>` as single audit entry point |
| `.opencode/skills/issue-operations-core/tasks/completion.md` | 24, 32, 34, 93 | Auditor-invoked check + invocation instructions |
| `.opencode/skills/issue-operations-core/tasks/pre-creation.md` | 266 | Related-skills list |
| `.opencode/skills/issue-review/tasks/completion.md` | 23 | Evidence check that spec-auditor was invoked |
| `.opencode/skills/verification/tasks/verify.md` | 105 | Listed as invoker of modality-aware verification |
| `.opencode/skills/audit/SKILL.md` | 114 | Prose reference to spec-auditor findings channel |
| `.opencode/skills/sre-runbook/SKILL.md` | 121 | Skills list |

Historical-record mentions (arguably legitimate; assess during fix scoping) — 4 refs, 3 files:

| File | Lines (at triage) |
|------|-------|
| `.opencode/CHANGELOG.md` | 118, 121, 122 |
| `.opencode/docs/audit-sc6959-verification.md` | 21 |

## Root Cause

Commit `8feba0ad` (#469) consolidated three auditor skills into `adversarial-audit` but did not update cross-references in the 9 live referer files. The subsequent rename to `audit` (`5bc22ae6`) compounded drift for any referer updated toward `adversarial-audit` paths.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `grep -rn "spec-auditor" --include="*.md"` over `.opencode/` returns zero hits outside CHANGELOG.md and docs/ historical records | string |
| SC-2 | Every remediated referer points to an on-disk skill/task path (existence verified at fix time) | string |
| SC-3 | README Quality row contains only skills whose directories exist under `.opencode/skills/` | string |

## Dedup Evidence (pre-creation Step 0.5)

```
Check: Title dedup gate for "[SPEC-FIX] 22 dangling references to removed spec-auditor skill..."
Tool: gh search issues --repo michael-conrad/.opencode ("spec-auditor" open+closed;
       "dangling OR nonexistent OR missing-skill"; "skill directory missing")
Remote: 30 open + 30 closed candidates scanned. Closest candidates classified:
  - #2254 (closed) internal-consistency remediation of spec-creation/audit decks
    → RELATED-BUT-DISTINCT (residual create.md format gap + E2E verification;
      does not track dangling spec-auditor referers)
  - #1365 (open) spec-audit task card missing codebase-accuracy/feasibility criteria
    → improves EXISTING successor card; not about the missing skill/referers
    → RELATED-BUT-DISTINCT
  - #751 (open) "Phase 5: Update spec-auditor with SC-12 criterion"
    → body targets successor card update, itself partially stale post-rename;
      not a dangling-reference tracker → RELATED-BUT-DISTINCT
Local: git grep over .opencode/.issues worktree → #1834 ([SPEC] Holistic Fix Spec for
  spec-creation Skill) and #2254 mention spec-auditor in passing → RELATED-BUT-DISTINCT.
  (local-issues search CLI unavailable: crashes on pre-existing malformed YAML in an
  unrelated issue record; git grep fallback used.)
Classification: No EXACT-DUPLICATE / NEAR-DUPLICATE / CLOSED-IN-ERROR match found.
Action: proceed — defect is genuinely untracked.
```

Overlap check (pre-creation Step 1): open spec issues #928, #972, #975, #1641, #2099 concern auditor-model swaps, agent cards, semantic depth, and dispatch behavior — none cover missing-skill/dangling-reference remediation. Classification: INDEPENDENT.

---

🤖 OpenCode (opencode/x-preview-f-free) created
