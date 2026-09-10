# Implementation Plan — .opencode#2441 — Early-termination semantic monitoring

**Issue:** .opencode#2441 (spec approved 2026-09-10; stacked onto feature/2434-stacked)
**Branch:** feature/2434-stacked (single stacked PR; one commit per item)

## Items (per-SC TDD order)

### Item 1 — deck fix (OWNED BY .opencode#2117 SC-26/Item 26)
- The writing-plans create.md bare-reference repoint is owned by #2117 (SC-26), per 2026-09-10 reattribution. The fix already landed on feature/2434-stacked; #2441 depends on it, does not implement it.

### Item 2 — SC-5 + monitor three-signal reads (R-1, R-2)
- File: `.opencode/tests-v2/behaviors/helpers.sh` `__semantic_monitor()`
- Add optional `BEHAVIOR_EXPECTED_ARTIFACT` + `BEHAVIOR_GOAL_ACTIONS` reads; per-poll artifact-existence check; goal-action detection (exact tool-name match). Unset → graceful skip (no behavior change).
- RED: existing scenarios without vars unchanged (SC-5); fixtures prove skip path.

### Item 3 — GREEN/HOPELESS termination + no-blind-retry (R-3..R-7, SC-1..SC-4, SC-6, SC-7)
- Same file: GREEN fires on (artifact exists AND ≥1 declared goal action); HOPELESS on cited-evidence judgment; both reuse kill + §10.5 export + diagnosis YAML + stderr banner; `behavior_run()` exits retry loop without blind retry; terminal states exclusive.
- Behavioral verification: monitored scenario with vars set → GREEN fires; poll log + judgment YAML recorded.

### Item 4 — SC-8/SC-10 docs (§14 mandate + conduct)
- File: `.opencode/tests-v2/AGENTS.md` §14 — add early-termination subsection: three-signal polling, GREEN/HOPELESS conditions, goal-action criterion (§1.1), evidence contract (session.yaml + poll log + judgment), no-blind-retry, resumption-vs-termination callout, fixed 30s cadence + per-poll three-signal report conduct (R-11/R-12).

### Item 5 — SC-9 parent pointer
- File: parent repo `AGENTS.md` Testing Lessons Learned — one-line pointer to §14 early-termination mandate.

## Verification
- Structural: grep suites per SC-8/SC-9/SC-10/SC-11; skildeck lint unchanged findings.
- Behavioral: SC-1..SC-7 via monitored scenario runs (with-vars GREEN run; without-vars no-change run; HOPELESS diagnosis run) — executed after Items 1-5 land; the #2430 SC-2 GREEN re-run doubles as the first real monitored run of the new signals.

## Commit strategy
- One commit per item, message references .opencode#2430 / .opencode#2441 as appropriate. Push after Items 1 (unblocks re-test) and after each subsequent item (§4 cycle).
