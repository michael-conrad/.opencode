# Code-Path Inventory — Issue #1885

## Scope

This inventory covers all execution paths through the writing-plans skill's plan creation entry points. The spec fixes a gate placement defect: the artifact validation gate fires at Step 4a (inside the 22-step pipeline) rather than at the entry point (Trigger Dispatch Table + pre-plan-readiness). This inventory enumerates both current paths (with the escape hatch) and post-fix paths (with the hatch closed).

## Affected Units

| Unit | File | Role |
|------|------|------|
| Trigger Dispatch Table | `SKILL.md:36-53` | Entry-point routing — decides which task to dispatch |
| Entry Criteria | `SKILL.md:97-100` | Prerequisites the orchestrator checks before dispatching |
| Mandatory Task Discipline item 8 | `SKILL.md:34` | Advisory artifact validation rule |
| pre-plan-readiness task | `tasks/pre-plan-readiness.md` | Entry-point gate — checks spec file, branch, sync |
| spec-to-plan handoff | `tasks/handoffs/spec-to-plan.md` | Pipeline-internal handoff manifest validation |
| readiness task (Step 4a) | `tasks/readiness.md` | Pipeline-internal readiness gate (existing artifact check location) |
| 000-critical-rules.md | `guidelines/000-critical-rules.md` | Enforcement layer — no existing artifact gate entry |

## Path Inventory

### CURRENT STATE — Paths (Escape Hatch Open)

#### Path 1: Happy Path — Spec With All Artifacts

- **Trigger condition:** Agent invokes `writing-plans` for a spec created through the spec-creation pipeline (all 7 analytical artifacts present)
- **Path description:** Trigger Dispatch Table matches "create plan" → dispatches to `create` task → enters 22-step pipeline → Step 4a readiness gate passes (artifacts exist) → plan created
- **Data flow:**
  - **Inputs:** `spec_issue_number`, `spec_body` (from Trigger Dispatch Table context)
  - **Transformations:** Dispatch routing → pipeline step execution → plan generation
  - **Outputs:** Plan files (`plan.md`, `plan-NN.md`) written to `.issues/{N}/`
  - **Side effects:** `local-issues sync`, git commits, Z3 check artifacts

#### Path 2: Escape Hatch — Spec Without Analytical Artifacts (CURRENT DEFECT)

- **Trigger condition:** Agent creates spec directly as GitHub Issue (bypassing spec-creation pipeline), then invokes `writing-plans`
- **Path description:** Trigger Dispatch Table matches "create plan" → dispatches to `create` task → enters 22-step pipeline → Step 4a readiness gate fires (artifacts missing) → agent is already inside pipeline → agent can rationalize bypass ("I'll create artifacts from spec body" or "spec is detailed enough")
- **Data flow:**
  - **Inputs:** `spec_issue_number`, `spec_body` (no analytical artifacts)
  - **Transformations:** Dispatch routing (no artifact check) → pipeline entry (no artifact check) → Step 4a gate fires too late
  - **Outputs:** Potentially defective plan (analytically shallow — no blast radius, concern map, code path inventory, cross-cutting matrix, interface compatibility, state analysis, testability assessment)
  - **Side effects:** Sunk-cost bias incentivizes fabrication over restart
- **Coverage gap:** This path has NO corresponding SC that blocks it at the entry point. SC-1 through SC-6 (post-fix) are designed to close this gap.

#### Path 3: pre-plan-readiness — Spec File Missing

- **Trigger condition:** `pre-plan-readiness` task invoked, spec file does not exist at `.issues/{N}/spec.md`
- **Path description:** Check 1 fails → return `BLOCKED` with `SPEC_FILE_MISSING`
- **Data flow:**
  - **Inputs:** `spec_issue_number`
  - **Transformations:** File existence check (structural)
  - **Outputs:** `status: BLOCKED`, `reason: SPEC_FILE_MISSING`
  - **Side effects:** None

#### Path 4: pre-plan-readiness — Feature Branch Missing

- **Trigger condition:** `pre-plan-readiness` task invoked, no feature branch exists or agent is on trunk
- **Path description:** Check 2 fails → return `BLOCKED` with `FEATURE_BRANCH_MISSING`
- **Data flow:**
  - **Inputs:** Current branch name
  - **Transformations:** Branch name comparison against trunk
  - **Outputs:** `status: BLOCKED`, `reason: FEATURE_BRANCH_MISSING`
  - **Side effects:** None

#### Path 5: pre-plan-readiness — Local Issues Not Synced

- **Trigger condition:** `pre-plan-readiness` task invoked, `local-issues sync` has not been run
- **Path description:** Check 3 fails → return `BLOCKED` with `LOCAL_ISSUES_NOT_SYNCED`
- **Data flow:**
  - **Inputs:** `.issues/{N}/` directory state
  - **Transformations:** Sync state verification
  - **Outputs:** `status: BLOCKED`, `reason: LOCAL_ISSUES_NOT_SYNCED`
  - **Side effects:** None

#### Path 6: pre-plan-readiness — All Prerequisites Met (CURRENT — No Artifact Check)

- **Trigger condition:** `pre-plan-readiness` task invoked, spec file exists, feature branch exists, sync done — BUT analytical artifacts may be missing
- **Path description:** All 3 checks pass → return `PASS` — **does NOT check for analytical artifacts**
- **Data flow:**
  - **Inputs:** `spec_issue_number`, branch name, sync state
  - **Transformations:** Three structural checks (file, branch, sync)
  - **Outputs:** `status: PASS`, `finding_summary: "All prerequisites met"`
  - **Side effects:** None — but this PASS is a false positive when artifacts are missing
- **Coverage gap:** This path is the entry-point bypass. It passes even when artifacts are missing, allowing the agent to enter the pipeline.

#### Path 7: spec-to-plan Handoff — Preconditions Fail

- **Trigger condition:** Handoff invoked, spec not approved or `.issues/{N}/` directory missing
- **Path description:** Step 1 precondition check fails → write BLOCKED manifest
- **Data flow:**
  - **Inputs:** Spec approval state, directory existence
  - **Transformations:** Precondition validation
  - **Outputs:** BLOCKED manifest YAML
  - **Side effects:** Manifest file written to `tmp/{N}/artifacts/`

#### Path 8: spec-to-plan Handoff — SC Summary YAML Invalid

- **Trigger condition:** Handoff invoked, `sc-summary.yaml` is malformed or missing required fields
- **Path description:** Step 2-3 YAML validation fails → write BLOCKED manifest
- **Data flow:**
  - **Inputs:** `sc-summary.yaml` content
  - **Transformations:** YAML parsing, field validation, SC-ID count verification
  - **Outputs:** BLOCKED manifest YAML
  - **Side effects:** Manifest file written

#### Path 9: spec-to-plan Handoff — Risk Cross-References Orphaned

- **Trigger condition:** Handoff invoked, RISK-ID references SC that doesn't exist in sc-summary
- **Path description:** Step 4 risk traceability check fails → write BLOCKED manifest
- **Data flow:**
  - **Inputs:** Risk Traceability table, `sc-summary.yaml`
  - **Transformations:** Cross-reference validation
  - **Outputs:** BLOCKED manifest YAML
  - **Side effects:** Manifest file written

#### Path 10: spec-to-plan Handoff — Decision Contradictions

- **Trigger condition:** Handoff invoked, decision ledger has detected contradictions
- **Path description:** Step 5 decision check fails → write BLOCKED manifest with `DECISION_CONTRADICTION`
- **Data flow:**
  - **Inputs:** Decision Ledger, spec-auditor findings
  - **Transformations:** Contradiction detection
  - **Outputs:** BLOCKED manifest YAML
  - **Side effects:** Manifest file written

#### Path 11: spec-to-plan Handoff — Decomposition Inconsistency

- **Trigger condition:** Handoff invoked, decomposition classification doesn't match SC-to-phase bindings
- **Path description:** Step 6 decomposition check fails → write BLOCKED manifest
- **Data flow:**
  - **Inputs:** Decomposition classification, `sc-summary.yaml` phase bindings
  - **Transformations:** Consistency validation (single-task vs multi-phase)
  - **Outputs:** BLOCKED manifest YAML
  - **Side effects:** Manifest file written

#### Path 12: spec-to-plan Handoff — All Checks Pass (CURRENT — No Artifact Check)

- **Trigger condition:** Handoff invoked, all 6 checks pass — BUT analytical artifacts may be missing
- **Path description:** All steps pass → write PASS manifest — **does NOT check for analytical artifacts**
- **Data flow:**
  - **Inputs:** All spec metadata (approval, sc-summary, risk, decisions, decomposition)
  - **Transformations:** Six validation steps
  - **Outputs:** PASS manifest YAML
  - **Side effects:** Manifest file written
- **Coverage gap:** This handoff passes even when artifacts are missing, propagating the defect to downstream pipeline consumers.

#### Path 13: Mandatory Task Discipline Item 8 — Advisory (CURRENT)

- **Trigger condition:** Agent reads SKILL.md Mandatory Task Discipline
- **Path description:** Item 8 says "Analytical artifact validation required before plan creation." — advisory language, not enforced as hard gate
- **Data flow:**
  - **Inputs:** SKILL.md text
  - **Transformations:** Agent reads advisory text
  - **Outputs:** Agent may treat as optional
  - **Side effects:** None — advisory language is not enforcement

#### Path 14: Trigger Dispatch Table — Missing Artifact HALT Entries (CURRENT — Partial)

- **Trigger condition:** Agent explicitly says "blast-radius artifact missing for plan" (or similar for other artifacts)
- **Path description:** Trigger Dispatch Table has HALT entries for each artifact name (lines 46-51) — but these only fire when the agent explicitly names the missing artifact, not as a general pre-check
- **Data flow:**
  - **Inputs:** Agent's exact phrasing
  - **Transformations:** Pattern matching against Trigger Dispatch Table
  - **Outputs:** HALT (if exact phrase matches)
  - **Side effects:** None
- **Coverage gap:** These entries are reactive (agent must name the missing artifact), not proactive (automatic pre-check before dispatch).

### POST-FIX — Paths (Escape Hatch Closed)

#### Path 15: Trigger Dispatch Table — Artifact Pre-Check Blocks (POST-FIX)

- **Trigger condition:** Agent invokes `writing-plans` for "create plan" — analytical artifacts missing
- **Path description:** Trigger Dispatch Table "create plan" entry includes artifact validation step → artifacts missing → BLOCKED with `MISSING_SPEC_ARTIFACT` → agent never enters pipeline
- **Data flow:**
  - **Inputs:** `spec_issue_number`, `.issues/{N}/` directory
  - **Transformations:** Artifact existence check (7 file-existence checks)
  - **Outputs:** `status: BLOCKED`, `reason: MISSING_SPEC_ARTIFACT`
  - **Side effects:** None — gate fires at entry point, before pipeline entry
- **SC coverage:** SC-1

#### Path 16: pre-plan-readiness — Artifact Check Blocks (POST-FIX)

- **Trigger condition:** `pre-plan-readiness` task invoked, analytical artifacts missing
- **Path description:** New check 4 verifies all 7 artifacts exist → artifacts missing → return `BLOCKED` with `MISSING_SPEC_ARTIFACT`
- **Data flow:**
  - **Inputs:** `.issues/{N}/` directory, 7 artifact file paths
  - **Transformations:** 7 file-existence checks (structural)
  - **Outputs:** `status: BLOCKED`, `reason: MISSING_SPEC_ARTIFACT`
  - **Side effects:** None
- **SC coverage:** SC-2

#### Path 17: SKILL.md Entry Criteria — Artifact Requirement Listed (POST-FIX)

- **Trigger condition:** Orchestrator reads Entry Criteria before dispatching
- **Path description:** Entry Criteria now list "All 7 analytical artifacts present" as a prerequisite → orchestrator sees requirement before dispatch
- **Data flow:**
  - **Inputs:** SKILL.md Entry Criteria text
  - **Transformations:** Orchestrator reads prerequisite list
  - **Outputs:** Orchestrator knows artifacts are required before dispatch
  - **Side effects:** None — informational gate
- **SC coverage:** SC-3

#### Path 18: Mandatory Task Discipline Item 8 — Hard Gate (POST-FIX)

- **Trigger condition:** Agent reads SKILL.md Mandatory Task Discipline
- **Path description:** Item 8 now says "Missing artifacts produce BLOCKED with `MISSING_SPEC_ARTIFACT`. The pipeline MUST NOT proceed past the entry point without all 7 artifacts." — hard gate language
- **Data flow:**
  - **Inputs:** SKILL.md text
  - **Transformations:** Agent reads hard-gate language
  - **Outputs:** Agent treats as mandatory enforcement
  - **Side effects:** None — hard gate language is enforcement
- **SC coverage:** SC-4

#### Path 19: spec-to-plan Handoff — Artifact Validation (POST-FIX)

- **Trigger condition:** Handoff invoked, analytical artifacts missing
- **Path description:** New check validates all 7 artifacts exist → artifacts missing → write BLOCKED manifest with `MISSING_SPEC_ARTIFACT`
- **Data flow:**
  - **Inputs:** `.issues/{N}/` directory, 7 artifact file paths
  - **Transformations:** 7 file-existence checks (structural)
  - **Outputs:** BLOCKED manifest YAML with `MISSING_SPEC_ARTIFACT`
  - **Side effects:** Manifest file written
- **SC coverage:** SC-5

#### Path 20: Critical-Rules Entry — Artifact Gate Bypass Prohibited (POST-FIX)

- **Trigger condition:** Agent attempts to bypass artifact gate (any method)
- **Path description:** Critical-rules entry fires → HALT (Tier 2 Process-Integrity) → agent cannot proceed
- **Data flow:**
  - **Inputs:** Agent's bypass attempt
  - **Transformations:** Critical-rules enforcement
  - **Outputs:** HALT
  - **Side effects:** None
- **SC coverage:** SC-6

#### Path 21: Behavioral Enforcement Test — Agent BLOCKED (POST-FIX)

- **Trigger condition:** Behavioral test sends prompt to create plan for spec without artifacts
- **Path description:** Agent reads writing-plans skill → artifact gate fires at entry point → agent returns BLOCKED → test asserts BLOCKED → PASS
- **Data flow:**
  - **Inputs:** Test prompt (plan creation request for artifact-less spec)
  - **Transformations:** Agent dispatch → artifact gate → BLOCKED
  - **Outputs:** Agent response with BLOCKED status
  - **Side effects:** Test session artifacts (session.yaml, stdout.log, stderr.log)
- **SC coverage:** SC-7, SC-8

## Path-to-SC Mapping

| Path | SC Coverage | Status |
|------|------------|--------|
| Path 1 (Happy — artifacts present) | Regression invariant 1 | Existing — must continue to work |
| Path 2 (Escape hatch — current defect) | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6 | **GAP — no current SC covers this; post-fix SCs close it** |
| Path 3 (pre-plan-readiness — spec missing) | Existing | Existing — unchanged |
| Path 4 (pre-plan-readiness — branch missing) | Existing | Existing — unchanged |
| Path 5 (pre-plan-readiness — sync missing) | Existing | Existing — unchanged |
| Path 6 (pre-plan-readiness — all pass, no artifact check) | SC-2 | **GAP — current path passes without artifact check** |
| Path 7-11 (handoff — various BLOCKED) | Existing | Existing — unchanged |
| Path 12 (handoff — all pass, no artifact check) | SC-5 | **GAP — current path passes without artifact check** |
| Path 13 (item 8 — advisory) | SC-4 | **GAP — advisory language, not enforcement** |
| Path 14 (TDT — reactive HALT entries) | SC-1 | **GAP — reactive, not proactive pre-check** |
| Path 15 (TDT — artifact pre-check, post-fix) | SC-1 | New — closes gap |
| Path 16 (pre-plan-readiness — artifact check, post-fix) | SC-2 | New — closes gap |
| Path 17 (Entry Criteria — artifact requirement, post-fix) | SC-3 | New — closes gap |
| Path 18 (item 8 — hard gate, post-fix) | SC-4 | New — closes gap |
| Path 19 (handoff — artifact validation, post-fix) | SC-5 | New — closes gap |
| Path 20 (critical-rules entry, post-fix) | SC-6 | New — closes gap |
| Path 21 (behavioral test, post-fix) | SC-7, SC-8 | New — enforcement evidence |

## Coverage Requirements

| Path Category | Minimum Coverage | Met? |
|---------------|-----------------|------|
| Happy path (Path 1) | At least 1 SC verifying primary success | ✅ Regression invariant 1 |
| Escape hatch (Path 2) | At least 1 SC blocking entry without artifacts | ❌ GAP — SC-1 through SC-6 close this |
| pre-plan-readiness error paths (Paths 3-5) | 1 SC each for correct BLOCKED reason | ✅ Existing |
| pre-plan-readiness false PASS (Path 6) | 1 SC blocking when artifacts missing | ❌ GAP — SC-2 closes this |
| handoff error paths (Paths 7-11) | 1 SC each for correct BLOCKED reason | ✅ Existing |
| handoff false PASS (Path 12) | 1 SC blocking when artifacts missing | ❌ GAP — SC-5 closes this |
| Advisory item 8 (Path 13) | 1 SC elevating to hard gate | ❌ GAP — SC-4 closes this |
| Reactive TDT entries (Path 14) | 1 SC making proactive pre-check | ❌ GAP — SC-1 closes this |
| Post-fix paths (Paths 15-21) | 1 SC each | ✅ SC-1 through SC-8 |

## Gap Analysis

### Paths Without Corresponding SC (Current State)

| Path | Gap Description | Closing SC |
|------|----------------|------------|
| Path 2 | Escape hatch — agent enters pipeline without artifacts | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6 |
| Path 6 | pre-plan-readiness passes without artifact check | SC-2 |
| Path 12 | spec-to-plan handoff passes without artifact check | SC-5 |
| Path 13 | Mandatory Task Discipline item 8 is advisory only | SC-4 |
| Path 14 | Trigger Dispatch Table has reactive HALT entries, not proactive pre-check | SC-1 |

### SCs Without Corresponding Path (Post-Fix)

All 8 SCs map to at least one post-fix path. No orphan SCs.

## Coverage Verification

Cross-referencing the path inventory against the spec's SC table:

| SC | Paths Covered | Coverage Status |
|----|--------------|-----------------|
| SC-1 | Path 15 | ✅ Covers Trigger Dispatch Table artifact pre-check |
| SC-2 | Path 16 | ✅ Covers pre-plan-readiness artifact check |
| SC-3 | Path 17 | ✅ Covers Entry Criteria artifact requirement |
| SC-4 | Path 18 | ✅ Covers Mandatory Task Discipline item 8 hard gate |
| SC-5 | Path 19 | ✅ Covers spec-to-plan handoff artifact validation |
| SC-6 | Path 20 | ✅ Covers critical-rules entry |
| SC-7 | Path 21 | ✅ Covers behavioral enforcement test (GREEN) |
| SC-8 | Path 21 | ✅ Covers behavioral TDD (RED before GREEN) |

**All SCs have path coverage. All identified gaps have closing SCs. No orphan SCs. No orphan paths.**

## Data Flow Summary

```
                    ┌─────────────────────────────────┐
                    │  Agent invokes writing-plans     │
                    │  for "create plan"               │
                    └───────────────┬─────────────────┘
                                    │
                    ┌───────────────▼─────────────────┐
                    │  Trigger Dispatch Table          │
                    │  ┌───────────────────────────┐   │
                    │  │ CURRENT: dispatch to create│   │
                    │  │ POST-FIX: artifact check  │   │
                    │  │ → BLOCKED if missing      │   │
                    │  └───────────────────────────┘   │
                    └───────────────┬─────────────────┘
                                    │ (if artifacts present)
                    ┌───────────────▼─────────────────┐
                    │  Entry Criteria                  │
                    │  ┌───────────────────────────┐   │
                    │  │ CURRENT: spec approved,    │   │
                    │  │   auth scope for_plan+     │   │
                    │  │ POST-FIX: + artifacts     │   │
                    │  └───────────────────────────┘   │
                    └───────────────┬─────────────────┘
                                    │
                    ┌───────────────▼─────────────────┐
                    │  pre-plan-readiness              │
                    │  ┌───────────────────────────┐   │
                    │  │ CURRENT: spec file, branch, │   │
                    │  │   sync → PASS/BLOCKED      │   │
                    │  │ POST-FIX: + artifact check │   │
                    │  │   → BLOCKED if missing     │   │
                    │  └───────────────────────────┘   │
                    └───────────────┬─────────────────┘
                                    │ (if PASS)
                    ┌───────────────▼─────────────────┐
                    │  22-Step Pipeline                │
                    │  ┌───────────────────────────┐   │
                    │  │ Step 4a: readiness        │   │
                    │  │ (existing artifact gate — │   │
                    │  │  secondary validation)    │   │
                    │  └───────────────────────────┘   │
                    │  ┌───────────────────────────┐   │
                    │  │ spec-to-plan handoff      │   │
                    │  │ CURRENT: 6 checks         │   │
                    │  │ POST-FIX: + artifact      │   │
                    │  │   validation (check 7)    │   │
                    │  └───────────────────────────┘   │
                    └───────────────┬─────────────────┘
                                    │
                    ┌───────────────▼─────────────────┐
                    │  Plan Created                     │
                    └─────────────────────────────────┘
```

## Edge Cases

| Edge Case | Path | Handling |
|-----------|------|----------|
| Spec has some but not all 7 artifacts | Path 15, 16, 19 | BLOCKED — all 7 required (DEC-2) |
| Spec has artifacts but they are empty files | Path 15, 16, 19 | BLOCKED — artifacts must be non-empty (item 8: "present and non-empty") |
| Spec created through spec-creation pipeline (has artifacts) | Path 1 | PASS — existing behavior preserved (regression invariant 1) |
| Existing plan (retroactive) for spec without artifacts | Path 2 (retroactive variant) | Existing behavior — retroactive plans use existing spec body (RISK-2 mitigation) |
| Agent explicitly names missing artifact | Path 14 | HALT — existing reactive entries preserved |
| Agent attempts to fabricate artifacts inline | Path 20 | HALT — critical-rules entry covers fabrication (RISK-1 mitigation) |
| Artifact directory exists but is empty | Path 15, 16, 19 | BLOCKED — directory existence ≠ artifact presence |
