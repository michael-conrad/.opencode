# Phase 3 — counter-validation-item-3

**Concern:** counter-write-validation — Step 7 presents the single named counter-write validation procedure.

**Files:**
- `.opencode/skills/issue-operations-sync/tasks/import-remote.md` (modify — same file as Phases 1–2)

**SCs:** SC-3

**Dependencies:** Phase 2 (same-file sequential TDD; item 3 commits after item 2)

**Entry Conditions:**
- Phase 2 exit criteria met (gate enumerates actual schema; SC-2 committed)
- Work tree clean at Phase 2 commit

**Exit Conditions:**
- Read of revised Step 7 confirms the named counter-write validation procedure (read `.counter`, digit-parse check, successor write satisfying monotonic invariant counter after write >= remote_number + 1) present as the SOLE documented mechanism, citing `_next_number` semantics
- No bare unvalidated echo-style counter write present
- Item 3 commit exists; work tree clean

**Code Path Coverage:**
- Agent executes Step 7 → `.counter` advancement. Path grounded by `local-issues` `_next_number` fail-fast digit-parse semantics. Change: single named counter-write validation procedure (read, digit-parse check, monotonic successor write) (SC-3).

**Cross-Cutting SCs:**
- None — SC-3 spans one concern (Step 7 plus referencing edge-case/verification rows).

**Interface Boundaries:**
- Task-card counter instruction ↔ `_next_number` semantics: documented write must satisfy digit-parse + monotonic invariant (counter after write >= remote_number + 1). Verdict after this phase: aligned.

**State Transitions:**
- `.counter`: current integer string, digits only → read verified via digit-parse (consistent with `_next_number`) → write successor value satisfying monotonic invariant. Invalid states: non-digit content, values < remote_number + 1, blind unvalidated echo writes — failure mode is tool fail-fast at next create; validation happens at write time.

**Step-by-step:**

- [ ] 17. (**task-card**) Pre-regression — dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`, context: run regression test patterns before RED phase; pre-clean `tmp/2477/artifacts/pipeline-pre-regression-*`.
  - SC reference: SC-3
- [ ] 18. (**task-card**) Pre-regression verify — dispatch `task(..., prompt: "execute verify task from verification-before-completion")` against pre-regression results; pre-clean `pipeline-pre-regression-verify-*`.
  - SC reference: SC-3
- [ ] 19. (**task-card**) RED — dispatch `task(..., prompt: "execute red task from test-driven-development")`, context: read Step 7 of the card; the test FAILS because a bare `echo $((N+1)) > .counter`-style unvalidated write instruction is present. Pre-clean `pipeline-red-*`.
  - SC reference: SC-3
- [ ] 20. (**task-card**) GREEN — dispatch `task(..., prompt: "execute green task from test-driven-development")`, context: rewrite Step 7 (and referencing edge-case/verification rows) to present the single named counter-write validation procedure from R-4 — read the current `.counter`, verify digit-parse, write the successor value satisfying the monotonic invariant (counter after write >= remote_number + 1), citing `_next_number` semantics — as the SOLE documented mechanism; no alternative mechanism offered. What must be true: read shows the named procedure present; no bare unvalidated echo-style write remains. Minimum change only. Pre-clean `pipeline-green-*`.
  - SC reference: SC-3
- [ ] 21. (**task-card**) Post-regression — dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`, context: run regression test patterns after GREEN; pre-clean `pipeline-post-regression-*`.
  - SC reference: SC-3
- [ ] 22. (**task-card**) Verify — dispatch `task(..., prompt: "execute verify task from verification-before-completion")`, context: verify SC-3 — read-back of Step 7 (single verification anchor) confirms the named counter-write validation procedure present as the sole documented mechanism citing `_next_number` semantics; grep for a bare unvalidated `echo $((...))` counter write returns no match. Pre-clean `pipeline-verify-*`.
  - SC reference: SC-3
- [ ] 23. (**direct**) Commit-inline — orchestrator runs `git add .opencode/skills/issue-operations-sync/tasks/import-remote.md && git commit -m "fix(sync): specify counter-write validation procedure in import-remote Step 7 (SC-3)"` — no sub-agent dispatch.
  - SC reference: SC-3

**Phase completion block (VbC assertions):**
- SC-3 verdict: PASS with string evidence (read-back confirmation; no bare echo write)
- Daisy chain: all three items committed; all SCs daisy-chained

**Cost frame:** Reading Step 7 and confirming the counter-write validation procedure costs one file read — a bounded, seconds-scale action cost that catches counter-corruption instructions before they are executed. Skipping this verification costs weeks of defect-discovery latency — an import bypasses the tool's fail-fast digit parse with a blind echo, silently corrupting `.counter`, and the corruption surfaces only when a later issue creation fails on a non-digit counter (1000×+ structural tier).

**Concern transition:** to post-implementation stage.

## Post-implementation steps

- [ ] 24. (**task-card**) Audit — dispatch `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")`, followed by validator, evaluator, arbiter in sequence; context: adversarial audit of the rewritten card against SC-1/SC-2/SC-3 and R-1..R-6. Pre-clean `pipeline-audit-*`.
  - SC reference: all
- [ ] 25. (**direct**) Z3 check — orchestrator runs `.opencode/tools/solve check --state-path tmp/2477/artifacts/state.yaml --contract-path tmp/2477/artifacts/dependency-contract.yaml` directly — no sub-agent dispatch; pre-clean `pipeline-z3-check-*`.
  - SC reference: none (gate)
- [ ] 26. (**task-card**) Structural checks — dispatch `task(..., prompt: "execute checklist task from finishing-a-development-branch")`, context: finishing checklist (lint — markdown lint/format checks per Build/Lint/Test Commands; typecheck not applicable to markdown-only change). Pre-clean `pipeline-structural-checks-*`.
  - SC reference: none (gate)
- [ ] 27. (**task-card**) Pre-PR gate — dispatch `task(..., prompt: "execute verify task from verification-before-completion")`, context: read all SC verdicts; BLOCKS if any FAIL — DONE_WITH_CONCERNS coerces to FAIL per implementation-workflow coercion rules. Pre-clean `pipeline-pre-pr-gate-*`.
  - SC reference: SC-1, SC-2, SC-3
- [ ] 28. (**task-card**) Regression check — dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`, context: final regression check before PR. Pre-clean `pipeline-regression-check-*`.
  - SC reference: none (gate)
- [ ] 29. (**task-card**) Review-prep — dispatch `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`, context: prepare PR review context for the stacked single-branch PR.
  - SC reference: none (gate)
- [ ] 30. (**task-card**) Create PR — dispatch `task(..., prompt: "execute create task from git-workflow-pr")`, context: squash the three implementation commits into one commit per issue at PR creation; PR targets the trunk `.opencode` repo; no merge by agent (human-only merge).
  - SC reference: none (gate)
- [ ] 31. (**task-card**) Exec summary — dispatch `task(..., prompt: "execute completion task from completion-core")`, context: generate completion executive summary; append lifecycle event `plan_created`-chain completion; chat-only report.
  - SC reference: none (gate)

## Exit Criteria

- [ ] C1. `import-remote.md` contains zero references to legacy mirror filenames (`comments.md`, `remote.md`, `state.md`) — card-wide grep returns 0 (SC-1)
- [ ] C2. Step 4 completeness gate enumerates `issue.yaml`, `comments.yaml`, `links.yaml` [+ `spec.md`] and recognizes already-migrated directories (SC-2)
- [ ] C3. Step 7 specifies the named counter-write validation procedure as the sole documented mechanism, citing `_next_number` semantics (SC-3)
- [ ] C4. Live-Verification evidence table verifies new filenames (carried by C1 card-wide grep; positive coverage via C2 read-back) (R-5)
- [ ] C5. All three SC item commits daisy-chained; pre-PR gate shows all SC verdicts PASS; PR created stacked on single branch