---
title: Replace Research-First Mandate with Pre-Response Factual Claim Gate in 065-verification-honesty.md
status: draft
created: 2026-07-12
license: MIT
provenance: AI-generated
issue: 1910
authors:
  - OpenCode (ollama-cloud/deepseek-v4-flash)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-12

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. See `080-code-standards.md` Test Integrity Mandate.

## Alternatives Considered & Why Discarded

| Alternative | Discard Rationale |
|-------------|-------------------|
| Add a new guideline file | Would fragment the existing verification honesty rules across two files, making cross-references harder to maintain |
| Add a plugin/enforcement script | Out of scope — spec explicitly prohibits code changes |
| Rewrite the entire 065 file | Unnecessary — only two sections are defective; the rest (Zero Tolerance, Core Principle, Evidence Hierarchy, Metadata, Hard Failure, Anti-Evasion) are working correctly |

## Root Cause Analysis

The Research-First Mandate (lines 119-162) and Proactive Verification (lines 223-276) sections describe *what* the agent MUST do (verify before claiming) but lack a numbered procedure with binary checks and a halt condition. The agent can read these sections, understand the intent, and still produce factual claims without tool calls because there is no explicit step-by-step gate that halts on violation.

The defect is structural: prose mandates without procedural enforcement produce advisory guidance, not enforceable rules. The agent needs a numbered procedure where each step is a binary check, and a halt condition that fires when the check fails.

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Replace both sections with single numbered procedure | Single gate is simpler to follow than two separate sections with overlapping intent | MUST | SC-1, SC-2 |
| DEC-2 | Proactive Verification becomes cross-reference | Its content (verify before claiming) is subsumed by the gate procedure | MUST | SC-3 |
| DEC-3 | Session-scoped verification (verify once per fact per session) | Prevents redundant re-verification while maintaining correctness | MUST | SC-4 |
| DEC-4 | Halt condition on zero tool calls | Binary check that catches the defect pattern | MUST | SC-5 |

## Interdependency

| Issue | Classification | Description |
|-------|---------------|-------------|
| None | INDEPENDENT | This spec has no dependencies on other open issues |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `grep` on `065-verification-honesty.md` lines 119-162, 223-276 | Identify exact line ranges to replace |
| Direct source search | `grep` on `000-critical-rules.md` line 251 | Identify anchor reference to update |
| Direct source search | `grep` on `.opencode/` for `Research-First\|Proactive Verification` | Identify cross-references to removed section headers |
| Direct source search | `grep` on `.opencode/` for `065-verification-honesty` | Identify filename-only references (no change needed) |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Content-verification tests | MUST | Update grep patterns to match new section headers |

## Objectives

Replace the Research-First Mandate and Proactive Verification sections in `065-verification-honesty.md` with a single numbered Pre-Response Factual Claim Gate procedure that has binary checks, a halt condition, and session-scoped verification semantics.

## Constraints and Scope

**In scope:**
- Replace lines 119-162 (Research-First Mandate) with new Pre-Response Factual Claim Gate procedure
- Replace lines 223-276 (Proactive Verification) with a short cross-reference to the new gate
- Update `000-critical-rules.md` line 251 anchor from "Proactive Verification" to new section name
- Update content-verification test patterns in `test-verification-honesty.sh` (SC-003, SC-004, SC-005, SC-006, SC-007)

**Out of scope:**
- No code changes, no plugins, no behavioral tests, no enforcement scripts
- No changes to other sections of 065-verification-honesty.md
- No changes to skill task files (all reference 065 by filename only)

## Affected Files

| File | Change Type | Anchor |
|------|-------------|--------|
| `.opencode/guidelines/065-verification-honesty.md` lines 119-162 | Replace | Research-First Mandate section |
| `.opencode/guidelines/065-verification-honesty.md` lines 223-276 | Replace | Proactive Verification section |
| `.opencode/guidelines/000-critical-rules.md` line 251 | Update anchor | `065-verification-honesty.md` → "Proactive Verification" |
| `.opencode/tests/test-verification-honesty.sh` | Update patterns | SC-003, SC-004, SC-005, SC-006, SC-007 |

## Pre-Response Factual Claim Gate (Replacement Content)

The following numbered procedure replaces the Research-First Mandate section (lines 119-162) in `065-verification-honesty.md`:

```markdown
## Pre-Response Factual Claim Gate

**Producing a response with factual claims and zero preceding tool calls is a CRITICAL VIOLATION.** Every factual claim in agent output MUST be preceded by at least one tool call that verifies it.

### Procedure

1. **Identify each factual claim** in the response you are about to produce. A factual claim is any assertion about code state, API behavior, file existence, configuration values, environment variables, or system state.

2. **For each claim, check if it has been verified by a tool call in the current session.** Session-scoped verification: verify once per fact per session, not per exchange. If the fact was verified in an earlier exchange in the same session and no state-change trigger has occurred, it MAY be reused without re-verification.

3. **If not verified, make a tool call before producing the claim.** Use the appropriate tool for the claim type: `read` for file contents, `srclight_get_signature` for API signatures, `grep` for code patterns, `bash` for command output, `github_*` for issue/PR state.

4. **If the tool call contradicts the claim, correct it.** The tool call result is authoritative — the claim must match the evidence.

5. **If no tool can verify the claim, omit it.** Do not produce unverifiable claims. Do not use training data as a substitute for verification.

### Halt Condition

A response that contains factual claims but has zero preceding tool calls in the same exchange is a CRITICAL VIOLATION. The agent MUST halt and report the violation before producing the response.

### Session-Scoped Verification

Verification is session-scoped: a fact verified once in the current session MAY be reused without re-verification, UNLESS a state-change trigger has occurred (user explicitly says something changed, API response indicates change, 5+ minutes elapsed with other agents active, session boundary, resource modified by the agent itself).
```

The Proactive Verification section (lines 223-276) is replaced with:

```markdown
## Proactive Verification

The Pre-Response Factual Claim Gate (above) subsumes the proactive verification duty. Before asserting any config schema, API signature, function parameter, or code behavior claim, follow the gate procedure. The gate's numbered steps replace the previous prose-only mandate.
```

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|---------------|-------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | Research-First Mandate section (lines 119-162) is replaced with the Pre-Response Factual Claim Gate numbered procedure | `string` | `grep -n "## Pre-Response Factual Claim Gate" .opencode/guidelines/065-verification-honesty.md` — MUST return a line number | On FAIL: verify the replacement text was written correctly; re-run grep | pre-commit | `.opencode/guidelines/065-verification-honesty.md` | DEC-1 | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-2 | Proactive Verification section (lines 223-276) is replaced with a short cross-reference to the new gate | `string` | `grep -n "Pre-Response Factual Claim Gate (above)" .opencode/guidelines/065-verification-honesty.md` — MUST return a line number | On FAIL: verify the replacement text was written correctly; re-run grep | pre-commit | `.opencode/guidelines/065-verification-honesty.md` | DEC-2 | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-3 | `000-critical-rules.md` line 251 anchor is updated from "Proactive Verification" to "Pre-Response Factual Claim Gate" | `string` | `grep -n "Pre-Response Factual Claim Gate" .opencode/guidelines/000-critical-rules.md` — MUST return a line number | On FAIL: verify the anchor text was updated; re-run grep | pre-commit | `.opencode/guidelines/000-critical-rules.md` | DEC-2 | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-4 | Content-verification test patterns in `test-verification-honesty.sh` are updated to match new section headers | `string` | `grep -n "Pre-Response Factual Claim Gate\|Proactive Verification" .opencode/tests/test-verification-honesty.sh` — MUST match expected patterns | On FAIL: update grep patterns in test file; re-run grep | pre-commit | `.opencode/tests/test-verification-honesty.sh` | DEC-2 | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-5 | No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation | `behavioral` | Verify all SCs maintain their declared evidence type through implementation; no SC is removed or weakened | On FAIL: restore original SC; re-verify | pre-commit | spec body | Anti-Lobotomization | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-6 | After this spec is approved, invoke `writing-plans` to create `.opencode/.issues/1910/plan.md` before implementation begins | `string` | Verify `.opencode/.issues/1910/plan.md` exists after approval | On FAIL: invoke writing-plans | pre-approval-gate | `.opencode/.issues/1910/plan.md` | Spec mandate | Phase 1 | pre-approval-gate | standalone | — | — | — | Phase 1 |

## Risk and Edge Cases

| Risk | Likelihood | Impact | Mitigation | Verifying SC |
|------|-----------|--------|------------|--------------|
| Cross-references to removed section headers in other files | Low | Medium | Search was performed — only `000-critical-rules.md` line 251 references "Proactive Verification" by name | SC-3 |
| Content-verification test patterns break | Medium | Low | Test file patterns are grep-only; update is straightforward | SC-4 |
| Skill task files reference 065 by filename only | High | None | 20+ files reference `065-verification-honesty.md` by filename — no section anchor, no change needed | N/A |

## SC-to-Root-Cause Traceability Table

| SC-ID | Root Cause Element |
|-------|-------------------|
| SC-1 | Prose mandates without numbered procedure — replace with binary-check procedure |
| SC-2 | Proactive Verification overlaps with Research-First Mandate — consolidate |
| SC-3 | Cross-reference anchor to removed section — update |
| SC-4 | Test patterns match removed section headers — update |
| SC-5 | Anti-lobotomization — no SC weakening |
| SC-6 | Plan creation mandate |

## Feasibility Assessment

- `065-verification-honesty.md` — verified exists at `.opencode/guidelines/065-verification-honesty.md`
- `000-critical-rules.md` — verified exists at `.opencode/guidelines/000-critical-rules.md`
- `test-verification-honesty.sh` — does not exist at `.opencode/tests/test-verification-honesty.sh` (not found by glob); content-verification test updates are conditional on file existence

## Implementation Approach

1. Edit `.opencode/guidelines/065-verification-honesty.md`: replace lines 119-162 with the Pre-Response Factual Claim Gate procedure
2. Edit `.opencode/guidelines/065-verification-honesty.md`: replace lines 223-276 with cross-reference
3. Edit `.opencode/guidelines/000-critical-rules.md` line 251: update anchor text
4. If `test-verification-honesty.sh` exists, update grep patterns

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

---

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
