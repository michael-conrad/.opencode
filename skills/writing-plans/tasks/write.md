# Task: write

## Purpose

Write the plan document to `.issues/{N}/plan.md`, validate dispatch table references, apply approval cascade, and sync cross-references.

## Entry Criteria

- Solve step completed with SAT and SOLVED status
- Phase structure and TDD definitions available

## Exit Criteria

- Plan document written to `.issues/{N}/plan.md`
- Dispatch table validation passed
- Approval cascade applied
- Cross-reference synced to spec issue

## Procedure

- [ ] 1. Write plan document header (Goal, Architecture, Tech Stack)
- [ ] 2. Write each phase section with Pre-RED Common, Per-Item RED+green Chains, Post-RED/green
- [ ] 3. Validate every dispatch marker skill name exists under `.opencode/skills/`
- [ ] 4. Apply approval cascade per authorization_scope
- [ ] 5. Sync cross-reference to spec issue body
- [ ] 6. Return PASS with plan file path

## Context Required

- Related tasks: `create` (21-step pipeline)
- Related skills: `issue-operations`
