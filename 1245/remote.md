---
remote_issue: 1245
remote_url: "https://github.com/michael-conrad/.opencode/issues/1245"
last_sync: "2026-06-16T15:24:57Z"
source: github
---

## SPEC-FIX: pipeline-executor Duplicated Step Table

### Problem

`pipeline-executor.md` maintains its own 14-step dispatch table duplicated from SKILL.md's 16-step canonical routing table. The executor has drifted — missing `post-red-enforcement` and `post-green-enforcement`, which the SKILL.md table defines. This has downstream consequences:

| Source | Steps Declared | Status |
|--------|---------------|--------|
| `skills/implementation-pipeline/SKILL.md` §Dispatch Routing Table | 16 (canonical) | Authoritative |
| `skills/implementation-pipeline/tasks/pipeline-executor.md` §14-Step Dispatch Table | 14 | **Stale** — missing G5, G7 |
| `skills/implementation-pipeline/pipeline-state-machine.yaml` | 14 | **Stale** — missing step labels + transition rules for G5, G7 |

The Z3 state machine contract (`pipeline-state-machine.yaml`) cannot validate transitions through `post-red-enforcement` and `post-green-enforcement` because those labels are absent from its `current_step.domain` and `previous_step.domain`, and no Z3 `Implies` rules reference them. Any pipeline run using the full 16-step dispatch will fail Z3 validation at step G5.

### Root Cause

Duplication. The executor's step table is a structural copy of SKILL.md's routing table. Duplicates drift — they are maintained in parallel and decay independently. The fix is to **eliminate the duplicate** and mandate the executor reads step definitions from SKILL.md, the single authoritative source.

### Fix

#### Fix 1: Remove duplicated step table from pipeline-executor.md

Delete the §14-Step Dispatch Table (lines 28-43) from `skills/implementation-pipeline/tasks/pipeline-executor.md`. Replace it with a mandate clause:

> **Step definitions are read from `skills/implementation-pipeline/SKILL.md` §Dispatch Routing Table at runtime.** This file does not maintain a duplicate step list. The orchestrator iterates the canonical step list from SKILL.md, dispatches each step via `task()`, and logs artifacts per the Z3 state integration and YAML artifact format below.

The executor retains: entry criteria, Z3 state integration, rollback protocol, remediation routing, YAML artifact format, and post-step checkpoint creation — all the *runtime behavior* that is not a step list.

#### Fix 2: Add missing steps to pipeline-state-machine.yaml

Add `post-red-enforcement` and `post-green-enforcement` to `current_step.domain` and `previous_step.domain`.

Add Z3 transition rules, splitting the current monolithic transitions:

**Current (stale):**
```yaml
- "z3.Implies(previous_step == z3.StringVal('red-doublecheck'), z3.Or(current_step == z3.StringVal('green-phase'), current_step == z3.StringVal('red-phase')))"
- "z3.Implies(previous_step == z3.StringVal('green-phase'), current_step == z3.StringVal('checkpoint-commit'))"
```

**Replacement:**
```yaml
- "z3.Implies(previous_step == z3.StringVal('red-doublecheck'), z3.Or(current_step == z3.StringVal('post-red-enforcement'), current_step == z3.StringVal('red-phase')))"
- "z3.Implies(previous_step == z3.StringVal('post-red-enforcement'), z3.Or(current_step == z3.StringVal('green-phase'), current_step == z3.StringVal('red-phase')))"
- "z3.Implies(previous_step == z3.StringVal('green-phase'), z3.Or(current_step == z3.StringVal('post-green-enforcement'), current_step == z3.StringVal('green-phase')))"
- "z3.Implies(previous_step == z3.StringVal('post-green-enforcement'), z3.Or(current_step == z3.StringVal('checkpoint-commit'), current_step == z3.StringVal('green-phase')))"
```

#### Fix 3: SKILL.md is authoritative — no other changes required

SKILL.md already has the canonical 16-step routing table with `post-red-enforcement` and `post-green-enforcement` correctly defined. No changes needed to SKILL.md.

### State Machine Contract Diagram (Z3 transition rules, post-fix)

```
init → pre-red-baseline → sc-coherence-gate → red-phase → red-doublecheck
                                                              ↓
                                         post-red-enforcement
                                                      ↓
                                                 green-phase
                                                      ↓
                                          post-green-enforcement
                                                      ↓
                                              checkpoint-commit → structural-checks → green-doublecheck → green-vbc → adversarial-audit → cross-validate → regression-check → review-prep → exec-summary

Each step has a remediation back-edge to its own or prior step (e.g., post-red-enforcement → red-phase). The inclusion of G5 and G7 now matches the canonical 16-step routing table.
```

### Phases

This is a single-phase fix. All three targets (pipeline-executor.md, pipeline-state-machine.yaml, behavioral test) are independent edits to different files. Phase order:

| Item | Concern | SCs | Dependencies |
|------|---------|-----|--------------|
| 1.1 | Remove duplicated step table from pipeline-executor.md | SC-1 | None |
| 1.2 | Add post-red-enforcement, post-green-enforcement to state machine | SC-2, SC-3 | None |
| 1.3 | Behavioral test: agent reads SKILL.md for step definitions | SC-4 | 1.1, 1.2 (test must validate fixed state) |

### Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `pipeline-executor.md` has no hardcoded step dispatch table (no `## 14-Step Dispatch Table` or equivalent with `| Step # | Step Label | Dispatches To |` header) | `string` | `grep '##.*Step.*Dispatch' pipeline-executor.md` returns no match |
| SC-2 | `pipeline-state-machine.yaml` `current_step.domain` includes `post-red-enforcement` and `post-green-enforcement` | `string` | `grep 'post-red-enforcement' pipeline-state-machine.yaml` + `grep 'post-green-enforcement' pipeline-state-machine.yaml` both return matches |
| SC-3 | `pipeline-state-machine.yaml` has Z3 `Implies` rules for transitions entering and exiting `post-red-enforcement` and `post-green-enforcement` | `string` | `grep 'Implies.*post-red-enforcement' pipeline-state-machine.yaml` returns 2 matches (enter + exit); same for `post-green-enforcement` |
| SC-4 | Pipeline orchestrator reads step definitions from SKILL.md §Dispatch Routing Table, not from `pipeline-executor.md` | `behavioral` | `opencode-cli run` with implementation pipeline prompt → clean-room semantic inspector confirms orchestrator reads SKILL.md for step list; no direct dispatch-table read of executor.md |

### Labels

- `spec-fix`
- `needs-approval`

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)