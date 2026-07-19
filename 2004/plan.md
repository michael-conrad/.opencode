# Plan: writing-plans skill holistic remediation — 9 defect categories

**Issue:** [#2004](https://github.com/michael-conrad/.opencode/issues/2004)
**Spec:** [SPEC] writing-plans skill holistic remediation — 9 defect categories
**Authorization scope:** `for_pr` (label: `approved-for-pr`)
**Plan type:** Multi-phase (3 phases)

## Goal

Apply the #1993 remediation pattern to writing-plans: remove fake dispatch entries, move pipeline definition to SKILL.md, delete operating-protocol.md, fix artifact extension mismatches, remove task()/skill() calls from task cards, add contract index, fix pipeline numbering, remove orphan handoffs/spec-to-plan dispatch, fix {project_root}/tmp/ references, replace hard-coded counts with Load [Text](path) references, and replace bare-path cross-references with Load [Text](path) format.

## Architecture

All affected files are under `.opencode/skills/writing-plans/`, `.opencode/skills/writing-plans-creation/`, and `.opencode/skills/writing-plans-holistic/` in the `.opencode` submodule. Changes are purely structural/documentation — no behavioral changes to the pipeline steps themselves.

## Affected Files

| File | Phase | Change |
|------|-------|--------|
| `skills/writing-plans/SKILL.md` | 1, 2 | Remove 4 fake dispatch entries; update Invocation; add Pipeline section; fix numbering; fix cross-refs |
| `skills/writing-plans-creation/tasks/create.md` | 1, 2 | Remove pipeline definition (moved to SKILL.md); remove task()/skill() calls; fix cross-refs |
| `skills/writing-plans-creation/tasks/operating-protocol.md` | 1 | Delete file; content moved to SKILL.md |
| `skills/writing-plans-creation/tasks/clean-room.md` | 1, 2 | Remove task()/skill() calls; fix {project_root}/tmp/ refs; fix cross-refs |
| `skills/writing-plans-creation/tasks/write.md` | 1, 2 | Remove task()/skill() references; fix {project_root}/tmp/ refs; fix cross-refs |
| `skills/writing-plans-creation/tasks/validate.md` | 1, 2 | Remove task()/skill() references; fix cross-refs |
| `skills/writing-plans-creation/tasks/retroactive.md` | 1 | Remove task() calls (dispatch strings) |
| `skills/writing-plans-creation/tasks/completion.md` | 1 | Remove task() call |
| `skills/writing-plans-creation/tasks/research.md` | 1 | Remove skill() call |
| `skills/writing-plans-creation/tasks/revisit.md` | 1 | Remove skill() call |
| `skills/writing-plans-creation/tasks/audit-fidelity.md` | 1 | Remove skill() call |
| `skills/writing-plans-creation/tasks/audit-concern.md` | 1 | Remove skill() call |
| `skills/writing-plans-creation/tasks/update.md` | 1 | Remove task() call |
| `skills/writing-plans-creation/tasks/pre-plan-readiness.md` | 2 | Fix artifact extensions (.md → .yaml) |
| `skills/writing-plans-creation/tasks/handoffs/spec-to-plan.md` | 2 | Delete or merge; fix artifact extensions; fix {project_root}/tmp/ refs |
| `skills/writing-plans-creation/contracts/INDEX.md` | 2 | Create new file mapping 22 templates to consuming steps |
| `skills/writing-plans-creation/SKILL.md` | 2 | Remove handoffs/ and operating-protocol.md from Tasks list |
| `.opencode/tests-v2/behaviors/writing-plans-dispatch.sh` | 3 | Create new behavioral test |

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | Trigger Dispatch Table has only 3 real entry points | 1 | 1.1, 1.2 |
| SC-2 | Invocation section has 4 dispatch strings | 1 | 1.3 |
| SC-3 | No task()/skill() in task cards | 1 | 1.5 |
| SC-4 | Pipeline definition moved to SKILL.md | 1 | 1.7 |
| SC-5 | operating-protocol.md deleted | 1 | 1.9 |
| SC-6 | contracts/INDEX.md exists | 2 | 2.1 |
| SC-7 | Artifact extensions as .yaml | 2 | 2.3 |
| SC-8 | Pipeline numbering consistent | 2 | 2.5 |
| SC-9 | handoffs/spec-to-plan removed | 2 | 2.7 |
| SC-10 | No {project_root}/tmp/ references | 2 | 2.9 |
| SC-11 | No hard-coded step counts or contract paths | 2 | 2.11 |
| SC-14 | All cross-references use Load [Text](path) | 2 | 2.13 |
| SC-12 | Behavioral test for 3 dispatch entry points | 3 | 3.1 |
| SC-13 | No SC weakened/deferred | All | N/A (enforced by guidelines) |

## Safety/Rollback Considerations

**Phase 1 — Safety/Rollback:**
- Destructive operations: Delete `operating-protocol.md`; modify SKILL.md, create.md, and 8 task cards
- Rollback plan: `git checkout -- skills/writing-plans/SKILL.md skills/writing-plans-creation/tasks/create.md skills/writing-plans-creation/tasks/operating-protocol.md` and all modified task cards
- Data loss risk: low (all changes are text edits; operating-protocol.md content is preserved in SKILL.md)

**Phase 2 — Safety/Rollback:**
- Destructive operations: Delete or merge `handoffs/spec-to-plan.md`; create `contracts/INDEX.md`; modify 4 task cards
- Rollback plan: `git checkout --` on modified files; `git rm` on INDEX.md if created; restore handoffs/spec-to-plan.md from git if deleted
- Data loss risk: low (handoffs/spec-to-plan.md content is merged into pre-plan-readiness.md before deletion)

**Phase 3 — Safety/Rollback:**
- Destructive operations: None (new file creation only)
- Rollback plan: `git rm .opencode/tests-v2/behaviors/writing-plans-dispatch.sh`
- Data loss risk: none

## Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1.1 | `skills/writing-plans/SKILL.md` | ✅ | `ls` confirmed |
| 1.2 | `skills/writing-plans/SKILL.md` Trigger Dispatch Table | ✅ | `read` confirmed |
| 1.3 | `skills/writing-plans/SKILL.md` Invocation section | ✅ | `read` confirmed |
| 1.4 | `skills/writing-plans-creation/tasks/*.md` | ✅ | `glob` confirmed 18 task files |
| 1.5 | `skills/writing-plans-creation/tasks/create.md` | ✅ | `read` confirmed |
| 1.6 | `skills/writing-plans-creation/tasks/operating-protocol.md` | ✅ | `read` confirmed |
| 2.1 | `skills/writing-plans-creation/contracts/` | ✅ | `glob` confirmed 22 templates |
| 2.2 | `skills/writing-plans-creation/tasks/pre-plan-readiness.md` | ✅ | `read` confirmed |
| 2.3 | `skills/writing-plans/SKILL.md` and `create.md` | ✅ | `read` confirmed |
| 2.4 | `skills/writing-plans-creation/tasks/handoffs/spec-to-plan.md` | ✅ | `read` confirmed |
| 2.5 | `skills/writing-plans-creation/tasks/clean-room.md`, `handoffs/spec-to-plan.md` | ✅ | `grep` confirmed 6 matches |
| 2.6 | All task cards under `writing-plans-creation/tasks/` | ✅ | `grep` confirmed 16 matches |
| 2.7 | All task cards under `writing-plans-creation/tasks/` | ✅ | `grep` confirmed 26 bare-path refs |
| 3.1 | `.opencode/tests-v2/behaviors/` | ✅ | `ls` confirmed directory exists |

## Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| SKILL.md has 7 dispatch entries (3 real + 4 fake) | `read` of Trigger Dispatch Table | ✅ |
| Invocation has 5 dispatch strings | `read` of Invocation section | ✅ |
| 22 contract templates exist | `glob` of contracts/ | ✅ |
| 18 task files under writing-plans-creation/tasks/ | `glob` of tasks/ | ✅ |
| 22 task()/skill() matches in task cards | `grep` for `task(|skill(` | ✅ |
| 6 {project_root}/tmp/ matches | `grep` for `{project_root}/tmp/` | ✅ |
| 16 hard-coded count/contract-path matches | `grep` for `21-step|22-step|create-output-template` | ✅ |
| 26 bare-path cross-reference matches | `grep` for `skills/|guidelines/|contracts/` minus `Load [` | ✅ |
| pre-plan-readiness.md uses .md extensions for artifacts | `read` confirmed | ✅ |
| handoffs/spec-to-plan.md uses .md extensions for artifacts | `read` confirmed | ✅ |
| operating-protocol.md delegates to SKILL.md | `read` confirmed | ✅ |

---

# Phase 1 — SKILL.md restructuring (SC-1 through SC-5)

**Concern:** Remove fake dispatch entries, clean Invocation, remove task()/skill() from task cards, move pipeline to SKILL.md, delete operating-protocol.md

**Files:** `skills/writing-plans/SKILL.md`, `skills/writing-plans-creation/tasks/create.md`, `skills/writing-plans-creation/tasks/operating-protocol.md`, `skills/writing-plans-creation/tasks/clean-room.md`, `skills/writing-plans-creation/tasks/write.md`, `skills/writing-plans-creation/tasks/validate.md`, `skills/writing-plans-creation/tasks/retroactive.md`, `skills/writing-plans-creation/tasks/completion.md`, `skills/writing-plans-creation/tasks/research.md`, `skills/writing-plans-creation/tasks/revisit.md`, `skills/writing-plans-creation/tasks/audit-fidelity.md`, `skills/writing-plans-creation/tasks/audit-concern.md`, `skills/writing-plans-creation/tasks/update.md`

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5

**Dependencies:** None

---

- [ ] 1.1. (**sub-agent**) Remove 4 fake dispatch entries from Trigger Dispatch Table in `skills/writing-plans/SKILL.md` — remove rows for `retroactive`, `handoffs/spec-to-plan`, `pre-plan-readiness`, and `completion`. Keep only `create`, `update`, `holistic-self-check`. Update the Tasks section to list only `create`, `update`, `holistic-self-check`. **→ SC-1**

- [ ] 1.2. (**inline**) Verify SC-1 — `grep -c '| `' skills/writing-plans/SKILL.md | grep -c 'sub-task'` returns exactly 3

- [ ] 1.3. (**sub-agent**) Update Invocation section in `skills/writing-plans/SKILL.md` — remove dispatch strings for `retroactive` and `pre-plan-readiness`. Keep only `create`, `update`, `completion`, `holistic-self-check` (4 total). **→ SC-2**

- [ ] 1.4. (**inline**) Verify SC-2 — `grep -c 'task(..., prompt:' skills/writing-plans/SKILL.md` returns exactly 4

- [ ] 1.5. (**sub-agent**) Remove all `task()` and `skill()` calls from task cards under `writing-plans-creation/tasks/` and `writing-plans-holistic/tasks/`. Affected files: `clean-room.md` (2 matches), `write.md` (2 matches), `validate.md` (1 match), `retroactive.md` (9 matches), `completion.md` (1 match), `research.md` (1 match), `revisit.md` (1 match), `audit-fidelity.md` (1 match), `audit-concern.md` (1 match), `update.md` (1 match), `create.md` (1 match). Replace with descriptive text about what the orchestrator does (e.g., "The orchestrator dispatches this step via the SKILL.md Trigger Dispatch Table"). **→ SC-3**

- [ ] 1.6. (**inline**) Verify SC-3 — `grep -rn 'task()\|skill()' skills/writing-plans-*/tasks/ --include='*.md'` returns zero matches

- [ ] 1.7. (**sub-agent**) Move pipeline definition from `create.md` to `writing-plans/SKILL.md`. In `create.md`, remove the 22-step pipeline section (Steps 1-22 under "Operating Protocol — 21-Step Pipeline") and replace with a `Load [Pipeline](skills/writing-plans/SKILL.md)` reference. In `writing-plans/SKILL.md`, add a Pipeline section containing the full step list, dispatch mode, and contract table from `create.md`. **→ SC-4**

- [ ] 1.8. (**inline**) Verify SC-4 — confirm `skills/writing-plans/SKILL.md` contains a Pipeline section with step list; confirm `create.md` references the SKILL.md pipeline

- [ ] 1.9. (**sub-agent**) Delete `operating-protocol.md` task card. Its content (which already delegates to SKILL.md via `Load [Text](path)` references) is already covered by the Pipeline section added to SKILL.md in step 1.7. Remove `operating-protocol.md` from the Tasks list in `writing-plans-creation/SKILL.md`. **→ SC-5**

- [ ] 1.10. (**inline**) Verify SC-5 — confirm `operating-protocol.md` no longer exists; confirm SKILL.md contains the operating protocol content

---

# Phase 2 — Artifact and reference cleanup (SC-6 through SC-11, SC-14)

**Concern:** Create contract index, fix artifact extensions, fix numbering, remove orphan handoffs, fix tmp/ refs, replace hard-coded counts, fix cross-references

**Files:** `skills/writing-plans-creation/contracts/INDEX.md` (new), `skills/writing-plans-creation/tasks/pre-plan-readiness.md`, `skills/writing-plans-creation/tasks/handoffs/spec-to-plan.md`, `skills/writing-plans/SKILL.md`, `skills/writing-plans-creation/tasks/create.md`, `skills/writing-plans-creation/tasks/clean-room.md`, `skills/writing-plans-creation/tasks/write.md`, `skills/writing-plans-creation/tasks/structure.md`, `skills/writing-plans-creation/tasks/readiness.md`, `skills/writing-plans-creation/tasks/retroactive.md`, `skills/writing-plans-creation/tasks/artifact-validation.md`, `skills/writing-plans-creation/SKILL.md`, all task cards under `writing-plans-creation/tasks/`

**SCs:** SC-6, SC-7, SC-8, SC-9, SC-10, SC-11, SC-14

**Dependencies:** Phase 1

---

- [ ] 2.1. (**sub-agent**) Create `contracts/INDEX.md` mapping all 22 contract templates to their consuming pipeline steps. Each entry: template filename → consuming step name(s) (e.g., `research-input-template.yaml` → `research`, `research-output-template.yaml` → `research`). **→ SC-6**

- [ ] 2.2. (**inline**) Verify SC-6 — confirm `contracts/INDEX.md` exists with entries for all 22 templates

- [ ] 2.3. (**sub-agent**) Fix artifact extension mismatches in `pre-plan-readiness.md` and `handoffs/spec-to-plan.md`. Change all 7 analytical artifact references from `.md` to `.yaml` (e.g., `blast-radius.md` → `blast-radius.yaml`). **→ SC-7**

- [ ] 2.4. (**inline**) Verify SC-7 — `grep -c '\.yaml' skills/writing-plans-creation/tasks/pre-plan-readiness.md` confirms `.yaml` references for analytical artifacts

- [ ] 2.5. (**sub-agent**) Fix pipeline numbering inconsistency. `skills/writing-plans/SKILL.md` says "22-step" but `create.md` has 21 steps. Change SKILL.md's "22-step" references to "21-step" to match create.md. Update the Overview section and Operating Protocol section. **→ SC-8**

- [ ] 2.6. (**inline**) Verify SC-8 — confirm SKILL.md and create.md both reference "21-step"

- [ ] 2.7. (**sub-agent**) Remove `handoffs/spec-to-plan` dispatch entry from Trigger Dispatch Table (already done in Phase 1 if SC-1 was completed). Merge content of `handoffs/spec-to-plan.md` into `pre-plan-readiness.md` (the readiness gate already covers spec validation). Delete `handoffs/spec-to-plan.md`. Remove `handoffs/` from Tasks list in `writing-plans-creation/SKILL.md`. **→ SC-9**

- [ ] 2.8. (**inline**) Verify SC-9 — confirm no dispatch entry for `handoffs/spec-to-plan` in SKILL.md; confirm `handoffs/spec-to-plan.md` is deleted

- [ ] 2.9. (**sub-agent**) Fix `{project_root}/tmp/` references in `clean-room.md` and `handoffs/spec-to-plan.md`. Replace with `.issues/{N}/` paths. In `clean-room.md`: change `{project_root}/tmp/{issue-N}/artifacts/clean-room-N.md` to `.issues/{issue-N}/artifacts/clean-room-N.md`. In `handoffs/spec-to-plan.md`: change `{project_root}/tmp/{issue-N}/artifacts/spec-to-plan-handoff-*.yaml` to `.issues/{issue-N}/artifacts/spec-to-plan-handoff-*.yaml`. Also fix the `{project_root}/tmp/behavioral-evidence-*` reference in `write.md` line 118. **→ SC-10**

- [ ] 2.10. (**inline**) Verify SC-10 — `grep -rn '{project_root}/tmp/' skills/writing-plans-*/tasks/ --include='*.md'` returns zero matches

- [ ] 2.11. (**sub-agent**) Replace hard-coded step counts and contract paths with `Load [Text](path)` references. In all task cards: replace "21-step pipeline" with `Load [Pipeline](skills/writing-plans/SKILL.md)`; replace contract paths like `contracts/create-output-template.yaml:research` with `Load [contracts](contracts/INDEX.md)`. **→ SC-11**

- [ ] 2.12. (**inline**) Verify SC-11 — `grep -rn '21-step\|22-step\|create-output-template' skills/writing-plans-*/tasks/ --include='*.md'` returns zero matches

- [ ] 2.13. (**sub-agent**) Replace all bare-path cross-references with `Load [Text](path)` format across all task cards under `writing-plans-creation/tasks/`. Affected patterns: `skills/implementation-pipeline/SKILL.md` → `Load [the Trigger Dispatch Table](skills/implementation-pipeline/SKILL.md)`; `guidelines/065-verification-honesty.md` → `Load [065-verification-honesty.md](guidelines/065-verification-honesty.md)`; `contracts/validate-output-template.yaml` → `Load [validate output contract](contracts/INDEX.md)`; bare `contracts/` references → `Load [contracts](contracts/INDEX.md)`. **→ SC-14**

- [ ] 2.14. (**inline**) Verify SC-14 — `grep -rn 'skills/\|guidelines/\|contracts/' skills/writing-plans-*/tasks/ --include='*.md' | grep -v 'Load \['` returns zero bare-path references

---

# Phase 3 — Behavioral enforcement (SC-12)

**Concern:** Create behavioral test verifying reduced dispatch set

**Files:** `.opencode/tests-v2/behaviors/writing-plans-dispatch.sh` (new)

**SCs:** SC-12

**Dependencies:** Phase 1, Phase 2

---

- [ ] 3.1. (**sub-agent**) Create behavioral enforcement test at `.opencode/tests-v2/behaviors/writing-plans-dispatch.sh`. The test sends a prompt that triggers the writing-plans skill and verifies the agent dispatches only 3 workflow entry points (create, update, holistic-self-check), not 7. Use `assert_semantic` for the behavioral assertion (clean-room AI inspector judges agent actions). Use `assert_stderr_pattern_present` as secondary corroboration for tool dispatch strings. **→ SC-12**

- [ ] 3.2. (**inline**) Verify SC-12 — run `bash .opencode/tests-v2/behaviors/writing-plans-dispatch.sh` and confirm PASS

---

## Exit Criteria

- [ ] C1. Plan index stored at `.opencode/.issues/2004/plan.md` with phase table
- [ ] C2. Phase files stored at `.opencode/.issues/2004/plan-01.md`, `plan-02.md`, `plan-03.md`
- [ ] C3. All SCs verified PASS (SC-1 through SC-14)
- [ ] C4. SC-13 enforced by existing anti-lobotomization guidelines — no SC weakened/deferred/downgraded
- [ ] C5. All implementation-pipeline gate steps enumerated in exit criteria
- [ ] C6. Step numbering is globally sequential across all phases
- [ ] C7. Phase exit criteria for behavioral SCs (SC-12) include both `behavior_run` artifact generation AND `behavioral-test-evaluation` clean-room dispatch steps
- [ ] C8. Each SC in exit criteria carries `evidence_type` metadata annotation
- [ ] C9. VbC section for behavioral SCs includes mandatory gate: after artifact generation, dispatch `behavioral-test-evaluation` before allowing PASS verdict
- [ ] C10. Plan reported in chat with `.opencode/.issues/2004/plan.md` path
- [ ] C11. Approval cascade applied (auto-approval for `for_pr` scope)
