# Task: revisit

## Purpose

Load the `verification-enforcement` skill and execute `--task revisit` inline, scanning for `⚠️ UNVERIFIED` markers in the plan document. Resolve if possible; escalate unresolvable claims.

## Entry Criteria

- Plan index written to `{N}/plan.md` with phase table; phase files at `{N}/plan-{NN}-*.md`
- Plan content contains potential unverified claims

## Exit Criteria

- All `⚠️ UNVERIFIED` markers resolved or escalated
- Result contract contains resolution_status (resolved/partial/escalated)
- If escalated: pipeline halts with spec-defect report

## Procedure

- [ ] 1. Load `verification-enforcement` skill: `skill({name: "verification-enforcement"})`
- [ ] 2. Execute `--task revisit` inline within this context
- [ ] 3. Scan plan document for `⚠️ UNVERIFIED` markers
- [ ] 4. For each marker: attempt to resolve with live-source verification
- [ ] 5. If all resolved: return PASS with resolution_status: resolved
- [ ] 6. If partial: return DONE_WITH_CONCERNS with resolution_status: partial
- [ ] 7. If any unresolvable: return BLOCKED with resolution_status: escalated — pipeline halts

## Context Required

- Related skills: `verification-enforcement`
- Related guidelines: `065-verification-honesty.md`
