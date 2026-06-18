# Plan: [SPEC-FIX] orchestrator DISPATCH_GATE violation — canonical dispatch enforcement

**Goal:** Enforce that the orchestrator uses the canonical dispatch string verbatim after loading a skill's dispatch table, rather than writing custom prompts with preloaded context. Add a critical rule, update all SKILL.md DISPATCH_GATE sections with Orchestrator Entry Criteria, and add a behavioral enforcement test.

**Architecture:** Three parallel changes — (1) critical rule in `000-critical-rules.md`, (2) Orchestrator Entry Criteria block in every SKILL.md's DISPATCH_GATE section, (3) behavioral enforcement test.

**Tech Stack:** Markdown (guidelines, SKILL.md), bash (behavioral test).

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## File Structure

| File | Action | Responsibility |
|------|--------|---------------|
| `.opencode/guidelines/000-critical-rules.md` | Add critical rule for canonical dispatch string | Phase 1 |
| `.opencode/skills/*/SKILL.md` (all 30+ skills with DISPATCH_GATE) | Add Orchestrator Entry Criteria block | Phase 1 |
| `.opencode/tests/behaviors/dispatch-gate-canonical.sh` | Create behavioral enforcement test | Phase 2 |

## RED Checkpoint Definitions

Each TDD task in the phases below has explicit failure conditions. A RED checkpoint fails when the test does NOT produce the expected failure signal.

| SC-ID | RED Checkpoint | Failure Condition | Re-Entry Step |
|-------|---------------|-------------------|---------------|
| SC-1 | Behavioral test sends canonical dispatch, verifies sub-agent returns valid result | Test passes (should fail because rule doesn't exist yet) | green-phase |
| SC-2 | Behavioral test sends custom prompt with preloaded context, verifies violation | Test passes (should fail because rule doesn't exist yet) | green-phase |
| SC-3 | Behavioral test sends empty-result scenario, verifies re-task | Test passes (should fail because rule doesn't exist yet) | green-phase |
| SC-4 | Behavioral test sends preloaded context, verifies PRELOADED_CONTEXT_REJECTED | Sub-agent does NOT return PRELOADED_CONTEXT_REJECTED | red-phase |

## SC Coverage

| SC-ID | Criterion | Evidence Type | Plan Phase |
|-------|-----------|---------------|------------|
| SC-1 | After loading a skill, orchestrator uses canonical dispatch string verbatim | behavioral | Phase 2 (test) |
| SC-2 | Custom prompt with preloaded context after reading canonical string is a violation | behavioral | Phase 2 (test) |
| SC-3 | Empty sub-agent result triggers clean-room re-task (not inline fallback) | behavioral | Phase 2 (test) |
| SC-4 | Sub-agent receiving preloaded context returns `PRELOADED_CONTEXT_REJECTED` | behavioral | Phase 2 (test) |

## Phase Structure

### Phase 1: Add Critical Rule + Orchestrator Entry Criteria

**Concern:** Content creation — add the critical rule and update all SKILL.md DISPATCH_GATE sections.
**Files:** `.opencode/guidelines/000-critical-rules.md`, all `.opencode/skills/*/SKILL.md`
**SCs covered:** SC-1, SC-2, SC-3 (structural — rule text exists)

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 1234, "phase": 1, "authorization_scope": "for_plan", "halt_at": "plan_created", "pr_strategy": "none", "pipeline_phase": "phase-1"}` | SC-1, SC-2, SC-3 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1234, "phase": 1, "authorization_scope": "for_plan", "halt_at": "plan_created", "pr_strategy": "none", "pipeline_phase": "phase-1"}` | SC-1 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 1234, "phase": 1, "description": "Write behavioral enforcement test that verifies sub-agent returns PRELOADED_CONTEXT_REJECTED when receiving preloaded context. Test must FAIL because the rule doesn't exist yet.", "authorization_scope": "for_plan", "halt_at": "plan_created", "pr_strategy": "none", "pipeline_phase": "phase-1"}` | SC-4 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 1234, "phase": 1, "authorization_scope": "for_plan", "halt_at": "plan_created", "pr_strategy": "none", "pipeline_phase": "phase-1"}` | SC-4 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 1234, "phase": 1, "authorization_scope": "for_plan", "halt_at": "plan_created", "pr_strategy": "none", "pipeline_phase": "phase-1"}` | SC-1 |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 1234, "phase": 1, "description": "Add critical rule to 000-critical-rules.md: 'After loading a skill and reading its dispatch table, the orchestrator MUST use the canonical dispatch string verbatim. Writing a custom prompt with preloaded context after reading the canonical string is a DISPATCH_GATE violation.' Add Orchestrator Entry Criteria block to every SKILL.md DISPATCH_GATE section.", "authorization_scope": "for_plan", "halt_at": "plan_created", "pr_strategy": "none", "pipeline_phase": "phase-1"}` | SC-1, SC-2, SC-3 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 1234, "phase": 1, "authorization_scope": "for_plan", "halt_at": "plan_created", "pr_strategy": "none", "pipeline_phase": "phase-1"}` | SC-1 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-1 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 1234, "phase": 1, "authorization_scope": "for_plan", "halt_at": "plan_created", "pr_strategy": "none", "pipeline_phase": "phase-1"}` | SC-1 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 1234, "phase": 1, "authorization_scope": "for_plan", "halt_at": "plan_created", "pr_strategy": "none", "pipeline_phase": "phase-1"}` | SC-1, SC-2, SC-3 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 1234, "phase": 1, "authorization_scope": "for_plan", "halt_at": "plan_created", "pr_strategy": "none", "pipeline_phase": "phase-1"}` | SC-1, SC-2, SC-3, SC-4 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 1234, "phase": 1, "audit_phase": "plan_creation", "authorization_scope": "for_plan", "halt_at": "plan_created", "pr_strategy": "none", "pipeline_phase": "phase-1"}` | SC-1, SC-2, SC-3, SC-4 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 1234, "phase": 1, "authorization_scope": "for_plan", "halt_at": "plan_created", "pr_strategy": "none", "pipeline_phase": "phase-1"}` | SC-1, SC-2, SC-3, SC-4 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 1234, "phase": 1, "authorization_scope": "for_plan", "halt_at": "plan_created", "pr_strategy": "none", "pipeline_phase": "phase-1"}` | SC-1, SC-2, SC-3, SC-4 |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 1234, "phase": 1, "authorization_scope": "for_plan", "halt_at": "plan_created", "pr_strategy": "none", "pipeline_phase": "phase-1"}` | SC-1, SC-2, SC-3, SC-4 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 1234, "phase": 1, "authorization_scope": "for_plan", "halt_at": "plan_created", "pr_strategy": "none", "pipeline_phase": "phase-1"}` | SC-1, SC-2, SC-3, SC-4 |

### Phase 2: Behavioral Enforcement Test

**Concern:** Test creation — write behavioral enforcement test that verifies the agent follows the new rule.
**Files:** `.opencode/tests/behaviors/dispatch-gate-canonical.sh`
**SCs covered:** SC-1, SC-2, SC-3, SC-4

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 1234, "phase": 2, "authorization_scope": "for_plan", "halt_at": "plan_created", "pr_strategy": "none", "pipeline_phase": "phase-2"}` | SC-1, SC-2, SC-3, SC-4 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1234, "phase": 2, "authorization_scope": "for_plan", "halt_at": "plan_created", "pr_strategy": "none", "pipeline_phase": "phase-2"}` | SC-1 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 1234, "phase": 2, "description": "Write behavioral enforcement test that sends a prompt with preloaded context and verifies sub-agent returns PRELOADED_CONTEXT_REJECTED. Test must FAIL because the rule doesn't exist yet.", "authorization_scope": "for_plan", "halt_at": "plan_created", "pr_strategy": "none", "pipeline_phase": "phase-2"}` | SC-4 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 1234, "phase": 2, "authorization_scope": "for_plan", "halt_at": "plan_created", "pr_strategy": "none", "pipeline_phase": "phase-2"}` | SC-4 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 1234, "phase": 2, "authorization_scope": "for_plan", "halt_at": "plan_created", "pr_strategy": "none", "pipeline_phase": "phase-2"}` | SC-1 |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 1234, "phase": 2, "description": "Create behavioral enforcement test at .opencode/tests/behaviors/dispatch-gate-canonical.sh that: (1) sends a prompt with preloaded context, (2) verifies sub-agent returns PRELOADED_CONTEXT_REJECTED, (3) sends canonical dispatch string, (4) verifies sub-agent returns valid result.", "authorization_scope": "for_plan", "halt_at": "plan_created", "pr_strategy": "none", "pipeline_phase": "phase-2"}` | SC-1, SC-2, SC-3, SC-4 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 1234, "phase": 2, "authorization_scope": "for_plan", "halt_at": "plan_created", "pr_strategy": "none", "pipeline_phase": "phase-2"}` | SC-1 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-1 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 1234, "phase": 2, "authorization_scope": "for_plan", "halt_at": "plan_created", "pr_strategy": "none", "pipeline_phase": "phase-2"}` | SC-1 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 1234, "phase": 2, "authorization_scope": "for_plan", "halt_at": "plan_created", "pr_strategy": "none", "pipeline_phase": "phase-2"}` | SC-1, SC-2, SC-3, SC-4 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 1234, "phase": 2, "authorization_scope": "for_plan", "halt_at": "plan_created", "pr_strategy": "none", "pipeline_phase": "phase-2"}` | SC-1, SC-2, SC-3, SC-4 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 1234, "phase": 2, "audit_phase": "plan_creation", "authorization_scope": "for_plan", "halt_at": "plan_created", "pr_strategy": "none", "pipeline_phase": "phase-2"}` | SC-1, SC-2, SC-3, SC-4 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 1234, "phase": 2, "authorization_scope": "for_plan", "halt_at": "plan_created", "pr_strategy": "none", "pipeline_phase": "phase-2"}` | SC-1, SC-2, SC-3, SC-4 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 1234, "phase": 2, "authorization_scope": "for_plan", "halt_at": "plan_created", "pr_strategy": "none", "pipeline_phase": "phase-2"}` | SC-1, SC-2, SC-3, SC-4 |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 1234, "phase": 2, "authorization_scope": "for_plan", "halt_at": "plan_created", "pr_strategy": "none", "pipeline_phase": "phase-2"}` | SC-1, SC-2, SC-3, SC-4 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 1234, "phase": 2, "authorization_scope": "for_plan", "halt_at": "plan_created", "pr_strategy": "none", "pipeline_phase": "phase-2"}` | SC-1, SC-2, SC-3, SC-4 |

### Inter-Phase Handoff

Between Phase 1 and Phase 2:
- Update Z3 state file: `solve state update` with phase 1's gate states
- Run `solve check`: confirm phase 1 dependency contract still SAT
- Verify checkpoint tag exists for phase 1
- Append lifecycle manifest event for phase 1 completion

### Post-All-Phases Sweep

- [ ] FINISHING CHECKLIST — route to finishing sub-agent: git status clean, lint/typecheck from scratch
- [ ] PR CREATION — N/A (pr_strategy: none)
- [ ] POST-MERGE CLEANUP — route to git-workflow cleanup: delete merged branches, close issues, sync dev

## Authorization Context

```
authorization_scope: for_pr
halt_at: pr_created
pr_strategy: stacked
pipeline_phase: phase-1
authorization_source: "User approved #1234 for PR on 2026-06-16"
```

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.
