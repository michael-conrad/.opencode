## Task

Fix the completion-core SKILL.md — update its description to accurately map to its actual dispatch triggers.

### Required Change

| Field | Current | Proposed |
|-------|---------|----------|
| description | "Use when completing skill task workflows with push, URL generation, lifecycle event append, and executive summary reporting. Completion signals MUST be clear and structured — always required." | "Use when signaling workflow completion after a sub-agent returns: pushing branches, generating URLs, or appending lifecycle events. Dispatch via skill() + task() — REQUIRED for all audit completions." |

### Defects Being Fixed

- **D2**: Current description doesn't map to actual dispatch triggers in TDT (resolve-models, verification-audit, spec-audit, etc.)
- **D3**: Doesn't cover all dispatch conditions from its TDT
- **Borderline D4**: "MUST be clear and structured" is about output quality, not a dispatch requirement

### Verification

After change:
- Description accurately maps to the skill's actual dispatch triggers (resolve-models, verification-audit, spec-audit, cross-validate, completion)
- Contains mandatory dispatch language (REQUIRED/always/not optional)
- No narrative-only sentences