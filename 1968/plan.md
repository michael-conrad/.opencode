---
title: '[PLAN] Gate per-turn git config watchdog to first-turn-only'
status: draft
created: 2026-07-16
license: MIT
provenance: AI-generated
issue: 1968
---

**STATUS:** DRAFT
**CREATED:** 2026-07-16

## Phase Table

| Phase | Description | Depends On | Steps |
|-------|-------------|------------|-------|
| 1 | Gate watchdog behind `isFirstTurn` | None | 1.1, 1.2, 1.3, 1.4, 1.5 |

## Phase 1 — Gate watchdog behind `isFirstTurn`

### SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | `git config --local --list` called 0 times on 2nd+ turn | 1 | 1.2 |
| SC-2 | `git rev-parse --git-dir` called 0 times on 2nd+ turn | 1 | 1.2 |
| SC-3 | `git remote -v` called 0 times on 2nd+ turn | 1 | 1.2 |
| SC-4 | Baseline capture at startup (line 753) unchanged | 1 | 1.1 |
| SC-5 | Watchdog still fires on first turn if config mutated | 1 | 1.2, 1.4 |

### Steps

#### Step 1.1 — Verify baseline capture code is unchanged

- **Action:** Read `plugins/session-enforcement.ts` line 753 to confirm `captureGitConfigBaseline` call is present and unchanged
- **SC:** SC-4
- **Evidence:** `grep` for `captureGitConfigBaseline` at line 753
- **Verification:** String assertion: `captureGitConfigBaseline` call exists at line 753

#### Step 1.2 — Gate watchdog block behind `isFirstTurn`

- **Action:** Wrap the watchdog block (lines 1085–1117) in `if (isFirstTurn && gitConfigBaseline) { ... }`
- **File:** `plugins/session-enforcement.ts`
- **SC:** SC-1, SC-2, SC-3, SC-5
- **Change:** Add `if (isFirstTurn && gitConfigBaseline) {` before line 1085 and `}` after line 1117
- **Evidence:** `diff` showing the wrapping

#### Step 1.3 — Write behavioral enforcement test

- **Action:** Create `.opencode/tests-v2/behaviors/watchdog-first-turn.sh` that:
  1. Sends two sequential messages to opencode
  2. Asserts stderr contains `git config` on first turn
  3. Asserts stderr does NOT contain `git config` on second turn
- **SC:** SC-1, SC-2, SC-3, SC-5
- **Evidence:** Test file exists and is executable

#### Step 1.4 — Run RED/GREEN cycle

- **Action:** 
  1. Run behavioral test BEFORE code change → expect FAIL (RED)
  2. Apply code change from Step 1.2
  3. Run behavioral test AFTER code change → expect PASS (GREEN)
- **SC:** SC-1, SC-2, SC-3, SC-5
- **Evidence:** Test output logs

#### Step 1.5 — Verify SC-4 (baseline unchanged)

- **Action:** Run `grep` for `captureGitConfigBaseline` at line 753 to confirm no changes to baseline capture
- **SC:** SC-4
- **Evidence:** grep output

### Safety/Rollback

**Phase 1 — Safety/Rollback:**
- Destructive operations: None (wrapping existing code in a conditional, no data mutation)
- Rollback plan: `git checkout -- plugins/session-enforcement.ts` to revert the change
- Data loss risk: None

### Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1.1 | `plugins/session-enforcement.ts:753` | ✅ | `read` confirmed `captureGitConfigBaseline` at line 753 |
| 1.2 | `plugins/session-enforcement.ts:1085-1117` | ✅ | `read` confirmed watchdog block at lines 1085-1117 |
| 1.2 | `isFirstTurn` variable at line 974 | ✅ | `read` confirmed `isFirstTurn` defined at line 974 |
| 1.2 | `gitConfigBaseline` variable | ✅ | `read` confirmed `gitConfigBaseline` used in existing guard at line 1086 |

### Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| Watchdog block at lines 1085-1117 | `read` of `plugins/session-enforcement.ts` | ✅ |
| `isFirstTurn` defined at line 974 | `read` of `plugins/session-enforcement.ts` | ✅ |
| `shouldInjectFirstTurn` guard closes at line 1046 | `read` of `plugins/session-enforcement.ts` | ✅ |
| `gitConfigBaseline` used in existing guard at line 1086 | `read` of `plugins/session-enforcement.ts` | ✅ |

### Exit Criteria

- [ ] SC-1: Behavioral test passes — no `git config` on 2nd+ turn
- [ ] SC-2: Behavioral test passes — no `git rev-parse` on 2nd+ turn
- [ ] SC-3: Behavioral test passes — no `git remote -v` on 2nd+ turn
- [ ] SC-4: String assertion passes — `captureGitConfigBaseline` at line 753 unchanged
- [ ] SC-5: Behavioral test passes — watchdog fires on first turn

### VbC Section

For behavioral SCs (SC-1, SC-2, SC-3, SC-5):
1. Run `behavior_run` with the behavioral test scenario
2. Dispatch `behavioral-test-evaluation` clean-room sub-agent to evaluate artifacts
3. Only on clean-room PASS verdict: mark SC as verified

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
