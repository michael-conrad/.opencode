# Plan Input Verification Ledger — .opencode#2456

issue: ".opencode#2456"
generated: "2026-09-21"

## Issue state + labels (from issue.yaml, read 2026-09-21)

- status: open
- labels: [approved-for-pr]
- title: "[SPEC] tests-v2 semantic-determination gate for behavioral opencode run dispatches"

## SC list with evidence types (from spec.md, read 2026-09-21)

- SC-1 poll evidence persisted per monitored run (BEHAVIOR_SEMANTIC_MONITOR=1) — behavioral
- SC-2 classification sub-agent dispatched with scenario-goal context — behavioral
- SC-3 determination record with classification + poll-evidence refs written — behavioral
- SC-4 off-track classification → orchestrator notification, never silent continuation — behavioral
- SC-5 progressing runs continue polling regardless of duration — behavioral
- SC-6 halt-class states halt + notify before further dispatch — behavioral
- SC-7 decision field recorded with allowed value-set {continue-new-dispatch, terminate-with-root-cause} — behavioral
- SC-8 hard gate blocks resume/re-run without non-undetermined determination — behavioral
- SC-9 undetermined-cycle ceiling (3) persisted; CEILING_REACHED block — structural
- SC-10 false_signal annotation on wrong abort — behavioral
- SC-11 new enforcement scenario passes via test-enforcement.sh — behavioral
- SC-12 AGENTS.md §10.7/§14/R-18/§17 mirror implemented predicates — structural

## Structure artifact mappings (read 2026-09-21)

- phase-1: SC-1, SC-2, SC-3 — depends none
- phase-2: SC-4, SC-5, SC-6, SC-7 — depends phase-1
- phase-3: SC-8, SC-9 — depends phase-1
- phase-4: SC-10, SC-11, SC-12 — depends phase-3
- DAG edges: 1→2, 1→3, 3→4 — acyclic
- Per-SC steps in structure: red (test-driven-development), green (test-driven-development), verify (verification-before-completion), commit (commit-inline orchestrator)

## Implementation-workflow reference card (read 2026-09-21)

- Pre-implementation: pre-regression, pre-regression-verify
- Per-item: red, green, post-regression, verify, commit-inline (orchestrator direct)
- Post-implementation: audit, z3-check (direct), structural-checks, pre-pr-gate, regression-check, review-prep, create-pr, exec-summary
- Dispatch strings verified against reference card TDT

## Analytical artifacts (read 2026-09-21, regenerated post SC-split)

- blast-radius: helpers.sh (SC-1..7,9,10), with-test-home (SC-8,9), AGENTS.md (SC-12), new scenario file (SC-11)
- code-path-inventory: __semantic_monitor line 508; behavior_run line 798; with-test-home resume gates; flock tmp/.behavior-run.lock
- cross-cutting: determination record spans SC-3/7/8/10; BEHAVIOR_SEMANTIC_MONITOR flag gate; flock; stderr conventions; R-10 doc mirroring; YAML standard
- interface-compatibility: with-test-home CLI unchanged (gate is internal precondition check); new record file interface; classification enum {progressing-directionally, off-track, undetermined}
- state-analysis: run-lifecycle, resume-gate, determination-record states; invariants (no silent continuation, mechanical gate, flag-gated)

## CLI surface flags needed

- Label write: `./.opencode/tools/local-issues update .opencode#2456 --labels approved-for-pr,spec-cleared` (replaces entire labels array — must include existing labels per pinned convention 11)

## Files (canonical)

- Plan index: `.opencode/.issues/2456/plan.md`
- Phase files: `plan-01-monitor-foundation.md`, `plan-02-classification-routing.md`, `plan-03-resume-gate-ceiling.md`, `plan-04-false-signal-scenario-docs.md`
