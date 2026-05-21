---
number: 700
title: "[SPEC-FIX] Hard Failure Discipline — unified pipeline invariant for non-debatable FAIL + dark prose weave"
status: "open"
labels: [spec-fix]
created: "2026-05-20T19:25:19.349478Z"
updated: "2026-05-20T19:29:33.601076Z"
github_issue: 762
author: "Michael Conrad"
github_url: "https://github.com/michael-conrad/.opencode/issues/762"
promoted_at: "2026-05-20T19:20:35Z"
remote_issue: "762"
remote_url: "https://github.com/michael-conrad/.opencode/issues/762"
---

## Intent and Executive Summary

**Problem Statement:** The agent pipeline treats FAIL as debatable — reclassifying cleanup gate failures as "structural," reporting "PASS with findings" in auditor verdicts, allowing INCONCLUSIVE escape hatches, and accepting sub-agent FAIL results at face value without independent reproduction. Six prior partial efforts addressed isolated pieces without defining a universal invariant.

**Root Cause:** There is no single rule that says **failure is not an opinion** — that a FAIL signal at any pipeline stage must either propagate to remediation or halt the pipeline. The conceptual gap: the agent can treat "implemented but unverified" as a valid terminal state, and can rationalize reclassification because no identity anchor fuses correctness with completion.

**Approach Chosen:** Define a single universal pipeline invariant — **Hard Failure Discipline** — that covers every failure point (verdicts, sub-agent results, cleanup gates, pipeline gates) with the same rule: FAIL is a hard signal, never reclassifiable, never accept-at-face-value, never soften with INCONCLUSIVE. Incorporate four dark prose patterns to close identity gaps that allow shortcut rationalization:
- **dark-prose-002** (Goal Hijacking / Identity Fusion): Verification IS Completion — no "implemented but unverified" state exists
- **dark-prose-007** (Cost-Frame Reformation): Cost is defect-discovery-latency, not tool-call-count
- **dark-prose-001** (Confirmshaming): Professional/Amateur binary at every pipeline stage
- **dark-prose-006** (Agency-respecting identity frame): WHAT quality standard + WHY it matters, never HOW

**Amendments from #763 (Accountability/Remediation Ownership Model):** This spec's "remediate OR HALT with blocker" clause is amended to "remediate FIRST → re-verify → HALT only on double-failure." The option to HALT without a remediation attempt is removed. The gate holds position during remediation; the agent remedies in-place without escalating to the developer.

---

## Success Criteria

| SC | Description | Verification |
|----|-------------|-------------|
| SC-1 | `000-critical-rules.md` contains a single Tier 2 rule `critical-rules-hard-fail` that defines: a FAIL signal at any pipeline stage (verdict, sub-agent result, cleanup gate, SC-verification gate, phase-completion gate) is a hard gate — remediate the root cause, re-verify, and proceed. Reclassification (calling it "structural/expected/intentional/acceptable/not-a-defect") is a soft-pass violation. INCONCLUSIVE is prohibited at every pipeline stage. HALT without remediation attempt is prohibited — HALT is only permitted after re-verification confirms the failure persists (double-failure). | Read `000-critical-rules.md`, grep for `critical-rules-hard-fail`. Must exist as single Tier 2 rule covering all four failure types with the remediation-first sequence. |
| SC-2 | `065-verification-honesty.md` contains a prose section "Hard Failure Discipline — Universal Invariant" after the Verification Comparison Semantics block. Defines: failure is not debatable. PASS means clean PASS (no findings, no caveats, no "minor issues"). FAIL means FAIL — never INCONCLUSIVE, never "PASS with concerns." The section includes dark-prose-002 identity fusion language ("Verification IS Completion — there is no valid state called 'implemented but unverified'") and dark-prose-007 cost-frame language ("Cost is defect-discovery-latency, not tool-call-count"). | Read `065-verification-honesty.md` — the Hard Failure Discipline section must exist with identity fusion and cost-frame language. |
| SC-3 | All `adversarial-audit` task files (`spec-audit.md`, `test-quality-audit.md`, `plan-fidelity.md`) that use PASS/FAIL/INCONCLUSIVE are updated to binary PASS/FAIL only. INCONCLUSIVE is removed from all verdict schemas, all result contracts, all error-handling tables. No INCONCLUSIVE state remains in any auditor task file. | grep for INCONCLUSIVE returns zero hits across `.opencode/skills/adversarial-audit/tasks/`. |
| SC-4 | `adversarial-audit/tasks/cross-validate.md` has a verdict self-consistency gate: if `result: "PASS"` while `explanation`, `evidence`, or `remediation` contains finding language, cross-validate downgrades to FAIL. PASS must be strictly confirmatory. `clean_room.verified` must be `false` when `violations_detected` is non-empty. | Read `cross-validate.md` — verdict self-consistency gate must exist between current Step 5 and Step 6. |
| SC-5 | `divide-and-conquer` enforcement files (`completion-checkpoint.md`, `result-validation.md`, `dispatch.md`) contain the Verify-Before-Acceptance protocol: orchestrator MUST NOT accept `status: FAIL` from a sub-agent at face value — independently reproduce, re-dispatch on mismatch, double-verify before accepting. The protocol MUST state that the orchestrator attempts re-dispatch with remediation instructions before escalating to HALT. | Read `completion-checkpoint.md`, `result-validation.md`, `dispatch.md` — FAIL status row with Verify-Before-Acceptance protocol that includes remediation-first before HALT. |
| SC-6 | `020-go-prohibitions.md` cost-blind verification block is followed by dark-prose-007 identity anchor. The block reframes cost as defect-discovery-latency using dark-prose-006 agency-respecting frame. | Read `020-go-prohibitions.md` — dark-prose-007 must be present as prose block, not just procedural rule. |
| SC-7 | `010-approval-gate.md` replaces `implementation_complete` with `verification_complete` in the Authorization Scope Model table. The conceptual model fuses verification and completion per dark-prose-002 so that "implemented but unverified" is not a valid halt_at state. | Read `010-approval-gate.md` Authorization Scope table — `verification_complete` only, no `implementation_complete`. |
| SC-8 | Behavioral test: dispatch a prompt with a cleanup FAIL scenario (PR merged, linked issues open) AND an auditor PASS-with-findings scenario. Assert agent does NOT reclassify FAIL, does NOT produce "PASS with findings," and attempts remediation before halting. | Test exists at `.opencode/tests/behaviors/hard-fail-discipline.sh` with `assert_stderr_pattern_absent_all_models` for reclassification language AND `assert_tool_calls_made` for remediation attempt. |

---

## Dark Prose Integration

### dark-prose-002 (Goal Hijacking / Identity Fusion) — applied at SC-2 and SC-7

The conceptual model must fuse "verification" and "completion" so that "implemented but unverified" does not exist as a valid terminal state. Applied in:
- `065-verification-honesty.md` Hard Failure Discipline section (SC-2)
- `010-approval-gate.md` halt_at rename (SC-7)

Formula: `[Task] IS [redefined identity]. Every [action] requires [preceding condition]. No valid [state] without [gate].`

Domain-specific prose:
> "Verification IS completion. Every implementation requires verified PASS. No valid halt_at state without verification_gate PASS. There is no 'implemented but unverified' — that state does not exist in the pipeline."

### dark-prose-007 (Cost-Frame Reformation) — applied at SC-6

Reframes the agent's cost model from tool-call-count to defect-discovery-latency. Applied in:
- `020-go-prohibitions.md` cost-blind block (SC-6)

Formula: `[action] costs [correct metric]. Every [incorrect metric] produces [consequence]. [Consequence] costs more than [action].`

Domain-specific prose:
> "Cost is measured in defect-discovery-latency, not model roundtrips. Running verification costs minutes of execution time — a bounded delay that surfaces defects before they reach CI. Skipping a verification step to save a tool call costs the full pipeline of rework when the defect surfaces downstream: diagnosis, fix, re-review, re-CI, re-deploy — each of which costs more roundtrips than the skipped verification would have consumed. Correctness is the only success metric — there is no score for tool-call economy."

### dark-prose-001 (Confirmshaming / Identity Frame) — applied at SC-1 and SC-5

Professional/Amateur binary at the critical rule and the sub-agent protocol. Applied in:
- `000-critical-rules.md` rule `critical-rules-hard-fail` prose (SC-1)
- `dispatch.md` Verify-Before-Acceptance protocol (SC-5)

### dark-prose-006 (Agency-Respecting Identity Frame) — meta-pattern ensures all prose is WHAT/WHY, never HOW

Every dark prose insertion uses the agency-respecting frame: defines the quality standard and why it matters, never instructs the agent how to comply.

### Anti-Pattern Verification

-  No blame-adjacent: no "you chose to reclassify FAIL"
-  No tool-control: no imperative instructions in dark prose (procedural rules in SC schemas are fine — they're not dark prose)
-  No tone-policing: consequences must be proportional to the actual cost of the defect
-  Agency-respecting: "PASS with findings is a FAIL because findings invalidate the PASS — a criterion either passes clean or it does not" (WHAT/WHY, not HOW)

---

## Phases

**Phase 1 — Core rule + guideline prose:** Add `critical-rules-hard-fail` to `000-critical-rules.md` Tier 2. Add "Hard Failure Discipline" prose section to `065-verification-honesty.md` with dark-prose-002 identity fusion and dark-prose-007 cost-frame language. The remediation-first sequence (remediate → re-verify → HALT only on double-failure) MUST be embedded in the rule prose.

**Phase 2 — Binary verdict enforcement:** Remove INCONCLUSIVE from all `adversarial-audit/tasks/` files. Add self-consistency gate to `cross-validate.md`.

**Phase 3 — Verify-Before-Acceptance protocol:** Add to `completion-checkpoint.md`, `result-validation.md`, `dispatch.md` — FAIL status row + protocol. Protocol MUST state: re-dispatch with remediation instructions first; HALT only on confirmed double-failure.

**Phase 4 — Dark prose injection in guidelines:** Add dark-prose-007 to `020-go-prohibitions.md` cost-blind block. Rename `implementation_complete` → `verification_complete` in `010-approval-gate.md`.

**Phase 5 — Behavioral test:** Create `.opencode/tests/behaviors/hard-fail-discipline.sh`. Covers FAIL reclassification (cleanup), PASS-with-findings downgrade (auditor), and FAIL protocol (sub-agent — remediation attempt before HALT).

---

## Affected Files

| File | Change | SC |
|------|--------|----|
| `.opencode/guidelines/000-critical-rules.md` | Add `critical-rules-hard-fail` (single Tier 2 rule), with dark-prose-001 confirmshaming in prose. Include remediation-first sequence. | SC-1 |
| `.opencode/guidelines/065-verification-honesty.md` | Add "Hard Failure Discipline" prose section with dark-prose-002 + dark-prose-007, add `verification-honesty-hard-fail` symbolic rule | SC-2 |
| `.opencode/skills/adversarial-audit/tasks/cross-validate.md` | Add verdict self-consistency gate (finding-lang detection when result=PASS) | SC-4 |
| `.opencode/skills/adversarial-audit/tasks/spec-audit.md` | Remove INCONCLUSIVE from schemas/contracts | SC-3 |
| `.opencode/skills/adversarial-audit/tasks/test-quality-audit.md` | Remove INCONCLUSIVE from schemas/contracts | SC-3 |
| `.opencode/skills/adversarial-audit/tasks/plan-fidelity.md` | Remove INCONCLUSIVE from schemas/contracts | SC-3 |
| `.opencode/skills/divide-and-conquer/enforcement/completion-checkpoint.md` | Add FAIL status row + Verify-Before-Acceptance protocol (remediation-first), dark-prose-001 prose | SC-5 |
| `.opencode/skills/divide-and-conquer/enforcement/result-validation.md` | Add FAIL result status + FAIL Result Validation Protocol (remediation-first) | SC-5 |
| `.opencode/skills/divide-and-conquer/tasks/dispatch.md` | Add FAIL to status enum, `error_output` field, FAIL checkpoint step, full Verify-Before-Acceptance protocol with remediation-first | SC-5 |
| `.opencode/guidelines/020-go-prohibitions.md` | Add dark-prose-007 after cost-blind verification block | SC-6 |
| `.opencode/guidelines/010-approval-gate.md` | Rename `implementation_complete` → `verification_complete` | SC-7 |
| `.opencode/tests/behaviors/hard-fail-discipline.sh` | New behavioral test covering FAIL reclassification, PASS-with-findings, FAIL protocol with remediation attempt | SC-8 |

---

## Accountability Model Alignment (per #763)

This spec is a **blocking dependency** of #763 (Accountability/Remediation Ownership Model). #763 cannot be implemented until this issue merges.

**Principle P1 alignment (audit fail is fail):** Already fully aligned. This spec defines the FAIL invariant that #763 Principle 1 references.

**Principle P7 alignment (remediate autonomously, not escalate):** REQUIRES AMENDMENT.

This spec currently states in SC-1: "remediate the root cause or HALT with blocker report." The "or HALT" presents HALT as a co-equal alternative to remediation, which conflicts with #763's Principle 7 (remediation is the default action; escalation only on verified remediation failure).

**Required amendment to SC-1:**

Replace: `remediate the root cause or HALT with blocker report`
With: `remediate the root cause; HALT only after verified remediation failure`

The correct sequence is:
1. FAIL detected → agent identifies root cause
2. Agent attempts autonomous remediation
3. If remediation succeeds → re-verify → proceed
4. If remediation fails (double-failure) → HALT with blocker report

"Or HALT with blocker report" is NOT a co-equal option. HALT is the last resort after remediation has been attempted and failed, not an alternative to remediation.

**Impact on other SCs:** This amendment does not change SC-2 through SC-8. The dark prose insertions (identity fusion, cost-frame, confirmshaming) are unaffected. The behavioral test in SC-8 should verify that the agent attempts remediation before halting.

**Dependency chain:** This issue MUST merge before #763 Phase 1 (core rule + guideline prose). #763 Phase 2 (amendment comments) will verify this amendment was applied during implementation.

---

## Change Control

| Version | Date | Change | Author |
|---------|------|--------|--------|
| 1.0 | 2026-05-20 | Initial spec — Hard Failure Discipline | |
| 1.1 | 2026-05-20 | Embed #763 amendments: remediation-first before HALT, remove "remediate OR HALT" option | |
| 1.2 | 2026-05-20 | Add Accountability Model Alignment section (per #763) — self-contained dependency chain documentation | |

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)