---
number: 7
title: "[PLAN] #397 Intelligent Audit Dispatch"
status: "open"
labels: [plan, approved-for-pr]
created: "2026-05-06T18:56:06Z"
updated: "2026-05-06T18:56:06Z"
github_issue: 397
author: "Michael Conrad"
---

# Plan: #397 Intelligent Audit Dispatch — Audit Phase Identity, Semantic Depth, and Clean Room Protocol

## Source Spec

GitHub Issue [#397](https://github.com/michael-conrad/.opencode/issues/397) — `[SPEC-FIX] Intelligent Audit Dispatch`

## Scope

This plan covers #397 only. Sub-issue #405 (Layer 3 semantic dimension procedures) requires #397's PR to merge first (PR merge boundary) and will be implemented in a separate PR.

## Phase Decomposition

### Phase 1: Agent Card Clean Room Protocol (SC-1, SC-2, SC-3, SC-4)

**Goal:** All 9 auditor agent cards get clean room violation detection, semantic depth mandate, CONTEXT_TAINTED refusal, and `clean_room` output block.

**Files:**
| File | Change |
|------|--------|
| `.opencode/agents/auditor-deepseek-v4.md` | Add MANDATORY FIRST CHECK, semantic depth mandate, CONTEXT_TAINTED refusal, clean_room output block |
| `.opencode/agents/auditor-deepseek-v3.md` | Same |
| `.opencode/agents/auditor-deepseek-flash.md` | Same |
| `.opencode/agents/auditor-glm-5.md` | Same |
| `.opencode/agents/auditor-glm-5.1.md` | Same |
| `.opencode/agents/auditor-qwen3.5.md` | Same |
| `.opencode/agents/auditor-kimi-k2.md` | Same |
| `.opencode/agents/auditor-devstral-2.md` | Same |
| `.opencode/agents/auditor-mistral-large.md` | Same |

**SCs verified:** SC-1 (clean room violation detection), SC-2 (semantic depth mandate), SC-3 (`clean_room` output block), SC-4 (agent cards remain generic — accept `audit_phase` from dispatch)

**Verification:** `auditor-context-tainted-refusal.sh` behavioral test (SC-8 of #397)

### Phase 2: SKILL.md Phase Identity (SC-5, SC-6)

**Goal:** Each auditor SKILL.md declares its audit phase identity. All dispatching skills include `audit_phase` in dispatch context.

**Files:**
| File | Change |
|------|--------|
| `.opencode/skills/spec-auditor/SKILL.md` | Add audit phase identity (`phase: spec`) to Persona/Operating Protocol |
| `.opencode/skills/plan-fidelity-auditor/SKILL.md` | Add audit phase identity (`phase: plan_fidelity`) |
| `.opencode/skills/concern-separation-auditor/SKILL.md` | Add audit phase identity (`phase: concern_separation`) |
| `.opencode/skills/coherence-auditor/SKILL.md` | Add audit phase identity (`phase: coherence`) |
| `.opencode/skills/adversarial-audit/SKILL.md` | Add audit phase identity + ensure dispatch context includes `audit_phase` |
| `.opencode/skills/approval-gate/SKILL.md` | Add `audit_phase` to dispatch context schema |
| `.opencode/skills/divide-and-conquer/SKILL.md` | Add `audit_phase` to dispatch context schema |
| `.opencode/skills/executing-plans/SKILL.md` | Add `audit_phase` to dispatch context schema |
| `.opencode/skills/finishing-a-development-branch/SKILL.md` | Add `audit_phase` to dispatch context schema |
| `.opencode/skills/writing-plans/SKILL.md` | Add `audit_phase` to dispatch context schema |
| `.opencode/skills/verification-before-completion/SKILL.md` | Add `audit_phase` to dispatch context schema (receives `audit_phase: implementation`) |

**SCs verified:** SC-5 (phase identity in SKILL.md files), SC-6 (`audit_phase` in dispatch context)

**Verification:** Content-verification (`--tag semantic-depth`) for agent card bodies; `auditor-semantic-exploration.sh` behavioral test (SC-9 of #397)

### Phase 3: Critical Violation `critical-rules-046` (SC-7)

**Goal:** Add mechanical-only audit critical violation to `000-critical-rules.md`.

**Files:**
| File | Change |
|------|--------|
| `.opencode/guidelines/000-critical-rules.md` | Add `critical-rules-046` yaml+symbolic block: "Mechanical-only audit without full semantic and conflict exploration is prohibited" |

**SCs verified:** SC-7 (critical violation for mechanical-only audit)

**Verification:** Content-verification tag check for `semantic-depth` in agent card bodies; behavioral test enforcement

### Phase 4: Behavioral Tests (SC-8, SC-9)

**Goal:** Create behavioral enforcement tests for clean room refusal and semantic exploration.

**Files:**
| File | Change |
|------|--------|
| `.opencode/tests/behaviors/auditor-context-tainted-refusal.sh` | NEW — dispatches auditor with intentionally tainted dispatch context |
| `.opencode/tests/behaviors/auditor-semantic-exploration.sh` | NEW — dispatches auditor with plan-spec pairing where plan claims "all" but spec lists incomplete files |
| `.opencode/tests/behaviors/phase3-auditor-infra-fix.sh` | UPDATE — agent card output format change (clean_room block) |
| `.opencode/tests/behaviors/clean-room-test-dispatch.sh` | UPDATE — dispatch context schema change (audit_phase) |
| `.opencode/tests/behaviors/clean-room-structural-verify.sh` | UPDATE — dispatch context schema change |
| `.opencode/tests/behaviors/clean-room-implementation-dispatch.sh` | UPDATE — dispatch context schema change |
| `.opencode/tests/behaviors/clean-room-git-workflow-dispatch.sh` | UPDATE — dispatch context schema change |
| `.opencode/tests/behaviors/model-aware-clean-room-dispatch.sh` | UPDATE — dispatch context schema change |
| `.opencode/tests/behaviors/adversarial-audit-skill-exists.sh` | UPDATE — agent card content change |

**SCs verified:** SC-8 (behavioral test for context-tainted refusal), SC-9 (behavioral test for semantic exploration)

**Verification:** Run both new behavioral tests to confirm they pass after implementation

### Phase 5: Verification + Commit

**Goal:** Run all behavioral and content-verification tests. Commit and push.

**Steps:**
1. Run content-verification: `bash .opencode/tests/test-enforcement.sh --tag semantic-depth`
2. Run behavioral tests: `auditor-context-tainted-refusal.sh`, `auditor-semantic-exploration.sh`
3. Run existing behavioral tests that were updated: `phase3-auditor-infra-fix.sh`, `clean-room-*.sh`, `adversarial-audit-skill-exists.sh`
4. Fix any failures
5. Commit all changes on `fix/397-intelligent-audit-dispatch`
6. Push to remote

## Execution Order

Phases 1→2→3→4→5 are sequential (each depends on prior). Phase 4 behavioral tests will initially be RED, then turn GREEN after Phases 1-3 implementation.

**Stacking strategy:** All phases stack on the same branch (`fix/397-intelligent-audit-dispatch`). No parallel execution — each phase builds on the prior.

## PR Strategy

Single PR targeting `dev` in `michael-conrad/.opencode`. Contains all 9 SCs from #397.

## Out of Scope

- #405 (Layer 3 semantic dimension procedures) — requires #397 merged first
- Any changes to existing behavioral tests beyond schema/format updates listed above