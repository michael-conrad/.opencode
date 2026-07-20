## Problem Statement

Skill cards and task cards lack a visible, procedural admonishment about mandatory task discipline. The existing enforcement layer (critical-rules-034, critical-rules-016, critical-rules-043) catches violations after they happen — by then the pipeline is poisoned. A preventive admonishment block at the top of each card gives the agent a cognitive speed bump before it decides to skip a step, inline work, or spawn sub-sub-agents.

## Scope

Add a mandatory task discipline admonishment block to all existing SKILL.md files and task card files. Create a canonical reference card for the admonishment text. Update the skill-creator skill and adversarial-audit to encode and validate the pattern.

## Design Decisions

### Two Audiences, Two Admonishment Formats

**SKILL.md** — read by the orchestrator. The admonishment governs dispatch decisions.

**Task cards** — read by the sub-agent. The admonishment governs execution behavior.

The sub-agent never sees the SKILL.md. If the admonishment is only in the SKILL.md, the sub-agent has no visibility into discipline requirements.

### Numbered Checklists

Agents treat `- [ ] N.` items as execution steps, not prose to skip. Numbered items are referenceable and reinforce sequential execution.

### Inline Task Escape Hatch

Some tasks are legitimately orchestrator-owned (marked `inline` in the dispatch table). These task cards get a stripped-down admonishment without the "do not dispatch sub-agents" item.

### Canonical Reference

The canonical admonishment text lives at `.opencode/skills/skill-creator/reference/skill-card-spec.md`. Both skill-creator (for new skills) and adversarial-audit (for validation) consume this single source of truth.

### Inline Text, Not Includes

The admonishment is copy-pasted into each SKILL.md and task card. SKILL.md files are self-contained — no include mechanism. The text is short (~100 words) and stable. Bounded maintenance cost.

## Admonishment Text

### SKILL.md Version (5 items)

```markdown
## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work
         that should be delegated to a sub-agent produces defective
         deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless
         explicitly marked as inline/orchestrator in this skill
- [ ] 4. Sub-agents must not dispatch sub-agents
- [ ] 5. Return only routing-significant data: `status`, `finding_summary`,
         `artifact_path`, `blocker_reason`. Full evidence goes to disk.
```

### Task Card Version — Non-Inline (4 items)

```markdown
## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`,
         `blocker_reason`. Full evidence goes to disk.
```

### Task Card Version — Inline (3 items)

```markdown
## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. If blocked, return BLOCKED with reason — do not work around it
- [ ] 3. Return only: `status`, `finding_summary`, `artifact_path`,
         `blocker_reason`. Full evidence goes to disk.
```

### Placement

- **SKILL.md:** after Overview, before Trigger Dispatch Table
- **Task cards:** after Purpose, before Operating Protocol

## Affected Files

### SKILL.md Files (~37 files)

All files matching `.opencode/skills/*/SKILL.md` and `.opencode/skills/*/platforms/*/SKILL.md`.

### Task Card Files (all task .md files under each skill's tasks/ directory)

Each task card needs the admonishment inserted. Inline tasks (identified by `inline` in the parent SKILL.md dispatch table) get the 3-item variant.

### New Files

- `.opencode/skills/skill-creator/reference/skill-card-spec.md` — canonical admonishment text and skill card structure reference

### Modified Skills

- `skill-creator` — add checklist item to init task flow: "add mandatory task discipline admonishment"
- `adversarial-audit` — add REQ-5 check to spec-audit and plan-fidelity: verify admonishment presence and correct variant

## Implementation Phasing

Each phase is independently valuable. After Phase 1, the highest-risk skills are disciplined.

### Phase 1 — Verification + Approval (highest risk)

Skills: `verification-before-completion`, `verification`, `verification-enforcement`, `adversarial-audit`, `completeness-gate`, `approval-gate`, `implementation-pipeline`

### Phase 2 — Git + Issue Operations (high risk, frequent use)

Skills: `git-workflow`, `using-git-worktrees`, `conflict-resolution`, `finishing-a-development-branch`, `pr-creation-workflow`, `issue-operations`, `issue-review`

### Phase 3 — Spec + Plan (medium risk)

Skills: `spec-creation`, `writing-plans`, `brainstorming`, `plan`, `plan-creation-pipeline`

### Phase 4 — Code Quality + Research (lower risk)

Skills: `engineering-approach`, `test-driven-development`, `programming-principles`, `systematic-debugging`, `research`, `researcher`

### Phase 5 — Tooling + Communication (lowest risk)

Skills: `mcp-tool-usage`, `multimodal-dispatch`, `skill-creator`, `sync-guidelines`, `changelog-generator`, `correspondence`, `sre-runbook`, `playwright-cli`

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | All SKILL.md files contain the 5-item Mandatory Task Discipline admonishment | `string` | grep for admonishment heading in all SKILL.md files |
| SC-2 | All non-inline task cards contain the 4-item Task Discipline admonishment | `string` | grep for admonishment heading in task card files |
| SC-3 | All inline task cards contain the 3-item Task Discipline admonishment (item 2 removed) | `string` | grep for admonishment heading + verify item 2 absent in inline task cards |
| SC-4 | Admonishment placement is correct (SKILL.md: after Overview before Dispatch Table; task cards: after Purpose before Operating Protocol) | `semantic` | sub-agent reads cards and verifies positioning |
| SC-5 | Canonical reference card exists at `.opencode/skills/skill-creator/reference/skill-card-spec.md` | `structural` | file existence check |
| SC-6 | `skill-creator` init task includes admonishment insertion step | `string` | grep for admonishment reference in init task |
| SC-7 | `validate_skill_cards.py` includes REQ-5 check for admonishment presence | `string` | grep for REQ-5 in validation script |
| SC-8 | Adversarial audit task files check for admonishment in skill card audits | `semantic` | sub-agent reads auditor task files and verifies check presence |
| SC-9 | Behavioral test verifies agent follows admonishment (dispatches via task(), does not inline) | `behavioral` | `opencode-cli run` with assertion on dispatch behavior |

🤖 Co-authored with AI: opencode (opencode/mimo-v2-free)