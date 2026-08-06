# Phase 2 — Local-first label reads

**Concern:** Establish local `{issues_prefix}/{N}/issue.yaml` as the default read source for authorization labels across the five label-reading task files, with remote read only as fallback or when explicitly requested.

**Files:**
- `.opencode/skills/writing-plans/tasks/handoff.md`
- `.opencode/skills/issue-operations-core/tasks/read-labels.md`
- `.opencode/skills/issue-review/tasks/gather.md`
- `.opencode/skills/audit/tasks/drift-detection-investigator.md`
- `.opencode/skills/verification-before-completion/tasks/operating-protocol.md`

**SCs:** SC-1, SC-9, SC-12, SC-13, SC-14

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: local-first label writes established
- Phase 1 VbC passed
- The `writing-plans/tasks/analyze.md` reference pattern (reads auth from local issue.yaml labels field) is available

**Exit Conditions:**
- All five label-reading task files read authorization labels from local `issue.yaml` by default
- Remote API reads occur only as fallback or when explicitly requested

---

## Code Path Coverage

| SC | Code Path |
|----|-----------|
| SC-1 | writing-plans pipeline → handoff → auth read from local issue.yaml (no remote API dependency) |
| SC-9 | issue-operations-core → read-labels → local issue.yaml read (default) → remote explicit only |
| SC-12 | issue-review → gather → local issue.yaml read (primary) → remote fallback only |
| SC-13 | audit → drift-detection → local issue.yaml read (primary) → remote fallback only |
| SC-14 | verification-before-completion → operating-protocol → local issue.yaml read (primary) → remote fallback only |

## Cross-Cutting SCs

No SC in this phase spans multiple concern categories. Each SC is confined to a single task file and the `CONCERN_LOCAL_READ` concern. `gather.md`, `drift-detection-investigator.md`, and `operating-protocol.md` each also carry a removal SC (SC-18, SC-15, SC-17 respectively) sequenced in Phase 5 to avoid same-file edit conflicts.

## Interface Boundaries

- `handoff.md → approval-gate --task verify-authorization` — BREAKING: the subcommand call is removed; handoff reads auth directly from local `issue.yaml`. Auth verification intent preserved via local read.
- `local-issues read-labels` — BACKWARD-COMPATIBLE; tool already supports the subcommand.
- `issue.yaml` labels field → authorization state — BACKWARD-COMPATIBLE; absence of labels = `needs-approval`.
- `writing-plans/tasks/analyze.md` — reference pattern, unchanged.

## State Transitions

| SC | From | To |
|----|------|----|
| SC-1 | handoff delegates auth verification to `approval-gate --task verify-authorization` (reads remote labels) | handoff reads authorization from local `issue.yaml` directly |
| SC-9 | read-labels reads labels from remote API by default | read-labels reads from local `issue.yaml` by default; remote only when explicitly requested |
| SC-12 | gather reads labels from remote API | gather reads from local `issue.yaml`; remote fallback only |
| SC-13 | drift-detection reads labels from remote API | drift-detection reads from local `issue.yaml`; remote fallback only |
| SC-14 | operating-protocol reads labels from remote API | operating-protocol reads from local `issue.yaml`; remote fallback only |

**Cost frame:** Verifying each local-first label read costs one clean-room sub-agent read of the task file. Skipping means every label read still hits remote API — multiplying remote dependency across every authorization check, so a network failure or rate-limit during any read blocks the pipeline.

---

- [ ] 28. **RED (**sub-agent**).** Write a failing behavioral enforcement test that verifies `writing-plans/tasks/handoff.md` reads authorization from local `issue.yaml` instead of calling `approval-gate --task verify-authorization`. The test FAILS because the file currently delegates to the subcommand (reads remote labels). **→ SC-1**
  - Dispatch via `task(..., prompt: "execute red task from test-driven-development")`
  - Clean up `tmp/2241/artifacts/pipeline-red-*` before running
- [ ] 29. **GREEN (**sub-agent**).** Modify `handoff.md` to read authorization from local `{issues_prefix}/{N}/issue.yaml` directly via `local-issues read-labels`, removing the `approval-gate --task verify-authorization` call. **→ SC-1**
  - Dispatch via `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 30. **Verify (**clean-room**).** Clean-room sub-agent reads `handoff.md` and evaluates whether auth is read from local `issue.yaml`. **→ SC-1**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
  - Clean up `tmp/2241/artifacts/pipeline-verify-*` before running
- [ ] 31. **Checkpoint commit (**inline**).** Commit `handoff.md` together with the behavioral test as one atomic slice. **→ SC-1**

- [ ] 32. **RED (**sub-agent**).** Write a failing behavioral enforcement test that verifies `read-labels.md` reads labels from local `issue.yaml` by default. The test FAILS because the file currently reads from remote API by default. **→ SC-9**
  - Dispatch via `task(..., prompt: "execute red task from test-driven-development")`
  - Clean up `tmp/2241/artifacts/pipeline-red-*` before running
- [ ] 33. **GREEN (**sub-agent**).** Modify `read-labels.md` to read from local `issue.yaml` by default; remote read only when explicitly requested. **→ SC-9**
  - Dispatch via `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 34. **Verify (**clean-room**).** Clean-room sub-agent reads `read-labels.md` and evaluates whether local read is default. **→ SC-9**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 35. **Checkpoint commit (**inline**).** Commit `read-labels.md` together with the behavioral test as one atomic slice. **→ SC-9**

- [ ] 36. **RED (**sub-agent**).** Write a failing behavioral enforcement test that verifies `issue-review/tasks/gather.md` reads labels from local `issue.yaml` as primary. The test FAILS because the file currently reads from remote API. **→ SC-12**
  - Dispatch via `task(..., prompt: "execute red task from test-driven-development")`
  - Clean up `tmp/2241/artifacts/pipeline-red-*` before running
- [ ] 37. **GREEN (**sub-agent**).** Modify `gather.md` to read labels from local `issue.yaml` as primary; remote fallback only. **→ SC-12**
  - Dispatch via `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 38. **Verify (**clean-room**).** Clean-room sub-agent reads `gather.md` and evaluates whether local read is primary. **→ SC-12**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 39. **Checkpoint commit (**inline**).** Commit `gather.md` together with the behavioral test as one atomic slice. **→ SC-12**

- [ ] 40. **RED (**sub-agent**).** Write a failing behavioral enforcement test that verifies `audit/tasks/drift-detection-investigator.md` reads labels from local `issue.yaml` as primary. The test FAILS because the file currently reads from remote API. **→ SC-13**
  - Dispatch via `task(..., prompt: "execute red task from test-driven-development")`
  - Clean up `tmp/2241/artifacts/pipeline-red-*` before running
- [ ] 41. **GREEN (**sub-agent**).** Modify `drift-detection-investigator.md` to read labels from local `issue.yaml` as primary; remote fallback only. **→ SC-13**
  - Dispatch via `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 42. **Verify (**clean-room**).** Clean-room sub-agent reads `drift-detection-investigator.md` and evaluates whether local read is primary. **→ SC-13**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 43. **Checkpoint commit (**inline**).** Commit `drift-detection-investigator.md` together with the behavioral test as one atomic slice. **→ SC-13**

- [ ] 44. **RED (**sub-agent**).** Write a failing behavioral enforcement test that verifies `verification-before-completion/tasks/operating-protocol.md` reads labels from local `issue.yaml` as primary. The test FAILS because the file currently reads from remote API. **→ SC-14**
  - Dispatch via `task(..., prompt: "execute red task from test-driven-development")`
  - Clean up `tmp/2241/artifacts/pipeline-red-*` before running
- [ ] 45. **GREEN (**sub-agent**).** Modify `operating-protocol.md` to read labels from local `issue.yaml` as primary; remote fallback only. **→ SC-14**
  - Dispatch via `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 46. **Verify (**clean-room**).** Clean-room sub-agent reads `operating-protocol.md` and evaluates whether local read is primary. **→ SC-14**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 47. **Checkpoint commit (**inline**).** Commit `operating-protocol.md` together with the behavioral test as one atomic slice. **→ SC-14**

#### Phase 2 VbC

- [ ] 48. **VbC (**clean-room**).** Verify all five label-reading task files read authorization labels from local `issue.yaml` by default; remote only as fallback or when explicitly requested. **→ SC-1, SC-9, SC-12, SC-13, SC-14**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
  - All SC verdicts must be PASS; any FAIL or DONE_WITH_CONCERNS coerced to FAIL blocks the phase

**Concern transition:** Leaving local-first label reads → entering cargo-cult removal (independent), No Metadata Trust removal, and comment-scanning removal. Phase 4 and Phase 5 depend on Phase 2 establishing local `issue.yaml` as the default read source.
