> **Full spec and artifacts: [`.opencode/.issues/2256/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/2256/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2256/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## 1. Intent and Executive Summary

### Problem Statement

The plan skill card set (`plan`, `solve`, `writing-plans`, `audit` plan-fidelity roles) and the plan-structure reference documents carry six distinct defects that cause plan creation and plan-fidelity auditing to route, invoke, and evaluate incorrectly. The plan-structure authority is split between two reference documents that declare conflicting frontmatter. The `writing-plans` research step invokes the `solve` and `plan` tools with broken CLI arguments. The `plan` and `solve` skill descriptions share identical scope language that misroutes agent-intent dispatch. The plan-fidelity audit chain references a phantom clean-room plan that is never generated. And the `writing-plans` skill files contain internal inconsistencies (task count, cycle terminology, YAML blocks, contract symmetry, unwired task, lifecycle target, path resolution, auth gating) that compound across every plan produced.

### Root Cause / Motivation

These defects are the residual of multiple migrations (flat-architecture refactor, skill/task split, reference consolidation, contract-template standardization) applied to the plan skill deck without a corresponding reconciliation pass. Because agent-facing text is consumed as routing instructions, each defect is a guaranteed defect vector: a split authority means consumers read a competing plan-artifact spec; a broken tool invocation fails at runtime during every plan-creation research step; a scope collision means agents misroute between `plan` and `solve`; a phantom clean-room basis makes plan-fidelity evaluate against a plan that does not exist; and writing-plans internal inconsistencies produce asymmetric contracts, dangling references, and an unwired task. The defects must be resolved now because they compound — every plan created or audited through the defective cards inherits the defect.

### Approach Chosen

Apply exactly ONE prescriptive resolution per finding, each mapped one-to-one to a success criterion. P1 resolves the split plan-structure authority to `plan-structure-standards.md` as the single canonical authority, removes the `dispatch` field, and strings `plan_schema_version`. P4 fixes the three runtime-broken `solve`/`plan` tool invocations in the research step and adds a BLOCK-on-incomplete-spec gate with diagnose→remediate→escalate. P3 resolves the plan/solve description scope collision and clarifies state/fallback ownership. P5 removes the phantom clean-room basis and adopts a single-plan model in the plan-fidelity chain. P6 fixes the writing-plans internal inconsistencies (task count, cycle terminology, YAML blocks, contract symmetry, verify-plan-pipeline wiring, completion lifecycle, sc-summary path, auth gating).

### Alternatives Considered & Why Discarded

- **Leave the defects in place and rely on agent judgment to route correctly.** Discarded: agent-facing text is consumed as routing instructions, not advisory prose. An agent cannot reliably compensate for a broken tool invocation, a competing authority, or a phantom comparison basis; each defect is a guaranteed defect vector, not a cosmetic inconsistency.
- **Introduce backwards-compatible dual paths (accept both old and new plan-artifact references, both old and new tool invocations).** Discarded: the anti-bifurcation mandate forbids dual-format agent-facing instructions. A backwards-compat path leaves the defective path live, so agents continue to follow it and the defect persists.

### Key Design Decisions

- **Single canonical plan-structure authority** in `plan-structure-standards.md`, with `plan-artifact-format.md` deleted. Tradeoff: a single source of truth requires all consumers to be updated in scope, but eliminates the competing-authority defect.
- **`plan_schema_version` is a string type.** Tradeoff: aligning to the string form used by the plan-artifact spec removes the integer/string mismatch, at the cost of a one-time type change for any consumer that reads it.
- **Plan and solve skill descriptions are mutually exclusive in scope.** Tradeoff: narrowing the `plan` description to plan-artifact generation and narrowing `solve` to constraint solving removes the misrouting collision, at the cost of requiring agents to dispatch precisely.
- **Plan-fidelity uses a single-plan model.** Tradeoff: removing the phantom clean-room comparison basis aligns the audit criteria with the actual single plan produced, at the cost of losing the (never-functional) clean-room cross-check.
- **Output contract templates include `blocker_reason`.** Tradeoff: adding the field to all 9 output templates for symmetry with task result contracts ensures contract templates and task result contracts declare the same fields, at the cost of updating every template.

### User Intent / Original Prompt

The spec is the plan skill card remediation covering P1-P6 scope: resolve the split plan-structure canon, fix runtime-broken Z3/planner tool invocations, resolve the plan/solve scope collision, remove the phantom clean-room plan-fidelity basis, and fix writing-plans internal inconsistencies.

## 2. Not Included

- **`src/` code changes** — All affected files are agent-facing markdown in `.opencode/`; no runtime code changes.
- **`tools/solve` or `tools/plan` CLI changes** — The scope is remediation of task-file invocations, not the tool interfaces. Tool CLIs are unchanged (REQ-CON-2).
- **`unified-planning` or Z3 solver implementation changes** — No changes to the underlying planner or solver internals (REQ-NON-1).
- **`spec-creation` skill changes** — The sc-summary.yaml path inconsistency is a writing-plans research.md issue, not a spec-creation change (REQ-NON-2).
- **New runtime features** — This is a documentation/skill-card remediation spec; no new runtime behavior (REQ-NON-3).

> **Analytical artifacts remediation (SC-19):** the analytical artifacts directory (`.opencode/.issues/2256/artifacts/`) is absent — blast-radius, concern-map, code-path-inventory, cross-cutting-matrix, interface-compatibility, state-analysis, and testability-assessment artifacts are not present, so artifact cross-reference against them is not possible. Per the developer directive ("any note is a remediation requirement — no exceptions"), this is converted to a remediation requirement. The seven analytical artifacts SHALL be generated retroactively and stored at `.opencode/.issues/2256/artifacts/` so the artifact cross-reference check can be performed (SC-19, R-22).

## 3. Success Criteria

> **Evidence-type taxonomy alignment (post-#2254):** #2256's evidence-type usage (structural/behavioral) SHALL cite the same canonical evidence-type taxonomy reference that #2254 establishes (SC-15/16). Both specs use one taxonomy source — #2256 does not introduce a competing evidence-type vocabulary.

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1a | `plan-artifact-format.md` SHALL be deleted (file absent from the codebase). | structural | file inspection — confirm `plan-artifact-format.md` is absent from the codebase |
| SC-1b | `reference/plan-structure-standards.md` SHALL be the single canonical plan-structure authority, referenced by `writing-plans/tasks/create.md` and the plan-fidelity tasks. | structural | file inspection — confirm `plan-structure-standards.md` is referenced by `writing-plans/tasks/create.md` and the plan-fidelity tasks |
| SC-1c | `writing-plans/SKILL.md` File Structure SHALL no longer list `plan-artifact-format.md`. | structural | file inspection — confirm `writing-plans/SKILL.md` File Structure no longer lists `plan-artifact-format.md` |
| SC-2 | The `dispatch: [<skill-names>]` field SHALL be removed from the plan frontmatter in `plan-structure-standards.md`. | structural | file inspection — confirm no plan frontmatter declares `dispatch:` |
| SC-3 | `plan_schema_version` SHALL be a string type in `plan-structure-standards.md` (aligning integer `1` with string `"1.0"`). | structural | file inspection — confirm `plan_schema_version` is a quoted string |
| SC-4 | The `solve model` invocation in `writing-plans/tasks/research.md` SHALL use a valid Z3 query expression, not `sat`. | behavioral | opencode run — dispatch a real-domain prompt that triggers research.md Step 10 and assert stderr shows a valid solve model invocation |
| SC-5 | The `solve check` invocation in `writing-plans/tasks/research.md` SHALL use a real solve state file, not the `state-analysis.yaml` analytical artifact. | behavioral | opencode run — dispatch a real-domain prompt that triggers research.md Step 11 and assert stderr shows solve check against a real state file |
| SC-6 | The `plan plan` invocation in `writing-plans/tasks/research.md` SHALL use the `--problem` flag, not `--contract-path`/`--output`. | behavioral | opencode run — dispatch a real-domain prompt that triggers research.md Step 12 and assert stderr shows plan plan with `--problem` |
| SC-7 | `writing-plans/tasks/research.md` SHALL include a BLOCK-on-incomplete-spec gate with diagnose→remediate→escalate before Z3/planner invocation. | behavioral | opencode run — dispatch a real-domain prompt with an incomplete spec and assert stderr shows the research step BLOCKs rather than invoking tools |
| SC-8 | `plan/SKILL.md` and `solve/SKILL.md` descriptions SHALL no longer share the scope language `validating workflow constraints, verifying state against contracts, proving theorems, or checking dependency ordering`. | structural | file inspection — confirm each description is scoped to its own domain |
| SC-9 | Each state/fallback task SHALL have a single owning skill between `plan` and `solve`. | structural | file inspection — confirm no state/fallback task is claimed by both skills |
| SC-10a | The plan-fidelity tasks (evaluator, arbiter, investigator, validator) SHALL use a single-plan evaluation model (plan-vs-spec), removing the phantom clean-room basis. | structural | file inspection — grep plan-fidelity tasks for absence of clean-room references. **Note (post-#2254):** SC-10a/10b build on the post-#2254 role-card state (naming already repaired, cross-references already repointed by #2254 SC-8/9/10). #2256 does NOT duplicate #2254's role-card work. |
| SC-10b | The plan-fidelity tasks SHALL NOT reference the non-existent `plan-fidelity.md` main task file. | structural | file inspection — grep plan-fidelity tasks for absence of `plan-fidelity.md`. **Note (post-#2254):** cross-references are already repointed by #2254 SC-8/9/10; #2256 only removes the residual `plan-fidelity.md` reference without redoing #2254's role-card naming work. |
| SC-11 | `writing-plans/SKILL.md` SHALL declare the correct task count (9, not 7) matching the actual task files. | structural | file inspection — confirm SKILL.md task count matches the 9 task files |
| SC-12 | `writing-plans` cycle terminology SHALL be consistent with `plan-structure-standards.md` and `091-incremental-build.md` (per-item TDD cycle). | structural | file inspection — confirm consistent per-item cycle terminology |
| SC-13 | `writing-plans/tasks/create.md` body SHALL contain no JSON/YAML code blocks. | structural | file inspection — confirm the Result Contract section has no YAML code block |
| SC-14 | `writing-plans/contracts/*-output.yaml` SHALL include the `blocker_reason` field, symmetric with task result contracts. | structural | file inspection — confirm all 9 output contract templates include `blocker_reason` |
| SC-15 | `verify-plan-pipeline` SHALL be wired into the writing-plans workflow sequence. | structural | file inspection — confirm verify-plan-pipeline appears in a workflow sequence |
| SC-16a | `writing-plans/tasks/completion.md` SHALL route the lifecycle event to the `completion-core` lifecycle manifest at `{project_root}/tmp/{issue-N}/lifecycle.yaml` (metadata, append-only). | structural | file inspection — confirm completion.md routes the lifecycle event to the completion-core manifest |
| SC-16b | `writing-plans/tasks/completion.md` SHALL report the executive summary in chat. | structural | file inspection — confirm completion.md reports the executive summary in chat |
| SC-16c | `writing-plans/tasks/completion.md` SHALL NOT append lifecycle events to `plan.md` or `spec.md`. | structural | file inspection — confirm completion.md does not append lifecycle events to plan.md/spec.md |
| SC-16d | `writing-plans/tasks/completion.md` SHALL NOT post lifecycle events as human-facing issue comments (non-substantive per the substantive-comment gate). | structural | file inspection — confirm completion.md does not post lifecycle events as issue comments |
| SC-17 | `writing-plans/tasks/research.md` sc-summary.yaml path SHALL match the spec-creation write path. | structural | file inspection — confirm research.md reads sc-summary.yaml from the correct path. **Note (post-#2254):** the spec-creation write path is the POST-#2254 path (after #2254 SC-17/18 changes to the spec-creation analyze/validate write paths). Verification MUST confirm against the post-#2254 spec-creation behavior. |
| SC-18 | `writing-plans/tasks/handoff.md` SHALL reference an existing approval-gate task, not the non-existent `verify-authorization`. | structural | file inspection — confirm handoff.md references apply-label, resolve-scope, or route |
| SC-19 | The analytical artifacts (blast-radius, concern-map, code-path-inventory, cross-cutting-matrix, interface-compatibility, state-analysis, testability-assessment) SHALL be generated and stored at `.opencode/.issues/2256/artifacts/`, so the artifact cross-reference check can be performed. | structural | file inspection — confirm all 7 analytical artifact files exist at `.opencode/.issues/2256/artifacts/` |

## 4. Requirements

- R-1a. `plan-artifact-format.md` SHALL be deleted (file absent from the codebase).
- R-1b. `reference/plan-structure-standards.md` SHALL be the single canonical plan-structure authority.
- R-1c. `writing-plans/SKILL.md` File Structure SHALL no longer list `plan-artifact-format.md`.
- R-2. The `dispatch` field SHALL be removed from the plan frontmatter in `plan-structure-standards.md`.
- R-3. `plan_schema_version` SHALL be a string type in `plan-structure-standards.md`.
- R-4. The `solve model` invocation in `research.md` SHALL use a valid Z3 query expression.
- R-5. The `solve check` invocation in `research.md` SHALL use a real solve state file.
- R-6. The `plan plan` invocation in `research.md` SHALL use the `--problem` flag.
- R-7. `research.md` SHALL include a BLOCK-on-incomplete-spec gate with diagnose→remediate→escalate before Z3/planner invocation.
- R-8. `plan/SKILL.md` and `solve/SKILL.md` descriptions SHALL be mutually exclusive in scope.
- R-9. Each state/fallback task SHALL have a single owning skill between `plan` and `solve`.
- R-10a. Plan-fidelity tasks SHALL use a single-plan evaluation model (plan-vs-spec), removing the phantom clean-room basis.
- R-10b. Plan-fidelity tasks SHALL NOT reference the non-existent `plan-fidelity.md` main task file.
- R-11. `writing-plans/SKILL.md` SHALL declare the correct task count (9).
- R-12. `writing-plans` cycle terminology SHALL be consistent with `plan-structure-standards.md` and `091-incremental-build.md`.
- R-13. `writing-plans/tasks/create.md` SHALL contain no JSON/YAML code blocks in its body.
- R-14. `writing-plans/contracts/*-output.yaml` SHALL include the `blocker_reason` field.
- R-15. `verify-plan-pipeline` SHALL be wired into the writing-plans workflow sequence.
- R-16a. `writing-plans/tasks/completion.md` SHALL route the lifecycle event to the `completion-core` lifecycle manifest at `{project_root}/tmp/{issue-N}/lifecycle.yaml` (metadata, append-only).
- R-16b. `writing-plans/tasks/completion.md` SHALL report the executive summary in chat.
- R-16c. `writing-plans/tasks/completion.md` SHALL NOT append lifecycle events to `plan.md` or `spec.md`.
- R-16d. `writing-plans/tasks/completion.md` SHALL NOT post lifecycle events as human-facing issue comments (non-substantive per the substantive-comment gate).
- R-17. `writing-plans/tasks/research.md` sc-summary.yaml path SHALL match the spec-creation write path.
- R-18. `writing-plans/tasks/handoff.md` SHALL reference an existing approval-gate task.
- R-19. No `src/` code changes; all changes SHALL be confined to agent-facing skill/task/reference/contract files under `.opencode/`.
- R-20. No changes SHALL be made to `tools/solve` or `tools/plan` CLI interfaces.
- R-21. No new runtime features SHALL be introduced; this is a documentation/skill-card remediation.
- R-22. The seven analytical artifacts SHALL be generated retroactively and stored at `.opencode/.issues/2256/artifacts/`.

## 5. Items

### Item 1 (SC-1a): Delete plan-artifact-format.md

- RED: file inspection asserts `plan-artifact-format.md` is absent from the codebase — fails on current presence
- GREEN: delete `skills/writing-plans/reference/plan-artifact-format.md`
- verify: file inspection conformance
- commit: `skills/writing-plans/reference/plan-artifact-format.md` (deletion)

### Item 2 (SC-1b): Establish plan-structure-standards.md as the single authority

- RED: file inspection asserts `plan-structure-standards.md` is referenced by `create.md` and plan-fidelity tasks as the sole authority — fails on current split
- GREEN: update consumers to reference `reference/plan-structure-standards.md` as the single canonical authority
- verify: file inspection conformance
- commit: `reference/plan-structure-standards.md`, `skills/writing-plans/tasks/create.md`, `skills/audit/tasks/plan-fidelity-*.md`

### Item 3 (SC-1c): Remove plan-artifact-format.md from SKILL.md File Structure

- RED: file inspection asserts `writing-plans/SKILL.md` File Structure no longer lists `plan-artifact-format.md` — fails on current listing
- GREEN: remove `plan-artifact-format.md` from the `writing-plans/SKILL.md` File Structure listing
- verify: file inspection conformance
- commit: `skills/writing-plans/SKILL.md`

### Item 4 (SC-2): Remove the dispatch field from plan frontmatter

- RED: file inspection asserts no plan frontmatter declares `dispatch:` — fails on current `plan-structure-standards.md`
- GREEN: remove the `dispatch: [<skill-names>]` field from the plan frontmatter
- verify: file inspection conformance
- commit: `reference/plan-structure-standards.md`

### Item 5 (SC-3): String plan_schema_version

- RED: file inspection asserts `plan_schema_version` is a string — fails on current integer `1`
- GREEN: change `plan_schema_version: 1` to `plan_schema_version: "1.0"` (string)
- verify: file inspection conformance
- commit: `reference/plan-structure-standards.md`

### Item 6 (SC-4): Fix the solve model invocation in research.md

- RED: behavioral test asserts research.md Step 10 uses a valid Z3 query expression, not `sat` — fails on current invocation
- GREEN: fix the `solve model --query sat` invocation to pass a valid Z3 query expression
- verify: behavioral conformance via opencode run
- commit: `skills/writing-plans/tasks/research.md`

### Item 7 (SC-5): Fix the solve check invocation in research.md

- RED: behavioral test asserts solve check uses a real solve state file, not `state-analysis.yaml` — fails on current invocation
- GREEN: fix the `solve check --state-path state-analysis.yaml` invocation to point at a real solve state file
- verify: behavioral conformance via opencode run
- commit: `skills/writing-plans/tasks/research.md`

### Item 8 (SC-6): Fix the plan plan invocation in research.md

- RED: behavioral test asserts plan plan uses the `--problem` flag, not `--contract-path`/`--output` — fails on current invocation
- GREEN: fix the `plan plan --contract-path/--output` invocation to use `--problem`
- verify: behavioral conformance via opencode run
- commit: `skills/writing-plans/tasks/research.md`

### Item 9 (SC-7): Add BLOCK-on-incomplete-spec gate to research.md

- RED: behavioral test asserts research.md BLOCKs on incomplete spec before tool invocation — fails on current absence
- GREEN: add a BLOCK-on-incomplete-spec gate with diagnose→remediate→escalate before the Z3/planner invocations
- verify: behavioral conformance via opencode run
- commit: `skills/writing-plans/tasks/research.md`

### Item 10 (SC-8): Resolve plan/solve scope collision in skill descriptions

- RED: file inspection asserts plan and solve descriptions no longer share the colliding scope language — fails on current shared language
- GREEN: rewrite `plan/SKILL.md` and `solve/SKILL.md` descriptions to be mutually exclusive
- verify: file inspection conformance
- commit: `skills/plan/SKILL.md`, `skills/solve/SKILL.md`

### Item 11 (SC-9): Clarify state/fallback ownership between plan and solve

- RED: file inspection asserts each state/fallback task has a single owning skill — fails on current overlap
- GREEN: clarify state/fallback ownership so no task is claimed by both skills
- verify: file inspection conformance
- commit: `skills/plan/SKILL.md`, `skills/solve/SKILL.md`

### Item 12 (SC-10a): Adopt single-plan model in plan-fidelity

- RED: file inspection asserts plan-fidelity tasks have no clean-room references — fails on current phantom basis
- GREEN: adopt a single-plan evaluation model (plan-vs-spec) in evaluator/arbiter/investigator/validator
- verify: file inspection conformance
- commit: `skills/audit/tasks/plan-fidelity-{evaluator,arbiter,investigator,validator}.md`

### Item 13 (SC-10b): Remove plan-fidelity.md reference

- RED: file inspection asserts plan-fidelity tasks have no `plan-fidelity.md` reference — fails on current reference
- GREEN: remove the reference to the non-existent `plan-fidelity.md` main task file
- verify: file inspection conformance
- commit: `skills/audit/tasks/plan-fidelity-{evaluator,arbiter,investigator,validator}.md`

### Item 14 (SC-11): Fix writing-plans task count claim

- RED: file inspection asserts SKILL.md task count is 9 — fails on current `7`
- GREEN: update `writing-plans/SKILL.md` task count to 9
- verify: file inspection conformance
- commit: `skills/writing-plans/SKILL.md`

### Item 15 (SC-12): Fix writing-plans cycle terminology

- RED: file inspection asserts consistent per-item cycle terminology — fails on current per-task/per-item mismatch
- GREEN: normalize cycle terminology in `writing-plans/SKILL.md` and `tasks/create.md` to per-item TDD cycle
- verify: file inspection conformance
- commit: `skills/writing-plans/SKILL.md`, `skills/writing-plans/tasks/create.md`

### Item 16 (SC-13): Remove YAML code block from create.md

- RED: file inspection asserts create.md body has no JSON/YAML code blocks — fails on current Result Contract YAML block
- GREEN: remove the YAML code block from `writing-plans/tasks/create.md` body
- verify: file inspection conformance
- commit: `skills/writing-plans/tasks/create.md`

### Item 17 (SC-14): Add blocker_reason to output contract templates

- RED: file inspection asserts all 9 output contract templates include `blocker_reason` — fails on current absence
- GREEN: add `blocker_reason` to `writing-plans/contracts/*-output.yaml` templates
- verify: file inspection conformance
- commit: `skills/writing-plans/contracts/*-output.yaml`

### Item 18 (SC-15): Wire verify-plan-pipeline into the workflow

- RED: file inspection asserts verify-plan-pipeline appears in a workflow sequence — fails on current unwired state
- GREEN: wire `verify-plan-pipeline` into the `writing-plans/SKILL.md` workflow sequence
- verify: file inspection conformance
- commit: `skills/writing-plans/SKILL.md`

### Item 19 (SC-16a): Route completion lifecycle event to the completion-core manifest

- RED: file inspection asserts completion.md routes the lifecycle event to the `completion-core` lifecycle manifest — fails on current issue-body/plan-file mismatch
- GREEN: normalize `writing-plans/tasks/completion.md` to route the lifecycle event to the `completion-core` lifecycle manifest at `{project_root}/tmp/{issue-N}/lifecycle.yaml` (metadata, append-only)
- verify: file inspection conformance
- commit: `skills/writing-plans/tasks/completion.md`

### Item 20 (SC-16b): Report executive summary in chat

- RED: file inspection asserts completion.md reports the executive summary in chat — fails on current absence
- GREEN: add the executive summary report to chat in `writing-plans/tasks/completion.md`
- verify: file inspection conformance
- commit: `skills/writing-plans/tasks/completion.md`

### Item 21 (SC-16c): Do not append lifecycle events to plan.md or spec.md

- RED: file inspection asserts completion.md does not append lifecycle events to `plan.md` or `spec.md` — fails on current issue-body/plan-file append
- GREEN: remove lifecycle-event appends to `plan.md`/`spec.md` in `writing-plans/tasks/completion.md`
- verify: file inspection conformance
- commit: `skills/writing-plans/tasks/completion.md`

### Item 22 (SC-16d): Do not post lifecycle events as human-facing issue comments

- RED: file inspection asserts completion.md does not post lifecycle events as issue comments — fails on current comment posting
- GREEN: remove lifecycle-event posting as human-facing issue comments (non-substantive per the substantive-comment gate) in `writing-plans/tasks/completion.md`
- verify: file inspection conformance
- commit: `skills/writing-plans/tasks/completion.md`

### Item 23 (SC-17): Fix sc-summary.yaml path resolution

- RED: file inspection asserts research.md sc-summary.yaml path matches the spec-creation write path — fails on current mismatch
- GREEN: fix the sc-summary.yaml path in `writing-plans/tasks/research.md`
- verify: file inspection conformance
- commit: `skills/writing-plans/tasks/research.md`

### Item 24 (SC-18): Fix auth gating in handoff.md

- RED: file inspection asserts handoff.md references an existing approval-gate task — fails on current `verify-authorization`
- GREEN: repoint `writing-plans/tasks/handoff.md` to an existing approval-gate task
- verify: file inspection conformance
- commit: `skills/writing-plans/tasks/handoff.md`

### Item 25 (SC-19): Generate the analytical artifacts retroactively

- RED: file inspection asserts the 7 analytical artifact files exist at `.opencode/.issues/2256/artifacts/` — fails on current absence
- GREEN: generate the analytical artifacts (blast-radius, concern-map, code-path-inventory, cross-cutting-matrix, interface-compatibility, state-analysis, testability-assessment) and store them at `.opencode/.issues/2256/artifacts/`
- verify: file inspection conformance — confirm all 7 analytical artifact files exist
- commit: `.opencode/.issues/2256/artifacts/*`

## 6. Dependencies

- **Prerequisite: issue #2254 (spec-writer/spec-audit skill card remediation)** — Relationship: #2256 builds on #2254's post-implementation state. #2254 consolidates the evidence-type taxonomy into a single canonical reference document (SC-15/16), repairs plan-fidelity role-card naming and repoints cross-references (SC-8/9/10), and changes the spec-creation analyze/validate write paths (SC-17/18). #2256's SCs that touch these areas MUST be consistent with the post-#2254 state. **Status: Prerequisite (assumed implemented).**
- **Reference: `reference/plan-structure-standards.md`** — Relationship: canonical plan-structure authority established in SC-1a/1b/1c/2/3 (with `plan-artifact-format.md` deleted); must be the single source before plan-fidelity (SC-10a/10b) reads it. **Status: Pending (in scope).**
- **Reference: `091-incremental-build.md` guideline** — Relationship: defines per-item TDD cycle terminology; SC-12 must conform to it. **Status: Satisfied (existing guideline).**
- **Reference: `skills/solve/SKILL.md` and `skills/plan/SKILL.md`** — Relationship: SC-4/5/6 fix research.md invocations against the actual tool CLIs; SC-8/9 clarify their descriptions. **Status: Pending (in scope).**
- **Reference: `skills/writing-plans/tasks/research.md`** — Relationship: edited by both P4 (SC-4/5/6/7) and P6 (SC-17); cross-cutting file. **Status: Pending (in scope).**
- **Reference: `skills/audit/tasks/plan-fidelity-*.md`** — Relationship: SC-10a/10b remove the phantom clean-room basis and `plan-fidelity.md` reference. **Status: Pending (in scope).**
- **Reference: `skills/writing-plans/SKILL.md`** — Relationship: edited by SC-11/12/15 (task count, terminology, verify-plan-pipeline wiring). **Status: Pending (in scope).**
- **Analytical artifacts (`.opencode/.issues/2256/artifacts/`)** — Relationship: SC-19 requires all seven analytical artifacts to exist at this path so the artifact cross-reference check can run. **Status: Absent (in scope, generated by SC-19).**

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1a | SC-1a | P1 |
| R-1b | SC-1b | P1 |
| R-1c | SC-1c | P1 |
| R-2 | SC-2 | P1 |
| R-3 | SC-3 | P1 |
| R-4 | SC-4 | P4 |
| R-5 | SC-5 | P4 |
| R-6 | SC-6 | P4 |
| R-7 | SC-7 | P4 |
| R-8 | SC-8 | P3 |
| R-9 | SC-9 | P3 |
| R-10a | SC-10a | P5 |
| R-10b | SC-10b | P5 |
| R-11 | SC-11 | P6 |
| R-12 | SC-12 | P6 |
| R-13 | SC-13 | P6 |
| R-14 | SC-14 | P6 |
| R-15 | SC-15 | P6 |
| R-16a | SC-16a | P6 |
| R-16b | SC-16b | P6 |
| R-16c | SC-16c | P6 |
| R-16d | SC-16d | P6 |
| R-17 | SC-17 | P6 |
| R-18 | SC-18 | P6 |
| R-19 | SC-1a..SC-19 | All |
| R-20 | SC-4, SC-5, SC-6 | P4 |
| R-21 | SC-1a..SC-19 | All |
| R-22 | SC-19 | P0 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| `reference/plan-structure-standards.md` | code | `.opencode/reference/` | read — inspected frontmatter (dispatch field, integer `plan_schema_version`) |
| `skills/writing-plans/reference/plan-artifact-format.md` | code | `.opencode/skills/writing-plans/reference/` | read — self-declares "single source of truth" |
| `skills/writing-plans/tasks/research.md` | code | `.opencode/skills/writing-plans/tasks/` | read — Steps 10-12 broken invocations |
| `skills/plan/SKILL.md`, `skills/solve/SKILL.md` | code | `.opencode/skills/` | read — shared scope language |
| `skills/audit/tasks/plan-fidelity-*.md` | code | `.opencode/skills/audit/tasks/` | read — phantom clean-room basis, missing `plan-fidelity.md` |
| `skills/writing-plans/SKILL.md` | code | `.opencode/skills/writing-plans/` | read — task count 7, unwired verify-plan-pipeline |
| `skills/writing-plans/contracts/*-output.yaml` | code | `.opencode/skills/writing-plans/contracts/` | read — missing `blocker_reason` |
| `.opencode/tools/solve`, `.opencode/tools/plan` | code | `.opencode/tools/` | read — CLI interface definitions (unchanged) |
| Research card `plan-fidelity-auditor-authoritative-sources.md` | doc | `.opencode/.issues/research-cards/` | read — confidence 1.0; authoritative references, dispatch indicators, Z3 schema |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1a:** Deleting `plan-artifact-format.md` costs one deletion. Skipping leaves a competing plan-artifact spec live, so consumers read divergent frontmatter that fails downstream audits.
- **SC-1b:** Establishing `plan-structure-standards.md` as the single authority costs one read of both reference docs and updating consumer references. Skipping leaves the split authority in place, so consumers read a competing spec.
- **SC-1c:** Removing `plan-artifact-format.md` from the SKILL.md File Structure costs one edit. Skipping leaves a dangling File Structure listing pointing at a deleted file.
- **SC-2:** Removing the dispatch field costs one edit. Skipping leaves a field that agents misread as a dispatch directive, misrouting plan creation.
- **SC-3:** Stringing `plan_schema_version` costs one edit. Skipping leaves an integer/string mismatch that a schema-checking consumer fails at runtime.
- **SC-4:** Fixing the solve model invocation costs one behavioral test run. Skipping means every research step passes `sat` as a query and the solve model never runs, shipping unusable dependency contracts.
- **SC-5:** Fixing the solve check invocation costs one behavioral test run. Skipping means solve check reads an analytical artifact instead of a state file, producing a false validation result.
- **SC-6:** Fixing the plan plan invocation costs one behavioral test run. Skipping means the plan tool never runs, so no plan is produced from the research step.
- **SC-7:** Adding the BLOCK gate costs one behavioral test run. Skipping means an incomplete spec silently proceeds to Z3/planner invocation, producing a plan built on missing artifacts.
- **SC-8:** Resolving the scope collision costs one read of both descriptions. Skipping means agents misroute between plan and solve, selecting the wrong skill for the wrong task.
- **SC-9:** Clarifying ownership costs one read. Skipping leaves ambiguous state/fallback ownership, so two skills claim the same task and neither reliably executes it.
- **SC-10a:** Adopting the single-plan model costs one grep of the plan-fidelity chain. Skipping means the audit evaluates against a phantom plan that does not exist, producing arbitrary verdicts.
- **SC-10b:** Removing the `plan-fidelity.md` reference costs one grep. Skipping leaves a dangling reference to a non-existent main task file that agents cannot dispatch.
- **SC-11:** Fixing the task count costs one edit. Skipping leaves a count that contradicts the actual deck, so agents treat tasks as missing or extra.
- **SC-12:** Fixing cycle terminology costs one grep. Skipping leaves per-task/per-item confusion, so items are batched instead of TDD-cycled.
- **SC-13:** Removing the YAML block costs one edit. Skipping leaves a block its own rule forbids, so a downstream parser chokes on the body.
- **SC-14:** Adding `blocker_reason` costs one edit per template. Skipping leaves asymmetric contracts, so a BLOCKED result loses its reason.
- **SC-15:** Wiring verify-plan-pipeline costs one edit. Skipping leaves an unwired task that is declared but never runs, so pipeline completeness is never verified.
- **SC-16a:** Routing the lifecycle event to the completion-core manifest costs one edit. Skipping leaves completion writing the lifecycle event to the plan file or issue body.
- **SC-16b:** Reporting the executive summary in chat costs one edit. Skipping leaves completion silent, so progress is not surfaced to the developer.
- **SC-16c:** Not appending lifecycle events to plan.md/spec.md costs one edit. Skipping violates the non-tracking mandate (AGENTS.md: "Specs and plans are NOT tracking documents").
- **SC-16d:** Not posting lifecycle events as issue comments costs one edit. Skipping violates the substantive-comment gate (non-substantive progress goes to chat only, never issue comments).
- **SC-17:** Fixing the sc-summary path costs one edit. Skipping leaves research.md reading sc-summary from the wrong path, so plan items are unnumbered.
- **SC-18:** Fixing auth gating costs one edit. Skipping leaves handoff referencing a non-existent approval-gate task, so authorization is never verified before plan handoff.
- **SC-19:** Generating the seven analytical artifacts costs one artifact-generation pass over the plan skill deck. Skipping leaves the artifact cross-reference check unable to run, so plan-fidelity and validate steps evaluate against a missing analytical baseline.

## 11. Edge Cases

- **Input boundaries (SC-4/5/6):** The corrected tool invocations SHALL handle the absence of a contract file or state file by BLOCKing on the incomplete-spec gate (SC-7), rather than invoking the tool with placeholder arguments. Resolution: the gate runs before Z3/planner invocation.
- **State transitions (SC-1a/1b/1c):** `plan-artifact-format.md` SHALL be deleted outright, and `writing-plans/SKILL.md` File Structure SHALL be updated to no longer list it, leaving `plan-structure-standards.md` as the single canonical authority. Resolution: the file is deleted and the File Structure listing is removed; no reconciliation or repointing is performed.
- **Failure modes (SC-10a/10b):** If a plan-fidelity task still references the phantom clean-room plan or the non-existent `plan-fidelity.md`, the SC FAILs and the reference is removed. Resolution: grep-based verification catches residual references.
- **Concurrency (SC-11/12/15):** Multiple P6 items edit `writing-plans/SKILL.md` (task count, cycle terminology, verify-plan-pipeline wiring). Resolution: items execute sequentially in the dependency DAG (11→12, 11→15) to avoid conflicting edits.
- **Recovery (SC-7):** When the BLOCK gate fires on an incomplete spec, the gate SHALL follow diagnose→remediate→escalate: diagnose the missing artifact, attempt remediation, and escalate on failure. Resolution: the gate defines the escalation path explicitly.
- **Analytical artifact generation (SC-19):** The seven analytical artifacts are absent at `.opencode/.issues/2256/artifacts/`, preventing the artifact cross-reference check. Resolution: SC-19 generates all seven artifacts retroactively from the current plan skill deck and stores them at the expected path so the cross-reference check can run. This is a remediation requirement per the developer directive, not a non-blocking deferral.

---

## 12. Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-06 | Declared issue #2254 (spec-writer/spec-audit skill card remediation) as a prerequisite dependency in the Dependencies section. Added alignment notes: (1) SC-17 sc-summary path verification now confirms against the POST-#2254 spec-creation write path; (2) SC table intro now cites the canonical evidence-type taxonomy reference that #2254 establishes (SC-15/16) as the single taxonomy source; (3) SC-10a/10b now build on the post-#2254 role-card state (naming repaired, cross-references repointed by #2254 SC-8/9/10) without duplicating #2254's role-card work. No new SCs added; SC count unchanged. | Developer directive — #2256 builds on #2254's post-implementation state; declared #2254 as prerequisite and aligned interaction points. | Developer directive |
| 2026-08-06 | Decomposed compound SC-1, SC-10, and SC-16 into atomic SCs per the validate atomicity finding (SC-1→SC-1a/1b/1c; SC-10→SC-10a/10b; SC-16→SC-16a/16b/16c/16d). Renumbered plan_item numbering in sc-summary.yaml to match the new 24-SC set. Split R-1, R-10, R-16 into R-1a/1b/1c, R-10a/10b, R-16a/16b/16c/16d. Added one Item per atomic SC (24 items), updated the Traceability table, Dependencies, Cost Frame, and Edge Cases to the atomic SC set. Evidence types remain structural for the SC-1/10/16 splits. Added the analytical-artifacts absence note. | validate atomicity finding — SC-1/SC-10/SC-16 were compound, bundling independently-verifiable targets joined by "and"; each must be its own atomic SC with its own verification target, item, requirement trace, and cost-frame entry. | Spec revision dispatch |
| 2026-08-06 | Revised SC-16 (and dependent R-16, Item 16, Cost Frame SC-16) to route the completion lifecycle event to the `completion-core` lifecycle manifest at `{project_root}/tmp/{issue-N}/lifecycle.yaml` (metadata, append-only) and report the executive summary in chat, instead of referencing a consistent lifecycle target in the issue body. | Authoritative-lifecycle-channel correction per completion-core manifest + non-tracking mandate (AGENTS.md: "Specs and plans are NOT tracking documents") + substantive-comment gate (non-substantive progress goes to chat only, never issue comments). | Spec revision dispatch |
| 2026-08-06 | Revised SC-1 (and dependent R-1, Item 1, Cost Frame SC-1, Edge Case state-transition) to commit to deleting `plan-artifact-format.md` as the single direction, establishing `reference/plan-structure-standards.md` as the single canonical plan-structure authority and removing `plan-artifact-format.md` from the `writing-plans/SKILL.md` File Structure listing. | Anti-bifurcation — SC-1 had an "or" directive ("reconciled into it or removed"); committed to delete `plan-artifact-format.md` as the single direction since it has zero functional consumers beyond the SKILL.md File Structure listing. | Spec revision dispatch |
| 2026-08-06 | Converted the analytical-artifacts-absent WARNING note into remediation SC-19: added SC-19 (analytical artifacts generated and stored at `.opencode/.issues/2256/artifacts/`), R-22, Item 25, a Cost Frame entry, and the Traceability mapping (R-22→SC-19→P0). Renumbered plan_item numbering in sc-summary.yaml to the new 25-SC set. | Developer directive — "any note is a remediation requirement, no exceptions"; the analytical-artifacts-absent warning is converted to a remediation SC so the artifact cross-reference check can run. | Developer directive |

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
