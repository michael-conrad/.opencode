## Problem

completion-core SKILL.md description fails audit #1384 on three dimensions (D2 FAIL, D3 INCOMPLETE, D4 FAIL):

- **D2 FAIL**: Description ("completing skill task workflows with push, URL generation, lifecycle event append, and executive summary reporting") does not map to actual dispatch triggers in its Trigger Dispatch Table (resolve-models, verification-audit, spec-audit, cross-validate, completion)
- **D3 INCOMPLETE**: Does not cover all TDT conditions — it is a non-misleading subset but technically incomplete
- **D4 FAIL**: "MUST be clear and structured" addresses output quality, not dispatch requirement. No mandatory language in the description field signals that the skill itself must be dispatched via `skill()` + `task()`.

## Current vs Proposed Description

**Current:**
> Use when completing skill task workflows with push, URL generation, lifecycle event append, and executive summary reporting. Completion signals MUST be clear and structured — always required.

**Proposed:**
> Use when signaling workflow completion after a sub-agent returns: pushing branches, generating URLs, or appending lifecycle events. Dispatch via skill() + task() — REQUIRED for all audit completions.

## Required Action

Update the `description` field in `.opencode/skills/completion-core/SKILL.md` frontmatter to use the proposed text above.