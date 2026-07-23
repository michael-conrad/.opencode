# Phase 1 — Create new spec-creation skill

**Concern:** New flat skill architecture — single SKILL.md + 4 task files with clean-room decomposition

**Files:**
- `.opencode/skills/spec-creation/SKILL.md` — New flat skill card
- `.opencode/skills/spec-creation/tasks/analyze.md` — ANALYSIS task
- `.opencode/skills/spec-creation/tasks/create.md` — PRODUCTION task
- `.opencode/skills/spec-creation/tasks/validate.md` — VERIFICATION task
- `.opencode/skills/spec-creation/tasks/revise.md` — PRODUCTION (revision) task

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9, SC-13, SC-14, SC-15, SC-16

**Dependencies:** None

**Entry conditions:** Spec approved, feature branch exists

**Exit conditions:** New SKILL.md and 4 task files written, all SCs verifiable

## Code Path Coverage

- SKILL.md frontmatter (name, description, license, provenance)
- SKILL.md Workflows section (analyze → create → validate → revise loop)
- analyze.md task file (pre-spec inspection → requirements → decomposition → artifacts)
- create.md task file (read artifacts → assemble spec → remote issue → write local)
- validate.md task file (holistic self-check → structural validation → PASS/FAIL)
- revise.md task file (read spec → update → change control)

## Cross-Cutting SCs

- SC-8: No task()/skill() in task files — applies to all 4 task files
- SC-13, SC-14, SC-15: Clean-room context — applies to analyze, create, validate respectively

## Interface Boundaries

- SKILL.md must follow #2076 standards (Workflows section format with sub-bullet dispatch contracts)
- Task files must follow task card structure standards
- No sub-skill references in dispatch strings

## State Transitions

- Spec not yet created → SKILL.md + task files written
- Task files exist → ready for Phase 2

## Step-by-step

- [ ] 1. **Write SKILL.md (**sub-agent**).** Create `.opencode/skills/spec-creation/SKILL.md` with:
  - Frontmatter: name `spec-creation`, description in agent-intent format (no "Load via skill() when" or "User phrases:"), license MIT, provenance AI-generated
  - Workflows section with 3-step pipeline: analyze → create → validate → (revise → validate)* → done
  - Each workflow step as a sub-bullet with Prompt, Context, and Returns fields per #2076 standards
  - No sub-skill references in dispatch strings
  - **→ SC-1, SC-2, SC-3, SC-16**

- [ ] 2. **Write analyze.md (**sub-agent**).** Create `.opencode/skills/spec-creation/tasks/analyze.md` with:
  - ANALYSIS category: pre-spec inspection → requirements extraction → decomposition → analytical artifacts
  - Entry criteria: {issue_number, project_root} only
  - No spec writing, remote issue ops, or holistic check
  - No task() or skill() calls
  - **→ SC-4, SC-8, SC-13**

- [ ] 3. **Write create.md (**sub-agent**).** Create `.opencode/skills/spec-creation/tasks/create.md` with:
  - PRODUCTION category: read analysis artifacts → assemble spec → create remote issue stub → write remote body → write local spec
  - Entry criteria: {issue_number, analysis_artifact_path} only
  - No analysis steps or verification steps
  - No task() or skill() calls
  - Writes spec to correct `.issues/{N}/` or `<sub-repo>/.issues/{N}/` path
  - **→ SC-5, SC-8, SC-9, SC-14**

- [ ] 4. **Write validate.md (**sub-agent**).** Create `.opencode/skills/spec-creation/tasks/validate.md` with:
  - VERIFICATION category: holistic self-check (11 dimensions) + structural validation (SC completeness, evidence types, traceability)
  - Entry criteria: {issue_number, spec_path} only
  - No production or analysis steps
  - No task() or skill() calls
  - **→ SC-6, SC-8, SC-15**

- [ ] 5. **Write revise.md (**sub-agent**).** Create `.opencode/skills/spec-creation/tasks/revise.md` with:
  - PRODUCTION category: read spec → update content → change control tracking
  - No task() or skill() calls
  - **→ SC-7, SC-8**

#### Phase 1 VbC

- [ ] 1a. **VbC (**clean-room**).** Verify: `ls skills/spec-creation/` shows SKILL.md + tasks/ only; `ls skills/spec-creation/tasks/` shows 4 files; grep SKILL.md for "from spec-creation-validation" — empty; grep SKILL.md description for "Load via skill() when" — empty; grep all 4 task files for "task(" and "skill(" — empty; grep analyze.md for "write spec" — empty; grep create.md for "inspect" — empty; grep validate.md for "write spec" — empty; grep SKILL.md Workflows section for analyze → create → validate → revise loop. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-16**

**Concern transition:** Leaving new flat skill architecture → entering brainstorming handoff. Phase 2 depends on Phase 1's SKILL.md and task files existing.
