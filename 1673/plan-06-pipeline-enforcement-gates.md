# Phase 06 — Pipeline Enforcement Gates

**Concern:** Add structural enforcement to the writing-plans pipeline to prevent Z3 check skipping, clean-room plan generation bypass, readiness gate self-certification, sub-agent output verification failures, and pipeline execution discipline violations.

**Files:**
- `.opencode/skills/writing-plans/tasks/create.md` — Operating Protocol (add Z3 contract paths, clean-room enforcement, sub-agent output verification, sequential ordering)
- `.opencode/skills/writing-plans/SKILL.md` — Mandatory Task Discipline (add pipeline enforcement rules)
- `.opencode/skills/writing-plans/contracts/` — 22 existing YAML contract files (reference correctly)

**SCs:** SC-22, SC-23, SC-24, SC-25, SC-26, SC-27, SC-28, SC-29

**Dependencies:** Phase 4 (same file — writing-plans SKILL.md and create.md)

**Entry conditions:** Phase 4 checkpoint committed, feature branch current

**Exit conditions:** All 8 SCs verified PASS

---

- [ ] 51. **Coherence gate (**clean-room**).** Read `.opencode/skills/writing-plans/tasks/create.md` Operating Protocol. Read `.opencode/skills/writing-plans/SKILL.md` Mandatory Task Discipline. Confirm current state: Z3 steps reference relative contract paths without full directory prefix, no clean-room enforcement, no readiness independence check, no sub-agent output verification, no todowrite/pipeline_phase/branch/commit/sync discipline, no sequential ordering mandate. **→ SC-22, SC-23, SC-24, SC-25, SC-26, SC-27, SC-28**

- [ ] 52. **Pre-red-baseline (**clean-room**).** Run `ls .opencode/skills/writing-plans/contracts/ | wc -l` (expect 22). Run `grep -c "contracts/" .opencode/skills/writing-plans/tasks/create.md` (expect 0 — no full paths). Run `grep -c "todowrite" .opencode/skills/writing-plans/SKILL.md` in Mandatory Task Discipline (expect 0). Record baselines. **→ SC-22, SC-27**

- [ ] 53. **RED: behavioral test for Z3 non-skip (**sub-agent**).** Write behavioral test at `.opencode/tests/behaviors/writing-plans-z3-non-skip.sh` that sends a plan creation prompt via `opencode-cli run` and asserts stderr shows `solve check` calls for each Z3 step. Run the test — it MUST FAIL (RED) because the pipeline currently skips Z3 checks. **→ SC-23, SC-29**

- [ ] 54. **GREEN: fix Z3 contract paths in create.md (**sub-agent**).** Edit `.opencode/skills/writing-plans/tasks/create.md`. For each of the 7 Z3 check steps (steps 3, 5, 7, 9, 12, 14, 16, 18, 20, 22), replace the relative contract path reference with the full path: `.opencode/skills/writing-plans/contracts/<task>-output-template.yaml:<section>`. For example, step 3's reference changes from `contracts/create-output-template.yaml:research` to `.opencode/skills/writing-plans/contracts/create-output-template.yaml:research`. **→ SC-22**

- [ ] 55. **GREEN: add clean-room plan enforcement (**sub-agent**).** Edit `.opencode/skills/writing-plans/tasks/create.md` Step 11 section. Add: "MANDATORY GATE — orchestrator MUST NOT proceed past Step 10 without dispatching Step 11. If Step 11 is skipped, the pipeline MUST halt. The clean-room sub-agent MUST receive ONLY the spec body — no existing plan context, no orchestrator reasoning." **→ SC-24**

- [ ] 56. **GREEN: add readiness gate independence check (**sub-agent**).** Edit `.opencode/skills/writing-plans/tasks/create.md` Step 4 section. Add: "INDEPENDENCE CHECK — The `sc-pipeline-readiness.yaml` file MUST be created by an independent sub-agent (pipeline-readiness-gate task), NOT by the orchestrator. If the file was created by the orchestrator (same session, no sub-agent dispatch), the gate MUST return BLOCKED. The orchestrator MUST NOT self-certify any gate." **→ SC-25**

- [ ] 57. **GREEN: add sub-agent output verification (**sub-agent**).** Edit `.opencode/skills/writing-plans/tasks/create.md`. Add a post-dispatch verification step after every sub-agent that claims to have written files: "POST-DISPATCH VERIFICATION — Run `ls <file-path>` or `./.opencode/tools/file-exists <file-path>` to confirm the file exists on disk. If the file does not exist, re-task clean-room with the same scoped context (do not accept the empty result)." **→ SC-26**

- [ ] 58. **GREEN: add pipeline execution discipline to Mandatory Task Discipline (**sub-agent**).** Edit `.opencode/skills/writing-plans/SKILL.md` Mandatory Task Discipline section. Add:
  - `todowrite` lifecycle MUST be maintained throughout pipeline execution (CREATE with status, UPDATE on transition, CLEAR before HALT)
  - `pipeline_phase` MUST be tracked and updated after each step
  - A feature branch MUST be created before any plan artifacts are written
  - Plan artifacts MUST be committed to the feature branch after creation
  - `local-issues sync` MUST be run before any `.issues/` writes and after each write **→ SC-27**

- [ ] 59. **GREEN: add sequential step ordering to create.md (**sub-agent**).** Edit `.opencode/skills/writing-plans/tasks/create.md` Operating Protocol. Add: "SEQUENTIAL STEP ORDERING — Every step with a chain dependency MUST execute sequentially. No parallel dispatch of chain-dependent steps. Each step's output is the next step's input. The 'sub-agent dispatch implies independence' rationalization is explicitly prohibited." **→ SC-28**

- [ ] 60. **GREEN doublecheck (**clean-room**).** Verify: `grep -c "contracts/" .opencode/skills/writing-plans/tasks/create.md` >= 7 (SC-22), `grep -q "MANDATORY GATE" .opencode/skills/writing-plans/tasks/create.md` in Step 11 (SC-24), `grep -q "INDEPENDENCE CHECK" .opencode/skills/writing-plans/tasks/create.md` in readiness section (SC-25), `grep -q "POST-DISPATCH VERIFICATION" .opencode/skills/writing-plans/tasks/create.md` (SC-26), `grep -q "todowrite" .opencode/skills/writing-plans/SKILL.md` in Mandatory Task Discipline (SC-27), `grep -q "SEQUENTIAL STEP ORDERING" .opencode/skills/writing-plans/tasks/create.md` (SC-28). **→ SC-22, SC-24, SC-25, SC-26, SC-27, SC-28**

- [ ] 61. **GREEN: re-run behavioral tests (**clean-room**).** Run the behavioral test from step 53. It MUST PASS (GREEN) now that the pipeline enforces Z3 checks. **→ SC-23, SC-29**

- [ ] 62. **Checkpoint commit (**inline**).** Commit: `git add .opencode/skills/writing-plans/tasks/create.md .opencode/skills/writing-plans/SKILL.md && git commit -m "Phase 6: Add pipeline enforcement gates"`. Create checkpoint tag. **→ SC-22, SC-23, SC-24, SC-25, SC-26, SC-27, SC-28, SC-29**

- [ ] 63. **VbC (**clean-room**).** Verify all 8 SCs: SC-22 (contract paths), SC-23 (behavioral test passes), SC-24 (mandatory gate), SC-25 (independence check), SC-26 (file verification), SC-27 (discipline rules), SC-28 (sequential ordering), SC-29 (Z3 non-skip behavioral test). **→ SC-22 through SC-29**

#### Phase 06 VbC

- [ ] 63. **VbC (**clean-room**).** Verify: SC-22 (contract paths in create.md), SC-23 (behavioral test passes), SC-24 (mandatory gate in Step 11), SC-25 (independence check in readiness), SC-26 (file verification post-dispatch), SC-27 (todowrite in Mandatory Task Discipline), SC-28 (sequential ordering in create.md), SC-29 (Z3 non-skip behavioral test passes). **→ SC-22 through SC-29**

**Concern transition:** Leaving pipeline enforcement gates → entering global post-steps. All 6 phases complete.
