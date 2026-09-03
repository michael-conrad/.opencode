---
plan_schema_version: 1
issue: 2429
title: "Tier-1 context-injection reduction — scopes A/B/C/D/E/G/H implementation plan"
lifecycle_events:
  - timestamp: "2026-09-03T02:50:00Z"
    event: plan_created
    plan_path: ".opencode/.issues/2429/plan.md"
    phase_count: 7
  - timestamp: "2026-09-03T20:40:00Z"
    event: plan_revised
    plan_path: ".opencode/.issues/2429/plan.md"
    revision_reason: "Spec revised to add scope G (test-framework semantic continuous monitoring mandate) — new SC-10 (behavioral), R-21/R-22, Item 10. Plan regenerated to cover all 10 SCs across 8 phases. Scope-G GREEN change already committed as 4989ffb5; Item 10 records the RED baseline + monitored-run evidence cycle with a committed-GREEN confirmation."
    phase_count: 8
  - timestamp: "2026-09-03T22:10:00Z"
    event: plan_revised
    plan_path: ".opencode/.issues/2429/plan.md"
    revision_reason: "Spec revised to add scope H (spec-creation remote-number-first numbering in the create task) — new SC-11 (structural), R-23/R-24, Item 11. Plan regenerated to cover all 11 SCs across 9 phases; DAG gains the Phase-9 node (depends on phase8_done only); dependency-contract gains phase9_done + create_task_numbering_remote_first; each item references exactly one SC-ID. Items 1–8 and 10 are execution-preserved (Phases 1–4 already committed; Phase 4 verify pending; Item 10 RED+evidence cycle pending) — the revision adds Item 11 as a NEW pending phase in dependency order and does not re-plan completed work. Future commit messages reference #2429; historical commits keep #2427 (immutable history). Solve artifacts regenerated for the 9-phase decomposition."
    phase_count: 9
dispatch: [test-driven-development, verification-before-completion, audit, finishing-a-development-branch, git-workflow-pr, completion-core]
---

# Implementation Plan — Issue #2429 (.opencode): Tier-1 Context-Injection Reduction — Scopes A/B/C/D/E/G/H

Spec: [`.opencode/.issues/2429/spec.md`](https://github.com/michael-conrad/.opencode/tree/issues-data/2429) — remote exec summary: https://github.com/michael-conrad/.opencode/issues/2429

## Goal

Deduplicate and re-place Tier-1 injected content in the `.opencode` submodule while preserving semantics (R-6: rewrites OK if rule/guide/intent unchanged; verbatim text NOT required). Add two 000-critical-rules.md carve-outs (infrastructure-failure inline authorization; anti-recitation). Split 020-go-prohibitions.md and 080-code-standards.md by moving scenario-governed sections to Tier-2 files. Trim AGENTS.md scenario sections to pointers. Reconcile every duplicate to exactly one canonical home. Register all demoted content in INDEX.md. NO size-threshold PASS/FAIL criteria (#2411) — size figures are diagnostic evidence only. The #497 hard-constraint core (human-only merge, approval gate, no self-authorization, attribution mandates) stays in Tier-1 injected files. Echo-block removal (scope F) is OUT OF SCOPE — echo blocks travel WITH their sections. Scope G (developer-directed revision, 2026-09-03) mandates semantic continuous monitoring of behavioral runs in the tests-v2 harness (SC-10, R-21/R-22). Scope H (developer-directed revision, 2026-09-03, refined same day) restructures the spec-creation create task's numbering to remote-number-first (SC-11, R-23/R-24): when a remote API is available the remote stub is created FIRST, the number is taken from the API create response's `number` field, and the local record is created at exactly N — local == remote BY CONSTRUCTION; the local counter is used ONLY in local-only mode.

## Architecture

Nine phases in dependency order. Phase 1 adds the two 000 carve-outs first (they must be available before split work — spec edge case: all sub-agent dispatch attempts may fail at implementation time, and the carve-out is the authorized recovery). Phases 2, 3, 4 are mutually independent (disjoint files) but execute sequentially in this plan. Phase 5 verifies duplicate reconciliation and INDEX completeness. Phase 6 sweeps consumers (Read-links + test prompts) to zero dangling anchors. Phase 7 verifies the #497 guard. Phase 8 (scope G) evidences the test-framework semantic continuous monitoring mandate — its GREEN change (tests-v2/AGENTS.md §14 + helpers.sh `__semantic_monitor`) is ALREADY COMMITTED as 4989ffb5 during the spec-revision step, so Item 10 executes the RED baseline + monitored-run evidence cycle against a committed GREEN; Phase 8 depends on phase8_done only through the sequential daisy-chain and no other pending phase. Phase 9 (scope H) is NEW pending work: restructure `.opencode/skills/spec-creation/tasks/create.md` to remote-number-first numbering (SC-11, R-23/R-24) with structural evidence (create.md read-back + fixture scenario script); it slots after Phase 8 in dependency order. Implementation target: `.opencode` submodule branch `feature/2402-finishing-checklist-trailer-remediation` — ALL file edits and commits occur inside the `.opencode` submodule working tree (use `git -C .opencode`); authorization scope `for_pr`, PR strategy `stacked` (one branch, nine commits, one PR — items 6–7 commits are conditional evidence-recording no-ops when the verified state is already achieved; items 9 and 10 record evidence only, no new commit; item 10's GREEN change is already landed as 4989ffb5; item 11 commits create.md plus its fixture script).

New Tier-2 destination files (numbers verified free; frontmatter `trigger_on`, `tier: 2`, `load_when` mandatory; NOT added to the opencode.jsonc instructions array):

- `.opencode/guidelines/022-orchestrator-context-discipline.md` — receives 020 section 1.1
- `.opencode/guidelines/025-discussion-mode.md` — receives 020 section 1.6
- `.opencode/guidelines/082-python-standards.md` — receives the 080 Python-specific sections
- `.opencode/skills/gb-cli/reference/install-and-authentication.md` — receives the AGENTS.md gb CLI install table, version pinning, TOOL_MISSING content (canonical home per SC-6 gb-install class)
- `.opencode/reference/editor-mcp-plugin.md` — receives the AGENTS.md editor MCP tool table

Existing canonical homes (dedup destinations, read-only in their own right): `.opencode/guidelines/085-project-local-tools.md` (project-local tools class), `.opencode/guidelines/116-pair-mode.md` (pair mode class).

## Files

Direct: `.opencode/guidelines/000-critical-rules.md`, `.opencode/guidelines/020-go-prohibitions.md`, `.opencode/guidelines/080-code-standards.md`, `.opencode/AGENTS.md`, `.opencode/guidelines/INDEX.md`, `.opencode/guidelines/085-project-local-tools.md`, new files listed above, `.opencode/tests-v2/behaviors/2429-sc1-infra-failure-carveout.sh`, `.opencode/tests-v2/behaviors/2429-sc2-anti-recitation.sh`, `.opencode/skills/spec-creation/tasks/create.md`, `.opencode/tests-v2/behaviors/2429-sc11-remote-number-first.sh` (new fixture scenario script), swept skill files and behavioral test prompts. Read-only: `.opencode/guidelines/116-pair-mode.md`, `.opencode/opencode.jsonc` (diff must be empty), `.opencode/guidelines/010-approval-gate.md`.

## Dispatch

Per-item cycle (items 1–8 and 11; items 9 and 10 are verification/evidence-only — item 9 guard RED inline, item 10 executes the RED baseline + monitored evidence cycle against its pre-committed GREEN, no new commit): `red` → test-driven-development (**clean-room**), `green` → test-driven-development (**clean-room**), `post-regression` → test-driven-development (**clean-room**), `verify` → verification-before-completion (**clean-room**), `commit` → orchestrator (**inline**). Pre-implementation: `pre-regression` → test-driven-development (**clean-room**), `pre-regression-verify` → verification-before-completion (**clean-room**). Post-implementation: `audit` → audit (**clean-room**, investigator → validator → evaluator → arbiter in sequence), `z3-check` → orchestrator (**inline**), `structural-checks` → finishing-a-development-branch (**clean-room**), `pre-pr-gate` → verification-before-completion (**clean-room**), `regression-check` → test-driven-development (**clean-room**), `review-prep` → git-workflow-pr (**clean-room**), `create-pr` → git-workflow-pr (**clean-room**), `exec-summary` → completion-core (**clean-room**).

## Blast Radius

From `.opencode/.issues/2429/artifacts/blast-radius.yaml` — verdict MEDIUM. Direct changes: 000 (APPEND scope A + scope B), 020 (SPLIT — sections 1.1, 1.6, 4 out; authorization core retained), 080 (SPLIT — Python sections out; attribution retained), AGENTS.md (TRIM gb install table, editor MCP table, Pair Mode → pointers), INDEX.md (ADD Tier-2 rows), three new Tier-2 files, 085 (canonical dedup), spec-creation create.md (RESTRUCTURE — Step 3 stub-first flow to remote-number-first; result contract gains a BLOCKED API-failure-mid-flow outcome). Indirect consumers: opencode.jsonc instructions array (NONE — untouched), session-enforcement.ts (NONE — zero coupling), test-enforcement.sh FILE_SCENARIO_MAP (LOW — path-keyed, paths stable), behavioral tests 2243-sc1 / 2249-sc6 / 2249-sc7 pair / test-sc3-di-carveout-doc (MEDIUM — prompts hardcode the 080 path, mandatory sweep), 2131-series structural tests (LOW — path stable, section assertions verify per move), 2241-sc6 spec-creation create-path behavioral test (LOW-MEDIUM — exercises create.md Step 3 remote stub flow; the remote-number-first restructure changes WHICH number the flow binds but preserves the remote-stub-first step the test asserts; verify via scenario re-run in Phase 9 post-regression), skills with Read-links into moved sections — verification-before-completion (2 files), git-workflow-commit, issue-review, git-workflow-branch, audit (5 files) (MEDIUM — sweep), 085 mutual Read-link into 020 section 4 (LOW — resolved by dedup). Primary risks: dangling Read-link anchors, test prompts pointing at moved content, echo-block grep targets moving with sections — all mitigated by the phase 6 sweep (SC-8); scope-H risk (mismatched local↔remote numbers pointing at unrelated remote resources) is eliminated BY CONSTRUCTION in Phase 9 (R-24 exact-match invariant).

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Items (Step Range) | Dispatch |
|-------|------|---------|-----|--------------|--------------------|----------|
| 1 | 000 carve-outs (scopes A + B) | Safety-critical additions to 000-critical-rules.md | SC-1, SC-2 | none | Items 1–2 | test-driven-development, verification-before-completion |
| 2 | 020 split (scope C) | Authorization law vs scenario content separation; 085 canonical dedup | SC-3 | Phase 1 | Item 3 | test-driven-development, verification-before-completion |
| 3 | 080 split (scope D) | Universal vs Python-specific standards; attribution untouched | SC-4 | Phase 1 | Item 4 | test-driven-development, verification-before-completion |
| 4 | AGENTS.md trim (scope E) | Repo-reference dedup/routing; 116 canonical Pair Mode | SC-5 | Phase 1 | Item 5 | test-driven-development, verification-before-completion |
| 5 | Dedup + INDEX verification | Single canonical home per rule class; routing reachability | SC-6, SC-7 | Phases 2, 3, 4 | Items 6–7 | test-driven-development, verification-before-completion |
| 6 | Consumer sweep | Read-link + test-prompt integrity; zero dangling anchors | SC-8 | Phases 2, 3, 4, 5 | Item 8 | test-driven-development, verification-before-completion |
| 7 | #497 guard verification | Tier-1 core retention; opencode.jsonc invariance | SC-9 | Phase 6 | Item 9 | test-driven-development, verification-before-completion |
| 8 | Monitoring mandate evidence (scope G) | Semantic continuous monitoring RED baseline + monitored-run evidence cycle; GREEN already committed (4989ffb5) | SC-10 | Phase 7 (sequential daisy-chain only — RED baseline independent of Phases 2–7 outcomes) | Item 10 | test-driven-development, verification-before-completion |
| 9 | Remote-number-first create task (scope H) | spec-creation create.md stub-first flow restructured to remote-number-first numbering | SC-11 | Phase 8 | Item 11 | test-driven-development, verification-before-completion |

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Exit Criteria

1. C1 — Every item completed its RED → GREEN → post-regression → verify → commit cycle in dependency order; phases executed 1 through 9 (Item 10's GREEN is pre-committed as 4989ffb5 — its cycle is the RED baseline + monitored-run evidence recording per the on-disk state).
2. C2 — SC-1 through SC-11 each verified with evidence matching its declared evidence type (behavioral SCs via `bash .opencode/tests-v2/with-test-home opencode run`; structural SCs via grep/git diff/read-back); zero EVIDENCE_TYPE_MISMATCH verdicts. Monitored-run behavioral verdicts (SC-10) record monitoring evidence (poll log or semantic diagnosis) alongside session.yaml. SC-11's verdict records create.md read-back plus the fixture scenario script result.
3. C3 — No byte/token/percentage/line-count reduction threshold used as a PASS/FAIL criterion anywhere in the plan execution (R-16, #2411).
4. C4 — #497 core retained: human-only merge in 000, zero-tolerance table in 010, attribution sections in 080; `.opencode/opencode.jsonc` diff empty with 14 instructions-array entries (SC-9).
5. C5 — Zero dangling section anchors after the consumer sweep (SC-8); the four named scenarios PASS via with-test-home.
6. C6 — Exactly one canonical home per duplicated rule class: project-local tools → 085, pair mode → 116, gb install → gb-cli skill reference (SC-6).
7. C7 — INDEX.md carries one Tier-2 routing row per demoted class with accurate trigger patterns; new files carry `tier: 2` frontmatter (SC-7).
8. C8 — `uvx pymarkdownlnt scan` and `uvx mdformat --check` pass (advisory, read-only modes) on all modified guideline files (R-19).
9. C9 — Audit, z3-check, structural checks, pre-PR gate, and final regression check all PASS; PR created per stacked strategy on `feature/2402-finishing-checklist-trailer-remediation`; executive summary delivered.

## Pre-Implementation (once per plan)

- [ ] 1. Coherence gate — verify the plan-to-spec chain before any dispatch. (**inline**)
  - Confirm the spec at `.opencode/.issues/2429/spec.md` holds 11 success criteria (SC-1 through SC-11) and 24 SHALL requirements (R-1 through R-24).
  - Confirm `.opencode/.issues/2429/artifacts/structure.yaml` holds the 9-phase decomposition with triplet co-location verified (each SC's RED, GREEN, COMMIT in exactly one phase; SC-10's GREEN is pre-committed as 4989ffb5 per the on-disk state) and the 13-edge dependency DAG (11 edges among phases 1–7 + the 7→8 daisy-chain edge + the 8→9 edge; Phase 9 depends on phase8_done only).
  - Confirm `.opencode/.issues/2429/artifacts/solve-output.yaml` records solve_status SAT and plan_status SOLVED_SATISFICING for the 9-phase decomposition.
  - Confirm authorization scope is `for_pr` with PR strategy `stacked`, and the implementation target is the `.opencode` submodule branch `feature/2402-finishing-checklist-trailer-remediation` (R-17 stacking base; #2416 same-file additions rebase cleanly — disjoint sections).
  - Confirm #2411 binding constraint is honored: no SC in this plan uses a size metric as PASS/FAIL.
  - Confirm the scope-G GREEN change is committed as 4989ffb5 on the branch (`git -C .opencode log --oneline -1` shows 4989ffb5 or a descendant) — Item 10 proceeds on the committed-GREEN path.
  - If any check fails: BLOCKED — do not proceed to phase 1.
- [ ] 2. Baseline check — verify the repository state before any file modification. (**inline**)
  - Run `git -C .opencode branch --show-current` — must report `feature/2402-finishing-checklist-trailer-remediation`.
  - Run `git -C .opencode status --porcelain` — must be empty (zero pending changes).
  - Run `git -C .opencode log --oneline -1` — record the HEAD commit as the rollback anchor; confirm 4989ffb5 (scope-G GREEN) is on the branch.
  - Run `rm -f tmp/.behavior-run.lock` — clear any stale behavioral-test lock before test execution.
  - Confirm `.opencode/tests-v2/with-test-home` exists (all behavioral verification MUST run through it — never bare `opencode run`).
  - Confirm Item 10's evidence prerequisites: no `tmp/behavioral-evidence-2429-sc10-*` directories exist (RED baseline + monitored-run cycle pending); `.opencode/tests-v2/behaviors/helpers.sh` exports `__semantic_monitor` (committed 4989ffb5).
  - If any check fails: halt and report — do not work from a non-trunk-tip or dirty state.
- [ ] 3. Pre-regression — run regression test patterns before the first RED phase. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-pre-regression-*`.
  - Dispatch: `task(..., prompt: "execute phase-0 task from test-driven-development")` with context: issue 2429, branch feature/2402-finishing-checklist-trailer-remediation, baseline scenarios silent-halt-with-search, read-secrets-in-output, pipeline-scoped-halt via `bash .opencode/tests-v2/test-enforcement.sh --scenario <name>` plus the 2131-series and 2243/2249-series behavioral scripts — all must PASS on the pre-change tree to establish the regression baseline.
- [ ] 4. Pre-regression-verify — verify the baseline results. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-pre-regression-verify-*`.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")` with context: verify the pre-regression evidence artifact shows all baseline scenarios PASS; BLOCK on any baseline failure.

---

# Phase 1 — 000 Carve-Outs (Scopes A + B)

**Concern:** Add the infrastructure-failure inline-execution carve-out (scope A) and the anti-recitation clause (scope B) to `.opencode/guidelines/000-critical-rules.md` as numbered binary-condition procedures.
**Files:** `.opencode/guidelines/000-critical-rules.md` (modified); `.opencode/tests-v2/behaviors/2429-sc1-infra-failure-carveout.sh` (new); `.opencode/tests-v2/behaviors/2429-sc2-anti-recitation.sh` (new).
**SCs:** SC-1 (behavioral), SC-2 (behavioral).
**Dependencies:** None — first phase. Entry: pre-implementation steps complete. Exit: items 1 and 2 committed.
**Code path coverage:** Path 1 (session-start injection — 000 is instructions-array-loaded; additions alter runtime agent behavior, substrate-determined behavioral change per critical-rules-BEH-EV) and Path 3 (enforcement tests — two new behavioral scenarios via with-test-home).
**Cross-cutting SCs:** None in this phase; the carve-outs are verified again by the phase 7 guard (human-only-merge rule remains present in 000 post-change).
**Interface boundaries:** 000 path is keyed in test-enforcement.sh FILE_SCENARIO_MAP (scenarios silent-halt-with-search, read-secrets-in-output) — the map keys on the file path, which is unchanged; the appended carve-outs must not alter those scenarios' behavior (post-regression confirms). Numbered binary-condition procedure form per the 0.9-confidence research card finding — not prose mandates.
**State transitions:** 000-critical-rules.md grows by the carve-out text (~15 lines scope A, ~10 lines scope B); two new behavior scripts appear under `.opencode/tests-v2/behaviors/`; git state advances by two commits on the feature branch.

**Cost frame:** Running each carve-out behavioral scenario costs minutes of with-test-home execution time — a bounded delay that surfaces a halt/loop or recitation defect at gate 1. Skipping either scenario costs the full rework cycle when agents hang on infrastructure failures or burn context on citation-only turns in production sessions — diagnosis, spec-fix, re-review — each costing more than the skipped test.

### Item 1 — SC-1: Infrastructure-failure carve-out (scope A)

- [ ] 1. RED — write the failing behavioral enforcement test. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-red-1-*`.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")` with context: create `.opencode/tests-v2/behaviors/2429-sc1-infra-failure-carveout.sh`; the scenario prompt simulates a session state with at least two consecutive tool-level sub-agent dispatch failures and a pending read-only/verification task; run via `bash .opencode/tests-v2/with-test-home opencode run '<scenario prompt>'` with a timeout of at least 600000 ms; assertions are stderr-based (assert_stderr_pattern helpers per the 091 behavioral variant): RED condition = the agent halts or loops with NO carve-out disclosure and NO inline execution, because 000-critical-rules.md does not yet contain the scope A carve-out. Run `rm -f tmp/.behavior-run.lock` before re-runs.
  - SC reference: SC-1. The test MUST FAIL before GREEN begins.
- [ ] 2. GREEN — add the carve-out that makes the test pass. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-green-1-*`.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")` with context: append to `.opencode/guidelines/000-critical-rules.md` a numbered binary-condition procedure (~15 lines) authorizing inline execution of read-only/verification work after at least two consecutive tool-level sub-agent dispatch failures, WITH mandatory explicit disclosure in the agent's output (R-1). What must be true afterwards: the behavioral scenario passes — the agent discloses and proceeds inline within read-only/verification limits. No scope creep — minimum change only; numbered procedure form, not prose.
  - SC reference: SC-1.
- [ ] 3. Post-regression — run regression patterns after GREEN. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-post-regression-1-*`.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")` with context: re-run the 000-keyed scenarios `bash .opencode/tests-v2/test-enforcement.sh --scenario silent-halt-with-search` and `bash .opencode/tests-v2/test-enforcement.sh --scenario read-secrets-in-output` — both must remain PASS after the 000 edit.
  - SC reference: SC-1 (guard: R-15 enforcement-test compatibility).
- [ ] 4. Verify — verify the implementation against the success criterion. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-verify-1-*`.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")` with context: SC-1 verdict — evidence must be behavioral: session stderr from the with-test-home run shows disclosure plus inline execution confined to read-only/verification work. Structural-only evidence is EVIDENCE_TYPE_MISMATCH → FAIL.
  - SC reference: SC-1.
- [ ] 5. Commit — commit the test and the change as one atomic slice. (**inline**)
  - Run: `git -C .opencode add guidelines/000-critical-rules.md tests-v2/behaviors/2429-sc1-infra-failure-carveout.sh && git -C .opencode commit -m "test(000-critical-rules): add infrastructure-failure inline-execution carve-out (#2429 SC-1)"`.
  - No co-author trailers during implementation commits — those are added during squash at PR time.
  - SC reference: SC-1. This commit is the precondition for Item 2's RED.
  - Execution note: COMMITTED as e820bbad with message `... (#2427 SC-1)` — historical commits keep #2427 (immutable history; future commits reference #2429).

### Item 2 — SC-2: Anti-recitation clause (scope B)

- [ ] 6. RED — write the failing behavioral enforcement test. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-red-2-*`.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")` with context: create `.opencode/tests-v2/behaviors/2429-sc2-anti-recitation.sh`; the scenario prompt directs the agent to perform a mechanically simple, safe, reversible action; run via `bash .opencode/tests-v2/with-test-home opencode run '<scenario prompt>'` with a timeout of at least 600000 ms; stderr-based assertions: RED condition = the agent produces citation-only turns, reciting protocol rules instead of acting, because 000-critical-rules.md does not yet contain the anti-recitation clause. Run `rm -f tmp/.behavior-run.lock` before re-runs.
  - SC reference: SC-2. The test MUST FAIL before GREEN begins.
- [ ] 7. GREEN — add the anti-recitation clause that makes the test pass. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-green-2-*`.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")` with context: append to `.opencode/guidelines/000-critical-rules.md` an anti-recitation clause (~10 lines) establishing that rule citations belong in enforcement artifacts (test scripts, pre-commit hooks), not in agent deliberation, and that on a safe reversible action the agent acts and discloses instead of reciting rules before acting (R-2). What must be true afterwards: the behavioral scenario passes — the agent performs the action with disclosure and zero citation-only turns. Numbered clause form consistent with the scope A addition.
  - SC reference: SC-2.
- [ ] 8. Post-regression — run regression patterns after GREEN. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-post-regression-2-*`.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")` with context: re-run `bash .opencode/tests-v2/test-enforcement.sh --scenario silent-halt-with-search`, `bash .opencode/tests-v2/test-enforcement.sh --scenario read-secrets-in-output`, and the Item 1 scenario `bash .opencode/tests-v2/behaviors/2429-sc1-infra-failure-carveout.sh` — all must remain PASS after the second 000 edit.
  - SC reference: SC-2 (guard: SC-1 regression).
- [ ] 9. Verify — verify the implementation against the success criterion. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-verify-2-*`.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")` with context: SC-2 verdict — behavioral evidence: the with-test-home run shows the safe action performed with disclosure; zero citation-only turns in session stderr.
  - SC reference: SC-2.
- [ ] 10. Commit — commit the test and the change as one atomic slice. (**inline**)
  - Run: `git -C .opencode add guidelines/000-critical-rules.md tests-v2/behaviors/2429-sc2-anti-recitation.sh && git -C .opencode commit -m "test(000-critical-rules): add anti-recitation clause for safe reversible actions (#2429 SC-2)"`.
  - SC reference: SC-2. This commit closes Phase 1.
  - Execution note: COMMITTED as 122f1749 with message `... (#2427 SC-2)` — historical commits keep #2427 (immutable history).

### Phase 1 Completion

- VbC assertion: SC-1 and SC-2 verdicts are PASS with behavioral evidence artifacts on disk under `tmp/2429/artifacts/`.
- VbC assertion: 000-critical-rules.md contains both carve-outs in numbered binary-condition form; the 000-keyed enforcement scenarios still PASS.
- Concern transition: the carve-outs are now available before any split work begins — proceed to Phase 2 (020 split).

---

# Phase 2 — 020 Split (Scope C)

**Concern:** Move scenario-governed sections (1.1 Orchestrator Context Discipline, 1.6 Discussion Mode Mandates, 4 Project-Local Tool Installation) out of `.opencode/guidelines/020-go-prohibitions.md` to Tier-2 destinations with semantically equivalent content; reconcile section 4 into 085 as the single canonical home (dedup, not dual copy); retain authorization semantics, prohibited authorization patterns, halt rules, the authorization-free-actions list, and silent-halt-with-search in the Tier-1 core.
**Files:** `.opencode/guidelines/020-go-prohibitions.md` (split), `.opencode/guidelines/022-orchestrator-context-discipline.md` (new), `.opencode/guidelines/025-discussion-mode.md` (new), `.opencode/guidelines/085-project-local-tools.md` (canonical dedup), `.opencode/guidelines/INDEX.md` (rows for 022, 025).
**SCs:** SC-3 (behavioral). Guards: R-6 (semantic equivalence — verbatim not required), R-9 (echo blocks inside moved sections travel WITH their sections — removal is out-of-scope F), R-14 (one-line imperative `Read [Text](path)` pointer per demoted concern — the "See X" citation form is defective and MUST NOT be used), R-19 (lint gate).
**Dependencies:** Phase 1 complete (carve-outs available). Entry: Item 2 committed. Exit: Item 3 committed.
**Code path coverage:** Path 1 (020 stays in the instructions array — file shrinks in place), Path 2 (Tier-2 on-demand routing via new INDEX rows for 022 and 025; existing 085 row reused), Path 4 (skill Read-links into 020 sections 1.1/1.6/4 become dangling until the phase 6 sweep — audit x5, verification-before-completion x2, git-workflow-commit, issue-review, 091 cross-refs).
**Cross-cutting SCs:** R-9 echo-block safety — the [critical-rules-034/035/043/044/048/063/065/071/072] echo blocks inside the moved sections travel with them; enforcement-test grep targets are re-pointed in phase 6, not here.
**Interface boundaries:** 020/085 file paths are stable public API (FILE_SCENARIO_MAP keys). The 085 mutual Read-link into 020 section 4 flips direction in this phase: 085 becomes canonical; the 020 core holds the pointer to 085. The empty "Specialized Execution Gates" section header in 020 is REMOVED (nothing to preserve) — not moved. Section 2 (Iterative Feedback & Plan Revision) STAYS in the 020 core — it is not in the demotion set.
**State transitions:** 020 loses sections 1.1, 1.6, 4 and the empty section 3 header; 022 and 025 are created with standard frontmatter (`trigger_on`, `tier: 2`, `load_when`); 085 absorbs the section 4 content as its single canonical copy; INDEX.md gains two rows; git state advances by one commit.

**Cost frame:** Running the 020 split's structural greps and one routing spot-check costs seconds to minutes. Skipping means authorization law and context mechanics share one file again — the next agent demoting content breaks the authorization core, and the defect surfaces as an enforcement-test failure in CI days later.

### Item 3 — SC-3: Split 020 — move scenario-governed sections to Tier-2

- [ ] 1. RED — write the failing enforcement test. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-red-3-*`.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")` with context: structural RED — grep asserts that INDEX.md lacks routing rows for the context-discipline and discussion-mode classes, that the 020 core still contains the three scenario-governed sections, and that the project-local-tools key rules appear in BOTH 020 section 4 and 085 (duplicate present); additionally stage the behavioral routing spot-check scenario prompt (agent must reach a demoted rule through the INDEX row or pointer) via `bash .opencode/tests-v2/with-test-home opencode run '<routing prompt>'` — RED condition = the demoted rule is unreachable because the move has not happened.
  - SC reference: SC-3. The test MUST FAIL before GREEN begins.
- [ ] 2. GREEN — perform the split with semantically equivalent content. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-green-3-*`.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")` with context: move 020 section 1.1 (Orchestrator Context Discipline — three mandates, context flow, authorization-free actions placement) into new `.opencode/guidelines/022-orchestrator-context-discipline.md`; move 020 section 1.6 (Discussion Mode Mandates) into new `.opencode/guidelines/025-discussion-mode.md`; reconcile 020 section 4 (Project-Local Tool Installation) INTO `.opencode/guidelines/085-project-local-tools.md` as the single canonical copy — dedup, NOT a dual-copy move (R-13); remove the empty "Specialized Execution Gates" header from 020 (nothing to preserve); echo blocks inside moved sections travel WITH their sections (R-9); rewrites/rephrasing/condensation permitted — same requirements, forbiddances, and mandates (R-6); when intent is ambiguous, preserve the original text rather than guess (fail-fast). What must be true afterwards: 020 core retains authorization semantics, prohibited authorization patterns, halt rules, the authorization-free-actions list, and silent-halt-with-search; each demoted concern has exactly one canonical home; the 020 core carries one-line imperative `Read [Text](path)` pointers per demoted concern; 022 and 025 carry `trigger_on`/`tier: 2`/`load_when` frontmatter; INDEX.md gains rows for 022 and 025 with trigger patterns matching their content; 085 is the only home for the 8 project-local-tools key rules.
  - SC reference: SC-3.
- [ ] 3. Post-regression — run regression patterns after GREEN. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-post-regression-3-*`.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")` with context: run `bash .opencode/tests-v2/test-enforcement.sh --scenario pipeline-scoped-halt` (020-keyed) — must remain PASS after the split; note the 2131-series and sweep-dependent scenarios are handled in their own phases.
  - SC reference: SC-3 (guard: R-15 enforcement-test compatibility).
- [ ] 4. Verify — verify the implementation against the success criterion. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-verify-3-*`.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")` with context: SC-3 verdict — structural greps: retained authorization/halt content present in the 020 core, moved sections absent from the core, one-line imperative pointers present; `grep -c` over 085 and 020 for the project-local-tools key semantics resolves to 085 only; plus the behavioral routing spot-check via `bash .opencode/tests-v2/with-test-home opencode run '<routing prompt>'` asserting the agent reaches a moved rule through the pointer or INDEX row. Lint gate: `uvx pymarkdownlnt scan -r .opencode/guidelines/` and `uvx --with mdformat-frontmatter --with mdformat-tables --with mdformat-config --with mdformat-gfm mdformat --number --compact-tables --check .opencode/guidelines/` (advisory, read-only).
  - SC reference: SC-3.
- [ ] 5. Commit — commit the split as one atomic slice. (**inline**)
  - Run: `git -C .opencode add guidelines/020-go-prohibitions.md guidelines/022-orchestrator-context-discipline.md guidelines/025-discussion-mode.md guidelines/085-project-local-tools.md guidelines/INDEX.md && git -C .opencode commit -m "refactor(guidelines): split 020 — demote context-discipline and discussion-mode to Tier-2; 085 canonical (#2429 SC-3)"`.
  - SC reference: SC-3. This commit is the precondition for Item 4's RED.
  - Execution note: COMMITTED as a0ee6d0e with message `... (#2427 SC-3)` — historical commits keep #2427 (immutable history).

### Phase 2 Completion

- VbC assertion: SC-3 verdict PASS with structural grep evidence plus the behavioral routing spot-check; lint gate PASS.
- VbC assertion: the 020 core retains all authorization semantics; 085 is the single canonical project-local-tools home.
- Concern transition: the 020 authorization core is isolated — proceed to Phase 3 (080 split).

---

# Phase 3 — 080 Split (Scope D)

**Concern:** Move Python-specific sections out of `.opencode/guidelines/080-code-standards.md` to a new Tier-2 file with semantically equivalent content; the attribution/provenance/byline-preservation sections remain Tier-1 and explicitly untouched (R-18, #2131 continuity).
**Files:** `.opencode/guidelines/080-code-standards.md` (split), `.opencode/guidelines/082-python-standards.md` (new), `.opencode/guidelines/INDEX.md` (row for 082).
**SCs:** SC-4 (behavioral). Guards: R-6 (semantic equivalence), R-9 (echo blocks travel — the critical-rules-042 echo in 080 moves with its section), R-14 (imperative pointer), R-19 (lint gate).
**Dependencies:** Phase 1 complete. Entry: Item 3 committed. Exit: Item 4 committed.
**Code path coverage:** Path 1 (080 stays instructions-array-loaded; shrinks in place), Path 2 (new INDEX row for 082), Path 3 (behavioral tests 2243-sc1, 2249-sc6, 2249-sc7 pair, test-sc3-di-carveout-doc hardcode the 080 path for DI content — prompts are re-pointed in phase 6; this phase verifies DI reachability against the new destination), Path 4 (skill Read-links into 080 Python sections dangle until phase 6).
**Cross-cutting SCs:** R-10/R-20 — 082 is NOT appended to the opencode.jsonc instructions array. R-18 — no supersession of closed #2131 outcomes; the attribution sections (AI Co-Authored Attribution, Provenance Headers, byline-preservation rules) and the Cross-Reference Standards, Numbering, YAML Standard, Tool Selection, and Linting sections stay in the 080 core.
**Interface boundaries:** 080 file path stable (FILE_SCENARIO_MAP consumers + 2131-series TARGET_FILE). Section anchors for Typing, Design Principles body, Modern Python, both Dependency Injection sections, Print Statements & Output, Libraries & Packages, and the Pipeline Rerun Constraint move to 082 — all consumer anchors re-pointed in phase 6. The 080 core keeps the programming-principles skill pointer intro; the Design Principles BODY moves.
**State transitions:** 080 loses the seven Python-specific sections; 082 is created with standard frontmatter; INDEX.md gains one row; git state advances by one commit.

**Cost frame:** Running the 080 split's greps and the DI-reachability re-run costs minutes. Skipping means Python standards at Tier 1 mislead non-Python sessions and the DI test prompts break silently — discovered only when the behavioral suite next runs.

### Item 4 — SC-4: Split 080 — move Python-specific sections to Tier-2

- [ ] 1. RED — write the failing enforcement test. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-red-4-*`.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")` with context: structural RED — grep asserts that no Tier-2 python-standards file exists and that the 080 core still carries the Typing, Design Principles body, Modern Python, Dependency Injection (both sections), Print Statements & Output, Libraries & Packages, and Pipeline Rerun Constraint sections; the DI-reachability scenario staged against the not-yet-existing destination fails.
  - SC reference: SC-4. The test MUST FAIL before GREEN begins.
- [ ] 2. GREEN — create the Tier-2 python-standards file and slim the 080 core. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-green-4-*`.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")` with context: create `.opencode/guidelines/082-python-standards.md` with `trigger_on`/`tier: 2`/`load_when` frontmatter; move the Typing, Design Principles body, Modern Python, Dependency Injection (mandate + generic mandate), Print Statements & Output, Libraries & Packages, and Pipeline Rerun Constraint sections from 080 into 082 with semantically equivalent content (R-6 — rewrites permitted, same requirements and forbiddances; ambiguous intent → preserve original text, fail-fast); echo blocks inside moved sections travel with them (R-9); add one-line imperative `Read [Text](path)` pointer in the 080 core; add the INDEX.md row for 082 with trigger patterns matching the moved content (dependency injection, di, typing, python, print, pipeline rerun). What must be true afterwards: the attribution/provenance/byline-preservation sections, Cross-Reference Standards, Numbering, YAML Standard, Tool Selection, and Linting sections remain in the 080 core UNTOUCHED (R-18); 082 is the single home for the Python-specific standards; 082 is NOT in the opencode.jsonc instructions array (R-10, R-20).
  - SC reference: SC-4.
- [ ] 3. Post-regression — run regression patterns after GREEN. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-post-regression-4-*`.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")` with context: run the 2131-series structural tests `bash .opencode/tests-v2/behaviors/2131/sc-1-parsing-paths.sh`, `bash .opencode/tests-v2/behaviors/2131/sc-2-library-names.sh`, `bash .opencode/tests-v2/behaviors/2131/sc-7-pipeline-rerun.sh` — record which assertions still target 080 content that moved to 082; the full re-point and re-run of those assertions happens in phase 6 (record the delta here, do not fix here).
  - SC reference: SC-4 (guard: R-15 enforcement-test compatibility evidence gathering).
- [ ] 4. Verify — verify the implementation against the success criterion. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-verify-4-*`.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")` with context: SC-4 verdict — structural greps: attribution sections intact in the 080 core, moved sections absent from the core, imperative pointer present, 082 frontmatter correct; behavioral DI-reachability: run the 2243-sc1-style DI scenario with the prompt re-pointed to the 082 destination via `bash .opencode/tests-v2/with-test-home opencode run '<DI prompt targeting 082>'` — the agent reaches the DI mandate through the new file. Lint gate per R-19 (advisory, read-only).
  - SC reference: SC-4.
- [ ] 5. Commit — commit the split as one atomic slice. (**inline**)
  - Run: `git -C .opencode add guidelines/080-code-standards.md guidelines/082-python-standards.md guidelines/INDEX.md && git -C .opencode commit -m "refactor(guidelines): split 080 — demote Python standards to Tier-2; attribution retained (#2429 SC-4)"`.
  - SC reference: SC-4. This commit is the precondition for Item 5's RED.
  - Execution note: COMMITTED as 73cfaf1b with message `... (#2427 SC-4)` — historical commits keep #2427 (immutable history).

### Phase 3 Completion

- VbC assertion: SC-4 verdict PASS with structural + behavioral DI-reachability evidence; attribution sections byte-untouched in the 080 core.
- VbC assertion: lint gate PASS on 080 and 082.
- Concern transition: Python standards are demoted — proceed to Phase 4 (AGENTS.md trim).

---

# Phase 4 — AGENTS.md Trim (Scope E)

**Concern:** Trim scenario-specific sections from `.opencode/AGENTS.md` to Tier-2 routing pointers: the gb CLI install table/version-pinning/TOOL_MISSING content, the editor MCP plugin tool table, and the Pair Mode section (dedup to the existing 116 canonical home — no second copy).
**Files:** `.opencode/AGENTS.md` (trimmed), `.opencode/skills/gb-cli/reference/install-and-authentication.md` (new — canonical gb install home), `.opencode/reference/editor-mcp-plugin.md` (new), `.opencode/guidelines/116-pair-mode.md` (existing canonical — read-only).
**SCs:** SC-5 (behavioral). Guards: R-6 (semantic equivalence), R-14 (imperative pointers), R-17 (stacks on feature/2402; #2416 same-file additions rebase cleanly — disjoint sections), R-19 (lint gate), R-13 (Pair Mode dedup — exactly one canonical home: 116).
**Dependencies:** Phase 1 complete. Entry: Item 4 committed. Exit: Item 5 committed.
**Code path coverage:** Path 1 (AGENTS.md is instructions-array-loaded; shrinks in place), Path 2 (gb install and editor table load on demand from their reference destinations; 116 already has an INDEX row), Path 4 (skill/guideline Read-links into the AGENTS.md gb, editor, and Pair Mode sections dangle until phase 6).
**Cross-cutting SCs:** R-13 dedup — the Pair Mode section is REPLACED by a pointer to 116 (which already holds the content); the gb skill-dispatch mandate line is RETAINED in AGENTS.md.
**Interface boundaries:** AGENTS.md path is stable (instructions array). The gb install canonical home moves into the gb-cli skill neighborhood (SC-6 gb-install class resolution); the editor MCP table moves to the reference/ directory; deep links into the removed AGENTS.md sections break unless re-pointed — phase 6 sweep covers them.
**State transitions:** AGENTS.md loses three sections (replaced by three one-line imperative pointers + the retained mandate line); two new reference files created; git state advances by one commit.

**Cost frame:** Running the AGENTS.md trim's structural checks costs seconds. Skipping means install tables and tool inventories keep injecting every session, and the duplicated Pair Mode rules drift apart until a pair-mode session follows the stale copy.

### Item 5 — SC-5: Trim AGENTS.md scenario sections to Tier-2 routing

- [ ] 1. RED — write the failing enforcement test. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-red-5-*`.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")` with context: structural RED — grep asserts that AGENTS.md still carries the gb CLI install table, version-pinning and TOOL_MISSING content, the editor MCP tool table, and the full Pair Mode section; no single canonical gb-install home exists outside the skill area; stage the behavioral spot-check prompt (a gb-install or pair-mode question must route to canonical content) via `bash .opencode/tests-v2/with-test-home opencode run '<gb-install or pair-mode prompt>'` — RED condition = the agent answers from the duplicated AGENTS.md copy or cannot reach canonical content.
  - SC reference: SC-5. The test MUST FAIL before GREEN begins.
- [ ] 2. GREEN — replace the three sections with pointers; dedup Pair Mode to 116. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-green-5-*`.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")` with context: move the gb CLI install-by-platform table, version-pinning rules, and TOOL_MISSING detection content into new `.opencode/skills/gb-cli/reference/install-and-authentication.md` (semantically equivalent, R-6); move the editor MCP plugin description and 11-tool surface table into new `.opencode/reference/editor-mcp-plugin.md`; replace the AGENTS.md Pair Mode section with a one-line imperative `Read [Text](.opencode/guidelines/116-pair-mode.md)` pointer — NO second copy of Pair Mode rules (R-13; read 116 first to confirm it holds the canonical content); replace the gb and editor sections with one-line imperative `Read [Text](path)` pointers to their new destinations; RETAIN the one-line gb skill-dispatch mandate in AGENTS.md. What must be true afterwards: AGENTS.md carries pointers plus the mandate line only; the install and editor content lives in exactly one Tier-2 location each; Pair Mode lives only in 116.
  - SC reference: SC-5.
- [ ] 3. Post-regression — run regression patterns after GREEN. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-post-regression-5-*`.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")` with context: run `bash .opencode/tests-v2/test-enforcement.sh --scenario silent-halt-with-search` and `bash .opencode/tests-v2/test-enforcement.sh --scenario pipeline-scoped-halt` (AGENTS.md is session context for both) — must remain PASS; record any gb-cli-series test result changes (gb-cli-*.sh test skill availability, not the AGENTS.md table — VERIFY only, sweep in phase 6 if any assertion targets the moved table).
  - SC reference: SC-5 (guard: R-15 enforcement-test compatibility).
- [ ] 4. Verify — verify the implementation against the success criterion. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-verify-5-*`.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")` with context: SC-5 verdict — structural greps: AGENTS.md contains one-line imperative pointers for the three trimmed sections plus the retained gb skill-dispatch mandate, and no residual install table, tool table, or Pair Mode rules; behavioral spot-check via `bash .opencode/tests-v2/with-test-home opencode run '<gb-install or pair-mode question>'` asserting the agent routes to the canonical content (gb-cli reference file or 116). Lint gate per R-19 (advisory, read-only).
  - SC reference: SC-5.
- [ ] 5. Commit — commit the trim as one atomic slice. (**inline**)
  - Run: `git -C .opencode add AGENTS.md skills/gb-cli/reference/install-and-authentication.md reference/editor-mcp-plugin.md && git -C .opencode commit -m "docs(agents): trim gb-install, editor-MCP, Pair Mode sections to Tier-2 pointers (#2429 SC-5)"`.
  - SC reference: SC-5. This commit closes Phase 4.
  - Execution note: GREEN changes COMMITTED across 4989ffb5 and f1bcf1cf (test-script renumbering 2427-* → 2429-* included in f1bcf1cf); Phase 4 verify (SC-5) evidence PENDING — execute Item 5 step 4 before advancing to Phase 5.

### Phase 4 Completion

- VbC assertion: SC-5 verdict PASS with structural pointer evidence plus the behavioral routing spot-check.
- VbC assertion: Pair Mode rules exist only in 116; gb install content exists only in the gb-cli skill reference.
- Concern transition: all three source files are trimmed — proceed to Phase 5 (dedup + INDEX verification).

---

# Phase 5 — Duplicate Reconciliation + INDEX Completeness (SC-6, SC-7)

**Concern:** Verify every duplicated rule class resolves to exactly ONE canonical Tier-2 home post-change (project-local tools → 085; pair mode → 116; gb install → gb-cli skill reference) and fix stragglers; verify INDEX.md holds a complete Tier-2 row set for every demoted class with accurate trigger patterns.
**Files:** `.opencode/guidelines/` (straggler dedup fixes if any), `.opencode/guidelines/INDEX.md` (row corrections if any).
**SCs:** SC-6 (structural), SC-7 (structural). Guards: R-7 (reachability), R-11 (frontmatter schema on new files), R-13 (dedup).
**Dependencies:** Phases 2, 3, 4 complete (their edits produced the dedup and INDEX rows this phase verifies). Entry: Item 5 committed. Exit: Items 6 and 7 committed.
**Code path coverage:** Path 2 (Tier-2 on-demand routing — INDEX rows are the reachability mechanism; a missing row makes a demoted rule unreachable and silently fails the semantic-preservation goal at first use).
**Cross-cutting SCs:** None new — this phase verifies the propagation rule from the cross-cutting matrix: every demoted section propagates to exactly one destination + one INDEX row + re-pointed consumers.
**Interface boundaries:** INDEX.md trigger patterns must not collide (exactly one row matches a given trigger intent; 022/025/082 number ranges verified free). Frontmatter schema (`trigger_on`, `tier: 2`, `load_when`) is mandatory on 022, 025, 082.
**State transitions:** guidelines tree converges to single canonical homes; INDEX.md row set finalizes; git state advances by at most two commits (straggler fixes and row corrections only — commits may be evidence-recording no-ops if items 3–5 already achieved the state).

**Cost frame:** Running the dedup grep sweep and the INDEX completeness read costs seconds. Skipping means dual canonical homes persist — divergent copies compound into contradictory rules that agents resolve arbitrarily, and a demoted rule becomes unreachable at first use.

### Item 6 — SC-6: Duplicate reconciliation verification

- [ ] 1. RED — write the failing structural test. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-red-6-*`.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")` with context: structural RED — `grep -rn` across `.opencode/guidelines/` and `.opencode/AGENTS.md` for each duplicated rule class's key semantics (project-local tools: the 8 key rules; pair mode: branch pattern table and dev-pair working-directory rules; gb install: platform download URLs and version pinning); RED condition = any class with MORE than one occurrence (straggler duplicate). If items 3–5 already achieved single-home state, the RED evidence records the zero-straggler counts and the item proceeds directly to verification — the grep evidence is mandatory either way.
  - SC reference: SC-6.
- [ ] 2. GREEN — fix any straggler duplicates. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-green-6-*`.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")` with context: for any class showing more than one occurrence, remove the non-canonical copy (canonical homes: 085 for project-local tools, 116 for pair mode, the gb-cli skill reference for gb install) leaving the canonical home intact; if the grep already shows exactly one occurrence per class, make NO edit — the minimum change needed is zero. What must be true afterwards: the class-key grep resolves to exactly one occurrence per class.
  - SC reference: SC-6.
- [ ] 3. Post-regression — run regression patterns after GREEN. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-post-regression-6-*`.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")` with context: re-run `bash .opencode/tests-v2/test-enforcement.sh --scenario pipeline-scoped-halt` and the 2131-series structural tests — all must remain PASS after any straggler fixes.
  - SC reference: SC-6.
- [ ] 4. Verify — verify the implementation against the success criterion. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-verify-6-*`.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")` with context: SC-6 verdict — structural: the class-key grep output shows exactly one occurrence per rule class across `.opencode/guidelines/` and `.opencode/AGENTS.md`, with the canonical home named for each class.
  - SC reference: SC-6.
- [ ] 5. Commit — commit any straggler fixes (or record the zero-fix evidence). (**inline**)
  - If edits were made: `git -C .opencode add guidelines/ && git -C .opencode commit -m "refactor(guidelines): dedup straggler fixes — single canonical home per rule class (#2429 SC-6)"`.
  - If no edits were needed: record the zero-straggler grep evidence under `tmp/2429/artifacts/` and skip the commit (verification-shaped item; nothing to commit).
  - SC reference: SC-6. This commit (or recorded no-op) is the precondition for Item 7's RED.

### Item 7 — SC-7: INDEX.md routing completeness

- [ ] 6. RED — write the failing structural test. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-red-7-*`.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")` with context: structural RED — read INDEX.md and assert a Tier-2 routing row exists for every demoted class (context-discipline → 022, discussion-mode → 025, python-standards → 082) with trigger patterns matching the moved content, and that 022/025/082 carry `trigger_on`/`tier: 2`/`load_when` frontmatter; RED condition = any missing row, any pattern that fails to match the destination content, or missing frontmatter.
  - SC reference: SC-7.
- [ ] 7. GREEN — complete or correct the INDEX row set. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-green-7-*`.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")` with context: add or correct INDEX.md rows so exactly one routing row exists per demoted class with trigger patterns matching the destination content; existing 085 and 116 rows are reused (they are already canonical); disambiguate any pattern collision so exactly one row matches a given trigger intent; if the row set is already complete and accurate from items 3 and 4, make NO edit. What must be true afterwards: one row per class; new files carry `tier: 2` frontmatter.
  - SC reference: SC-7.
- [ ] 8. Post-regression — run regression patterns after GREEN. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-post-regression-7-*`.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")` with context: re-run `bash .opencode/tests-v2/test-enforcement.sh --scenario pipeline-scoped-halt` — INDEX.md is session context; must remain PASS.
  - SC reference: SC-7.
- [ ] 9. Verify — verify the implementation against the success criterion. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-verify-7-*`.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")` with context: SC-7 verdict — structural: read INDEX.md post-change and assert one Tier-2 routing row per demoted class (context-discipline, discussion-mode, python-standards) with trigger patterns matching the moved content; assert 022, 025, and 082 each carry `trigger_on`, `tier: 2`, `load_when` frontmatter; confirm the existing 085 and 116 rows still resolve.
  - SC reference: SC-7.
- [ ] 10. Commit — commit INDEX corrections (or record the zero-fix evidence). (**inline**)
  - If edits were made: `git -C .opencode add guidelines/INDEX.md && git -C .opencode commit -m "docs(guidelines): INDEX routing rows for demoted classes (#2429 SC-7)"`.
  - If no edits were needed: record the row-set evidence under `tmp/2429/artifacts/` and skip the commit.
  - SC reference: SC-7. This commit (or recorded no-op) closes Phase 5.

### Phase 5 Completion

- VbC assertion: SC-6 and SC-7 verdicts PASS with grep and read evidence artifacts on disk.
- VbC assertion: every rule class has exactly one canonical home; every demoted class is INDEX-routable.
- Concern transition: canonical homes are final — proceed to Phase 6 (consumer sweep re-points all consumers to these final locations).

---

# Phase 6 — Consumer Sweep (SC-8)

**Concern:** Re-point ALL skill Read-links and behavioral test SCENARIO_PROMPTs referencing moved sections; eliminate every dangling section anchor; run the affected behavioral scenarios to PASS.
**Files:** `.opencode/skills/` (Read-link sweep — verification-before-completion operating-protocol.md and verify.md, git-workflow-commit SKILL.md, git-workflow-branch SKILL.md, issue-review tasks, audit tasks x5, 091 cross-references to context mechanics, 085 mutual-link already resolved in phase 2), `.opencode/tests-v2/` (SCENARIO_PROMPTs in 2243-sc1-dependency-injector-mandate.sh, 2249-sc6-generic-di-mandate.sh, 2249-sc7-html-css-exclusion.sh, 2249-sc7-contested-ts-di.sh, test-sc3-di-carveout-doc.sh; 2131-series TARGET_FILE/section assertions per moved sections).
**SCs:** SC-8 (behavioral). Guards: R-12 (consumer updates), R-15 (enforcement-test compatibility).
**Dependencies:** Phases 2, 3, 4, 5 complete (moved anchors and canonical homes exist). Entry: Item 7 committed (or recorded no-op). Exit: Item 8 committed.
**Code path coverage:** Path 3 (enforcement tests — prompts and assertions re-pointed) and Path 4 (skill Read-links re-pointed). The sweep command of record: `grep -rn "guidelines/020-go-prohibitions\|guidelines/080-code-standards" .opencode/skills/ .opencode/guidelines/`.
**Cross-cutting SCs:** Echo-block grep-target safety — moved echo blocks ([critical-rules-*] inside relocated sections) keep their text; test assertions that grep those echoes re-point to the new file locations in this phase; NO content removal (scope F out of scope).
**Interface boundaries:** The sweep is the mitigation for the BREAKING interfaces 3 and 4 from the interface-compatibility artifact: section anchors moved in phases 2–4; every Read-link and prompt targeting them must resolve to the new destination after this phase. FILE_SCENARIO_MAP keys on unchanged file paths — untouched.
**State transitions:** skill files and test scripts advance by one commit; the four named scenarios plus pipeline-scoped-halt reach PASS state via with-test-home.

**Cost frame:** Running the consumer sweep and the four named scenarios costs minutes via with-test-home. Skipping means dangling Read-links and broken test prompts surface as CI failures and misrouted agents — an order of magnitude more expensive to diagnose downstream.

### Item 8 — SC-8: Consumer sweep — Read-links + test prompts

- [ ] 1. RED — write the failing sweep verification. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-red-8-*`.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")` with context: run the sweep grep `grep -rn "guidelines/020-go-prohibitions\|guidelines/080-code-standards" .opencode/skills/ .opencode/guidelines/` and diff each hit against the post-phase-2/3 file states — RED condition = at least one hit resolves to a section anchor that no longer exists in the source file (dangling), or one of the 080-path test prompts directs the agent to DI content that now lives in 082; attempt the affected scenario runs to record the failure baseline.
  - SC reference: SC-8.
- [ ] 2. GREEN — re-point every consumer to the new canonical locations. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-green-8-*`.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")` with context: re-point every skill Read-link referencing 020 sections 1.1/1.6/4 or the 080 Python sections to their new destinations (022, 025, 085, 082) — imperative `Read [Text](path)` form only; re-point SCENARIO_PROMPT paths in the 2243-sc1, 2249-sc6, 2249-sc7 pair, and test-sc3-di-carveout-doc scripts from the 080 path to the 082 destination (or confirm a visible pointer routes there); update 2131-series TARGET_FILE/section assertions whose target sections moved; re-point echo-block grep targets in enforcement tests to the new file locations (blocks themselves untouched). What must be true afterwards: the sweep grep returns no dangling anchors, and every named scenario completes.
  - SC reference: SC-8.
- [ ] 3. Post-regression — run the named affected scenarios. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-post-regression-8-*`.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")` with context: run `rm -f tmp/.behavior-run.lock`, then via with-test-home with timeouts of at least 600000 ms: `bash .opencode/tests-v2/with-test-home opencode run` driven scenarios `bash .opencode/tests-v2/behaviors/2243-sc1-dependency-injector-mandate.sh`, `bash .opencode/tests-v2/behaviors/2249-sc6-generic-di-mandate.sh`, `bash .opencode/tests-v2/behaviors/2249-sc7-html-css-exclusion.sh`, `bash .opencode/tests-v2/behaviors/2249-sc7-contested-ts-di.sh`, and `bash .opencode/tests-v2/test-enforcement.sh --scenario pipeline-scoped-halt` — all PASS.
  - SC reference: SC-8.
- [ ] 4. Verify — verify the implementation against the success criterion. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-verify-8-*`.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")` with context: SC-8 verdict — the sweep grep returns zero dangling anchors across `.opencode/skills/` and `.opencode/guidelines/`; the four named scenarios PASS via with-test-home with stderr-based evidence; zero unverified claims.
  - SC reference: SC-8.
- [ ] 5. Commit — commit the swept files as one atomic slice. (**inline**)
  - Run: `git -C .opencode add skills/ tests-v2/ && git -C .opencode commit -m "test(sweep): re-point Read-links and scenario prompts to moved sections (#2429 SC-8)"`.
  - SC reference: SC-8. This commit closes Phase 6.

### Phase 6 Completion

- VbC assertion: SC-8 verdict PASS — zero dangling anchors, four named scenarios PASS with session evidence on disk.
- VbC assertion: no enforcement test asserts content at a stale location.
- Concern transition: all consumers resolve — proceed to Phase 7 (#497 guard verification).

---

# Phase 7 — #497 Guard Verification (SC-9)

**Concern:** Verify the #497 hard-constraint core survived all edits: human-only merge in 000-critical-rules.md, the approval gate / zero-tolerance table in 010-approval-gate.md, and the attribution mandates in 080-code-standards.md remain in Tier-1 injected files; the opencode.jsonc instructions array is unchanged (14 entries, byte-identical).
**Files:** `.opencode/guidelines/000-critical-rules.md`, `.opencode/guidelines/010-approval-gate.md`, `.opencode/guidelines/080-code-standards.md` (all read-only greps), `.opencode/opencode.jsonc` (read-only diff).
**SCs:** SC-9 (structural).
**Dependencies:** Phase 6 complete (guard runs after ALL content edits including the sweep). Entry: Item 8 committed. Exit: Item 9 verified — no commit.
**Code path coverage:** Path 1 (session-start injection — the guard confirms the true Tier-1 core still reaches the model) and Path 5 (config invariance).
**Cross-cutting SCs:** This is the verification column of the cross-cutting matrix for #497 core preservation, the scope A/B additions, and the informational-only context-reduction measurement (#2411 — measure and record, never gate).
**Interface boundaries:** Interface 1 (opencode.jsonc instructions array — UNCHANGED, 14 entries) and the #497 WARNING comment accuracy are the verified boundaries.
**State transitions:** no file changes — verification-only item; evidence recorded under `tmp/2429/artifacts/`; the informational injection-size measurement (pre/post stat of the 15 injected files) is recorded as diagnostic evidence ONLY, never a PASS/FAIL input (#2411).

**Cost frame:** Running the #497 guard greps and the git diff costs seconds. Skipping risks repeating the documented regression — a PR merged because the human-only-merge rule was missing from context — the highest-cost failure mode in the deck's history.

### Item 9 — SC-9: #497 guard verification (verification-only)

- [ ] 1. Guard RED — confirm the core rules were present before the edits (pre-change state check). (**inline**)
  - Run the guard greps against the baseline commit recorded in the pre-implementation baseline check (`git -C .opencode show <baseline-sha>:guidelines/000-critical-rules.md | grep -c "human-only merge"` and the corresponding 010 and 080 checks) — expected PASS on the baseline; this establishes the guard reference before comparing post-change state.
  - SC reference: SC-9.
- [ ] 2. GREEN — run the full structural guard verification. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-green-9-*`.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")` with context: no code change — run the post-change greps: human-only-merge rule present in `guidelines/000-critical-rules.md`; the zero-tolerance table present in `guidelines/010-approval-gate.md`; the attribution sections present in `guidelines/080-code-standards.md`; `git -C .opencode diff opencode.jsonc` is empty; the opencode.jsonc instructions array holds exactly 14 entries; record the informational injection-size stat (diagnostic only, #2411). What must be true afterwards: every guard grep passes and the diff is empty.
  - SC reference: SC-9.
- [ ] 3. Post-regression — final file-level regression confirmation. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-post-regression-9-*`.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")` with context: confirm `git -C .opencode status --porcelain` is clean (all slices committed) and the full scenario set touched by this plan is recorded PASS in the phase evidence.
  - SC reference: SC-9.
- [ ] 4. Verify — verify the implementation against the success criterion. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-verify-9-*`.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")` with context: SC-9 verdict — structural evidence: guard grep outputs + empty `git -C .opencode diff opencode.jsonc` + 14-entry count, recorded as the SC-9 evidence artifact.
  - SC reference: SC-9.
- [ ] 5. Record evidence — no commit (verification-only item). (**inline**)
  - Write the SC-9 evidence (grep outputs, diff emptiness, entry count, informational size stat) to `tmp/2429/artifacts/sc9-guard-evidence.yaml`.
  - SC reference: SC-9. This closes Phase 7 — SC-1 through SC-9 all carry verdicts.

### Phase 7 Completion

- VbC assertion: SC-9 verdict PASS — #497 core present, opencode.jsonc byte-identical, 14 entries.
- VbC assertion: SC-1 through SC-9 verdicts recorded with evidence-type-matched artifacts; Phase 8 (SC-10) then Phase 9 (SC-11) complete the eleven-SC set after this phase.

---

# Phase 8 — Monitoring Mandate Evidence (Scope G, SC-10)

**Concern:** Evidence the test-framework semantic continuous monitoring mandate (scope G) per SC-10: the GREEN change (tests-v2/AGENTS.md §14 monitoring mandate + tests-v2/behaviors/helpers.sh `__semantic_monitor` poll protocol) is ALREADY COMMITTED as 4989ffb5 during the spec-revision step — this phase's cycle is therefore the RED baseline + monitored-run evidence recording against a committed GREEN, plus regression/verify steps. The RED baseline records the unmonitored comparison (a run driving an off-track/loop state burning the full timeout with no abort and no diagnosis); the evidence cycle records the monitored variant (poll protocol executing, hard-abort detected, §10.5 export, semantic diagnosis recorded). The monitoring evidence requirements apply to SC-10's verdict AND to every monitored-run behavioral verdict recorded by Phases 1–7 evidence artifacts going forward.
**Files:** `.opencode/tests-v2/behaviors/helpers.sh` and `.opencode/tests-v2/AGENTS.md` (READ-ONLY this phase — change already committed as 4989ffb5); new evidence artifacts under `tmp/2429/artifacts/` (RED baseline record, poll log, semantic diagnosis, SC-10 verdict).
**SCs:** SC-10 (behavioral). Guards: R-21 (monitoring mandate), R-22 (hard-abort signals + abort recovery + §10.7 limitation documentation).
**Dependencies:** Phase 7 (sequential daisy-chain placement only) — the RED baseline and monitored evidence are independent of Phases 2–7 outcomes; no other pending phase constrains this phase.
**Code path coverage:** Path 3 (enforcement tests — helpers.sh `__semantic_monitor` poll protocol is the runtime-under-test; the monitored run exercises background launch, interval polling, live session DB read, semantic event-stream evaluation, hard-abort signals, kill + §10.5 export + diagnosis) and Path 5 (evidence contract — monitoring evidence recorded alongside session.yaml per the SC-10 evidence rule).
**Cross-cutting SCs:** SC-10's monitoring protocol is the evidence-collection method upgrade for ALL behavioral SCs in this plan (SC-1 through SC-5, SC-8) — monitored runs record poll logs/semantic diagnoses alongside session.yaml. §14's evidence requirement is verified here once as the harness-level gate; individual phase evidence artifacts confirm compliance per run.
**Interface boundaries:** helpers.sh and tests-v2/AGENTS.md are READ-ONLY in this phase (4989ffb5 is the committed GREEN; no further harness edits authorized under this plan — a defect found here is a spec-revision trigger, not an inline fix). The §10.7 amendment (new-home-per-invocation limitation) is verified present in tests-v2/AGENTS.md. The monitoring evidence contract (poll log + semantic diagnosis alongside session.yaml) is the verified interface between this phase and every behavioral SC verdict.
**State transitions:** NO file changes in the `.opencode` submodule this phase — Item 10 is evidence-recording only (the GREEN commit 4989ffb5 already advanced git state); evidence artifacts appear under `tmp/2429/artifacts/`; `tmp/behavioral-evidence-2429-sc10-*` directories are created by the RED baseline and monitored runs.

**Cost frame:** Running the RED baseline and the monitored scenario costs the poll intervals plus one abort-and-diagnose cycle — a bounded delay that surfaces a stuck-run defect at gate 1 instead of burning the full 600–900s timeout on every looped run (SC-10 cost frame, dark-prose-007). The per-run polling cost is seconds of SQLite reads against an already-present session DB; skipping the evidence cycle means SC-10's behavioral verdict has no poll-log/semantic-diagnosis artifact — an EVIDENCE_TYPE_MISMATCH that fails the completion gate regardless of the committed GREEN.

### Item 10 — SC-10: Monitoring mandate evidence cycle (scope G — GREEN pre-committed as 4989ffb5)

- [ ] 1. RED — record the unmonitored-run failure baseline. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-red-10-*` and `rm -f tmp/.behavior-run.lock`.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")` with context: the GREEN change is already committed (4989ffb5) — this RED step records the RED-vs-GREEN comparison baseline required by SC-10's verdict basis, not a pre-change failure. Run a scenario that drives an off-track/loop state (a prompt that induces repeated identical tool input or reasoning growth with no goal-relevant tool calls) with the monitor DISABLED (bypassing `__semantic_monitor`) via `bash .opencode/tests-v2/with-test-home opencode run '<off-track prompt>'` with a timeout of at least 600000 ms — observe it burn the full timeout with NO abort and NO semantic diagnosis recorded; archive the run artifacts under `tmp/behavioral-evidence-2429-sc10-RED-<model>/`. RED condition = the unmonitored run completes (or is killed by timeout) with zero poll-log entries, zero abort record, zero diagnosis — the comparison baseline against which the monitored variant's abort evidence is judged.
  - SC reference: SC-10. The RED baseline MUST be recorded before the monitored-run evidence step begins.
- [ ] 2. GREEN — confirm the committed monitoring mandate satisfies the scenario. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-green-10-*`.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")` with context: NO code change — the GREEN change is already landed as 4989ffb5 (tests-v2/AGENTS.md §14 mandate + helpers.sh `__semantic_monitor` wired into behavioral run paths). Verify the committed state satisfies SC-10: run the monitored variant of the same off-track scenario — the run is launched in background and polled; the poll reads the live session DB (newest `tmp/test-home-*/.local/share/opencode/opencode.db`), semantically evaluates the event stream, detects a hard-abort signal (identical tool input >=3x, or reasoning >20K chars with <=1 new tool call, or semantically judged off-track), kills the run, exports session.yaml per §10.5, and records the semantic diagnosis; archive poll log + session.yaml + diagnosis under `tmp/behavioral-evidence-2429-sc10-GREEN-<model>/`. What must be true afterwards: the abort beats the RED baseline's full-timeout burn; poll log shows per-poll event-stream reads + semantic judgment; §10.5 export present; diagnosis records the abort reason.
  - SC reference: SC-10.
- [ ] 3. Post-regression — confirm the monitoring mandate does not regress existing scenarios. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-post-regression-10-*`.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")` with context: re-run one completed behavioral scenario end-to-end under the monitoring protocol — `bash .opencode/tests-v2/behaviors/2429-sc1-infra-failure-carveout.sh` (SC-1's committed scenario) via `bash .opencode/tests-v2/with-test-home opencode run '<SC-1 scenario prompt>'` with a timeout of at least 600000 ms — must remain PASS with the poll protocol executing silently on a healthy run (no false-abort); confirms the monitor does not abort progressing runs.
  - SC reference: SC-10 (guard: healthy-run non-interference).
- [ ] 4. Verify — verify SC-10 with monitoring evidence alongside session.yaml. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-verify-10-*`.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")` with context: SC-10 verdict — evidence must be behavioral AND monitoring-shaped: session.yaml from the monitored run shows the stalled event stream; the poll log artifact shows per-poll live-DB event-stream reads + semantic judgments; the abort record shows the §10.5 export + semantic diagnosis; the §10.7 amendment (with-test-home new-home-per-invocation limitation, cross-invocation resumption impossible) is visible in tests-v2/AGENTS.md; the committed GREEN (4989ffb5) contains the §14 mandate and the `__semantic_monitor` helper. Structural-only evidence is EVIDENCE_TYPE_MISMATCH → FAIL.
  - SC reference: SC-10.
- [ ] 5. Record evidence — no commit (GREEN change already committed as 4989ffb5). (**inline**)
  - Write the SC-10 evidence (RED baseline record, poll log, semantic diagnosis, monitored-run session.yaml path, §10.7 amendment citation, committed-GREEN SHA) to `tmp/2429/artifacts/sc10-monitoring-evidence.yaml`.
  - SC reference: SC-10. This closes Phase 8 — ten of eleven SCs now carry verdicts; Phase 9 (SC-11) follows.

### Phase 8 Completion

- VbC assertion: SC-10 verdict PASS — monitored abort evidence (poll log + semantic diagnosis + §10.5 export) recorded alongside session.yaml; RED baseline shows the unmonitored full-timeout burn; no false-abort on the healthy-run regression scenario.
- VbC assertion: SC-1 through SC-10 all carry verdicts with evidence-type-matched artifacts; Phase 9 (SC-11) completes the set after this phase.

---

# Phase 9 — Remote-Number-First Create Task (Scope H, SC-11)

**Concern:** Restructure `.opencode/skills/spec-creation/tasks/create.md` stub-first flow to remote-number-first numbering per SC-11 (R-23/R-24): when a remote API is available, the flow creates the remote stub FIRST (before any local record), takes the remote-assigned number N from the API create response's `number` field, creates the local issue record at exactly N (local directory `.issues/N/`, issue.yaml with `remote_issue: N`), and writes the binding fields (remote_issue, remote_url, github_url) all referencing N — local == remote BY CONSTRUCTION. The create task explicitly documents that the local counter is used ONLY in local-only mode. The result contract gains a BLOCKED outcome for API failure mid-flow (remote stub created but local write fails — no silent reassignment of a different local number). The renumber/migrate repair pattern is documented for the case where the remote assigns a number whose local directory already exists.
**Files:** `.opencode/skills/spec-creation/tasks/create.md` (restructured), `.opencode/tests-v2/behaviors/2429-sc11-remote-number-first.sh` (new fixture scenario script — structural evidence).
**SCs:** SC-11 (structural). Guards: R-23 (remote-number-first number sourcing), R-24 (exact-match invariant + renumber/migrate repair).
**Dependencies:** Phase 8 complete (sequential daisy-chain placement; create.md is disjoint from the guideline/test files edited in Phases 1–8 — the dependency is ordering, not content). Entry: Item 10 evidence recorded. Exit: Item 11 committed.
**Code path coverage:** Path 5 (deterministic task-card procedure — the flow is a documented sequence whose behavior is verified by reading the revised create.md; not a runtime-behavioral change: agent dispatch behavior is unchanged, only the number-sourcing sequence inside the task card is restructured, substrate-determined structural per the spec's SC-11 evidence declaration) and Path 3 (fixture scenario script demonstrating the number is taken from the API response, not the counter).
**Cross-cutting SCs:** The 2241-sc6 spec-creation create-path behavioral test exercises create.md Step 3's remote stub flow — re-run post-GREEN in this phase's post-regression to confirm the stub-first step it asserts is preserved (the remote-number-first restructure keeps the remote stub; only the number source changes).
**Interface boundaries:** create.md is a task card read by sub-agents executing the spec-creation create step — the restructure changes the numbered procedure body only; the task card's category (PRODUCTION), entry criteria, exit criteria, and result-contract field set are preserved, with the result contract gaining the BLOCKED `API_FAILURE_MID_FLOW` outcome. The `.issues/N/` path convention and the `remote_issue` binding field are existing interfaces — unchanged, now sourced from the API response. Local counter semantics: `local-issues create` without `--number` autonumbers from the local `.counter` — that path remains ONLY for local-only mode (no remote API).
**State transitions:** create.md Step 3 restructured (remote stub FIRST; number from API response `number` field; local record at exactly N; local counter restricted to local-only mode; BLOCKED on API failure mid-flow; renumber/migrate repair documented); new fixture scenario script under `.opencode/tests-v2/behaviors/`; git state advances by one commit.

**Cost frame:** Running the remote-number-first test scenario script costs seconds — a grep of create.md plus a fixture execution demonstrating the number comes from the API response (spec SC-11 cost frame). Skipping means every future stub-first creation re-risks the verified 2427↔2429 defect: two independent number sources bind mismatched numbers, pointing blockquotes, artifact URLs, and cross-references at an unrelated remote PR, and every downstream consumer of the wrong number inherits a corrupted pointer that costs a full renumber-and-repair cycle to undo. Construction-by-remote-number eliminates the divergence class outright.

### Item 11 — SC-11: Spec-creation remote-number-first flow (scope H)

- [ ] 1. RED — write the failing structural test. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-red-11-*`.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")` with context: structural RED — read `.opencode/skills/spec-creation/tasks/create.md` and confirm the incumbent stub-first flow: the remote stub is created (Step 3) WITHOUT the number being taken from the API response to drive the local record — the local number is picked independently (local counter / autonumber), i.e., two independent number sources; assert create.md does NOT yet state the remote-number-first sequence (stub FIRST, number from the API response's `number` field, local record at exactly N, local counter restricted to local-only mode, BLOCKED on API failure mid-flow). Create the fixture scenario script `.opencode/tests-v2/behaviors/2429-sc11-remote-number-first.sh`: a fixture API create response whose `number` field (e.g., 2429) DIFFERS from the local counter value (e.g., 2427) — the flow MUST adopt the API's number (2429), not the counter's (2427); RED condition = the fixture script fails because create.md lacks the remote-number-first sequence the script asserts. The fixture demonstrates the defect class verified this session (local 2427 assigned while remote counter was at 2429; remote #2427 a merged PR).
  - SC reference: SC-11. The test MUST FAIL before GREEN begins.
- [ ] 2. GREEN — restructure create.md to remote-number-first. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-green-11-*`.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")` with context: restructure `.opencode/skills/spec-creation/tasks/create.md` Step 3 to remote-number-first per R-23: when a remote API is available (github.platform is not `local`), the flow creates the remote stub FIRST (before any local record), takes the remote-assigned number N from the API create response's `number` field, creates the local issue record at exactly N (local directory `.issues/N/`, issue.yaml with `remote_issue: N`), and writes the binding fields (remote_issue, remote_url, github_url) all referencing N — local == remote BY CONSTRUCTION; explicitly document that the local counter is used ONLY in local-only mode (no remote API) and the create task MUST NOT use the local counter to pick the number when a remote API is available; add a BLOCKED outcome to the result contract for API failure mid-flow (remote stub created but local write fails) with blocker reason `API_FAILURE_MID_FLOW` — the task MUST NOT silently reassign a different local number and MUST NOT leave a half-bound state; document the renumber/migrate repair pattern per R-24 for the case where the remote assigns a number whose local directory already exists (migrate the existing local directory to the remote-assigned number, then create) — repair, not the primary guard. What must be true afterwards: the fixture scenario script passes — reading the revised create.md confirms the remote-number-first sequence (stub BEFORE any local record; number from the API response's `number` field; local record at exactly N; local counter restricted to local-only mode; BLOCKED outcome present), and the fixture run adopts the API response's number over the counter's.
  - SC reference: SC-11.
- [ ] 3. Post-regression — re-run the spec-creation create-path scenario. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-post-regression-11-*`.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")` with context: re-run the fixture scenario script `bash .opencode/tests-v2/behaviors/2429-sc11-remote-number-first.sh` — PASS; and confirm the 2241-sc6 spec-creation create-path behavioral test `bash .opencode/tests-v2/behaviors/2241-sc6-spec-creation-create-local-first.sh` still exercises create.md's remote stub flow without regression (the remote stub remains created FIRST; only the number source changed).
  - SC reference: SC-11.
- [ ] 4. Verify — verify the implementation against the success criterion. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-verify-11-*`.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")` with context: SC-11 verdict — structural evidence per the spec's declared evidence type: (1) read the revised `.opencode/skills/spec-creation/tasks/create.md` and confirm the remote-number-first sequence — remote stub created BEFORE any local record, number taken from the API create response's `number` field, local record created at exactly N with binding fields (remote_issue, remote_url, github_url) referencing N, BLOCKED outcome on API failure mid-flow, and an explicit statement that the local counter is used only in local-only mode; (2) run the fixture scenario script demonstrating the number comes from the API response, not the counter (fixture response `number` differs from the local counter — the flow adopts the API's number). Post-creation binding fields match the local directory number exactly. Prose recall is NOT evidence.
  - SC reference: SC-11.
- [ ] 5. Commit — commit the restructure and the fixture script as one atomic slice. (**inline**)
  - Run: `git -C .opencode add skills/spec-creation/tasks/create.md tests-v2/behaviors/2429-sc11-remote-number-first.sh && git -C .opencode commit -m "refactor(spec-creation): remote-number-first create-task flow — stub FIRST, number from API response, local record at exactly N (#2429 SC-11)"`.
  - SC reference: SC-11. This commit closes Phase 9.

### Phase 9 Completion

- VbC assertion: SC-11 verdict PASS — create.md read-back confirms the remote-number-first sequence; the fixture scenario script demonstrates the number is taken from the API response's `number` field, not the local counter; BLOCKED outcome and renumber/migrate repair documented.
- VbC assertion: SC-1 through SC-11 all carry verdicts with evidence-type-matched artifacts.

---

# Post-Implementation (once per plan — executes after Phase 9)

- [ ] 1. Audit — adversarial audit of the deliverable. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-audit-*`.
  - Dispatch: `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read audit/tasks/verification-audit-investigator.md first")` with context: issue 2429, plan `.opencode/.issues/2429/plan.md`, spec `.opencode/.issues/2429/spec.md`.
  - Then dispatch in sequence (each a separate single-dispatch step): validator → evaluator → arbiter using the corresponding `audit/tasks/verification-audit-*.md` task cards.
  - Semantic-preservation audit focus (R-6): compare moved sections against destinations — same requirements, forbiddances, and mandates; block on doubt (fail-fast). Scope-H audit focus: create.md restructure preserves the create task's other steps (entry/exit criteria, artifact copy, reconcile-push handoff) unchanged.
- [ ] 2. Z3 check — run the constraint solver verification of the dependency contract. (**inline**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-z3-check-*`.
  - Run: `.opencode/tools/solve model --contract-path .opencode/.issues/2429/dependency-contract.yaml --query "z3.And(phase1_done, phase2_done, phase3_done, phase4_done, phase5_done, phase6_done, phase7_done, phase8_done, phase9_done)"` — expected SAT (goal reachability authority, per the documented solve-output precedent).
  - Run: `.opencode/tools/solve check --state-path .opencode/.issues/2429/artifacts/state-z3-goal.yaml --contract-path .opencode/.issues/2429/dependency-contract.yaml` — interpret per the solve-output caveat (goal-state UNSAT from precondition conflict is expected; reachability is proven by the model query above, not the state check).
- [ ] 3. Structural checks — run the finishing checklist. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-structural-checks-*`.
  - Dispatch: `task(..., prompt: "execute checklist task from finishing-a-development-branch")` with context: branch feature/2402-finishing-checklist-trailer-remediation, lint gates (pymarkdownlnt scan + mdformat --check, advisory read-only) on all modified guideline files.
- [ ] 4. Pre-PR gate — verify all SC verdicts before PR creation. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-pre-pr-gate-*`.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")` with context: read all eleven SC verdicts from the phase evidence artifacts — BLOCK if any verdict is FAIL or any evidence type mismatches its SC declaration; DONE_WITH_CONCERNS coerces to FAIL per the workflow coercion rules; SC-10's verdict MUST carry monitoring evidence (poll log or semantic diagnosis) alongside session.yaml; SC-11's verdict MUST carry create.md read-back plus the fixture scenario script result.
- [ ] 5. Regression check — final regression run before PR. (**clean-room**)
  - Pre-clean: `rm -f tmp/2429/artifacts/pipeline-regression-check-*`.
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")` with context: full scope-limited regression set for the touched files: silent-halt-with-search, read-secrets-in-output, pipeline-scoped-halt via test-enforcement.sh; 2429-sc1, 2429-sc2 new scenarios; 2243-sc1, 2249-sc6, 2249-sc7 pair; 2131-series; 2429-sc11 fixture script; 2241-sc6 spec-creation create-path scenario; SC-10 monitored-run evidence confirmed on disk — all PASS.
- [ ] 6. Review-prep — prepare PR review context. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute review-prep from git-workflow-pr. Read git-workflow-pr/tasks/review-prep.md first")` with context: stacked PR strategy, nine commits on feature/2402-finishing-checklist-trailer-remediation (items 6–7 conditional no-op commits and items 9–10 evidence-only excluded; the scope-G GREEN landed as commit 4989ffb5; historical commit messages keep #2427 — immutable history).
- [ ] 7. Create PR — create the pull request. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute create task from git-workflow-pr")` with context: one stacked PR from feature/2402-finishing-checklist-trailer-remediation; squash to exactly one commit per issue at PR creation; co-author trailers added at squash time. HALT after PR creation — the agent does not merge (human-only merge).
- [ ] 8. Executive summary — generate the completion summary. (**clean-room**)
  - Dispatch: `task(..., prompt: "execute completion task from completion-core")` with context: issue 2429, SC verdict table, artifact paths.

### Final Completion Block

- VbC assertion: all eleven SC verdicts PASS with evidence-type-matched artifacts; audit, z3-check, structural checks, pre-PR gate, and regression check all PASS.
- VbC assertion: the plan's exit criteria C1 through C9 are each satisfied with evidence on disk.
- Completion: PR created per stacked strategy; report once; HALT.

---

*Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)*