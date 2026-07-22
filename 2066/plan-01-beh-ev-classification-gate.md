# Phase 1 — BEH-EV classification gate

## Phase Metadata

| Field | Value |
|-------|-------|
| Concern | Add BEH-EV classification sub-steps to decompose.md step 3 |
| Files | `spec-creation-validation/tasks/decompose.md` |
| SCs | SC-1 |
| Dependencies | None |
| Entry | Spec approved, feature branch created |
| Exit | `decompose.md` step 3 has mandatory BEH-EV classification sub-steps with presumptive runtime-behavioral file types |

## Code Path Coverage

- `spec-creation-validation/tasks/decompose.md` step 3 — currently assigns evidence types. Extended with BEH-EV classification sub-steps.

## Cross-Cutting SCs

None — SC-1 is phase-local.

## Interface Boundaries

None — task file modification only.

## State Transitions

- decompose.md step 3: before → after (additive sub-steps, no existing logic changed)

## Step-by-step

- [ ] 1. Read `spec-creation-validation/tasks/decompose.md` to confirm current step 3 content
  - **SC:** SC-1
  - **Dispatch:** `spec-creation-validation`
  - **Expected:** Current step 3 reads "Assign evidence types to each SC"

- [ ] 2. Extend step 3 with BEH-EV classification sub-steps
  - **SC:** SC-1
  - **Action:** Replace step 3 with:
    ```
    - [ ] 3. Assign evidence types to each SC
      - [ ] 3a. For each SC, ask: "Does this change affect runtime behavior? YES/NO"
        - This is a substrate-determined question — the answer depends on what the change DOES, not what the author intended
      - [ ] 3b. Presumptive YES for files matching: `SKILL.md`, `tasks/*.md`, `guidelines/*.md`, `enforcement/*.md`
        - These files control agent behavior at runtime. Any SC modifying them is automatically behavioral.
      - [ ] 3c. If YES → evidence type is `behavioral` (mandatory uplift)
      - [ ] 3d. If NO → declared evidence type stands
      - [ ] 3e. Record classification in decomposition artifact: `{sc_id, classification: behavioral|declared, reason: "<substrate rationale>"}`
    ```
  - **Expected:** Step 3 now has 5 sub-steps (3a-3e) covering classification question, presumptive file types, uplift, and artifact recording

- [ ] 3. Verify modified `decompose.md` — confirm step 3 has BEH-EV sub-steps
  - **SC:** SC-1
  - **Action:** Read `decompose.md` step 3, confirm sub-steps 3a-3e present
  - **Expected:** Sub-steps 3a-3e present with correct content

## Phase Completion

- [ ] All steps in Phase 1 complete
- [ ] C1 verified: `decompose.md` step 3 has mandatory BEH-EV classification sub-steps

## Concern Transition to Phase 2

Phase 1 completes the classification gate. Phase 2 builds on this by adding the evaluator result contract field, orchestrator dispatch, and arbiter comparison — the downstream consumers of the classification.
