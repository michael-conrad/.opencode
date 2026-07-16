---
title: '[SPEC-FIX] Gate per-turn git config watchdog to first-turn-only'
status: draft
created: 2026-07-16
license: MIT
provenance: AI-generated
issue: 1968
authors:
  - OpenCode (ollama-cloud/deepseek-v4-flash)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-16

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem

The per-turn git config mutation watchdog in `session-enforcement.ts` (lines 973–1005) runs `git config --local --list`, `git rev-parse --git-dir`, and `git remote -v` on every single interactive message turn. This is 3–4 git subprocess invocations per turn, for the entire session lifetime.

The watchdog sits outside the `if (shouldInjectFirstTurn)` guard (line 888), so it fires unconditionally on every `messages.transform` invocation.

## Root Cause

The watchdog block at line 973 is positioned after the `if (shouldInjectFirstTurn)` block closes at line 934. It was intended to detect config mutations the agent makes during the session, but the implementation runs git commands every turn instead of only on the first turn.

## Goals

- Eliminate unnecessary git subprocess calls on every message turn
- Preserve watchdog functionality for the first turn
- Preserve baseline capture at plugin startup

## Non-Goals

- Removing the watchdog entirely — it still fires on the first turn
- Changing how the baseline is captured at startup

## Fix

Gate the entire watchdog block behind `isFirstTurn`:

```typescript
// --- Per-turn: Git config mutation watchdog ---
// Gated to first-turn-only: baseline captured at startup, comparison runs once.
if (isFirstTurn && gitConfigBaseline) {
  // ... existing watchdog code ...
}
```

## Affected File

`plugins/session-enforcement.ts` — lines 973–1005

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. Read [Test Integrity Mandate](guidelines/080-code-standards.md).

## Interdependency

| Issue | Classification | Description |
|-------|---------------|-------------|
| [#1968](https://github.com/michael-conrad/.opencode/issues/1968) | SELF | This spec |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|---------------|---------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | `git config --local --list` is called 0 times on the 2nd+ message turn | `behavioral` | `opencode run` → stderr assertion: no `git config` execSync on subsequent turns | Gate the watchdog behind `isFirstTurn`; re-run behavioral test | pre-commit | `plugins/session-enforcement.ts` | Root cause: watchdog outside first-turn guard | Phase 1 | pre-commit | standalone | — | — | `behaviors/watchdog-first-turn.sh` | Phase 1 |
| SC-2 | `git rev-parse --git-dir` is called 0 times on the 2nd+ message turn | `behavioral` | `opencode run` → stderr assertion | Same as SC-1 | pre-commit | `plugins/session-enforcement.ts` | Root cause: watchdog outside first-turn guard | Phase 1 | pre-commit | standalone | — | — | `behaviors/watchdog-first-turn.sh` | Phase 1 |
| SC-3 | `git remote -v` is called 0 times on the 2nd+ message turn | `behavioral` | `opencode run` → stderr assertion | Same as SC-1 | pre-commit | `plugins/session-enforcement.ts` | Root cause: watchdog outside first-turn guard | Phase 1 | pre-commit | standalone | — | — | `behaviors/watchdog-first-turn.sh` | Phase 1 |
| SC-4 | Git config baseline is still captured at plugin startup (line 753) | `string` | grep for `captureGitConfigBaseline` call at line 753 | Verify baseline capture code is unchanged | pre-commit | `plugins/session-enforcement.ts` | Non-goal: preserve startup behavior | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-5 | Watchdog still fires on first turn if config was mutated between startup and first message | `behavioral` | `opencode run` → stderr assertion: watchdog block present on first turn | Verify `isFirstTurn` is true on first message | pre-commit | `plugins/session-enforcement.ts` | Goal: preserve watchdog on first turn | Phase 1 | pre-commit | standalone | — | — | `behaviors/watchdog-first-turn.sh` | Phase 1 |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Risk and Edge Cases

| Risk | Likelihood | Impact | Mitigation | Verifying SC |
|------|-----------|--------|------------|-------------|
| Watchdog never fires (isFirstTurn check wrong) | Low | High | Behavioral test SC-5 verifies first-turn firing | SC-5 |
| Baseline capture broken by refactor | Low | High | String test SC-4 verifies baseline call at line 753 | SC-4 |

## Implementation Approach

1. Wrap the watchdog block (lines 973–1005) in `if (isFirstTurn && gitConfigBaseline) { ... }`
2. Write behavioral enforcement test in `.opencode/tests-v2/behaviors/watchdog-first-turn.sh`
3. Verify SC-4 (baseline capture unchanged) via grep
4. Run behavioral test to confirm RED (test fails before change), then GREEN

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `plugins/session-enforcement.ts` via `github_get_file_contents` | Verify watchdog position relative to `shouldInjectFirstTurn` guard |
| MCP search | `github_issue_read` on #1968 | Verify existing raw issue content |

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
