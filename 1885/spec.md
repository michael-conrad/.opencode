# [SPEC-FIX] Close artifact gate bypass escape hatch in writing-plans skill

**STATUS: DRAFT**
**CREATED: 2026-07-11**

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem Statement

The writing-plans skill has an artifact gate that requires all 7 analytical artifacts from spec-creation to be present before plan creation. However, this gate fires at Step 4a of the 21-step create pipeline (inside the `readiness` task), not at the entry point. The `pre-plan-readiness` task — which is the entry-point gate — checks only:

1. Spec file exists at `.issues/{N}/spec.md`
2. Feature branch exists
3. `local-issues sync` has been run

It does NOT check for analytical artifacts. This creates an escape hatch:

1. An agent creates a spec directly as a GitHub Issue (bypassing the spec-creation pipeline)
2. The spec has no analytical artifacts (no blast-radius, concern-map, code-path-inventory, cross-cutting-matrix, interface-compatibility, state-analysis, testability-assessment)
3. The agent invokes `writing-plans` to create a plan
4. `pre-plan-readiness` passes because it only checks spec file + branch + sync
5. The agent enters the 21-step pipeline
6. At Step 4a (readiness), the artifact gate fires — but the agent is already inside the pipeline
7. The agent can rationalize: "I'll create the analytical artifacts from the spec body" or "the spec is detailed enough, I'll bypass the artifact gate"

The escape hatch exists because the artifact check is not at the entry point. The `pre-plan-readiness` task and the Trigger Dispatch Table entry for "create plan" do not validate analytical artifacts before allowing pipeline entry.

## Root Cause Analysis

The root cause is a gate placement defect: the artifact validation gate is positioned inside the pipeline (Step 4a) rather than at the entry point (Trigger Dispatch Table + pre-plan-readiness). This is a structural defect, not a content defect — the gate exists but fires too late.

**Why the gate fires too late:**
1. The Trigger Dispatch Table entry for "create plan" dispatches directly to `create` without any artifact pre-check
2. The `pre-plan-readiness` task is a separate dispatch path that is not chained to the "create plan" entry
3. The artifact check in Mandatory Task Discipline item 8 is advisory ("required before plan creation") but not enforced as a hard gate at the entry point
4. The `spec-to-plan` handoff manifest validates SC summary YAML but does not validate analytical artifact presence

**Why this matters:**
- Plans created without analytical artifacts are analytically shallow — they lack blast radius awareness, concern boundary analysis, code path inventory, cross-cutting impact analysis, interface compatibility verification, state transition analysis, and testability assessment
- The spec-creation pipeline produces these artifacts as mandatory outputs; bypassing them means the plan is built on incomplete analysis
- The escape hatch is exploitable: an agent can create a spec directly as a GitHub Issue, then invoke writing-plans, and the artifact gate won't fire until Step 4a — at which point the agent has already invested context in the pipeline and is incentivized to fabricate artifacts rather than restart

## Scope

**In scope:**
- Add analytical artifact pre-check to the writing-plans Trigger Dispatch Table entry for "create plan"
- Add analytical artifact check to the `pre-plan-readiness` task
- Add analytical artifact requirement to writing-plans SKILL.md Entry Criteria
- Elevate Mandatory Task Discipline item 8 from advisory to hard gate (BLOCKED on missing artifacts)
- Add analytical artifact validation to the `spec-to-plan` handoff manifest
- Add a critical-rules entry prohibiting bypassing the artifact gate
- Add a behavioral enforcement test verifying the agent does not bypass the artifact gate

**Out of scope:**
- Changes to the spec-creation pipeline itself
- Changes to the 21-step writing-plans pipeline structure
- Adding analytical artifacts to existing specs (retroactive)
- Changes to the `readiness` task (Step 4a) — the artifact check there is correct; this fix adds the check at the entry point

## Approach

Seven changes to five files, plus one new critical-rules entry and one behavioral enforcement test:

### Change 1: Trigger Dispatch Table — Add artifact pre-check

Modify the "create plan" entry in the writing-plans Trigger Dispatch Table to include an artifact validation step before dispatch. The entry currently dispatches directly to `create`; it must first verify analytical artifacts exist.

### Change 2: pre-plan-readiness task — Add artifact check

Add a new check to the `pre-plan-readiness` task that verifies all 7 analytical artifacts exist in `.issues/{N}/` before allowing plan creation. Missing artifacts produce `BLOCKED` with `MISSING_SPEC_ARTIFACT`.

### Change 3: SKILL.md Entry Criteria — Add artifact requirement

Add analytical artifact presence to the Entry Criteria section of the writing-plans SKILL.md. The entry criteria currently list only spec approval and authorization scope; they must also list analytical artifact presence.

### Change 4: Elevate Mandatory Task Discipline item 8 to hard gate

Item 8 currently says "Analytical artifact validation required before plan creation." This is advisory language. It must be elevated to a hard gate: "Missing artifacts produce BLOCKED with `MISSING_SPEC_ARTIFACT`. The pipeline MUST NOT proceed past the entry point without all 7 artifacts."

### Change 5: spec-to-plan handoff — Add artifact validation

Add a check to the `spec-to-plan` handoff manifest that validates the presence of all 7 analytical artifacts. The manifest currently validates SC summary YAML, risk traceability, decision ledger, and decomposition consistency — but not analytical artifact presence.

### Change 6: Critical-rules entry

Add a critical-rules entry to `000-critical-rules.md` prohibiting bypassing the artifact gate. The entry must classify the violation as Tier 2 (Process-Integrity) and reference the behavioral enforcement test.

### Change 7: Behavioral enforcement test

Add a behavioral enforcement test in `.opencode/tests/behaviors/` that verifies the agent does NOT proceed with plan creation when analytical artifacts are missing. The test sends a prompt to create a plan for a spec without artifacts and asserts the agent returns BLOCKED.

## Affected Files

| File | Change |
|------|--------|
| `.opencode/skills/writing-plans/SKILL.md` | Trigger Dispatch Table: add artifact pre-check; Entry Criteria: add artifact requirement; Mandatory Task Discipline item 8: elevate to hard gate |
| `.opencode/skills/writing-plans/tasks/pre-plan-readiness.md` | Add artifact check procedure step |
| `.opencode/skills/writing-plans/tasks/handoffs/spec-to-plan.md` | Add artifact validation check |
| `.opencode/guidelines/000-critical-rules.md` | Add critical-rules entry prohibiting artifact gate bypass |
| `.opencode/tests/behaviors/` | New behavioral enforcement test |

## Success Criteria

**🚫 ALL-OR-NOTHING GATE: ALL success criteria MUST pass for implementation to be considered complete.**

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|---------------|---------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | Trigger Dispatch Table "create plan" entry includes artifact pre-check before dispatch | `string` | `grep` for artifact validation in the "create plan" row of the Trigger Dispatch Table in SKILL.md | Add artifact pre-check language to the Trigger Dispatch Table entry | `green-vbc` | `./tmp/1885/artifacts/sc1-grep.log` | MUST validate artifacts at entry point, not inside pipeline | `Phase 1` | `pre-commit` | `standalone` | `skill-card` | `structure` | `test_sc1_trigger_artifact_check.sh` | `Phase 1` |
| SC-2 | `pre-plan-readiness` task checks for all 7 analytical artifacts | `string` | `grep` for each artifact name (blast-radius, concern-map, code-path-inventory, cross-cutting-matrix, interface-compatibility, state-analysis, testability-assessment) in `pre-plan-readiness.md` | Add artifact check procedure step to pre-plan-readiness task | `green-vbc` | `./tmp/1885/artifacts/sc2-grep.log` | MUST verify all 7 artifacts at entry point before pipeline entry | `Phase 1` | `pre-commit` | `standalone` | `task-files` | `structure` | `test_sc2_readiness_artifact_check.sh` | `Phase 1` |
| SC-3 | SKILL.md Entry Criteria list analytical artifact presence as a prerequisite | `string` | `grep` for "analytical artifact" in the Entry Criteria section of SKILL.md | Add artifact requirement to Entry Criteria | `green-vbc` | `./tmp/1885/artifacts/sc3-grep.log` | MUST declare artifact requirement at skill entry, not buried in pipeline | `Phase 1` | `pre-commit` | `standalone` | `skill-card` | `structure` | `test_sc3_entry_criteria_artifacts.sh` | `Phase 1` |
| SC-4 | Mandatory Task Discipline item 8 is elevated to hard gate with BLOCKED on missing artifacts | `string` | `grep` for "BLOCKED" and "MISSING_SPEC_ARTIFACT" in Mandatory Task Discipline item 8 of SKILL.md | Rewrite item 8 to use hard-gate language with BLOCKED status and MISSING_SPEC_ARTIFACT reason | `green-vbc` | `./tmp/1885/artifacts/sc4-grep.log` | MUST enforce artifact requirement as hard gate, not advisory | `Phase 1` | `pre-commit` | `standalone` | `skill-card` | `structure` | `test_sc4_hard_gate_item8.sh` | `Phase 1` |
| SC-5 | `spec-to-plan` handoff manifest validates analytical artifact presence | `string` | `grep` for artifact names in `spec-to-plan.md` handoff manifest checks | Add artifact validation check to spec-to-plan handoff procedure | `green-vbc` | `./tmp/1885/artifacts/sc5-grep.log` | MUST validate artifacts in handoff manifest for cross-gate consistency | `Phase 1` | `pre-commit` | `standalone` | `handoffs` | `structure` | `test_sc5_handoff_artifact_check.sh` | `Phase 1` |
| SC-6 | Critical-rules entry prohibits bypassing the artifact gate | `string` | `grep` for "artifact gate" or "analytical artifact" in `000-critical-rules.md` | Add critical-rules entry with Tier 2 classification | `green-vbc` | `./tmp/1885/artifacts/sc6-grep.log` | MUST codify prohibition in critical rules for enforcement traceability | `Phase 1` | `pre-commit` | `standalone` | `guidelines` | `structure` | `test_sc6_critical_rules_entry.sh` | `Phase 1` |
| SC-7 | Behavioral enforcement test verifies agent does NOT bypass artifact gate | `behavioral` | `opencode-cli run` → agent attempts plan creation for spec without artifacts → stderr shows BLOCKED or HALT, no plan created | If agent proceeds past artifact gate: fix entry-point checks; re-run behavioral test | `red-green` | `./tmp/1885/artifacts/behavioral/sc7-session.yaml` | MUST verify agent behavior, not just rule text; behavioral evidence is PRIMARY per `080-code-standards.md` | `Phase 2` | `red-green` | `standalone` | `behavioral` | `structure` | `test_sc7_behavioral_artifact_gate.sh` | `Phase 2` |
| SC-8 | Before any implementation, behavioral enforcement test exists and is confirmed RED (fails before change) | `behavioral` | `opencode-cli run` → behavioral test sends prompt → agent currently proceeds past artifact gate → test asserts BLOCKED → test FAILS (RED) because agent doesn't block yet | Write behavioral test first (RED), then implement change (GREEN) per `091-incremental-build.md` Per-Item TDD Cycle | `red-green` | `./tmp/1885/artifacts/behavioral/sc8-session.yaml` | MUST enforce behavioral TDD for rule-changing specs; behavioral test is PRIMARY enforcement gate per `080-code-standards.md` | `Phase 2` | `red-green` | `standalone` | `behavioral` | `structure` | `test_sc8_behavioral_tdd.sh` | `Phase 2` |
| SC-9 | Coherence gate verifies spec-to-codebase alignment before any file changes | `structural` | `ls` for coherence gate artifacts in `.issues/{N}/`; sub-agent reads spec and affected files to verify alignment | Re-run coherence gate if artifacts missing or alignment mismatch found | `green-vbc` | `./tmp/1885/artifacts/sc9-ls.log` | MUST verify spec-to-codebase alignment before implementation begins | `Phase 0` | `pre-commit` | `standalone` | `pipeline-gate` | `structure` | `test_sc9_coherence_gate.sh` | `Phase 0` |
| SC-10 | Pre-flight checks confirm all prerequisites (branch, artifacts, authorization) before Phase 1 | `structural` | `ls` for prerequisite artifacts; `git branch --show-current` for feature branch; verify authorization scope | Re-run pre-flight if prerequisites missing | `green-vbc` | `./tmp/1885/artifacts/sc10-ls.log` | MUST confirm all prerequisites before per-file implementation begins | `Phase 0` | `pre-commit` | `standalone` | `pipeline-gate` | `structure` | `test_sc10_preflight.sh` | `Phase 0` |
| SC-11 | Spec audit passes all checks after all per-file implementation | `semantic` | Sub-agent reads revised spec and produces PASS/FAIL per audit dimension | Re-run audit if FAIL; remediate findings | `green-vbc` | `./tmp/1885/artifacts/sc11-audit.log` | MUST verify spec quality after all implementation changes | `Phase 3` | `pre-PR` | `standalone` | `pipeline-gate` | `structure` | `test_sc11_audit.sh` | `Phase 3` |
| SC-12 | Cross-validate confirms all SCs verified with correct evidence types | `semantic` | Sub-agent cross-validates VbC evidence against SC evidence type requirements | Re-run cross-validate if EVIDENCE_TYPE_MISMATCH found | `green-vbc` | `./tmp/1885/artifacts/sc12-crossvalidate.log` | MUST verify no EVIDENCE_TYPE_MISMATCH in any SC verification | `Phase 3` | `pre-PR` | `standalone` | `pipeline-gate` | `structure` | `test_sc12_crossvalidate.sh` | `Phase 3` |
| SC-13 | Review confirms all deliverables match spec requirements | `semantic` | Sub-agent reviews all deliverables against spec SCs | Re-run review if deliverables incomplete | `green-vbc` | `./tmp/1885/artifacts/sc13-review.log` | MUST verify deliverable completeness before PR creation | `Phase 3` | `pre-PR` | `standalone` | `pipeline-gate` | `structure` | `test_sc13_review.sh` | `Phase 3` |

### Cross-Cutting SCs: SC-1, SC-2, SC-3, SC-4, SC-5, SC-6
— Verified once in Phase 1, applies to all subsequent phases.

### Pre-Phase SCs: SC-9, SC-10
— Verified in Phase 0 before any per-file implementation begins.

### Post-Phase SCs: SC-11, SC-12, SC-13
— Verified in Phase 3 after all per-file implementation completes.

### Semantic Intent

| SC | Why the exact criterion value matters |
|----|--------------------------------------|
| SC-1 | The Trigger Dispatch Table is the entry point for all plan creation. If the artifact check is not here, the agent enters the pipeline without validation — and once inside, the sunk-cost bias incentivizes fabrication over restart. |
| SC-2 | The `pre-plan-readiness` task is the explicit entry-point gate. Without artifact checks here, the gate is a formality — it passes for any spec with a file and a branch, regardless of analytical depth. |
| SC-3 | Entry Criteria are what the orchestrator reads before dispatching. If artifacts aren't listed here, the orchestrator has no signal that they're required — and dispatches blind. |
| SC-4 | Advisory language ("required before plan creation") is not enforcement. The agent treats advisory as optional. Hard-gate language ("BLOCKED with MISSING_SPEC_ARTIFACT") is enforcement — the agent cannot proceed. |
| SC-5 | The handoff manifest is consumed by downstream pipeline stages. If it doesn't validate artifacts, downstream consumers assume artifacts exist when they don't — propagating the defect. |
| SC-6 | Critical rules are the enforcement layer. Without a critical-rules entry, the prohibition exists only in skill files — and skill files are not loaded by default. A critical-rules entry ensures the prohibition is visible at the guideline level. |
| SC-7 | Behavioral evidence is PRIMARY per `080-code-standards.md`. String evidence (grep) confirms the rule text exists; behavioral evidence confirms the agent follows it. Bug #1217 proved that content-verification alone is insufficient. |
| SC-8 | Behavioral TDD for rule changes is the PRIMARY enforcement gate. A guideline change without a behavioral test is a suggestion, not a rule. The test must be RED first (proving the gap exists), then GREEN (proving the change closed it). |
| SC-9 | The coherence gate is the first pipeline stage. Without it, the implementation proceeds without verifying that the spec aligns with the actual codebase — producing work that may not fit the code. |
| SC-10 | Pre-flight checks are the last gate before implementation begins. Without them, the pipeline may start with missing prerequisites — producing work that fails mid-implementation. |
| SC-11 | Spec audit is the quality gate after implementation. Without it, defects in the spec itself go undetected — and the PR ships with spec-level errors. |
| SC-12 | Cross-validate is the evidence-type integrity gate. Without it, EVIDENCE_TYPE_MISMATCH defects (structural evidence for behavioral SCs) go undetected — producing false PASS verdicts. |
| SC-13 | Review is the final deliverable completeness gate. Without it, incomplete deliverables may be shipped — producing a PR that doesn't satisfy all SCs. |

## Determinism Gate

For each SC, the question "If two different auditors read this SC, will they independently produce the same PASS/FAIL result against the same implementation?" MUST answer "yes."

| SC | Deterministic? | Rationale |
|----|---------------|-----------|
| SC-1 through SC-6 | ✅ Yes | `grep` patterns produce identical results on identical file content |
| SC-7 | ✅ Yes | Behavioral test with `assert_semantic` — clean-room AI inspector evaluates full agent output; different inspector models may produce different judgments but the assertion helper normalizes PASS/FAIL |
| SC-8 | ✅ Yes | Behavioral test with stderr-based assertion helpers — grep on stderr for BLOCKED/HALT patterns is deterministic |
| SC-9, SC-10 | ✅ Yes | Structural checks (`ls`, `git branch --show-current`) produce identical results on identical filesystem state |
| SC-11, SC-12, SC-13 | ✅ Yes | Semantic sub-agent evaluation with structured PASS/FAIL criteria — different sub-agent models may produce different judgments but the structured criteria normalize the outcome |

## Risk Traceability

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|-------------|
| RISK-1 | Agent finds new bypass path (e.g., creates artifacts inline to satisfy gate) | Low | High | Behavioral test verifies agent does NOT fabricate artifacts; critical-rules entry covers fabrication as a violation | SC-7 |
| RISK-2 | Existing specs without artifacts become unplannable | Medium | Medium | Gate only applies to new plan creation; existing plans are unaffected; retroactive plans use existing spec body | SC-2 |
| RISK-3 | Artifact check adds latency to plan creation for valid specs | Low | Low | Artifact check is a file-existence check (structural, ~1s); negligible compared to 21-step pipeline cost | SC-2 |

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|-------------|
| DEC-1 | Artifact check at entry point, not inside pipeline | The escape hatch exists because the gate fires too late. Moving it to the entry point closes the hatch — the agent cannot enter the pipeline without artifacts. | MUST | SC-1, SC-2, SC-3 |
| DEC-2 | All 7 analytical artifacts required | Partial artifacts produce analytically shallow plans. The spec-creation pipeline produces all 7 as mandatory outputs; requiring all 7 ensures plan quality parity. | MUST | SC-2, SC-5 |
| DEC-3 | Hard gate (BLOCKED), not advisory | Advisory language is not enforcement. The agent treats "required" as "preferred." BLOCKED is a hard stop — the agent cannot proceed. | MUST | SC-4 |
| DEC-4 | Behavioral enforcement test required | The fix changes agent dispatch/routing behavior (the agent must BLOCKED instead of proceeding). String evidence confirms rule text; behavioral evidence confirms agent behavior. | MUST | SC-7, SC-8 |
| DEC-5 | Critical-rules entry at Tier 2 (Process-Integrity) | The violation produces quality defects (analytically shallow plans), not irreversible harm. Tier 2 is the correct classification per the three-tier model. | MUST | SC-6 |

## Decomposition Classification

| Classification | Number of Phases | Sub-Issue Requirements | PR Strategy |
|----------------|------------------|------------------------|-------------|
| multi-phase | 4 | One sub-issue per phase | stacked PRs per phase |

**Phase breakdown:**
- **Phase 0:** Global pre-phase — coherence gate, pre-flight checks (SC-9, SC-10)
- **Phase 1:** File changes (SC-1 through SC-6) — Trigger Dispatch Table, pre-plan-readiness, Entry Criteria, Mandatory Task Discipline item 8, handoff manifest, critical-rules entry
- **Phase 2:** Behavioral enforcement test (SC-7, SC-8) — RED/GREEN TDD cycle
- **Phase 3:** Global post-phase — audit, cross-validate, review (SC-11, SC-12, SC-13)

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan (`.opencode/.issues/1885/plan.md`) | MUST | Revise to match revised spec |
| Behavioral tests (`.opencode/tests/behaviors/`) | MUST | Review for continued validity; update assertions if SCs changed |
| Critical-rules entry (`000-critical-rules.md`) | SHOULD | Review if violation classification changes |

## Regression Invariants

- [ ] 1. Existing plan creation for specs WITH analytical artifacts MUST continue to work unchanged.
- [ ] 2. The 21-step writing-plans pipeline structure MUST NOT be altered.
- [ ] 3. The `readiness` task (Step 4a) artifact check MUST remain in place as a secondary validation gate.
- [ ] 4. The `writing-plans` skill MUST remain invocable via `skill({name: "writing-plans"})` with the same Trigger Dispatch Table user-facing phrases.
- [ ] 5. Existing `pre-plan-readiness` checks (spec file, feature branch, local-issues sync) MUST continue to function.

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `.opencode/skills/writing-plans/SKILL.md` | Identify Trigger Dispatch Table, Entry Criteria, Mandatory Task Discipline item 8, artifact gate placement |
| Direct source search | `.opencode/skills/writing-plans/tasks/pre-plan-readiness.md` | Verify current checks (spec file, branch, sync) and absence of artifact check |
| Direct source search | `.opencode/skills/writing-plans/tasks/handoffs/spec-to-plan.md` | Verify handoff manifest checks and absence of artifact validation |
| Direct source search | `.opencode/skills/writing-plans/tasks/readiness.md` | Verify Step 4a artifact gate placement inside pipeline |
| Direct source search | `.opencode/skills/writing-plans/tasks/create.md` | Verify 21-step pipeline structure and artifact gate position |
| Direct source search | `.opencode/guidelines/000-critical-rules.md` | Verify no existing critical-rules entry for artifact gate bypass |
| Direct source search | `.opencode/guidelines/080-code-standards.md` | Verify behavioral test mandate and evidence type taxonomy |

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. See `080-code-standards.md` Test Integrity Mandate.

## Interdependency

| Issue | Classification | Description |
|-------|---------------|-------------|
| [#1320](https://github.com/michael-conrad/.opencode/issues/1320) | RELATED | Decomposed writing-plans into 21-step pipeline — this spec fixes a gate placement defect in that pipeline |
| [#1703](https://github.com/michael-conrad/.opencode/issues/1703) | RELATED | Enforced writing-plans pipeline discipline — complementary enforcement fix |

After this spec is approved, invoke `writing-plans` to create `.opencode/.issues/1885/plan.md` before implementation begins.
