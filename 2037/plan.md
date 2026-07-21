# Implementation Plan — [#2037](https://github.com/michael-conrad/.opencode/tree/issues-data/2037) — Universal Discussion Discipline

- **Goal:** Consolidate 5 scattered discussion discipline rules into a unified Tier 1 framework: universal question tool prohibition, pigeon-holing ban, single-topic enforcement, order of importance, and always-discuss default.
- **Architecture:** 6 sequential phases (1 pre-phase, 4 per-file phases, 1 post-phase). All phases modify overlapping files (`020-go-prohibitions.md` and `000-critical-rules.md` are touched by Phases 1-5), requiring strict sequential ordering with commit gates.
- **Files:** `.opencode/guidelines/020-go-prohibitions.md`, `.opencode/guidelines/000-critical-rules.md`, `.opencode/guidelines/010-approval-gate.md`, `.opencode/skills/approval-gate-scope/tasks/pre-implementation-analysis.md`, `.opencode/guidelines/140-planning-spec-creation.md`, `.opencode/tests-v2/behaviors/universal-discussion-discipline.sh`
- **Dispatch:** All phases dispatch via `task()` to clean-room sub-agents. Orchestrator holds routing metadata only.


## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | Question tool prohibited universally (all contexts, all scopes) | 1 | 1-10 |
| SC-2 | Pigeon-holing in natural language prohibited | 2 | 11-16 |
| SC-3 | Single-topic discipline enforced as Tier 1 | 3 | 17-22 |
| SC-4 | Order of importance rule established | 4 | 23-28 |
| SC-5 | Discussion as default, structured output as opt-in | 5 | 29-34 |
| SC-6 | Contradictory question tool instruction removed from 140-planning-spec-creation.md | 1 | 1-10 |
| SC-7 | Behavioral enforcement test passes 100% clean PASS | 6 | 35-40 |

## Safety/Rollback

No destructive operations in any phase — all changes are text edits to guideline/skill/test files. Rollback via `git checkout` on the feature branch.

## Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1-10 | `020-go-prohibitions.md` §1.6 | ✅ | Spec §Affected Files |
| 1-10 | `000-critical-rules.md` critical-rules-037 | ✅ | Spec §Affected Files |
| 1-10 | `010-approval-gate.md` edge case table | ✅ | Spec §Affected Files |
| 1-10 | `pre-implementation-analysis.md` scope qualifier | ✅ | Spec §Affected Files |
| 1-10 | `140-planning-spec-creation.md` question tool instruction | ✅ | Spec §Affected Files |
| 2-5 | `020-go-prohibitions.md` §1 🚫 NEVER DO | ✅ | Spec §Affected Files |
| 2-5 | `000-critical-rules.md` Tier 1 entries | ✅ | Spec §Affected Files |
| 6 | `universal-discussion-discipline.sh` | ✅ | Spec §Affected Files |

## Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| 5 scope qualifiers exist in 5 files | Spec §Problem | ✅ |
| SC-1 through SC-7 are defined | Spec §Success Criteria | ✅ |
| All 6 affected files exist | Spec §Affected Files | ✅ |

## Behavioral SC Exit Criteria

Each phase with behavioral SCs MUST include in its exit criteria:

1. **`behavior_run`** — Generate behavioral test artifacts (stdout.log, stderr.log, session.yaml)
2. **`behavioral-test-evaluation`** — Dispatch clean-room sub-agent to evaluate artifacts against SC
3. **PASS gate** — Only after clean-room evaluation returns PASS may the phase be marked complete

| Phase | SCs | evidence_type | VbC Gate |
|-------|-----|---------------|----------|
| 1 | SC-1 | behavioral | behavior_run → behavioral-test-evaluation → PASS |
| 2 | SC-2 | behavioral | behavior_run → behavioral-test-evaluation → PASS |
| 3 | SC-3 | behavioral | behavior_run → behavioral-test-evaluation → PASS |
| 4 | SC-4 | behavioral | behavior_run → behavioral-test-evaluation → PASS |
| 5 | SC-5 | behavioral | behavior_run → behavioral-test-evaluation → PASS |
| 6 | SC-7 | behavioral | behavior_run → behavioral-test-evaluation → PASS |

## Blast Radius

| Phase | Affected Files | Risk |
|-------|---------------|------|
| 1 | 020-go-prohibitions.md, 000-critical-rules.md, 010-approval-gate.md, pre-implementation-analysis.md, 140-planning-spec-creation.md | Medium — 5 files modified, scope qualifier removal across all |
| 2 | 020-go-prohibitions.md, 000-critical-rules.md | Low — new rule addition |
| 3 | 020-go-prohibitions.md, 000-critical-rules.md | Low — advisory text elevation |
| 4 | 020-go-prohibitions.md, 000-critical-rules.md | Low — new rule addition |
| 5 | 020-go-prohibitions.md, 000-critical-rules.md | Medium — section reframing |
| 6 | .opencode/tests-v2/behaviors/universal-discussion-discipline.sh | Low — additive only |

## Concern Map Reference

| Concern | Phases | Coordination |
|---------|--------|-------------|
| 020-go-prohibitions.md modification integrity | 1, 2, 3, 4, 5 | Sequential editing required |
| 000-critical-rules.md new entries ordering | 1, 2, 3, 4, 5 | Sequential insertion, consistent numbering |
| Behavioral enforcement test consistency | 1, 2, 3, 4, 5, 6 | Independent per-phase tests, shared infrastructure |
| Session-enforcement.ts enforcement block updates | 1 | May need update if rule scope changes |
| Pre-implementation-analysis task file consistency | 1 | Cross-file consistency with sub-tasks |

> **⚠️ COMPLIANCE REQUIREMENT:** This plan is a routing document. The orchestrator dispatches each step to a clean-room sub-agent via `task()` and receives a result contract. The orchestrator NEVER reads task file contents, performs inline work, or makes implementation decisions. Every step below is a dispatch instruction, not an implementation action. Violation of this discipline is a poisoned pipeline — full restart required.

> **⚠️ ONE-STEP-AT-A-TIME PROTOCOL:** Execute exactly one step at a time. After each step completes, verify the result contract before proceeding to the next step. Do NOT batch, combine, or parallelize steps. Each step is a discrete dispatch with its own entry/exit criteria.

### Step Status Instruction

Each step below uses one of three status markers:
- `(**sub-agent**)` — Dispatch via `task()` with phase file + orchestrator-provided context (issue number, spec path, artifact paths)
- `(**clean-room**)` — Dispatch via `task()` with phase file only (routing metadata only — no orchestrator context)
- `(**inline**)` — Orchestrator executes directly (no sub-agent)

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Steps | Dispatch |
|-------|------|---------|-----|-------------|-------|----------|
| 1 | Universal question tool prohibition | Remove scope qualifiers from 5 files | SC-1, SC-6 | Spec approved | 1-10 | sub-agent |
| 2 | Pigeon-holing in natural language prohibition | Add new Tier 1 critical rule | SC-2 | Phase 1 committed | 11-16 | sub-agent |
| 3 | Single-topic discipline enforcement | Elevate advisory text to Tier 1 | SC-3 | Phase 2 committed | 17-22 | sub-agent |
| 4 | Order of importance rule | Add new topic ordering rule | SC-4 | Phase 3 committed | 23-28 | sub-agent |
| 5 | Always discuss as default | Reframe discussion as default mode | SC-5 | Phase 4 committed | 29-34 | sub-agent |
| 6 | Behavioral enforcement test | Create and pass enforcement test | SC-7 | Phase 5 committed | 35-40 | sub-agent |

> **⚠️ COMPLIANCE REQUIREMENT:** This plan is a routing document. The orchestrator dispatches each step to a clean-room sub-agent via `task()` and receives a result contract. The orchestrator NEVER reads task file contents, performs inline work, or makes implementation decisions. Every step below is a dispatch instruction, not an implementation action. Violation of this discipline is a poisoned pipeline — full restart required.

> **⚠️ SELF-REMEDIATION PROTOCOL:** When a sub-agent returns BLOCKED, the orchestrator MUST discard all output from that sub-agent and re-task clean-room with the same scoped context (max 2 retries). If re-task also fails, report double-failure and HALT. The orchestrator MUST NOT inline-fix, patch, or salvage output from a BLOCKED sub-agent.

## Exit Criteria

- [ ] C1: All 5 discussion discipline rules exist as Tier 1 critical rules in `000-critical-rules.md`
- [ ] C2: All 5 rules have corresponding prohibitions in `020-go-prohibitions.md`
- [ ] C3: `010-approval-gate.md` edge case table references universal critical-rules-037
- [ ] C4: `pre-implementation-analysis.md` has no post-plan-presentation scope qualifier
- [ ] C5: `140-planning-spec-creation.md` has no question tool instruction
- [ ] C6: Behavioral enforcement test exists at `.opencode/tests-v2/behaviors/universal-discussion-discipline.sh`
- [ ] C7: Behavioral enforcement test passes with 100% clean PASS
- [ ] C8: All changes committed to feature branch with sequential commits (one per phase)
