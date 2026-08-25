---
title: '[SPEC-FIX] executing-plans skill present on disk but not registered in available_skills — blocks for_pr plan-execution gate'
status: open
labels:
- needs-approval
remote_issue: 2324
remote_url: https://github.com/michael-conrad/.opencode/issues/2324
---

> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2324/

## Problem

The `executing-plans` skill exists on disk at `.opencode/skills/executing-plans/SKILL.md` (with `tasks/read-plan.md` and `tasks/dispatch-phase.md`), is tracked in git, and has valid YAML frontmatter (`name: executing-plans`, `description`, `license: MIT`, `provenance: AI-generated`). However, it is NOT present in the agent's `<available_skills>` list. The approval-gate skill's Mandatory Routing Rule for `for_pr` scope requires dispatching `executing-plans` before PR creation, but the skill cannot be loaded via `skill({name: "executing-plans"})` because it is absent from the available skills registry. This blocks the mandatory plan-execution gate for all `for_pr`-scoped work.

## Root Cause

The skill is missing from the skilldeck registration/discovery mechanism that populates `<available_skills>`. The SKILL.md file itself is valid — the defect is in the discovery/registration layer, not the skill card content. The skill was re-added by merged PR #2321 (issue #1364), but the discovery mechanism has not registered it, so the runtime never surfaces it to the agent.

## Scope

- Register `executing-plans` in the skilldeck discovery mechanism so it appears in `<available_skills>`
- Verify `skill({name: "executing-plans"})` loads successfully
- Verify the approval-gate `for_pr` routing rule can dispatch `executing-plans`

**Out of scope:**
- Changes to the `executing-plans` SKILL.md content or task cards
- Changes to the approval-gate routing rule text
- Behavioral test authoring (tracked separately)

## Approach

Identify the skilldeck registration/discovery mechanism that populates `<available_skills>` and add the `executing-plans` entry. The discovery is driven by YAML frontmatter self-discovery per `.opencode/AGENTS.md` "Skill Self-Discovery" section. The fix registers the existing skill card so the runtime surfaces it to the agent, restoring the mandatory plan-execution gate for `for_pr`-scoped work.

## Impact

1. **Risk:** `for_pr`-scoped work proceeds to PR creation without executing the plan. **Mitigation:** Register the skill so the mandatory gate fires.
2. **Risk:** Other skills may also be missing from the registry. **Mitigation:** Audit the full skill deck for registration gaps.
3. **Dependency:** Requires the skilldeck discovery mechanism to pick up the registration. **Call to action:** Register `executing-plans` and verify `skill()` loads it.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
