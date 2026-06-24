# [SPEC-FIX] writing-plans: Trigger Dispatch Table classifies orchestrator tasks as sub-task

## Problem

The `writing-plans` skill's Trigger Dispatch Table classifies `create`, `retroactive`, and `completion` as `sub-task` dispatches, but their task files contain orchestrator-level routing instructions (sub-agent dispatches, Z3 checks, skill invocations). A sub-agent has no `task()` tool and cannot dispatch sub-agents. This creates an impossible execution path.

Additionally, the `tasks/create/` subdirectory contains two monolithic legacy task files (`create-and-validate.md`, `plan-structure.md`) that bundle multiple pipeline steps, duplicate content from the decomposed top-level task files, contain orchestrator-level instructions, use wrong syntax, and bypass platform routing. These are deprecated artifacts that must be purged.

The spec itself has a secondary defect: it does not define what a fully complete and correctly formatted plan looks like. The `writing-plans` skill produces plans, but there is no canonical specification of the plan format. This means every plan produced by the skill is at risk of being incomplete or incorrectly formatted. This spec must define the plan format requirements so the fixed skill can produce plans that match.

## Root Cause

The `create.md` task file's operating protocol lists 10 steps of "orchestrator routes to: X via sub-agent" — instructions only the orchestrator can execute. The Trigger Dispatch Table incorrectly classifies this as `sub-task` instead of `orchestrator`. Same pattern applies to `retroactive` and `completion`.

The `create/` subdirectory files were written before the skill was decomposed into 10 individual sub-task files. They were never removed after decomposition, creating duplicate, contradictory, and stale content.

The plan format was never formally specified. The `create.md` task file describes how to create a plan (operating protocol, dispatch table format) but does not define the output format of the plan document itself. This means the skill produces plans without a canonical target format to validate against.

## Plan Format Requirements

Every plan produced by the `writing-plans` skill MUST conform to the following format specification. This is the canonical plan format — no deviations, no simplified alternatives, no missing sections.

### Required Sections (in order)

1. **Title line**: `# Implementation Plan — [`.opencode#N`](https://github.com/michael-conrad/.opencode/issues/N) — description`
2. **Goal/Architecture/Files block**: Three bulleted items with `- [ ]` checkboxes:
   - `- [ ] **Goal:**` — one-sentence description of what the plan achieves
   - `- [ ] **Architecture:**` — phase ordering and dependency description
   - `- [ ] **Files:**` — bulleted sub-list of every file modified, with phase assignment
3. **Compliance admonishment blockquote** (top): Full canonical text (see §Admonishment Text below). MUST appear before the first phase section.
4. **Phase sections**: One `## Phase N — Name` per phase, separated by `---` horizontal rules
5. **Phase metadata block**: Immediately after the phase heading, a block with:
   - `**Concern:**` — what architectural concern this phase addresses
   - `**File:**` or `**Files:**` — which file(s) this phase modifies
   - `**SCs:**` — comma-separated list of SCs this phase covers
   - `**Dependencies:**` — which phases must complete first (or `None`)
   - `**Entry condition:**` — what must be true before this phase starts
   - `**Exit condition:**` — what must be true after this phase completes
   - `**Artifact paths:**` — `./tmp/{N}/artifacts/pipeline-{step_label}-{STATUS}-{timestamp}.yaml`
6. **Sequentially numbered steps**: Every step in the plan is numbered sequentially from 1 to N across ALL phases. No resetting per phase. Each step is a `- [ ] N.` checkbox.
7. **Dispatch indicators**: Every step title MUST contain exactly one of three dispatch mode indicators:
   - `(**sub-agent**)` — orchestrator dispatches a sub-agent with context (not blind)
   - `(**clean-room**)` — orchestrator dispatches a clean-room sub-agent (blind, no prior context)
   - `(**inline**)` — orchestrator executes the step directly (no sub-agent)
8. **Sub-steps**: Steps with multiple operations MUST use indented sub-bullets (`- [ ] Na.`, `- [ ] Nb.`, etc.) under the parent step. No collapsing multiple operations into prose.
9. **RED+green item chains**: Items are interleaved as RED→GREEN→RED→GREEN→... in dependency order, not batched as all REDs then all GREENs. Each item follows the full chain:
   - RED → RED doublecheck → Post-RED enforcement → GREEN → Post-GREEN enforcement → Structural checks → GREEN doublecheck → Checkpoint commit
   - Each of these is a separate sequentially numbered step
   - SC annotations (`→ SC-N`) appear on RED and GREEN steps
   - Items that have no interdependency may be ordered arbitrarily; items that share files or symbols must be ordered so that each GREEN establishes the baseline for the next item's RED
10. **SC annotations**: `→ SC-N` at the end of step titles that verify specific SCs. Multiple SCs: `→ SC-1, SC-2`.
11. **Phase completion block**: After the last RED+green item in a phase, a block with:
    - VbC (`(**clean-room**)`)
    - Resolve models (`(**inline**)`)
    - Auditor 1: verification-audit (`(**clean-room**)`)
    - Auditor 2: verification-audit (`(**clean-room**)`)
    - Cross-validate (`(**clean-room**)`)
    - Regression check (`(**clean-room**)`)
    - Review prep (`(**clean-room**)`)
12. **Concern transition**: Between phases, a paragraph describing what concern is being left and what concern is being entered. Format: `**Concern transition:** Leaving X → entering Y. Phase N depends on...`
13. **Compliance admonishment blockquote** (bottom): Same canonical text as the top. MUST appear before the Exit Criteria section.
14. **Exit Criteria section**: `## Exit Criteria` with `- [ ] C1:` through `C{N}:` items summarizing the overall completion conditions.

### Admonishment Text

The exact canonical text for the compliance admonishment blockquote:

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

### Prohibited Patterns

- Dispatch tables (6-column `| Gate | Dispatch Type | ... |` tables) — these are replaced by dispatch indicators in step titles
- Hardcoded gate sequences — gate sequence MUST be discovered from `implementation-pipeline/SKILL.md` §Dispatch Routing Table at plan-creation time
- TBD/TODO placeholders — every step must be concrete and actionable
- Shared cross-references between phases — each phase is self-contained
- Zero-indexed numbering — steps start at 1, not 0
- Line number references — use stable anchors (function names, section headers) instead

### Validation Rules

Every plan MUST pass these validation checks:

1. Every step is `- [ ] N.` with at least one sub-bullet or dispatch indicator
2. Every step title contains exactly one of `(**sub-agent**)`, `(**clean-room**)`, or `(**inline**)`
3. Gate sequence matches `implementation-pipeline/SKILL.md` dispatch routing table
4. No step describes more than one atomic action — every sub-operation is expanded into its own `- [ ] N.` entry
5. All SCs referenced via `→ SC-N` annotations
6. No TBD/TODO placeholders
7. Admonishment blockquote present at both top and bottom
8. Phase dependency ordering matches spec architecture
9. Steps are sequentially numbered across all phases (no reset)
10. Phase completion block present after each phase's last RED+green item
11. Concern transition paragraph present between phases
12. Exit Criteria section present with completion conditions

## Defects

### Dispatch Classification (1-4)

| # | Location | Defect | Severity |
|---|----------|--------|----------|
| 1 | SKILL.md line 27 | `create` → `sub-task`, should be `orchestrator` | CRITICAL |
| 2 | SKILL.md line 28 | `retroactive` → `sub-task`, should be `orchestrator` | CRITICAL |
| 3 | SKILL.md line 29 | `completion` → `sub-task`, should be `orchestrator` | CRITICAL |
| 4 | SKILL.md lines 50-53 | Invocation table lists orchestrator tasks as `task()` calls | MAJOR |

### Sub-Agent Routing (5-6, 13-14)

| # | Location | Defect | Severity |
|---|----------|--------|----------|
| 5 | `audit-fidelity.md` line 5 | "with auditor sub-agent type context" — sub-agent cannot set subagent_type | MAJOR |
| 6 | `audit-concern.md` line 5 | Same as #5 | MAJOR |
| 13 | SKILL.md line 95 | "All tasks run via `task(subagent_type="general")`" — false for orchestrator tasks | MAJOR |
| 14 | SKILL.md line 95 | "No inline work" — contradicts 21-step pipeline which includes `[inline]` steps | MAJOR |

### create.md (7-8, 18-19)

| # | Location | Defect | Severity |
|---|----------|--------|----------|
| 7 | `create.md` lines 16-25 | Missing 11 steps (1 inline + 10 z3-check) from 21-step pipeline | MAJOR |
| 8 | `create.md` | Step 1 inline approval check not in operating protocol | MINOR |
| 18 | `create.md` line 46 | Entry criteria requires "Spec-to-plan handoff PASS" — circular: handoff is produced by step 4 of the pipeline | MAJOR |
| 19 | `create.md` line 5 | "The orchestrator dispatches each step via `task()`" — explicitly confirms orchestrator-level, contradicting Trigger Dispatch Table | MAJOR |

### completion.md (9-12, 20)

| # | Location | Defect | Severity |
|---|----------|--------|----------|
| 9 | `completion.md` line 31 | `task()` call in sub-agent task file | CRITICAL |
| 10 | `completion.md` line 16 | "invoke `writing-plans --task create`" in sub-agent task file | CRITICAL |
| 11 | `completion.md` line 20 | "invoke `issue-operations --task link-sub-issue`" in sub-agent task file | CRITICAL |
| 12 | `completion.md` line 24 | "invoke `writing-plans --task validate`" in sub-agent task file | CRITICAL |
| 20 | `completion.md` line 41 | References `.opencode/skills/completion-core/completion-core.md` — path should be `completion-core/SKILL.md` | MINOR |

### retroactive.md (15-17)

| # | Location | Defect | Severity |
|---|----------|--------|----------|
| 15 | `retroactive.md` | Task file is a simplified 3-step procedure; SKILL.md says retroactive uses "the same 21-step sequence" | MAJOR |
| 16 | `retroactive.md` line 36 | "Run `validate` task checks" — `validate` is a sub-task, sub-agent cannot dispatch | CRITICAL |
| 17 | `retroactive.md` line 37 | "issue-operations -> read-sub-issues" — sub-task dispatch in sub-task file | CRITICAL |

### Deprecated create/ Subdirectory (21-44) — PURGE

| # | Location | Defect | Severity |
|---|----------|--------|----------|
| 21 | `create/create-and-validate.md` | Monolithic legacy file (202 lines) bundling multiple pipeline steps, skipping all Z3 validation gates | CRITICAL |
| 22 | `create/plan-structure.md` | Monolithic legacy file (269 lines) bundling multiple pipeline steps, skipping all Z3 validation gates | CRITICAL |
| 23 | `create-and-validate.md` line 145 | Uses `/skill verification-enforcement --task revisit` — CLI syntax for humans, not `skill()` for sub-agents | MAJOR |
| 24 | `plan-structure.md` line 53 | Same `/skill` CLI syntax issue | MAJOR |
| 25 | `create-and-validate.md` line 182 | Calls `github_issue_write` directly — platform routing bypass, must route through `issue-operations` | CRITICAL |
| 26 | `plan-structure.md` line 65 | "Query GitHub Issue for spec content" — same platform routing bypass | CRITICAL |
| 27 | `create-and-validate.md` line 168 | Contains `task()` rules section — sub-agents cannot call `task()` | CRITICAL |
| 28 | `create-and-validate.md` lines 30, 36 | Duplicate compliance admonishment blockquotes | MINOR |
| 29 | `create-and-validate.md` lines 72, 84 | Duplicate "Spec-to-Plan Handoff Artifact Check" steps (7.5 and 7.7) | MINOR |
| 30 | `plan-structure.md` lines 23-30, 103-107 | Duplicate phase dependency solve contract sections | MINOR |
| 31 | `plan-structure.md` lines 32-40, 244-260 | Duplicate plan utility validation sections | MINOR |
| 32 | `plan-structure.md` lines 42-49, 109-115 | Duplicate SC-ID mapping sections | MINOR |
| 33 | `create-and-validate.md` line 91 vs `plan-structure.md` line 264 | Contradiction: one says "Generate Implementation Checklist", other says "REMOVED" | MAJOR |
| 34 | `plan-structure.md` line 264 | Dead documentation — "Step 6: Generate Implementation Checklist — REMOVED" heading still present | MINOR |
| 35 | `create-and-validate.md` line 99 | Self-review by same sub-agent that wrote the plan — not adversarial | MAJOR |
| 36 | `create-and-validate.md` line 201, `plan-structure.md` line 268 | Circular dependency — each references the other as a related task | MAJOR |
| 37 | `plan-structure.md` line 72 | Fragment marker with no fragment include system | MINOR |
| 38 | `create.md` line 5 | Claims "10 decomposed sub-task files" but `create/` contains 2 monolithic files, not 10 | MAJOR |
| 39 | `create-and-validate.md` lines 106-141 | Duplicates `validate.md` content (12 validation rules) | MAJOR |
| 40 | `create-and-validate.md` lines 143-146 | Duplicates `revisit.md` content | MAJOR |
| 41 | `plan-structure.md` lines 53-54 | Duplicates `research.md` content | MAJOR |
| 42 | `plan-structure.md` lines 58-61 | Duplicates `readiness.md` content | MAJOR |
| 43 | `plan-structure.md` lines 74-208 | Duplicates `structure.md` content | MAJOR |
| 44 | `plan-structure.md` lines 244-260 | Duplicates `solve.md` content | MAJOR |

## Fix

1. Change Trigger Dispatch Table entries for `create`, `retroactive`, `completion` from `sub-task` to `orchestrator`
2. Update Invocation table: orchestrator reads task file and executes steps inline, does not `task()` itself
3. Update `audit-fidelity.md` and `audit-concern.md`: remove "with auditor sub-agent type context" — auditor subagent_type is passed by orchestrator in task context, not set by sub-agent
4. Update `create.md` operating protocol: add missing `[inline]` step 1 (verify spec approved) and all 10 `[z3-check]` steps from the 21-step pipeline
5. Update `completion.md`: remove all `task()` calls and skill invocations — these are orchestrator-level operations
6. Update `retroactive.md`: align with the 21-step pipeline per SKILL.md retroactive operating protocol; remove sub-task dispatches
7. Update SKILL.md §Sub-Agent Routing: remove "All tasks run via `task(subagent_type="general")`" — orchestrator tasks do not; remove "No inline work" — inline steps exist
8. Fix `create.md` entry criteria: remove circular "Spec-to-plan handoff PASS" requirement
9. Fix `completion.md` line 41: correct path to `completion-core/SKILL.md`
10. **PURGE `tasks/create/` subdirectory** — delete `create-and-validate.md` and `plan-structure.md`. These are deprecated monolithic legacy files that duplicate decomposed top-level task files, contain orchestrator-level instructions, use wrong syntax, and bypass platform routing. All content they duplicate already exists in the top-level task files (`research.md`, `readiness.md`, `structure.md`, `solve.md`, `write.md`, `revisit.md`, `validate.md`, `audit-fidelity.md`, `audit-concern.md`, `completion.md`).
11. Update `create.md` line 5: remove claim of "10 decomposed sub-task files" — the sub-task files are at the top level, not in `create/`
12. Remove `create.md` §Sub-Task Files table (lines 28-40) — references to `create-and-validate` and `plan-structure` are stale
13. **Add `## Plan Format Requirements` section to `create.md`** — the canonical plan format specification defined in this spec's §Plan Format Requirements must be embedded in `create.md` as a referenceable section. This ensures the plan format is defined in the skill itself, not just in this spec.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `create` dispatch type is `orchestrator` in Trigger Dispatch Table | structural | `grep` for `create.*orchestrator` in SKILL.md |
| SC-2 | `retroactive` dispatch type is `orchestrator` in Trigger Dispatch Table | structural | `grep` for `retroactive.*orchestrator` in SKILL.md |
| SC-3 | `completion` dispatch type is `orchestrator` in Trigger Dispatch Table | structural | `grep` for `completion.*orchestrator` in SKILL.md |
| SC-4 | Invocation table does not list orchestrator tasks as `task()` calls | structural | `grep` for `task(..., prompt: "execute create task"` returns no match |
| SC-5 | `audit-fidelity.md` does not contain "with auditor sub-agent type context" | structural | `grep` returns no match |
| SC-6 | `audit-concern.md` does not contain "with auditor sub-agent type context" | structural | `grep` returns no match |
| SC-7 | `create.md` operating protocol includes all 21 steps (1 inline + 10 sub-task + 10 z3-check) | structural | Count steps in create.md operating protocol |
| SC-8 | `completion.md` contains no `task()` calls | structural | `grep` for `task(` returns no match |
| SC-9 | `completion.md` contains no skill invocations (e.g., "invoke `writing-plans`") | structural | `grep` for `invoke` returns no match |
| SC-10 | `retroactive.md` operating protocol matches 21-step pipeline | structural | Count steps in retroactive.md; verify no sub-task dispatches |
| SC-11 | SKILL.md §Sub-Agent Routing does not claim "All tasks run via `task()`" | structural | `grep` for "All tasks run via" returns no match |
| SC-12 | SKILL.md §Sub-Agent Routing does not claim "No inline work" | structural | `grep` for "No inline work" returns no match |
| SC-13 | `create.md` entry criteria does not require "Spec-to-plan handoff PASS" | structural | `grep` for "Spec-to-plan handoff" in create.md returns no match |
| SC-14 | `completion.md` line 41 references correct path | structural | `grep` for `completion-core/SKILL.md` in completion.md |
| SC-15 | `tasks/create/` subdirectory does not exist | structural | `ls .opencode/skills/writing-plans/tasks/create/` returns no such file |
| SC-16 | `create.md` does not reference `create-and-validate` or `plan-structure` | structural | `grep` for `create-and-validate\|plan-structure` in create.md returns no match |
| SC-17 | `create.md` contains a `## Plan Format Requirements` section defining the canonical plan format | structural | `grep` for `## Plan Format Requirements` in create.md returns match |
| SC-18 | `create.md` Plan Format Requirements section includes admonishment text | structural | `grep` for "Compliance Requirement" in create.md returns match |
| SC-19 | `create.md` Plan Format Requirements section includes all 14 required sections in order | structural | Read create.md Plan Format Requirements section; verify all 14 sections listed |
| SC-20 | `create.md` Plan Format Requirements section includes all 12 validation rules | structural | Count validation rules in create.md Plan Format Requirements section |
| SC-21 | `create.md` Plan Format Requirements section includes prohibited patterns list | structural | `grep` for "Prohibited Patterns" in create.md returns match |
| SC-22 | `create.md` Plan Format Requirements section includes all three dispatch indicator modes (`(**sub-agent**)`, `(**clean-room**)`, `(**inline**)`) | structural | `grep` for `(**sub-agent**)` and `(**clean-room**)` and `(**inline**)` in create.md — all three match |
| SC-23 | `create.md` Plan Format Requirements section includes RED+green item chain specification | structural | `grep` for "RED+green" in create.md returns match |
| SC-24 | `create.md` Plan Format Requirements section includes phase completion block specification | structural | `grep` for "Phase completion" in create.md returns match |
| SC-25 | `create.md` Plan Format Requirements section includes concern transition specification | structural | `grep` for "Concern transition" in create.md returns match |
| SC-26 | `create.md` Plan Format Requirements section includes exit criteria specification | structural | `grep` for "Exit Criteria" in create.md returns match |

## Labels

`[SPEC-FIX]`, `skill`

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
