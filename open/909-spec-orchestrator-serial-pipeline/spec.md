---
remote_issue: 909
remote_url: "https://github.com/michael-conrad/.opencode/issues/909"
last_sync: 2026-06-14T20:50:47Z
source: github.com
---

> **Scope revision: `.opencode#1222` (Enforcement-Gated Contract Schema) adds mandatory `gate_result`, `verifier_identity`, and `artifact_hash` fields to every per-step contract artifact in the 14-step pipeline. This spec retains the 14-step dispatch table structure and merge group ordering. The Step Contract Schema section below is updated to reference #1222's standardized format.**

STATUS: 0.6

**This is a PARENT TRACKING SPEC.** Sub-issues define each merge group. Full design details at `.issues/909/design-notes.yaml`.

**Z3-verified ordering model at `.issues/909/909-phase-contract.yaml` and `.issues/909/state-3-phase.yaml`.**
**NONE OF THIS IS IMPLEMENTED YET.** The existing `divide-and-conquer` skill remains in effect. All changes described here are pending.

## Problem

The `divide-and-conquer` skill's `assemble-work` task is dispatched as a **single sub-agent** that executes the entire implementation pipeline internally. This violates the core principle that the main orchestrator must dispatch each pipeline step as a clean-room sub-agent serially, collecting result contracts at each gate. Additionally, a sub-agent cannot dispatch sub-tasks (`task()` is an orchestrator privilege), so the monolithic pipeline-dispatch-in-one-sub-agent approach is architecturally invalid.

**Root cause:** `skill({name: "divide-and-conquer"})` → `task(subagent_type="general", prompt: "execute assemble-work task from divide-and-conquer")` hands the entire pipeline to one sub-agent, which then cannot delegate.

## Solution

Replace `divide-and-conquer` with `implementation-pipeline` — a **dispatch routing table**. The orchestrator holds a 14-step routing table and dispatches each step as a `task()` call to an **existing skill's task file**. Pipeline steps are routing metadata, not wrapper sub-agents.

## Architecture

- **14 dispatch entries** — each step label maps to an existing skill task (e.g., `red-phase` → `test-driven-development --task red`)
- **Enforcement-gated contract artifacts** per `#1222` schema: each hand-off YAML includes `gate.gate_result`, `gate.verdict_source`, `gate.artifact_hashes`, and `evidence_types[]`
- **Orchestrator holds** only `{status, artifact_path, summary}` per step — frugal YAML contracts, never full content
- **Cumulative `pipeline_state`** in each artifact for session resume
- **SC coherence gate** — dispatches to `adversarial-audit --task coherence-extraction`, which runs solve check + evidence type mismatch detection
- **Researcher skill** — dedicated card for remediation scope determination
- **Remediation routing** — orchestrator reads FAIL artifact frontmatter, dispatches researcher, routes to `remediation_steps[0].target_step`
- **Session resume** — glob + follow remediation plan or dispatch researcher
- **Cross-validate** — #932 disk-offload pattern, evidence type gate, dark pattern enforcement
- **Z3 tooling** (#872) — `solve state init` at pre-red-baseline, `solve state update` per-step, `solve check` in coherence gate

### Dispatch Table

| Step | Dispatches To |
|------|---------------|
| `sc-coherence-gate` | `adversarial-audit --task coherence-extraction` |
| `pre-red-baseline` | `implementation-pipeline --task pre-red-baseline` (simple bash sub-agent) |
| `red-phase` | `test-driven-development --task red` |
| `red-doublecheck` | `verification-before-completion --task verify` |
| `green-phase` | `test-driven-development --task green` |
| `checkpoint-commit` | `git-workflow --task commit-prep` |
| `structural-checks` | `finishing-a-development-branch --task checklist` |
| `green-doublecheck` | `verification-before-completion --task verify` |
| `green-vbc` | `verification-before-completion --task completion` |
| `adversarial-audit` | `adversarial-audit --task spec-audit` |
| `cross-validate` | `adversarial-audit --task cross-validate` |
| `regression-check` | `test-driven-development --task patterns` (regression) |
| `review-prep` | `git-workflow --task review-prep` |
| `exec-summary` | `completion-core --task completion` |

## Merge Groups (Z3-Verified Optimal Ordering)

Z3 model at `.issues/909/909-phase-contract.yaml` verified the minimum is **3 phases**. The dependency chain 915 → (912, 951) → (952, 954) forces this: 915 must land before 912/951, and 952 depends on 951 while 954 depends on 915+932+951.

State file `state-3-phase.yaml` confirms the SAT assignment below.

### Phase 1 (ALL PARALLEL — independent file scopes)
| Issue | What | Authorization |
|-------|------|---------------|
| #915 | Merge Group A: Rename + dispatch routing table + Z3 state tracking | `for_pr` needed |
| #913 | Merge Group B: Researcher skill card only | `for_pr` needed |
| #932 | Merge Group B: Auditor disk-offload + naming convention | `approved-for-pr` — READY |

### Phase 2 (depends on #915)
| Issue | What | Authorization |
|-------|------|---------------|
| #912 | Merge Group C: Coherence gate + remediation routing + behavioral tests | `for_pr` needed |
| #951 | Merge Group A-Adjacent: Solve gate integration | `for_pr` needed |

### Phase 3 (depends on #915 + #932 + #951)
| Issue | What | Authorization |
|-------|------|---------------|
| #952 | Merge Group A-Adjacent: Solve enforcement tests + docs | `for_pr` needed |
| #954 | Merge Group A-Adjacent: Skill inventory (frugal contract + solve gates) | `for_pr` needed |

## Verified Constraints

| Query | Result | Meaning |
|-------|--------|---------|
| 915/913/932 all in same phase | SAT | Independent — no mutual dependencies |
| Max 2 phases total | UNSAT | 915→951→952 forces 3 layers |
| Max 3 phases total | SAT | Minimum viable |
| 952/954 in same phase 3 | SAT | No dependency between them |

## Sub-issues

- **#872** — Z3 constraint tooling (merged)
- **#915** — Merge Group A: Rename + dispatch routing table + Z3 state tracking
- **#913** — Merge Group B: Researcher skill card (Phase 6 dropped)
- **#932** — Merge Group B: Auditor disk-offload + cross-validate revision + naming convention (merged)
- **#912** — Merge Group C: Coherence gate + remediation routing + behavioral tests
- **#951** — Merge Group A-Adjacent: Solve gate integration
- **#952** — Merge Group A-Adjacent: Solve gate enforcement tests
- **#954** — Merge Group A-Adjacent: Skill inventory

## Files Affected

Full files-affected table at `.issues/909/design-notes.yaml`.

## Related Issues

- `.opencode#1222` — Enforcement-Gated Contract Schema (adds enforcement fields to every per-step contract)

🤖 OpenCode (deepseek-v4-flash)