# Skill Card Change Type Taxonomy

> Reference document for classifying semantic change types in skill card (SKILL.md) and task card (task `.md`) modifications.

## Overview

This taxonomy defines 10 semantic change types for skill card and task card modifications. Every change to a SKILL.md or task `.md` file MUST be classified into exactly one type. The classification determines blast radius, remediation guidance, validation method, and workflow validation requirements.

## Change Types

### Type 1: Persona Reframe

| Field | Value |
|-------|-------|
| **Name** | Persona Reframe |
| **Description** | Changing the Persona section of a SKILL.md from first-person identity framing ("Spec Architect", "Plan Author") to third-person dispatch framing ("This skill produces specs by dispatching sub-agents"). |
| **Trigger** | Orchestrator performs work inline instead of dispatching sub-agents. Root cause is identity-frame conflict per `250-dark-prose-reference.md`. |
| **Blast Radius** | **Global** — affects every invocation of the skill. The orchestrator's role changes from "doer" to "router". All downstream task dispatches are affected. |
| **Remediation Guidance** | Replace Persona prose with third-person dispatch framing. Include "intelligent agents, not dumb terminals" admonishment. Do NOT modify DISPATCH_GATE sections. |
| **Validation** | `grep` for absence of first-person identity terms ("Architect", "Author" as role labels). `grep` for presence of third-person dispatch framing. |
| **Workflow Validation** | Generate Z3 solve contract for the skill's workflow. Run `solve check` — MUST return SAT. Run `plan plan` — MUST return SOLVED_SATISFICING or SOLVED_OPTIMALLY. |
| **Example Spec** | `.opencode#1278` Phase 1 |

### Type 2: Checklist Reform

| Field | Value |
|-------|-------|
| **Name** | Checklist Reform |
| **Description** | Converting the Operating Protocol section of a SKILL.md from bullet items or prose paragraphs to a unified `- [ ] N.` sequential checklist. |
| **Trigger** | Orchestrator skips steps or executes out of order because the Operating Protocol lacks a numbered sequential checklist. |
| **Blast Radius** | **Skill-level** — affects the execution order of the skill's workflow. Does not affect other skills. |
| **Remediation Guidance** | Replace all bullet items and prose paragraphs in Operating Protocol with `- [ ] N.` items. Each item is one action. No prose between items. Preserve all existing requirements. |
| **Validation** | `grep -c "^- \[ \]"` on the SKILL.md Operating Protocol section. Verify count matches expected step count. |
| **Workflow Validation** | Generate Z3 solve contract for the reformatted checklist. Run `solve check` — MUST return SAT. Run `plan plan` — MUST return SOLVED_SATISFICING or SOLVED_OPTIMALLY. |
| **Example Spec** | `.opencode#1278` Phase 2 |

### Type 3: Task File Reformat

| Field | Value |
|-------|-------|
| **Name** | Task File Reformat |
| **Description** | Converting a task `.md` file from mixed prose/header format (`### Step N:` headers with prose paragraphs) to pure `- [ ] N.` checklist format. |
| **Trigger** | Task file contains prose paragraphs between steps, causing sub-agents to miss steps or misinterpret procedure. |
| **Blast Radius** | **Task-level** — affects only the specific task file. Does not affect other tasks or the SKILL.md. |
| **Remediation Guidance** | Convert all `### Step N:` headers and prose paragraphs into sequential `- [ ] N.` checklist items. Each step is one action. No prose paragraphs between steps. Preserve all Entry/Exit Criteria. |
| **Validation** | `grep -c "^### Step"` returns 0. `grep -c "^- \[ \]"` > 0. |
| **Workflow Validation** | Generate Z3 solve contract for the task's procedure. Run `solve check` — MUST return SAT. Run `plan plan` — MUST return SOLVED_SATISFICING or SOLVED_OPTIMALLY. |
| **Example Spec** | `.opencode#1278` Phase 4 |

### Type 4: Contract Template Addition

| Field | Value |
|-------|-------|
| **Name** | Contract Template Addition |
| **Description** | Adding input/output YAML contract template files under `.opencode/skills/<skill>/contracts/` for sub-agent dispatch. Templates use `{{placeholder}}` values that the orchestrator substitutes. |
| **Trigger** | Orchestrator cannot construct dispatch YAML because no template exists. Orchestrator falls back to inline work or reads task files (corrupting persona). |
| **Blast Radius** | **Skill-level** — affects all dispatches for the skill's tasks. Does not affect other skills. |
| **Remediation Guidance** | Create template YAML files at `.opencode/skills/<skill>/contracts/<task>-input-template.yaml` and `.opencode/skills/<skill>/contracts/<task>-output-template.yaml`. Use `{{placeholder}}` values. Reference templates in SKILL.md Operating Protocol steps. |
| **Validation** | `test -f` for each template file. `grep -q "{{"` for placeholder presence. Verify all templates are referenced in SKILL.md. |
| **Workflow Validation** | Generate Z3 solve contract for the dispatch chain. Run `solve check` — MUST return SAT. Run `plan plan` — MUST return SOLVED_SATISFICING or SOLVED_OPTIMALLY. |
| **Example Spec** | `.opencode#1278` Phase 3 |

### Type 5: Dispatch Annotation

| Field | Value |
|-------|-------|
| **Name** | Dispatch Annotation |
| **Description** | Adding dispatch type (`[inline]` or `[sub-task: <task-name>]`), contract YAML paths, template references, and chain annotations to Operating Protocol checklist steps. |
| **Trigger** | Orchestrator does not know whether a step is inline or sub-agent dispatch, what task name to invoke, or how to chain output contracts to subsequent inputs. |
| **Blast Radius** | **Skill-level** — affects the orchestrator's routing decisions for every step in the workflow. |
| **Remediation Guidance** | Annotate each checklist step with: dispatch type, task name, input/output paths, template reference, and chain annotation. Follow the format from `.opencode#1278` Phase 2. |
| **Validation** | `grep -c "^- \[ \] \[sub-task:"` >= expected sub-task count. `grep -c "chain:"` >= expected step count. |
| **Workflow Validation** | Generate Z3 solve contract for the annotated dispatch chain. Run `solve check` — MUST return SAT. Run `plan plan` — MUST return SOLVED_SATISFICING or SOLVED_OPTIMALLY. |
| **Example Spec** | `.opencode#1278` Phase 2 |

### Type 6: Tool Invocation Addition

| Field | Value |
|-------|-------|
| **Name** | Tool Invocation Addition |
| **Description** | Adding `solve` and/or `plan` tool invocation steps to the SKILL.md Operating Protocol. These steps were previously only in task files and were skipped by orchestrators. |
| **Trigger** | Orchestrator skips `solve` or `plan` validation because the steps are not in the SKILL.md Operating Protocol. |
| **Blast Radius** | **Skill-level** — adds validation gates to the workflow. Affects whether the orchestrator halts on UNSAT or UNSOLVABLE. |
| **Remediation Guidance** | Add inline steps to the Operating Protocol checklist: `[inline] Invoke solve model`, `[inline] Invoke solve check`, `[inline] Invoke plan plan`. Include chain annotations. |
| **Validation** | `grep -c "solve"` on SKILL.md Operating Protocol >= 2. `grep -c "plan"` on SKILL.md Operating Protocol >= 1. |
| **Workflow Validation** | Generate Z3 solve contract for the updated workflow. Run `solve check` — MUST return SAT. Run `plan plan` — MUST return SOLVED_SATISFICING or SOLVED_OPTIMALLY. |
| **Example Spec** | `.opencode#1278` Phase 2 |

### Type 7: Schema Sharing

| Field | Value |
|-------|-------|
| **Name** | Schema Sharing |
| **Description** | Merging or separating contract template files based on whether step N output feeds directly into step N+1 input without transformation. Shared schemas use one template file for both output and input. |
| **Trigger** | Unnecessary template proliferation (too many files) or incorrect schema separation (transformation needed but schema shared). |
| **Blast Radius** | **Workflow-level** — affects the chaining between steps. Does not affect individual step behavior. |
| **Remediation Guidance** | When step N output shape matches step N+1 input shape, use one template file. When shapes differ, create separate files. Document the sharing rationale in the template file comment. |
| **Validation** | Verify shared template files are referenced by both the output step and the input step in SKILL.md. Verify separate template files are NOT cross-referenced. |
| **Workflow Validation** | Generate Z3 solve contract for the shared-schema chain. Run `solve check` — MUST return SAT. Run `plan plan` — MUST return SOLVED_SATISFICING or SOLVED_OPTIMALLY. |
| **Example Spec** | `.opencode#1278` Phase 3 (shared schema rule) |

### Type 8: DISPATCH_GATE Modification

| Field | Value |
|-------|-------|
| **Name** | DISPATCH_GATE Modification |
| **Description** | Changing the DISPATCH_GATE section of a SKILL.md — the Orchestrator task() Prompt Protocol, Forbidden Patterns, Dispatch Context Contract, Sub-Agent Entry Criteria, or Orchestrator Entry Criteria. |
| **Trigger** | Changes to the dispatch protocol (e.g., adding new forbidden patterns, changing context contract fields). |
| **Blast Radius** | **Cross-skill** — DISPATCH_GATE sections are standardized across all skills. A change to one affects expectations for all. |
| **Remediation Guidance** | Update DISPATCH_GATE in ALL skill cards, not just one. Verify consistency across all `.opencode/skills/*/SKILL.md` files. Run cross-skill audit after change. |
| **Validation** | `diff` DISPATCH_GATE sections across all SKILL.md files. Verify identical content. |
| **Workflow Validation** | Generate Z3 solve contract for the cross-skill dispatch protocol. Run `solve check` — MUST return SAT. Run `plan plan` — MUST return SOLVED_SATISFICING or SOLVED_OPTIMALLY. |
| **Example Spec** | N/A — no current example. This type is defined for future use. |

### Type 9: Cross-Reference Update

| Field | Value |
|-------|-------|
| **Name** | Cross-Reference Update |
| **Description** | Adding, removing, or updating cross-references between skills or between skills and guidelines in the Cross-References section of a SKILL.md. |
| **Trigger** | A skill or guideline is added, removed, or renamed. Cross-references become stale or missing. |
| **Blast Radius** | **Cross-skill** — affects discoverability. A missing cross-reference means the orchestrator may not load a required skill. |
| **Remediation Guidance** | Update the Cross-References section to reflect current dependencies. Add new skills/guidelines. Remove deleted ones. Update renamed references. |
| **Validation** | Verify each cross-referenced skill/guideline exists. `grep` for stale references. |
| **Workflow Validation** | Generate Z3 solve contract for the cross-reference dependency graph. Run `solve check` — MUST return SAT. Run `plan plan` — MUST return SOLVED_SATISFICING or SOLVED_OPTIMALLY. |
| **Example Spec** | N/A — defined for future use. |

### Type 10: Workflow Restructure

| Field | Value |
|-------|-------|
| **Name** | Workflow Restructure |
| **Description** | Adding, removing, or reordering steps in the Operating Protocol checklist. Changes the workflow sequence. |
| **Trigger** | New requirements demand new steps. Redundant steps are removed. Dependency order changes. |
| **Blast Radius** | **Skill-level** — affects the execution order and completeness of the workflow. |
| **Remediation Guidance** | Update the Operating Protocol checklist. Update chain annotations for affected steps. Update or create contract templates for new steps. Verify Z3 SAT after restructure. |
| **Validation** | `solve check` returns SAT. `plan plan` returns SOLVED. Verify all chain annotations reference valid step numbers. |
| **Workflow Validation** | Generate Z3 solve contract for the restructured workflow. Run `solve check` — MUST return SAT. Run `plan plan` — MUST return SOLVED_SATISFICING or SOLVED_OPTIMALLY. |
| **Example Spec** | N/A — defined for future use. |

## Mandatory Workflow Validation Rule

For EVERY skill card or task card modification, regardless of change type, the following workflow validation MUST be performed before implementation is considered complete:

1. **Z3 solve contract generation** — Generate a solve contract representing the modified workflow's dependency structure, step ordering, and chain constraints
2. **Z3 solve check** — Run `./.opencode/tools/solve check` against the contract. MUST return SAT. UNSAT is a hard blocker — HALT with blocker report.
3. **Plan tool phase solvability** — Run `./.opencode/tools/plan plan` against the workflow's phase structure. MUST return SOLVED_SATISFICING or SOLVED_OPTIMALLY. UNSOLVABLE is a hard blocker — HALT with blocker report.
4. **Evidence artifact** — Save the solve contract and plan output to `.issues/{N}/contracts/workflow-validation/`. Include both SAT/SOLVED results and the contract YAML.

This rule applies to ALL 10 change types. No exceptions. No "this change is too small for workflow validation."

---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)
