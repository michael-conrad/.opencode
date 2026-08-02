> **Full spec and artifacts: [`.opencode/.issues/2229/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2229)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2229/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# [SPEC] Skill deck completeness validation — missing SKILL.md or task cards trigger investigation + fatal HALT

## Intent and Executive Summary

- **Problem Statement:** The skill deck under `.opencode/skills/` has no structural completeness validation. There is no automated check that every skill directory has a `SKILL.md`, that every `SKILL.md`'s Trigger Dispatch Table references resolve to existent task files, or that every skill with a `tasks/` directory has a `SKILL.md`. Missing skill cards or task cards silently degrade agent capability — the agent cannot discover or dispatch skills whose cards are missing, and there is no mechanism to detect this condition. Currently, 1 of 50 skill directories (`reference/`) lacks a `SKILL.md` (intentional — needs exception mechanism), and 3 of 50 lack `tasks/` directories (routing/orchestrator skills — likely intentional). These gaps are undocumented and unenforced.

- **Root Cause / Motivation:** The `skildeck lint` tool validates YAML frontmatter and progressive disclosure but has no structural completeness checks. The `test-enforcement.sh` framework has no scenario for skill deck completeness. There are no behavioral tests that verify the agent investigates and halts on missing skill cards. Without enforcement, a missing `SKILL.md` or task card goes undetected until an agent fails to dispatch a skill — at which point the root cause is opaque and the failure is silent.

- **Approach Chosen:** Extend `skildeck lint` with structural completeness checks (every skill dir has `SKILL.md`, TDT references resolve, every `tasks/` dir has `SKILL.md`). Add a content-verification test scenario to `test-enforcement.sh`. Add a behavioral enforcement test in `behaviors/`. Update both `AGENTS.md` files with references. Add a critical violation section to `000-critical-rules.md` that triggers investigation + fatal HALT with escalation when a missing skill card or task card is detected.

- **Alternatives Considered & Why Discarded:**
  - *Separate validation script* — discarded in favor of extending the existing `skildeck lint` tool, which is the canonical lint entry point
  - *Pre-commit hook* — discarded because structural completeness is a CI/audit concern, not a per-commit gate
  - *Runtime agent check* — discarded because the agent should not be responsible for infrastructure validation; the tooling layer should catch it first

- **Key Design Decisions:**
  - Exception mechanism: a `.skilldeck-ignore` file in directories that are intentionally not skills (e.g., `reference/`)
  - New `skildeck lint` findings use existing finding format with new category codes
  - Behavioral test follows the artifact-only generator paradigm (produces `manifest.yaml`, `session.yaml`, `stdout.log`, `stderr.log`)
  - Critical violation ID: `critical-rules-074` (next available after `critical-rules-073`)

- **User Intent / Original Prompt:** Add enforcement that missing skill cards or skill task cards trigger a full investigation with report output followed by fatal HALT with escalation.

## Not Included

- Runtime agent-side validation of skill deck completeness (tooling layer only)
- Pre-commit hook for skill deck validation
- Validation of task card content beyond file existence (no content audits)
- Validation of cross-references between skill cards (e.g., that every skill referenced in another skill's TDT exists)
- Auto-remediation of missing skill cards (detection and halt only)

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|----------|---------------|---------------------|
| SC-1 | `skildeck lint` extended with structural completeness checks: every directory under `.opencode/skills/` has a `SKILL.md` (with exception mechanism for known non-skill dirs like `reference/`), every `SKILL.md`'s Trigger Dispatch Table references resolve to existent task files, every skill with a `tasks/` directory has a `SKILL.md` | `behavioral` | `opencode run` with prompt that triggers skildeck lint on a broken skill deck; assert stderr contains structural completeness findings |
| SC-2 | Content-verification test scenario added to `test-enforcement.sh` mapping skill deck structural files to the test | `string + structural` | `grep` for new scenario in `test-enforcement.sh` + `ls` for scenario file |
| SC-3 | Behavioral enforcement test in `behaviors/` that sends a prompt triggering the missing-skill-card investigation and verifies the agent produces investigation report and fatal HALT with escalation | `behavioral` | `bash .opencode/tests-v2/behaviors/skill-deck-completeness.sh` produces artifacts; clean-room semantic inspector verifies agent behavior |
| SC-4 | `.opencode/AGENTS.md` updated with reference to the enforcement mechanism: Reference Documents table updated, Build/Lint/Test Commands table updated with new `skildeck lint --completeness` command | `string` | `grep` for new command and reference in `.opencode/AGENTS.md` |
| SC-5 | `AGENTS.md` (root) updated with reference to the enforcement mechanism in Reference Files table | `string` | `grep` for new reference in `AGENTS.md` |
| SC-6 | `000-critical-rules.md` updated with critical violation section: new `critical-rules-074` — "Missing skill card or task card triggers investigation + fatal HALT with escalation" | `string + behavioral` | `grep` for `critical-rules-074` + behavioral test verifies agent follows the rule |

## Requirements

1. `skildeck lint` SHALL include a `--completeness` flag that runs structural completeness checks on the skill deck.
2. The structural completeness check SHALL verify that every directory under `.opencode/skills/` has a `SKILL.md`, excluding directories listed in a `.skilldeck-ignore` file.
3. The structural completeness check SHALL verify that every `SKILL.md`'s Trigger Dispatch Table references resolve to existent task files under `tasks/`.
4. The structural completeness check SHALL verify that every skill with a `tasks/` directory has a `SKILL.md`.
5. The exception mechanism SHALL use a `.skilldeck-ignore` file placed in directories that are intentionally not skills (e.g., `reference/`).
6. `test-enforcement.sh` SHALL have a `skill-deck-completeness` scenario that maps skill deck structural files to the content-verification test.
7. A behavioral enforcement test SHALL exist at `.opencode/tests-v2/behaviors/skill-deck-completeness.sh` following the artifact-only generator paradigm.
8. `.opencode/AGENTS.md` SHALL be updated with a new row in the Reference Documents table and a new row in the Build/Lint/Test Commands table.
9. `AGENTS.md` (root) SHALL be updated with a new row in the Reference Files table.
10. `000-critical-rules.md` SHALL contain a new `critical-rules-074` section: "Missing skill card or task card triggers investigation + fatal HALT with escalation".

## Items

1. Extend `skildeck lint` with `--completeness` flag and structural checks (SC-1)
2. Add content-verification test scenario to `test-enforcement.sh` (SC-2)
3. Create behavioral enforcement test in `behaviors/` (SC-3)
4. Update `.opencode/AGENTS.md` (SC-4)
5. Update root `AGENTS.md` (SC-5)
6. Add critical violation section to `000-critical-rules.md` (SC-6)

## Dependencies

- Existing `skildeck lint` tool at `.opencode/tools/impl/skildeck/skildeck-lint`
- Existing `test-enforcement.sh` at `.opencode/tests-v2/test-enforcement.sh`
- Existing behavioral test template at `.opencode/tests-v2/behaviors/`
- Existing `000-critical-rules.md` at `.opencode/guidelines/000-critical-rules.md`
- Existing `AGENTS.md` files at root and `.opencode/`

## Traceability

| Requirement | SCs | Item |
|-------------|-----|------|
| R1-R5 | SC-1 | 1 |
| R6 | SC-2 | 2 |
| R7 | SC-3 | 3 |
| R8 | SC-4 | 4 |
| R9 | SC-5 | 5 |
| R10 | SC-6 | 6 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| skildeck lint source | Code | `.opencode/tools/impl/skildeck/skildeck-lint` | Read file |
| test-enforcement.sh | Code | `.opencode/tests-v2/test-enforcement.sh` | Read file |
| behavioral test template | Code | `.opencode/tests-v2/behaviors/` | `ls` directory |
| 000-critical-rules.md | Guideline | `.opencode/guidelines/000-critical-rules.md` | Read file |
| .opencode/AGENTS.md | Documentation | `.opencode/AGENTS.md` | Read file |
| AGENTS.md (root) | Documentation | `AGENTS.md` | Read file |

## Enforcement Gate

ALL success criteria MUST pass before this spec is considered complete. No partial delivery.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Extending skildeck lint with structural checks costs one Python function addition. Skipping means a missing SKILL.md goes undetected until an agent silently fails to dispatch — the defect-discovery-latency is unbounded.
- SC-2: Adding a content-verification test scenario costs one bash dict entry. Skipping means the structural checks have no CI gate — they exist but are never run.
- SC-3: Creating a behavioral test costs one shell script following the established template. Skipping means the agent's response to missing skill cards is never verified — the critical violation exists in text but not in behavior.
- SC-4: Updating `.opencode/AGENTS.md` costs one table edit. Skipping means developers don't know the command exists.
- SC-5: Updating root `AGENTS.md` costs one table edit. Skipping means the reference table is incomplete.
- SC-6: Adding a critical violation section costs one text block. Skipping means the enforcement has no behavioral anchor — the agent has no rule to follow.

## Edge Cases

- **Non-skill directories under `.opencode/skills/`:** The `reference/` directory is intentionally not a skill. The `.skilldeck-ignore` exception mechanism handles this. If new non-skill directories are added, they must be added to `.skilldeck-ignore`.
- **Routing/orchestrator skills without `tasks/`:** Three skills (approval-gate, git-workflow, issue-operations) lack `tasks/` directories — this is intentional for routing/orchestrator skills. The completeness check must not flag these as errors.
- **Empty skill directories:** A skill directory with neither `SKILL.md` nor `tasks/` is a structural error — flagged by the check.
- **TDT references to non-existent task files:** A `SKILL.md` whose Trigger Dispatch Table references a task file that does not exist under `tasks/` is a structural error — flagged by the check.
- **`--completeness` flag not provided:** Without `--completeness`, skildeck lint behaves exactly as before — no structural checks run. This preserves backward compatibility.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
