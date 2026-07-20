## Problem Statement

Skill cards and task cards currently use free-form prose for routing, dispatch, and execution instructions. LLMs process prose differently than structured checklists — prose gets skipped, details get missed, and agents make routing errors that enforcement catches only after the damage is done. The existing admonishment work (SPEC #1357) adds discipline about *what* agents must do; this spec addresses *how* cards present instructions for maximum compliance.

## Scope

Reorganize the internal structure of all SKILL.md files and task cards to use workflow-grouped checklist format for dispatch, routing, and execution instructions. This is a structural refactor — no content changes, just reformatting existing instructions into agent-optimized presentation.

## Design Decisions

### Why Checklists Over Prose

LLMs treat `- [ ]` items as discrete execution steps. Prose paragraphs get processed as context, not as steps to follow. A checklist item is a contract: do this, verify that, return this.

### Workflow-Grouped Sections

Each card is organized into workflow groups that mirror the agent's actual execution flow:

1. **Entry Criteria** — preconditions that must be true before starting
2. **Dispatch** — how to route to sub-agents (SKILL.md only)
3. **Execution** — step-by-step task procedures (task cards only)
4. **Return** — what to return in the result contract
5. **Cleanup** — post-execution housekeeping

### What Does NOT Change

- Admonishment blocks (from SPEC #1357) stay as-is
- YAML frontmatter stays as-is (tooling, not agent-facing)
- Skill metadata (name, description, triggers) stays as-is
- Existing prose content that doesn't describe dispatch/routing/execution stays as-is

## Reorganization Template

### SKILL.md Structure

```markdown
---
# YAML frontmatter (unchanged)
---

# Skill Name

## Overview
(existing prose — kept as-is)

## Mandatory Task Discipline
(from SPEC #1357 — kept as-is)

## Trigger Dispatch Table
(existing table — kept as-is)

## Dispatch

- [ ] 1. Load this skill via `skill({name: "..."})`
- [ ] 2. Read the Trigger Dispatch Table
- [ ] 3. Match user intent to the correct task row
- [ ] 4. Dispatch via `task(subagent_type="general", prompt: "execute <task> from <skill>. Read `<skill>/tasks/<task>.md` first")`
- [ ] 5. Pass only: `worktree.path`, `github.owner`, `github.repo`, `authorization_scope`, `halt_at`, `pr_strategy`, `pipeline_phase`
- [ ] 6. Do NOT preload file paths, step sequences, expected outcomes, or orchestrator reasoning
- [ ] 7. Receive result contract: `status`, `finding_summary`, `artifact_path`, `blocker_reason`
- [ ] 8. Route to next pipeline step based on `status`

## Sub-Agent Routing
(existing content — kept as-is, describes sub-agent types and exclusions)

## Operating Protocol
(existing content — kept as-is)
```

### Task Card Structure — Non-Inline

```markdown
---
# YAML frontmatter (unchanged)
---

# Task Name

## Purpose
(existing prose — kept as-is)

## Task Discipline
(from SPEC #1357 — kept as-is)

## Entry Criteria

- [ ] 1. Verify preconditions listed below are satisfied
- [ ] 2. If any precondition fails, return BLOCKED with reason

### Preconditions
- `issue_number` is provided and valid
- `github.owner` and `github.repo` are set
- (skill-specific preconditions)

## Execution

- [ ] 1. Read the issue body and all comments via `github_issue_read`
- [ ] 2. (step specific to this task)
- [ ] 3. (step specific to this task)
- [ ] N. If blocked at any step, return BLOCKED with reason — do not work around it

## Return

- [ ] 1. Return result contract with exactly these fields:
       - `status`: DONE | BLOCKED | FAIL
       - `finding_summary`: 1-3 sentences of routing-significant output
       - `artifact_path`: path to full evidence on disk
       - `blocker_reason`: (if BLOCKED) why blocked
- [ ] 2. Full evidence artifacts go to `./tmp/` — do NOT return them in the contract

## Cleanup

- [ ] 1. Clean up any temporary files created during execution
- [ ] 2. Release any locks or reservations
```

### Task Card Structure — Inline (Orchestrator-Owned)

Same as non-inline, but:
- Task Discipline uses 3-item variant (no "do not dispatch sub-agents" item)
- Execution steps may reference orchestrator context
- Dispatch section is absent (orchestrator runs inline)

## Affected Files

### SKILL.md Files (~37 files)

Restructure routing and dispatch instructions into the Dispatch checklist section. Existing prose in Operating Protocol and Sub-Agent Routing stays as-is.

### Task Card Files (all task .md files under each skill's tasks/ directory)

Restructure execution instructions into Entry Criteria, Execution, Return, and Cleanup checklist sections. Existing domain-specific content (what each step does) stays as-is — only the presentation format changes.

## Implementation Approach

This is a mechanical refactor. For each card:

1. Read the existing content
2. Identify dispatch/routing/execution instructions
3. Reorganize into the template sections
4. Preserve all existing domain-specific content
5. Add checklist formatting to identified instructions

No content changes. No new instructions. Just reformatting existing prose into checklists.

## Implementation Phasing

Follow the same phase ordering as SPEC #1357 (admonishment work). This spec executes AFTER admonishments are in place — the reorganization includes the admonishment block in its template.

### Phase 1 — Core Pipeline Skills
`verification-before-completion`, `verification`, `verification-enforcement`, `adversarial-audit`, `completeness-gate`, `approval-gate`, `implementation-pipeline`

### Phase 2 — Git + Issue Operations
`git-workflow`, `using-git-worktrees`, `conflict-resolution`, `finishing-a-development-branch`, `pr-creation-workflow`, `issue-operations`, `issue-review`

### Phase 3 — Spec + Plan
`spec-creation`, `writing-plans`, `brainstorming`, `plan`, `plan-creation-pipeline`

### Phase 4 — Code Quality + Research
`engineering-approach`, `test-driven-development`, `programming-principles`, `systematic-debugging`, `research`, `researcher`

### Phase 5 — Tooling + Communication
`mcp-tool-usage`, `multimodal-dispatch`, `skill-creator`, `sync-guidelines`, `changelog-generator`, `correspondence`, `sre-runbook`, `playwright-cli`

## Dependencies

- SPEC #1357 (admonishment addition) must be completed first
- Canonical reference card from #1357 provides the admonishment block

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | All SKILL.md files contain a Dispatch checklist section with ≥5 items | `string` | grep for "## Dispatch" heading + count checklist items |
| SC-2 | All non-inline task cards contain Entry Criteria, Execution, Return, and Cleanup sections | `string` | grep for all four section headings in task card files |
| SC-3 | All checklist items use `- [ ] N.` numbered format | `string` | grep for numbered checklist pattern in reorganized files |
| SC-4 | No existing domain-specific content was lost during reorganization | `semantic` | sub-agent compares before/after content of sample cards |
| SC-5 | Reorganized cards match the template structure defined in this spec | `semantic` | sub-agent reads sample cards and verifies template compliance |
| SC-6 | Admonishment block is present in all reorganized cards (inherited from #1357) | `string` | grep for admonishment heading in reorganized files |

🤖 Co-authored with AI: opencode (opencode/mimo-v2-free)