# Implementation Plan — #1260

**Spec:** [SPEC-FIX] Sub-agent detection broken: input.client unavailable in messages.transform hook
**Plan structure:** combined (single-task spec, plan references spec content inline)
**Authorization:** for_pr scope, halt_at=pr_created, pr_strategy=stacked

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Goal

Fix sub-agent detection in `session-enforcement.ts` so sub-agent sessions are correctly identified and receive the `### Core Principles (Sub-Agent)` enforcement block on their first turn.

## Architecture

Single-file fix in `.opencode/plugins/session-enforcement.ts`. No new files, no new dependencies. The fix adds a `session.created` event handler that populates an in-memory `Map<sessionID, parentID>` cache, then rewrites the `messages.transform` detection to check the cache first with the existing `input.client.session.get()` API call as fallback.

## Tech Stack

TypeScript (existing plugin), OpenCode plugin API (`session.created` event, `messages.transform` hook), bash behavioral tests (`opencode-cli run`).

## File Structure

| Path | Responsibility |
|------|---------------|
| `.opencode/plugins/session-enforcement.ts` | Add `session.created` event handler + cache; rewrite `isSubAgent` detection in `messages.transform` |
| `.opencode/tests/behaviors/sub-agent-principles-injection.sh` | Behavioral enforcement test (RED before GREEN) |

## Item Decomposition

| Item | Name | Scope | Deliverable | Depends On |
|------|------|-------|-------------|------------|
| 1 | Event cache infrastructure | Register `session.created` handler, populate `Map<sessionID, parentID>` | Cache populated before `messages.transform` fires | — |
| 2 | Detection rewrite | Replace detection to check cache first, API fallback second | `isSubAgent` returns correct value for sub-agents | Item 1 |
| 3 | Behavioral enforcement test | Write RED test, implement fix, verify GREEN | `sub-agent-principles-injection.sh` PASS | Items 1, 2 |

## Phase 1: Detection Rewrite

**Concern:** Sub-agent detection mechanism — replacing broken `input.client.session.get()` with `session.created` event cache + fallback.

**Files:** `.opencode/plugins/session-enforcement.ts`, `.opencode/tests/behaviors/sub-agent-principles-injection.sh`

**SCs covered:** SC-1, SC-2, SC-3, SC-4

### Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 1260, "github.owner": "michael-conrad", "github.repo": ".opencode", "authorization_scope": "for_pr", "halt_at": "pr_created", "pr_strategy": "stacked", "pipeline_phase": "Phase 1"}` | SC-1, SC-2, SC-3, SC-4 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1260, "github.owner": "michael-conrad", "github.repo": ".opencode", "authorization_scope": "for_pr", "halt_at": "pr_created", "pr_strategy": "stacked", "pipeline_phase": "Phase 1"}` | SC-1, SC-2, SC-3, SC-4 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 1260, "github.owner": "michael-conrad", "github.repo": ".opencode", "authorization_scope": "for_pr", "halt_at": "pr_created", "pr_strategy": "stacked", "pipeline_phase": "Phase 1"}` | SC-4 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 1260, "github.owner": "michael-conrad", "github.repo": ".opencode", "authorization_scope": "for_pr", "halt_at": "pr_created", "pr_strategy": "stacked", "pipeline_phase": "Phase 1"}` | SC-4 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 1260, "github.owner": "michael-conrad", "github.repo": ".opencode", "authorization_scope": "for_pr", "halt_at": "pr_created", "pr_strategy": "stacked", "pipeline_phase": "Phase 1"}` | SC-4 |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 1260, "github.owner": "michael-conrad", "github.repo": ".opencode", "authorization_scope": "for_pr", "halt_at": "pr_created", "pr_strategy": "stacked", "pipeline_phase": "Phase 1"}` | SC-1, SC-2, SC-3, SC-4 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 1260, "github.owner": "michael-conrad", "github.repo": ".opencode", "authorization_scope": "for_pr", "halt_at": "pr_created", "pr_strategy": "stacked", "pipeline_phase": "Phase 1"}` | SC-1, SC-2, SC-3, SC-4 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-1, SC-2, SC-3, SC-4 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 1260, "github.owner": "michael-conrad", "github.repo": ".opencode", "authorization_scope": "for_pr", "halt_at": "pr_created", "pr_strategy": "stacked", "pipeline_phase": "Phase 1"}` | SC-1, SC-2, SC-3 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 1260, "github.owner": "michael-conrad", "github.repo": ".opencode", "authorization_scope": "for_pr", "halt_at": "pr_created", "pr_strategy": "stacked", "pipeline_phase": "Phase 1"}` | SC-1, SC-2, SC-3, SC-4 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 1260, "github.owner": "michael-conrad", "github.repo": ".opencode", "authorization_scope": "for_pr", "halt_at": "pr_created", "pr_strategy": "stacked", "pipeline_phase": "Phase 1"}` | SC-1, SC-2, SC-3, SC-4 |
| G12: adversarial-audit | sub-task | yes (blind) | auditor_1, auditor_2 | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 1260, "github.owner": "michael-conrad", "github.repo": ".opencode", "authorization_scope": "for_pr", "halt_at": "pr_created", "pr_strategy": "stacked", "pipeline_phase": "Phase 1", "audit_phase": "post_implementation"}` | SC-1, SC-2, SC-3, SC-4 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 1260, "github.owner": "michael-conrad", "github.repo": ".opencode", "authorization_scope": "for_pr", "halt_at": "pr_created", "pr_strategy": "stacked", "pipeline_phase": "Phase 1"}` | SC-1, SC-2, SC-3, SC-4 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 1260, "github.owner": "michael-conrad", "github.repo": ".opencode", "authorization_scope": "for_pr", "halt_at": "pr_created", "pr_strategy": "stacked", "pipeline_phase": "Phase 1"}` | SC-1, SC-2, SC-3 |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 1260, "github.owner": "michael-conrad", "github.repo": ".opencode", "authorization_scope": "for_pr", "halt_at": "pr_created", "pr_strategy": "stacked", "pipeline_phase": "Phase 1"}` | SC-1, SC-2, SC-3, SC-4 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 1260, "github.owner": "michael-conrad", "github.repo": ".opencode", "authorization_scope": "for_pr", "halt_at": "pr_created", "pr_strategy": "stacked", "pipeline_phase": "Phase 1"}` | SC-1, SC-2, SC-3, SC-4 |

### Per-Unit Pipeline Gate Table

| Gate | Name | Exit Criterion (unit-specific) |
|------|------|-------------------------------|
| 1 | sc-coherence-gate | All 4 SCs classified as behavioral evidence type; no EVIDENCE_TYPE_MISMATCH for any SC |
| 2 | pre-red-baseline | Source currency verified: `session-enforcement.ts` current state matches spec description; SC-ID cross-ref traceability confirmed |
| 3 | red-phase | Behavioral test `sub-agent-principles-injection.sh` exists and FAILS (sub-agent does NOT receive Core Principles block) |
| 4 | red-doublecheck | RED-side SC evidence: test FAIL confirms SC-4 gap (no sub-agent enforcement block injection) |
| 5 | post-red-enforcement | `git diff --name-only` shows only test file changed (no implementation files modified) |
| 6 | green-phase | `session.created` event handler + cache implemented; detection rewritten; behavioral test PASSES (sub-agent receives Core Principles block) |
| 7 | post-green-enforcement | `git diff --name-only` shows `session-enforcement.ts` and test file changed; no unintended files modified |
| 8 | checkpoint-commit | All changes committed with checkpoint tag |
| 9 | structural-checks | TypeScript check passes (`npx tsc --noEmit`); no lint errors on modified files |
| 10 | green-doublecheck | GREEN-side SC evidence: SC-1 (event cache captures parentID), SC-2 (cache primary, API fallback), SC-3 (sub-agent receives block), SC-4 (behavioral test PASS) all verified |
| 11 | green-vbc | VbC completion artifact confirms all 4 SCs PASS with behavioral evidence |
| 12 | adversarial-audit | Dual cross-family auditor consensus PASS on verification-audit; no FAIL or DONE_WITH_CONCERNS |
| 13 | cross-validate | Cross-validate confirms auditor consensus; no EVIDENCE_TYPE_MISMATCH or conflicting verdicts |
| 14 | regression-check | Existing enforcement tests still PASS; no regression in primary session injection or diagnostic output |
| 15 | review-prep | Compare URL generated; PR body drafted with Summary/Outcome/Fixes structure |
| 16 | exec-summary | PR created; issue comment posted with PR URL |

### RED/GREEN Conditions

**RED (what must be false before implementation):**
- Sub-agent sessions must NOT be correctly identified as sub-agents
- Sub-agents must NOT receive the `### Core Principles (Sub-Agent)` enforcement block
- The behavioral enforcement test `sub-agent-principles-injection.sh` must FAIL

**GREEN (what must be true when done):**
- `session.created` event handler must capture `parentID` into in-memory cache before `messages.transform` fires
- `isSubAgent` detection must use event cache as primary source, with `input.client.session.get()` as fallback
- Sub-agents must receive `### Core Principles (Sub-Agent)` block on first turn
- Behavioral enforcement test must PASS
- Primary sessions must still receive full first-turn injections (regression invariant)
- Diagnostic output must continue to function (regression invariant)
- Graceful degradation on API failure must be preserved (regression invariant)

### Concern Boundary

**Leaving:** No prior concern — this is the first and only phase.

**Entering:** Sub-agent detection mechanism in `session-enforcement.ts`. The concern is the `isSubAgent` detection pipeline: event registration → cache population → cache lookup → API fallback → enforcement block injection.

**Handoff to post-implementation:** After this phase, the fix is complete. The behavioral test serves as ongoing regression protection. No downstream phases depend on this phase's output.

### Inter-Phase Handoff

N/A — single phase. After G16 (exec-summary), proceed to Post-All-Phases Sweep.

### Post-All-Phases Sweep

- [ ] FINISHING CHECKLIST — git status clean, lint/typecheck from scratch, coverage sweep
- [ ] PR CREATION — via `github_create_pull_request`, extract `html_url` from response
- [ ] POST-MERGE CLEANUP — delete merged branches, close issues, sync dev

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

---

**Plan created for [michael-conrad/.opencode#1260](https://github.com/michael-conrad/.opencode/issues/1260) (SPEC-FIX: sub-agent detection broken). 1 phase, 3 items, 16 gates.**

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
