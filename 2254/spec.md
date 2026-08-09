> **Full spec and artifacts: [`.opencode/.issues/2254/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/2254/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2254/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## 1. Intent and Executive Summary

### Problem Statement

A history-grounded read-only audit of the spec-writer and spec-audit skill card sets (`spec-creation`, `audit`) and the consolidated reference standards (`.opencode/reference/`) identified internal-consistency drifts between what each card declares (dispatch format, structural sections, role naming, task references, evidence-type taxonomy source, validation criteria) and the actual on-disk reality. These drifts cause agents to dispatch tasks using a deprecated prompt format the reference docs forbid, resolve cross-references to non-existent task files, read the evidence-type taxonomy from a redirect source instead of the canonical one, evaluate a spec against a different 11-dimension set than the auditor uses, and route to tasks whose cards do not exist.

A subsequent brainstorming session expanded the remediation scope beyond drift repair to a total remediation of the spec-writer and spec-auditor skills plus the consolidated `.opencode/reference/` standards. The expanded scope adds six new requirement areas: (1) a canonical numbered-checkbox Workflows format for both main skill cards with explicit execution-mode sub-bullets; (2) a numbered-checkbox task-card Procedure format designed for non-task-capable sub-agents, requiring fat task cards to be split; (3) dispatch-contract completeness so every workflow Context sub-bullet supplies every parameter a task card needs; (4) linter enforcement of the new format rules via the skildeck linter; (5) markdown link verification across the two skills and reference docs; and (6) workflow clarity so the orchestrator knows step-by-step what to do and whether each step is inline or dispatched. A further revision adds the dependency prerequisite: the two reference docs that define these formats — skill-card-description-standards.md §7 (Workflows) and task-card-structure-standards.md (Procedure) — still define the OLD plain numbered-list format, so they must be updated to the new numbered-checkbox format (with the execution-mode indicator, the clean-room unit mandate, and the dispatch-contract completeness requirement) BEFORE the skill cards can conform and BEFORE the linter can enforce it.

A further revision adds functional end-to-end verification. The drift-repair and format SCs (SC-1..SC-30) prove the remediated cards are well-formed on disk, but they do not prove the remediated skills actually work when dispatched. The goal is a working set of spec skills. New behavioral SCs (SC-31..SC-33) run the remediated spec-creation pipeline and the audit DiMo 4-role chain end-to-end against a fixture in a shared test home with a test gitbucket instance, asserting correct output — no mis-routing, no missing task cards, no broken cross-references, no deprecated dispatch strings. These tests build incrementally: later tests reuse the state created by earlier ones in the same shared test home.

### Root Cause / Motivation

Both skill sets retain content from before several migrations: the flat-architecture refactor, the DiMo 4-role audit dispatch, the Workflows-section format, and the consolidated `.opencode/reference/` location. Because agent-facing text is consumed as routing instructions, each drift is a defect vector — an agent that follows a deprecated dispatch string, a dangling cross-reference, or a divergent dimension list produces defective work that must be re-done. The drifts must be resolved now because they compound: every spec created or audited through the drifted cards inherits the defect.

The expanded requirements address a second class of defect: format and contract gaps that are not drift but absence. The main skill cards do not use a numbered-checkbox Workflows format with execution-mode sub-bullets, so the orchestrator cannot tell at a glance whether a step is inline or dispatched. Task cards are not uniformly formatted as numbered checkbox lists and some fat task cards would require internal sub-agent dispatch — which sub-agents cannot perform because `task: deny` is hardcoded. The two reference docs that define these formats — skill-card-description-standards.md §7 and task-card-structure-standards.md — still specify the OLD plain numbered-list format, so the skill cards and the linter have no canonical reference format to conform to and enforce; they must be updated to the new numbered-checkbox format first. Workflow Context sub-bullets do not reliably supply every parameter a task card's Dispatch Contract and Entry Criteria require, so a dispatched sub-agent searches for, guesses, or fabricates missing parameters. The skildeck linter does not enforce any of these format rules, so the defects recur silently. Markdown links are not verified to resolve to real targets with correct relative paths and the `Read [Text](path)` wording.

The functional end-to-end requirement addresses a third class of defect: well-formedness without proof of function. A card set can be internally consistent and still fail when dispatched — a workflow that routes to the wrong task, a task card that is missing, a cross-reference that resolves to a file that does not exist, or a dispatch string the reference docs forbid. Only running the remediated skills end-to-end against a fixture proves they work. The shared test home with a test gitbucket instance provides the isolation and the remote API needed to run these pipelines for real.

### Approach Chosen

Apply exactly ONE prescriptive resolution per finding, each mapped one-to-one to a success criterion. Consolidate the evidence-type taxonomy into one canonical reference document and make both the spec-creation validate task and the audit skill load it dynamically. Convert the audit SKILL.md from Trigger Dispatch Table + Invocation + Tasks table to a Workflows section with 4 DiMo steps. Remove the redundant Task Files table from spec-creation. Repair role-card frontmatter name fields to match filenames. Repoint broken cross-references to role-split files. Update stale reference-doc task names. Flatten three subdirectory audit tasks to flat role files and remove stub index files. Correct completion task routing and repoint the dangling approval-gate reference. Rewrite the audit description to canonical agent-intent format. Remove the redundant behavioral-sc-evaluator.md. Point taxonomy citations at the canonical reference. Make a missing evidence-type declaration a hard FAIL.

For the expanded scope: convert both main skill card Workflows sections to numbered checkbox lists with sub-bullets for the prompt string, the passed parameters/context, and an execution-mode indicator (inline vs sub-agent dispatch). Convert task card Procedure sections to numbered checkbox lists and split any fat task card whose procedure would require internal sub-agent dispatch into multiple task cards, adjusting the SKILL.md workflow to dispatch each split task card as a separate step. Update the two reference docs that define these formats — skill-card-description-standards.md §7 (Workflows) and task-card-structure-standards.md (Procedure) — to the numbered-checkbox format with the execution-mode indicator, the clean-room unit mandate, and the dispatch-contract completeness requirement, so the skill cards and the linter have a canonical standard to conform to and enforce. Verify dispatch-contract completeness so every workflow Context sub-bullet supplies every parameter in the task card's Dispatch Contract and Entry Criteria. Extend the skildeck linter to enforce the new format rules. Verify all markdown links in the two skills and reference docs resolve to real targets with correct relative paths and the `Read [Text](path)` wording. Make the workflows explicitly orchestrator step-by-step with the execution-mode sub-bullet making the inline-vs-dispatch decision explicit.

For the functional end-to-end scope: add behavioral SCs that run the remediated skills end-to-end. SC-31 dispatches the full spec-creation pipeline (analyze → create → validate) against a fixture problem in the shared test home and asserts a valid spec with no mis-routing, no missing task cards, no broken cross-references, and no deprecated dispatch strings. SC-32 dispatches the audit DiMo 4-role chain (investigator → validator → evaluator → arbiter) against a fixture spec in the shared test home and asserts a valid verdict with each role dispatching to the correct split task card with a complete dispatch contract. SC-33 requires the spec-creation and audit behavioral tests to share a common test home with a test project and test gitbucket instance, sequenced so later tests build upon the state created by earlier tests in an incremental fashion. All three use the shared `with-test-home` infrastructure with the gitbucket instance.

### Alternatives Considered & Why Discarded

- **Leave the drifts in place and rely on agent judgment to route correctly.** Discarded: agent-facing text is consumed as routing instructions, not advisory prose. An agent cannot reliably compensate for a deprecated dispatch string or a dangling cross-reference; the drift is a guaranteed defect vector, not a cosmetic inconsistency.
- **Introduce backwards-compatible dual paths (accept both old and new formats).** Discarded: the anti-bifurcation mandate forbids dual-format agent-facing instructions. A backwards-compat path leaves the deprecated format live, so agents continue to follow it and the defect persists.
- **Document the new format rules in reference docs only, without linter enforcement.** Discarded: documentation without enforcement is decoration. The format rules must be enforced by the skildeck linter so the defects cannot recur silently. This is why the linter extension is in scope.
- **Update the skill cards and linter to the new format while leaving the reference docs in the old plain numbered-list format.** Discarded: the reference docs are the canonical definition of the format. If they keep defining the old format, the skill cards (SC-23, SC-24, SC-25) conform to a format the reference forbids and the linter (SC-28) has no canonical format to enforce. The reference docs must be updated to the new format first — this is why SC-34 and SC-35 are in scope as a dependency prerequisite.
- **Keep fat task cards and rely on the sub-agent to "do the work" despite `task: deny`.** Discarded: sub-agents have `task: deny` hardcoded and cannot call `skill()`. A task card whose procedure requires internal sub-agent dispatch is unexecutable by its consumer. Fat task cards must be split into multiple task cards dispatched as separate workflow steps.
- **Verify the remediated skills only by static well-formedness checks (grep, link resolution, structural validation).** Discarded: static checks prove the cards are well-formed on disk, not that they work when dispatched. A workflow can be internally consistent and still mis-route, reference a missing task card, or use a deprecated dispatch string. Only running the remediated skills end-to-end against a fixture proves they work. This is why the functional behavioral SCs (SC-31..SC-33) are in scope.
- **Run each behavioral test in a fresh, isolated test home with no shared state.** Discarded: the functional tests build incrementally — later tests reuse the state created by earlier ones (the spec created by SC-31 is the fixture audited by SC-32). A shared test home with a test project and test gitbucket instance provides the isolation and the remote API needed for this incremental build-up. This is why SC-33 mandates the shared test home.

### Key Design Decisions

- **Single canonical evidence-type taxonomy** in one reference document, loaded dynamically by both spec-creation validate and audit. Tradeoff: a single source of truth requires all consumers to be updated in scope, but eliminates the redirect-source and divergent-list defects.
- **Workflows-only structure** for audit SKILL.md. Tradeoff: converting TDT/Invocation/Tasks to a Workflows section changes the routing surface, but aligns with the canonical skill-card format and removes the deprecated dispatch strings.
- **Missing evidence-type declaration is a hard FAIL** routed to the remediation workflow. Tradeoff: stricter validation may surface more spec defects, but eliminates the default-to-string escape hatch that masks missing declarations.
- **Numbered-checkbox Workflows format with execution-mode sub-bullets** for both main skill cards. Tradeoff: the format is more verbose than a plain numbered list, but the execution-mode sub-bullet makes the inline-vs-dispatch decision explicit and the numbered checkbox list is the canonical checklist format the reference docs already mandate for pipeline gates.
- **Task-card clean-room unit** — task cards are designed for non-task-capable sub-agents; any procedure requiring internal dispatch is split. Tradeoff: splitting fat task cards increases the number of task cards and workflow steps, but guarantees each task card is executable by its consumer.
- **Reference docs updated to the new format** — skill-card-description-standards.md §7 and task-card-structure-standards.md are remediation targets in scope, not merely satisfied prerequisites. Tradeoff: updating the reference docs adds two SCs (SC-34, SC-35) and two items, but is a dependency prerequisite — the skill cards (SC-23, SC-24, SC-25) and the linter (SC-28) must have a canonical reference format to conform to and enforce.
- **Linter enforcement of the format rules** via the skildeck linter. Tradeoff: extending the linter changes runtime behavior and requires behavioral evidence, but is the only way to prevent silent recurrence of the format defects.
- **Functional end-to-end behavioral verification** of the remediated skills. Tradeoff: running the full spec-creation pipeline and the audit DiMo chain end-to-end costs minutes of execution time per test, but is the only way to prove the remediated skills actually work when dispatched — not just that they are well-formed. This is the difference between a working set of spec skills and a well-formed set of spec cards.
- **Shared test home with a test project and test gitbucket instance** for the functional behavioral tests. Tradeoff: sharing state between tests couples them (later tests depend on earlier ones), but enables incremental build-up where the spec created by SC-31 becomes the fixture audited by SC-32, and provides the remote API needed for remote-stub/issue-creation tests. The `with-test-home` infrastructure and the `BEHAVIOR_NEEDS_REMOTE` gitbucket provisioning already provide this shared, isolated environment.

### User Intent / Original Prompt

A history-grounded read-only audit of the spec-writer and spec-audit skill card sets and the consolidated reference standards, identifying internal-consistency drifts and prescribing one resolution per finding. Expanded by a brainstorming session into a total remediation of the spec-writer (spec-creation) and spec-auditor (audit) skills plus the consolidated `.opencode/reference/` standards, incorporating the six new requirement areas (workflow format, task-card format, dispatch-contract completeness, linter enforcement, markdown link verification, workflow clarity). Further expanded by a revision request to add mandatory functional behavioral SCs that run the remediated skills end-to-end against a fixture in a shared test home with a test gitbucket instance, proving the skills work — not just that they are well-formed. Further expanded by a revision request to add the dependency-prerequisite SCs (SC-34, SC-35) that update the two reference docs (skill-card-description-standards.md §7, task-card-structure-standards.md) to the new numbered-checkbox format with the execution-mode indicator, the clean-room unit mandate, and the dispatch-contract completeness requirement, so the skill cards and the linter have a canonical reference format to conform to and enforce.

## 2. Not Included

- **Application `src/` code changes** — All affected files are agent-facing markdown in `.opencode/` plus the skildeck linter under `.opencode/tools/impl/skildeck/`; no application `src/` runtime code changes.
- **Non-agent-facing documentation** — Changes confined to skill cards, task cards, reference standards, and the skildeck linter consumed by agents.
- **Behavioral test suite changes beyond what the SCs require** — The behavioral SCs (issue anchoring, linter enforcement, functional end-to-end spec-creation and audit) require their own behavioral tests; no other test-suite changes are in scope.
- **Other skills' Workflows/task-card formats** — The numbered-checkbox format and clean-room split apply to the two main skill cards (spec-creation, audit) and their task cards in scope, plus the two reference docs that define those formats (skill-card-description-standards.md, task-card-structure-standards.md); other skills are not reformatted in this spec.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | spec-creation/SKILL.md SHALL use the canonical dispatch prompt format `Follow the instructions in [<skill>/tasks/<task>.md](...)` for all task() dispatches, with zero occurrences of the deprecated `execute X from Y` coded strings. | string | grep spec-creation/SKILL.md for absence of `execute .* from` and presence of canonical format |
| SC-2 | spec-creation/SKILL.md SHALL NOT contain a `## Task Files` table. | string | grep spec-creation/SKILL.md for absence of `## Task Files` |
| SC-3 | audit/SKILL.md SHALL use a single Workflows section with 4 DiMo steps (Investigator, Validator, Evaluator, Arbiter). | string | grep audit/SKILL.md for Workflows section |
| SC-4 | audit/SKILL.md SHALL NOT contain Trigger Dispatch Table, Tasks, or Invocation sections. | string | grep audit/SKILL.md for absence of TDT/Invocation/Tasks sections |
| SC-5 | audit/SKILL.md SHALL use the canonical dispatch prompt format `Follow the instructions in [<skill>/tasks/<task>.md](...)` for all task() dispatches. | string | grep audit/SKILL.md for presence of canonical format |
| SC-6 | audit/SKILL.md SHALL NOT contain deprecated `execute <task-name> DiMo <role> from audit` dispatch strings. | string | grep audit/SKILL.md for absence of `execute .* DiMo .* from audit` |
| SC-7 | audit/SKILL.md description frontmatter SHALL be in canonical agent-intent format (no `Load via skill() when`, `Also load when`, `User phrases:` meta-instructions). | semantic | sub-agent reads audit/SKILL.md frontmatter and verifies canonical agent-intent format via analytical judgment |
| SC-8 | Every audit role-card frontmatter `name:` field SHALL match its filename (Investigator/Validator/Evaluator/Arbiter), with zero `-generator`/`-knowledge-supporter`/`-path-provider` mismatches. The authoritative on-disk count of defective role-card files is 40: 28 flat role files in tasks/ (24 with stale pre-rename role names — generator/knowledge-supporter/path-provider — plus 4 with empty `name` field: concern-separation-investigator, concern-separation-validator, plan-fidelity-investigator, behavioral-sc-evaluator) and 12 subdirectory role files (closure-verification/*, coherence-extraction/*, spec-summary/* — 4 each) all with empty `name` field. Note: plan-fidelity-validator.md carries `name: plan-fidelity-knowledge-supporter` (stale, not empty), and is counted in the 24 stale. Note: SC-14 removes behavioral-sc-evaluator.md; after its removal the flat-file mismatch count is 27. | string | for each audit/tasks/*-role.md, verify frontmatter name == basename |
| SC-9 | Every audit role-card `# Task:` heading SHALL match its filename (Investigator/Validator/Evaluator/Arbiter). | string | for each audit/tasks/*-role.md, verify `# Task:` heading == basename |
| SC-10 | Broken cross-references to non-existent monolithic role-task files (tasks/spec-audit.md, tasks/plan-fidelity.md) SHALL be repointed to the actual role-split files, including in reference/holistic-dimensions.yaml. | string | grep audit/tasks and reference/holistic-dimensions.yaml for absence of monolithic refs and presence of role-split refs |
| SC-11 | Stale reference-doc task names (inspect/decompose/write/check/file) in reference/skill-card-description-standards.md SHALL be updated to actual task names (analyze/create/validate/revise). | string | grep reference/skill-card-description-standards.md for absence of stale names and presence of actual names |
| SC-12 | The three subdirectory audit tasks (closure-verification/, coherence-extraction/, spec-summary/) SHALL be flattened to flat role files and their stub index files (closure-verification.md, coherence-extraction.md, spec-summary.md) SHALL be removed. | string | verify the three subdirectories are flat files and stub files are absent |
| SC-13 | audit/tasks/completion.md SHALL route to the actual 3-step verify-authorization workflow and SHALL NOT reference the dangling `approval-gate --task verify-authorization`. | string | grep audit/tasks/completion.md for correct routing and absence of dangling reference |
| SC-14 | The redundant audit/tasks/behavioral-sc-evaluator.md SHALL be removed. | string | verify audit/tasks/behavioral-sc-evaluator.md is absent |
| SC-15 | Evidence-type taxonomy citations in spec-creation validate and audit role cards SHALL point at the single canonical reference document, loaded dynamically. | string | grep spec-creation/tasks/validate.md and audit role cards for canonical reference citation |
| SC-16 | A missing evidence-type declaration in reference/spec-structure-standards.md SHALL be a hard FAIL routed to the remediation workflow, not a default-to-string/warn/backwards-compat tier. | semantic | sub-agent reads reference/spec-structure-standards.md and verifies the missing-type rule is hard FAIL via analytical judgment |
| SC-17 | spec-creation/tasks/analyze.md SHALL BLOCK on an unbound/placeholder issue number. Remote-stub-first issue-number binding is NOT analyze.md's responsibility — it is handled upstream by issue-operations-core creation and by create.md. | behavioral | opencode run (with-test-home): dispatch analyze with unbound/placeholder issue_number and assert BLOCK |
| SC-18 | spec-creation/tasks/validate.md SHALL load the 11 holistic dimensions dynamically from reference/holistic-dimensions.yaml rather than a hardcoded divergent list. | string | grep spec-creation/tasks/validate.md for dynamic load of reference/holistic-dimensions.yaml |
| SC-19 | spec-creation/tasks/create.md SHALL route the remote issue body to the canonical exec-summary body format (Spec Reference Blockquote, Problem, Scope, Approach, Impact) defined in issue-operations-core/tasks/creation.md Step 5. | string | grep spec-creation/tasks/create.md for a reference to the canonical exec-summary body format / creation.md Step 5 |
| SC-20 | spec-creation/tasks/create.md SHALL include the forward-reference Spec Reference Blockquote link in the remote issue body, pointing to the issues-data branch URL. | string | grep spec-creation/tasks/create.md for the forward-reference Spec Reference Blockquote / issues-data link |
| SC-21 | The create task SHALL sequence the post-push reconciliation of the Spec Reference Blockquote / artifact URL after issue-operations/platforms/local/tasks/push-artifacts.md runs. | string | grep spec-creation/tasks/create.md for the post-push reconciliation sequenced after push-artifacts.md |
| SC-22 | spec-creation/tasks/revise.md SHALL regenerate the exec-summary remote issue body when the spec is revised. | string | grep spec-creation/tasks/revise.md for exec-summary body regeneration on revision |
| SC-23 | spec-creation/SKILL.md Workflows section SHALL use numbered checkbox lists (`- [ ] N.`) with sub-bullets for the prompt string, the passed parameters/context, and an execution-mode indicator (inline vs sub-agent dispatch). | string | grep spec-creation/SKILL.md for numbered checkbox workflow steps and execution-mode sub-bullets |
| SC-24 | audit/SKILL.md Workflows section SHALL use numbered checkbox lists (`- [ ] N.`) with sub-bullets for the prompt string, the passed parameters/context, and an execution-mode indicator (inline vs sub-agent dispatch). | string | grep audit/SKILL.md for numbered checkbox workflow steps and execution-mode sub-bullets |
| SC-25 | Every task card Procedure section in spec-creation and audit SHALL use numbered checkbox lists (`- [ ] N.`). | string | grep all task cards in spec-creation and audit for numbered checkbox procedure steps |
| SC-26 | No task card procedure in spec-creation or audit SHALL require internal sub-agent dispatch; any task card whose procedure would require internal dispatch SHALL be split into multiple task cards, and the SKILL.md workflow SHALL dispatch each split task card as a separate step. | semantic | sub-agent reads all task cards in spec-creation and audit and verifies no procedure requires internal dispatch via analytical judgment |
| SC-27 | For every task card in spec-creation and audit, the SKILL.md workflow Context sub-bullet that dispatches it SHALL supply every parameter in the task card's Dispatch Contract and Entry Criteria. | semantic | sub-agent cross-references each task card's Dispatch Contract/Entry Criteria against the SKILL.md workflow Context sub-bullet via analytical judgment |
| SC-28 | The skildeck linter (.opencode/tools/impl/skildeck/) SHALL be extended to enforce the new format rules: numbered-checkbox workflow format, execution-mode sub-bullet, task-card clean-room unit, dispatch-contract completeness, and markdown link correctness. | behavioral | opencode run (with-test-home): run skildeck lint against a fixture violating each new rule and assert the linter flags it |
| SC-29 | All markdown links in spec-creation/SKILL.md, audit/SKILL.md, and the reference docs SHALL resolve to real targets, use correct relative paths, and be worded per the `Read [Text](path)` cross-reference pattern. | string | verify all markdown links in the two skills and reference docs resolve and follow the `Read [Text](path)` pattern |
| SC-30 | The workflows in spec-creation/SKILL.md and audit/SKILL.md SHALL clearly indicate they are for the orchestrator to follow step-by-step, with the execution-mode sub-bullet making the inline-vs-dispatch decision explicit. | string | grep the two SKILL.md files for orchestrator-step framing and execution-mode sub-bullets |
| SC-31 | Dispatching the full spec-creation pipeline (analyze → create → validate) against a fixture problem in the shared test home SHALL produce a valid spec with no mis-routing, no missing task cards, no broken cross-references, and no deprecated dispatch strings. | behavioral | opencode run (with-test-home): dispatch the remediated spec-creation pipeline end-to-end against the test gitbucket instance and assert correct output |
| SC-32 | Dispatching the audit DiMo 4-role chain (investigator → validator → evaluator → arbiter) against a fixture spec in the shared test home SHALL produce a valid verdict, with each role dispatching to the correct split task card with a complete dispatch contract. | behavioral | opencode run (with-test-home): dispatch the remediated audit chain end-to-end and assert correct output |
| SC-33 | The spec-creation and audit behavioral tests SHALL share a common test home with a test project and test gitbucket instance, sequenced so later tests build upon the state created by earlier tests in an incremental fashion. | behavioral | verify the behavioral test setup uses the shared with-test-home infrastructure with the gitbucket instance |
| SC-34 | reference/skill-card-description-standards.md SHALL specify the Workflows section as numbered-checkbox lists (`- [ ] N.`) with sub-bullets for the prompt string, the passed parameters/context, and an execution-mode indicator (inline vs sub-agent dispatch), replacing the current plain numbered-list format. | string | grep reference/skill-card-description-standards.md for the numbered-checkbox Workflows specification and execution-mode sub-bullet |
| SC-35 | reference/task-card-structure-standards.md SHALL specify the task-card Procedure as numbered-checkbox lists and SHALL state the clean-room unit mandate (task cards are for non-task-capable sub-agents; a procedure requiring internal sub-agent dispatch MUST be split) and the dispatch-contract completeness requirement (the workflow Context must supply every parameter in the task card's Dispatch Contract and Entry Criteria). | string | grep reference/task-card-structure-standards.md for the numbered-checkbox Procedure format, the clean-room unit mandate, and the dispatch-contract completeness requirement |

## 4. Requirements

- R-1. The spec-creation and audit SKILL.md files SHALL use the canonical dispatch prompt format `Follow the instructions in [<skill>/tasks/<task>.md](...)` for all task() dispatches.
- R-2. The audit SKILL.md SHALL convert the Trigger Dispatch Table, Invocation, and Tasks sections into a single Workflows section with 4 DiMo steps (Investigator, Validator, Evaluator, Arbiter).
- R-3. The spec-creation SKILL.md SHALL remove the redundant Task Files table.
- R-4. Audit role-card frontmatter `name:` fields SHALL match their filenames (Investigator/Validator/Evaluator/Arbiter).
- R-5. Broken cross-references to non-existent monolithic role-task files SHALL be repointed to the actual role-split files.
- R-6. Stale reference-doc task names (inspect/decompose/write/check/file) SHALL be updated to actual task names (analyze/create/validate/revise).
- R-7. The three subdirectory audit tasks (closure-verification, coherence-extraction, spec-summary) SHALL be flattened to flat role files and their stub index files removed.
- R-8. Completion task routing SHALL be corrected and the dangling approval-gate `--task verify-authorization` reference repointed to the actual 3-step verify-authorization workflow.
- R-9. The audit SKILL.md description SHALL be rewritten to canonical agent-intent format.
- R-10. The redundant behavioral-sc-evaluator.md SHALL be removed.
- R-11. Evidence-type taxonomy citations SHALL point at the single canonical reference document, loaded dynamically by both validate and audit.
- R-12. A missing evidence-type declaration SHALL be a hard FAIL routed to the remediation workflow, not a warn/default/backwards-compat tier.
- R-13. The spec-creation analyze task SHALL BLOCK on an unbound/placeholder issue number.
- R-14. The validate task SHALL load the 11 holistic dimensions dynamically from reference/holistic-dimensions.yaml rather than hardcoding a divergent list.
- R-18. The spec-creation create task SHALL route the remote issue body to the canonical exec-summary body format defined in issue-operations-core/tasks/creation.md Step 5 (Spec Reference Blockquote, Problem, Scope, Approach, Impact).
- R-19. The spec-creation create task SHALL include the forward-reference Spec Reference Blockquote link in the remote issue body pointing to the issues-data branch URL.
- R-20. The post-push reconciliation of the Spec Reference Blockquote / artifact URL SHALL be sequenced after issue-operations/platforms/local/tasks/push-artifacts.md.
- R-21. The spec-creation revise task SHALL regenerate the exec-summary remote issue body when the spec is revised.
- R-15. No application `src/` code changes; changes SHALL be confined to agent-facing skill/reference markdown files and the skildeck linter under `.opencode/tools/impl/skildeck/`. Application `src/` code remains excluded.
- R-16. Behavioral SCs SHALL apply only where the change affects runtime dispatch behavior; string/structural elsewhere.
- R-17. No bifurcated/backwards-compat paths SHALL be introduced in agent-facing instructions (anti-bifurcation mandate).
- R-22. The main skill card Workflows sections (spec-creation/SKILL.md and audit/SKILL.md) SHALL use numbered checkbox lists (`- [ ] N.`) with sub-bullets for the prompt string, the passed parameters/context, and an execution-mode indicator (inline vs sub-agent dispatch).
- R-23. Task card Procedure sections SHALL use numbered checkbox lists (`- [ ] N.`). Task cards SHALL be designed for non-task-capable sub-agents; a task card whose procedure would require internal sub-agent dispatch SHALL be split into multiple task cards, and the SKILL.md workflow SHALL dispatch each split task card as a separate step.
- R-24. For every task card, the SKILL.md workflow Context sub-bullet that dispatches it SHALL supply every parameter in the task card's Dispatch Contract and Entry Criteria.
- R-25. The skildeck linter (.opencode/tools/impl/skildeck/) SHALL be extended to enforce the new format rules: numbered-checkbox workflow format, execution-mode sub-bullet, task-card clean-room unit, dispatch-contract completeness, and markdown link correctness.
- R-26. All markdown links in the two skills and reference docs SHALL be correct: resolve to real targets, use correct relative paths, and be worded per the `Read [Text](path)` cross-reference pattern.
- R-27. The workflows in the main skill cards SHALL clearly indicate they are for the orchestrator to follow step-by-step, with the execution-mode sub-bullet making the inline-vs-dispatch decision explicit.
- R-28. The spec-creation behavioral test SHALL dispatch the full spec-creation pipeline (analyze → create → validate) end-to-end against a fixture problem in the shared test home and assert correct output (a valid spec with no mis-routing, no missing task cards, no broken cross-references, and no deprecated dispatch strings).
- R-29. The audit behavioral test SHALL dispatch the DiMo 4-role chain (investigator → validator → evaluator → arbiter) end-to-end against a fixture spec in the shared test home and assert a valid verdict with each role dispatching to the correct split task card with a complete dispatch contract.
- R-30. The spec-creation and audit behavioral tests SHALL share a common test home with a test project and test gitbucket instance, sequenced so later tests build upon the state created by earlier tests in an incremental fashion.
- R-31. reference/skill-card-description-standards.md SHALL specify the Workflows section as numbered-checkbox lists (`- [ ] N.`) with sub-bullets for the prompt string, the passed parameters/context, and an execution-mode indicator (inline vs sub-agent dispatch), replacing the current plain numbered-list format.
- R-32. reference/task-card-structure-standards.md SHALL specify the task-card Procedure as numbered-checkbox lists and SHALL state the clean-room unit mandate (task cards are for non-task-capable sub-agents; a procedure requiring internal sub-agent dispatch MUST be split) and the dispatch-contract completeness requirement (the workflow Context must supply every parameter in the task card's Dispatch Contract and Entry Criteria).

## 5. Items

### Item 1 (SC-1): Convert spec-creation dispatch format

- RED: grep spec-creation/SKILL.md asserts absence of `execute .* from` and presence of canonical format — fails on current content
- GREEN: Convert 6 `execute X from Y` dispatch prompts to `Follow the instructions in [<skill>/tasks/<task>.md](...)`
- verify: grep conformance
- commit: spec-creation/SKILL.md

### Item 2 (SC-2): Remove Task Files table

- RED: grep spec-creation/SKILL.md asserts absence of `## Task Files` — fails on current content
- GREEN: Remove the redundant `## Task Files` table
- verify: grep conformance
- commit: spec-creation/SKILL.md

### Item 3 (SC-3): Convert audit to Workflows structure

- RED: grep audit/SKILL.md asserts Workflows section present — fails on current content
- GREEN: Convert TDT + Tasks + Invocation + DiMo Role Chain to a single Workflows section with 4 DiMo steps
- verify: grep conformance
- commit: audit/SKILL.md

### Item 4 (SC-4): Remove audit TDT/Invocation/Tasks sections

- RED: grep audit/SKILL.md asserts TDT/Invocation/Tasks absent — fails on current content
- GREEN: Remove the Trigger Dispatch Table, Invocation, and Tasks sections from audit/SKILL.md
- verify: grep conformance
- commit: audit/SKILL.md

### Item 5 (SC-5): Convert audit dispatch format (positive)

- RED: grep audit/SKILL.md asserts canonical dispatch format present — fails on current content
- GREEN: Replace deprecated DiMo dispatch strings with canonical format
- verify: grep conformance
- commit: audit/SKILL.md

### Item 6 (SC-6): Remove deprecated audit dispatch strings (negative)

- RED: grep audit/SKILL.md asserts absence of `execute .* DiMo .* from audit` — fails on current content
- GREEN: Ensure no deprecated DiMo dispatch strings remain
- verify: grep conformance
- commit: audit/SKILL.md

### Item 7 (SC-7): Rewrite audit description

- RED: sub-agent reads audit/SKILL.md frontmatter and asserts canonical agent-intent format via analytical judgment — fails on current content
- GREEN: Rewrite description to canonical agent-intent format
- verify: sub-agent read + analytical judgment
- commit: audit/SKILL.md

### Item 8 (SC-8): Repair role-card frontmatter names

- RED: for each audit/tasks/*-role.md, assert frontmatter name == basename — fails on 40 mismatches (28 flat: 24 stale pre-rename role names + 4 empty `name` field; 12 subdirectory: all empty `name` field)
- GREEN: Repair 40 role-card frontmatter name fields to match filenames (28 flat + 12 subdirectory)
- verify: per-file frontmatter check
- commit: audit/tasks/*-role.md

### Item 9 (SC-9): Repair role-card Task headings

- RED: for each audit/tasks/*-role.md, assert `# Task:` heading == basename — fails on current content
- GREEN: Repair `# Task:` headings to match filenames
- verify: per-file heading check
- commit: audit/tasks/*-role.md

### Item 10 (SC-10): Repoint cross-references

- RED: grep audit/tasks and reference/holistic-dimensions.yaml asserts absence of monolithic refs — fails on current content
- GREEN: Repoint spec-audit.md/plan-fidelity.md refs to role-split files, including holistic-dimensions.yaml
- verify: grep conformance
- commit: audit/tasks, reference/holistic-dimensions.yaml

### Item 11 (SC-11): Update reference task names

- RED: grep reference/skill-card-description-standards.md asserts absence of stale names — fails on current content
- GREEN: Update inspect/decompose/write/check/file to analyze/create/validate/revise
- verify: grep conformance
- commit: reference/skill-card-description-standards.md

### Item 12 (SC-12): Flatten subdirectory tasks

- RED: verify closure-verification/, coherence-extraction/, spec-summary/ are flat files and stub files absent — fails on current content
- GREEN: Flatten three subdirectories to flat role files and remove stub index files
- verify: file structure check
- commit: audit/tasks

### Item 13 (SC-13): Correct completion routing

- RED: grep audit/tasks/completion.md asserts correct routing and absence of dangling reference — fails on current content
- GREEN: Repoint verify-authorization to the actual 3-step workflow
- verify: grep conformance
- commit: audit/tasks/completion.md

### Item 14 (SC-14): Remove redundant evaluator

- RED: verify audit/tasks/behavioral-sc-evaluator.md is absent — fails on current content
- GREEN: Remove behavioral-sc-evaluator.md
- verify: file absence check
- commit: audit/tasks

### Item 15 (SC-15): Consolidate taxonomy citations

- RED: grep spec-creation/tasks/validate.md and audit role cards asserts canonical reference citation — fails on current content
- GREEN: Point taxonomy citations at the single canonical reference, loaded dynamically
- verify: grep conformance
- commit: reference/, spec-creation/tasks/validate.md, audit role cards

### Item 16 (SC-16): Missing evidence type is hard FAIL

- RED: sub-agent reads reference/spec-structure-standards.md and asserts the missing-type rule is hard FAIL via analytical judgment — fails on current content
- GREEN: Change missing evidence-type declaration from default-to-string to hard FAIL routed to remediation
- verify: sub-agent read + analytical judgment
- commit: reference/spec-structure-standards.md

### Item 17 (SC-17): Analyze issue-number anchoring precondition

- RED: opencode run (with-test-home) dispatches analyze with unbound/placeholder issue_number and asserts BLOCK — fails on current content
- GREEN: Add analyze task BLOCK on unbound/placeholder issue number only
- verify: behavioral test via opencode run
- commit: spec-creation/tasks/analyze.md

### Item 18 (SC-18): Dynamic dimension loading

- RED: grep spec-creation/tasks/validate.md asserts dynamic load of reference/holistic-dimensions.yaml — fails on current content
- GREEN: Make validate load the 11 holistic dimensions dynamically from reference/holistic-dimensions.yaml
- verify: grep conformance
- commit: spec-creation/tasks/validate.md

### Item 19 (SC-19): Create routes exec-summary body format

- RED: grep spec-creation/tasks/create.md asserts a reference to the canonical exec-summary body format (creation.md Step 5) — fails on current content
- GREEN: Route create.md remote issue body to the canonical exec-summary body format (Spec Reference Blockquote, Problem, Scope, Approach, Impact)
- verify: grep conformance
- commit: spec-creation/tasks/create.md

### Item 20 (SC-20): Create includes forward-reference blockquote

- RED: grep spec-creation/tasks/create.md asserts presence of the forward-reference Spec Reference Blockquote / issues-data link — fails on current content
- GREEN: Add the forward-reference Spec Reference Blockquote link (issues-data branch URL) to the remote issue body
- verify: grep conformance
- commit: spec-creation/tasks/create.md

### Item 21 (SC-21): Sequence post-push reconciliation

- RED: grep spec-creation/tasks/create.md asserts the post-push reconciliation sequenced after push-artifacts.md — fails on current content
- GREEN: Sequence the post-push reconciliation of the Spec Reference Blockquote / artifact URL after issue-operations/platforms/local/tasks/push-artifacts.md
- verify: grep conformance
- commit: spec-creation/tasks/create.md

### Item 22 (SC-22): Revise regenerates exec-summary body

- RED: grep spec-creation/tasks/revise.md asserts exec-summary body regeneration — fails on current content
- GREEN: Regenerate the exec-summary remote issue body on revision
- verify: grep conformance
- commit: spec-creation/tasks/revise.md

### Item 23 (SC-23): Convert spec-creation Workflows to numbered-checkbox format

- RED: grep spec-creation/SKILL.md asserts numbered checkbox workflow steps and execution-mode sub-bullets — fails on current content
- GREEN: Convert the spec-creation Workflows section to numbered checkbox lists with sub-bullets for prompt string, parameters/context, and execution-mode indicator
- verify: grep conformance
- commit: spec-creation/SKILL.md

### Item 24 (SC-24): Convert audit Workflows to numbered-checkbox format

- RED: grep audit/SKILL.md asserts numbered checkbox workflow steps and execution-mode sub-bullets — fails on current content
- GREEN: Convert the audit Workflows section to numbered checkbox lists with sub-bullets for prompt string, parameters/context, and execution-mode indicator
- verify: grep conformance
- commit: audit/SKILL.md

### Item 25 (SC-25): Convert task card Procedures to numbered-checkbox format

- RED: grep all task cards in spec-creation and audit asserts numbered checkbox procedure steps — fails on current content
- GREEN: Convert every task card Procedure section to numbered checkbox lists
- verify: grep conformance
- commit: spec-creation/tasks, audit/tasks

### Item 26 (SC-26): Split fat task cards for clean-room unit

- RED: sub-agent reads all task cards in spec-creation and audit and asserts no procedure requires internal dispatch via analytical judgment — fails on current content
- GREEN: Split any task card whose procedure would require internal sub-agent dispatch into multiple task cards; adjust the SKILL.md workflow to dispatch each split task card as a separate step
- verify: sub-agent read + analytical judgment
- commit: spec-creation/tasks, audit/tasks, spec-creation/SKILL.md, audit/SKILL.md

### Item 27 (SC-27): Verify dispatch-contract completeness

- RED: sub-agent cross-references each task card's Dispatch Contract/Entry Criteria against the SKILL.md workflow Context sub-bullet and asserts completeness via analytical judgment — fails on current content
- GREEN: Ensure every workflow Context sub-bullet supplies every parameter in the task card's Dispatch Contract and Entry Criteria
- verify: sub-agent read + analytical judgment
- commit: spec-creation/SKILL.md, audit/SKILL.md, spec-creation/tasks, audit/tasks

### Item 28 (SC-28): Extend skildeck linter for format rules

- RED: opencode run (with-test-home) runs skildeck lint against a fixture violating each new rule and asserts the linter flags it — fails on current content
- GREEN: Extend the skildeck linter to enforce numbered-checkbox workflow format, execution-mode sub-bullet, task-card clean-room unit, dispatch-contract completeness, and markdown link correctness
- verify: behavioral test via opencode run
- commit: .opencode/tools/impl/skildeck/

### Item 29 (SC-29): Verify markdown links

- RED: verify all markdown links in the two skills and reference docs resolve and follow the `Read [Text](path)` pattern — fails on current content
- GREEN: Fix all markdown links to resolve to real targets, use correct relative paths, and follow the `Read [Text](path)` wording
- verify: link resolution check
- commit: spec-creation/SKILL.md, audit/SKILL.md, reference/

### Item 30 (SC-30): Make workflows orchestrator-step explicit

- RED: grep the two SKILL.md files asserts orchestrator-step framing and execution-mode sub-bullets — fails on current content
- GREEN: Make the workflows clearly indicate they are for the orchestrator to follow step-by-step, with the execution-mode sub-bullet making the inline-vs-dispatch decision explicit
- verify: grep conformance
- commit: spec-creation/SKILL.md, audit/SKILL.md

### Item 31 (SC-31): Functional end-to-end spec-creation pipeline

- RED: opencode run (with-test-home) dispatches the remediated spec-creation pipeline (analyze → create → validate) end-to-end against a fixture problem in the shared test home and asserts correct output — fails on current content (the pipeline mis-routes, references missing task cards, or uses deprecated dispatch strings)
- GREEN: Ensure the remediated spec-creation pipeline dispatches end-to-end against the test gitbucket instance and produces a valid spec with no mis-routing, no missing task cards, no broken cross-references, and no deprecated dispatch strings
- verify: behavioral test via opencode run (with-test-home) against the test gitbucket instance
- commit: spec-creation/SKILL.md, spec-creation/tasks, behavioral test script

### Item 32 (SC-32): Functional end-to-end audit DiMo chain

- RED: opencode run (with-test-home) dispatches the remediated audit DiMo 4-role chain (investigator → validator → evaluator → arbiter) end-to-end against a fixture spec in the shared test home and asserts correct output — fails on current content (roles mis-route, dispatch to missing task cards, or carry incomplete dispatch contracts)
- GREEN: Ensure the remediated audit chain dispatches end-to-end and produces a valid verdict, with each role dispatching to the correct split task card with a complete dispatch contract
- verify: behavioral test via opencode run (with-test-home)
- commit: audit/SKILL.md, audit/tasks, behavioral test script

### Item 33 (SC-33): Shared test home with gitbucket instance

- RED: verify the spec-creation and audit behavioral test setup uses the shared with-test-home infrastructure with the gitbucket instance, sequenced incrementally — fails on current content (no shared test home / gitbucket instance)
- GREEN: Ensure the spec-creation and audit behavioral tests share a common test home with a test project and test gitbucket instance, sequenced so later tests build upon the state created by earlier tests in an incremental fashion
- verify: behavioral test setup check (shared with-test-home infrastructure with the gitbucket instance)
- commit: behavioral test scripts, fixtures

### Item 34 (SC-34): Update skill-card-description-standards Workflows to numbered-checkbox format

- RED: grep reference/skill-card-description-standards.md asserts the numbered-checkbox Workflows specification and execution-mode sub-bullet — fails on current content (plain numbered-list format)
- GREEN: Update reference/skill-card-description-standards.md §7 to specify the Workflows section as numbered-checkbox lists (`- [ ] N.`) with sub-bullets for the prompt string, the passed parameters/context, and an execution-mode indicator (inline vs sub-agent dispatch)
- verify: grep conformance
- commit: reference/skill-card-description-standards.md

### Item 35 (SC-35): Update task-card-structure-standards Procedure to numbered-checkbox format with clean-room and dispatch-contract mandates

- RED: grep reference/task-card-structure-standards.md asserts the numbered-checkbox Procedure format, the clean-room unit mandate, and the dispatch-contract completeness requirement — fails on current content (plain numbered steps, no clean-room/dispatch-contract mandates)
- GREEN: Update reference/task-card-structure-standards.md to specify the task-card Procedure as numbered-checkbox lists and state the clean-room unit mandate (task cards are for non-task-capable sub-agents; a procedure requiring internal sub-agent dispatch MUST be split) and the dispatch-contract completeness requirement (the workflow Context must supply every parameter in the task card's Dispatch Contract and Entry Criteria)
- verify: grep conformance
- commit: reference/task-card-structure-standards.md

## 6. Dependencies

- **Reference: `.opencode/reference/` consolidated standards** — Relationship: the canonical evidence-type taxonomy and holistic-dimensions.yaml must be resolved before the dynamic-loading SCs (SC-15, SC-18) can be verified. Status: satisfied (files exist on disk).
- **Reference: DiMo 4-role audit dispatch** — Relationship: the audit Workflows structure (SC-3) and role-card naming (SC-8, SC-9) depend on the DiMo role model. Status: satisfied.
- **Reference: skill-card-description-standards.md §7** — Relationship: defines the Workflows-only structure and canonical description format that SC-3 and SC-7 conform to. Status: **in scope for update** — §7 currently specifies Workflows as plain numbered lists with sub-bullets (Prompt/Context/Returns); SC-34 updates it to the numbered-checkbox format with an execution-mode indicator (inline vs sub-agent dispatch). This is a dependency prerequisite for SC-23/SC-24 (the skill cards conform to the reference format) and SC-28 (the linter enforces it).
- **Reference: task-card-structure-standards.md** — Relationship: defines the task-card clean-room unit (no internal dispatch) and numbered Procedure format that SC-25 and SC-26 conform to. Status: **in scope for update** — the Procedure section currently specifies plain numbered steps; SC-35 updates it to numbered-checkbox lists and adds the clean-room unit mandate and the dispatch-contract completeness requirement. This is a dependency prerequisite for SC-25/SC-26 (task cards conform to the reference format) and SC-28 (the linter enforces it).
- **Tool: skildeck linter (`.opencode/tools/impl/skildeck/`)** — Relationship: the linter must be extended to enforce the new format rules (SC-28). Status: satisfied (linter exists on disk).
- **Infrastructure: `with-test-home` + GitBucket instance** — Relationship: the functional behavioral SCs (SC-31, SC-32, SC-33) depend on the shared test home with a test project and the test gitbucket instance provisioned by `BEHAVIOR_NEEDS_REMOTE`. Status: satisfied (`.opencode/tests-v2/with-test-home` and `__ensure_gitbucket` in `behaviors/helpers.sh` exist).

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1, SC-5, SC-6 | Phase 1, Phase 2 |
| R-2 | SC-3, SC-4 | Phase 2 |
| R-3 | SC-2 | Phase 1 |
| R-4 | SC-8, SC-9 | Phase 2 |
| R-5 | SC-10 | Phase 2, Phase 3 |
| R-6 | SC-11 | Phase 3 |
| R-7 | SC-12 | Phase 2 |
| R-8 | SC-13 | Phase 4 |
| R-9 | SC-7 | Phase 2 |
| R-10 | SC-14 | Phase 2 |
| R-11 | SC-15 | Phase 3 |
| R-12 | SC-16 | Phase 3 |
| R-13 | SC-17 | Phase 1 |
| R-14 | SC-18 | Phase 1 |
| R-15 | SC-1..SC-35 | All |
| R-16 | SC-17, SC-28, SC-31, SC-32, SC-33 | Phase 1, Phase 6, Phase 7 |
| R-17 | SC-1..SC-35 | All |
| R-18 | SC-19 | Phase 1 |
| R-19 | SC-20 | Phase 1 |
| R-20 | SC-21 | Phase 1 |
| R-21 | SC-22 | Phase 5 |
| R-22 | SC-23, SC-24, SC-30 | Phase 6 |
| R-23 | SC-25, SC-26 | Phase 6 |
| R-24 | SC-27 | Phase 6 |
| R-25 | SC-28 | Phase 6 |
| R-26 | SC-29 | Phase 6 |
| R-27 | SC-30 | Phase 6 |
| R-28 | SC-31 | Phase 7 |
| R-29 | SC-32 | Phase 7 |
| R-30 | SC-33 | Phase 7 |
| R-31 | SC-34 | Phase 6 |
| R-32 | SC-35 | Phase 6 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| spec-creation/SKILL.md | code | `.opencode/skills/spec-creation/SKILL.md` | read + grep during analysis |
| audit/SKILL.md | code | `.opencode/skills/audit/SKILL.md` | read + grep during analysis |
| spec-creation/tasks/analyze.md | code | `.opencode/skills/spec-creation/tasks/analyze.md` | read during analysis |
| spec-creation/tasks/validate.md | code | `.opencode/skills/spec-creation/tasks/validate.md` | read during analysis |
| audit/tasks/*-role.md | code | `.opencode/skills/audit/tasks/*-role.md` | read during analysis |
| audit/tasks/completion.md | code | `.opencode/skills/audit/tasks/completion.md` | read during analysis |
| reference/spec-structure-standards.md | doc | `.opencode/reference/spec-structure-standards.md` | read during analysis |
| reference/holistic-dimensions.yaml | config | `.opencode/reference/holistic-dimensions.yaml` | read during analysis |
| reference/skill-card-description-standards.md | doc | `.opencode/reference/skill-card-description-standards.md` | read during analysis |
| reference/task-card-structure-standards.md | doc | `.opencode/reference/task-card-structure-standards.md` | read during analysis |
| reference/cost-model-standards.md | doc | `.opencode/reference/cost-model-standards.md` | read during analysis |
| skildeck linter | code | `.opencode/tools/impl/skildeck/` | read during analysis |
| with-test-home | infra | `.opencode/tests-v2/with-test-home` | read during analysis |
| behaviors/helpers.sh | infra | `.opencode/tests-v2/behaviors/helpers.sh` | read during analysis |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Verifying the dispatch format costs one grep search. Skipping means agents keep dispatching with a deprecated format the reference docs forbid, and every downstream task inherits the routing defect.
- SC-2: Verifying the Task Files table removal costs one grep search. Skipping means the redundant table persists and duplicates the Workflows task references.
- SC-3: Verifying the Workflows structure costs one grep search. Skipping means audit dispatches keep routing through the deprecated TDT/Invocation/Tasks surface.
- SC-4: Verifying the TDT/Invocation/Tasks removal costs one grep search. Skipping means the deprecated routing surface persists alongside the new Workflows section.
- SC-5: Verifying the audit dispatch format (positive) costs one grep search. Skipping means agents keep using deprecated DiMo dispatch strings.
- SC-6: Verifying the audit dispatch format (negative) costs one grep search. Skipping means deprecated DiMo dispatch strings persist.
- SC-7: Verifying the description format costs one semantic sub-agent read. Skipping means the audit card keeps a deprecated description that misroutes skill selection.
- SC-8: Verifying role-card frontmatter names costs a per-file frontmatter check. Skipping means 40 name-vs-filename mismatches persist (28 flat + 12 subdirectory) and break skill-card validation.
- SC-9: Verifying role-card Task headings costs a per-file heading check. Skipping means `# Task:` headings diverge from filenames and misroute task execution.
- SC-10: Verifying cross-reference repoints costs one grep search. Skipping means agents resolve to non-existent monolithic task files.
- SC-11: Verifying reference task names costs one grep search. Skipping means reference docs keep pointing at non-existent inspect/decompose/write/check/file tasks.
- SC-12: Verifying the flattening costs a file-structure check. Skipping means subdirectory tasks and stub index files persist.
- SC-13: Verifying completion routing costs one grep search. Skipping means completion routes to a dangling verify-authorization reference.
- SC-14: Verifying the evaluator removal costs a file-absence check. Skipping means a redundant file with zero consumers persists.
- SC-15: Verifying taxonomy citations costs one grep search. Skipping means validate and audit read the taxonomy from a redirect source instead of the canonical one.
- SC-16: Verifying the missing-type rule costs one semantic sub-agent read. Skipping means a missing evidence-type declaration silently defaults to string and masks a defect.
- SC-17: Running the behavioral test costs minutes of execution time. Skipping means the analyze task accepts an unbound issue number and produces a spec anchored to a placeholder — a defect that ships to the issues-data branch and costs 1000× more to fix.
- SC-18: Verifying dynamic dimension loading costs one grep search. Skipping means validate evaluates a spec against a divergent 11-dimension set than the auditor uses.
- SC-19: Verifying the create exec-summary body routing costs one grep search. Skipping means the remote issue body drifts from the canonical exec-summary format and stakeholders lose a consistent body contract.
- SC-20: Verifying the forward-reference blockquote costs one grep search. Skipping means the remote issue body lacks the issues-data forward reference and consumers cannot locate the authoritative spec.
- SC-21: Verifying the post-push reconciliation sequencing costs one grep search. Skipping means the artifact URL in the remote body is stale or unverified after push.
- SC-22: Verifying the revise exec-summary regeneration costs one grep search. Skipping means a revised spec ships a stale remote exec-summary body that contradicts the authoritative local spec.
- SC-23: Verifying the spec-creation Workflows numbered-checkbox format costs one grep search. Skipping means the orchestrator cannot tell at a glance whether each workflow step is inline or dispatched, and the format drifts from the canonical checklist format.
- SC-24: Verifying the audit Workflows numbered-checkbox format costs one grep search. Skipping means the audit workflow steps lack the execution-mode sub-bullet and the orchestrator cannot distinguish inline from dispatched steps.
- SC-25: Verifying the task-card numbered-checkbox Procedure format costs one grep search. Skipping means task cards keep a non-canonical procedure format that diverges from the reference standard.
- SC-26: Verifying the task-card clean-room unit costs one semantic sub-agent read. Skipping means a fat task card whose procedure requires internal sub-agent dispatch remains unexecutable by its consumer (sub-agents have `task: deny`), producing a guaranteed defect on every dispatch.
- SC-27: Verifying dispatch-contract completeness costs one semantic sub-agent read. Skipping means a dispatched sub-agent searches for, guesses, or fabricates parameters it was not given — a defect that propagates into every downstream deliverable.
- SC-28: Running the linter behavioral test costs minutes of execution time. Skipping means the format rules are documented but not enforced, so the defects recur silently on every future skill-card edit.
- SC-29: Verifying markdown links costs a link-resolution check. Skipping means dangling links and misworded cross-references persist, and agents fail to load referenced content.
- SC-30: Verifying workflow clarity costs one grep search. Skipping means the orchestrator cannot tell whether a step is inline or dispatched, and the inline-vs-dispatch decision is left to guesswork.
- SC-31: Running the functional spec-creation pipeline behavioral test costs minutes of execution time. Skipping means the remediated spec-creation pipeline is never proven to work end-to-end — a mis-routing, a missing task card, a broken cross-reference, or a deprecated dispatch string ships undetected and every spec created through the pipeline inherits the defect.
- SC-32: Running the functional audit DiMo chain behavioral test costs minutes of execution time. Skipping means the remediated audit chain is never proven to work end-to-end — a role mis-routing to a missing task card or carrying an incomplete dispatch contract ships undetected and every audit verdict inherits the defect.
- SC-33: Verifying the shared test home with the gitbucket instance costs a behavioral test setup check. Skipping means the functional tests run in isolation without shared state, so the incremental build-up (the spec created by SC-31 becomes the fixture audited by SC-32) is lost and the remote API for remote-stub/issue-creation tests is unavailable.
- SC-34: Verifying the skill-card-description-standards Workflows numbered-checkbox format costs one grep search. Skipping means the reference doc keeps defining the old plain numbered-list format, so the skill cards (SC-23, SC-24) conform to a format the reference forbids and the linter (SC-28) has no canonical format to enforce — the format defect recurs silently.
- SC-35: Verifying the task-card-structure-standards Procedure numbered-checkbox format, clean-room unit mandate, and dispatch-contract completeness requirement costs one grep search. Skipping means the reference doc keeps defining plain numbered steps without the clean-room unit or dispatch-contract completeness mandates, so task cards (SC-25, SC-26) and dispatch contracts (SC-27) have no canonical standard to conform to and the linter (SC-28) cannot enforce them.

## 11. Edge Cases

- **Condition: A role-card filename does not match any of the four role names (Investigator/Validator/Evaluator/Arbiter).** Expected behavior: the name field and `# Task:` heading are repaired to match the filename per SC-8/SC-9. Resolution: the role-split file set is fixed; no new role names are introduced.
- **Condition: A cross-reference target file is genuinely absent (not just renamed).** Expected behavior: the reference is repointed to the actual role-split file per SC-10. Resolution: each repoint is verified against actual on-disk task files during implementation.
- **Condition: The canonical evidence-type taxonomy location changes after consolidation.** Expected behavior: both validate and audit load it dynamically per SC-15, so no hardcoded path breaks. Resolution: dynamic loading keeps consumers in sync.
- **Condition: An analyze dispatch receives an unbound/placeholder issue number.** Expected behavior: the analyze task BLOCKs per SC-17. Resolution: the orchestrator must provide a bound issue number; issue-number binding happens upstream via issue-operations-core creation and create.md remote-stub-first, not in analyze.md.
- **Condition: A spec omits an evidence-type declaration.** Expected behavior: validation is a hard FAIL routed to the remediation workflow per SC-16. Resolution: the spec is revised to declare an evidence type; no default-to-string escape hatch.
- **Condition: A downstream skill hardcodes the deprecated dispatch string.** Expected behavior: the deprecated format is removed outright per SC-1/SC-5/SC-6 (anti-bifurcation). Resolution: downstream consumers are updated in scope; no backwards-compat path is retained.
- **Condition: The behavioral SC-17 test cannot execute (model unavailable).** Expected behavior: the SC is reported FAIL per the functional/behavioral test substitution prohibition. Resolution: remediation-first protocol applies before any escalation.
- **Condition: The remote issue body exec-summary format drifts from issue-operations-core creation.md Step 5.** Expected behavior: create.md routes to the canonical format per SC-19. Resolution: create.md references the canonical format rather than duplicating it.
- **Condition: A revised spec changes the exec-summary content (Problem/Scope/Approach/Impact).** Expected behavior: revise.md regenerates the remote body per SC-22. Resolution: revision always refreshes the remote exec-summary body to match the authoritative local spec.
- **Condition: The push-artifacts.md reconciliation has not run before the remote body is finalized.** Expected behavior: the post-push reconciliation is sequenced after push-artifacts.md per SC-21. Resolution: create.md orders the reconciliation step after the push so the forward-reference URL is accurate.
- **Condition: A task card's procedure would require internal sub-agent dispatch.** Expected behavior: the task card is split into multiple task cards and the SKILL.md workflow dispatches each split task card as a separate step per SC-26. Resolution: no task card requires internal dispatch; sub-agents have `task: deny` hardcoded and cannot call `skill()`.
- **Condition: A workflow Context sub-bullet omits a parameter the task card's Dispatch Contract or Entry Criteria requires.** Expected behavior: the Context sub-bullet is completed to supply every required parameter per SC-27. Resolution: dispatch-contract completeness is verified for every task card; a dispatched sub-agent never searches for, guesses, or fabricates a parameter.
- **Condition: The skildeck linter flags a format violation in a skill card.** Expected behavior: the linter enforces the new format rules per SC-28. Resolution: the violation is fixed before the skill card is accepted; the linter prevents silent recurrence.
- **Condition: A markdown link in a skill or reference doc resolves to a non-existent target or uses a wrong relative path.** Expected behavior: the link is corrected to resolve to a real target with the correct relative path and `Read [Text](path)` wording per SC-29. Resolution: all links are verified during implementation.
- **Condition: A workflow step is ambiguous about whether it is inline or dispatched.** Expected behavior: the execution-mode sub-bullet makes the inline-vs-dispatch decision explicit per SC-30. Resolution: every workflow step carries an execution-mode indicator.
- **Condition: The functional spec-creation pipeline (SC-31) mis-routes, references a missing task card, or uses a deprecated dispatch string when dispatched end-to-end.** Expected behavior: the behavioral test asserts correct output and FAILs on any of these defects. Resolution: the drift-repair and format SCs (SC-1..SC-30) are implemented first; SC-31 verifies the remediated pipeline works end-to-end.
- **Condition: The functional audit DiMo chain (SC-32) mis-routes a role to a missing task card or carries an incomplete dispatch contract.** Expected behavior: the behavioral test asserts a valid verdict and FAILs on any of these defects. Resolution: the role-card and dispatch-contract SCs (SC-8, SC-9, SC-26, SC-27) are implemented first; SC-32 verifies the remediated chain works end-to-end.
- **Condition: The spec-creation and audit behavioral tests do not share a common test home with a test project and test gitbucket instance.** Expected behavior: SC-33 requires the shared with-test-home infrastructure with the gitbucket instance. Resolution: the tests are sequenced so later tests build upon the state created by earlier tests in an incremental fashion; the gitbucket instance provides the remote API for remote-stub/issue-creation tests.
- **Condition: The functional behavioral tests (SC-31, SC-32) cannot execute (model unavailable, gitbucket provisioning failure).** Expected behavior: the SCs are reported FAIL per the functional/behavioral test substitution prohibition. Resolution: remediation-first protocol applies before any escalation.
- **Condition: The reference docs (skill-card-description-standards.md, task-card-structure-standards.md) still define the old plain numbered-list format.** Expected behavior: the reference docs are updated to the numbered-checkbox format per SC-34/SC-35. Resolution: the reference docs are remediation targets in scope, not merely satisfied prerequisites — they must define the new format BEFORE the skill cards (SC-23, SC-24, SC-25) can conform and BEFORE the linter (SC-28) can enforce it.
- **Condition: A task card's Procedure in the reference doc is not specified as numbered-checkbox, or the clean-room unit / dispatch-contract completeness mandates are absent.** Expected behavior: the reference doc states the numbered-checkbox Procedure format, the clean-room unit mandate, and the dispatch-contract completeness requirement per SC-35. Resolution: the reference doc is updated so task cards (SC-25, SC-26) and dispatch contracts (SC-27) have a canonical standard to conform to and the linter (SC-28) can enforce it.

## 12. Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-06 | Item 6 (SC-6) RED/GREEN mismatch count corrected from 24 to 39; Cost Frame SC-6 reference updated to match. SC-6 goal (zero mismatches) unchanged. | Validation finding (correctness, dimension 4): live on-disk count is 39 role-card files (27 flat + 12 subdirectory), not 24. The prior count would cause the implementor to search for 24 mismatches and miss 15. | spec-creation validation pipeline |
| 2026-08-06 | Item 6 (SC-6) RED/GREEN mismatch count corrected from 39 to 40; SC-6 criterion and Cost Frame SC-6 reference updated to the verified on-disk count and breakdown (28 flat: 23 stale pre-rename role names + 5 empty `name` field; 12 subdirectory: all empty `name` field). SC-6 goal (zero mismatches) unchanged. | Validation finding (correctness, dimension 4): the previous revision set the count to 39, but the authoritative on-disk count of role-card files with a defective frontmatter `name` field is 40. The breakdown lets the implementor verify the count. | spec-creation validation pipeline |
| 2026-08-06 | SC-6 and Item 6 flat-file breakdown corrected from 23 stale + 5 empty = 28 flat to 24 stale + 4 empty = 28 flat. The 4 EMPTY flat files are exactly concern-separation-investigator, concern-separation-validator, plan-fidelity-investigator, behavioral-sc-evaluator. The 24 STALE flat files carry pre-rename role names (generator/knowledge-supporter/path-provider) in their frontmatter `name`. plan-fidelity-validator.md carries `name: plan-fidelity-knowledge-supporter` (STALE, not empty). SC-6's goal (zero mismatches) and the aggregate total (40) are unchanged. | Validation finding (correctness, dimension 4): the previous breakdown mislabeled plan-fidelity-validator.md as empty; it is stale. Live on-disk verification of all 28 flat role files' frontmatter confirms 24 stale + 4 empty. | spec-creation validation pipeline |
| 2026-08-06 | Compound SCs decomposed into atomic SCs per validate.md Step 3.3. SC-3 split into SC-3 (Workflows present) + SC-4 (TDT/Invocation/Tasks absent). SC-4 split into SC-5 (canonical dispatch present) + SC-6 (deprecated DiMo strings absent). SC-6 split into SC-8 (frontmatter name matches filename) + SC-9 (`# Task:` heading matches filename). All SCs renumbered to 18; Requirements→SC mapping, traceability table, Item list (RED/GREEN), sc-summary.yaml plan_item numbering, Cost Frame, and Edge Cases references updated to remain consistent. Evidence types unchanged (string/structural; behavioral only for the issue-anchoring SC-17). | Validation finding (atomicity, compound-SC check): SC-3, SC-4, and SC-6 each bundled multiple independently verifiable claims joined by "and" (positive + negative assertions, or name-field + heading assertions). Each compound SC must be decomposed into single independently verifiable atomic SCs. | spec-creation validation pipeline |
| 2026-08-06 | Traceability table corrected: SC-6 (deprecated DiMo strings absent — the negative counterpart of SC-5) mapped to R-1; SC-9 (`# Task:` heading matches filename — the heading counterpart of SC-8) mapped to R-4. | Validation finding (traceability): SC-6 and SC-9 were absent from the specific requirement rows (R-1..R-14) and covered only by the catch-all R-15/R-17. Each SC must map to the specific requirement it implements. | spec-creation validation pipeline |
| 2026-08-06 | Evidence types for SC-7 and SC-16 corrected from `string` to `semantic`. Verification methods rewritten to specify sub-agent read + analytical judgment. sc-summary.yaml, Items 7 and 16, and Cost Frame SC-7/SC-16 updated to stay consistent. | Validation finding (EVIDENCE_TYPE_MISMATCH): SC-7 and SC-16 declared evidence type `string` but their verification methods are "read the file and verify format/rule via analytical judgment" — which is `semantic` (sub-agent read + judgment), not `string` (grep/pattern match) per the taxonomy. Option (a) applied: evidence type corrected to match the actual verification method. | spec-creation validation pipeline |
| 2026-08-09 | Re-scoped SC-17 to analyze.md-only (BLOCK on unbound issue number). Removed remote-stub-first from SC-17, R-13, Item 17, and the SC-17 edge case: issue-number binding is handled upstream by issue-operations-core creation and create.md, not analyze.md. Added SC-19 (create routes exec-summary body format per creation.md Step 5), SC-20 (create includes forward-reference blockquote / issues-data link), SC-21 (post-push reconciliation sequenced after push-artifacts.md), SC-22 (revise regenerates exec-summary body). Added R-18..R-21, Items 19-22, Cost Frame SC-19..SC-22, and edge cases. Updated Traceability (R-18..R-21; catch-all R-15/R-17 now SC-1..SC-22), sc-summary.yaml plan_item numbering to 22. | Revision request: SC-17 bundled two distinct concerns across two task files (analyze.md BLOCK on unbound issue number, and create.md remote-stub-first + exec-summary remote body). These must be split because remote-stub-first is not analyze.md's job — the issue number is bound upstream by issue-operations-core creation (runs before analyze.md). The exec-summary body format already exists in issue-operations-core/tasks/creation.md Step 5. The post-push reconciliation is sequenced after issue-operations/platforms/local/tasks/push-artifacts.md. | developer (revision request) |
| 2026-08-09 | Expanded the spec scope to total remediation of the spec-writer (spec-creation) and spec-auditor (audit) skills plus the consolidated `.opencode/reference/` standards. Added SC-23..SC-30, R-22..R-27, Items 23-30, Cost Frame SC-23..SC-30, and edge cases. Re-scoped R-15 to permit `.opencode/tools/impl/skildeck/` changes while still excluding application `src/` code. Updated Problem Statement, Approach Chosen, Key Design Decisions, Not Included, Dependencies, Traceability (R-22..R-27; catch-all R-15/R-17 now SC-1..SC-30), and sc-summary.yaml plan_item numbering to 30. Evidence types: linter changes (SC-28) are behavioral; format checks (SC-23, SC-24, SC-25, SC-29, SC-30) are string; task-card clean-room (SC-26) and dispatch-contract completeness (SC-27) are semantic. | Revision request (brainstorming session): incorporate six new requirement areas — (1) numbered-checkbox Workflows format with execution-mode sub-bullets for both main skill cards; (2) numbered-checkbox task-card Procedure format designed for non-task-capable sub-agents, with fat task cards split; (3) dispatch-contract completeness so every workflow Context sub-bullet supplies every parameter a task card needs; (4) linter enforcement of the new format rules via the skildeck linter; (5) markdown link verification across the two skills and reference docs; (6) workflow clarity so the orchestrator knows step-by-step what to do and whether each step is inline or dispatched. | developer (revision request) |
| 2026-08-09 | Added mandatory functional behavioral SCs SC-31..SC-33, R-28..R-30, Items 31-33, Cost Frame SC-31..SC-33, and edge cases. Updated Problem Statement (functional end-to-end verification paragraph), Approach Chosen, Key Design Decisions, Not Included, Dependencies (with-test-home + GitBucket instance), Traceability (R-28..R-30; catch-all R-15/R-17 now SC-1..SC-33; R-16 extended to SC-31..SC-33), and sc-summary.yaml plan_item numbering to 33. Evidence types: all three new SCs are behavioral. | Revision request: the current spec has only two narrow behavioral SCs (SC-17 analyze BLOCK on unbound issue number, SC-28 skildeck linter enforcement). The spec lacks behavioral SCs that run the remediated skills end-to-end to prove they actually work — not just that they are well-formed. The goal is a working set of spec skills. Add functional behavioral SCs for spec-creation and audit that run the remediated skills end-to-end against a fixture and assert correct output (no mis-routing, no missing task cards, no broken cross-references, no deprecated dispatch strings). The behavioral tests SHALL use a common test home with a test project and a test gitbucket instance, sequenced so later tests build upon the state created by earlier tests in an incremental fashion. | developer (revision request) |
| 2026-08-09 | Added dependency-prerequisite SCs SC-34..SC-35, R-31..R-32, Items 34-35, Cost Frame SC-34..SC-35, and edge cases. Updated Problem Statement, Root Cause / Motivation, Approach Chosen, Alternatives Considered, Key Design Decisions, Not Included, Dependencies (the two reference docs are now remediation targets in scope, not merely satisfied prerequisites), Traceability (R-31..R-32; catch-all R-15/R-17 now SC-1..SC-35), and sc-summary.yaml plan_item numbering to 35. Evidence types: both new SCs are string. | Revision request: the spec's SC-23, SC-24, SC-25 require the numbered-checkbox Workflows/task-card format, and SC-28 requires the skildeck linter to enforce it. But the reference docs still define the OLD numbered-list format (not checkbox), and the spec has NO SC updating them to the new format. This is a dependency prerequisite: the reference docs must be updated to define the new format BEFORE the skill cards can conform and BEFORE the linter can enforce it. Add SC-34 (skill-card-description-standards.md §7 Workflows → numbered-checkbox with execution-mode sub-bullet) and SC-35 (task-card-structure-standards.md Procedure → numbered-checkbox with clean-room unit mandate and dispatch-contract completeness requirement). | developer (revision request) |

---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)
