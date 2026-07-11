# Cross-Cutting Analysis — Issue #1885

**Generated: 2026-07-11**
**Spec: [SPEC-FIX] Close artifact gate bypass escape hatch in writing-plans skill**

## Unit Inventory

| Unit ID | Unit | Description | Phase |
|---------|------|-------------|-------|
| U1 | Change 1: Trigger Dispatch Table | Add artifact pre-check to "create plan" entry in writing-plans SKILL.md | Phase 1 |
| U2 | Change 2: pre-plan-readiness task | Add artifact check procedure step to pre-plan-readiness.md | Phase 1 |
| U3 | Change 3: SKILL.md Entry Criteria | Add analytical artifact requirement to Entry Criteria section | Phase 1 |
| U4 | Change 4: Mandatory Task Discipline item 8 | Elevate item 8 from advisory to hard gate (BLOCKED) | Phase 1 |
| U5 | Change 5: spec-to-plan handoff | Add artifact validation check to handoff manifest | Phase 1 |
| U6 | Change 6: Critical-rules entry | Add Tier 2 critical-rules entry prohibiting artifact gate bypass | Phase 1 |
| U7 | Change 7: Behavioral enforcement test | New behavioral test verifying agent does NOT bypass artifact gate | Phase 2 |

## Cross-Cutting Concern Inventory

### CC-1: Artifact Name Consistency

**Classification:** Cross-cutting (appears in 5 of 7 units)
**Uniformity:** Identical — all 7 artifact names must match across all entry points
**Centralization:** None — each entry point independently references the artifact names; no central registry exists

**Description:** All 5 Phase 1 changes must reference the same 7 analytical artifact names (blast-radius, concern-map, code-path-inventory, cross-cutting-matrix, interface-compatibility, state-analysis, testability-assessment). A typo or omission in any one entry point creates a bypass — the agent can claim "artifact X is not listed in the check, so it's not required."

**Propagation Map:**

| Stage | Unit | How Concern Manifests |
|-------|------|----------------------|
| Entry | U1 (TDT) | TDT "create plan" entry must list all 7 artifact names in its pre-check |
| Entry | U2 (pre-plan-readiness) | pre-plan-readiness procedure must check for all 7 artifact names |
| Entry | U3 (Entry Criteria) | Entry Criteria must declare all 7 artifacts as prerequisites |
| Entry | U4 (Item 8) | Item 8 must reference all 7 artifacts in its hard-gate declaration |
| Entry | U5 (handoff) | Handoff manifest must validate all 7 artifacts |
| Exit | U6 (critical-rules) | Critical-rules entry must reference the same 7 artifact names |

**Handling Strategy:** All 5 entry-point changes must use the identical list of 7 artifact names. The behavioral test (U7) must verify that a missing artifact from this list produces BLOCKED. No central registry exists — consistency is enforced by the behavioral test and cross-reference audit.

### CC-2: Gate Placement (Entry-Point vs. In-Pipeline)

**Classification:** Cross-cutting (appears in 4 of 7 units)
**Uniformity:** Identical — all gates must fire at entry point, not inside pipeline
**Centralization:** None — each gate is independently positioned

**Description:** The core defect being fixed: the artifact validation gate fires at Step 4a (inside the pipeline) rather than at the entry point. All Phase 1 changes must ensure the gate fires before pipeline entry. The Step 4a gate remains as a secondary validation but must never be the primary gate.

**Propagation Map:**

| Stage | Unit | How Concern Manifests |
|-------|------|----------------------|
| Entry | U1 (TDT) | TDT pre-check fires before dispatch to `create` — blocks pipeline entry |
| Entry | U2 (pre-plan-readiness) | pre-plan-readiness fires before pipeline entry — blocks pipeline entry |
| Entry | U3 (Entry Criteria) | Entry Criteria declare prerequisites that must be met before pipeline entry |
| Entry | U4 (Item 8) | Item 8 declares hard gate at entry point, not inside pipeline |
| Secondary | Step 4a (readiness) | Existing artifact check remains as secondary validation — must NOT be removed |

**Handling Strategy:** Every gate must be positioned at the entry point (TDT, pre-plan-readiness, Entry Criteria, Item 8). The Step 4a gate is preserved as a secondary validation but is never the primary gate. The behavioral test (U7) verifies the agent is blocked at entry, not at Step 4a.

### CC-3: Hard-Gate Enforcement (Advisory → BLOCKED)

**Classification:** Cross-cutting (appears in 3 of 7 units)
**Uniformity:** Identical — all gates use BLOCKED with MISSING_SPEC_ARTIFACT
**Centralization:** Item 8 (U4) is the canonical declaration; other units enforce it

**Description:** The artifact gate must be a hard gate (BLOCKED), not advisory. Advisory language ("required before plan creation") is treated as optional by agents. Hard-gate language ("BLOCKED with MISSING_SPEC_ARTIFACT") is a hard stop.

**Propagation Map:**

| Stage | Unit | How Concern Manifests |
|-------|------|----------------------|
| Canonical | U4 (Item 8) | Item 8 declares the hard-gate rule: "Missing artifacts produce BLOCKED with MISSING_SPEC_ARTIFACT" |
| Enforcer | U1 (TDT) | TDT pre-check returns BLOCKED on missing artifacts |
| Enforcer | U2 (pre-plan-readiness) | pre-plan-readiness returns BLOCKED with MISSING_SPEC_ARTIFACT |
| Enforcer | U5 (handoff) | Handoff manifest returns BLOCKED on missing artifacts |

**Handling Strategy:** Item 8 is the canonical declaration. All enforcement points (TDT, pre-plan-readiness, handoff) use the same BLOCKED status and MISSING_SPEC_ARTIFACT reason code. The behavioral test (U7) verifies the agent returns BLOCKED, not a warning.

### CC-4: Behavioral Enforcement (TDD Cycle)

**Classification:** Cross-cutting (appears in 2 of 7 units, spans both phases)
**Uniformity:** Identical — behavioral TDD cycle (RED → GREEN)
**Centralization:** U7 (behavioral test) is the enforcement mechanism

**Description:** The fix changes agent dispatch/routing behavior. Per `080-code-standards.md`, behavioral evidence is PRIMARY for rule-changing specs. The behavioral test must be RED first (proving the gap exists), then GREEN (proving the change closed it).

**Propagation Map:**

| Stage | Unit | How Concern Manifests |
|-------|------|----------------------|
| RED | U7 (behavioral test) | Test sends prompt to create plan for spec without artifacts; agent currently proceeds; test asserts BLOCKED; test FAILS (RED) |
| GREEN | U1-U6 (all Phase 1 changes) | File changes implement the artifact gate at entry points |
| GREEN | U7 (behavioral test) | Re-run test; agent now returns BLOCKED; test PASSES (GREEN) |

**Handling Strategy:** The behavioral test (U7) is the PRIMARY enforcement gate. String evidence (grep) confirms rule text exists; behavioral evidence confirms agent behavior. The TDD cycle is enforced by SC-8: test must be RED before any implementation begins.

### CC-5: Error Handling / BLOCKED Protocol Consistency

**Classification:** Cross-cutting (appears in 3 of 7 units)
**Uniformity:** Identical — all gates use the same BLOCKED protocol
**Centralization:** Item 8 (U4) defines the protocol; other units implement it

**Description:** All artifact validation gates must use a consistent BLOCKED protocol: `status: BLOCKED` with `reason: MISSING_SPEC_ARTIFACT`. Inconsistent reason codes create ambiguity — the agent may not recognize a BLOCKED from one gate as the same condition as a BLOCKED from another.

**Propagation Map:**

| Stage | Unit | How Concern Manifests |
|-------|------|----------------------|
| Protocol | U4 (Item 8) | Defines BLOCKED protocol: `status: BLOCKED, reason: MISSING_SPEC_ARTIFACT` |
| Implementer | U1 (TDT) | TDT pre-check returns BLOCKED with MISSING_SPEC_ARTIFACT |
| Implementer | U2 (pre-plan-readiness) | pre-plan-readiness returns BLOCKED with MISSING_SPEC_ARTIFACT |
| Implementer | U5 (handoff) | Handoff manifest returns BLOCKED with MISSING_SPEC_ARTIFACT |

**Handling Strategy:** All gates use the identical BLOCKED protocol. The behavioral test (U7) verifies the agent recognizes and respects the BLOCKED signal.

### CC-6: Bylines and Attribution

**Classification:** Cross-cutting (appears in all 7 units)
**Uniformity:** Identical — AI co-authored attribution on all modified files
**Centralization:** `080-code-standards.md` defines the attribution format

**Description:** All modified files (SKILL.md, pre-plan-readiness.md, spec-to-plan.md, 000-critical-rules.md, behavioral test) must include AI co-authored attribution per `080-code-standards.md`. Existing bylines must be preserved; new bylines appended.

**Propagation Map:**

| Stage | Unit | How Concern Manifests |
|-------|------|----------------------|
| All | U1-U7 | Each modified file must preserve existing bylines and append new byline |

**Handling Strategy:** Per `080-code-standards.md` §Preserve Existing Bylines: never overwrite a prior agent's byline. Append new byline on a new line following existing byline(s). New files use the format specified per file type.

## Concern-to-Phase Matrix

| Cross-Cutting Concern | Phase 1 (File Changes) | Phase 2 (Behavioral Test) | Handling Strategy |
|-----------------------|------------------------|---------------------------|-------------------|
| CC-1: Artifact Name Consistency | ✅ (U1, U2, U3, U4, U5, U6) | ✅ (U7 verifies consistency) | All entry points use identical 7-artifact list; behavioral test verifies |
| CC-2: Gate Placement | ✅ (U1, U2, U3, U4) | ✅ (U7 verifies entry-point blocking) | Gates fire at entry point; Step 4a preserved as secondary |
| CC-3: Hard-Gate Enforcement | ✅ (U1, U2, U4, U5) | ✅ (U7 verifies BLOCKED, not warning) | Item 8 is canonical; all enforcers use BLOCKED + MISSING_SPEC_ARTIFACT |
| CC-4: Behavioral Enforcement | ❌ | ✅ (U7 is the enforcement mechanism) | RED/GREEN TDD cycle; behavioral test is PRIMARY |
| CC-5: BLOCKED Protocol Consistency | ✅ (U1, U2, U4, U5) | ✅ (U7 verifies protocol recognition) | All gates use identical BLOCKED protocol |
| CC-6: Bylines and Attribution | ✅ (U1-U6) | ✅ (U7) | Preserve existing bylines; append new byline per file type |

## Coverage Verification

| Check | Result |
|-------|--------|
| All 7 units accounted for in concern inventory | ✅ U1-U7 all appear in at least one cross-cutting concern |
| All cross-cutting concerns have a handling strategy | ✅ CC-1 through CC-6 all have documented strategies |
| All cross-cutting concerns mapped to phases | ✅ Concern-to-phase matrix complete |
| No cross-cutting concern missed | ✅ All recurring patterns classified |
| Coincidental patterns distinguished from cross-cutting concerns | ✅ No coincidental patterns identified — all 6 concerns are genuine cross-cutting |

## Coincidental Pattern Check

| Pattern | Appears In | Classification | Rationale |
|---------|-----------|----------------|-----------|
| Markdown file format | U1-U7 | Coincidental | All changes are to markdown files — this is a shared implementation detail, not a concern |
| `.opencode/` path prefix | U1-U6 | Coincidental | All files are under `.opencode/` — this is a project structure detail, not a concern |
| `grep` verification method | SC-1 through SC-6 | Coincidental | All string-evidence SCs use grep — this is a verification tool choice, not a concern |
