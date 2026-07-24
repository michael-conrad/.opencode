> **Migrated from michael-conrad/opencode-config#338** — this issue concerns `.opencode/` submodule content and was refiled to the correct repository.

## Problem

The agent may attempt to run `gh pr merge` to merge pull requests. This command corrupts the opencode environment and crashes the agent process. There is no safeguard in `.opencode/AGENTS.md` preventing this.

## Success Criteria

- [ ] SC-1: `.opencode/AGENTS.md` contains a CRITICAL RULE section under the Boundaries section (or similar appropriate location) stating:
  - NEVER run the command `gh pr merge`
  - If a merge is needed, stop completely and ask the user to do it
  - Executing `gh pr merge` will corrupt the environment and crash the process
- [ ] SC-2: The rule is placed in a visible, prominent location in the file (e.g., under the `🚫 NEVER:` list in the Boundaries section, or as a standalone CRITICAL RULE block)

## Evidence Type

| ID | Evidence Type |
|----|---------------|
| SC-1 | `string` |
| SC-2 | `string` |

## Approach

1. Read `.opencode/AGENTS.md` to find the appropriate insertion point
2. Add a `# CRITICAL RULE` section (or integrate into the existing `🚫 NEVER:` list in the Boundaries section) with the `gh pr merge` prohibition
3. Verify the rule is present and readable

## Affected Files

- `.opencode/AGENTS.md`

## Root Cause

The agent has access to `gh pr merge` as a CLI command and may attempt to use it when a PR needs merging. This is destructive in the opencode environment and must be explicitly prohibited in agent-facing instructions.
