# [PLAN] Reference Card Architecture + Spec Output Structure — Updated Coordination

## Intent

Implement 8 issues across 6 layers in 5 sequential phases. Each phase produces a self-contained PR that depends structurally on the previous phase. The plan defines phase boundaries, sub-issue linkage, SC pass-through, and handoff contracts between spec-upstream and plan-downstream artifacts.

## Executive Summary

| Layer | Issue(s) | Deliverable | Depends On | Phase |
|-------|----------|-------------|------------|-------|
| 0 — Reference Cards | #848, #853 | 255-distribution-shifting card, 257-procedural-discipline card | None | 1 |
| 1 — Policy | #849 | Co-application policy in 080-code-standards + 250/255/257 §4 rules + pipeline re-priming rule | #848, #853 | 1 |
| 2 — Enforcement Style + Structure | #850 (narrowed), #1060 | Pre-pipeline gate + spec-auditor scan; SC column expansion, preamble sections, self-review | #849 | 2 |
| 3 — Artifact Infrastructure | #1061 | SC coverage YAML, solve/plan contracts, lifecycle manifest, retention policy | #1060 | 3 |
| 4 — Boundary Gates | #1062 | Spec-to-plan, plan-to-pipeline, SC close-out, revision re-entry | #1061 | 4 |
| 5 — Pipeline + Plan Enforcement | #1063, #1064 | Pipeline enforcement steps; writing-plans structured consumption + cross-ref validation | #1062 | 5 |

## Dependency Graph

```
#848 ──→ #849 ──→ #850 ──→ #1060 ──→ #1061 ──→ #1062 ──→ #1063
#853 ──→ #849                              │                  │
                                            │                  │
                                            └──→ #1064 (peers with #1063)
```

**Edge semantics**: Solid arrow = `depends_on`. #1063 and #1064 are peers under Layer 5 — both depend on #1062 but are independent of each other.

## Phases and Sub-Issues

### Phase 1: Foundation (Issues #848, #853, #849)

PR branch: `phase/854/1-foundation`
SC count: 28 + 16 + 13 = 57

**#848 (SC-1 through SC-12)**: Create 255-distribution-shifting-reference.md
- SC-1 through SC-12: card file existence, all 8 patterns, selection matrix, co-application rules, re-research mandate, sections 5-10, verified research claims, pattern formulas dist-shift-007, dist-shift-008, dist-shift-003 positional strategy, dist-shift-004 anti-sycophancy

**#853 (SC-1 through SC-16)**: Create 257-procedural-discipline-reference.md
- SC-1 through SC-16: card file with 6 patterns, formulas p-dis-001 through p-dis-006, dependency-order gate protocol, re-priming protocol + positional strategy, controlled vocabulary with external-verification + over-enforcement rows, re-research mandate, co-application rules for 250/255, sections 9-13, selection matrix, 250 §9 dependency-order bright-line companion, 000-critical-rules pipeline re-priming rule, INDEX.md entry

**#849 (SC-1 through SC-13)**: Mandatory co-application policy
- SC-1 through SC-13: 250 §9 references 255/257, 255 §4 co-application rules for 250/257, 257 §4 co-application rules for 250/255, INDEX.md entries for 255/257, 080-code-standards co-application section + auto-detection trigger, 000-critical-rules pipeline re-priming rule, AGENTS.md discipline anchor, 250 §9 bright-line companion rows (dependency-order, dist-shift-007, dist-shift-008, p-dis-006, over-enforcement)

Handoff: SC summary YAML persists to Phase 2 ISAs pass-through.

### Phase 2: Structure (Issue #1060)

PR branch: `phase/854/2-structure`
Depends on: Phase 1 merged
SC count: 12

**#1060 (SC-1 through SC-12)**: Expand spec-creation `write.md`

Eight new SC table columns (SC-1 through SC-8):
- Pipeline Step Binding, Artifact Path, Requirement Traceability (mandatory all tiers), Phase Binding (multi-phase only), Verification Gate (3 tiers), Integration Mode (required when Gate=ci), Affinity Group (optional), Re-Entry Step (all tiers)

Four new preamble sections (SC-9 through SC-12):
- Decision Ledger (DEC-IDs with RFC 2119 keys), Risk Traceability Table (RISK-IDs with Verifying SC binding), Revision Policy (artifact cascade declarations), Decomposition Classification (single-task/multi-phase)

Handoff: Expanded SC table schema is input to Phase 3 artifact layer. Consumed by #1061 `sc-summary.yaml` schema and #1064 cross-reference validation.

### Phase 3: Artifacts (Issue #1061)

PR branch: `phase/854/3-artifacts`
Depends on: Phase 2 merged
SC count: 10

**#1061 (SC-1 through SC-10)**: Structured artifact layer
- SC coverage summary YAML at `spec-artifacts/sc-summary.yaml`
- Pre-approval gate solve contract expanded for new columns
- Dependency-ordering solve contracts (Z3 inequality constraints per phase)
- Verification consistency solve contract (Evidence Type × Verification Gate compliance)
- Lifecycle manifest at `spec-artifacts/lifecycle.yaml` (append-only)
- Blocker documentation appended to lifecycle manifest
- Revision re-entry protocol at `spec-artifacts/revision-re-entry-contract.yaml`
- Solve/plan utility invocations in spec-creation (solve for constraints ledger, plan for decomposition, solve for pre-approval gate)
- Solve/plan utility invocations in writing-plans (solve for phase dependency ordering, solve for exit criteria, plan for phase structure)
- Retention policy: `./tmp/{issue-N}/` → PR merge cleanup; `spec-artifacts/` permanent

Handoff: All artifact paths and YAML schemas passed to Phase 4 boundary gates as read contracts.

### Phase 4: Boundaries (Issue #1062)

PR branch: `phase/854/4-boundaries`
Depends on: Phase 3 merged
SC count: 7

**#1062 (SC-1 through SC-7)**: Handoff gates
- Spec-to-Plan Handoff: plan author verifies all spec artifacts before plan creation. Entry criteria: artifact enumeration, SC summary integrity, solve contract results, decomposition consistency, risk/decision cross-refs.
- Plan-to-Pipeline Handoff: pipeline verifies plan structurally complete before RED-phase. Pre-flight: phase/TDD task coverage, RED checkpoints, SC-ID traceability, approval cascade match, gate preservation.
- Handoff Consistency Check: compares spec-to-plan vs plan-to-pipeline manifests for shared variables (SC count, phase count, decomposition). BLOCKs on mismatch.
- SC Close-Out Verification: exec-summary step confirms every SC-ID received at least one PASS. UNVERIFIED SCs block closure.
- Spec Revision Re-Entry Protocol: solve contract defining which handoffs/pipeline steps must re-run per revision scope.

Handoff: Handoff gate contracts consumed by Phase 5 pipeline enforcement as entry/exit criteria for pipeline steps.

### Phase 5: Enforcement + Plan Awareness (Issues #1063, #1064)

PR branch: `phase/854/5-enforcement`
Depends on: Phase 4 merged
SC count: 6 + 7 = 13

**#1063 (SC-1 through SC-6)**: Pipeline enforcement gates
- SC-1: Evidence-Type Uplift Scan as sc-coherence-gate step (validates SC evidence type vs substrate classification)
- SC-2: Doc-Source-Currency Check as pre-red-baseline step (re-verifies spec file paths, signatures, config)
- SC-3: SC-ID Traceability as pre-red-baseline step (all spec SC-IDs have plan references)
- SC-4: Semantic-Intent Verification as green-doublecheck step (PASS satisfies semantic intent)
- SC-5: RED/GREEN Anti-Merge enforcement (git diff --name-only -- src/ FAIL if RED touched implementation; git diff --name-only -- test/ FAIL if GREEN touched tests)
- SC-6: SC-ID Referencing Format — `### TDD-:  (SC-1, SC-2)` mandatory format, regex-parsed

**#1064 (SC-1 through SC-7)**: Writing-plans consumer awareness
- SC-1: Structured consumption of 8 fields (SC-ID→phase/TDD map, Pipeline Step Binding→verification passthrough, Phase Binding→ordering, Verification Gate→method selection, Artifact Path→output location, Risk Traceability→risk analysis, Decision Ledger→constraint compliance, Decomposition Classification→plan format)
- SC-2 through SC-7: Cross-reference validation (6 checks: SC-ID→TDD traceability, TDD SC-ID exists in spec, Phase matches Phase Binding, Pipeline Step Binding preserved, no DEC-ID contradiction, RISK-ID→mitigation, combined/separate matches Decomposition Classification)

## Success Criteria

All SCs are plan-level (structural — verify via grep, ls, file read).

| SC-ID | Criterion | Evidence Type | Phase | Issue |
|-------|-----------|--------------|-------|-------|
| SC-1 | Phase 1 PR merged with all #848, #853, #849 artifacts created | structural | 1 | #848, #853, #849 |
| SC-2 | Phase 2 PR merged with #1060 spec-creation `write.md` expanded (8 SC columns + 4 preamble sections) | structural | 2 | #1060 |
| SC-3 | Phase 3 PR merged with #1061 artifact layer (sc-summary.yaml, solve contracts, lifecycle manifest, retention) | structural | 3 | #1061 |
| SC-4 | Phase 4 PR merged with #1062 handoff gates (spec-to-plan, plan-to-pipeline, SC close-out, revision re-entry) | structural | 4 | #1062 |
| SC-5 | Phase 5 PR merged with #1063 pipeline enforcement + #1064 writing-plans consumer awareness | structural | 5 | #1063, #1064 |
| SC-6 | All sub-issues closed after their PRs merge — no orphaned open issues | structural | Post | all |
| SC-7 | Dependency chain verified: no Phase N+1 merged before Phase N | structural | Post | all |
| SC-8 | Coordination spec #854 updated with status markers per phase | structural | Per-phase | #854 |
| SC-9 | Spec-artifacts directory contains per-phase card catalogue entries | structural | Per-phase | #854 |

## Non-Goals

- Behavioral enforcement tests for any of the 8 issues (deferred to per-spec implementation)
- Backfilling existing SKILL.md files or guideline blocks with enforcement text (separate cross-cutting spec)
- Few-shot exemplar distribution shifting (needs behavioral research — separate spec)
- Model-specific adaptation of any pattern (operational notes, not spec deliverable)
- Changes to skills other than spec-creation and writing-plans (out of scope)

## Revision Policy

| Scope | Action |
|-------|--------|
| Phase SC count changes | Update SC table and sub-issue comments |
| Phase dependency reorder | Update dependency graph + sub-issue reprioritization |
| New issue in existing layer | Append to phase, add SC-10+ |
| New layer | New Phase 6, full sub-issue structure |
| Remove issue | Remove from phase, update SC count, renumber SCs |