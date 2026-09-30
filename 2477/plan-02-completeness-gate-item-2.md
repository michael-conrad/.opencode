# Phase 2 — completeness-gate-item-2

**Concern:** schema-enumeration — Step 4 completeness gate enumerates the actual schema file set.

**Files:**
- `.opencode/skills/issue-operations-sync/tasks/import-remote.md` (modify — same file as Phase 1)

**SCs:** SC-2

**Dependencies:** Phase 1 (same-file sequential TDD; item 2 commits after item 1)

**Entry Conditions:**
- Phase 1 exit criteria met (legacy names zero; SC-1 committed)
- Work tree clean at Phase 1 commit

**Exit Conditions:**
- Positive grep for `issue.yaml`, `comments.yaml`, `links.yaml` anchored at the Step 4 completeness gate block returns matches
- Already-migrated-directory recognition present (R-3); frontmatter examples parser-valid (R-6)
- Item 2 commit exists; work tree clean

**Code Path Coverage:**
- Agent executes Step 4 completeness gate → checks recognized-complete file set. Path grounded by tool read/list commands reading issue.yaml + comments.yaml + links.yaml. Change: gate enumerates actual schema; recognizes already-migrated directories (SC-2).

**Cross-Cutting SCs:**
- None — SC-2 spans one concern (completeness gate block only; evidence-table legacy removal carried by SC-1 card-wide grep per one-target reduction).

**Interface Boundaries:**
- Task-card contract ↔ local-issues tool schema: card's enumerated mirror file set must equal YAML_FILES + MARKDOWN_FILES (issue.yaml, comments.yaml, links.yaml, spec.md). Verdict after this phase: aligned.

**State Transitions:**
- Mirror directory: legacy or absent → new-schema-complete via card-guided import; already-migrated directories recognized complete (no demotion). Empty/missing `comments.yaml` still materialized with empty `comments:` list.

**Step-by-step:**

- [ ] 10. (**task-card**) Pre-regression — dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`, context: run regression test patterns before RED phase; pre-clean `tmp/2477/artifacts/pipeline-pre-regression-*`.
  - SC reference: SC-2
- [ ] 11. (**task-card**) Pre-regression verify — dispatch `task(..., prompt: "execute verify task from verification-before-completion")` against pre-regression results; pre-clean `pipeline-pre-regression-verify-*`.
  - SC reference: SC-2
- [ ] 12. (**task-card**) RED — dispatch `task(..., prompt: "execute red task from test-driven-development")`, context: run the SC-2 positive grep for `issue.yaml`/`comments.yaml`/`links.yaml` anchored at the Step 4 completeness gate block; the test FAILS because the gate references legacy or absent schema (no matches). Pre-clean `pipeline-red-*`.
  - SC reference: SC-2
- [ ] 13. (**task-card**) GREEN — dispatch `task(..., prompt: "execute green task from test-driven-development")`, context: rewrite the Step 4 completeness gate to enumerate the actual schema file set (`issue.yaml`, `comments.yaml`, `links.yaml` [+ `spec.md`]) as the recognized-complete file set and recognize already-migrated directories per R-3; ensure frontmatter examples remain parser-valid per R-6. What must be true: positive grep at the gate-anchored block returns matches. Minimum change only — no Step 7 counter rewrite here (Phase 3). Pre-clean `pipeline-green-*`.
  - SC reference: SC-2
- [ ] 14. (**task-card**) Post-regression — dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`, context: run regression test patterns after GREEN; pre-clean `pipeline-post-regression-*`.
  - SC reference: SC-2
- [ ] 15. (**task-card**) Verify — dispatch `task(..., prompt: "execute verify task from verification-before-completion")`, context: verify SC-2 — positive grep for `issue.yaml`, `comments.yaml`, `links.yaml` anchored at the Step 4 completeness gate block returns matches; read-back confirms the comment-import instruction into `comments.yaml` list format (R-2 positive verification) and the YAML frontmatter example preserved against the parser's tolerated key set (R-6 positive verification). Pre-clean `pipeline-verify-*`.
  - SC reference: SC-2
- [ ] 16. (**direct**) Commit-inline — orchestrator runs `git add .opencode/skills/issue-operations-sync/tasks/import-remote.md && git commit -m "fix(sync): enumerate actual schema in import-remote completeness gate (SC-2)"` — no sub-agent dispatch.
  - SC reference: SC-2

**Phase completion block (VbC assertions):**
- SC-2 verdict: PASS with string evidence (gate-anchored positive grep matches; read-back for R-2/R-6)
- Daisy chain: item 2 commit exists and is the precondition for Phase 3's RED

**Cost frame:** Running the completeness-gate positive grep and gate rewrite costs minutes of bounded execution time — the defect (a completeness gate demanding nonexistent or legacy schema files) is caught at this gate before the next import halts or skips verification. Skipping this verification costs days-to-weeks of defect-discovery latency — the gate either fails spuriously on correctly imported directories (blocking re-imports for no reason) or passes on a mirror missing required files, and the defect surfaces only when a downstream reader consumes an incomplete mirror (100×–1000× tier). Correctness is the only metric.

**Concern transition:** to Phase 3 (counter-write-validation) — Step 7 counter procedure rewrite; Phase 2's commit is the precondition for Phase 3's RED.