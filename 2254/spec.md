> **Full spec and artifacts: [`2254/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2254)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2254/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## 1. Intent and Executive Summary

### Problem Statement

This spec remediates the spec-writer (`spec-creation`) and spec-auditor (`audit`) skill card sets plus the consolidated `.opencode/reference/` standards and the skildeck linter under `.opencode/tools/impl/skildeck/`, addressing internal-consistency drifts, broken file paths and cross-references, dispatch-contract mismatches, format gaps, linter enforcement gaps, and functional end-to-end verification.

A prior revision of this spec asserted a false premise: that the drift-repair and format remediation described by the original SC set (SC-1..SC-18, SC-23..SC-31, SC-35..SC-37) was **already complete on disk** and therefore removed from the active SC set. Independent verification against the actual filesystem shows this is incorrect. Substantial defective paths, broken cross-references, and dispatch-contract mismatches **remain on disk** and are NOT covered by the active SCs (SC-25, SC-32, SC-33, SC-34, SC-47, SC-48, SC-49). The verified on-disk defects are:

**Class A — Broken file paths / cross-references (verified on disk):**
- **A1:** The `Plan Audit Code Deep Dive` section of `spec-creation/SKILL.md` references `docs/specs/how-to-write-good-spec-ai-agents.md`, which does not exist anywhere — the `docs/specs/` directory is absent (verified: `ls docs/specs/` → no such directory; `find . -name how-to-write-good-spec-ai-agents.md` → no results).
- **A2/A3/A4:** The Procedure steps of `spec-creation/tasks/create.md` and `spec-creation/tasks/revise.md` that reference `issue-operations-core/tasks/creation.md` and `issue-operations/platforms/local/tasks/push-artifacts.md` do so **missing the `skills/` prefix**. As written they resolve to non-existent paths; the real files live at `.opencode/skills/issue-operations-core/tasks/creation.md` and `.opencode/skills/issue-operations/platforms/local/tasks/push-artifacts.md` (verified via `find`).
- **A5:** 17 monolithic task-file references in `audit/tasks/*.md` (e.g., `tasks/verification-audit.md`, `tasks/drift-detection.md`, `tasks/spec-audit.md`, `tasks/plan-fidelity.md`, `tasks/content-audit.md`, `tasks/guideline-audit.md`, `tasks/concern-separation.md`, `tasks/coherence-maintenance.md`, `tasks/test-quality-audit.md`) point to files that were split into role-split cards and no longer exist (verified: `grep` counts 17 references across the role cards; the monolithic files are absent from `audit/tasks/`).

**Class B — Dispatch contract mismatches (verified on disk):**
- **B1:** The `Run an audit` Workflows section dispatch contracts in `audit/SKILL.md` pass a 21-parameter union to every role, but the downstream task cards' Dispatch Contracts accept only a subset (e.g., `verification-audit-investigator.md` accepts only `spec_local_dir`, `artifact_evidence_dir`, `spec_issue_number`). `pr_number` is passed but accepted by **no** task card (verified: `grep -rln pr_number audit/tasks/*.md` → no results).
- **B2:** The `Run an audit` Workflows section Returns fields in `audit/SKILL.md` say `finding_summary`, but the task cards' Result Contracts use `summary` (verified: 45 task cards use `summary:`; `finding_summary` appears only as prose, not as the result-contract field).

**Class C — Task cards carrying YAML frontmatter (verified on disk):**
- 48 of 50 `audit/tasks/*.md` role cards carry YAML frontmatter. Per `task-card-structure-standards.md` §1, task cards do NOT get YAML frontmatter — the "No" in the canonical-sections table means **absent**, not optional. Only SKILL.md files get YAML frontmatter. These 48 cards must have their YAML frontmatter removed (verified: 48 files start with `---`; only `completion.md` and `pr-body-audit.md` do not).

**Class D — Incomplete dispatch prompt format (behavioral evidence from SC-32/SC-33):**
- **D1:** The spec-creation and audit Workflows dispatch instructions use a partial template (`Dispatch task(..., prompt: "Follow the instructions in [path](url)")`) without:
  1. "You are a sub-agent" identity framing in the prompt
  2. A directive telling the orchestrator NOT to read the task card itself
  3. Inline context value passing in the prompt string
- This incomplete format produces a deliberation death spiral: the orchestrator reads instructions that say "dispatch to sub-agents" but lacks the "you are NOT the sub-agent" boundary, causing the orchestrator to attempt sub-agent work itself or enter an infinite deliberation loop. Verified by SC-32/SC-33 behavioral test failure analysis.

**Linter defects (verified on disk):** The skildeck linter (`skildeck-lint`) enforces rules R1-R5 (numbered-checkbox workflow, execution-mode sub-bullet, task-card clean-room unit, dispatch-contract completeness, markdown-link correctness). But it does NOT enforce:
- **(a)** broken markdown-link targets in **task cards** — R5 only checks SKILL.md Workflows dispatch lines, so A1, A2/A3/A4, and A5 are not flagged;
- **(b)** the **no-YAML-frontmatter-on-task-cards** rule — no such rule exists, so the 48 Class C cards are not flagged;
- **(c)** **dispatch-contract completeness beyond one direction** — R4 only checks that a workflow step's Context ⊇ the dispatched task card's Entry Criteria params. It does NOT check that the result-contract field names match (B2: `finding_summary` vs `summary`), nor that passed params are actually consumed (B1: `pr_number` passed but accepted by no card).

The actual remaining remediation, re-grounded in the current on-disk state, is:

1. **Broken path / cross-reference repair (SC-38, SC-39, SC-40):** Fix A1 (spec-creation/SKILL.md broken link), A2/A3/A4 (create.md + revise.md missing `skills/` prefix), and A5 (17 monolithic references in audit/tasks) so every reference resolves to a real file.
2. **Dispatch-contract repair (SC-41, SC-42):** Fix B1 (audit/SKILL.md 21-param union vs task-card subsets; remove `pr_number`) and B2 (Returns `finding_summary` vs task-card `summary`).
3. **Task-card frontmatter removal (SC-43):** Remove YAML frontmatter from the 48 audit role cards.
4. **Linter extension (SC-44, SC-45, SC-46):** Extend `skildeck-lint` to enforce (a) broken markdown-link targets across task cards, (b) no-YAML-frontmatter-on-task-cards, (c) dispatch-contract completeness including result-contract field-name matching and no over-supplied/unconsumed context params.
5. **Residual format conformance gap (SC-25):** `spec-creation/tasks/create.md` contains plain numbered lists (not numbered-checkbox) inside its Procedure sub-steps (Step 3, Step 3.1, Step 3.2, Step 6, Step 7), violating the canonical numbered-checkbox task-card Procedure format defined in `task-card-structure-standards.md`.
6. **Functional end-to-end verification (SC-32, SC-33, SC-34):** The repair SCs prove the remediated cards are well-formed on disk, but they do not prove the remediated skills actually work when dispatched. These behavioral SCs run the remediated `spec-creation` pipeline and the audit DiMo 4-role chain end-to-end against a fixture in a shared test home with a test gitbucket instance, asserting correct output — no mis-routing, no missing task cards, no broken cross-references, no deprecated dispatch strings. The behavioral test scripts for these SCs already exist (`2254-sc32-functional-spec-creation-pipeline.sh`, `2254-sc33-audit-dimo-chain.sh`, `2254-sc34-shared-test-home.sh`); the SCs require them to pass.
7. **Canonical dispatch prompt format adoption (SC-47, SC-48, SC-49):** The SC-32/SC-33 behavioral tests revealed a deliberation death spiral caused by Workflows dispatch instructions that use a partial template without identity framing, orchestrator-boundary directives, or inline context passing. SC-47 requires all spec-creation and audit Workflows dispatch instructions to use the canonical format with "You are a sub-agent" identity framing, inline context values, and a `Read [Text](path)` directive. SC-48 requires an explicit "orchestrator does NOT read task cards" directive before the Workflows step listing in the spec-creation and audit SKILL.md Workflows sections. SC-49 extends the same canonical format to all other skills with Workflows dispatch instructions.

### Root Cause / Motivation

The prior revision of this spec was authored against an asserted-but-incorrect on-disk state. It claimed the drift-repair and format remediation was already complete and removed those SCs from the active set. Live verification shows the opposite: the defective paths, broken cross-references, dispatch-contract mismatches, and task-card frontmatter violations remain on disk. Because agent-facing text is consumed as routing instructions, a spec that misstates the on-disk state is itself a defect vector: an implementor following the prior revision would conclude the spec-writer and spec-auditor skills are already consistent and working, when in fact they contain broken links (A1, A2/A3/A4, A5), mismatched dispatch contracts (B1, B2), non-canonical task cards (C), and incomplete dispatch prompt formats (D1). This revision re-grounds the spec in the verified on-disk state so the remaining work is precisely scoped: repair the broken paths and contracts, remove the non-canonical frontmatter, extend the linter to enforce these rules, close the residual `create.md` format gap, adopt the canonical dispatch prompt format across all skill Workflows sections, and prove the remediated skills work end-to-end.

### Approach Chosen

Re-ground the spec's problem statement and success criteria in the verified on-disk state. Add SCs that cover the verified defect classes: Class A broken paths/cross-references (SC-38, SC-39, SC-40), Class B dispatch-contract mismatches (SC-41, SC-42), Class C task-card frontmatter (SC-43), Class D dispatch prompt format (SC-47, SC-48, SC-49), and the three linter-enforcement gaps (SC-44, SC-45, SC-46). Retain the SCs that represent the actual remaining remediation: SC-25 (residual `create.md` format conformance) and SC-32..SC-34 (functional end-to-end verification). Apply exactly one prescriptive resolution per SC, each mapped one-to-one to a success criterion and to a phase in the 29-phase implementation plan. Fix the traceability table's phase numbering to match the 29-phase plan and analytical artifacts.

### Alternatives Considered & Why Discarded

- **Keep the prior revision's premise that the remediation is already complete and add no new SCs.** Discarded: the premise is false — the defects verified on disk (A1, A2/A3/A4, A5, B1, B2, C, D1, linter gaps) remain and would ship undetected. The spec must cover them.
- **Fold all Class A broken-link repairs into one SC.** Discarded: the defects span different files and different phases (spec-creation/SKILL.md and create.md/revise.md in Phase 25; audit/tasks monolithic references in Phase 14). Separate SCs map cleanly to their phases and preserve one-prescriptive-resolution-per-SC.
- **Classify the dispatch-contract repairs (B1, B2) as behavioral.** Discarded: the static contract-matching (Context params vs task-card Dispatch Contract; Returns field names vs Result Contract) is a structural property verified by inspection; the runtime correctness is proven behaviorally by SC-33 (functional audit DiMo chain). Classifying B1/B2 as structural avoids over-testing while SC-33 supplies the behavioral proof.
- **Leave the traceability table at Phase 21..29 only.** Discarded: the implementation plan and analytical artifacts use a 29-phase model (plan.md `phase_count: 29`), and the new SCs map to phases 14, 21, 23, 24, 25, 27, 28, 29. The traceability table must reflect the actual phase structure.
- **Treat the dispatch prompt format change as a single SC for spec-creation+audit only.** Discarded: the root cause (deliberation death spiral) affects all skills with Workflows dispatch instructions. SC-49 extends the format to the ~30 other skills, which is a separate concern with a broader scope. Separating spec-creation/audit (SC-47, SC-48) from the full deck (SC-49) preserves one-prescriptive-resolution-per-SC and maps cleanly to distinct phases.

### Key Design Decisions

- **Add SCs for the verified defect classes; retain the residual format and functional SCs.** Tradeoff: the SC set grows to cover the real remaining work, but the spec accurately reflects the on-disk state and the implementor's scope is precisely bounded.
- **Repair broken paths and contracts before functional verification.** Tradeoff: the repair SCs (SC-38..SC-43) are prerequisites for the functional SCs (SC-32, SC-33), which prove the remediated skills work end-to-end. This ordering matches the plan's dependency graph.
- **Extend the skildeck linter to enforce the new rules.** Tradeoff: extending the linter adds code under `.opencode/tools/impl/skildeck/`, but it converts one-time repairs into enforced invariants that prevent regression (broken links, task-card frontmatter, dispatch-contract drift).
- **Retain the functional end-to-end SCs (SC-32..SC-34) as the primary remaining work.** Tradeoff: running the full `spec-creation` pipeline and audit DiMo chain end-to-end costs minutes of execution time per test, but is the only way to prove the remediated skills actually work when dispatched.
- **Retain SC-25 for the residual `create.md` format gap.** Tradeoff: a narrow, verifiable format-conformance item, but it is a genuine on-disk format defect found by re-verification.
- **Align the traceability table with the 29-phase plan.** Tradeoff: the traceability table maps each requirement to the phase that implements it in the actual plan.
- **Adopt the canonical dispatch prompt format across the full skill deck.** Tradeoff: updating ~30 skills in addition to spec-creation and audit is costly, but the deliberation death spiral affects any skill whose Workflows section uses the partial template. A partial fix to spec-creation+audit only would leave the other 28+ skills with the same defect, requiring a follow-up spec.

### User Intent / Original Prompt

A history-grounded read-only audit of the spec-writer and spec-audit skill card sets and the consolidated reference standards, identifying internal-consistency drifts and prescribing one resolution per finding, subsequently expanded into a total remediation scope. A prior revision asserted the drift-repair/format remediation was already complete on disk; independent verification showed this premise is false — broken paths, broken cross-references, dispatch-contract mismatches, task-card frontmatter violations, and incomplete dispatch prompt formats remain. This revision re-grounds the spec so its problem statement and success criteria accurately reflect the actual on-disk state and the actual remaining remediation.

## 2. Not Included

- **Application `src/` code changes** — All affected files are agent-facing markdown in `.opencode/` plus the skildeck linter under `.opencode/tools/impl/skildeck/`; no application `src/` runtime code changes.
- **Non-agent-facing documentation** — Changes confined to skill cards, task cards, reference standards, and the skildeck linter consumed by agents.
- **Behavioral test suite changes beyond what the SCs require** — The functional end-to-end SCs (SC-32..SC-34) require their own behavioral tests; no other test-suite changes are in scope.
- **Re-verification of already-correct content** — SCs target only the verified defect classes (A, B, C, D) and the residual format gap; content that is already correct on disk is not re-scoped.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-25 | Every task card Procedure section in `spec-creation` and `audit` SHALL use numbered checkbox lists (`- [ ] N.`), including the Procedure sub-steps of `spec-creation/tasks/create.md` (Step 3, Step 3.1, Step 3.2, Step 6, Step 7 currently use plain numbered lists). | string | grep all task cards in spec-creation and audit for numbered checkbox procedure steps; assert no plain numbered lists remain in Procedure sections |
| SC-38 | `spec-creation/SKILL.md` SHALL NOT reference the non-existent `docs/specs/how-to-write-good-spec-ai-agents.md`; the reference SHALL be removed or repointed to a real file, and every markdown link in `spec-creation/SKILL.md` SHALL resolve to an existing file. | string | grep `spec-creation/SKILL.md` for the broken reference; assert it is absent or resolves; assert all markdown links in the file resolve to existing paths |
| SC-39 | The Procedure steps of `spec-creation/tasks/create.md` and `spec-creation/tasks/revise.md` that reference `issue-operations-core/tasks/creation.md` and `issue-operations/platforms/local/tasks/push-artifacts.md` SHALL carry the correct `skills/` prefix so they resolve to `.opencode/skills/issue-operations-core/tasks/creation.md` and `.opencode/skills/issue-operations/platforms/local/tasks/push-artifacts.md`. | string | grep create.md and revise.md for the issue-operations references; assert the link targets resolve to existing files under `.opencode/skills/` |
| SC-40 | All 17 monolithic task-file references in `audit/tasks/*.md` (e.g., `tasks/verification-audit.md`, `tasks/drift-detection.md`, `tasks/spec-audit.md`, `tasks/plan-fidelity.md`) SHALL be removed or repointed to the actual role-split cards that exist on disk. | string | grep audit/tasks/*.md for monolithic task-file references; assert none resolve to non-existent files and all role cross-references point to existing role-split cards |
| SC-41 | The `Run an audit` Workflows section dispatch contracts in `audit/SKILL.md` SHALL pass exactly the parameters each role's task card accepts; the 21-parameter union SHALL be reduced to each role's accepted subset, and `pr_number` SHALL be removed from the context passed to any role whose task card does not accept it. | structural | compare the Context passed in audit/SKILL.md against each role task card's Dispatch Contract; assert no over-supplied/unconsumed params and no missing required params |
| SC-42 | The `Run an audit` Workflows section Returns fields in `audit/SKILL.md` SHALL use the same field names as the task cards' Result Contracts — `summary`, not `finding_summary`. | structural | compare the Returns field names in audit/SKILL.md against each role task card's Result Contract; assert field names match |
| SC-43 | No `audit/tasks/*.md` role card SHALL carry YAML frontmatter; the 48 cards that currently start with `---` SHALL have their YAML frontmatter removed, per `task-card-structure-standards.md` §1 (task cards do not get YAML frontmatter). | string | grep audit/tasks/*.md for leading `---`; assert no role card starts with YAML frontmatter |
| SC-44 | The skildeck linter SHALL enforce broken markdown-link targets across task cards (not just SKILL.md Workflows dispatch lines), flagging A1, A2/A3/A4, and A5 class references that resolve to non-existent files. | behavioral | opencode run (with-test-home): extend skildeck-lint, run it against the skill deck, and assert it flags the broken task-card links |
| SC-45 | The skildeck linter SHALL enforce the no-YAML-frontmatter-on-task-cards rule, flagging any task card that carries YAML frontmatter. | behavioral | opencode run (with-test-home): extend skildeck-lint, run it against the skill deck, and assert it flags task cards with YAML frontmatter |
| SC-46 | The skildeck linter SHALL enforce dispatch-contract completeness including result-contract field-name matching (B2) and no over-supplied/unconsumed context params (B1), flagging mismatches between a SKILL.md dispatch contract and the dispatched task card's Dispatch/Result Contract. | behavioral | opencode run (with-test-home): extend skildeck-lint, run it against the skill deck, and assert it flags dispatch-contract mismatches |
| SC-32 | Dispatching the full spec-creation pipeline (analyze → create → validate) against a fixture problem in the shared test home SHALL produce a valid spec with no mis-routing, no missing task cards, no broken cross-references, and no deprecated dispatch strings. | behavioral | opencode run (with-test-home): dispatch the remediated spec-creation pipeline end-to-end against the test gitbucket instance and assert correct output |
| SC-33 | Dispatching the audit DiMo 4-role chain (investigator → validator → evaluator → arbiter) against a fixture spec in the shared test home SHALL produce a valid verdict, with each role dispatching to the correct split task card with a complete dispatch contract. | behavioral | opencode run (with-test-home): dispatch the remediated audit chain end-to-end and assert correct output |
| SC-34 | The spec-creation and audit behavioral tests SHALL share a common test home with a test project and test gitbucket instance, sequenced so later tests build upon the state created by earlier tests in an incremental fashion. | string | verify the behavioral test setup uses the shared with-test-home infrastructure with the gitbucket instance |
| SC-47 | All spec-creation and audit Workflows dispatch instructions SHALL use the canonical `task(subagent_type=..., prompt: concat("You are a sub-agent. Follow the instructions in [description](path). context_field_1: ", value_1, ", context_field_2: ", value_2))` format with "You are a sub-agent" identity framing, a `Read [Text](path)` directive for the sub-agent to discover the task card independently, and inlined context values. | structural | grep the spec-creation and audit SKILL.md and task cards for Workflows `task()` dispatch instructions; assert each uses the canonical format with "You are a sub-agent", `Read [Text](path)`, and inline context values |
| SC-48 | The spec-creation and audit SKILL.md Workflows sections SHALL include an explicit "orchestrator does NOT read task cards" directive before the Workflows step listing. | string | grep the spec-creation and audit SKILL.md Workflows sections for the directive; assert the directive appears before any Workflows dispatch step |
| SC-49 | All other skills with Workflows dispatch instructions (~30 skills) SHALL use the same canonical dispatch prompt format as SC-47, with "You are a sub-agent" identity framing, `Read [Text](path)` directive, and inlined context values, adopted across the full skill deck. | structural | grep all SKILL.md files in `.opencode/skills/` for Workflows `task()` dispatch instructions; assert each uses the canonical format; enumerate any skills whose dispatch instructions do not conform |

## 4. Requirements

- R-23. Task card Procedure sections SHALL use numbered checkbox lists (`- [ ] N.`). Task cards SHALL be designed for non-task-capable sub-agents; a task card whose procedure would require internal sub-agent dispatch SHALL be split into multiple task cards, and the SKILL.md workflow SHALL dispatch each split task card as a separate step. (SC-25 implements the numbered-checkbox Procedure requirement.)
- R-38. `spec-creation/SKILL.md` SHALL reference only existing files; the non-existent `docs/specs/how-to-write-good-spec-ai-agents.md` reference SHALL be removed or repointed, and every markdown link in the file SHALL resolve to an existing path. (SC-38.)
- R-39. `spec-creation/tasks/create.md` and `spec-creation/tasks/revise.md` SHALL reference `issue-operations-core/tasks/creation.md` and `issue-operations/platforms/local/tasks/push-artifacts.md` with the correct `skills/` prefix so the links resolve to existing files. (SC-39.)
- R-40. `audit/tasks/*.md` SHALL NOT reference monolithic task files that no longer exist; cross-references SHALL point to the actual role-split cards on disk. (SC-40.)
- R-41. The `audit/SKILL.md` dispatch contracts SHALL pass exactly the parameters each role's task card accepts; no over-supplied/unconsumed params, and `pr_number` SHALL be removed where no task card accepts it. (SC-41.)
- R-42. The `audit/SKILL.md` Returns contracts SHALL use the same field names as the task cards' Result Contracts (`summary`, not `finding_summary`). (SC-42.)
- R-43. `audit/tasks/*.md` role cards SHALL NOT carry YAML frontmatter, per `task-card-structure-standards.md` §1. (SC-43.)
- R-44. The skildeck linter SHALL enforce broken markdown-link targets across task cards. (SC-44.)
- R-45. The skildeck linter SHALL enforce the no-YAML-frontmatter-on-task-cards rule. (SC-45.)
- R-46. The skildeck linter SHALL enforce dispatch-contract completeness including result-contract field-name matching and no over-supplied/unconsumed context params. (SC-46.)
- R-28. The spec-creation behavioral test SHALL dispatch the full spec-creation pipeline (analyze → create → validate) end-to-end against a fixture problem in the shared test home and assert correct output (a valid spec with no mis-routing, no missing task cards, no broken cross-references, and no deprecated dispatch strings).
- R-29. The audit behavioral test SHALL dispatch the DiMo 4-role chain (investigator → validator → evaluator → arbiter) end-to-end against a fixture spec in the shared test home and assert a valid verdict with each role dispatching to the correct split task card with a complete dispatch contract.
- R-30. The spec-creation and audit behavioral tests SHALL share a common test home with a test project and test gitbucket instance, sequenced so later tests build upon the state created by earlier tests in an incremental fashion.
- R-47. All spec-creation and audit Workflows dispatch instructions SHALL use the canonical format: `task(subagent_type=..., prompt: concat("You are a sub-agent. Follow the instructions in [description](path). context_field_1: ", value_1, ...))` with identity framing, `Read [Text](path)` directive, and inline context values. The orchestrator does NOT read the task card; the sub-agent discovers it via the `Read` directive in the prompt. (SC-47.)
- R-48. The spec-creation and audit SKILL.md Workflows sections SHALL include an explicit "orchestrator does NOT read task cards" directive before the Workflows step listing. (SC-48.)
- R-49. All other skills with Workflows dispatch instructions SHALL follow the same canonical dispatch prompt format as SC-47. (SC-49.)
- R-15. No application `src/` code changes; changes SHALL be confined to agent-facing skill/reference markdown files and the skildeck linter under `.opencode/tools/impl/skildeck/`. Application `src/` code remains excluded.
- R-16. Behavioral SCs SHALL apply only where the change affects runtime dispatch behavior; string/structural elsewhere.
- R-17. No bifurcated/backwards-compat paths SHALL be introduced in agent-facing instructions (anti-bifurcation mandate).

## 5. Items

### Item 25 (SC-25): Convert create.md Procedure sub-steps to numbered-checkbox format

- RED: grep `spec-creation/tasks/create.md` asserts no plain numbered lists remain in Procedure sub-steps (Step 3, Step 3.1, Step 3.2, Step 6, Step 7) — fails on current content (the Step 3, Step 3.1, Step 3.2, Step 6, and Step 7 sub-steps of create.md currently use plain numbered lists)
- GREEN: Convert the plain numbered lists in create.md Procedure sub-steps to numbered checkbox lists (`- [ ] N.`)
- verify: grep conformance
- commit: spec-creation/tasks/create.md

### Item 38 (SC-38): Repair spec-creation/SKILL.md broken link

- RED: grep `spec-creation/SKILL.md` asserts the non-existent `docs/specs/how-to-write-good-spec-ai-agents.md` reference is absent and all markdown links resolve — fails on current content (the `Plan Audit Code Deep Dive` section references the non-existent path)
- GREEN: Remove or repoint the broken reference; ensure all markdown links in spec-creation/SKILL.md resolve to existing files
- verify: grep + link-resolution check
- commit: spec-creation/SKILL.md

### Item 39 (SC-39): Fix create.md and revise.md issue-operations link prefixes

- RED: grep `spec-creation/tasks/create.md` and `spec-creation/tasks/revise.md` asserts the issue-operations references carry the correct `skills/` prefix and resolve — fails on current content (the Procedure steps of create.md and revise.md that reference issue-operations-core/tasks/creation.md and issue-operations/platforms/local/tasks/push-artifacts.md miss the prefix)
- GREEN: Add the `skills/` prefix to the `issue-operations-core/tasks/creation.md` and `issue-operations/platforms/local/tasks/push-artifacts.md` references so they resolve to `.opencode/skills/...`
- verify: grep + link-resolution check
- commit: spec-creation/tasks/create.md, spec-creation/tasks/revise.md

### Item 40 (SC-40): Repoint monolithic task-file references in audit/tasks

- RED: grep `audit/tasks/*.md` asserts no monolithic task-file references resolve to non-existent files — fails on current content (17 references to `tasks/verification-audit.md`, `tasks/drift-detection.md`, `tasks/spec-audit.md`, `tasks/plan-fidelity.md`, etc.)
- GREEN: Remove or repoint the 17 monolithic references to the actual role-split cards on disk
- verify: grep + link-resolution check
- commit: audit/tasks/*.md

### Item 41 (SC-41): Fix audit/SKILL.md dispatch contract param sets

- RED: compare the Context passed in the `Run an audit` Workflows section dispatch contracts of `audit/SKILL.md` against each role task card's Dispatch Contract — fails on current content (21-param union over-supplies; `pr_number` accepted by no card)
- GREEN: Reduce the Context passed to each role's accepted subset; remove `pr_number` where no card accepts it
- verify: structural contract comparison
- commit: audit/SKILL.md

### Item 42 (SC-42): Fix audit/SKILL.md Returns contract field names

- RED: compare the Returns field names in the `Run an audit` Workflows section Returns fields of `audit/SKILL.md` against each role task card's Result Contract — fails on current content (`finding_summary` vs `summary`)
- GREEN: Change the Returns contracts to use `summary` (matching the task cards' Result Contracts)
- verify: structural contract comparison
- commit: audit/SKILL.md

### Item 43 (SC-43): Remove YAML frontmatter from audit role cards

- RED: grep `audit/tasks/*.md` asserts no role card starts with `---` — fails on current content (48 of 50 role cards carry YAML frontmatter)
- GREEN: Remove the YAML frontmatter from the 48 audit role cards
- verify: grep conformance
- commit: audit/tasks/*.md

### Item 44 (SC-44): Extend skildeck linter for task-card link correctness

- RED: opencode run (with-test-home) asserts the extended linter flags broken task-card links — fails on current linter (R5 only checks SKILL.md Workflows dispatch lines, not task-card links)
- GREEN: Extend skildeck-lint to check markdown-link targets across task cards; run it and assert it flags A1/A2/A3/A4/A5-class broken links
- verify: behavioral test via opencode run (with-test-home)
- commit: skildeck-lint, linter tests

### Item 45 (SC-45): Extend skildeck linter for no-YAML-frontmatter-on-task-cards

- RED: opencode run (with-test-home) asserts the extended linter flags task cards with YAML frontmatter — fails on current linter (no such rule)
- GREEN: Add a rule to skildeck-lint that flags task cards carrying YAML frontmatter; run it and assert it flags the 48 Class C cards
- verify: behavioral test via opencode run (with-test-home)
- commit: skildeck-lint, linter tests

### Item 46 (SC-46): Extend skildeck linter for dispatch-contract completeness

- RED: opencode run (with-test-home) asserts the extended linter flags dispatch-contract mismatches (result-contract field names, over-supplied/unconsumed params) — fails on current linter (R4 only checks Context ⊇ Entry Criteria)
- GREEN: Extend skildeck-lint to check result-contract field-name matching and no over-supplied/unconsumed context params; run it and assert it flags B1/B2-class mismatches
- verify: behavioral test via opencode run (with-test-home)
- commit: skildeck-lint, linter tests

### Item 32 (SC-32): Functional end-to-end spec-creation pipeline

- RED: opencode run (with-test-home) dispatches the remediated spec-creation pipeline (analyze → create → validate) end-to-end against a fixture problem in the shared test home and asserts correct output — fails if the pipeline mis-routes, references missing task cards, or uses deprecated dispatch strings
- GREEN: Ensure the remediated spec-creation pipeline dispatches end-to-end against the test gitbucket instance and produces a valid spec with no mis-routing, no missing task cards, no broken cross-references, and no deprecated dispatch strings
- verify: behavioral test via opencode run (with-test-home) against the test gitbucket instance
- commit: behavioral test script (`2254-sc32-functional-spec-creation-pipeline.sh`), fixtures

### Item 33 (SC-33): Functional end-to-end audit DiMo chain

- RED: opencode run (with-test-home) dispatches the remediated audit DiMo 4-role chain (investigator → validator → evaluator → arbiter) end-to-end against a fixture spec in the shared test home and asserts correct output — fails if roles mis-route, dispatch to missing task cards, or carry incomplete dispatch contracts
- GREEN: Ensure the remediated audit chain dispatches end-to-end and produces a valid verdict, with each role dispatching to the correct split task card with a complete dispatch contract
- verify: behavioral test via opencode run (with-test-home)
- commit: behavioral test script (`2254-sc33-audit-dimo-chain.sh`), fixtures

### Item 34 (SC-34): Shared test home with gitbucket instance

- RED: verify the spec-creation and audit behavioral test setup uses the shared with-test-home infrastructure with the gitbucket instance, sequenced incrementally — fails if no shared test home / gitbucket instance
- GREEN: Ensure the spec-creation and audit behavioral tests share a common test home with a test project and test gitbucket instance, sequenced so later tests build upon the state created by earlier tests in an incremental fashion
- verify: test setup inspection (string check — shared with-test-home infrastructure with the gitbucket instance)
- commit: behavioral test scripts (`2254-sc34-shared-test-home.sh`), fixtures

### Item 47 (SC-47): Adopt canonical dispatch prompt format in spec-creation and audit Workflows

- RED: grep spec-creation and audit SKILL.md and task cards for Workflows `task()` dispatch instructions — fails on current content (dispatch instructions use the partial template without "You are a sub-agent" identity framing, `Read [Text](path)` directive, or inline context values)
- GREEN: Rewrite all spec-creation and audit Workflows dispatch instructions to use the canonical format: `task(subagent_type=..., prompt: concat("You are a sub-agent. Follow the instructions in [description](path). context_field_1: ", value_1, ...))`. The orchestrator does NOT read the task card; the sub-agent discovers it via the `Read [Text](path)` directive.
- verify: structural — grep for canonical format pattern across spec-creation and audit SKILL.md and task cards
- commit: spec-creation/SKILL.md, spec-creation/tasks/*.md, audit/SKILL.md, audit/tasks/*.md

### Item 48 (SC-48): Add "orchestrator does NOT read task cards" directive to spec-creation and audit SKILL.md Workflows sections

- RED: grep the spec-creation and audit SKILL.md Workflows sections for an explicit "orchestrator does NOT read task cards" directive — fails on current content (no such directive exists)
- GREEN: Add an explicit "orchestrator does NOT read task cards" directive before the Workflows step listing in spec-creation/SKILL.md and audit/SKILL.md
- verify: grep for the directive string in both SKILL.md files
- commit: spec-creation/SKILL.md, audit/SKILL.md

### Item 49 (SC-49): Adopt canonical dispatch prompt format across all other skills with Workflows

- RED: grep all SKILL.md files in `.opencode/skills/` for Workflows `task()` dispatch instructions that do NOT use the canonical format — fails on current content (the ~28 other skills with Workflows sections use the partial template)
- GREEN: Rewrite all Workflows dispatch instructions in the ~28 non-spec-creation/non-audit skills to use the canonical format with "You are a sub-agent" identity framing, `Read [Text](path)` directive, and inline context values
- verify: structural — grep all SKILL.md files for canonical format pattern; enumerate any non-conforming skills
- commit: all affected SKILL.md files

## 6. Dependencies

- **Infrastructure: `with-test-home` + GitBucket instance** — Relationship: the functional end-to-end SCs (SC-32, SC-33, SC-34) depend on the shared test home with a test project and the test gitbucket instance provisioned by `BEHAVIOR_NEEDS_REMOTE`. Status: satisfied (`.opencode/tests-v2/with-test-home` and `__ensure_gitbucket` in `behaviors/helpers.sh` exist; the SC-32/SC-33/SC-34 behavioral test scripts exist).
- **Reference: `task-card-structure-standards.md`** — Relationship: defines the numbered-checkbox task-card Procedure format that SC-25 conforms to, and the no-YAML-frontmatter-on-task-cards rule that SC-43 conforms to. Status: satisfied (the reference doc specifies the numbered-checkbox Procedure format and the "No" for task-card YAML frontmatter).
- **Reference: `spec-structure-standards.md`** — Relationship: defines the canonical spec structure and prohibited content patterns that the revised spec conforms to. Status: satisfied.
- **Reference: `skill-card-description-standards.md`** — Relationship: defines the canonical Workflows dispatch format including the "orchestrator does NOT read task cards" directive and the `task(subagent_type=..., prompt: concat("You are a sub-agent. Follow the instructions in [description](path). ..."))` format. Status: needs update — the current reference does not specify the canonical dispatch prompt format with identity framing and `Read [Text](path)` directive. SC-47/SC-48/SC-49 adoption depends on this reference being updated first. Verified: grep the reference for "You are a sub-agent", "orchestrator does NOT read task cards", and "Read [Text](path)" — none present. The reference must be updated to specify the canonical format before the skill Workflows sections are rewritten.
- **Tool: skildeck linter (`.opencode/tools/impl/skildeck/`)** — Relationship: SC-44, SC-45, SC-46 extend skildeck-lint to enforce task-card link correctness, no-YAML-frontmatter-on-task-cards, and dispatch-contract completeness; SC-25 conforms to the numbered-checkbox format rules the linter enforces. Status: satisfied (skildeck-lint enforces rules R1-R5; needs extension for the three gaps).
- **Files: `issue-operations-core/tasks/creation.md` and `issue-operations/platforms/local/tasks/push-artifacts.md`** — Relationship: SC-39 repoints create.md and revise.md references to these real files (under `.opencode/skills/`). Status: satisfied (both files exist on disk).

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-23 | SC-25 | Phase 21 |
| R-38 | SC-38 | Phase 25 |
| R-39 | SC-39 | Phase 25 |
| R-40 | SC-40 | Phase 14 |
| R-41 | SC-41 | Phase 23 |
| R-42 | SC-42 | Phase 23 |
| R-43 | SC-43 | Phase 21 |
| R-44 | SC-44 | Phase 24 |
| R-45 | SC-45 | Phase 24 |
| R-46 | SC-46 | Phase 24 |
| R-28 | SC-32 | Phase 27 |
| R-29 | SC-33 | Phase 28 |
| R-30 | SC-34 | Phase 29 |
| R-47 | SC-47 | Phase 30 |
| R-48 | SC-48 | Phase 30 |
| R-49 | SC-49 | Phase 31 |
| R-15 | SC-25, SC-38, SC-39, SC-40, SC-41, SC-42, SC-43, SC-44, SC-45, SC-46, SC-32, SC-33, SC-34, SC-47, SC-48, SC-49 | All |
| R-16 | SC-44, SC-45, SC-46, SC-32, SC-33 | Phase 24, Phase 27, Phase 28 |
| R-17 | SC-25, SC-38, SC-39, SC-40, SC-41, SC-42, SC-43, SC-44, SC-45, SC-46, SC-32, SC-33, SC-34, SC-47, SC-48, SC-49 | All |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| spec-creation/SKILL.md | code | `.opencode/skills/spec-creation/SKILL.md` | read + grep during analysis |
| spec-creation/tasks/create.md | code | `.opencode/skills/spec-creation/tasks/create.md` | read + grep during analysis |
| spec-creation/tasks/revise.md | code | `.opencode/skills/spec-creation/tasks/revise.md` | read + grep during analysis |
| audit/SKILL.md | code | `.opencode/skills/audit/SKILL.md` | read + grep during analysis |
| audit/tasks/*.md | code | `.opencode/skills/audit/tasks/*.md` | read during analysis |
| reference/task-card-structure-standards.md | doc | `.opencode/reference/task-card-structure-standards.md` | read during analysis |
| reference/skill-card-description-standards.md | doc | `.opencode/reference/skill-card-description-standards.md` | read during analysis |
| reference/spec-structure-standards.md | doc | `.opencode/reference/spec-structure-standards.md` | read during analysis |
| reference/holistic-dimensions.yaml | config | `.opencode/reference/holistic-dimensions.yaml` | read during analysis |
| issue-operations-core/tasks/creation.md | code | `.opencode/skills/issue-operations-core/tasks/creation.md` | read + grep during analysis |
| issue-operations/platforms/local/tasks/push-artifacts.md | code | `.opencode/skills/issue-operations/platforms/local/tasks/push-artifacts.md` | read + grep during analysis |
| skildeck linter | code | `.opencode/tools/impl/skildeck/` | read during analysis |
| with-test-home | infra | `.opencode/tests-v2/with-test-home` | read during analysis |
| behaviors/helpers.sh | infra | `.opencode/tests-v2/behaviors/helpers.sh` | read during analysis |
| behavioral test scripts | infra | `.opencode/tests-v2/behaviors/2254-sc{32,33,34}-*.sh` | read during analysis |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-25: Verifying the create.md Procedure format costs one grep search. Skipping means a task card keeps a non-canonical procedure format that diverges from the reference standard.
- SC-38/SC-39/SC-40: Verifying the broken-path repairs costs grep + link-resolution checks. Skipping means the spec-writer and spec-auditor skills carry broken links that mis-route agents to non-existent files — every dispatch through them inherits the defect.
- SC-41/SC-42: Verifying the dispatch-contract repairs costs structural contract comparisons. Skipping means the audit SKILL.md passes an over-supplied 21-param union and returns `finding_summary` where task cards expect `summary` — every audit dispatch inherits the mismatch.
- SC-43: Verifying the frontmatter removal costs a grep. Skipping means 48 audit role cards carry non-canonical YAML frontmatter that violates task-card-structure-standards.md §1.
- SC-44/SC-45/SC-46: Verifying the linter extension costs behavioral opencode run. Skipping means the repairs are one-time fixes with no enforced invariant — broken links, task-card frontmatter, and dispatch-contract drift silently regress.
- SC-32: Running the functional spec-creation pipeline behavioral test costs minutes of execution time. Skipping means the remediated spec-creation pipeline is never proven to work end-to-end — a mis-routing, a missing task card, a broken cross-reference, or a deprecated dispatch string ships undetected and every spec created through the pipeline inherits the defect.
- SC-33: Running the functional audit DiMo chain behavioral test costs minutes of execution time. Skipping means the remediated audit chain is never proven to work end-to-end — a role mis-routing to a missing task card or carrying an incomplete dispatch contract ships undetected and every audit verdict inherits the defect.
- SC-34: Verifying the shared test home with the gitbucket instance costs a test setup inspection (string check). Skipping means the functional tests run in isolation without shared state, so the incremental build-up (the spec created by SC-32 becomes the fixture audited by SC-33) is lost and the remote API for remote-stub/issue-creation tests is unavailable.
- SC-47: Verifying the canonical dispatch prompt format in spec-creation and audit costs a grep for the canonical pattern. Skipping means the deliberation death spiral persists — the orchestrator receives partial instructions that lack identity framing, triggering infinite deliberation loops on every spec-creation and audit dispatch.
- SC-48: Verifying the "orchestrator does NOT read task cards" directive costs a grep for the directive string. Skipping means the orchestrator may read task card content inline, performing sub-agent work itself instead of routing — a contamination path on every dispatch.
- SC-49: Verifying the canonical format across the full skill deck costs a grep of all SKILL.md files. Skipping means ~28 skills retain the partial template, each a latent death-spiral trigger. The deliberation death spiral is not limited to spec-creation and audit — any skill with the partial template can trigger it.

## 11. Edge Cases

- **Condition: A task card's Procedure sub-step uses a plain numbered list instead of a numbered-checkbox list.** Expected behavior: the sub-step is converted to a numbered-checkbox list per SC-25. Resolution: the Procedure section of every task card in spec-creation and audit conforms to the canonical numbered-checkbox format.
- **Condition: A reference in spec-creation/SKILL.md, create.md, revise.md, or audit/tasks resolves to a non-existent file (A1, A2/A3/A4, A5).** Expected behavior: the broken reference is removed or repointed to a real file per SC-38/SC-39/SC-40. Resolution: every markdown link in the affected files resolves to an existing path; the linter (SC-44) enforces this going forward.
- **Condition: The audit/SKILL.md dispatch contract passes params a role's task card does not accept, or returns a field name the task cards do not use (B1, B2).** Expected behavior: the dispatch contract is reduced to each role's accepted subset and the Returns field names match the task cards' Result Contracts per SC-41/SC-42. Resolution: the structural contract comparison passes; the linter (SC-46) enforces this going forward.
- **Condition: An audit role card carries YAML frontmatter (C).** Expected behavior: the frontmatter is removed per SC-43. Resolution: no audit role card starts with `---`; the linter (SC-45) enforces this going forward.
- **Condition: The functional spec-creation pipeline (SC-32) mis-routes, references a missing task card, or uses a deprecated dispatch string when dispatched end-to-end.** Expected behavior: the behavioral test asserts correct output and FAILs on any of these defects. Resolution: the broken-path and dispatch-contract repairs (SC-38..SC-43) are fixed first; SC-32 verifies the remediated pipeline works end-to-end.
- **Condition: The functional audit DiMo chain (SC-33) mis-routes a role to a missing task card or carries an incomplete dispatch contract.** Expected behavior: the behavioral test asserts a valid verdict and FAILs on any of these defects. Resolution: the dispatch-contract repairs (SC-41, SC-42) and broken-path repairs (SC-40) are fixed first; SC-33 verifies the remediated chain works end-to-end.
- **Condition: The spec-creation and audit behavioral tests do not share a common test home with a test project and test gitbucket instance.** Expected behavior: SC-34 requires the shared with-test-home infrastructure with the gitbucket instance. Resolution: the tests are sequenced so later tests build upon the state created by earlier tests in an incremental fashion; the gitbucket instance provides the remote API for remote-stub/issue-creation tests.
- **Condition: The functional behavioral tests (SC-32, SC-33) cannot execute (model unavailable, gitbucket provisioning failure).** Expected behavior: the SCs are reported FAIL per the functional/behavioral test substitution prohibition. Resolution: remediation-first protocol applies before any escalation.
- **Condition: The spec-creation and audit Workflows dispatch instructions use the partial template but the orchestrator still routes correctly (false positive in canonical-format check).** Expected behavior: the structural grep for the canonical pattern catches any dispatch instruction that does not include "You are a sub-agent" identity framing, a `Read [Text](path)` directive, and inline context values. Resolution: SC-47/SC-48 grep enforces the full canonical pattern; a dispatch that routes correctly despite missing identity framing is still non-conforming and must be updated.
- **Condition: A skill's Workflows section has no `task()` dispatch instructions (no dispatch pattern to reformat).** Expected behavior: the skill is excluded from the grep and not flagged. Resolution: only skills with Workflows `task()` dispatch instructions are in scope for SC-49.
- **Condition: An existing skill's canonical-format update depends on the `skill-card-description-standards.md` reference being updated first.** Expected behavior: the reference update is a prerequisite for the skill Workflows section rewrites. Resolution: the reference is updated (Phase 30), then spec-creation/audit (Phase 30), then the remaining ~28 skills (Phase 31). The dependency is gated at the plan level.

## 12. Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-15 | Replaced all exact line-number references in the SC criteria and elsewhere in the spec body with stable file-area/step references. SC-39 now references "the Procedure steps of create.md and revise.md that reference issue-operations-core/tasks/creation.md and issue-operations/platforms/local/tasks/push-artifacts.md" instead of lines 96/145/47; SC-41 now references "the `Run an audit` Workflows section dispatch contracts in audit/SKILL.md" instead of lines 76/81/86/91; SC-42 now references "the `Run an audit` Workflows section Returns fields in audit/SKILL.md" instead of lines 77/82/87/92. Updated the Problem Statement (A1, A2/A3/A4, B1, B2), Items (Item 38, 39, 41, 42 RED descriptions), and the prior Change Control entry to use the same stable references. The SC criteria, verification methods, requirements, and scope are unchanged — only the brittle line-number references were replaced with the stable anchors that the grep targets. | spec-creation validate returned FAIL on determinism: SC-39, SC-41, and SC-42 embed exact line numbers in their success criteria (e.g., "create.md lines 96/145", "audit/SKILL.md lines 76/81/86/91"), violating spec-structure-standards.md §Prohibited Content Patterns ('exact file paths with line numbers → FAIL'). Line numbers are brittle and shift on edit. | spec-creation revision pipeline |
| 2026-08-15 | Corrected the false premise in the Problem Statement: the prior revision claimed the drift-repair/format remediation was already complete on disk, but independent verification shows substantial defective paths, broken cross-references, and dispatch-contract mismatches remain. Added SCs for the verified defect classes: SC-38 (spec-creation/SKILL.md broken link to non-existent `docs/specs/how-to-write-good-spec-ai-agents.md`), SC-39 (the Procedure steps of create.md and revise.md that reference issue-operations-core/tasks/creation.md and issue-operations/platforms/local/tasks/push-artifacts.md missing the `skills/` prefix), SC-40 (17 monolithic task-file references in audit/tasks), SC-41 (audit/SKILL.md 21-param dispatch union; `pr_number` accepted by no card), SC-42 (audit/SKILL.md Returns `finding_summary` vs task-card `summary`), SC-43 (48 audit role cards carrying YAML frontmatter), SC-44/SC-45/SC-46 (skildeck linter extension for task-card link correctness, no-YAML-frontmatter-on-task-cards, and dispatch-contract completeness). Retained SC-25 (create.md format gap) and SC-32/SC-33/SC-34 (functional e2e verification). Updated Root Cause, Approach, Alternatives, Key Design Decisions, Not Included, Requirements, Items, Dependencies, Traceability, Documentation Sources, Cost Frame, and Edge Cases for internal consistency. Mapped new SCs to the 29-phase plan: SC-40→Phase 14, SC-43→Phase 21, SC-41/SC-42→Phase 23, SC-44/45/46→Phase 24, SC-38/SC-39→Phase 25, SC-32→Phase 27, SC-33→Phase 28, SC-34→Phase 29. | Revision request: the spec's core premise is FALSE — the drift-repair/format remediation is NOT complete on disk for the path/contract defect classes; substantial defective paths, broken cross-references, and dispatch-contract mismatches REMAIN and are NOT covered by the active SCs. | spec-creation revision pipeline |
| 2026-08-15 | Corrected SC-34's declared evidence type from `behavioral` to `string` to resolve the validate EVIDENCE_TYPE_MISMATCH. SC-34's verification method (verify the behavioral test setup uses the shared with-test-home infrastructure with the gitbucket instance) is a setup/config inspection, not test execution with output inspection — per the canonical evidence-type taxonomy this is string/structural, not behavioral. The SC criterion and verification method are unchanged; only the declared evidence type was corrected to match the actual method. Updated R-16 traceability (SC-34 removed from the behavioral mapping), the traceability table, the Cost Frame, and Item 34 to be internally consistent. | spec-creation validate returned FAIL on SC-34 evidence-type mismatch (EVIDENCE_TYPE_MISMATCH) | spec-creation revision pipeline |
| 2026-08-15 | Re-grounded the spec in the verified on-disk state following a spec-audit FAIL. Removed the already-satisfied drift-repair and format SCs (SC-1..SC-18, SC-23,, SC-24, SC-26..SC-31, SC-35..SC-37) from the active SC set; retained only the actual remaining remediation: SC-25 (residual `create.md` Procedure plain-numbered-list format gap) and SC-32..SC-34 (functional end-to-end verification). Rewrote the Problem Statement to acknowledge the drift-repair and format remediation is already complete on disk. Removed the fabricated SC-8/SC-10/SC-12/SC-14 claims (audit/tasks/ has no subdirectories, all role-card `name:` fields already match filenames, no monolithic cross-references, behavioral-sc-evaluator.md does not exist). Fixed the traceability table phase numbering from Phase 1..7 to the 29-phase plan (Phase 21 for SC-25, Phase 27/28/29 for SC-32/33/34). Updated Requirements, Items, Dependencies, Documentation Sources, Cost Frame, and Edge Cases to match the re-grounded SC set. | Spec-audit FAIL (5 of 11 holistic dimensions: Implementability, Internal Consistency, Testability, Provenance, Correctness): the spec's stated current on-disk state contradicts actual state. SC-8/SC-10/SC-12/SC-14 claim to fix defects that do not exist on disk; the traceability table uses Phase 1..7 while the analytical artifacts and plan use Phase 1..29. The spec must be revised so its problem statement and SCs accurately reflect the actual on-disk state. | spec-creation revision pipeline |
| 2026-08-15 | Replaced the exact line-number references in Item 25's RED description (lines 71-72, 80-82, 88-90, 130-133, 147-148) with stable file-area/step references (Step 3, Step 3.1, Step 3.2, Step 6, Step 7 of create.md). The SC criterion and verification method are unchanged; only the RED description's brittle line numbers were replaced with the stable step identifiers that the grep targets. | spec-creation validate returned FAIL on Item 25's RED description: it embeds exact line numbers, violating spec-structure-standards.md §Prohibited Content Patterns ('exact file paths with line numbers → FAIL'). Line numbers are brittle and shift on edit. | spec-creation revision pipeline |
| 2026-08-16 | Added SC-47 (canonical dispatch prompt format in spec-creation and audit Workflows), SC-48 ("orchestrator does NOT read task cards" directive in spec-creation and audit SKILL.md Workflows sections), and SC-49 (canonical dispatch prompt format across all ~30 other skills with Workflows dispatch instructions). Updated the Problem Statement with Class D (incomplete dispatch prompt format), the Root Cause, Approach, Alternatives, Key Design Decisions, Not Included, Requirements (R-47, R-48, R-49), Items (Item 47, Item 48, Item 49), Dependencies (new dependency on `skill-card-description-standards.md` reference update), Traceability (Phases 30, 31 for the new SCs), Cost Frame, and Edge Cases. The SC criteria and verification methods follow the structural/string evidence type classification (static format conformance, not runtime dispatch behavior). | SC-32/SC-33 behavioral tests revealed a deliberation death spiral caused by incomplete Workflows dispatch instructions. The canonical format (identity framing + Read [Text](path) directive + inline context) prevents orchestrator-task-card confusion. The three SCs decompose the fix: spec-creation+audit format (SC-47), orchestrator-boundary directive (SC-48), full-deck adoption (SC-49). | Spec revision request: adding canonical dispatch prompt format SCs. |

---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)
