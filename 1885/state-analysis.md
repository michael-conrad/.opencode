# State Analysis — Issue #1885

## State Inventory

### Initial State

| State | Description | Entry Conditions | Exit Conditions |
|-------|-------------|------------------|-----------------|
| `SPEC_CREATED_NO_ARTIFACTS` | A spec exists as a GitHub Issue but has zero analytical artifacts (no blast-radius, concern-map, code-path-inventory, cross-cutting-matrix, interface-compatibility, state-analysis, testability-assessment) | Spec created directly as GitHub Issue (bypassing spec-creation pipeline) | All 7 analytical artifacts created and committed to `.issues/{N}/` |

### Intermediate States

| State | Description | Entry Conditions | Exit Conditions |
|-------|-------------|------------------|-----------------|
| `SPEC_CREATED_WITH_ARTIFACTS` | A spec exists with all 7 analytical artifacts present and non-empty | All 7 artifacts exist in `.issues/{N}/` (created via spec-creation pipeline or manually) | Spec is approved; authorization scope is `for_plan` or above |
| `PRE_PLAN_READINESS_CHECK` | Entry-point gate verifying prerequisites before plan creation | Agent invokes `writing-plans` with "create plan" trigger | All checks pass (spec file, branch, sync, artifacts) → proceed; any check fails → BLOCKED |
| `PIPELINE_ENTRY` | Agent has entered the 21-step writing-plans create pipeline | pre-plan-readiness returns PASS; Trigger Dispatch Table pre-check passes | Pipeline steps execute sequentially |
| `ARTIFACT_VALIDATION_SECONDARY` | Step 4a secondary validation gate inside the pipeline | Pipeline Step 4 completes with PASS | Artifacts validated → proceed to Step 5; artifacts missing → BLOCKED (should never reach this state after fix) |
| `PLAN_CREATION_IN_PROGRESS` | Pipeline steps 5-21 executing | All entry-point gates passed; artifact validation passed | All pipeline steps complete with PASS |
| `PLAN_CREATED` | Implementation plan successfully created and stored | All 21 pipeline steps complete; plan index and phase files written to `.issues/{N}/` | Plan is ready for implementation |

### Terminal States

| State | Description | Entry Conditions | Exit Conditions |
|-------|-------------|------------------|-----------------|
| `BLOCKED_MISSING_ARTIFACTS` | Plan creation halted because analytical artifacts are missing | pre-plan-readiness or Trigger Dispatch Table pre-check detects missing artifacts | N/A (terminal — requires remediation: create artifacts via spec-creation pipeline) |
| `PLAN_CREATION_FAILED` | Plan creation failed for a reason other than missing artifacts | Any pipeline step returns BLOCKED or FAIL | N/A (terminal — requires remediation of the specific failure) |

### Error States

| State | Description | Entry Conditions | Exit Conditions |
|-------|-------------|------------------|-----------------|
| `ARTIFACT_FABRICATION_DETECTED` | Agent attempted to fabricate artifacts inline instead of routing through spec-creation pipeline | Behavioral enforcement test or auditor detects fabricated artifacts | N/A (terminal — critical violation) |

---

## Transition Table

### Current State Machine (BEFORE fix — escape hatch exists)

| # | Current State | Trigger | Guard | Target State | Action |
|---|--------------|---------|-------|-------------|--------|
| T1 | `SPEC_CREATED_NO_ARTIFACTS` | Agent invokes `writing-plans` "create plan" | Spec file exists, branch exists, sync done | `PIPELINE_ENTRY` | pre-plan-readiness passes (no artifact check) — **ESCAPE HATCH** |
| T2 | `SPEC_CREATED_WITH_ARTIFACTS` | Agent invokes `writing-plans` "create plan" | Spec file exists, branch exists, sync done | `PIPELINE_ENTRY` | pre-plan-readiness passes |
| T3 | `PIPELINE_ENTRY` | Pipeline Step 4 completes | Step 4 returns PASS | `ARTIFACT_VALIDATION_SECONDARY` | Step 4a artifact validation fires |
| T4 | `ARTIFACT_VALIDATION_SECONDARY` | Artifacts present and valid | All 7 artifacts exist, non-empty, well-formed | `PLAN_CREATION_IN_PROGRESS` | Proceed to Step 5 |
| T5 | `ARTIFACT_VALIDATION_SECONDARY` | Artifacts missing | Agent rationalizes bypass or fabricates artifacts | `PLAN_CREATION_IN_PROGRESS` | **ESCAPE HATCH** — agent proceeds despite missing artifacts |
| T6 | `ARTIFACT_VALIDATION_SECONDARY` | Artifacts missing | Agent does NOT bypass | `PLAN_CREATION_FAILED` | BLOCKED with `MISSING_SPEC_ARTIFACT` |
| T7 | `PLAN_CREATION_IN_PROGRESS` | All pipeline steps complete | Steps 5-21 all return PASS | `PLAN_CREATED` | Plan index and phase files written |
| T8 | `PLAN_CREATION_IN_PROGRESS` | Any pipeline step fails | Step returns BLOCKED or FAIL | `PLAN_CREATION_FAILED` | Pipeline halts |

### Desired State Machine (AFTER fix — escape hatch closed)

| # | Current State | Trigger | Guard | Target State | Action |
|---|--------------|---------|-------|-------------|--------|
| T1' | `SPEC_CREATED_NO_ARTIFACTS` | Agent invokes `writing-plans` "create plan" | — | `BLOCKED_MISSING_ARTIFACTS` | **NEW**: Trigger Dispatch Table pre-check detects missing artifacts → BLOCKED before dispatch |
| T2' | `SPEC_CREATED_NO_ARTIFACTS` | Agent invokes `writing-plans` "pre-plan-readiness" | — | `BLOCKED_MISSING_ARTIFACTS` | **NEW**: pre-plan-readiness Step 4 checks artifacts → BLOCKED with `MISSING_SPEC_ARTIFACT` |
| T3' | `SPEC_CREATED_WITH_ARTIFACTS` | Agent invokes `writing-plans` "create plan" | All 7 artifacts exist, non-empty | `PIPELINE_ENTRY` | Trigger Dispatch Table pre-check passes; pre-plan-readiness passes |
| T4' | `PIPELINE_ENTRY` | Pipeline Step 4 completes | Step 4 returns PASS | `ARTIFACT_VALIDATION_SECONDARY` | Step 4a artifact validation fires (secondary gate) |
| T5' | `ARTIFACT_VALIDATION_SECONDARY` | Artifacts present and valid | All 7 artifacts exist, non-empty, well-formed | `PLAN_CREATION_IN_PROGRESS` | Proceed to Step 5 |
| T6' | `ARTIFACT_VALIDATION_SECONDARY` | Artifacts missing | Should never reach this state after fix | `PLAN_CREATION_FAILED` | BLOCKED with `MISSING_SPEC_ARTIFACT` (defense-in-depth) |
| T7' | `PLAN_CREATION_IN_PROGRESS` | All pipeline steps complete | Steps 5-21 all return PASS | `PLAN_CREATED` | Plan index and phase files written |
| T8' | `PLAN_CREATION_IN_PROGRESS` | Any pipeline step fails | Step returns BLOCKED or FAIL | `PLAN_CREATION_FAILED` | Pipeline halts |

### Recovery Transitions

| # | Current State | Trigger | Guard | Target State | Action |
|---|--------------|---------|-------|-------------|--------|
| R1 | `BLOCKED_MISSING_ARTIFACTS` | Developer creates artifacts via spec-creation pipeline | All 7 artifacts now exist | `SPEC_CREATED_WITH_ARTIFACTS` | Re-invoke `writing-plans` "create plan" |
| R2 | `PLAN_CREATION_FAILED` | Developer remediates failure cause | Failure cause resolved | `SPEC_CREATED_WITH_ARTIFACTS` | Re-invoke `writing-plans` "create plan" |

---

## Completeness Verification

### Deadlock Check

| State | Outgoing Transitions | Deadlock? |
|-------|---------------------|-----------|
| `SPEC_CREATED_NO_ARTIFACTS` | T1', T2' | No |
| `SPEC_CREATED_WITH_ARTIFACTS` | T3' | No |
| `PRE_PLAN_READINESS_CHECK` | T2', T3' (implicit) | No |
| `PIPELINE_ENTRY` | T4' | No |
| `ARTIFACT_VALIDATION_SECONDARY` | T5', T6' | No |
| `PLAN_CREATION_IN_PROGRESS` | T7', T8' | No |
| `PLAN_CREATED` | None (terminal) | No — terminal state |
| `BLOCKED_MISSING_ARTIFACTS` | R1 | No — has recovery path |
| `PLAN_CREATION_FAILED` | R2 | No — has recovery path |
| `ARTIFACT_FABRICATION_DETECTED` | None (terminal) | No — terminal error state |

**Result: No deadlock states.** All non-terminal states have at least one outgoing transition. All terminal states are explicitly terminal (success, blocked, or failure).

### Reachability Check

| State | Reachable from Initial? | Path |
|-------|------------------------|------|
| `SPEC_CREATED_NO_ARTIFACTS` | Yes (initial) | — |
| `SPEC_CREATED_WITH_ARTIFACTS` | Yes | SPEC_CREATED_NO_ARTIFACTS → (create artifacts) → SPEC_CREATED_WITH_ARTIFACTS |
| `BLOCKED_MISSING_ARTIFACTS` | Yes | SPEC_CREATED_NO_ARTIFACTS → T1' or T2' → BLOCKED_MISSING_ARTIFACTS |
| `PIPELINE_ENTRY` | Yes | SPEC_CREATED_WITH_ARTIFACTS → T3' → PIPELINE_ENTRY |
| `ARTIFACT_VALIDATION_SECONDARY` | Yes | PIPELINE_ENTRY → T4' → ARTIFACT_VALIDATION_SECONDARY |
| `PLAN_CREATION_IN_PROGRESS` | Yes | ARTIFACT_VALIDATION_SECONDARY → T5' → PLAN_CREATION_IN_PROGRESS |
| `PLAN_CREATED` | Yes | PLAN_CREATION_IN_PROGRESS → T7' → PLAN_CREATED |
| `PLAN_CREATION_FAILED` | Yes | PLAN_CREATION_IN_PROGRESS → T8' → PLAN_CREATION_FAILED |
| `ARTIFACT_FABRICATION_DETECTED` | Yes | SPEC_CREATED_NO_ARTIFACTS → (fabrication attempt) → ARTIFACT_FABRICATION_DETECTED |

**Result: No unreachable states.** Every state is reachable from the initial state through a chain of valid transitions.

### Exit Path Check

| State | Path to Terminal | Exists? |
|-------|-----------------|---------|
| `SPEC_CREATED_NO_ARTIFACTS` | → BLOCKED_MISSING_ARTIFACTS (T1') | Yes |
| `SPEC_CREATED_WITH_ARTIFACTS` | → PIPELINE_ENTRY → ... → PLAN_CREATED (T3'→T4'→T5'→T7') | Yes |
| `PIPELINE_ENTRY` | → ARTIFACT_VALIDATION_SECONDARY → ... → PLAN_CREATED (T4'→T5'→T7') | Yes |
| `ARTIFACT_VALIDATION_SECONDARY` | → PLAN_CREATION_IN_PROGRESS → PLAN_CREATED (T5'→T7') | Yes |
| `PLAN_CREATION_IN_PROGRESS` | → PLAN_CREATED (T7') or → PLAN_CREATION_FAILED (T8') | Yes |

**Result: Every non-terminal state has a path to a terminal state.**

### Missing Transition Check

| From → To | Defined? | Rationale |
|-----------|---------|-----------|
| `SPEC_CREATED_NO_ARTIFACTS` → `PIPELINE_ENTRY` | ❌ (intentionally blocked) | This is the escape hatch being closed — the fix prevents this transition |
| `SPEC_CREATED_NO_ARTIFACTS` → `PLAN_CREATION_IN_PROGRESS` | ❌ (intentionally blocked) | Cannot enter pipeline without artifacts |
| `BLOCKED_MISSING_ARTIFACTS` → `PIPELINE_ENTRY` | ❌ (intentionally blocked) | Must transition through SPEC_CREATED_WITH_ARTIFACTS first (recovery path R1) |
| `ARTIFACT_VALIDATION_SECONDARY` → `BLOCKED_MISSING_ARTIFACTS` | ❌ (defense-in-depth) | Should never reach this state after fix; if it does, T6' handles it via PLAN_CREATION_FAILED |

**Result: All missing transitions are intentional — they represent the escape hatch being closed.**

---

## Coverage Verification

### Against Spec Requirements

| Requirement | State Coverage | Transition Coverage |
|-------------|---------------|-------------------|
| Artifact pre-check at Trigger Dispatch Table entry point | `SPEC_CREATED_NO_ARTIFACTS` → `BLOCKED_MISSING_ARTIFACTS` (T1') | ✅ Covered |
| Artifact check in pre-plan-readiness task | `SPEC_CREATED_NO_ARTIFACTS` → `BLOCKED_MISSING_ARTIFACTS` (T2') | ✅ Covered |
| Artifact requirement in Entry Criteria | `SPEC_CREATED_WITH_ARTIFACTS` as prerequisite for `PIPELINE_ENTRY` | ✅ Covered |
| Hard gate (BLOCKED, not advisory) | `BLOCKED_MISSING_ARTIFACTS` as terminal state with recovery path | ✅ Covered |
| Handoff manifest artifact validation | `ARTIFACT_VALIDATION_SECONDARY` as defense-in-depth (T6') | ✅ Covered |
| Critical-rules entry | `ARTIFACT_FABRICATION_DETECTED` as error state | ✅ Covered |
| Behavioral enforcement test | T1' and T2' as the transitions the behavioral test verifies | ✅ Covered |

### Error Condition Coverage

| Error Condition | Error State | Recovery Path |
|----------------|-------------|---------------|
| Artifacts missing at entry point | `BLOCKED_MISSING_ARTIFACTS` | R1: Create artifacts via spec-creation pipeline |
| Artifacts missing at secondary gate (defense-in-depth) | `PLAN_CREATION_FAILED` | R2: Remediate failure cause |
| Agent fabricates artifacts | `ARTIFACT_FABRICATION_DETECTED` | Critical violation — no recovery; behavioral test prevents |
| Pipeline step failure | `PLAN_CREATION_FAILED` | R2: Remediate failure cause |

---

## Key Insight: The Escape Hatch Mechanism

The escape hatch exists because of a **gate placement defect** in the state machine:

**Before fix:**
```
SPEC_CREATED_NO_ARTIFACTS
    │
    ▼ (pre-plan-readiness: checks spec file, branch, sync — NO artifact check)
PIPELINE_ENTRY  ←── ESCAPE HATCH: agent enters pipeline without artifacts
    │
    ▼ (Step 4a: artifact validation fires — but agent is already inside)
ARTIFACT_VALIDATION_SECONDARY
    │
    ├── artifacts present → PLAN_CREATION_IN_PROGRESS
    └── artifacts missing → agent rationalizes bypass → PLAN_CREATION_IN_PROGRESS (ESCAPE HATCH)
```

**After fix:**
```
SPEC_CREATED_NO_ARTIFACTS
    │
    ├── Trigger Dispatch Table pre-check → BLOCKED_MISSING_ARTIFACTS (T1')
    └── pre-plan-readiness Step 4 → BLOCKED_MISSING_ARTIFACTS (T2')
    
SPEC_CREATED_WITH_ARTIFACTS
    │
    ▼ (pre-plan-readiness: checks spec file, branch, sync, AND artifacts)
PIPELINE_ENTRY  ←── Only reachable WITH artifacts
    │
    ▼ (Step 4a: secondary validation — defense-in-depth)
ARTIFACT_VALIDATION_SECONDARY
    │
    ├── artifacts present → PLAN_CREATION_IN_PROGRESS
    └── artifacts missing → PLAN_CREATION_FAILED (should never reach here)
```

The fix adds two blocking transitions (T1', T2') from `SPEC_CREATED_NO_ARTIFACTS` to `BLOCKED_MISSING_ARTIFACTS`, making `PIPELINE_ENTRY` unreachable from the no-artifacts state. The existing T5 (escape hatch) is eliminated because `ARTIFACT_VALIDATION_SECONDARY` is no longer reachable without artifacts.

---

## Defect Report

| Defect | Severity | Description |
|--------|----------|-------------|
| Gate placement defect | High | Artifact validation gate at Step 4a (inside pipeline) instead of entry point. Agent can enter pipeline without artifacts and rationalize bypass. |
| Missing transition guard | High | T1 (current) has no artifact guard — pre-plan-readiness passes for any spec with a file and branch, regardless of analytical depth. |
| Advisory language | Medium | Mandatory Task Discipline item 8 uses advisory language ("required before plan creation") instead of hard-gate language ("BLOCKED with MISSING_SPEC_ARTIFACT"). |

**All defects are addressed by the spec's 7 changes (SC-1 through SC-7).**
