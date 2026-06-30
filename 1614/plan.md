# Implementation Plan — [.opencode#1614](https://github.com/michael-conrad/.opencode/issues/1614) — Split plan files: plan.md index + plan-{O}.md phase files

**Goal:** Replace the monolithic `plan.md` with a split format: `plan.md` (index with phase table) + `plan-{NN}-{slug}.md` (one per phase, globally sequential steps). Update all cross-referencing skills to read the split format. Fix completion/validate tasks to check local files instead of GitHub API.

**Architecture:** The plan file convention changes from `{N}/plan.md` (all phases inline) to `{N}/plan.md` (index only) + `{N}/plan-{NN}-{slug}.md` (one per phase). The index holds goal/architecture/files, phase table, exit criteria, and admonishments. Each phase file holds phase metadata, full step-by-step with global sequential numbering, dispatch indicators, RED/GREEN chains, VbC blocks, and concern transitions. All cross-referencing skills that read `plan.md` must be updated to read the index first, then the relevant phase file.

**Files:**

| # | File | Change |
|---|------|--------|
| 1 | `.opencode/skills/writing-plans/SKILL.md` | §Plan Model: phases are separate `plan-{O}.md` files |
| 2 | `.opencode/skills/writing-plans/tasks/create.md` | Exit criteria, plan path references |
| 3 | `.opencode/skills/writing-plans/tasks/write.md` | Produce `plan.md` index + N `plan-{O}.md` phase files |
| 4 | `.opencode/skills/writing-plans/tasks/completion.md` | Check local `plan-{O}.md` files instead of GitHub API sub-issues |
| 5 | `.opencode/skills/writing-plans/tasks/validate.md` | Step 9: replace `github_issue_read(method=get_sub_issues)` with local file glob |
| 6 | `.opencode/skills/writing-plans/tasks/update.md` | Plan path references |
| 7 | `.opencode/skills/writing-plans/tasks/revisit.md` | Plan path references |
| 8 | `.opencode/skills/writing-plans/tasks/audit-fidelity.md` | Plan path references |
| 9 | `.opencode/skills/writing-plans/tasks/audit-concern.md` | Plan path references |
| 10 | `.opencode/skills/writing-plans/tasks/clean-room.md` | Plan path references |
| 11 | `.opencode/skills/implementation-pipeline/tasks/pre-red-baseline.md` | Read `plan.md` for phase table, then `plan-{O}.md` for current phase |
| 12 | `.opencode/skills/implementation-pipeline/tasks/assemble-work.md` | Plan path references |
| 13 | `.opencode/skills/implementation-pipeline/tasks/pre-flight-handoff.md` | Plan path references |
| 14 | `.opencode/skills/adversarial-audit/tasks/plan-fidelity.md` | Read `plan.md` index + all `plan-{O}.md` for full audit |
| 15 | `.opencode/skills/plan-creation-pipeline/SKILL.md` | Plan artifact path references |
| 16 | `.opencode/guidelines/140-planning-spec-creation.md` | Plan file path references |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One-step-at-a-time protocol:** Each numbered step is a single unit of work. The orchestrator completes step N, reports completion to chat, then proceeds to step N+1. Steps MUST NOT be combined, batched, or executed in parallel.

> **Step Status instruction:** When reporting progress in chat, use the following format with exactly one status marker per step:
>
> | Marker | Meaning |
> |--------|---------|
> | ✅ | Step completed |
> | 🔄 | Step currently being worked on |
> | ⏳ | Step not yet started |
>
> **Format:**
> ```
> ✅ Step 1 — Title
> 🔄 Step 2 — Title
> ⏳ Step 3 — Title
> ```
>
> **Edge case rules:**
> - Omit the ✅ column entirely when no steps are completed (all steps are 🔄 or ⏳)
> - Omit the ⏳ column entirely when the current step is the last step (no steps remain)
> - Exactly one step MUST be marked 🔄 at any time
> - The 🔄 marker moves to the next step only after the current step's verification passes

---

## Phase 1 — writing-plans SKILL.md: Plan Model Update

**Concern:** Update the Plan Model section in writing-plans/SKILL.md to describe the split file convention.

**Files:** `.opencode/skills/writing-plans/SKILL.md`

**SCs:** SC-4

**Dependencies:** None

**Entry:** Phase 1 starts

**Exit:** SKILL.md §Plan Model describes `plan.md` + `plan-{O}.md` convention

- [ ] 1. **RED (**sub-agent**).** Write a behavioral enforcement test that verifies the SKILL.md Plan Model section references `plan.md` + `plan-{NN}-{slug}.md` format. Test MUST FAIL because the current text says "Phases are sections in the local plan file." **→ SC-4**
- [ ] 2. **GREEN (**sub-agent**).** Edit `.opencode/skills/writing-plans/SKILL.md` §Plan Model (line 52-55). Change from:
      ```
      **All plans are local artifacts.** Plans are stored at `.issues/{N}/plan.md` (root repo) or `*/.issues/{N}/plan.md` (submodule/sub-repo). Phases are sections in the local plan file.
      
      - **Separate (multi-task):** `.issues/{N}/plan.md` or `*/.issues/{N}/plan.md` with stand-alone phase sections, each with concern boundary annotations
      - **Combined (single-task):** `.issues/{N}/plan.md` or `*/.issues/{N}/plan.md` referencing spec content inline
      ```
      To:
      ```
      **All plans are local artifacts.** Plans use a split file convention:
      
      - **Index:** `.issues/{N}/plan.md` (root repo) or `*/.issues/{N}/plan.md` (submodule/sub-repo) — contains goal, architecture, file list, phase table, exit criteria, and admonishments. No implementation steps.
      - **Phase files:** `.issues/{N}/plan-{NN}-{short-slug}.md` (root repo) or `*/.issues/{N}/plan-{NN}-{short-slug}.md` (submodule/sub-repo) — one per phase, with globally sequential step numbering. `{NN}` is zero-padded phase number, `{short-slug}` is a descriptive slug.
      
      - **Separate (multi-task):** `.issues/{N}/plan.md` index + `.issues/{N}/plan-01-*.md` through `.issues/{N}/plan-0N-*.md` phase files
      - **Combined (single-task):** `.issues/{N}/plan.md` index + `.issues/{N}/plan-01-*.md` (single phase file)
      ```
      **→ SC-4**
- [ ] 3. **GREEN doublecheck (**clean-room**).** Verify the edit is correct: read SKILL.md §Plan Model, confirm split convention is described. **→ SC-4**
- [ ] 4. **Checkpoint commit (**inline**).** `git add .opencode/skills/writing-plans/SKILL.md && git commit -m "writing-plans SKILL.md: update Plan Model to split file convention"`

---

## Phase 2 — writing-plans write.md: Produce Split Format

**Concern:** Update the write task to produce `plan.md` index + N `plan-{O}.md` phase files instead of a single monolithic file.

**Files:** `.opencode/skills/writing-plans/tasks/write.md`

**SCs:** SC-1, SC-4

**Dependencies:** Phase 1 (Plan Model convention defined)

**Entry:** Phase 1 complete

**Exit:** write.md procedure produces `plan.md` index + `plan-{NN}-{slug}.md` per phase

- [ ] 5. **RED (**sub-agent**).** Write a behavioral enforcement test: create a multi-phase plan using the write task, verify `plan.md` exists with phase table, verify `plan-01-*.md` through `plan-0N-*.md` exist with globally sequential steps. Test MUST FAIL because write task still produces monolithic format. **→ SC-1**
- [ ] 6. **GREEN (**sub-agent**).** Edit `.opencode/skills/writing-plans/tasks/write.md`:
      - **Step 1:** Change "write plan header to `.issues/{N}/plan.md`" to "write plan index to `.issues/{N}/plan.md`" — index contains Goal, Architecture, Files, Phase Table, Exit Criteria, Admonishments. No implementation steps.
      - **Step 2:** Change "write each phase section" to "write each phase as a separate `plan-{NN}-{slug}.md` file" — each phase file contains phase metadata, full step-by-step with global sequential numbering, dispatch indicators, RED/GREEN chains, VbC blocks, concern transition.
      - **§Plan Format Requirements:** Update "Required Sections" to reflect split: sections 1-5, 7-10 go in `plan.md` index; phase sections (section 6) go in `plan-{NN}-{slug}.md` files.
      - **§Three-Tier Plan Structure:** Update to reflect that Tier 1 (global) and Tier 2 (per-phase) are in separate files.
      - **§Phase Completion Block:** Update to reference `plan-{NN}-{slug}.md` file.
      - **§Concern Transition:** Update to reference `plan-{NN}-{slug}.md` file.
      - **§Exit Criteria:** Update to reference `plan.md` index.
      - **§Validation Rules:** Add rule: "Phase files follow naming convention `plan-{NN}-{slug}.md` with zero-padded phase numbers."
      - **§Prohibited Patterns:** Add: "No implementation steps in `plan.md` index — steps live in phase files only."
      **→ SC-1, SC-4**
- [ ] 7. **GREEN doublecheck (**clean-room**).** Verify the edit: read write.md, confirm all references to monolithic `plan.md` are replaced with split format. **→ SC-1, SC-4**
- [ ] 8. **Checkpoint commit (**inline**).** `git add .opencode/skills/writing-plans/tasks/write.md && git commit -m "writing-plans write.md: produce plan.md index + plan-{NN}-{slug}.md phase files"`

---

## Phase 3 — writing-plans completion.md: Local File Check

**Concern:** Update completion task to check local `plan-{O}.md` files instead of GitHub API sub-issues.

**Files:** `.opencode/skills/writing-plans/tasks/completion.md`

**SCs:** SC-2, SC-4

**Dependencies:** Phase 1 (Plan Model convention defined)

**Entry:** Phase 1 complete

**Exit:** completion.md checks local `plan-{O}.md` files, not GitHub API

- [ ] 9. **RED (**sub-agent**).** Write a behavioral enforcement test: run completion on a multi-phase plan with all phase files present → PASS; with a missing phase file → BLOCKED. Test MUST FAIL because completion still checks GitHub API. **→ SC-2**
- [ ] 10. **GREEN (**sub-agent**).** Edit `.opencode/skills/writing-plans/tasks/completion.md`:
       - **Step 1 (State Check Phase):** Change "Verify plan file exists at `.issues/{N}/plan.md`" to "Verify plan index exists at `.issues/{N}/plan.md` and all phase files exist at `.issues/{N}/plan-{NN}-*.md`"
       - **Step 2 (State Check Phase):** Remove "Sub-issues created: For multi-task plans, verify sub-issues created under the plan" — plans are local artifacts, sub-issues are never created for plan phases.
       - **Step 1 (Skill-Specific Completion):** Change "Check evidence for plan file at `.issues/{N}/plan.md`" to "Check evidence for plan index at `.issues/{N}/plan.md` and all phase files at `.issues/{N}/plan-{NN}-*.md`"
       - **Step 2 (Skill-Specific Completion):** Remove "Sub-issues (if multi-task and not already created)" — plans are local artifacts.
       - **§Completion Guarantee:** Update plan path references.
       **→ SC-2, SC-4**
- [ ] 11. **GREEN doublecheck (**clean-room**).** Verify the edit: read completion.md, confirm no remaining GitHub API sub-issue references. **→ SC-2, SC-4**
- [ ] 12. **Checkpoint commit (**inline**).** `git add .opencode/skills/writing-plans/tasks/completion.md && git commit -m "writing-plans completion.md: check local plan-{NN}-*.md files instead of GitHub API"`

---

## Phase 4 — writing-plans validate.md: Local File Check

**Concern:** Update validate task Step 9 to check local files instead of GitHub API.

**Files:** `.opencode/skills/writing-plans/tasks/validate.md`

**SCs:** SC-3, SC-4

**Dependencies:** Phase 1 (Plan Model convention defined)

**Entry:** Phase 1 complete

**Exit:** validate.md Step 9 checks local `plan-{O}.md` files, not GitHub API

- [ ] 13. **RED (**sub-agent**).** Write a string enforcement test: `grep 'github_issue_read.*get_sub_issues'` on validate.md returns zero matches. Test MUST FAIL because the pattern still exists. **→ SC-3**
- [ ] 14. **GREEN (**sub-agent**).** Edit `.opencode/skills/writing-plans/tasks/validate.md`:
       - **Step 9:** Replace:
         ```
         - [ ] 09. (**inline**) Sub-issue parent — If plan has sub-issues, they link to the plan (not the spec)
           - Command: `github_issue_read(method=get_sub_issues, issue_number=plan_number)`
           - SC: All
           - Expected: sub-issues linked to plan, not spec
         ```
         With:
         ```
         - [ ] 09. (**inline**) Phase file completeness — All phase files exist for the plan
           - Command: `ls .issues/{N}/plan-*.md 2>/dev/null | wc -l`
           - SC: All
           - Expected: at least one phase file exists
         ```
       - **Step 10:** Update to check for `plan.md` index + `plan-{NN}-*.md` files.
       - **§Live Verification:** Update the "Sub-issues link to plan" row to reference local file glob instead of GitHub API.
       - **§Finding Classification:** Update "Sub-issues under wrong parent" to "Missing phase files".
       **→ SC-3, SC-4**
- [ ] 15. **GREEN doublecheck (**clean-room**).** Verify the edit: `grep 'github_issue_read.*get_sub_issues'` on validate.md returns zero matches. **→ SC-3, SC-4**
- [ ] 16. **Checkpoint commit (**inline**).** `git add .opencode/skills/writing-plans/tasks/validate.md && git commit -m "writing-plans validate.md: replace GitHub API sub-issue check with local file glob"`

---

## Phase 5 — writing-plans create.md: Plan Path References

**Concern:** Update create.md exit criteria and plan path references to reflect split format.

**Files:** `.opencode/skills/writing-plans/tasks/create.md`

**SCs:** SC-4

**Dependencies:** Phase 1 (Plan Model convention defined)

**Entry:** Phase 1 complete

**Exit:** create.md references split format

- [ ] 17. **RED (**sub-agent**).** Write a structural enforcement test: `grep -c 'plan-[0-9]'` on create.md returns expected count after update. Test MUST FAIL because references are to monolithic `plan.md`. **→ SC-4**
- [ ] 18. **GREEN (**sub-agent**).** Edit `.opencode/skills/writing-plans/tasks/create.md`:
       - **§Exit Criteria:** Change "Plan stored at `.issues/{N}/plan.md`" to "Plan index stored at `.issues/{N}/plan.md` with phase files at `.issues/{N}/plan-{NN}-*.md`"
       - **§Plan Format:** Update to reference write.md's split format specification.
       - **§Context Required:** Update plan path references.
       **→ SC-4**
- [ ] 19. **GREEN doublecheck (**clean-room**).** Verify the edit: read create.md, confirm all plan path references use split format. **→ SC-4**
- [ ] 20. **Checkpoint commit (**inline**).** `git add .opencode/skills/writing-plans/tasks/create.md && git commit -m "writing-plans create.md: update plan path references to split format"`

---

## Phase 6 — writing-plans update.md, revisit.md, audit-fidelity.md, audit-concern.md, clean-room.md: Plan Path References

**Concern:** Update remaining writing-plans task files to reference split format.

**Files:** `.opencode/skills/writing-plans/tasks/update.md`, `revisit.md`, `audit-fidelity.md`, `audit-concern.md`, `clean-room.md`

**SCs:** SC-4

**Dependencies:** Phase 1 (Plan Model convention defined)

**Entry:** Phase 1 complete

**Exit:** All 5 task files reference `plan.md` + `plan-{O}.md` convention

- [ ] 21. **RED (**sub-agent**).** Write a structural enforcement test: `grep -c 'plan-[0-9]'` on each of the 5 files returns expected count. Test MUST FAIL because references are to monolithic `plan.md`. **→ SC-4**
- [ ] 22. **GREEN (**sub-agent**).** Edit all 5 files in parallel:
       - **update.md:** Change all `.issues/{N}/plan.md` references to note the split format. Update Step 2 to read `plan.md` index and relevant `plan-{NN}-*.md` phase files. Update Step 4 to edit the correct phase file.
       - **revisit.md:** Change `.issues/{N}/plan.md` references to note the split format. Update to scan `plan.md` index + all `plan-{NN}-*.md` phase files for `⚠️ UNVERIFIED` markers.
       - **audit-fidelity.md:** Change `.issues/{N}/plan.md` references to note the split format. Update to pass `plan.md` index + all `plan-{NN}-*.md` phase files to the audit.
       - **audit-concern.md:** Change `.issues/{N}/plan.md` references to note the split format. Update to pass `plan.md` index + all `plan-{NN}-*.md` phase files to the audit.
       - **clean-room.md:** Change `.issues/{N}/plan.md` references to note the split format. Update §Key Differences to reference split format.
       **→ SC-4**
- [ ] 23. **GREEN doublecheck (**clean-room**).** Verify all 5 files: read each, confirm plan path references use split format. **→ SC-4**
- [ ] 24. **Checkpoint commit (**inline**).** `git add .opencode/skills/writing-plans/tasks/update.md .opencode/skills/writing-plans/tasks/revisit.md .opencode/skills/writing-plans/tasks/audit-fidelity.md .opencode/skills/writing-plans/tasks/audit-concern.md .opencode/skills/writing-plans/tasks/clean-room.md && git commit -m "writing-plans: update plan path references in update/revisit/audit-fidelity/audit-concern/clean-room tasks"`

---

## Phase 7 — implementation-pipeline pre-red-baseline.md: Read Split Format

**Concern:** Update pre-red-baseline to read `plan.md` for phase table, then `plan-{O}.md` for current phase.

**Files:** `.opencode/skills/implementation-pipeline/tasks/pre-red-baseline.md`

**SCs:** SC-4, SC-5

**Dependencies:** Phase 1 (Plan Model convention defined)

**Entry:** Phase 1 complete

**Exit:** pre-red-baseline.md reads `plan.md` index + `plan-{O}.md` for current phase

- [ ] 25. **RED (**sub-agent**).** Write a behavioral enforcement test: dispatch pre-red-baseline on a split-format plan, verify it loads the correct phase file. Test MUST FAIL because pre-red-baseline reads monolithic `plan.md`. **→ SC-5**
- [ ] 26. **GREEN (**sub-agent**).** Edit `.opencode/skills/implementation-pipeline/tasks/pre-red-baseline.md`:
       - **§Entry Criteria:** Change "Plan exists at `.issues/{issue-N}/plan.md`" to "Plan index exists at `.issues/{issue-N}/plan.md` and phase files exist at `.issues/{issue-N}/plan-{NN}-*.md`"
       - **Step 2 (Document Source Currency):** Change "Read `.issues/{issue-N}/plan.md`" to "Read `.issues/{issue-N}/plan.md` for phase table, then read `.issues/{issue-N}/plan-{NN}-*.md` for current phase's steps"
       - **Step 3 (SC-ID Cross-Reference):** Change "Read `.issues/{issue-N}/plan.md`" to "Read `.issues/{issue-N}/plan.md` index and `.issues/{issue-N}/plan-{NN}-*.md` phase files"
       - **§Context Required:** Update plan path references.
       - **§Related Files:** Update plan path references.
       **→ SC-4, SC-5**
- [ ] 27. **GREEN doublecheck (**clean-room**).** Verify the edit: read pre-red-baseline.md, confirm it reads `plan.md` for phase table then `plan-{O}.md` for current phase. **→ SC-4, SC-5**
- [ ] 28. **Checkpoint commit (**inline**).** `git add .opencode/skills/implementation-pipeline/tasks/pre-red-baseline.md && git commit -m "implementation-pipeline pre-red-baseline.md: read plan.md index + plan-{NN}-*.md phase files"`

---

## Phase 8 — implementation-pipeline assemble-work.md, pre-flight-handoff.md: Plan Path References

**Concern:** Update assemble-work and pre-flight-handoff to reference split format.

**Files:** `.opencode/skills/implementation-pipeline/tasks/assemble-work.md`, `pre-flight-handoff.md`

**SCs:** SC-4

**Dependencies:** Phase 1 (Plan Model convention defined)

**Entry:** Phase 1 complete

**Exit:** Both task files reference `plan.md` + `plan-{O}.md` convention

- [ ] 29. **RED (**sub-agent**).** Write a structural enforcement test: `grep -c 'plan-[0-9]'` on each file returns expected count. Test MUST FAIL. **→ SC-4**
- [ ] 30. **GREEN (**sub-agent**).** Edit both files:
       - **assemble-work.md:** Change all `.issues/{N}/plan.md` references to note the split format. Update Step 1 to read `plan.md` index for phase table, then `plan-{NN}-*.md` for current phase steps. Update §Context Required.
       - **pre-flight-handoff.md:** Change all `.issues/{N}/plan.md` references to note the split format. Update Step 1 to read `plan.md` index + `plan-{NN}-*.md` phase files. Update Step 2. Update §Context Required.
       **→ SC-4**
- [ ] 31. **GREEN doublecheck (**clean-room**).** Verify both files: read each, confirm plan path references use split format. **→ SC-4**
- [ ] 32. **Checkpoint commit (**inline**).** `git add .opencode/skills/implementation-pipeline/tasks/assemble-work.md .opencode/skills/implementation-pipeline/tasks/pre-flight-handoff.md && git commit -m "implementation-pipeline: update plan path references in assemble-work and pre-flight-handoff"`

---

## Phase 9 — adversarial-audit plan-fidelity.md: Read Split Format

**Concern:** Update plan-fidelity to read `plan.md` index + all `plan-{O}.md` for full audit.

**Files:** `.opencode/skills/adversarial-audit/tasks/plan-fidelity.md`

**SCs:** SC-4, SC-6

**Dependencies:** Phase 1 (Plan Model convention defined)

**Entry:** Phase 1 complete

**Exit:** plan-fidelity.md reads `plan.md` index + all `plan-{O}.md` phase files

- [ ] 33. **RED (**sub-agent**).** Write a behavioral enforcement test: dispatch plan-fidelity on a split-format plan, verify all phase files are audited. Test MUST FAIL because plan-fidelity reads monolithic `plan.md`. **→ SC-6**
- [ ] 34. **GREEN (**sub-agent**).** Edit `.opencode/skills/adversarial-audit/tasks/plan-fidelity.md`:
       - **Step 2 (Fetch Existing Plan):** Change from:
         ```
         Read the existing plan from `spec_local_dir/`:
         - `read <spec_local_dir>/plan.md` if the plan file exists in the spec directory
         - Otherwise, the plan is embedded in the spec body — extract from there
         ```
         To:
         ```
         Read the existing plan from `spec_local_dir/`:
         - `read <spec_local_dir>/plan.md` for the index (phase table, goal, architecture, exit criteria)
         - `glob <spec_local_dir>/plan-*.md` to discover all phase files
         - `read <spec_local_dir>/plan-{NN}-*.md` for each phase's full step-by-step
         - If no split files exist, the plan is embedded in the spec body — extract from there
         ```
       - **§Entry Criteria:** Update plan path references.
       - **§Exit Criteria:** Update to reference split format.
       - **§Procedure:** Update all plan path references.
       **→ SC-4, SC-6**
- [ ] 35. **GREEN doublecheck (**clean-room**).** Verify the edit: read plan-fidelity.md, confirm it reads `plan.md` index + all `plan-{O}.md` phase files. **→ SC-4, SC-6**
- [ ] 36. **Checkpoint commit (**inline**).** `git add .opencode/skills/adversarial-audit/tasks/plan-fidelity.md && git commit -m "adversarial-audit plan-fidelity.md: read plan.md index + all plan-{NN}-*.md phase files"`

---

## Phase 10 — plan-creation-pipeline SKILL.md: Plan Artifact Path References

**Concern:** Update plan-creation-pipeline SKILL.md to reference split format.

**Files:** `.opencode/skills/plan-creation-pipeline/SKILL.md`

**SCs:** SC-4

**Dependencies:** Phase 1 (Plan Model convention defined)

**Entry:** Phase 1 complete

**Exit:** plan-creation-pipeline SKILL.md references `plan.md` + `plan-{O}.md` convention

- [ ] 37. **RED (**sub-agent**).** Write a structural enforcement test: `grep -c 'plan-[0-9]'` on SKILL.md returns expected count. Test MUST FAIL. **→ SC-4**
- [ ] 38. **GREEN (**sub-agent**).** Edit `.opencode/skills/plan-creation-pipeline/SKILL.md`:
       - **§Dispatch Routing Table:** Change "plan artifact at `.issues/{N}/plan.md`" to "plan index at `.issues/{N}/plan.md` with phase files at `.issues/{N}/plan-{NN}-*.md`"
       - **§Cross-References:** Update plan path references.
       **→ SC-4**
- [ ] 39. **GREEN doublecheck (**clean-room**).** Verify the edit: read SKILL.md, confirm plan artifact path references use split format. **→ SC-4**
- [ ] 40. **Checkpoint commit (**inline**).** `git add .opencode/skills/plan-creation-pipeline/SKILL.md && git commit -m "plan-creation-pipeline SKILL.md: update plan artifact path references"`

---

## Phase 11 — guidelines 140-planning-spec-creation.md: Plan File Path References

**Concern:** Update guideline 140 to reference split format.

**Files:** `.opencode/guidelines/140-planning-spec-creation.md`

**SCs:** SC-4, SC-7

**Dependencies:** Phase 1 (Plan Model convention defined)

**Entry:** Phase 1 complete

**Exit:** 140-planning-spec-creation.md references `plan.md` + `plan-{O}.md` convention

- [ ] 41. **RED (**sub-agent**).** Write a string enforcement test: `grep 'plan-[0-9]'` on 140-planning-spec-creation.md returns matches. Test MUST FAIL because references are to monolithic `plan.md`. **→ SC-7**
- [ ] 42. **GREEN (**sub-agent**).** Edit `.opencode/guidelines/140-planning-spec-creation.md`:
       - **§Spec-Driven Development Workflow (line 14):** Change "Create a local plan file at `.issues/{N}/plan.md`" to "Create a local plan index at `.issues/{N}/plan.md` with phase files at `.issues/{N}/plan-{NN}-*.md`"
       - **§Terminology (line 36):** Change "Create a local plan file at `.issues/{N}/plan.md`" to "Create a local plan index at `.issues/{N}/plan.md` with phase files at `.issues/{N}/plan-{NN}-*.md`"
       - **§Terminology (line 39):** Change "Plans are local artifacts at `.issues/{N}/plan.md`" to "Plans are local artifacts at `.issues/{N}/plan.md` (index) + `.issues/{N}/plan-{NN}-*.md` (phase files)"
       **→ SC-4, SC-7**
- [ ] 43. **GREEN doublecheck (**clean-room**).** Verify the edit: `grep 'plan-[0-9]'` on 140-planning-spec-creation.md returns matches. **→ SC-4, SC-7**
- [ ] 44. **Checkpoint commit (**inline**).** `git add .opencode/guidelines/140-planning-spec-creation.md && git commit -m "guidelines 140-planning-spec-creation.md: update plan file path references"`

---

## Phase 12 — Global Verification

**Concern:** Run all enforcement tests and verify all 16 affected files are updated.

**Files:** All 16 affected files

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7

**Dependencies:** All prior phases complete

**Entry:** All prior phases committed

**Exit:** All SCs verified PASS

- [ ] 45. **Run behavioral tests for SC-1 (**clean-room**).** Run the SC-1 behavioral test: create a multi-phase plan, verify `plan.md` exists with phase table, verify `plan-01-*.md` through `plan-0N-*.md` exist with globally sequential steps. **→ SC-1**
- [ ] 46. **Run behavioral tests for SC-2 (**clean-room**).** Run the SC-2 behavioral test: run completion on a multi-phase plan with all phase files present → PASS; with a missing phase file → BLOCKED. **→ SC-2**
- [ ] 47. **Run string check for SC-3 (**inline**).** `grep 'github_issue_read.*get_sub_issues'` on validate.md returns zero matches. **→ SC-3**
- [ ] 48. **Run structural check for SC-4 (**inline**).** `grep -c 'plan-[0-9]'` on each of the 16 affected files returns expected count. **→ SC-4**
- [ ] 49. **Run behavioral tests for SC-5 (**clean-room**).** Dispatch pre-red-baseline on a split-format plan, verify it loads the correct phase file. **→ SC-5**
- [ ] 50. **Run behavioral tests for SC-6 (**clean-room**).** Dispatch plan-fidelity on a split-format plan, verify all phase files are audited. **→ SC-6**
- [ ] 51. **Run string check for SC-7 (**inline**).** `grep 'plan-[0-9]'` on 140-planning-spec-creation.md returns matches. **→ SC-7**
- [ ] 52. **Final structural sweep (**inline**).** Verify all 16 affected files are updated. List each file and confirm it references the split format. **→ SC-4**

---

## Exit Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|-------------------|
| C1 | writing-plans write task produces `plan.md` index + N `plan-{O}.md` phase files | behavioral | Create a multi-phase plan, verify `plan.md` exists with phase table, verify `plan-01-*.md` through `plan-0N-*.md` exist with globally sequential steps |
| C2 | writing-plans completion task checks local `plan-{O}.md` files instead of GitHub API | behavioral | Run completion on a multi-phase plan with all phase files present → PASS; with a missing phase file → BLOCKED |
| C3 | writing-plans validate task step 9 checks local files instead of GitHub API | string | `grep 'github_issue_read.*get_sub_issues'` on validate.md returns zero matches |
| C4 | All 16 affected files updated to reference `plan.md` + `plan-{O}.md` convention | structural | `grep -c 'plan-[0-9]'` on each affected file returns expected count |
| C5 | implementation-pipeline pre-red-baseline reads `plan.md` for phase table then `plan-{O}.md` for current phase | behavioral | Dispatch pre-red-baseline on a split-format plan, verify it loads the correct phase file |
| C6 | adversarial-audit plan-fidelity reads `plan.md` index + all `plan-{O}.md` for full audit | behavioral | Dispatch plan-fidelity on a split-format plan, verify all phase files are audited |
| C7 | guideline 140-planning-spec-creation.md references updated | string | `grep 'plan-[0-9]'` on 140-planning-spec-creation.md returns matches |

> **One step at a time protocol:** Each numbered step is a single unit of work. The orchestrator completes exactly one step, reports the result, and proceeds to the next step without asking for permission. "Combining steps" means performing work that spans multiple plan step numbers in a single operation — regardless of how many tool calls, dispatches, or response turns it takes. The self-check is: "does the work I just completed correspond to exactly one plan step number?" If the work touches files or concerns from step N and step N+1, it is combined. The RED→GREEN transition is a zero-tolerance gate: the RED test MUST be verified as FAILING (by reading its artifact output) before any GREEN implementation begins. Skipping this verification invalidates the entire phase and all work in it.

> **Self-remediation protocol:** If the orchestrator combines steps or skips a gate, it MUST self-remediate by reverting only the work belonging to the incorrectly-combined step and re-dispatching from the failed step. Do NOT revert work from correctly-executed prior steps. No halting, no asking for permission, no "should I?" — the answer is always revert the offending step and re-dispatch.

## Compliance Notice

This plan implements `.opencode#1614` (Split plan files: plan.md index + plan-{O}.md phase files). All changes are confined to `.opencode/skills/` task files and `.opencode/guidelines/140-*.md`. No changes to spec-creation, approval-gate, issue-operations, or the plan tool (unified-planning/PDDL). The PR strategy is stacked — one branch, 12 commits (one per phase), one PR targeting `dev`.
