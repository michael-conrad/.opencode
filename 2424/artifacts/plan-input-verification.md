# Plan Input Verification Ledger — .opencode#2424

Verified once 2026-09-20. All subsequent plan steps read THIS ledger, not the sources.

## Issue state + labels (from `.opencode/.issues/2424/issue.yaml`)

- title: '[SPEC] Remediate executing-plans SKILL.md — missing sub-agent dispatch text and validator conformance defects'
- status: open
- labels: `approved-for-pr` (authorization: for_pr → PR creation authorized; label write must preserve this)
- remote: michael-conrad/.opencode#2424

## SC list with evidence types (source: spec.md §3 — AUTHORITATIVE, 9 SCs)

Note: `sc-summary.yaml` (8 SCs) is STALE; spec.md §3 governs. structure.yaml already reflects 9 SCs.

| SC | Criterion (condensed) | Evidence Type |
|----|----------------------|---------------|
| SC-1 | read-plan dispatch prompt begins `You are a sub-agent.` inside quote, before `Follow the instructions in` | string |
| SC-2 | execute-phase dispatch prompt begins `You are a sub-agent.` inside quote, before `Follow the instructions in` | string |
| SC-3 | byline uses `<AgentName> (<ModelId>)` placeholder; hardcoded `OpenCode (deepseek-v4-flash)` absent | string |
| SC-4 | `## Worktree Mode` section present with Appendix A verbatim sentence (sole pass condition) | string |
| SC-5 | Workflows section uses `N. **` numbered format; `- [ ] N. **` prefix absent | string |
| SC-6 | read-plan link text = `inventory plan phases`; no `tasks/`, no `.md` suffix | string |
| SC-7 | execute-phase link text = `dispatch one plan phase`; no `tasks/`, no `.md` suffix | string |
| SC-8 | `## Mandatory Task Discipline` section with canonical four-item checklist | string |
| SC-9 | validator suite passes with zero violations for executing-plans | behavioral |

## Structure artifact mappings (structure.yaml, generated 2026-09-20)

- Phase 1 "Dispatch prompt sub-agent prefixes" → SC-1, SC-2 (items 1-2)
- Phase 2 "Validator REQ remediation (REQ-2, REQ-3, REQ-6)" → SC-3, SC-4, SC-5 (items 3-5)
- Phase 3 "Purpose-condensation alignment and Mandatory Task Discipline section" → SC-6, SC-7, SC-8 (items 6-8)
- Phase 4 "Full validator conformance gate" → SC-9 (item 9; depends on items 1-8; RED/GREEN/VERIFY only, no commit)
- DAG: phase-1,2,3 → phase-4; phases 1-3 mutually independent (disjoint SKILL.md regions); strict sequential ordering for diff isolation
- Triplet colocation verified; no cross-phase RED dependency
- Every item dispatch: task-card (test-driven-development → red/green; verification-before-completion → verify; commit-inline orchestrator). Item 9: verification-before-completion verify (behavioral gate), no commit.

## Target file

- `.opencode/skills/executing-plans/SKILL.md` (single file; all phases edit disjoint regions: dispatch prompt text / byline+sections+headers / link labels)

## Reference baselines (spec §6)

- Dispatch-pattern baseline: `.opencode` commit `125b423e0bd846439e908c1150e18e913f042726` → `git show 125b423e:skills/spec-creation/SKILL.md` (SC-1/SC-2 visual diff only)
- Section-content reference: `.opencode/skills/completion-core/SKILL.md` (Worktree Mode + Mandatory Task Discipline canonical form)
- Validator: `uv run .opencode/skills/skill-creator/scripts/validate_skill_cards.py --json` (read-only; MUST NOT modify)

## Out-of-scope constraints

- R-10: no changes to `read-plan.md` / `execute-phase.md`
- R-11: no other skill card modified
- R-12: validator not modified

## CLI surface flags needed

- `./.opencode/tools/local-issues update .opencode#2424 --labels <all existing + new>` (label write REPLACES entire labels array — must include `approved-for-pr` + `spec-cleared`)
- git commits via orchestrator commit-inline (no co-author trailers during implementation commits)

## Per-task cycle steps (from implementation-workflow reference card — authoritative)

- Pre: pre-regression (tdd phase-0) → pre-regression-verify (vbc verify)
- Per item: red → green → post-regression (tdd phase-4) → verify → commit-inline
- Post: audit → z3-check → structural-checks → pre-pr-gate → regression-check → review-prep → create-pr → exec-summary
- Coercion: DONE_WITH_CONCERNS→FAIL; EVIDENCE_TYPE_MISMATCH→FAIL
- Step pre-cleanup: `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-<step>-*` at each step start
