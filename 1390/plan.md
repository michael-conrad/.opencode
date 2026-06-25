# Implementation Plan — [#1390](https://github.com/michael-conrad/.opencode/issues/1390) — approval-gate Trigger Dispatch Table

Spec: #1390

- **Goal:** Add a formal Trigger Dispatch Table to `skills/approval-gate/SKILL.md` covering all routing conditions, and update the YAML frontmatter description to reflect the table's conditions with mandatory language and no narrative-only content.
- **Architecture:** Single-file edit to `skills/approval-gate/SKILL.md`. The existing file has a Trigger Dispatch Table with 10 rows. Add 5 missing rows (approval cascade, pipeline halt boundaries, label application, revision revocation, bug discovery protocol). Update the YAML frontmatter `description:` field to remove narrative-only content and add mandatory language.
- **Files:** `skills/approval-gate/SKILL.md`

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.
>
> **Cost-frame mandate:** Verification is measured in defect-discovery-latency, not execution time. A structural check costs ~1s but may take weeks to discover the defect it misses. A behavioral test costs minutes but catches defects at the earliest gate. Every verification decision is a choice between paying the bounded cost of a test (break) or accepting the exponential cost of downstream discovery (death spiral). Run every verification step — there is no valid cost-based exemption.

## Phase 1 — Add Trigger Dispatch Table rows and update description

- **Concern:** Add 5 missing Trigger Dispatch Table rows to `skills/approval-gate/SKILL.md` and update the YAML frontmatter description.
- **Files:** `skills/approval-gate/SKILL.md`
- **SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6
- **Dependencies:** None (single phase)
- **Entry:** Submodule `.opencode` checked out to `dev` branch, fresh feature branch created
- **Exit:** Plan written, changes implemented, verified, committed, submodule pointer updated
- **Z3 contract:** P1_I1_G1 (submodule reset), P1_I2_G1 (feature branch), P1_I3_G1 (RED), P1_I4_G1 (GREEN add rows), P1_I5_G1 (GREEN doublecheck rows), P1_I6_G1 (GREEN update description), P1_I7_G1 (GREEN doublecheck description), P1_I8_G1 (checkpoint commit), P1_I9_G1 (submodule pointer), P1_I10_G1 (VbC). Invariant: P1_I{N}_G1 → P1_I{N-1}_G1 (serial ordering). No preconditions.

- [ ] 1. **Submodule reset (**inline**).** Verify `.opencode` submodule is on `dev` branch. If on a feature branch, run `cd .opencode && git checkout dev && git pull`.
   - `cd .opencode && git branch --show-current` — expect `dev`
   - `cd .opencode && git status` — expect clean
   **→ SC-1, SC-2**

- [ ] 2. **Feature branch (**inline**).** Create fresh feature branch from submodule dev.
   - `cd .opencode && git checkout -b feature/1390-approval-gate-trigger-dispatch-table dev`
   **→ SC-1, SC-2**

- [ ] 3. **RED — Verify absence (**inline**).** Confirm the 5 target rows are NOT present.
   - `grep -c 'approval-cascade\|pipeline-halt\|apply-label\|revision-revocation\|bug-discovery-protocol' skills/approval-gate/SKILL.md` — expect 0
   **→ SC-1, SC-2, SC-3**

- [ ] 4. **GREEN — Add 5 Trigger Dispatch Table rows (**clean-room**).** Task a clean-room sub-agent to add 5 rows to the existing Trigger Dispatch Table in `skills/approval-gate/SKILL.md`:
   - Row: approval cascade → `approval-cascade` → `sub-task` → `{parent_issue, sub_issues}`
   - Row: pipeline halt boundary → `check-halt-boundary` → `sub-task` → `{authorization_scope, halt_at, pipeline_phase}`
   - Row: apply label → `apply-label` → `sub-task` → `{issue_number, authorization_scope}`
   - Row: revision revocation → `revision-revocation` → `sub-task` → `{spec_issue, plan_issue}`
   - Row: bug discovery protocol → `bug-discovery-protocol` → `sub-task` → `{issue_number, bug_description}`
   - Insert after the `"verify already implemented"` row, before the `completion` row
   **→ SC-1, SC-2, SC-3**

- [ ] 5. **GREEN doublecheck — Verify rows (**clean-room**).** Task a clean-room sub-agent to verify:
   - All 5 new rows are present in the table
   - Each row has valid User says / Context, Task, Dispatch, and Context passed columns
   - The table follows the standard format used by all other skills
   - No existing rows were removed or modified
   **→ SC-1, SC-2, SC-3**

- [ ] 6. **GREEN — Update YAML frontmatter description (**clean-room**).** Task a clean-room sub-agent to update the `description:` field in the YAML frontmatter to:
   - Reflect all table conditions (approval cascade, pipeline halt boundaries, label application, revision revocation, bug discovery protocol)
   - Use mandatory language (e.g., "All conditions are mandatory — no implementation without authorization")
   - Remove any narrative-only sentences
   **→ SC-4, SC-5, SC-6**

- [ ] 7. **GREEN doublecheck — Description verification (**clean-room**).** Task a clean-room sub-agent to verify:
   - Description reflects all table conditions (SC-4)
   - Description contains mandatory language (SC-5)
   - Description contains no narrative-only sentences (SC-6)
   **→ SC-4, SC-5, SC-6**

- [ ] 8. **Checkpoint commit (**inline**).** Commit the changes to the submodule feature branch.
   - `cd .opencode && git add skills/approval-gate/SKILL.md && git commit -m "feat(#1390): add 5 Trigger Dispatch Table rows and update description"`
   **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**

- [ ] 9. **Update submodule pointer (**inline**).** In the parent repo, stage and commit the submodule pointer update.
   - `git add .opencode && git commit -m "fix(#1390): update submodule pointer"`
   **→ SC-1, SC-2**

#### Phase 1 VbC

- [ ] 10. **VbC (**clean-room**).** Verify all 6 SCs: SC-1 (table exists), SC-2 (standard format), SC-3 (covers all routing conditions), SC-4 (description reflects table), SC-5 (mandatory language), SC-6 (no narrative-only). **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Exit Criteria

- C1: `skills/approval-gate/SKILL.md` contains a formal Trigger Dispatch Table with 15 rows (10 existing + 5 new)
- C2: Table follows the standard format (User says / Context, Task, Dispatch, Context passed)
- C3: Table covers all routing conditions: authorization scope checking, approval cascade, pipeline halt boundaries, label application, spec-to-plan cascade, revision revocation, bug discovery protocol
- C4: Description reflects all table conditions
- C5: Description contains mandatory language
- C6: Description contains no narrative-only sentences
- C7: Submodule feature branch committed with changes
- C8: Parent repo submodule pointer updated
- C9: Pre-RED baseline confirmed — dev branch lacks the 5 target rows
- C10: Post-RED enforcement passed — no implementation code written during RED phase
- C11: Post-GREEN enforcement passed — test files unchanged during GREEN phase
- C12: Structural checks (lint/typecheck) pass on modified file
- C13: Adversarial audit passed — dual cross-family auditor consensus on all SCs
- C14: Cross-validation passed — auditor artifacts reconciled
- C15: Regression check passed — no existing behavior broken
- C16: Review-prep completed — PR body, compare URL, reviewer context ready
