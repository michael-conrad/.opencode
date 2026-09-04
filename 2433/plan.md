---
plan_schema_version: 1
issue: 2433
title: "Implementation Plan — Remediate Orchestrator Dispatch Discipline (#2433)"
dispatch: [test-driven-development, verification-before-completion, audit, finishing-a-development-branch, git-workflow-pr, completion-core]
---

# Implementation Plan — Remediate Orchestrator Dispatch Discipline

**Issue:** [#2433](https://github.com/michael-conrad/.opencode/issues/2433) — the authoritative spec lives at `.opencode/.issues/2433/spec.md` on the `issues-data` branch; the remote issue body is a condensed exec summary only.

## Goal / Architecture / Files / Dispatch

- **Goal:** Adopt Architecture B as the single orchestrator architecture across the `.opencode` directive layer — the orchestrator loads skill cards and executes workflow steps directly in its own context, dispatching task cards via `task()` only where the workflow marks dispatch — and re-point every directive layer (system prompt, guidelines, skill deck, plan layer, AGENTS.md) at it, closing with a single-sourced canonical dispatch vocabulary.
- **Architecture:** Directive-text-only remediation (spec §2). Eight phases, one success criterion per phase, executed in topological order of the phase DAG. All 8 success criteria are behavioral: verification runs through behavioral probes dispatched via `task()` from the working session (no isolated environment, no project writes) plus direct reading of the edited text artifacts. Static substitutes are EVIDENCE_TYPE_MISMATCH — an unexecutable probe is FAIL, never a structural pass.
- **Files:** `.opencode/prompts/default.txt`; `.opencode/guidelines/022-orchestrator-context-discipline.md`; `.opencode/guidelines/000-critical-rules.md`; `.opencode/skills/executing-plans/SKILL.md`, `tasks/read-plan.md`, `tasks/dispatch-phase.md`; `.opencode/skills/**/SKILL.md` (51-card deck surface); `.opencode/reference/task-card-structure-standards.md`; `.opencode/reference/skill-card-description-standards.md`; `.opencode/skills/writing-plans/SKILL.md`, `reference/plan-artifact-format.md`, `tasks/create.md`; `.opencode/AGENTS.md` (Universal Skill Dispatch Gate section only).
- **Dispatch:** Every phase runs the full per-task cycle from the implementation-workflow reference card — pre-regression → pre-regression-verify → RED → GREEN → post-regression → verify → commit-inline. The RED/GREEN/post-regression steps dispatch `test-driven-development` task cards; the pre-regression-verify and verify steps dispatch `verification-before-completion` task cards; commit-inline runs as orchestrator-direct `git add` + `git commit` in the `.opencode` submodule. Post-implementation gates run once after the last phase: audit → z3-check → structural-checks → pre-pr-gate → regression-check → review-prep → create-pr → exec-summary.
- **Branch:** All implementation commits land on `feature/2402-finishing-checklist-trailer-remediation` in the `michael-conrad/.opencode` submodule. No co-author trailers on implementation commits — those are added during squash at PR time.

## Blast Radius

From the blast-radius artifact (`.opencode/.issues/2433/artifacts/blast-radius.md`):

- **Quantified surface:** 51 SKILL.md cards (284 `task(subagent_type=...)` dispatch strings; 49/51 TDTs route tasks to sub-agents); 299 task cards; 35 guidelines (`022` is the architecture-defining doc; `000-critical-rules.md` carries the whole-card prohibition); 3 reference standards cards; 1 system prompt loaded into every session; open plans #1210/#1214 carry a third dispatch vocabulary and are superseded (spec §12), not edited.
- **Directly affected (must change):** the system prompt routing-boundary prose; `022` pure-router framing and inline-HALT rows; `000-critical-rules.md` carve-out and routing-bypass classifications (whole-card prohibition retained); executing-plans card and its read-plan/dispatch-phase task cards; the 3 TDT-contradiction cards (audit, brainstorming, spec-creation); all 45 blanket-clause cards; the writing-plans plan-format surface; both standards reference cards; `.opencode/AGENTS.md` dispatch directives.
- **Indirectly affected:** behavioral tests under the tests-v2 tree whose scenario expectations assert the old dispatch model — expectations update alongside each GREEN; skildeck validators may gain additive closed-set/mode checks (optional, out of scope for this plan).
- **Out of scope:** node_modules, venvs, `.issues/` data bodies, Python test tooling, and all application code — no code file of any kind is touched (spec §2).

**State invariants (hold at every phase boundary):**

- All 51 SKILL.md retain the `ORCHESTRATOR_ONLY_SKILL_CARD` pre-flight guard after any card edit.
- Sub-agent result contract envelope `{status, finding_summary, artifact_path, blocker_reason}` unchanged.
- Retired vocabularies in pre-existing plans remain readable; only new plans carry closed-set per-step modes.
- Directive text only — no code, DB, or serialized-data change.
- No `.opencode/.opencode/` nested directory creation; markdown lint/format gates keep passing on edited guideline/reference files.

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Steps | Dispatch |
|---|---|---|---|---|---|---|
| 1 | System Prompt Architecture-B Rewrite | Rewrite `prompts/default.txt` Sub-Agent Routing Boundary + Pre-Response Gate to Architecture B; remove Architecture-A forwarding prose | SC-1 | none | 1–8 | test-driven-development (pre-regression, red, green, post-regression); verification-before-completion (pre-regression-verify, verify); commit-inline |
| 2 | Directive-Layer HALT Machinery Re-Pointing | Re-point `022` pure-router framing + inline-HALT rows to whole-card/whole-plan forwarding triggers; align `000-critical-rules` classifications; retain whole-card prohibition | SC-2 | none | 1–8 | test-driven-development; verification-before-completion; commit-inline |
| 3 | executing-plans Plan-Execution Rewrite | Orchestrator reads plan + executes steps directly; step-scoped `task()` only at marked points | SC-3 | none | 1–8 | test-driven-development; verification-before-completion; commit-inline |
| 4 | Whole-Card Forwarding Elimination | No `task()` string targets a SKILL.md path; guards retained 51/51 by direct reading | SC-4 | Phase 3 | 1–8 | test-driven-development; verification-before-completion; commit-inline |
| 5 | Plan Pre-Flight Guard | `ORCHESTRATOR_ONLY_PLAN` guard definition in canonical standards docs + sub-agent entry pattern | SC-5 | none | 1–8 | test-driven-development; verification-before-completion; commit-inline |
| 6 | TDT Closed-Set Vocabulary Migration | TDT Dispatch values → {`orchestrator`, `task-card`, `task-card blind`}; resolve 3 contradictions; rewrite blanket clause in 45 cards | SC-6 | Phases 3, 4 | 1–8 | test-driven-development; verification-before-completion; commit-inline |
| 7 | Per-Step Plan Dispatch Mode | `direct` \| `task-card` (default `direct`) per-step mode in canonical plan format; producer templates emit it | SC-7 | none | 1–8 | test-driven-development; verification-before-completion; commit-inline |
| 8 | Canonical Dispatch-Vocabulary Single-Sourcing | Canonical table in reference layer; Read-link conversions across directive-layer files incl. AGENTS.md; strip system-prompt duplicates; then post-implementation gates | SC-8 | Phases 1, 2, 5, 7 | 1–8 + post 1–8 | test-driven-development; verification-before-completion; audit; solve (z3-check); finishing-a-development-branch; git-workflow-pr; completion-core |

## Self-Remediation Protocol

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

**Recovery (spec §11):** if a behavioral GREEN regresses a previously passing SC, the affected earlier SC re-runs before the pipeline advances — the enforcement gate is all-or-nothing.

## Exit Criteria

- [ ] C1. All 8 SCs verified PASS with behavioral evidence artifacts; no SC left FAIL or UNVERIFIED (all-or-nothing enforcement gate).
- [ ] C2. Phases executed in topological order (1, 2, 3, 4, 5, 6, 7, 8); every phase's commit preceded its dependents' RED; no circular dependency encountered.
- [ ] C3. `ORCHESTRATOR_ONLY_SKILL_CARD` guards retained 51/51 after every card edit.
- [ ] C4. All commits landed on `feature/2402-finishing-checklist-trailer-remediation` in the `.opencode` submodule; no co-author trailers on implementation commits.
- [ ] C5. Closed-set vocabulary {`orchestrator`, `task-card`, `task-card blind`} holds across all 51 TDTs with TDT-vs-Invocation agreement; the blanket clause is absent from all 45 former carriers.
- [ ] C6. The canonical dispatch-vocabulary table exists in the reference layer; every directive-layer file references it via Read-link; the system prompt carries no duplicated or contradictory dispatch definitions.
- [ ] C7. Audit completed and z3-check recorded; no unresolved findings.
- [ ] C8. Pre-PR gate reports all SC verdicts PASS; final regression check clean.
- [ ] C9. PR created (stacked strategy) for the `.opencode` submodule; completion executive summary produced.

---

## Pre-Implementation (Tier 1 — once per plan)

- [ ] 1. (**inline**) Run the coherence gate before any file modification.
  - Verify the plan-phase-to-SC mapping is 1:1: eight phases map to SC-1..SC-8 per spec Items 1–8, with each phase's item referencing exactly one SC-ID.
  - Verify the phase DAG (edges 3→4, 3→6, 4→6, 1→8, 2→8, 5→8, 7→8) matches the spec §11 overlapping-file ordering constraints and contains no circular dependency.
  - Verify all 8 SCs are covered by exactly one phase and the dependency contract (`dependency-contract.yaml`) matches the structure artifact.
- [ ] 2. (**inline**) Run the baseline check before any file modification.
  - Verify the `.opencode` submodule is on branch `feature/2402-finishing-checklist-trailer-remediation` with zero pending changes and at the remote tracking tip (git-workflow pre-work re-verification).
  - Record the baseline: `ORCHESTRATOR_ONLY_SKILL_CARD` guard count measured 51/51; `ORCHESTRATOR_ONLY_PLAN` occurrences measured 0 across skills/guidelines/reference/prompts.
  - Verify the behavioral-probe model is available (`qwen3.8:27b-256k-gguf4`) — probes require real-model execution; claim unavailability only with tool-call evidence.

---

# Phase 1 — System Prompt Architecture-B Rewrite

## Phase Metadata

- **Concern:** Rewrite the system prompt dispatch directives (`prompts/default.txt` Sub-Agent Routing Boundary + Pre-Response Gate) to Architecture B — the orchestrator executes skill workflow steps directly in its own context and dispatches a task card via `task()` only where the workflow marks dispatch; the Architecture-A prose "The orchestrator routes. It does not do." and the "hand off to executing-plans via sub-agent" forwarding language are absent.
- **Files:** `.opencode/prompts/default.txt`
- **SCs:** SC-1
- **Dependencies:** none (first phase)
- **Entry condition:** baseline check passed; working tree clean on the feature branch
- **Exit condition:** SC-1 verify verdict PASS recorded; commit landed on the feature branch

## Code Path Coverage

- Sub-Agent Routing Boundary section: rewrite the Architecture-A routing prose to Architecture B direct-execution semantics.
- The "hand off to executing-plans via sub-agent" forwarding line: removed and replaced with orchestrator-own plan execution language.
- Pre-Response Gate dispatch step: `task()`-only-at-marked-points semantics retained and made the sole routing surface.

## Cross-Cutting SCs

- None — SC-1 is directive-layer primary per the cross-cutting matrix. Its Read-link conversion to the canonical vocabulary table happens in Phase 8.

## Interface Boundaries

- `task()` dispatch-string contract: `task()` accepts only task-card dispatch strings — no card content, no whole plan bodies; the result contract envelope is unchanged (spec §2).
- The canonical-table Read-link edge from this file lands in Phase 8; Phase 1 writes the Architecture-B prose that edge will reference.

## State Transitions

- From: the system prompt carries both architectures (Architecture-A prose at the routing boundary and the executing-plans hand-off line; Architecture-B procedure at the Pre-Response Gate dispatch step).
- To: the system prompt carries Architecture B only — orchestrator executes workflow steps directly; `task()` only at marked points; no Architecture-A forwarding prose. Persistent file-content state, loaded at every session start.

**Cost frame:** Running the skill-trigger behavioral probe costs minutes of model execution time — the defect (whole-card forwarding) is caught at the earliest gate and the fix costs one bounded re-run. Skipping means the averaging defect ships in the system prompt loaded into every future session, and every skill invocation thereafter inherits it — the death spiral starts at the highest-leverage file in the deck.

## Step-by-step

- [ ] 1. (**inline**) Clean stale artifacts for this phase's pipeline steps.
  - Remove previous-run artifacts so stale state cannot contaminate this run: `rm -f tmp/2433/artifacts/pipeline-pre-regression-* tmp/2433/artifacts/pipeline-pre-regression-verify-* tmp/2433/artifacts/pipeline-red-* tmp/2433/artifacts/pipeline-green-* tmp/2433/artifacts/pipeline-post-regression-* tmp/2433/artifacts/pipeline-verify-*`
- [ ] 2. (**sub-agent**) Run pre-regression.
  - Dispatch: `task(..., prompt: "execute phase-0 task from test-driven-development")`
  - Purpose: run regression test patterns before the RED phase; confirm no unrelated behavioral regressions are already present.
- [ ] 3. (**sub-agent**) Verify pre-regression results.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Purpose: verify the pre-regression run is clean before RED begins.
- [ ] 4. (**sub-agent**) RED — write the failing behavioral probe for SC-1.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Probe type: skill-trigger prompt dispatched from the working session (no isolated environment, no project writes).
  - What fails: the probe currently shows whole-card forwarding or router-model dispatch — SKILL.md content inside a `task()` prompt, or the orchestrator not executing workflow steps in its own context.
- [ ] 5. (**sub-agent**) GREEN — implement the SC-1 change that makes the probe pass.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - What must be true: the Sub-Agent Routing Boundary and Pre-Response Gate state Architecture B (orchestrator executes skill workflow steps directly in its own context; `task()` dispatches a task card only where the workflow marks dispatch); the prose "The orchestrator routes. It does not do." and the "hand off to executing-plans via sub-agent" forwarding language are absent from `prompts/default.txt`.
  - Minimum change only — no scope creep beyond the two named sections; update any behavioral scenario expectations that assert the old model in the same GREEN.
- [ ] 6. (**sub-agent**) Run post-regression.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Purpose: run regression test patterns after GREEN; confirm the rewrite broke nothing else.
- [ ] 7. (**sub-agent**) Verify SC-1 against its success criterion.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Verify: the probe asserts the orchestrator executes workflow steps in its own context, `task()` appears only at marked points, and no card content sits inside any `task()` prompt; direct reading of `prompts/default.txt` confirms the Architecture-A prose is gone. Evidence recorded per the SC's behavioral evidence type — structural substitutes are EVIDENCE_TYPE_MISMATCH.
- [ ] 8. (**inline**) Commit the SC-1 slice.
  - From the `.opencode` submodule working tree: `git add .opencode/prompts/default.txt && git commit -m "Item 1 (SC-1): rewrite system prompt dispatch directives to Architecture B"`
  - No co-author trailers on implementation commits.

## Phase Completion

- SC-1 verify verdict is PASS, recorded in the pipeline-verify evidence artifact for this phase.
- Behavioral probe evidence preserved under the pipeline artifact path for audit cross-validation.
- The commit is present on `feature/2402-finishing-checklist-trailer-remediation`; working tree clean.
- Concern transition: Phase 2 re-points the directive-layer HALT machinery to the same forwarding-based trigger this rewrite establishes.

---

# Phase 2 — Directive-Layer HALT Machinery Re-Pointing

## Phase Metadata

- **Concern:** Re-point the directive-layer HALT machinery — rewrite `022-orchestrator-context-discipline.md` (pure-router framing, inline-work HALT rows) to forwarding-based triggers; align `000-critical-rules.md` carve-out and routing-bypass classifications; retain the whole-card dispatch prohibition. Sanctioned direct execution of workflow steps by the orchestrator is NOT prohibited.
- **Files:** `.opencode/guidelines/022-orchestrator-context-discipline.md`, `.opencode/guidelines/000-critical-rules.md`
- **SCs:** SC-2
- **Dependencies:** none
- **Entry condition:** working tree clean; Phase 1 not required (independent directive surface)
- **Exit condition:** SC-2 verify verdict PASS recorded; commit landed on the feature branch

## Code Path Coverage

- `022`: remove the pure-router framing ("pure router — never performing work inline"); re-point the halt machinery from inline-work rows to whole-card/whole-plan forwarding triggers.
- `000-critical-rules`: retain the whole-card prohibition (critical-rules-XXX); re-point the Infrastructure-Failure Carve-out and routing-bypass classifications to forwarding-based violations consistent with `022`'s re-pointed machinery.

## Cross-Cutting SCs

- None — SC-2 is directive-layer primary per the cross-cutting matrix. Its Read-link conversion to the canonical vocabulary table happens in Phase 8.

## Interface Boundaries

- Directive-alignment edge between `000-critical-rules.md` and `022` (dependency contract): the classifications must reference forwarding-based violations consistent with the re-pointed halt machinery.
- Halt-machinery trigger condition changes from orchestrator-inline-work to whole-card/whole-plan forwarding; the halt behavior itself is preserved.

## State Transitions

- From: `022` defines the orchestrator as a pure router and HALTs on inline work; `000-critical-rules` whole-card prohibition already correct.
- To: `022`'s halt machinery fires on whole-card/whole-plan forwarding; sanctioned direct execution is not halted; `000-critical-rules` carve-out and routing-bypass classifications aligned with the prohibition retained. Persistent guideline text state, enforced at directive read time.

**Cost frame:** Running the direct-execution and forwarding probes costs minutes. Skipping means the HALT machinery keeps firing on correct behavior and never fires on the defect — the orchestrator learns that following the rules is punished, which trains the averaging behavior this plan exists to remove.

## Step-by-step

- [ ] 1. (**inline**) Clean stale artifacts for this phase's pipeline steps.
  - `rm -f tmp/2433/artifacts/pipeline-pre-regression-* tmp/2433/artifacts/pipeline-pre-regression-verify-* tmp/2433/artifacts/pipeline-red-* tmp/2433/artifacts/pipeline-green-* tmp/2433/artifacts/pipeline-post-regression-* tmp/2433/artifacts/pipeline-verify-*`
- [ ] 2. (**sub-agent**) Run pre-regression.
  - Dispatch: `task(..., prompt: "execute phase-0 task from test-driven-development")`
  - Purpose: regression patterns before RED.
- [ ] 3. (**sub-agent**) Verify pre-regression results.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 4. (**sub-agent**) RED — write the failing behavioral probe for SC-2.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Probe type: behavioral probes dispatched from the working session — one exercising sanctioned direct workflow execution, one exercising whole-card forwarding.
  - What fails: the probe asserting the current state shows `022` still HALTs on sanctioned direct execution — the old rule fires on correct behavior.
- [ ] 5. (**sub-agent**) GREEN — implement the SC-2 change that makes the probes pass.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - What must be true: `022` no longer defines the orchestrator as a pure router and no longer HALTs on orchestrator inline work; its halt machinery fires on whole-card/whole-plan forwarding instead; `000-critical-rules.md` retains the whole-card dispatch prohibition and its Infrastructure-Failure Carve-out and routing-bypass classifications reference forwarding-based violations.
  - Update any behavioral scenario expectations that assert the old inline-work trigger in the same GREEN.
- [ ] 6. (**sub-agent**) Run post-regression.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 7. (**sub-agent**) Verify SC-2 against its success criterion.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Verify: behavioral probes — orchestrator performing sanctioned direct workflow execution is not halted; orchestrator forwarding a whole card is halted; direct reading of both guideline files confirms the re-pointed machinery and the retained prohibition.
- [ ] 8. (**inline**) Commit the SC-2 slice.
  - From the `.opencode` submodule working tree: `git add .opencode/guidelines/022-orchestrator-context-discipline.md .opencode/guidelines/000-critical-rules.md && git commit -m "Item 2 (SC-2): re-point directive-layer HALT machinery to forwarding triggers"`

## Phase Completion

- SC-2 verify verdict PASS recorded in the pipeline-verify evidence artifact.
- Both probes' behavioral evidence preserved for audit cross-validation.
- Commit present on the feature branch; working tree clean.
- Concern transition: Phase 3 rewrites the plan-execution architecture in the skill deck to match the corrected directive layer.

---

# Phase 3 — executing-plans Plan-Execution Rewrite

## Phase Metadata

- **Concern:** Rewrite the `executing-plans` plan-execution architecture — the orchestrator reads the plan file directly, executes steps step-by-step in its own context, and dispatches a step's task card via `task()` only where that step marks dispatch; the read-plan/dispatch-phase routing that sends the whole plan or whole workflow to a sub-agent is absent.
- **Files:** `.opencode/skills/executing-plans/SKILL.md`, `.opencode/skills/executing-plans/tasks/read-plan.md`, `.opencode/skills/executing-plans/tasks/dispatch-phase.md`
- **SCs:** SC-3
- **Dependencies:** none (Phases 4 and 6 depend on this phase)
- **Entry condition:** working tree clean
- **Exit condition:** SC-3 verify verdict PASS recorded; commit landed on the feature branch

## Code Path Coverage

- `executing-plans/SKILL.md`: route plan execution to the orchestrator — reads the plan file directly, executes steps step-by-step in its own context.
- `tasks/read-plan.md`: rewritten from sub-agent routing to orchestrator-own-context plan reading.
- `tasks/dispatch-phase.md`: rewritten from whole-phase/workflow dispatch to step-scoped `task()` dispatch only where a plan step marks dispatch.

## Cross-Cutting SCs

- SC-3 spans the plan layer (primary) and skill deck layer (secondary). The wrapped-tail blanket clause carried on this card is rewritten later by Phase 6 — spec §11 ordering runs SC-3 before SC-6 so the clause rewrite lands on the already-corrected card.

## Interface Boundaries

- TDT-reference edge from `executing-plans/SKILL.md` to `tasks/read-plan.md`: the read-plan card must route plan reading to the orchestrator's own context, not a sub-agent.
- TDT-reference edge from `executing-plans/SKILL.md` to `tasks/dispatch-phase.md`: step-scoped `task()` dispatch only where the plan step marks dispatch; whole-plan/whole-workflow forwarding absent.

## State Transitions

- From: `executing-plans` routes read-plan and dispatch-phase to sub-agents; no directive anywhere says the orchestrator executes plan steps directly.
- To: `executing-plans` routes plan execution to the orchestrator — reads the plan directly, executes steps step-by-step, `task()` only at step-marked points. Persistent skill/task-card text state.

**Cost frame:** Running the approved-plan behavioral probe costs minutes. Skipping means plans continue to be wholesale-forwarded to leaf sub-agents that stall, fabricate completion, or return partial work as complete — the defect surfaces as silent pipeline corruption discovered days later in review.

## Step-by-step

- [ ] 1. (**inline**) Clean stale artifacts for this phase's pipeline steps.
  - `rm -f tmp/2433/artifacts/pipeline-pre-regression-* tmp/2433/artifacts/pipeline-pre-regression-verify-* tmp/2433/artifacts/pipeline-red-* tmp/2433/artifacts/pipeline-green-* tmp/2433/artifacts/pipeline-post-regression-* tmp/2433/artifacts/pipeline-verify-*`
- [ ] 2. (**sub-agent**) Run pre-regression.
  - Dispatch: `task(..., prompt: "execute phase-0 task from test-driven-development")`
- [ ] 3. (**sub-agent**) Verify pre-regression results.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 4. (**sub-agent**) RED — write the failing behavioral probe for SC-3.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Probe type: approved-plan prompt dispatched from the working session.
  - What fails: the probe currently shows whole-plan/workflow dispatch to a sub-agent — the plan body or the whole workflow inside a `task()` prompt.
- [ ] 5. (**sub-agent**) GREEN — implement the SC-3 change that makes the probe pass.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - What must be true: the skill card routes plan execution to the orchestrator — it reads the plan file directly and executes steps step-by-step in its own context; a step's task card is dispatched via `task()` only where that step marks dispatch; the read-plan/dispatch-phase sub-agent routing is absent from all three files.
- [ ] 6. (**sub-agent**) Run post-regression.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 7. (**sub-agent**) Verify SC-3 against its success criterion.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Verify: the probe asserts plan steps executed with orchestrator-own tool calls and `task()` only at step-marked points; no whole-plan body inside any `task()` prompt; direct reading of the three skill files confirms the routing rewrite.
- [ ] 8. (**inline**) Commit the SC-3 slice.
  - From the `.opencode` submodule working tree: `git add .opencode/skills/executing-plans/SKILL.md .opencode/skills/executing-plans/tasks/read-plan.md .opencode/skills/executing-plans/tasks/dispatch-phase.md && git commit -m "Item 3 (SC-3): rewrite executing-plans plan-execution to orchestrator-owned steps"`

## Phase Completion

- SC-3 verify verdict PASS recorded in the pipeline-verify evidence artifact.
- Behavioral evidence preserved for audit cross-validation.
- Commit present on the feature branch; working tree clean.
- Concern transition: Phase 4 sweeps the deck's dispatch strings — the corrected `executing-plans` card is included in the sweep surface (DAG edge 3→4).

---

# Phase 4 — Whole-Card Forwarding Elimination (Deck-Wide)

## Phase Metadata

- **Concern:** Eliminate whole-card forwarding across the deck — no SKILL.md contains a `task()` dispatch string whose target is a SKILL.md path or that forwards card content; all 51 SKILL.md retain the `ORCHESTRATOR_ONLY_SKILL_CARD` pre-flight guard, verified by direct reading.
- **Files:** `.opencode/skills/**/SKILL.md` (offending dispatch strings; 51-card sweep surface)
- **SCs:** SC-4
- **Dependencies:** Phase 3 (the `executing-plans` card must be in corrected Architecture-B form before the deck-wide sweep touches its dispatch strings — spec §11 overlapping-file ordering)
- **Entry condition:** Phase 3 commit landed; working tree clean
- **Exit condition:** SC-4 verify verdict PASS recorded; commit landed on the feature branch

## Code Path Coverage

- Deck sweep: audit every `task()` dispatch string across the 51 SKILL.md files; fix any whose target is a SKILL.md path (whole-card forwarding invitation).
- Guard verification: all 51 SKILL.md retain `ORCHESTRATOR_ONLY_SKILL_CARD`, confirmed by direct reading (measured 51/51 at baseline).

## Cross-Cutting SCs

- SC-4 spans the skill deck layer (primary) and plan layer (secondary) — the whole-card prohibition shares the vocabulary and guard-semantics layer with the plan guard (SC-5); both are pre-flight-guard backstops defined in the standards docs.

## Interface Boundaries

- Vocabulary-conformance edge over the 51-card deck: guards `ORCHESTRATOR_ONLY_SKILL_CARD` retained in 51/51 (shared invariant with SC-6).
- Guard presence alone is insufficient — SC-4 fails on the dispatch-string condition even when guards are retained (spec §11 edge case); both conditions must pass.

## State Transitions

- From: some SKILL.md carry `task()` dispatch strings targeting SKILL.md paths (whole-card forwarding invitations); guards present 51/51.
- To: no SKILL.md contains a `task()` string targeting a SKILL.md path or forwarding card content; guards retained 51/51. Persistent deck-wide dispatch-string state; guard count must remain 51 after every card edit.

**Cost frame:** Running the dispatch-string behavioral probe costs minutes. Skipping means whole-card forwarding invitations persist across the deck, and the guard converts each affected skill invocation into a stall-retry loop instead of a correction — every affected invocation pays the cost.

## Step-by-step

- [ ] 1. (**inline**) Clean stale artifacts for this phase's pipeline steps.
  - `rm -f tmp/2433/artifacts/pipeline-pre-regression-* tmp/2433/artifacts/pipeline-pre-regression-verify-* tmp/2433/artifacts/pipeline-red-* tmp/2433/artifacts/pipeline-green-* tmp/2433/artifacts/pipeline-post-regression-* tmp/2433/artifacts/pipeline-verify-*`
- [ ] 2. (**sub-agent**) Run pre-regression.
  - Dispatch: `task(..., prompt: "execute phase-0 task from test-driven-development")`
- [ ] 3. (**sub-agent**) Verify pre-regression results.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 4. (**sub-agent**) RED — write the failing behavioral probe for SC-4.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Probe type: skill-trigger behavioral probe dispatched from the working session.
  - What fails: the probe shows card content inside `task()` prompts for at least one offending dispatch string.
- [ ] 5. (**sub-agent**) GREEN — implement the SC-4 change that makes the probe pass.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - What must be true: every offending `task()` dispatch string is re-pointed to its task card (no SKILL.md-path targets, no card-content forwarding); all 51 SKILL.md retain the `ORCHESTRATOR_ONLY_SKILL_CARD` pre-flight guard, verified by direct reading of every card's guard line.
- [ ] 6. (**sub-agent**) Run post-regression.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 7. (**sub-agent**) Verify SC-4 against its success criterion.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Verify: behavioral probe asserts no card content in any `task()` prompt; direct reading of every SKILL.md Invocation/Dispatch section finds no SKILL.md-path targets and confirms guard retention in all 51 cards — both conditions required.
- [ ] 8. (**inline**) Commit the SC-4 slice.
  - From the `.opencode` submodule working tree: `git add .opencode/skills/ && git commit -m "Item 4 (SC-4): eliminate whole-card forwarding across the deck; guards retained 51/51"`

## Phase Completion

- SC-4 verify verdict PASS recorded in the pipeline-verify evidence artifact.
- Guard count confirmed 51/51 at the phase boundary (state invariant).
- Commit present on the feature branch; working tree clean.
- Concern transition: Phase 5 adds the plan-side guard — the pre-flight-guard backstop class this phase completed for cards.

---

# Phase 5 — Plan Pre-Flight Guard (ORCHESTRATOR_ONLY_PLAN)

## Phase Metadata

- **Concern:** Add the plan pre-flight guard — a leaf sub-agent receiving a whole plan body rejects with `ORCHESTRATOR_ONLY_PLAN` and halts, analogous to the card guard; the guard definition is written into the canonical standards docs and stated in the sub-agent entry pattern.
- **Files:** `.opencode/reference/task-card-structure-standards.md`
- **SCs:** SC-5
- **Dependencies:** none
- **Entry condition:** working tree clean
- **Exit condition:** SC-5 verify verdict PASS recorded; commit landed on the feature branch

## Code Path Coverage

- `reference/task-card-structure-standards.md`: define the `ORCHESTRATOR_ONLY_PLAN` guard semantics — a leaf sub-agent receiving a whole plan body rejects with `BLOCKED` reason `ORCHESTRATOR_ONLY_PLAN` and halts.
- Sub-agent entry pattern (task-card directive text): states the guard semantics; trip condition is a plan document body in the dispatch prompt — step-scoped prompts and task cards are unaffected (spec §11 edge case).

## Cross-Cutting SCs

- SC-5 spans the plan layer (primary) and skill deck layer (secondary) — the plan guard is the analog of the card-side guard; both are defined in the standards docs and enforced by the same `task()`-string discipline.

## Interface Boundaries

- Guard-definition edge (dependency contract): the only NEW guard interface; the card-side guard interface is unchanged and verified 51/51.
- Trip condition: plan document body in the dispatch prompt — step-scoped prompts referencing the plan do not trip the guard.

## State Transitions

- From: zero occurrences of `ORCHESTRATOR_ONLY_PLAN` across skills, guidelines, reference, and prompts; plans are the only unguarded artifact class.
- To: `ORCHESTRATOR_ONLY_PLAN` defined in `task-card-structure-standards.md` and stated in the sub-agent entry pattern; a leaf sub-agent receiving a whole plan body rejects with `BLOCKED` and halts. Persistent guard-semantics state in the canonical standards docs.

**Cost frame:** Running the negative probe (whole plan to a sub-agent) costs minutes. Skipping means plans remain the only unguarded artifact class — the one path where forwarding produces silent malfunction instead of a `BLOCKED` contract.

## Step-by-step

- [ ] 1. (**inline**) Clean stale artifacts for this phase's pipeline steps.
  - `rm -f tmp/2433/artifacts/pipeline-pre-regression-* tmp/2433/artifacts/pipeline-pre-regression-verify-* tmp/2433/artifacts/pipeline-red-* tmp/2433/artifacts/pipeline-green-* tmp/2433/artifacts/pipeline-post-regression-* tmp/2433/artifacts/pipeline-verify-*`
- [ ] 2. (**sub-agent**) Run pre-regression.
  - Dispatch: `task(..., prompt: "execute phase-0 task from test-driven-development")`
- [ ] 3. (**sub-agent**) Verify pre-regression results.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 4. (**sub-agent**) RED — write the failing negative behavioral probe for SC-5.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Probe type: negative behavioral probe dispatched from the working session — dispatch a sub-agent with a whole plan body.
  - What fails: the sub-agent does not reject — no `BLOCKED` with reason `ORCHESTRATOR_ONLY_PLAN` is returned, because the guard does not exist yet.
- [ ] 5. (**sub-agent**) GREEN — implement the SC-5 change that makes the probe pass.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - What must be true: the `ORCHESTRATOR_ONLY_PLAN` guard semantics are defined in `task-card-structure-standards.md` and stated in the sub-agent entry pattern — a leaf sub-agent receiving a whole plan body rejects with `BLOCKED` reason `ORCHESTRATOR_ONLY_PLAN` and halts; the trip condition (plan document body in the dispatch prompt) is specified.
- [ ] 6. (**sub-agent**) Run post-regression.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 7. (**sub-agent**) Verify SC-5 against its success criterion.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Verify: the negative probe asserts `BLOCKED` with reason `ORCHESTRATOR_ONLY_PLAN`; direct reading of the standards doc confirms the guard definition and the entry-pattern statement.
- [ ] 8. (**inline**) Commit the SC-5 slice.
  - From the `.opencode` submodule working tree: `git add .opencode/reference/task-card-structure-standards.md && git commit -m "Item 5 (SC-5): add ORCHESTRATOR_ONLY_PLAN plan pre-flight guard to standards docs"`

## Phase Completion

- SC-5 verify verdict PASS recorded in the pipeline-verify evidence artifact.
- Negative-probe behavioral evidence preserved for audit cross-validation.
- Commit present on the feature branch; working tree clean.
- Concern transition: Phase 6 migrates the deck's TDT vocabulary — the largest state transition, whose closed set the new guard-era vocabulary shares.

---

# Phase 6 — TDT Closed-Set Vocabulary Migration (Deck-Wide)

## Phase Metadata

- **Concern:** Normalize TDT vocabulary to the closed set {`orchestrator`, `task-card`, `task-card blind`} across the deck; resolve the TDT-vs-Invocation contradictions in the audit, brainstorming, and spec-creation cards; rewrite the blanket "each step dispatched to a sub-agent unless marked inline" clause in every card carrying it (45 files measured).
- **Files:** `.opencode/skills/**/SKILL.md` (TDT sections — 45 blanket-clause carriers, 3 contradiction cards)
- **SCs:** SC-6
- **Dependencies:** Phases 3 and 4 (DAG edges 3→6, 4→6 — the migration lands on the already-corrected `executing-plans` card, and the dispatch-string fixes precede the vocabulary pass over the same deck surface; sequential bulk edits, no concurrent edit window)
- **Entry condition:** Phase 3 and Phase 4 commits landed; working tree clean
- **Exit condition:** SC-6 verify verdict PASS recorded; commit landed on the feature branch

## Code Path Coverage

- Deck TDT sweep: Dispatch column values migrate to the closed set across all SKILL.md files — `inline` retires to `orchestrator`; `sub-task`/`task()` maps to `task-card`; `blind sub-task` maps to `task-card blind`.
- Contradiction resolution: audit, brainstorming, and spec-creation cards — TDT rows marked `inline` re-aligned with their Invocation `task()` routing.
- Blanket-clause rewrite: the clause head "must be dispatched to a sub-agent via `task()`" with tail "unless explicitly marked as inline" (verbatim in 44 cards; wrapped-tail variant "explicitly marked as inline/orchestrator" in `executing-plans/SKILL.md`) rewritten in all 45 carrying cards.
- The closed-set values are fixed by spec R-6; the canonical reference table that anchors them is authored in Phase 8.

## Cross-Cutting SCs

- SC-6 spans the skill deck layer (primary) and directive layer (secondary) — the migrated values must exactly match the directive-layer canonical table (SC-8) and the retired "inline" pejorative in `022`/AGENTS.md (SC-2/SC-8).
- Overlapping-file edge case with SC-3: both edits land on `executing-plans/SKILL.md` without conflict — Phase 3 rewrote the routing architecture; this phase rewrites the Task Discipline clause on the already-corrected card (spec §11).

## Interface Boundaries

- Vocabulary-conformance edge over all 51 cards: all TDT Dispatch values in the closed set; TDT rows agree with their card's Invocation section; blanket clause rewritten in all 45 carrying cards; guards `ORCHESTRATOR_ONLY_SKILL_CARD` retained 51/51 (invariant shared with SC-4).

## State Transitions

- From: TDT Dispatch values use {`inline`, `sub-task`, `blind sub-task`, `task()`, "orchestrator routes to general (blind)"}; 3 contradictory cards; 45 blanket-clause cards.
- To: TDT Dispatch values in the closed set {`orchestrator`, `task-card`, `task-card blind`}; audit/brainstorming/spec-creation contradictions resolved; blanket clause rewritten in all 45 carrying cards. Largest state transition — deck-wide bulk edit across 51 files, overlapped with SC-3's file set per spec §11 ordering.

**Cost frame:** Reading the migrated TDTs and running the routing probe costs minutes. Skipping means three vocabularies persist and every new card flips a coin between them — each new card added under the old vocabulary extends the migration debt.

## Step-by-step

- [ ] 1. (**inline**) Clean stale artifacts for this phase's pipeline steps.
  - `rm -f tmp/2433/artifacts/pipeline-pre-regression-* tmp/2433/artifacts/pipeline-pre-regression-verify-* tmp/2433/artifacts/pipeline-red-* tmp/2433/artifacts/pipeline-green-* tmp/2433/artifacts/pipeline-post-regression-* tmp/2433/artifacts/pipeline-verify-*`
- [ ] 2. (**sub-agent**) Run pre-regression.
  - Dispatch: `task(..., prompt: "execute phase-0 task from test-driven-development")`
- [ ] 3. (**sub-agent**) Verify pre-regression results.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 4. (**sub-agent**) RED — write the failing probe for SC-6.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - What fails: direct reading of all TDTs finds retired values present and the 3 contradictory cards unresolved; the routing probe confirms dispatch routes contradict the closed set.
- [ ] 5. (**sub-agent**) GREEN — implement the SC-6 change that makes the probe pass.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - What must be true: every TDT Dispatch column value across the 51 cards is in {`orchestrator`, `task-card`, `task-card blind`}; the audit, brainstorming, and spec-creation TDT-vs-Invocation contradictions are resolved (the TDT row and the Invocation section agree); the blanket clause is rewritten in every card carrying it (45 files), retiring the word "inline" from the dispatch vocabulary.
  - Deck-wide bulk edit — one sequential pass over the 45 blanket-clause carriers plus the 3 contradiction cards; verify guard retention 51/51 after the pass.
- [ ] 6. (**sub-agent**) Run post-regression.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 7. (**sub-agent**) Verify SC-6 against its success criterion.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Verify: behavioral probe routes per closed-set rows; direct reading of every SKILL.md TDT and Invocation section confirms closed-set values and TDT-vs-Invocation agreement.
- [ ] 8. (**inline**) Commit the SC-6 slice.
  - From the `.opencode` submodule working tree: `git add .opencode/skills/ && git commit -m "Item 6 (SC-6): normalize TDT vocabulary to the closed set; resolve contradictions; rewrite blanket clause in 45 cards"`

## Phase Completion

- SC-6 verify verdict PASS recorded in the pipeline-verify evidence artifact.
- Guard count confirmed 51/51 after the deck-wide pass (state invariant).
- Commit present on the feature branch; working tree clean.
- Concern transition: Phase 7 extends the plan format with per-step dispatch modes — the vocabulary the plan layer shares with this phase's closed set.

---

# Phase 7 — Per-Step Plan Dispatch Mode

## Phase Metadata

- **Concern:** Add a per-step dispatch mode (`direct` or `task-card`, default `direct`) to the canonical plan format; the writing-plans producer templates emit it so every produced plan step carries an explicit mode.
- **Files:** `.opencode/skills/writing-plans/SKILL.md`, `.opencode/skills/writing-plans/reference/plan-artifact-format.md`, `.opencode/skills/writing-plans/tasks/create.md`
- **SCs:** SC-7
- **Dependencies:** none
- **Entry condition:** working tree clean
- **Exit condition:** SC-7 verify verdict PASS recorded; commit landed on the feature branch

## Code Path Coverage

- `reference/plan-artifact-format.md`: the plan-format dispatch-indicator section is extended with an explicit per-step dispatch mode field — `direct` (orchestrator executes the step in its own context, default) or `task-card` (the orchestrator dispatches the step's task card).
- Producer templates (`SKILL.md` plan-format guidance and `tasks/create.md` step-writing procedure): emit the mode so every step of a produced plan carries an explicit mode.

## Cross-Cutting SCs

- SC-7 spans the plan layer (primary) and skill deck layer (secondary) — the mode vocabulary joins the closed-set vocabulary single-sourced in Phase 8 (the canonical table's plan-step-mode row reflects the finalized plan format from this phase — DAG edge 7→8).

## Interface Boundaries

- Format-conformance edge from the canonical plan format to the producer template: the mode field defined in `plan-artifact-format.md` and emitted by `create.md`.
- Existing plans without explicit modes remain readable — the old vocabulary is not erroring for old plans (spec §11 edge case); only new plans must carry explicit closed-set modes.

## State Transitions

- From: the canonical plan format defines dispatch indicators but no explicit per-step dispatch-mode field; producer templates emit none.
- To: per-step dispatch mode (`direct` | `task-card`, default `direct`) defined in the canonical plan format; writing-plans producer templates emit it; every produced plan step carries an explicit mode. Persistent format-schema state for all future plans; no migration of existing plans.

**Cost frame:** Producing a plan with per-step modes and running the probe costs minutes. Skipping means the plan layer stays prose-ambiguous and Phase 3's behavioral fix degrades back to wholesale forwarding on the next hand-written plan.

## Step-by-step

- [ ] 1. (**inline**) Clean stale artifacts for this phase's pipeline steps.
  - `rm -f tmp/2433/artifacts/pipeline-pre-regression-* tmp/2433/artifacts/pipeline-pre-regression-verify-* tmp/2433/artifacts/pipeline-red-* tmp/2433/artifacts/pipeline-green-* tmp/2433/artifacts/pipeline-post-regression-* tmp/2433/artifacts/pipeline-verify-*`
- [ ] 2. (**sub-agent**) Run pre-regression.
  - Dispatch: `task(..., prompt: "execute phase-0 task from test-driven-development")`
- [ ] 3. (**sub-agent**) Verify pre-regression results.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 4. (**sub-agent**) RED — write the failing probe for SC-7.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - What fails: direct reading of a plan produced by the current writing-plans flow finds no explicit per-step dispatch modes; the behavioral probe cannot execute a produced plan per per-step modes because none are emitted.
- [ ] 5. (**sub-agent**) GREEN — implement the SC-7 change that makes the probe pass.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - What must be true: the canonical plan format defines the per-step dispatch mode field with values `direct` and `task-card`, default `direct`; the writing-plans producer templates emit the mode so every step of a produced plan carries an explicit mode.
- [ ] 6. (**sub-agent**) Run post-regression.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 7. (**sub-agent**) Verify SC-7 against its success criterion.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Verify: a plan produced by the updated writing-plans flow is executed per its per-step modes (behavioral probe dispatched from the working session); direct reading of the produced plan and the producer templates confirms explicit per-step modes on every step.
- [ ] 8. (**inline**) Commit the SC-7 slice.
  - From the `.opencode` submodule working tree: `git add .opencode/skills/writing-plans/SKILL.md .opencode/skills/writing-plans/reference/plan-artifact-format.md .opencode/skills/writing-plans/tasks/create.md && git commit -m "Item 7 (SC-7): add per-step dispatch mode (direct | task-card) to canonical plan format and producer templates"`

## Phase Completion

- SC-7 verify verdict PASS recorded in the pipeline-verify evidence artifact.
- Behavioral evidence preserved for audit cross-validation.
- Commit present on the feature branch; working tree clean.
- Concern transition: Phase 8 single-sources the vocabulary — the convergence state that keeps Phases 1–7 from re-fragmenting.

---

# Phase 8 — Canonical Dispatch-Vocabulary Single-Sourcing

## Phase Metadata

- **Concern:** Single-source the dispatch vocabulary — write the canonical table into the reference layer; convert directive-layer restatements to Read-links in the system prompt, `022`, `000-critical-rules`, both standards reference cards, and `.opencode/AGENTS.md`'s Universal Skill Dispatch Gate section; rewrite AGENTS.md's dispatch directives onto the canonical table (retired-vocabulary header prose rewritten); strip duplicated and contradictory definitions from the system prompt.
- **Files:** `.opencode/reference/skill-card-description-standards.md`, `.opencode/prompts/default.txt`, `.opencode/guidelines/022-orchestrator-context-discipline.md`, `.opencode/guidelines/000-critical-rules.md`, `.opencode/reference/task-card-structure-standards.md`, `.opencode/AGENTS.md` (Universal Skill Dispatch Gate section only)
- **SCs:** SC-8
- **Dependencies:** Phases 1, 2, 5, 7 (DAG edges 1→8, 2→8, 5→8, 7→8 — the Read-link conversions require the corrected Architecture-B prompt text, the re-pointed halt machinery, the guard definition, and the finalized plan-step mode in place)
- **Entry condition:** Phases 1, 2, 5, and 7 commits landed; working tree clean
- **Exit condition:** SC-8 verify verdict PASS recorded; commit landed on the feature branch; then the post-implementation gates complete

## Code Path Coverage

- Reference layer: the single canonical dispatch-vocabulary table is written into `skill-card-description-standards.md`.
- Read-link conversion: the system prompt, `022`, `000-critical-rules`, `task-card-structure-standards.md`, and `AGENTS.md` (Universal Skill Dispatch Gate section) reference the canonical table instead of restating definitions.
- System prompt dedup: `prompts/default.txt` carries no duplicated or contradictory dispatch definitions.
- The canonical table's rows reflect the finalized surfaces from Phases 1–7: Architecture B routing, forwarding-based halt triggers, the `ORCHESTRATOR_ONLY_PLAN` guard, the closed TDT set, and the `direct` | `task-card` plan-step mode.

## Cross-Cutting SCs

- SC-8 is the keystone spanning all three concerns (directive layer, skill deck layer, plan layer) — every layer references its canonical table, and it is executed last after Phases 1–7 establish the corrected surfaces it links to.

## Interface Boundaries

- Read-link reference edges converge on the canonical vocabulary table: the table must exist (this phase) for all Read-link edges to resolve (dependency contract).
- AGENTS.md dispatch directives use the canonical table via Read-link; non-dispatch AGENTS.md content is out of scope (spec §2).

## State Transitions

- From: dispatch vocabulary defined redundantly and contradictorily across the system prompt, `022`, `000-critical-rules`, the standards cards, and AGENTS.md; no canonical table.
- To: a single canonical dispatch-vocabulary table in the reference layer; every directive-layer file references it via Read-link; AGENTS.md dispatch directives use the canonical table; the system prompt carries no duplicates. The convergence state that prevents re-fragmentation of the Phase 1–7 outcomes.

**Cost frame:** Reading the canonical table and running both trigger probes costs minutes. Skipping means the vocabulary re-fragments at the next session that edits a directive file — the dedup is the only item that keeps the other seven from regressing.

## Step-by-step

- [ ] 1. (**inline**) Clean stale artifacts for this phase's pipeline steps.
  - `rm -f tmp/2433/artifacts/pipeline-pre-regression-* tmp/2433/artifacts/pipeline-pre-regression-verify-* tmp/2433/artifacts/pipeline-red-* tmp/2433/artifacts/pipeline-green-* tmp/2433/artifacts/pipeline-post-regression-* tmp/2433/artifacts/pipeline-verify-*`
- [ ] 2. (**sub-agent**) Run pre-regression.
  - Dispatch: `task(..., prompt: "execute phase-0 task from test-driven-development")`
- [ ] 3. (**sub-agent**) Verify pre-regression results.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 4. (**sub-agent**) RED — write the failing probe for SC-8.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - What fails: direct reading of the directive-layer files finds duplicate/contradictory dispatch definitions and no canonical table; the skill-trigger and plan-trigger probes route inconsistently.
- [ ] 5. (**sub-agent**) GREEN — implement the SC-8 change that makes the probes pass.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - What must be true: the canonical dispatch-vocabulary table exists in `skill-card-description-standards.md`; every directive-layer file references it via Read-link instead of restating definitions; `.opencode/AGENTS.md`'s dispatch directives (Universal Skill Dispatch Gate section) use the canonical table with the retired-vocabulary header prose rewritten; the system prompt carries no duplicated or contradictory dispatch definitions.
- [ ] 6. (**sub-agent**) Run post-regression.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 7. (**sub-agent**) Verify SC-8 against its success criterion.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Verify: behavioral probes (skill trigger and plan trigger) both route per the canonical table; direct reading of the directive files (including `.opencode/AGENTS.md`) confirms Read-link presence and absent duplicate definitions.
- [ ] 8. (**inline**) Commit the SC-8 slice.
  - From the `.opencode` submodule working tree: `git add .opencode/reference/skill-card-description-standards.md .opencode/reference/task-card-structure-standards.md .opencode/prompts/default.txt .opencode/guidelines/022-orchestrator-context-discipline.md .opencode/guidelines/000-critical-rules.md .opencode/AGENTS.md && git commit -m "Item 8 (SC-8): single-source dispatch vocabulary in canonical reference table; Read-link directive layer"`

## Post-Implementation (Tier 1 — once per plan, at the end of the last phase)

- [ ] 1. (**sub-agent**) Run the adversarial audit.
  - Dispatch: `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")` — followed by the validator, evaluator, and arbiter in sequence.
  - Purpose: adversarial audit of the deliverable against the spec; record verdicts.
- [ ] 2. (**inline**) Run the Z3 constraint-solver verification.
  - Command: `.opencode/tools/solve check --state-path tmp/2433/artifacts/state-z3-post.yaml --contract-path .opencode/.issues/2433/dependency-contract.yaml`
  - Purpose: verify the post-implementation phase state against the dependency contract; record the solver output as the pipeline z3-check artifact. Interpret goal-state UNSAT against initial-state preconditions per the precedent documented in the solve-output artifact (reachability was proven by the model query).
- [ ] 3. (**sub-agent**) Run the finishing checklist.
  - Dispatch: `task(..., prompt: "execute checklist task from finishing-a-development-branch")`
  - Purpose: structural checks — markdown lint/format gates on edited guideline and reference files, submodule state, branch readiness.
- [ ] 4. (**sub-agent**) Run the pre-PR gate.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Purpose: read all SC verdicts; BLOCK if any SC is FAIL (DONE_WITH_CONCERNS coerces to FAIL; EVIDENCE_TYPE_MISMATCH is a hard FAIL).
- [ ] 5. (**sub-agent**) Run the final regression check.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Purpose: final regression check before PR.
- [ ] 6. (**sub-agent**) Prepare the PR review context.
  - Dispatch: `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`
- [ ] 7. (**sub-agent**) Create the pull request.
  - Dispatch: `task(..., prompt: "execute create task from git-workflow-pr")`
  - Target: `michael-conrad/.opencode` from `feature/2402-finishing-checklist-trailer-remediation`; stacked strategy — one branch, one squashed commit per issue, one PR. Human-only merge — the agent never merges.
- [ ] 8. (**sub-agent**) Generate the completion executive summary.
  - Dispatch: `task(..., prompt: "execute completion task from completion-core")`

---

## Exit Criteria (recheck before halt)

All exit criteria C1–C9 listed in the plan index must hold before the pipeline declares completion. The enforcement gate is all-or-nothing: any SC FAIL blocks completion, remediation-first protocol applies, and escalation follows only after exhaustive remediation.

---

## Lifecycle Events

```yaml
lifecycle_events:
  - timestamp: "2026-09-04T02:07:26Z"
    event: plan_created
    plan_file: ".opencode/.issues/2433/plan.md"
    phase_count: 8
```