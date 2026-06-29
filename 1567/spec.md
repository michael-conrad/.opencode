# Spec-Fix: cross-validate Evidence Type Gate false-positive on behavioral evidence artifacts

**Source:** Phase 1 implementation of #1540 — cross-validate flagged EVIDENCE_TYPE_MISMATCH on timeline.yaml from opencode-cli run
**Created:** 2026-06-29
**Parent:** None (standalone fix)

## Problem

The `cross-validate` task's Evidence Type Gate (Step 4, rule `cross-validate-007b`) flags behavioral evidence artifacts as `EVIDENCE_TYPE_MISMATCH` when auditors inspect them via `read`/`grep` tools. The gate conflates *inspection method* (file read) with *evidence type* (behavioral provenance).

A `timeline.yaml` produced by `opencode-cli run` against a real model IS behavioral evidence — the evidence type is determined by the artifact's provenance (real model execution), not by which tool the auditor uses to read it.

## Root Cause

The Evidence Type Gate in `cross-validate.md` Step 4 checks:

> If the auditor used structural evidence (file existence, grep, read) for a criterion declared as `behavioral`, downgrade that auditor's verdict from PASS to FAIL with `EVIDENCE_TYPE_MISMATCH`

This is fundamentally wrong. The evidence type is determined at **production time** (the orchestrator ran `opencode-cli run` = behavioral), not at **consumption time** (the auditor uses `read` to inspect the results). The gate is trying to re-derive the evidence type from the auditor's inspection tool, which is a category error.

The evidence type taxonomy defines `behavioral` as "Test execution (`opencode-cli run`, `pytest`, `bash test.sh`)" — the test execution IS the behavioral act. The artifacts on disk (timeline.yaml, stderr.log) are the *record* of that act. An auditor reading the record is not "producing structural evidence" — they are inspecting the results of a behavioral test.

## Required Actions

### 1. Replace Evidence Type Gate with Artifact Engagement Check

**File:** `adversarial-audit/tasks/cross-validate.md`

**Change:** The Evidence Type Gate must be replaced with an **Artifact Engagement Check** that:

- Does NOT re-classify evidence by inspection method. The evidence type is declared by the orchestrator when it passes `artifact_evidence_dir` — the orchestrator ran `opencode-cli run`, therefore the evidence is behavioral.
- Instead, verifies the auditor actually inspected the behavioral evidence artifacts. Did the auditor read the `timeline.yaml`? Did they reference specific tool calls from the trace?
- The only valid EVIDENCE_TYPE_MISMATCH is when the auditor did NOT inspect behavioral evidence at all — e.g., they only checked file existence or grepped source code and never touched the behavioral test output directory.

**SC:** SC-1 (string + semantic — verify the gate checks artifact engagement, not inspection tool)

### 2. Update verification-audit task to clarify auditor role

**File:** `adversarial-audit/tasks/verification-audit.md`

**Change:** Add explicit note that auditors are read-only evaluators. They inspect behavioral evidence artifacts produced by the orchestrator's `opencode-cli run` invocations. They do NOT run behavioral tests themselves. Reading a behavioral evidence artifact with `read` is valid behavioral evidence inspection — the evidence type is determined by the artifact's provenance, not the inspection tool.

**SC:** SC-2 (structural — verify note exists)

## Success Criteria Summary

| SC | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Evidence Type Gate replaced with Artifact Engagement Check — verifies auditor inspected behavioral evidence artifacts, does NOT re-classify by inspection tool | string + semantic |
| SC-2 | verification-audit task has explicit note that auditors are read-only evaluators of behavioral evidence artifacts; evidence type determined by provenance, not inspection tool | structural |

## Non-Goals

- Does NOT change the auditor dispatch model — auditors remain read-only
- Does NOT change the Evidence Type Taxonomy or enforcement matrix
- Does NOT change the cross-validate consensus computation
- Does NOT change the FAIL-is-terminal invariant
- Does NOT use path-based pattern matching to classify evidence types (brittle, heuristic-based)

## Regression Invariants

1. Structural evidence for behavioral SCs (auditor never touched behavioral test output) still correctly fails
2. All existing cross-validate rules remain unchanged
3. The monotonic non-increasing invariant is preserved
4. The FAIL-is-terminal invariant is preserved
