## Summary

The writing-plans pipeline (`writing-plans/tasks/write.md` → `create.md`) generated a plan at `.issues/25/plan.md` that violates 10 of the 14 Plan Format Requirements specified in `write.md` lines 52-167. The defect was not caught by any of the 4 downstream validation/audit gates (validate.md, plan-fidelity audit, concern-separation audit, write output contract).

## Root Cause

A **three-layer gap** in the pipeline:

### Layer 1: validate.md has zero format-compliance checks
The validate task (`writing-plans/tasks/validate.md`) runs 18 checks, but **none** verify compliance with the Plan Format Requirements from write.md. It checks placeholders, TDD structure, pipeline gate coverage, dispatch semantics — but never checks title format, Goal/Architecture presence, admonishment separateness/position, per-phase Files metadata, dispatch indicator bold formatting, line-number prohibition, Phase VbC blocks, concern transitions, or section ordering.

### Layer 2: Write output contract is self-reported and incomplete
The `write-output-template.yaml` contract (11 fields) is filled in by the write sub-agent itself — no independent verifier — and its fields don't cover format compliance. The `admonishment_present: bool` field cannot distinguish "3 separate admonishments at correct positions" from "1 combined blockquote at wrong position."

### Layer 3: Plan-fidelity audit uses a format-free baseline
Clean-room plans (`clean-room.md` line 75: "Agent-chosen prose (no template)") have no template structure. Comparing a format-compliant plan against a format-free plan cannot validate format compliance. The PF-DISPATCH-MODE criterion should have caught dispatch indicator formatting (`(**sub-agent**)` vs `(sub-agent)`) but the auditor did not enforce it.

## Violations Traceability

| # | Violation | Introduced At | Gate That Should Catch | Why Missed |
|---|-----------|--------------|------------------------|------------|
| 1 | Title wrong format | Write (step 10) | Validate (step 15) | No check exists |
| 2 | Missing Goal/Architecture/Files | Write (step 10) | Validate (step 15) | Check 6 only checks Files section, not Goal/Architecture |
| 3 | Admonishments combined into one blockquote | Write (step 10) | Validate (step 15) | Check 17 uses grep — cannot detect combined vs separate |
| 4 | Missing **Files:** per phase | Write (step 10) | Validate (step 15) | No per-phase metadata check exists |
| 5 | Wrong dispatch indicators `(sub-agent)` not `(**sub-agent**)` | Write (step 10) | Plan-fidelity (step 17) | PF-DISPATCH-MODE criterion exists but auditor didn't enforce |
| 6 | Line number references (prohibited) | Write (step 10) | Validate (step 15) | No stable-anchor-only check exists |
| 7 | Missing Phase VbC blocks | Write (step 10) | Validate (step 15) | No completion-block check exists |
| 8 | Missing concern transitions | Write (step 10) | Validate (step 15) | No transition check exists |
| 9 | Missing bottom compliance admonishment | Write (step 10) | Plan-fidelity (step 17) | PF-ADMONISHMENT — clean-room is format-free; semantic comparison drifts |
| 10 | Exit Criteria before bottom admonishments (wrong order) | Write (step 10) | Validate (step 15) | No section-ordering check exists |

## Evidence

The non-compliant plan was at `.issues/25/plan.md` in the SEC-Filings-Scraper repo. The Plan Format Requirements are in `.opencode/skills/writing-plans/tasks/write.md` lines 52-167 (14 rules numbered R1-R14).

## Suggested Fixes

| Priority | Fix | Target |
|----------|-----|--------|
| HIGH | Add 10+ format-compliance checks to validate.md covering title format, Goal/Architecture/Files presence, admonishment separateness and position, per-phase **Files:** metadata, dispatch indicator bold formatting (`(**sub-agent**)` not `(sub-agent)`), line-number prohibition, Phase VbC blocks, concern transitions, and section ordering | `writing-plans/tasks/validate.md` |
| HIGH | Make validate step independently verify format compliance rather than trusting write sub-agent's self-reported contract fields | `writing-plans/tasks/validate.md` + `create.md` steps 15-16 |
| MEDIUM | Add format-requirement fields to `write-output-template.yaml` so the contract can encode format compliance (e.g., `title_format_valid: bool`, `admonishments_separate: bool`, `per_phase_files_present: bool`, `dispatch_indicator_format_valid: bool`, `no_line_number_refs: bool`, `phase_vbc_blocks_present: bool`, `concern_transitions_present: bool`, `section_order_valid: bool`) | `writing-plans/contracts/write-output-template.yaml` |
| MEDIUM | Strengthen PF-DISPATCH-MODE in plan-fidelity.md to check dispatch indicator format (grep for `(**sub-agent**)` not `(sub-agent)`) rather than relying on clean-room comparison | `writing-plans/tasks/plan-fidelity.md` Step 3 |

🤖 OpenCode (deepseek-v4-flash-free) created