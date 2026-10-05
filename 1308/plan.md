# Plan — #1308: Clean up session-enforcement.ts

## Goal

Remove four accumulated defects from `session-enforcement.ts`: replace the fragile `isFirstTurn` heuristic with a process-scoped `Set<sessionID>`, remove the ineffective inline work detector, simplify mode-switch handling to unconditional stripping, and eliminate redundant gate block injections.

## Architecture

All four changes target `.opencode/plugins/session-enforcement.ts`, the session-enforcement plugin hooking into the opencode session lifecycle. Changes are structural removals/replacements within the same plugin file — no cross-file or cross-module concerns. The plugin has a `messages.transform` handler and various injection functions that build context blocks for the first user message.

## Tech Stack

- TypeScript (opencode plugin system)
- Node.js local toolchain at `.opencode/.node/`

## File Structure

- `.opencode/plugins/session-enforcement.ts` — target file for all 4 changes and verification

---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

### Phase 1: Clean up session-enforcement.ts

**Concern:** All 4 changes target the same plugin file with no cross-architectural dependencies. Changes are independent structural modifications within a single TypeScript module.
**Files:** `.opencode/plugins/session-enforcement.ts`
**SCs covered:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9, SC-10, SC-11

#### Pre-RED Common

- [ ] 1. sc-coherence-gate (**clean-room**). Dispatch adversarial-audit --task coherence-extraction to verify spec/codebase alignment across all 4 changes → SC-1 through SC-11
- [ ] 2. pre-red-baseline (**clean-room**). Dispatch implementation-pipeline --task pre-red-baseline to capture current source state before modifications

#### Per-Item RED+green Chains

##### TDD-1: Replace isFirstTurn heuristic with process-scoped Set<sessionID> (SC-1, SC-2)

- [ ] 1. RED: test-driven-development --task red (**clean-room**). Verify `userMessages.length === 1` still used for first-turn detection in `messages.transform` → SC-1
- [ ] 2. RED-doublecheck (**inline**). Verify RED condition confirmed via verification-before-completion --task verify → SC-1
- [ ] 3. GREEN: test-driven-development --task green (**clean-room**). Module-level `injectedFirstTurnSessions: Set<string>` keyed by `sessionID` from `session.created` event replaces length heuristic in `messages.transform` → SC-1, SC-2
- [ ] 4. GREEN-doublecheck (**inline**). Verify GREEN condition confirmed via verification-before-completion --task verify → SC-1, SC-2
- [ ] 5. checkpoint-commit (**clean-room**). Commit TDD-1 changes via git-workflow --task commit-prep

##### TDD-2: Remove inline work detector code (SC-3)

- [ ] 1. RED: test-driven-development --task red (**clean-room**). Verify inline work detection statements still exist in `messages.transform` handler → SC-3
- [ ] 2. RED-doublecheck (**inline**). Verify RED condition confirmed → SC-3
- [ ] 3. GREEN: test-driven-development --task green (**clean-room**). Remove all inline work detection statements from `messages.transform` handler → SC-3
- [ ] 4. GREEN-doublecheck (**inline**). Verify GREEN condition confirmed → SC-3
- [ ] 5. checkpoint-commit (**clean-room**). Commit TDD-2 changes

##### TDD-3: Remove mode-switch handling, replace with unconditional stripping (SC-4, SC-5)

- [ ] 1. RED: test-driven-development --task red (**clean-room**). Verify `isModeSwitchContent`, `handleModeSwitchParts`, `MODE_SWITCH_ANCHOR` still defined in `session-enforcement.ts` → SC-4
- [ ] 2. RED-doublecheck (**inline**). Verify RED condition confirmed → SC-4
- [ ] 3. GREEN: test-driven-development --task green (**clean-room**). Remove all three mode-switch identifiers; strip synthetic messages via text-content check (`text` contains known boilerplate → set `text = ""`) → SC-4, SC-5
- [ ] 4. GREEN-doublecheck (**inline**). Verify GREEN condition confirmed → SC-4, SC-5
- [ ] 5. checkpoint-commit (**clean-room**). Commit TDD-3 changes

##### TDD-4: Remove gate blocks — Pre-Implementation Gate, Core Principles, Tier 1 Mandate (SC-6, SC-7, SC-8)

- [ ] 1. RED: test-driven-development --task red (**clean-room**). Verify Pre-Implementation Gate, Core Principles injection, and Tier 1 Mandate Enforcement blocks still present in plugin → SC-6, SC-7, SC-8
- [ ] 2. RED-doublecheck (**inline**). Verify RED condition confirmed → SC-6, SC-7, SC-8
- [ ] 3. GREEN: test-driven-development --task green (**clean-room**). Remove all three gate blocks (`buildPreImplementationGate`, `buildCorePrinciplesBlock`, `buildTier1EnforcementBlock` and their call sites in `messages.transform`) → SC-6, SC-7, SC-8
- [ ] 4. GREEN-doublecheck (**inline**). Verify GREEN condition confirmed → SC-6, SC-7, SC-8
- [ ] 5. checkpoint-commit (**clean-room**). Commit TDD-4 changes

##### TDD-5: TypeScript compilation passes after all changes (SC-9)

- [ ] 1. RED: test-driven-development --task red (**clean-room**). Verify `npx tsc --noEmit` produces TypeScript errors in `.opencode/` directory → SC-9
  - *Depends on TDD-1 through TDD-4 being complete*
- [ ] 2. GREEN: test-driven-development --task green (**clean-room**). Fix compilation errors until `npx tsc --noEmit` produces zero errors → SC-9
- [ ] 3. GREEN-doublecheck (**inline**). Verify GREEN condition confirmed → SC-9
- [ ] 4. checkpoint-commit (**clean-room**). Commit TDD-5 changes

##### TDD-6: First-turn injection fires on first user message in a fresh session (SC-10)

- [ ] 1. RED: test-driven-development --task red (**clean-room**). Verify `opencode-cli run` with single-turn prompt shows no enforcement/injection blocks in first-turn context → SC-10
- [ ] 2. RED-doublecheck (**inline**). Verify RED condition confirmed → SC-10
- [ ] 3. GREEN: test-driven-development --task green (**clean-room**). Fix behavioral issue so enforcement/injection blocks are present on first turn in a fresh session → SC-10
- [ ] 4. GREEN-doublecheck (**inline**). Verify GREEN condition confirmed → SC-10
- [ ] 5. checkpoint-commit (**clean-room**). Commit TDD-6 changes

##### TDD-7: First-turn injection does NOT fire on subsequent turns (SC-11)

- [ ] 1. RED: test-driven-development --task red (**clean-room**). Verify `opencode-cli run` multi-turn test shows injection blocks on turn 2 or later → SC-11
- [ ] 2. RED-doublecheck (**inline**). Verify RED condition confirmed → SC-11
- [ ] 3. GREEN: test-driven-development --task green (**clean-room**). Ensure injection blocks appear only on turn 1 in multi-turn test, never on subsequent turns → SC-11
- [ ] 4. GREEN-doublecheck (**inline**). Verify GREEN condition confirmed → SC-11
- [ ] 5. checkpoint-commit (**clean-room**). Commit TDD-7 changes

#### Post-RED/green

- [ ] 1. adversarial-audit (**clean-room**). Dispatch dual-family adversarial audit: resolve-models → auditor_1 → remediate → auditor_2 → cross-validate → SC-1 through SC-11
- [ ] 2. cross-validate (**clean-room**). Run adversarial-audit --task cross-validate on auditor consensus → SC-1 through SC-11
- [ ] 3. regression-check (**clean-room**). Run test-driven-development --task patterns for regression verification across all 7 TDD items
- [ ] 4. review-prep (**clean-room**). Dispatch git-workflow --task review-prep for PR readiness
- [ ] 5. exec-summary (**inline**). Dispatch completion-core --task completion for final summary and byline

---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Exit Criteria

- Plan stored at `.opencode/.issues/1308-spec-clean-up-session-enforcement-ts/plan.md`
- All 11 SCs mapped to 7 TDD items in 1 phase
- Auto-approved via scope >= `for_plan`
- `halt_at: plan_created` — HALT after plan creation, do NOT proceed to implementation
