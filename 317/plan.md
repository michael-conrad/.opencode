# Implementation Plan — [.opencode#317](https://github.com/michael-conrad/.opencode/issues/317) — Add filesystem-root guards to walk-up root detection loops

**Spec:** [#317](https://github.com/michael-conrad/.opencode/issues/317)

**Goal:** Add filesystem-root guard to all 26 scripts with canonical walk-up pattern, preventing infinite loop when `.opencode/` is unreachable.

**Architecture:** Insert guard check (`if parent == current → fatal error`) into the walk-up loop of each script, after `PARENT="$(dirname "$PROJECT_DIR")"` / `parent = _path.parent` and before `PROJECT_DIR="$PARENT"` / `_path = parent`.

**Files (26 total):**
- G1: 2 bash scripts (`tools/detect-secrets-wrapper.sh`, `tools/ensure-node`)
- G2: 12 Python PEP 723 tools (`tools/guidelines`, `tools/md`, `tools/py`, `tools/file-exists`, `tools/session-init`, `tools/help`, `tools/jupyter`, `tools/jupyter-start`, `tools/jupyter-stop`, `tools/skildeck`, `tools/plan`, `tools/solve`)
- G3: 8 Python PEP 723 impl scripts (`tools/impl/guidelines-read`, `tools/impl/guidelines-show`, `tools/impl/guidelines-search`, `tools/impl/guidelines-edit`, `tools/impl/jupyter-start`, `tools/impl/jupyter-stop`, `tools/impl/py-ls`, `tools/impl/py-mkpkg`)
- G4: 4 Python scripts (`scripts/session_context_triggers.py`, `skills/issue-operations/platforms/gitbucket-api/tests/verify_api.py`, `skills/issue-operations/platforms/gitbucket-api/tests/test_pr_idempotency.py`, `tests/regressions/regression-91-verify-structure.py`)
- SC-5 reference: `tools/local-issues` (existing guard — verify unchanged)

> **Compliance requirement:** This plan MUST be executed in strict dependency order. Each step depends on the prior step completing successfully. No step may be skipped, reordered, or combined. If any step fails, halt and report the failure. Do not proceed past a failed step.

> **One-step-at-a-time protocol:** Execute exactly one step at a time. After each step, verify the result before proceeding to the next. Do not batch steps, do not skip ahead, do not combine multiple steps into one action. Each numbered step is an atomic unit of work.

> **Step Status:** Before each step, update the step status in the issue body to `in_progress`. After each step, update to `completed`. This provides traceability and enables resumption after interruption.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range |
|-------|------|---------|-----|--------------|------------|
| 1 | Add filesystem-root guards | Insert root-guard into 26 walk-up scripts | SC-1, SC-2, SC-3, SC-4, SC-5 | None (single phase) | 1–17 |

## Phase 1 — Add filesystem-root guards

**Concern:** Insert filesystem-root guard into all 26 scripts with canonical walk-up pattern.

**Files:** G1 (2 bash), G2 (12 Python tools), G3 (8 Python impl), G4 (4 Python scripts), plus `tools/local-issues` for SC-5 verification.

**SCs:** SC-1 (14 shell scripts — actually 2 bash + 12 Python tools), SC-2 (8 shell impl — actually 8 Python impl), SC-3 (4 Python scripts), SC-4 (consistent guard pattern), SC-5 (local-issues guard unchanged)

**Dependencies:** None.

**Entry condition:** All 26 files exist and have canonical walk-up pattern without root-guard. `tools/local-issues` has existing root-guard.

**Exit condition:** All 26 files have root-guard inserted. SC-4 grep passes. SC-5 local-issues guard verified unchanged.

---

### Pre-phase

- [ ] 1. **Pre-phase: Verify all 26 files exist (**inline**).** Confirm every file in G1, G2, G3, G4 is present and readable. Verify `tools/local-issues` exists. **→ SC-1, SC-2, SC-3, SC-5**

- [ ] 2. **Pre-phase: Verify tools/local-issues has existing root-guard (**inline**).** Grep for `parent == _path` or `PARENT = "$PROJECT_DIR"` guard pattern in `tools/local-issues`. Record the guard line(s) for SC-5 comparison. **→ SC-5**

- [ ] 3. **Pre-phase: Verify all 26 files lack root-guard (**inline**).** Grep each file for the guard pattern. Confirm absence (guard not yet inserted). If any file already has a guard, flag for review. **→ SC-1, SC-2, SC-3, SC-4**

### G1: Bash scripts (2 files)

- [ ] 4. **G1 RED: Write behavioral test for 2 bash scripts (**sub-agent**).** Create `./tmp/behavioral-evidence-SC-1-bash.sh` that executes each of the 2 bash scripts outside the `.opencode/` tree and asserts FATAL error exit. Test MUST FAIL (scripts lack guard). **→ SC-1**

- [ ] 5. **G1 GREEN: Insert root-guard into 2 bash scripts (**sub-agent**).** For each of the 2 G1 files, insert the guard after `PARENT="$(dirname "$PROJECT_DIR")"` and before `PROJECT_DIR="$PARENT"`:
   ```bash
   if [ "$PARENT" = "$PROJECT_DIR" ]; then
       echo "FATAL: Could not find .opencode/ directory" >&2
       exit 1
   fi
   ```
   **→ SC-1, SC-4**

- [ ] 6. **G1 GREEN doublecheck: Verify guard insertion (**inline**).** Grep each of the 2 G1 files for the guard pattern. Confirm both have the guard. **→ SC-1, SC-4**

- [ ] 7. **G1 Checkpoint commit (**inline**).** Commit G1 changes with message: `Add filesystem-root guard to 2 bash scripts [.opencode#317]`. **→ SC-1**

### G2: Python PEP 723 tools (12 files)

- [ ] 8. **G2 RED: Write behavioral test for 12 Python tools (**sub-agent**).** Create `./tmp/behavioral-evidence-SC-1-python-tools.sh` that runs each of the 12 Python tools outside the `.opencode/` tree and asserts RuntimeError. Test MUST FAIL. **→ SC-1**

- [ ] 9. **G2 GREEN: Insert root-guard into 12 Python tools (**sub-agent**).** For each of the 12 G2 files, insert the guard after `parent = _path.parent` and before `_path = parent`:
   ```python
   if parent == _path:
       raise RuntimeError("Could not find .opencode/ directory")
   ```
   **→ SC-1, SC-4**

- [ ] 10. **G2 GREEN doublecheck: Verify guard insertion (**inline**).** Grep each of the 12 G2 files for the guard pattern. Confirm all 12 have the guard. **→ SC-1, SC-4**

- [ ] 11. **G2 Checkpoint commit (**inline**).** Commit G2 changes with message: `Add filesystem-root guard to 12 Python tools [.opencode#317]`. **→ SC-1**

### G3: Python PEP 723 impl scripts (8 files)

- [ ] 12. **G3 RED: Write behavioral test for 8 Python impl scripts (**sub-agent**).** Create `./tmp/behavioral-evidence-SC-2.sh` that runs each of the 8 Python impl scripts outside the `.opencode/` tree and asserts RuntimeError. Test MUST FAIL. **→ SC-2**

- [ ] 13. **G3 GREEN: Insert root-guard into 8 Python impl scripts (**sub-agent**).** For each of the 8 G3 files, insert the same Python guard pattern after `parent = _path.parent` and before `_path = parent`. **→ SC-2, SC-4**

- [ ] 14. **G3 GREEN doublecheck: Verify guard insertion (**inline**).** Grep each of the 8 G3 files for the guard pattern. Confirm all 8 have the guard. **→ SC-2, SC-4**

- [ ] 15. **G3 Checkpoint commit (**inline**).** Commit G3 changes with message: `Add filesystem-root guard to 8 Python impl scripts [.opencode#317]`. **→ SC-2**

### G4: Python scripts (4 files)

- [ ] 16. **G4 RED: Write behavioral test for 4 Python scripts (**sub-agent**).** Create `./tmp/behavioral-evidence-SC-3.sh` that runs each of the 4 Python scripts outside the `.opencode/` tree and asserts RuntimeError. Test MUST FAIL. **→ SC-3**

- [ ] 17. **G4 GREEN: Insert root-guard into 4 Python scripts (**sub-agent**).** For each of the 4 G4 files, insert the same Python guard pattern after `parent = _path.parent` and before `_path = parent`. **→ SC-3, SC-4**

- [ ] 18. **G4 GREEN doublecheck: Verify guard insertion (**inline**).** Grep each of the 4 G4 files for the guard pattern. Confirm all 4 have the guard. **→ SC-3, SC-4**

- [ ] 19. **G4 Checkpoint commit (**inline**).** Commit G4 changes with message: `Add filesystem-root guard to 4 Python scripts [.opencode#317]`. **→ SC-3**

### Post-phase

- [ ] 20. **Post-phase: Verify SC-4 — consistent guard pattern (**inline**).** Grep all 26 files for the canonical guard pattern. Confirm every file uses the exact canonical form. Report any deviations. **→ SC-4**

- [ ] 21. **Post-phase: Verify SC-5 — local-issues guard unchanged (**inline**).** Grep `tools/local-issues` for the guard pattern. Compare against the pre-phase recording from step 2. Confirm guard is present and identical. **→ SC-5**

#### Phase 1 VbC

- [ ] 22. **VbC (**clean-room**).** Run behavioral tests from steps 4, 8, 12, 16 (now MUST PASS). Run SC-4 grep across all 26 files. Run SC-5 guard comparison. Collect evidence artifacts into `./tmp/behavioral-evidence-*/`. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

---

> **Compliance requirement:** This plan MUST be executed in strict dependency order. Each step depends on the prior step completing successfully. No step may be skipped, reordered, or combined. If any step fails, halt and report the failure. Do not proceed past a failed step.

> **Self-remediation protocol:** If any step fails, the agent MUST diagnose the root cause, fix the issue, and re-run the step before proceeding. Do not skip failed steps. Do not mark failed steps as complete. If remediation requires changes outside the current step's scope, halt and report the blocker.

## Self-Review Evidence

- [ ] Plan covers all 5 SCs from spec #317
- [ ] All 26 files correctly classified (2 bash, 12 Python tools, 8 Python impl, 4 Python scripts)
- [ ] Guard patterns match spec's canonical forms (bash: `if [ "$PARENT" = "$PROJECT_DIR" ]`, Python: `if parent == _path`)
- [ ] Pre-phase verifies file existence and guard absence before RED/GREEN
- [ ] Post-phase verifies SC-4 (consistent pattern) and SC-5 (local-issues unchanged)
- [ ] VbC step runs behavioral tests and collects evidence artifacts
- [ ] 4 checkpoint commits provide rollback points per group
- [ ] Step ordering: pre-phase → G1 → G2 → G3 → G4 → post-phase → VbC

## Exit Criteria

- [ ] C1: All 2 G1 bash scripts have root-guard (SC-1)
- [ ] C2: All 12 G2 Python tools have root-guard (SC-1)
- [ ] C3: All 8 G3 Python impl scripts have root-guard (SC-2)
- [ ] C4: All 4 G4 Python scripts have root-guard (SC-3)
- [ ] C5: Guard pattern is consistent across all 26 files (SC-4)
- [ ] C6: `tools/local-issues` existing root-guard is unchanged (SC-5)
- [ ] C7: Behavioral tests PASS for all 4 groups
- [ ] C8: All changes committed with descriptive messages
