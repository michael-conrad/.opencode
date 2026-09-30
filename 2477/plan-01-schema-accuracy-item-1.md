# Phase 1 — schema-accuracy-item-1

**Concern:** legacy-filename-purge — eliminate every legacy mirror-filename reference in `import-remote.md`.

**Files:**
- `.opencode/skills/issue-operations-sync/tasks/import-remote.md` (modify)

**SCs:** SC-1

**Dependencies:** None

**Entry Conditions:**
- Coherence gate (plan step 1) passed; baseline check (plan step 2) passed
- Spec #2477 carries `approved-for-for_pr`; feature branch checked out
- Ground-truth constants verified (YAML_FILES / MARKDOWN_FILES unchanged)

**Exit Conditions:**
- `grep -c 'comments\.md\|remote\.md\|state\.md' .opencode/skills/issue-operations-sync/tasks/import-remote.md` returns 0
- Item 1 commit exists; work tree clean

**Code Path Coverage:**
- Agent follows import-remote card → mirror file enumeration → materializes mirror files. Path grounded by `local-issues` YAML_FILES = (issue.yaml, comments.yaml, links.yaml), MARKDOWN_FILES = (spec.md). Change: rewrite references from legacy names to schema names (SC-1).

**Cross-Cutting SCs:**
- None — SC-1 spans one concern only (per cross-cutting matrix).

**Interface Boundaries:**
- Task-card contract ↔ local-issues tool schema: card's enumerated mirror file set must equal YAML_FILES + MARKDOWN_FILES. Verdict after this phase: legacy names eliminated; full alignment completed by Phase 2.

**State Transitions:**
- Mirror directory: legacy-schema mentions in card text → new-schema references only. No store state changes (documentation-only).

**Step-by-step:**

- [ ] 3. (**task-card**) Pre-regression — dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`, context: run regression test patterns before RED phase, pre-clean `tmp/2477/artifacts/pipeline-pre-regression-*`.
  - SC reference: SC-1
- [ ] 4. (**task-card**) Pre-regression verify — dispatch `task(..., prompt: "execute verify task from verification-before-completion")` against pre-regression results, pre-clean `pipeline-pre-regression-verify-*`.
  - SC reference: SC-1
- [ ] 5. (**task-card**) RED — dispatch `task(..., prompt: "execute red task from test-driven-development")`, context: run the SC-1 grep `grep -c 'comments\.md\|remote\.md\|state\.md' .opencode/skills/issue-operations-sync/tasks/import-remote.md`; the test FAILS because legacy names are present (count > 0). Pre-clean `pipeline-red-*`.
  - SC reference: SC-1
- [ ] 6. (**task-card**) GREEN — dispatch `task(..., prompt: "execute green task from test-driven-development")`, context: replace every legacy mirror-filename reference across the card with the actual schema name (`comments.md` → `comments.yaml`; `remote.md`/`state.md` references removed or rewritten), including the Live-Verification evidence table rows (R-1, R-5). What must be true: the card-wide grep returns 0 legacy-name matches. Minimum change only — no Step 7 counter rewrite here (Phase 3), no completeness-gate rewrite here beyond legacy-name removal (Phase 2). Pre-clean `pipeline-green-*`.
  - SC reference: SC-1
- [ ] 7. (**task-card**) Post-regression — dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`, context: run regression test patterns after GREEN, pre-clean `pipeline-post-regression-*`.
  - SC reference: SC-1
- [ ] 8. (**task-card**) Verify — dispatch `task(..., prompt: "execute verify task from verification-before-completion")`, context: verify SC-1 — `grep -c 'comments\.md\|remote\.md\|state\.md' .opencode/skills/issue-operations-sync/tasks/import-remote.md` returns 0, covering every section including the Live-Verification evidence table. Pre-clean `pipeline-verify-*`.
  - SC reference: SC-1
- [ ] 9. (**direct**) Commit-inline — orchestrator runs `git add .opencode/skills/issue-operations-sync/tasks/import-remote.md && git commit -m "fix(sync): purge legacy mirror filenames from import-remote card (SC-1)"` — no sub-agent dispatch.
  - SC reference: SC-1

**Phase completion block (VbC assertions):**
- SC-1 verdict: PASS with string evidence (grep count 0)
- Daisy chain: item 1 commit exists and is the precondition for Phase 2's RED

**Cost frame:** Running the zero-legacy-name grep and the card rewrite costs minutes of bounded execution time — the defect (a sub-agent producing a tool-invisible mirror) is caught at this gate before the next import executes. Skipping this verification costs weeks-to-months of defect-discovery latency — the next import sub-agent following the card verbatim writes `comments.md` that `read-comments` cannot see, and the defect surfaces only when issue data is found missing, diagnosed across tool source, store directories, and skill cards (DEATH SPIRAL START per the string-evidence tier). Correctness is the only metric.

**Concern transition:** to Phase 2 (schema-enumeration) — completeness gate enumerates the actual schema file set; Phase 1's commit is the precondition for Phase 2's RED.