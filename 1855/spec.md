# [SPEC] Rewrite SKILL.md descriptions from user-trigger-phrase-oriented to agent-intent-oriented

## Intent and Executive Summary

| Field | Value |
|-------|-------|
| **Problem Statement** | All 43 SKILL.md `description` frontmatter fields are written as if the opencode runtime parses trigger phrases and auto-dispatches skills. In reality, the runtime (`packages/core/src/skill.ts`) only recognizes `name`, `description`, `slash` — the `description` is rendered verbatim into the `<available_skills>` XML block in the system prompt. The LLM reads it and decides whether to call `skill()`. There is zero trigger-phrase matching in the runtime. |
| **Root Cause / Motivation** | The current pattern (`"Use when... Invoke for:... Trigger phrases:..."`) was designed for a keyword-matching runtime that doesn't exist. It trains the LLM to pattern-match user words instead of reasoning about its own intent. The LLM needs descriptions that answer "Should I dispatch this skill for what I'm about to do?" — not "Did the user say one of these magic words?" |
| **Approach Chosen** | Rewrite all 43 SKILL.md descriptions to lead with agent-intent language (what the agent is doing when it should dispatch), with user trigger phrases retained as supplementary info appended after the agent-facing text. Update the skill-creator validation scripts and reference docs to enforce the new pattern. |
| **Alternatives Considered & Why Discarded** | (1) Adding new frontmatter fields — discarded because the runtime only recognizes `name`, `description`, `slash`. (2) Removing user phrases entirely — discarded because they still provide useful signal for the LLM. (3) Keeping the current pattern — discarded because it's architecturally wrong. |
| **Key Design Decisions** | DEC-1: The `description` field is the only mechanism available — no new fields. DEC-2: User phrases are retained as supplementary info, not removed. DEC-3: The skill-creator validation script must enforce the new pattern. DEC-4: Behavioral enforcement tests required because this changes agent dispatch behavior. |

---

## Phase 1: Define the New Description Pattern

### Steps
1. ☐ Define the canonical agent-intent description pattern
2. ☐ Update skill-creator reference docs (`skill-card-spec.md`, `routing-only-template.md`)
3. ☐ Update skill-creator init script (`init_skill.py`) to generate the new pattern
4. ☐ Update skill-creator validate script (`validate_skill_cards.py`) to enforce the new pattern

### Content

The new description pattern:

```
<noun phrase describing what the skill is>. Dispatch when <agent-facing trigger conditions>. Also dispatch when <additional trigger conditions>. <Any additional context or requirements>. User phrases: <preserved user-facing trigger phrases>
```

**Example transformation:**

BEFORE (git-workflow):
> "Use when creating a branch, committing, pushing, or creating a PR. Also use when handling rebase/merge conflicts (invoke conflict-resolution), checking PR state and cleanup, or running provenance tracking. Invoke for: branch creation, commit, push, PR creation, rebase, merge, conflict resolution dispatch, PR state verification, cleanup, provenance tracking, submodule sync. Branch-and-PR discipline is REQUIRED — always follow the workflow. Trigger phrases: create branch, commit, push, create PR, rebase, merge, check pr, check prs, check merged prs, pr merged, provenance, sync submodules, release PR."

AFTER (git-workflow):
> "Branch, commit, push, and PR lifecycle management. Dispatch when the agent needs to create a feature branch, commit changes, push to remote, create a pull request, handle rebase or merge operations, verify PR state, clean up merged branches, sync submodules, or track provenance. Also dispatch when a PR has been merged and cleanup is needed. Branch-and-PR discipline is REQUIRED — always follow the workflow. User phrases: create branch, commit, push, create PR, rebase, merge, check pr, check prs, check merged prs, pr merged, provenance, sync submodules, release PR."

**Validation rules (for validate_skill_cards.py):**
- Description MUST NOT start with "Use when" (old pattern)
- Description MUST start with an agent-intent statement (a noun phrase describing what the skill is)
- Description MUST contain "Dispatch when" (the agent-facing trigger)
- Description MUST contain "User phrases:" (the supplementary user-facing triggers)
- Description MUST NOT contain "Invoke for:" (old pattern)
- Description MUST NOT contain "Trigger phrases:" (old pattern)
- Description MUST NOT contain "Also use when" (old pattern — must be replaced with "Also dispatch when" or equivalent agent-facing language)

---

## Phase 2: Rewrite All 43 SKILL.md Descriptions

### Steps
1. ☐ Rewrite descriptions for pipeline/process skills (approval-gate, audit, brainstorming, changelog-generator, completeness-gate, completion-core, conflict-resolution, engineering-approach, executing-plans, finishing-a-development-branch, implementation-pipeline, pre-analysis, verification, verification-before-completion, verification-enforcement)
2. ☐ Rewrite descriptions for git/PR skills (git-workflow, pr-creation-workflow, receiving-code-review, requesting-code-review, using-git-worktrees)
3. ☐ Rewrite descriptions for content/planning skills (correspondence, plan, plan-creation-pipeline, spec-creation, writing-plans, sre-runbook)
4. ☐ Rewrite descriptions for tool/utility skills (issue-operations, issue-review, mcp-tool-usage, multimodal-dispatch, playwright-cli, programming-principles, research, skill-creator, solve, sync-guidelines, systematic-debugging, test-driven-development, version-manager)
5. ☐ Rewrite descriptions for platform sub-skills (local, github-mcp, gitbucket-api)
6. ☐ Rewrite descriptions for release/ops skills (release-promoter)

### Content
Each file rewrite follows the pattern defined in Phase 1. The "User phrases:" section preserves the current trigger phrases for backward compatibility.

---

## Phase 3: Behavioral Enforcement Tests

### Steps
1. ☐ Write behavioral test: agent dispatches git-workflow when it decides to create a PR (not when user says "create PR")
2. ☐ Write behavioral test: agent dispatches spec-creation when it decides to write a spec (not when user says "write spec")
3. ☐ Write behavioral test: agent dispatches verification-before-completion when it decides to verify (not when user says "verify")
4. ☐ Write behavioral test: validate_skill_cards.py rejects old pattern descriptions
5. ☐ Write behavioral test: validate_skill_cards.py accepts new pattern descriptions

### Content
Behavioral tests use `opencode-cli run` with prompts that test agent intent-based routing, not user-phrase matching. The tests verify that the agent dispatches the correct skill based on what it has decided to do, not based on user wording.

---

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | New description pattern is defined and documented in skill-creator reference docs | `string` | grep for pattern definition in skill-card-spec.md and routing-only-template.md |
| SC-2 | validate_skill_cards.py rejects descriptions starting with "Use when" | `behavioral` | opencode-cli run with old-pattern SKILL.md → FAIL |
| SC-3 | validate_skill_cards.py accepts descriptions matching the new pattern | `behavioral` | opencode-cli run with new-pattern SKILL.md → PASS |
| SC-4 | init_skill.py generates descriptions using the new pattern | `string` | grep init_skill.py output for "Dispatch when" |
| SC-5 | All 43 SKILL.md descriptions follow the new pattern (excludes non-skill-card directories under skills/ such as reference/) | `string` | grep all SKILL.md files — zero "Use when" at start, zero "Invoke for:", zero "Trigger phrases:", zero "Also use when" |
| SC-6 | All 43 SKILL.md descriptions contain "User phrases:" with preserved trigger phrases (excludes non-skill-card directories under skills/) | `string` | grep all SKILL.md files for "User phrases:" |
| SC-7 | Agent dispatches git-workflow when it decides to create a PR (intent-based) | `behavioral` | opencode-cli run → stderr shows skill("git-workflow") |
| SC-8 | Agent dispatches spec-creation when it decides to write a spec (intent-based) | `behavioral` | opencode-cli run → stderr shows skill("spec-creation") |
| SC-9 | Agent dispatches verification-before-completion when it decides to verify (intent-based) | `behavioral` | opencode-cli run → stderr shows skill("verification-before-completion") |
| SC-10 | validate_skill_cards.py passes on all 43 rewritten files | `behavioral` | uv run validate_skill_cards.py → exit 0 |
| SC-11 | All rewritten descriptions are ≤ 1024 characters (opencode limit) | `structural` | Extract description field from YAML frontmatter of each SKILL.md, then wc -c on the extracted value |
| SC-12 | No existing behavioral tests break due to description changes | `behavioral` | Full behavioral test suite passes |

---

## Change Control

| Revision | Date | Author | Change |
|----------|------|--------|--------|
| 1.0 | 2026-07-11 | OpenCode | Initial spec |
| 1.1 | 2026-07-11 | OpenCode | Fixed pattern template to noun-phrase-first; added release-promoter to Phase 2 Step 6; clarified SC-11 verification method; added exclusion note for reference/ directories in SC-5/SC-6 |
| 1.2 | 2026-07-11 | OpenCode | Added validation rule: "Also use when" MUST NOT appear (must be replaced with "Also dispatch when"); added "Also use when" to SC-5 grep pattern |

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
