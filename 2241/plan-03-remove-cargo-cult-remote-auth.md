# Phase 3 — Remove cargo-cult remote auth from list/search

**Concern:** Remove cargo-cult remote authorization references from the issue listing and search use cases.

**Files:**
- `.opencode/skills/issue-operations-core/tasks/list-issues.md`
- `.opencode/skills/issue-operations-core/tasks/search-issues.md`

**SCs:** SC-10, SC-11

**Dependencies:** None (independent phase)

**Entry Conditions:**
- Spec #2241 approved
- Feature branch exists on `$DEFAULT_BRANCH` in the `.opencode` submodule
- Pre-implementation steps (coherence gate, baseline check) complete and PASS

**Exit Conditions:**
- `list-issues.md` no longer lists "Authorization scope label verification" as a use case
- `search-issues.md` no longer lists "Authorization scope label search" as a use case

---

## Code Path Coverage

| SC | Code Path |
|----|-----------|
| SC-10 | issue-operations-core → list-issues → use cases (no remote auth label verification) |
| SC-11 | issue-operations-core → search-issues → use cases (no remote auth label search) |

## Cross-Cutting SCs

No cross-cutting SCs. Each SC is confined to a single task file and the `CONCERN_CARGO_CULT` concern.

## Interface Boundaries

No interface changes. These are use-case documentation removals; the `local-issues` tool and `issue.yaml` format are untouched.

## State Transitions

| SC | From | To |
|----|------|----|
| SC-10 | `list-issues.md` lists "Authorization scope label verification" | `list-issues.md` no longer contains "Authorization scope label verification" |
| SC-11 | `search-issues.md` lists "Authorization scope label search" | `search-issues.md` no longer contains "Authorization scope label search" |

**Cost frame:** Verifying each cargo-cult removal costs one grep search of the task file. Skipping means the next agent reads "auth scope label verification"/"auth scope label search" and tries to use remote issue lists and search for authorization — a cargo-cult pattern that propagates remote-API auth dependency.

---

- [ ] 49. **RED (**sub-agent**).** Run a grep assertion that `list-issues.md` currently contains "Authorization scope label". The assertion SHALL match (RED state) because the cargo-cult line is present. **→ SC-10**
  - Dispatch via `task(..., prompt: "execute red task from test-driven-development")`
  - Clean up `tmp/2241/artifacts/pipeline-red-*` before running
- [ ] 50. **GREEN (**sub-agent**).** Remove the "Authorization scope label verification" use case line from `list-issues.md`. **→ SC-10**
  - Dispatch via `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 51. **Verify (**clean-room**).** Grep `list-issues.md` for "Authorization scope label" — SHALL return no matches. **→ SC-10**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
  - Clean up `tmp/2241/artifacts/pipeline-verify-*` before running
- [ ] 52. **Checkpoint commit (**inline**).** Commit `list-issues.md`. **→ SC-10**

- [ ] 53. **RED (**sub-agent**).** Run a grep assertion that `search-issues.md` currently contains "Authorization scope label". The assertion SHALL match (RED state) because the cargo-cult line is present. **→ SC-11**
  - Dispatch via `task(..., prompt: "execute red task from test-driven-development")`
  - Clean up `tmp/2241/artifacts/pipeline-red-*` before running
- [ ] 54. **GREEN (**sub-agent**).** Remove the "Authorization scope label search" use case line from `search-issues.md`. **→ SC-11**
  - Dispatch via `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 55. **Verify (**clean-room**).** Grep `search-issues.md` for "Authorization scope label" — SHALL return no matches. **→ SC-11**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 56. **Checkpoint commit (**inline**).** Commit `search-issues.md`. **→ SC-11**

#### Phase 3 VbC

- [ ] 57. **VbC (**clean-room**).** Verify `list-issues.md` and `search-issues.md` contain no "Authorization scope label" use case. **→ SC-10, SC-11**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
  - All SC verdicts must be PASS; any FAIL or DONE_WITH_CONCERNS coerced to FAIL blocks the phase

**Concern transition:** Leaving cargo-cult removal → entering No Metadata Trust doctrine removal. Phase 3 is independent; no phase depends on it.
