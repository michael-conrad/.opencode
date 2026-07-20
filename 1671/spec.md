## Problem

Three skill cards in the opencode-config skill deck have defective or incomplete DISPATCH_GATE subsections, causing orchestrators to receive insufficient routing protocol guidance. This leads to incorrect context preloading, sub-agent re-dispatches, and broken work. Two canonical templates also lack DISPATCH_GATE documentation, propagating the defect to future skills. The validation script has no check for DISPATCH_GATE completeness.

## Affected Files

| File | Defect |
|------|--------|
| `.opencode/skills/adversarial-audit/SKILL.md` | Prose-only DISPATCH GATE block (line 76), no structured subsections |
| `.opencode/skills/playwright-cli/SKILL.md` | Prose-only DISPATCH GATE block (line 450), no structured subsections |
| `.opencode/skills/solve/SKILL.md` | Has DISPATCH_GATE heading + Orchestrator Entry Criteria, missing Dispatch Context Contract and Sub-Agent Entry Criteria |
| `.opencode/skills/skill-creator/reference/routing-only-template.md` | No DISPATCH_GATE section in template |
| `.opencode/skills/skill-creator/reference/skill-card-spec.md` | No DISPATCH_GATE structure mentioned |
| `.opencode/skills/skill-creator/scripts/validate_skill_cards.py` | No check for DISPATCH_GATE completeness |

## Canonical DISPATCH_GATE Structure

From 33 working skills (e.g., `approval-gate/SKILL.md`, `spec-creation/SKILL.md`), the canonical structure has these subsections:

1. **Context cost frame disclaimer** — blockquote noting these are operational bookkeeping notes, not implementation complexity measures
2. **Core rule** — orchestrator MUST NOT preload execution context into `task()` prompts; sub-agents independently discover scope
3. **`#### Forbidden in task() Prompts`** — table with Violation, Forbidden Pattern, Correct Pattern columns
4. **`## Required: Sub-agent Task File Discovery Directive`** — format: `execute <task> from <skill>. Read \`<skill>/tasks/<task>.md\` first`
5. **`#### Dispatch Context Contract`** — allowed fields + exclusions table
6. **`#### Sub-Agent Entry Criteria`** — what sub-agent MUST reject + `PRELOADED_CONTEXT_REJECTED` protocol
7. **`#### Orchestrator Entry Criteria`** — canonical dispatch string mandate

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `adversarial-audit/SKILL.md` prose-only DISPATCH GATE block (line 76) is replaced with full structured DISPATCH_GATE section containing all 7 subsections | `string` | grep for `#### Forbidden in task() Prompts`, `#### Dispatch Context Contract`, `#### Sub-Agent Entry Criteria`, `#### Orchestrator Entry Criteria` in file |
| SC-2 | `playwright-cli/SKILL.md` prose-only DISPATCH GATE block (line 450) is replaced with full structured DISPATCH_GATE section containing all 7 subsections; only the DISPATCH_GATE section is modified (upstream-adapted Apache-2.0 constraint) | `string` | grep for all 4 subsection headings; `git diff` shows changes only within DISPATCH_GATE section |
| SC-3 | `solve/SKILL.md` DISPATCH_GATE section gains missing `#### Dispatch Context Contract` and `#### Sub-Agent Entry Criteria` subsections; existing `#### Orchestrator Entry Criteria` is preserved unchanged | `string` | grep for `#### Dispatch Context Contract` and `#### Sub-Agent Entry Criteria` in file; existing Orchestrator Entry Criteria text unchanged |
| SC-4 | `routing-only-template.md` gains a DISPATCH_GATE section in the template body (after Invocation, before Sub-Agent Routing) with all 7 subsections | `string` | grep for `DISPATCH_GATE` in file |
| SC-5 | `skill-card-spec.md` gains a section documenting the DISPATCH_GATE structure requirements for SKILL.md cards | `string` | grep for `DISPATCH_GATE` in file |
| SC-6 | `validate_skill_cards.py` gains a new REQ check (e.g., REQ-6) that validates each SKILL.md has a complete DISPATCH_GATE section with all required subsections | `behavioral` | Run `uv run .opencode/skills/skill-creator/scripts/validate_skill_cards.py` — adversarial-audit, playwright-cli, and solve cards show DISPATCH_GATE violations before fix, pass after fix |
| SC-7 | Existing 33 working skill cards with complete DISPATCH_GATE sections are not broken by the validation change | `behavioral` | Run `uv run .opencode/skills/skill-creator/scripts/validate_skill_cards.py` — all previously-passing cards still pass |

## Constraints

- Prose-only blocks in `adversarial-audit` and `playwright-cli` must be **replaced**, not supplemented
- `solve` card must only add missing subsections, preserve existing Orchestrator Entry Criteria
- `playwright-cli` is upstream-adapted (Apache-2.0) — only modify the DISPATCH_GATE section
- Validation must use same pattern as existing REQ checks (REQ-1 through REQ-5)

## Change Control

- **Spec owner**: Agent
- **Authorization scope**: `for_pr`
- **PR strategy**: `stacked`
- **Branch**: `feature/dispatch-gate-fix`

## Cross-References

- `000-critical-rules.md` §critical-rules-dispatch-gate-canonical — Canonical dispatch string violation
- `000-critical-rules.md` §critical-rules-048 — Skill pre-read + inline execution
- `000-critical-rules.md` §critical-rules-034 — Orchestrator inline work
- `020-go-prohibitions.md` §1.1 — Orchestrator Context Discipline
- `approval-gate/SKILL.md` §DISPATCH_GATE — Canonical reference implementation
- `spec-creation/SKILL.md` §DISPATCH_GATE — Canonical reference implementation