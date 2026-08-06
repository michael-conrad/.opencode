# Phase 1 — Local-first label writes

**Concern:** Establish local `{issues_prefix}/{N}/issue.yaml` as the canonical write target for all authorization labels across the six label-writing task files.

**Files:**
- `.opencode/skills/approval-gate/tasks/apply-label.md`
- `.opencode/skills/issue-operations-core/tasks/creation.md`
- `.opencode/skills/issue-operations-core/tasks/completion.md`
- `.opencode/skills/spec-creation/tasks/create.md`
- `.opencode/skills/issue-review/tasks/analyze-and-spec.md`
- `.opencode/skills/writing-plans/tasks/create.md`

**SCs:** SC-2, SC-3, SC-4, SC-6, SC-7, SC-8

**Dependencies:** None

**Entry Conditions:**
- Spec #2241 approved
- Feature branch created on `$DEFAULT_BRANCH` in the `.opencode` submodule
- Pre-implementation steps (coherence gate, baseline check) complete and PASS

**Exit Conditions:**
- All six label-writing task files write authorization labels to local `issue.yaml` as primary canonical source
- Remote API writes are best-effort/secondary and never block the pipeline

---

## Code Path Coverage

| SC | Code Path |
|----|-----------|
| SC-2 | approval-gate → apply-label → local issue.yaml write (canonical) → remote best-effort |
| SC-3 | issue-operations-core → creation → local issue.yaml write (primary) → remote best-effort |
| SC-4 | issue-operations-core → completion → local issue.yaml read (primary) → remote write best-effort |
| SC-6 | spec-creation → create → local issue.yaml write (primary) → remote secondary |
| SC-7 | issue-review → analyze-and-spec → local issue.yaml write (primary) → remote secondary |
| SC-8 | writing-plans → create → local issue.yaml write (primary) → remote secondary |

## Cross-Cutting SCs

No SC in this phase spans multiple concern categories. Each SC is confined to a single task file and the `CONCERN_LOCAL_WRITE` concern.

## Interface Boundaries

- `local-issues update --labels` — BACKWARD-COMPATIBLE; tool already supports the subcommand (spec §6 verified).
- `issue.yaml` labels field — format unchanged; labels field already exists.
- No other interface changes; `local-issues` tool itself is unchanged (only calling task files change).

## State Transitions

| SC | From | To |
|----|------|----|
| SC-2 | apply-label writes `approved-for-{scope}` to remote as canonical | apply-label writes to local `issue.yaml` as canonical; remote best-effort |
| SC-3 | creation writes `needs-approval` to remote as primary | creation writes to local `issue.yaml` as primary; remote best-effort |
| SC-4 | completion reads `needs-approval` from remote | completion reads from local `issue.yaml`; remote write best-effort |
| SC-6 | spec-creation/create writes labels to remote as primary | spec-creation/create writes to local `issue.yaml` as primary; remote secondary |
| SC-7 | analyze-and-spec writes labels to remote as primary | analyze-and-spec writes to local `issue.yaml` as primary; remote secondary |
| SC-8 | writing-plans/create writes `spec-cleared` to remote as primary | writing-plans/create writes to local `issue.yaml` as primary; remote secondary |

**Cost frame:** Verifying each local-first label write costs one clean-room sub-agent read of the task file. Skipping means the primary label-write path still targets unreliable remote API — GitBucket post-creation label failure silently drops authorization state, and a network failure during any write loses the canonical record.

---

- [ ] 3. **RED (**sub-agent**).** Write a failing behavioral enforcement test that verifies `apply-label.md` writes `approved-for-{scope}` to local `issue.yaml` as primary canonical source. The test FAILS because the file currently writes to remote as canonical. **→ SC-2**
  - Dispatch via `task(..., prompt: "execute red task from test-driven-development")`
  - Clean up `tmp/2241/artifacts/pipeline-red-*` before running
- [ ] 4. **GREEN (**sub-agent**).** Modify `apply-label.md` to write `approved-for-{scope}` to local `issue.yaml` as canonical via `local-issues update --labels`; make the remote write best-effort only. **→ SC-2**
  - Dispatch via `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 5. **Verify (**clean-room**).** Clean-room sub-agent reads `apply-label.md` and evaluates whether local write is primary. **→ SC-2**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
  - Clean up `tmp/2241/artifacts/pipeline-verify-*` before running
- [ ] 6. **Checkpoint commit (**inline**).** Commit `apply-label.md` together with the behavioral test as one atomic slice. **→ SC-2**
  - Orchestrator runs `git add` + `git commit` directly; no co-author trailers (added at squash time)

- [ ] 7. **RED (**sub-agent**).** Write a failing behavioral enforcement test that verifies `creation.md` writes `needs-approval` to local `issue.yaml` as primary. The test FAILS because the file currently writes to remote as primary. **→ SC-3**
  - Dispatch via `task(..., prompt: "execute red task from test-driven-development")`
  - Clean up `tmp/2241/artifacts/pipeline-red-*` before running
- [ ] 8. **GREEN (**sub-agent**).** Modify `creation.md` to write `needs-approval` to local `issue.yaml` as primary; make the remote write best-effort. **→ SC-3**
  - Dispatch via `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 9. **Verify (**clean-room**).** Clean-room sub-agent reads `creation.md` and evaluates whether local write is primary. **→ SC-3**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 10. **Checkpoint commit (**inline**).** Commit `creation.md` together with the behavioral test as one atomic slice. **→ SC-3**

- [ ] 11. **RED (**sub-agent**).** Write a failing behavioral enforcement test that verifies `completion.md` reads `needs-approval` from local `issue.yaml` as primary. The test FAILS because the file currently reads from remote. **→ SC-4**
  - Dispatch via `task(..., prompt: "execute red task from test-driven-development")`
  - Clean up `tmp/2241/artifacts/pipeline-red-*` before running
- [ ] 12. **GREEN (**sub-agent**).** Modify `completion.md` to read `needs-approval` from local `issue.yaml`; make the remote write best-effort. **→ SC-4**
  - Dispatch via `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 13. **Verify (**clean-room**).** Clean-room sub-agent reads `completion.md` and evaluates whether local read is primary. **→ SC-4**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 14. **Checkpoint commit (**inline**).** Commit `completion.md` together with the behavioral test as one atomic slice. **→ SC-4**

- [ ] 15. **RED (**sub-agent**).** Write a failing behavioral enforcement test that verifies `spec-creation/tasks/create.md` writes labels to local `issue.yaml` as primary. The test FAILS because the file currently writes to remote as primary. **→ SC-6**
  - Dispatch via `task(..., prompt: "execute red task from test-driven-development")`
  - Clean up `tmp/2241/artifacts/pipeline-red-*` before running
- [ ] 16. **GREEN (**sub-agent**).** Modify `spec-creation/tasks/create.md` to write labels to local `issue.yaml` as primary; remote secondary. **→ SC-6**
  - Dispatch via `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 17. **Verify (**clean-room**).** Clean-room sub-agent reads `create.md` and evaluates whether local write is primary. **→ SC-6**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 18. **Checkpoint commit (**inline**).** Commit `spec-creation/tasks/create.md` together with the behavioral test as one atomic slice. **→ SC-6**

- [ ] 19. **RED (**sub-agent**).** Write a failing behavioral enforcement test that verifies `issue-review/tasks/analyze-and-spec.md` writes labels to local `issue.yaml` as primary. The test FAILS because the file currently writes to remote as primary. **→ SC-7**
  - Dispatch via `task(..., prompt: "execute red task from test-driven-development")`
  - Clean up `tmp/2241/artifacts/pipeline-red-*` before running
- [ ] 20. **GREEN (**sub-agent**).** Modify `analyze-and-spec.md` to write labels to local `issue.yaml` as primary; remote secondary. **→ SC-7**
  - Dispatch via `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 21. **Verify (**clean-room**).** Clean-room sub-agent reads `analyze-and-spec.md` and evaluates whether local write is primary. **→ SC-7**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 22. **Checkpoint commit (**inline**).** Commit `analyze-and-spec.md` together with the behavioral test as one atomic slice. **→ SC-7**

- [ ] 23. **RED (**sub-agent**).** Write a failing behavioral enforcement test that verifies `writing-plans/tasks/create.md` writes `spec-cleared` to local `issue.yaml` as primary. The test FAILS because the file currently writes to remote as primary. **→ SC-8**
  - Dispatch via `task(..., prompt: "execute red task from test-driven-development")`
  - Clean up `tmp/2241/artifacts/pipeline-red-*` before running
- [ ] 24. **GREEN (**sub-agent**).** Modify `writing-plans/tasks/create.md` to write `spec-cleared` to local `issue.yaml` as primary; remote secondary. **→ SC-8**
  - Dispatch via `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 25. **Verify (**clean-room**).** Clean-room sub-agent reads `writing-plans/tasks/create.md` and evaluates whether local write is primary. **→ SC-8**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 26. **Checkpoint commit (**inline**).** Commit `writing-plans/tasks/create.md` together with the behavioral test as one atomic slice. **→ SC-8**

#### Phase 1 VbC

- [ ] 27. **VbC (**clean-room**).** Verify all six label-writing task files write authorization labels to local `issue.yaml` as primary canonical source; remote best-effort/secondary and non-blocking. **→ SC-2, SC-3, SC-4, SC-6, SC-7, SC-8**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
  - All SC verdicts must be PASS; any FAIL or DONE_WITH_CONCERNS coerced to FAIL blocks the phase

**Concern transition:** Leaving local-first label writes → entering local-first label reads. Phase 2 depends on Phase 1 establishing local `issue.yaml` as the canonical label source.
