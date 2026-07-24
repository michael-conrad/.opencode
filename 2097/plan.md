---
plan_schema_version: "1.0"
issue: 2097
title: "Remove all stderr/diagnostic noise from plugins and session-init"
authorization_scope: for_implementation
pr_strategy: stacked
phase_count: 3
---

# Implementation Plan — #2097 — Remove stderr/diagnostic noise from plugins and session-init

**Goal:** Remove all non-actionable diagnostic output (`console.error`, `console.warn`, `writeDiagnostic`, `print(file=sys.stderr)`) from `session-enforcement.ts`, `env-loader.ts`, and `session-init`.

**Architecture:** Three independent files, each cleaned in its own phase. No shared dependencies between phases. Each phase removes diagnostic calls and dead code paths that become unreachable after removal.

**Files:**
- `.opencode/plugins/session-enforcement.ts`
- `.opencode/plugins/env-loader.ts`
- `.opencode/tools/session-init`

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Clean session-enforcement.ts | `test-driven-development` | `green` | `.opencode/plugins/session-enforcement.ts` | SC-1, SC-2, SC-3, SC-4 | — |
| 2 — Clean env-loader.ts | `test-driven-development` | `green` | `.opencode/plugins/env-loader.ts` | SC-5, SC-6, SC-7, SC-8 | — |
| 3 — Clean session-init | `test-driven-development` | `green` | `.opencode/tools/session-init` | SC-9 | — |

---

## Phase Details

### Phase 1 — Clean session-enforcement.ts

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `.opencode/plugins/session-enforcement.ts` |
| SCs | SC-1, SC-2, SC-3, SC-4 |
| Depends On | — |

**Context:**
```yaml
file: .opencode/plugins/session-enforcement.ts
removals:
  - 5 console.error/console.warn/console.log calls
  - writeDiagnostic() function + PluginDiagnostic interface + DIAGNOSTICS_PATH constant
  - collectDiagnostics() function
  - buildDiagnosticBlock() function
  - 8 writeDiagnostic() call sites
  - Diagnostic injection block in first-turn message
sc_ids:
  - SC-1: "zero console.error/warn/log calls"
  - SC-2: "zero writeDiagnostic calls"
  - SC-3: "no collectDiagnostics or buildDiagnosticBlock functions"
  - SC-4: "no diagnostic injection block in first-turn message"
```

### Phase 2 — Clean env-loader.ts

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `.opencode/plugins/env-loader.ts` |
| SCs | SC-5, SC-6, SC-7, SC-8 |
| Depends On | — |

**Context:**
```yaml
file: .opencode/plugins/env-loader.ts
removals:
  - 2 console.error calls
  - writeDiagnostic() function + PluginDiagnostic interface + DIAGNOSTICS_PATH constant
  - 2 writeDiagnostic() call sites
  - isEnvGitignored() function
  - ENV_LOADER_SECURITY_WARNING env var injection
sc_ids:
  - SC-5: "zero console.error/warn/log calls"
  - SC-6: "zero writeDiagnostic calls"
  - SC-7: "no isEnvGitignored function"
  - SC-8: "no ENV_LOADER_SECURITY_WARNING string"
```

### Phase 3 — Clean session-init

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `.opencode/tools/session-init` |
| SCs | SC-9 |
| Depends On | — |

**Context:**
```yaml
file: .opencode/tools/session-init
removals:
  - print(file=sys.stderr) for hook install counts
  - print(file=sys.stderr) for hook failure per-repo
  - print(file=sys.stderr) for submodule context
  - print(file=sys.stderr) for srclight status
  - print(file=sys.stderr) for git timeout
  - print(file=sys.stderr) for legacy hooksPath removal
sc_ids:
  - SC-9: "zero print(file=sys.stderr) calls"
```

---

## Pre-Implementation

- [ ] 1. **Coherence gate (**clean-room**).** Verify spec #2097 is approved. **→ pre-flight**
- [ ] 2. **Baseline check (**clean-room**).** Run grep for `console.error`, `console.warn`, `console.log`, `writeDiagnostic`, `print(file=sys.stderr)` across all 3 target files to confirm current state. **→ pre-flight**

---

## Phase 1 — Clean session-enforcement.ts

**Concern:** Remove all diagnostic output and dead diagnostic infrastructure from `session-enforcement.ts`.

**Files:**
- `.opencode/plugins/session-enforcement.ts`

**SCs:** SC-1, SC-2, SC-3, SC-4

**Dependencies:** None

**Entry Conditions:**
- Coherence gate passed
- Baseline check confirmed current diagnostic calls

**Exit Conditions:**
- No `console.error`, `console.warn`, or `console.log` calls remain
- No `writeDiagnostic` function, calls, or related constants
- No `collectDiagnostics` or `buildDiagnosticBlock` functions
- No diagnostic injection block in first-turn message

---

- [ ] 3. **GREEN (**sub-agent**).** Remove all diagnostic output from `session-enforcement.ts`: delete `writeDiagnostic()`, `collectDiagnostics()`, `buildDiagnosticBlock()`, `DIAGNOSTICS_PATH`, `PluginDiagnostic` interface, all 8 `writeDiagnostic()` call sites, all 5 `console.error`/`console.warn`/`console.log` calls, and the diagnostic injection block. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 4. **GREEN doublecheck (**clean-room**).** Run grep assertions: `console\.(error|warn|log)` → 0 matches, `writeDiagnostic` → 0 matches, `collectDiagnostics` → 0 matches, `buildDiagnosticBlock` → 0 matches, `diagnostic` → only comments remain. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 5. **Checkpoint commit (**inline**).** Commit session-enforcement.ts cleanup.

#### Phase 1 VbC

- [ ] 6. **VbC (**clean-room**).** Verify all 4 SCs via grep. **→ SC-1, SC-2, SC-3, SC-4**

---

## Phase 2 — Clean env-loader.ts

**Concern:** Remove all diagnostic output and dead code from `env-loader.ts`.

**Files:**
- `.opencode/plugins/env-loader.ts`

**SCs:** SC-5, SC-6, SC-7, SC-8

**Dependencies:** None

**Entry Conditions:**
- Phase 1 complete and VbC passed

**Exit Conditions:**
- No `console.error`, `console.warn`, or `console.log` calls remain
- No `writeDiagnostic` function, calls, or related constants
- No `isEnvGitignored` function
- No `ENV_LOADER_SECURITY_WARNING` string

---

- [ ] 7. **GREEN (**sub-agent**).** Remove all diagnostic output from `env-loader.ts`: delete `writeDiagnostic()`, `PluginDiagnostic` interface, `DIAGNOSTICS_PATH`, `isEnvGitignored()`, 2 `console.error` calls, 2 `writeDiagnostic()` call sites, and `ENV_LOADER_SECURITY_WARNING` env var injection. **→ SC-5, SC-6, SC-7, SC-8**
- [ ] 8. **GREEN doublecheck (**clean-room**).** Run grep assertions: `console\.(error|warn|log)` → 0 matches, `writeDiagnostic` → 0 matches, `isEnvGitignored` → 0 matches, `ENV_LOADER_SECURITY_WARNING` → 0 matches. **→ SC-5, SC-6, SC-7, SC-8**
- [ ] 9. **Checkpoint commit (**inline**).** Commit env-loader.ts cleanup.

#### Phase 2 VbC

- [ ] 10. **VbC (**clean-room**).** Verify all 4 SCs via grep. **→ SC-5, SC-6, SC-7, SC-8**

---

## Phase 3 — Clean session-init

**Concern:** Remove all `print(file=sys.stderr)` diagnostic calls from `session-init`.

**Files:**
- `.opencode/tools/session-init`

**SCs:** SC-9

**Dependencies:** None

**Entry Conditions:**
- Phase 2 complete and VbC passed

**Exit Conditions:**
- No `print(file=sys.stderr)` calls remain

---

- [ ] 11. **GREEN (**sub-agent**).** Remove all 6 `print(file=sys.stderr)` calls from `session-init`. **→ SC-9**
- [ ] 12. **GREEN doublecheck (**clean-room**).** Run `grep 'file=sys.stderr' .opencode/tools/session-init` → 0 matches. **→ SC-9**
- [ ] 13. **Checkpoint commit (**inline**).** Commit session-init cleanup.

#### Phase 3 VbC

- [ ] 14. **VbC (**clean-room**).** Verify SC-9 via grep. **→ SC-9**

---

## Post-Implementation

- [ ] 15. **Structural checks (**sub-agent**).** Run TypeScript type check (`tsc --noEmit`) if available. **→ SC-11**
- [ ] 16. **Regression check (**sub-agent**).** Run `bash .opencode/tests-v2/test-enforcement.sh` to verify all 15 behavioral enforcement tests still PASS. **→ SC-10**
- [ ] 17. **Audit (**sub-agent**).** Dispatch verification-audit for the diagnostic removal. **→ post-flight**
- [ ] 18. **Cross-validate (**clean-room**).** Verify audit findings against evidence artifacts. **→ post-flight**
- [ ] 19. **Review prep (**sub-agent**).** Prepare PR with summary of all removals. **→ post-flight**
- [ ] 20. **Create PR (**sub-agent**).** Create pull request for the feature branch. **→ post-flight**
- [ ] 21. **Completion (**sub-agent**).** Report summary with PR URL. **→ post-flight**

---

## Exit Criteria

- [ ] C1. `session-enforcement.ts` has zero `console.error`/`console.warn`/`console.log` calls
- [ ] C2. `session-enforcement.ts` has zero `writeDiagnostic` calls
- [ ] C3. `session-enforcement.ts` has no `collectDiagnostics` or `buildDiagnosticBlock` functions
- [ ] C4. `session-enforcement.ts` has no diagnostic injection block in first-turn message
- [ ] C5. `env-loader.ts` has zero `console.error`/`console.warn`/`console.log` calls
- [ ] C6. `env-loader.ts` has zero `writeDiagnostic` calls
- [ ] C7. `env-loader.ts` has no `isEnvGitignored` function
- [ ] C8. `env-loader.ts` has no `ENV_LOADER_SECURITY_WARNING` string
- [ ] C9. `session-init` has zero `print(file=sys.stderr)` calls
- [ ] C10. All 15 behavioral enforcement tests still PASS
- [ ] C11. TypeScript compiles without errors
