> **Full spec and artifacts: [`#2166`](https://github.com/michael-conrad/.opencode/issues/2166)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2166/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Objective

Remove dead stderr/stdout-grep assertion helpers from `helpers.sh` and convert the 2 remaining legacy scripts to artifact-only generators, completing the migration to SQLite-based behavioral test evaluation.

## Background

Prior specs (#2011, #842, #835, #836, #860, #861, #911) established the **artifact-only generator paradigm**: behavioral test scripts call `behavior_run` and exit 0 — they do NOT evaluate output. Evaluation is the orchestrator's job via clean-room sub-agents reading `session.yaml` (SQLite DB export).

The `session.yaml` (exported from the `part` and `event` tables of opencode's SQLite DB) is the PRIMARY evidence source. It contains structured tool call data with tool name, callID, status, input, output, and millisecond timestamps — making it reliable and deterministic for behavioral analysis.

However, two categories of dead/legacy code remain:

1. **Dead assertion helpers in `helpers.sh`** — 9 functions (`assert_tool_calls_made`, `assert_skill_called`, `assert_no_skill_called`, `assert_stderr_pattern_present`, `assert_stderr_pattern_absent`, `assert_stderr_pattern_present_all_models`, `assert_stderr_pattern_absent_all_models`, `assert_forbidden_pattern_absent`, `assert_required_pattern_present`) that grep stderr/stdout for tool call patterns. These are defined but only called by the 2 legacy scripts being converted (items 2 and 3 below). Outside those scripts, they have zero callers. They are dead code.

2. **2 legacy scripts** (`verify-auth-step5d.sh`, `2146-session-timestamp.sh`) that still use `assert_semantic` inline and exit with `OVERALL_RESULT` — violating the artifact-only paradigm.

3. **`assert_semantic`** — the only remaining active assertion helper. It sends `stdout.log` + `stderr.log` to a clean-room inspector. It should also (or instead) send `session.yaml` and `timeline.yaml` so the inspector has structured data.

## Not Included

- Changes to `assert_stderr_pattern_present` / `assert_stderr_pattern_absent` for non-behavioral (string/structural) SCs — these are for content-verification tests, not behavioral. Note: SC-4 and SC-5 remove these functions entirely from `helpers.sh` because they are dead code (zero callers outside the 2 legacy scripts being converted). If a future need arises for stderr-pattern helpers, they can be re-added.
- Changes to the SQLite schema or `__export_sqlite_to_yaml` internals
- Changes to `session-to-timeline` tool (it already processes `session.yaml` correctly)
- Re-architecting the evaluation pipeline — only cleanup of dead/legacy code

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `assert_tool_calls_made` function is removed from `helpers.sh` | `string` | Grep for function definition — must not exist |
| SC-2 | `assert_skill_called` function is removed from `helpers.sh` | `string` | Grep for function definition — must not exist |
| SC-3 | `assert_no_skill_called` function is removed from `helpers.sh` | `string` | Grep for function definition — must not exist |
| SC-4 | `assert_stderr_pattern_present` function is removed from `helpers.sh` | `string` | Grep for function definition — must not exist |
| SC-5 | `assert_stderr_pattern_absent` function is removed from `helpers.sh` | `string` | Grep for function definition — must not exist |
| SC-6 | `assert_stderr_pattern_present_all_models` function is removed from `helpers.sh` | `string` | Grep for function definition — must not exist |
| SC-7 | `assert_stderr_pattern_absent_all_models` function is removed from `helpers.sh` | `string` | Grep for function definition — must not exist |
| SC-8 | `assert_forbidden_pattern_absent` function is removed from `helpers.sh` | `string` | Grep for function definition — must not exist |
| SC-9 | `assert_required_pattern_present` function is removed from `helpers.sh` | `string` | Grep for function definition — must not exist |
| SC-10 | `verify-auth-step5d.sh` is converted to artifact-only generator: calls `behavior_run`, exits 0, no `assert_semantic`, no `OVERALL_RESULT`, no `exit $OVERALL_RESULT` | `behavioral` | Run the script — verify it produces artifacts and exits 0 without evaluating |
| SC-11 | `2146-session-timestamp.sh` is converted to artifact-only generator: calls `behavior_run`, exits 0, no `assert_semantic`, no `OVERALL_RESULT`, no `exit $OVERALL_RESULT` | `behavioral` | Run the script — verify it produces artifacts and exits 0 without evaluating |
| SC-12 | `assert_semantic` in `helpers.sh` sends `session.yaml` and `timeline.yaml` to the clean-room inspector alongside `stdout.log`/`stderr.log` — the inspector prompt includes the full `session.yaml` content (all tool call records with tool name, callID, status, input, output, timestamps) and the `timeline.yaml` summary. The structured data is appended to the inspector prompt after the raw stdout/stderr, not replacing it. | `behavioral` | Behavioral test that verifies inspector prompt contains structured data from session.yaml |
| SC-13 | All existing behavioral test scripts continue to pass unchanged after dead code removal | `string` | Run `test-enforcement.sh --tag behavioral` — all pass |
| SC-14 | `__export_sqlite_to_yaml` is confirmed to export the `event` table (check current behavior; add if missing) | `string` | Grep `__export_sqlite_to_yaml` for `event` table query — confirm it queries `sqlite_master` for all tables |

## Requirements

1. The system SHALL remove the `assert_tool_calls_made` function definition from `helpers.sh`.
2. The system SHALL remove the `assert_skill_called` function definition from `helpers.sh`.
3. The system SHALL remove the `assert_no_skill_called` function definition from `helpers.sh`.
4. The system SHALL remove the `assert_stderr_pattern_present` function definition from `helpers.sh`.
5. The system SHALL remove the `assert_stderr_pattern_absent` function definition from `helpers.sh`.
6. The system SHALL remove the `assert_stderr_pattern_present_all_models` function definition from `helpers.sh`.
7. The system SHALL remove the `assert_stderr_pattern_absent_all_models` function definition from `helpers.sh`.
8. The system SHALL remove the `assert_forbidden_pattern_absent` function definition from `helpers.sh`.
9. The system SHALL remove the `assert_required_pattern_present` function definition from `helpers.sh`.
10. The system SHALL convert `verify-auth-step5d.sh` to an artifact-only generator: call `behavior_run`, exit 0, remove all `assert_semantic` calls, `OVERALL_RESULT`, and `exit $OVERALL_RESULT`.
11. The system SHALL convert `2146-session-timestamp.sh` to an artifact-only generator: call `behavior_run`, exit 0, remove all `assert_semantic` calls, `OVERALL_RESULT`, and `exit $OVERALL_RESULT`.
12. The system SHALL update `assert_semantic` to pass `session.yaml` and `timeline.yaml` to the clean-room inspector alongside `stdout.log` and `stderr.log`.
13. The system SHALL verify that `__export_sqlite_to_yaml` exports the `event` table (adding it if missing).
14. The system SHALL maintain backward compatibility: all existing behavioral tests SHALL continue to pass after these changes.

## Items

| # | SC | Description |
|---|----|-------------|
| 1 | SC-1 | Remove `assert_tool_calls_made` |
| 2 | SC-2 | Remove `assert_skill_called` |
| 3 | SC-3 | Remove `assert_no_skill_called` |
| 4 | SC-4 | Remove `assert_stderr_pattern_present` |
| 5 | SC-5 | Remove `assert_stderr_pattern_absent` |
| 6 | SC-6 | Remove `assert_stderr_pattern_present_all_models` |
| 7 | SC-7 | Remove `assert_stderr_pattern_absent_all_models` |
| 8 | SC-8 | Remove `assert_forbidden_pattern_absent` |
| 9 | SC-9 | Remove `assert_required_pattern_present` |
| 10 | SC-10 | Convert `verify-auth-step5d.sh` to artifact-only |
| 11 | SC-11 | Convert `2146-session-timestamp.sh` to artifact-only |
| 12 | SC-12 | Update `assert_semantic` to include structured data |
| 13 | SC-13 | Verify backward compatibility |
| 14 | SC-14 | Verify/ensure `event` table export |

## Dependencies

- Pre-spec inspection (completed) — confirmed all assertion helpers are dead code (zero callers outside 2 legacy scripts), 2 legacy scripts remain, session.yaml is already exported
- Research card consultation (completed) — no relevant research cards found
- Analytical artifacts — not generated for this spec. This is a cleanup-only spec (dead code removal + script conversion) with no behavioral changes to the testing pipeline. The 7 analytical artifacts (blast radius, concern map, code path inventory, cross-cutting matrix, interface compatibility, state analysis, testability assessment) are not applicable to a pure deletion-and-conversion spec.

## Traceability

| Requirement | SCs | Phase |
|-------------|-----|-------|
| R1–R9 (remove dead helpers) | SC-1–SC-9 | Phase 1 |
| R10 (convert verify-auth-step5d) | SC-10 | Phase 2 |
| R11 (convert 2146-session-timestamp) | SC-11 | Phase 2 |
| R12 (assert_semantic structured data) | SC-12 | Phase 3 |
| R13 (event table export) | SC-14 | Phase 3 |
| R14 (backward compatibility) | SC-13 | Phase 4 |
