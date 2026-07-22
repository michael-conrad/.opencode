# Phase 2 — Evaluator result contract + orchestrator dispatch + arbiter comparison

## Phase Metadata

| Field | Value |
|-------|-------|
| Concern | Add `needs_clean_room` to evaluator contracts, orchestrator dispatch, arbiter comparison |
| Files | `audit/tasks/behavioral-sc-evaluator.md`, `audit/tasks/cross-validate.md`, 9 `audit/tasks/*-evaluator.md` files |
| SCs | SC-2, SC-3, SC-4 |
| Dependencies | Phase 1 |
| Entry | Phase 1 complete |
| Exit | All 9 evaluator contracts carry `needs_clean_room`, behavioral-sc-evaluator has dispatch entry, cross-validate receives clean-room results |

## Code Path Coverage

- 9 evaluator files: `spec-audit-evaluator.md`, `verification-audit-evaluator.md`, `plan-fidelity-evaluator.md`, `content-audit-evaluator.md`, `drift-detection-evaluator.md`, `coherence-maintenance-evaluator.md`, `test-quality-audit-evaluator.md`, `concern-separation-evaluator.md`, `guideline-audit-evaluator.md`
- `audit/tasks/behavioral-sc-evaluator.md` — orchestrator dispatch entry point
- `audit/tasks/cross-validate.md` — clean-room result reception and comparison

## Cross-Cutting SCs

None — all SCs are phase-local.

## Interface Boundaries

- Evaluator result contract: `needs_clean_room` field is read by orchestrator, not by other evaluators
- `behavioral-sc-evaluator.md`: orchestrator dispatch entry point is called by orchestrator, not by other task files
- `cross-validate.md`: receives clean-room results alongside evaluator verdict

## State Transitions

- Evaluator result contracts: before → after (additive `needs_clean_room` field)
- `behavioral-sc-evaluator.md`: before → after (additive dispatch entry point)
- `cross-validate.md`: before → after (additive clean-room comparison step)

## Step-by-step

- [ ] 4. Add `needs_clean_room` field to all 9 evaluator result contracts
  - **SC:** SC-2
  - **Action:** For each of the 9 `audit/tasks/*-evaluator.md` files, add `needs_clean_room: [SC-IDs]` to the Result Contract section. The field is a list of SC IDs that require clean-room evaluation (populated by the evaluator at runtime based on which SCs are behavioral).
  - **Files:**
    - `spec-audit-evaluator.md`
    - `verification-audit-evaluator.md`
    - `plan-fidelity-evaluator.md`
    - `content-audit-evaluator.md`
    - `drift-detection-evaluator.md`
    - `coherence-maintenance-evaluator.md`
    - `test-quality-audit-evaluator.md`
    - `concern-separation-evaluator.md`
    - `guideline-audit-evaluator.md`
  - **Expected:** Each evaluator's Result Contract section includes `needs_clean_room: [SC-IDs]` field

- [ ] 5. Verify `needs_clean_room` field in all 9 evaluator files
  - **SC:** SC-2
  - **Action:** Grep each of the 9 files for `needs_clean_room`
  - **Expected:** All 9 files contain `needs_clean_room` in their Result Contract section

- [ ] 6. Read `audit/tasks/behavioral-sc-evaluator.md` to confirm current content
  - **SC:** SC-3
  - **Action:** Read the file to understand its current structure
  - **Expected:** File exists with clean-room evaluation procedure (from #2064)

- [ ] 7. Add orchestrator dispatch entry point to `behavioral-sc-evaluator.md`
  - **SC:** SC-3
  - **Action:** Add a "Dispatch Contract" section at the top (after the Purpose section) specifying:
    - `artifact_evidence_dir`: Path to directory containing behavioral test artifacts (stdout.log, stderr.log)
    - `sc_ids`: List of SC IDs to evaluate
    - `spec_local_dir`: Local directory containing spec files for SC reference
  - **Expected:** `behavioral-sc-evaluator.md` has a Dispatch Contract section with `artifact_evidence_dir`, `sc_ids`, and `spec_local_dir`

- [ ] 8. Read `audit/tasks/cross-validate.md` to confirm current content
  - **SC:** SC-4
  - **Action:** Read the file to understand its current structure
  - **Expected:** File exists with cross-validate checklist and procedure

- [ ] 9. Add clean-room result reception and comparison logic to `cross-validate.md`
  - **SC:** SC-4
  - **Action:** Add a new step after the existing "Load upstream verdict artifacts" step:
    ```
    - [ ] 3a. Load clean-room evaluation results
      - Read `behavioral-sc-evaluation.yaml` from `{artifact_evidence_dir}/behavioral-sc-evaluation.yaml`
      - If file exists: extract per-SC verdicts
      - If file does not exist: all behavioral SCs default to FAIL with `MISSING_CLEAN_ROOM_EVALUATION`
    - [ ] 3b. Compare evaluator verdict vs. clean-room verdict for each SC
      - For each SC in `needs_clean_room`:
        - If evaluator verdict == clean-room verdict → consensus (use that verdict)
        - If evaluator verdict != clean-room verdict → report CONFLICT, use FAIL as the safe default
        - If clean-room verdict is MISSING → use evaluator verdict with `NO_CLEAN_ROOM` flag
    ```
  - **Expected:** `cross-validate.md` has steps 3a and 3b for clean-room result reception and comparison

- [ ] 10. Verify all Phase 2 changes
  - **SC:** SC-2, SC-3, SC-4
  - **Action:** Read each modified file and confirm changes are correct
  - **Expected:** All 9 evaluators have `needs_clean_room`, behavioral-sc-evaluator has dispatch contract, cross-validate has clean-room comparison steps

## Phase Completion

- [ ] All steps in Phase 2 complete
- [ ] C2 verified: All 9 evaluator result contracts carry `needs_clean_room: [SC-IDs]` field
- [ ] C3 verified: `behavioral-sc-evaluator.md` has orchestrator dispatch entry point
- [ ] C4 verified: `cross-validate.md` receives both evaluator verdict and clean-room results
- [ ] C5 verified: All modified files pass markdown lint
- [ ] C6 verified: All modified files pass markdown format check
