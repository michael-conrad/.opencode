# Audit Report: SKILL.md Dispatch Table Sub-Step Exposure

**Issue:** #1591
**Date:** 2026-06-30
**Auditor:** OpenCode (ollama-cloud/deepseek-v4-flash)

## Summary

Audited 42 SKILL.md files across `.opencode/skills/` (including 3 platform sub-skills). Found **1 skill with DEFECT** — `spec-creation` — which is already targeted by fix spec #1590. All other skills are clean.

---

## Audit Results

### Skills with DEFECT (D3 or D4 FAIL)

| Skill | D1 (Dispatch Table?) | D2 (Operating Protocol?) | D3 (Exposes Sub-Steps?) | D4 (Invocation Exposes Sub-Steps?) | Entries to Remove |
|-------|---------------------|--------------------------|------------------------|-------------------------------------|-------------------|
| `spec-creation` | PASS | PASS | **FAIL** — `pipeline-readiness-gate`, `completion` appear in both dispatch table and Operating Protocol steps | **FAIL** — `pipeline-readiness-gate`, `completion` have canonical task() strings in Invocation section | `pipeline-readiness-gate`, `completion` |

### Skills That Are Clean (No Defect)

| Skill | D1 | D2 | D3 | D4 | Notes |
|-------|----|----|----|----|-------|
| `adversarial-audit` | PASS | FAIL | N/A | N/A | No Operating Protocol — dispatch entries are standalone tasks |
| `approval-gate` | PASS | FAIL | N/A | N/A | No Operating Protocol |
| `brainstorming` | PASS | PASS | PASS | PASS | Dispatch entries are standalone; Operating Protocol steps are different |
| `changelog-generator` | PASS | FAIL | N/A | N/A | No Operating Protocol |
| `completeness-gate` | PASS | PASS | PASS | PASS | Dispatch entries are standalone |
| `completion-core` | PASS | FAIL | N/A | N/A | No Operating Protocol |
| `conflict-resolution` | PASS | FAIL | N/A | N/A | No Operating Protocol |
| `correspondence` | PASS | PASS | PASS | PASS | Dispatch entries are standalone |
| `engineering-approach` | PASS | PASS | PASS | PASS | Dispatch entries are standalone |
| `executing-plans` | PASS | PASS | PASS | PASS | Dispatch entries are standalone |
| `finishing-a-development-branch` | PASS | PASS | PASS | PASS | Dispatch entries are standalone |
| `git-workflow` | PASS | PASS | PASS | PASS | Dispatch entries are standalone |
| `implementation-pipeline` | PASS | FAIL | N/A | N/A | No Operating Protocol — pipeline steps defined in Dispatch Routing Table |
| `issue-operations` | PASS | PASS | PASS | PASS | Dispatch entries are standalone |
| `issue-review` | PASS | PASS | PASS | PASS | Dispatch entries are standalone |
| `mcp-tool-usage` | PASS | FAIL | N/A | N/A | No Operating Protocol |
| `multimodal-dispatch` | PASS | FAIL | N/A | N/A | No Operating Protocol |
| `plan-creation-pipeline` | PASS | FAIL | N/A | N/A | No Operating Protocol |
| `plan` | PASS | FAIL | N/A | N/A | No Operating Protocol |
| `playwright-cli` | PASS | FAIL | N/A | N/A | No Operating Protocol |
| `pr-creation-workflow` | PASS | PASS | PASS | PASS | Dispatch entries are standalone |
| `pre-analysis` | PASS | PASS | PASS | PASS | Dispatch entries are standalone |
| `programming-principles` | PASS | FAIL | N/A | N/A | No Operating Protocol |
| `receiving-code-review` | PASS | FAIL | N/A | N/A | No Operating Protocol |
| `requesting-code-review` | PASS | FAIL | N/A | N/A | No Operating Protocol |
| `research` | PASS | FAIL | N/A | N/A | No Operating Protocol |
| `skill-creator` | PASS | PASS | PASS | PASS | Dispatch entries are standalone |
| `solve` | PASS | FAIL | N/A | N/A | No Operating Protocol |
| `sre-runbook` | PASS | FAIL | N/A | N/A | No Operating Protocol |
| `sync-guidelines` | PASS | FAIL | N/A | N/A | No Operating Protocol |
| `systematic-debugging` | PASS | FAIL | N/A | N/A | No Operating Protocol |
| `test-driven-development` | PASS | FAIL | N/A | N/A | No Operating Protocol |
| `using-git-worktrees` | PASS | FAIL | N/A | N/A | No Operating Protocol |
| `verification-before-completion` | PASS | FAIL | N/A | N/A | No Operating Protocol |
| `verification-enforcement` | PASS | FAIL | N/A | N/A | No Operating Protocol |
| `verification` | PASS | FAIL | N/A | N/A | No Operating Protocol |
| `writing-plans` | PASS | PASS | PASS | PASS | Dispatch entries (`create`, `retroactive`, `update`, `completion`) are pipeline entry points, not sub-steps of the 22-step Operating Protocol |

### Platform Sub-Skills

| Skill | D1 | D2 | D3 | D4 | Notes |
|-------|----|----|----|----|-------|
| `gitbucket-api` | FAIL | FAIL | N/A | N/A | No Trigger Dispatch Table — uses Sub-Agent Tasks table instead |
| `github-mcp` | FAIL | FAIL | N/A | N/A | No Trigger Dispatch Table — uses Sub-Agent Tasks table instead |
| `local` | FAIL | FAIL | N/A | N/A | No Trigger Dispatch Table — uses Sub-Agent Tasks table instead |

---

## Detailed Findings

### DEFECT: `spec-creation`

**D3 — Dispatch Table Exposes Sub-Steps:**

The Trigger Dispatch Table (line 28-33) lists:
- `create` — genuine pipeline entry point ✅
- `pipeline-readiness-gate` — **DEFECT**: appears as Operating Protocol step 4.5
- `completion` — **DEFECT**: appears as Operating Protocol step 11

**D4 — Invocation Section Exposes Sub-Steps:**

The Invocation section (line 53-57) provides canonical `task()` strings for:
- `create` — genuine entry point ✅
- `pipeline-readiness-gate` — **DEFECT**: sub-step with canonical string
- `completion` — **DEFECT**: sub-step with canonical string

**Proposed Fix:**
- Remove `pipeline-readiness-gate` and `completion` from the Trigger Dispatch Table
- Remove their canonical `task()` strings from the Invocation section
- These tasks remain callable from within the Operating Protocol by the orchestrator reading the task file directly

### `writing-plans` — Clean (No Defect)

The dispatch table lists `create`, `retroactive`, `update`, `completion`. The Operating Protocol has 22 numbered steps (e.g., "Verify spec is approved", "Research", "Z3 check", etc.). None of the dispatch table entries match any Operating Protocol step. The dispatch entries are genuine pipeline entry points.

### Platform Sub-Skills — No Trigger Dispatch Table

The three platform sub-skills (`gitbucket-api`, `github-mcp`, `local`) use a `## Sub-Agent Tasks` section with a task routing table instead of a `## Trigger Dispatch Table`. They have no `## Operating Protocol` section. These are structurally different from the main skills and do not have the defect.

---

## SC Verification

| ID | Criterion | Result | Evidence |
|----|-----------|--------|----------|
| SC-1 | All SKILL.md files audited against D1-D4 via fresh inspection | PASS | 42 files read and analyzed in this session |
| SC-2 | Every DEFECT in D3 or D4 identified with specific evidence | PASS | `spec-creation`: `pipeline-readiness-gate` and `completion` identified in both dispatch table (lines 32-33) and Operating Protocol (steps 4.5, 11) |
| SC-3 | Audit report lists proposed dispatch table entries to remove for each affected skill | PASS | `spec-creation`: remove `pipeline-readiness-gate`, `completion` |
| SC-4 | Audit report lists skills that are clean (no defect) | PASS | 37 clean skills listed above |

---

## Conclusion

The dispatch-table sub-step exposure defect identified in #1591 is **limited to `spec-creation`**, which is already targeted by fix spec #1590. No other skills exhibit the pattern where dispatch table entries correspond to Operating Protocol sub-steps.

The `completion` task appears in dispatch tables across many skills, but it is a universal workflow-end task, not a sub-step of any Operating Protocol. It is only a DEFECT in `spec-creation` because the Operating Protocol explicitly lists it as a numbered step (step 11).

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
