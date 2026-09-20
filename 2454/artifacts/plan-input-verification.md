# Plan Input Verification Ledger — .opencode#2454
provenance: AI-generated
written_once: 2026-09-20

## Issue State
- issue: .opencode#2454 (qualifier `.opencode#2454`)
- title: "[SPEC] Orchestrator-direct plan execution — task() only at plan-marked dispatch points"
- status: open
- local labels (issue.yaml — canonical): [approved-for-pr]
- github_url: michael-conrad/.opencode

## SC List (from spec.md §3)
- SC-1 — orchestrator own-tool-call execution on direct steps — evidence: behavioral — verify via `opencode run` through `with-test-home`; stderr agent actions.
- SC-2 — forwarding prohibition (no whole-plan/whole-phase `task()` forwarding) — behavioral.
- SC-3 — dispatch restricted to `(**task-card**)`-marked steps only — behavioral.
- SC-4 — pre-flight guard backstop: BLOCKED with `ORCHESTRATOR_ONLY_PLAN` / `ORCHESTRATOR_ONLY_SKILL_CARD` — behavioral (one SC, dual reason codes, single mechanism).

## Structure Artifact Mappings (structure.yaml)
- Single phase P1: "executing-plans orchestrator-direct mandate (behavioral enforcement)" — SCs [SC-1..SC-4], items 1-4, each item: red → green → verify → commit.
- dependency_dag edges: [] (single phase; no inter-item RED dependencies).
- triplet_co_location verified: true.
- post_implementation: audit → structural-checks → pre-pr-gate → review-prep → create-pr.

## Files in Scope (code-path-inventory / blast-radius)
- .opencode/skills/executing-plans/SKILL.md
- .opencode/skills/executing-plans/tasks/execute-phase.md
- .opencode/skills/executing-plans/tasks/read-plan.md
- .opencode/tests-v2/ (behavioral scenarios)

## Local-Issues CLI Surface Needed
- `./.opencode/tools/local-issues update .opencode#2454 --labels <full comma list>` — REPLACES the entire labels array; must include existing `approved-for-pr` plus `spec-cleared` → final list: `approved-for-pr,spec-cleared`.

## Per-Task Cycle Steps (implementation-workflow.md)
- Pre: pre-regression, pre-regression-verify
- Item cycle: red → green → post-regression → verify → commit-inline
- Post: audit, z3-check, structural-checks, pre-pr-gate, regression-check, review-prep, create-pr, exec-summary
- No sub-dispatch from within this task. Behavioral items: commit + push precede behavioral run (§4 harness gate).
