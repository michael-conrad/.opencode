# Task: assemble-work

Assembly IS verification-enforced completion. Every implementation step requires a verification gate as preceding condition. No valid completion state exists without a verification gate.

## Purpose

Orchestration without verification gates produces undetected defects that compound through every downstream consumer. Every artifact assembled without an independent verification gate carries undiscoverable failures — professional engineers verify every step, amateurs trust their own work.

## Pipeline (Single Branch, Dependency Order)

Issues are processed in dependency order — an issue whose dependencies haven't completed waits. All issues share one feature branch. Per-issue commits via git-workflow.

```
Authorization received (#N)
│
├─ 1. git-workflow --task pre-work
│     Create ONE feature branch from dev
│
├─ 2. approval-gate --task pre-implementation-analysis
│     Screen issues, reconcile, dependency graph, write work state
│
├─ 3. FOR EACH issue in dependency order:
│     │
│     ├─ 3a. task() → RED sub-agent
│     │     Write tests only, return result contract
│     │
│     ├─ 3b. completeness-gate --task check (RED)
│     │     Structural pre-check: files exist, tests compile, SCs covered
│     │
│     ├─ 3c. task() → verification-before-completion sub-agent (RED deliverable)
│     │     Verify tests against spec success criteria (clean-room)
│     │
│     ├─ 3d. task() → adversarial-audit (RED deliverable)
│     │     Dual cross-family audit of test quality and spec coverage
│     │
│     ├─ 3e. task() → GREEN sub-agent
│     │     Implement code only, return result contract
│     │
│     ├─ 3f. completeness-gate --task check (GREEN)
│     │     Structural pre-check: files exist, code compiles, no missing artifacts
│     │
│     ├─ 3g. task() → verification-before-completion sub-agent (GREEN deliverable)
│     │     Verify implementation against spec success criteria (clean-room)
│     │
│     ├─ 3h. task() → adversarial-audit (GREEN deliverable)
│     │     Dual cross-family audit of implementation quality
│     │
│     └─ 3i. git-workflow --task implementation
│           WIP checkpoint commit per issue on shared branch
│
├─ 4. finishing-a-development-branch --task checklist
│     Lint, typecheck, structural final checks
│
├─ 5. git-workflow --task review-prep
│     Commit-prep analysis, push, compare URL
│
└─ 6. HALT with results
      Executive summary + compare URL in chat
```

After explicit "create a PR" from developer:

```
├─ 7. git-workflow --task completion
│   └─ pr-creation-workflow
```

## Verification Layers (per issue)

Verification quality is the only success metric. Every verification layer must produce clean PASS — no third category exists. See `000-critical-rules.md` §critical-rules-hard-fail.

| Layer | What | Why | Dispatch |
|-------|------|-----|----------|
| Completeness gate | Structural check (exists? compiles? SCs covered?) | Cheap deterministic gate before expensive verification | Skill call |
| verification-before-completion | Verify against spec success criteria | Clean-room verification, independent from producer | task() sub-agent |
| Adversarial audit | Dual cross-family quality verification | Independent verification catches structural misses | task() sub-agent |

## Result Contract Schema

Every sub-agent MUST return a result contract with:

| Field | Required | Description |
|-------|----------|-------------|
| `status` | Yes | `DONE \| DONE_WITH_CONCERNS \| BLOCKED \| OVERFLOW \| FAIL` |
| `task` | Yes | Task identifier |
| `concerns` | If DONE_WITH_CONCERNS | List of non-blocking issues |
| `blocker` | If BLOCKED | What prevented completion |
| `evidence` | Yes | Tool-call artifacts proving the result |

### Status Classification

| Status | Meaning | Orchestrator Action |
|--------|---------|---------------------|
| `DONE` | All sub-tasks completed successfully | Record result, proceed to next step |
| `DONE_WITH_CONCERNS` | Completed but with warnings | Record concerns in work state, proceed |
| `BLOCKED` | Cannot proceed due to external dependency | HALT, report blocker in chat |
| `OVERFLOW` | Context window exceeded | Initiate overflow recovery per `enforcement/overflow-signal.md` |
| `FAIL` | Sub-agent returned FAIL status | Initiate Verify-Before-Acceptance protocol |

### Verify-Before-Acceptance Protocol (FAIL status)

Orchestration without independent failure verification means accepting unconfirmed failures. Professional orchestrators independently reproduce failures before accepting them.

1. Independently reproduce the failure — run the same verification command or assertion
2. If reproduction confirms FAIL: re-dispatch with remediation instructions including failure evidence
3. If reproduction shows PASS: discard the sub-agent result, re-task clean-room
4. Double-verify after remediation: re-run verification on remediated result
5. Double-failure: HALT and report blocker with both failure artifacts

Max 3 remediation attempts before escalating to developer.

## Dispatch Method Rationale

| Work type | Dispatch method | Why |
|-----------|----------------|-----|
| Creative work (RED, GREEN) | task() sub-agent | Clean context, scoped, no contamination |
| Verification (verification-before-completion) | task() sub-agent | Different agent than producer — clean-room separation |
| Quality verification (adversarial audit) | task() sub-agent | Dual cross-family, independent from producer and VbC |
| Structural check (completeness-gate) | Skill call | Deterministic, no judgment, no contamination risk |
| Git operations (commit, push, branch) | git-workflow skill | Complete git workflow, not raw git commands |
| Routing (which issue next, record results) | Orchestrator | Requires work state, must happen in sequence |

## How-to Guidance

Each verification layer runs independently — the implementing agent determines the specific assertions and evidence collection by reading the spec success criteria and the verification skill documentation.

Every sub-agent dispatch includes `authorization_scope`, `halt_at`, and `must_receive` in the task context. Omitting any required field is a context-contamination violation per `000-critical-rules.md`.

Git operations are delegated to git-workflow skill entirely. The orchestrator never invokes raw git commands — git-workflow enforces hooks, state verification, and conflict resolution.

Dependency-ordered iteration means issues whose dependencies are satisfied go next. All dependencies must reach DONE before an issue starts its RED phase.

## Enforcement

- No approval → HALT (approval-gate blocks)
- Placeholders in plan → HALT (writing-plans blocks)
- No feature branch → HALT (git-workflow creates)
- Sub-agent BLOCKED → remediate or HALT (max 3 attempts)
- Sub-agent OVERFLOW → re-dispatch with reduced scope per `enforcement/overflow-signal.md`
- Sub-agent FAIL → Verify-Before-Acceptance protocol
- Orchestrator inline work → poison recovery per `000-critical-rules.md` §critical-rules-009

## Overflows

See `enforcement/overflow-signal.md` for OVERFLOW contract and re-dispatch strategies.

## Work State

See `enforcement/work-state-verification.md` for work state format and verification table schema.