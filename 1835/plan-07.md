# Phase 7 — Part B3: verification-before-completion Changes

**Concern:** Add analytical artifact coverage gates to verification-before-completion

**Files:**
- `.opencode/skills/verification-before-completion/tasks/verify.md` (MODIFY)
- `.opencode/skills/verification-before-completion/tasks/structural-verify.md` (MODIFY)
- `.opencode/skills/verification-before-completion/tasks/collect.md` (MODIFY)
- `.opencode/skills/verification-before-completion/tasks/operating-protocol.md` (MODIFY)

**SCs:** SC-32, SC-33, SC-34, SC-35

**Dependencies:** Phase 6

**Entry Criteria:** Phase 6 complete, writing-plans updated

**Exit Criteria:** All verification-before-completion task files include analytical artifact gates

## Step-by-Step

- [ ] 36. (**sub-agent**) Update `verify.md` — Add 5 new coverage gates (0.76-0.80): Blast Radius Coverage Gate, Concern Map Coverage Gate, Code Path Coverage Gate, Cross-Cutting Verification Gate, State Transition Coverage Gate. Each reads the corresponding artifact and verifies implementation coverage.
  - SC: SC-32

- [ ] 37. (**sub-agent**) Update `structural-verify.md` — Add 7 new component types to verification table: `blast_radius`, `concern_map`, `code_path_inventory`, `cross_cutting_matrix`, `interface_compatibility`, `state_analysis`, `testability_assessment`. Each checked for existence and valid YAML.
  - SC: SC-33

- [ ] 38. (**sub-agent**) Update `collect.md` — Add "Analytical Artifact Evidence Collection" section with procedures for collecting evidence that each analytical artifact's claims are satisfied by the implementation.
  - SC: SC-34

- [ ] 39. (**sub-agent**) Update `operating-protocol.md` — Add Step 1a (analytical artifact presence gate) and Step 1b (analytical artifact coverage gate). Add 7 new dispatch contract fields: same 7 artifact paths as spec-audit.
  - SC: SC-35

## Phase Completion

- [ ] verify.md includes 5 new coverage gates
- [ ] structural-verify.md includes 7 new component types
- [ ] collect.md includes analytical artifact evidence collection procedures
- [ ] operating-protocol.md includes analytical artifact presence and coverage gates

## Concern Transition

Phase 7 updates verification-before-completion. Phase 8 updates brainstorming.
