---
number: 699
title: "[SPEC] Accountability/Remediation Ownership Model — agent owns every failure, remediates autonomously"
status: "open"
labels: [spec, needs-approval]
created: "2026-05-20T19:11:47Z"
updated: "2026-05-20T19:29:18.950790Z"
github_issue: 763
github_url: "https://github.com/michael-conrad/.opencode/issues/763"
author: "michael-conrad"
promoted_at: "2026-05-20T19:11:47Z"
remote_issue: "763"
remote_url: "https://github.com/michael-conrad/.opencode/issues/763"
---

## Intent and Executive Summary

**Problem Statement:** The agent pipeline has enforcement gates for failures (audit FAIL, skipped testing, missing artifacts) but no ownership model defining who is responsible when those gates fire. Current behavior defaults to escalation — the agent halts and reports the problem to the developer. This shifts the cost of every failure onto the developer, creating friction, delay, and the implicit assumption that "this is someone else's problem."

**Root Cause:** Every existing enforcement issue (#762, #603, #673, etc.) defines *what happens on failure* (HALT, report, remediate-or-HALT) but never defines *who owns the failure*. The default answer — "escalate to the developer" — is the de facto ownership model, and it is wrong.

**Approach Chosen:** Define a single Accountability/Remediation Ownership Model that applies uniformly across ALL failure modes:

1. Audit fail is a fail — no exceptions, no reclassification
2. Bad prompt is on the agent — agent owns prompt quality
3. Defective spec/plan is on the agent — agent produces correct artifacts or remediates
4. Bad/incomplete implementation is on the agent — agent owns implementation quality
5. Missing text artifacts is a fail — agent produces complete deliverables
6. Skipped functional/behavioral testing is a fail — no exceptions, no excuses
7. Remediate autonomously, never escalate — escalation is only for dire circumstances; skipping remediation is not a valid choice

**Alternatives Considered:**
- Per-failure escalation model (status quo) — rejected because every failure costs a developer roundtrip
- Selective ownership (some failures are agent-owned, some are developer-owned) — rejected because it creates ambiguity and loopholes
- Escalation-is-okay-with-blocker-report (current #762 model) — rejected per Principle 7: HALT is last resort after remediation attempt, not a first response

**Key Design Decisions:**
- Principles are universal (all failure modes), not per-gate
- Existing issues are NOT superseded — they define the gate mechanics; this issue defines the ownership framework
- Ownership is non-delegable — the writing agent owns defects in its output, regardless of sub-agent involvement
- Remediation means: fix the root cause, re-verify, and proceed. Only when remediation is genuinely impossible (verified, not assumed) may the agent HALT with escalation

---

## Dependency Graph

```
MERGE ORDER (critical):
  ┌─ #762 Hard Failure Discipline ──→ defines "FAIL" invariant ──→ NEW needs FAIL definition
  ├─ #673 SC Enforcement Gate  ─────→ producer-side all-or-nothing gate ──→ NEW needs gate foundation
  ├─ #603 Behavioral Test Sub  ─────→ defines behavioral/functional test ──→ NEW P6 needs definition
  │
  └─ ALL THREE must merge BEFORE this spec

POST-MERGE AMENDMENTS (this spec triggers):
  ├─ #762: "remediate OR HALT" → "remediate FIRST, HALT only after remediation fails"
  ├─ #673: "FAIL blocks pipeline" → "FAIL triggers remediation, gate holds until remediated"
  ├─ #626: Add "remediation IS agent-owned" identity fusion layer
  └─ #733: Add missed-preamble = agent-fault clause (blame ownership)
```

### DEPENDS ON (must merge first)

| Issue | Why | New Principle |
|-------|-----|---------------|
| **#762** (Hard Failure Discipline) | Defines the FAIL invariant. Without knowing what "FAIL" means, P1 and P6 are meaningless. | P1 (audit fail=FAIL), P6 (skipped testing=FAIL) |
| **#673** (SC Enforcement Gate) | Defines all-or-nothing SC gate. Accountability model needs the gate to exist before layering ownership on top. | P1 (fail is fail), P6 (skipped testing=FAIL) |
| **#603** (Behavioral Test Substitution) | Defines what "behavioral/functional test" means and enumerates forbidden substitutions. Without this definition, P6 has no foundation. | P6 (skipped testing=FAIL) |
| **#626** (Identity Fusion) | Fuses verification and completion conceptually. The fusion makes "implemented but unverified" invalid. | P4 (bad implementation = on agent) |

### AMENDS (post-merge changes to existing issues)

| Issue | Amendment Required | Principle Trigger |
|-------|-------------------|-------------------|
| **#762** | Change "remediate OR HALT" to "remediate FIRST → re-verify → HALT only on double-failure". The current option to HALT without remediation attempt violates P7. | P7 (remediate, not escalate) |
| **#673** | Add to gate language: "FAIL triggers autonomous remediation by agent, not pipeline halt. Gate holds until remediation is verified or double-failure occurs." | P7 (remediate, not escalate) |
| **#626** | After "Verification IS completion" identity fusion, add "Remediation IS agent-owned" as the next fusion layer. | P3 (defective spec/plan), P4 (bad implementation) |
| **#733** | Add clause: "Absent preamble in a standard+ spec is a spec-producer defect, not a reviewer miss." | P5 (missing text artifacts) |

### CONFLICTING MANDATES

| Conflict | Severity | Resolution |
|----------|----------|------------|
| **#762:** "remediate OR HALT with blocker" vs **P7:** "remediate, not escalate" | HIGH | Amend #762: sequence HALT as last resort after failed remediation, not as co-equal option |
| **#673:** "FAIL blocks implementation" vs **P7:** "remediate autonomously without escalating" | MEDIUM | Gate holds position but agent remediates in-place. No developer escalation needed. |
| **P2** (bad prompt = agent's fault) has no existing enforcement | MEDIUM | Requires new critical rules + behavioral tests. Gap flagged. |

---

## Success Criteria

| SC | Criterion | Verification | Type |
|----|-----------|-------------|------|
| SC-1 | `000-critical-rules.md` contains `critical-rules-accountability-ownership` (Tier 2, 7 principles). | Read file — rule must exist with all 7 principles. | Content |
| SC-2 | `020-go-prohibitions.md` ALWAYS DO: "Remediate before escalating." | Read file — must contain mandate. | Content |
| SC-3 | `020-go-prohibitions.md` NEVER DO: "NEVER escalate without attempting remediation." | Read file — must contain prohibition. | Content |
| SC-4 | #762 amendment comment posted. | Verify comment on #762. | Content |
| SC-5 | #673 amendment comment posted. | Verify comment on #673. | Content |
| SC-6 | #626 amendment comment posted. | Verify comment on #626. | Content |
| SC-7 | #733 amendment comment posted. | Verify comment on #733. | Content |
| SC-8 | Behavioral test: failed audit → remediate (not escalate). | `accountability-remediation.sh` passes. | Behavioral |
| SC-9 | Behavioral test: missing artifact → produce (not flag). | Same test file, scenario 2. | Behavioral |
| SC-10 | Behavioral test: defective spec → revise (not report). | Same test file, scenario 3. | Behavioral |

---

## Phases

### Phase 1: Core Rule + Guideline Prose (SC-1, SC-2, SC-3)

Add `critical-rules-accountability-ownership` to `000-critical-rules.md` (Tier 2). Add remediation-first prose to `020-go-prohibitions.md`.

### Phase 2: Amendment Comments (SC-4, SC-5, SC-6, SC-7)

Post comments on #762, #673, #626, #733 documenting amendments.

### Phase 3: Behavioral Enforcement Tests (SC-8, SC-9, SC-10)

Create `tests/behaviors/accountability-remediation.sh` with 3 scenarios.

---

## Risk Analysis

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Existing issues merge without amendments applied | Medium | High | Amendment comments create paper trail; SC-4–SC-7 verify presence |
| Agent attempts remediation but makes it worse | Medium | Medium | Bounded remediation: fix root cause, re-verify, proceed. Double-failure escalates. |
| "Escalation only for dire" boundary is ambiguous | Medium | Medium | "Dire" = verified remediation failure, or external blocker the agent cannot resolve. |
| P2 (bad prompt) has no enforcement infrastructure | High | High | Follow-up critical rules + behavioral tests needed. Known gap. |

---

## Edge Cases

| Case | Rule |
|------|------|
| Sub-agent produced the defect | Ownership is non-delegable. Orchestrator owns sub-agent output. Re-task with remediation. |
| Defect was pre-existing | If agent was instructed to revise/use the artifact, it owns checking. Caveat emptor. |
| Developer explicitly told agent to skip | Override takes precedence. Agent MUST note skipped requirement and override source. |
| Remediation requires more time than escalation | P7 is cost-blind. "Remediate, not escalate" is not conditioned on cost. |
| Agent cannot determine root cause | Systematic debugging applies. Indeterminate root cause = failed remediation → escalation permitted. |

---

## Change Control

| Version | Date | Change | Author |
|---------|------|--------|--------|
| 1.0 | 2026-05-20 | Initial spec | michael-conrad |

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)
