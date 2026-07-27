---
plan_schema_version: "1.0"
issue: 2165
title: "Self-contained GitBucket test container for behavioral tests"
---

# Plan: Self-contained GitBucket test container for behavioral tests

## Phase Table

| Phase | SCs | Concern | Dispatch |
|-------|-----|---------|----------|
| 1 | SC-1, SC-10 | JDK provisioning + gitignore | implementation-pipeline (red-phase, green-phase, etc.) |
| 2 | SC-2, SC-10 | GitBucket JAR provisioning + gitignore | implementation-pipeline (red-phase, green-phase, etc.) |
| 3 | SC-3 | GitBucket startup and port discovery | implementation-pipeline (red-phase, green-phase, etc.) |
| 4 | SC-4 | Token generation | implementation-pipeline (red-phase, green-phase, etc.) |
| 5 | SC-5 | Test repo creation and remote wiring | implementation-pipeline (red-phase, green-phase, etc.) |
| 6 | SC-6 | Reset function | implementation-pipeline (red-phase, green-phase, etc.) |
| 7 | SC-7 | Clean-all integration | implementation-pipeline (red-phase, green-phase, etc.) |
| 8 | SC-8, SC-9 | BEHAVIOR_NEEDS_REMOTE flag + multi-test reset | implementation-pipeline (red-phase, green-phase, etc.) |
| 9 | — | Documentation | implementation-pipeline (green-phase only) |

## Exit Criteria

| SC | Phase | Criterion |
|----|-------|-----------|
| SC-1 | 1 | `__ensure_gitbucket()` provisions JDK to `.tools/jdk/` on first call |
| SC-2 | 2 | `__ensure_gitbucket()` downloads latest GitBucket WAR to `.tools/gitbucket/` on first call |
| SC-3 | 3 | GitBucket starts on auto-assigned port (`--port=0`), port discovered from log/port file |
| SC-4 | 4 | `GB_TOKEN` env var is set from admin API token generation |
| SC-5 | 5 | Test repo created on GitBucket and wired as test project's `origin` remote |
| SC-6 | 6 | `__reset_gitbucket()` kills process, deletes data dir, re-starts fresh |
| SC-7 | 7 | `with-test-home --clean-all` kills GitBucket process, preserves `.tools/` cache |
| SC-8 | 8 | Test with `BEHAVIOR_NEEDS_REMOTE=1` can create issue on GitBucket and verify labels |
| SC-9 | 8 | Multiple tests sharing GitBucket instance get clean state via reset |
| SC-10 | 1, 2 | `.tools/` cache is gitignored and not tracked |

## Pre-implementation

- [ ] **Coherence gate.** Dispatch `audit --task coherence-extraction` to verify spec/plan coherence before RED routing. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Baseline check.** Dispatch `pre-red-baseline` to verify baseline state before any RED phase. (**sub-agent**)
  - Context: `{issue_number: 2165}`

## Phase 1 — JDK provisioning + gitignore (SC-1, SC-10)

Provision Eclipse Temurin 21 JRE to `.tools/jdk/` and verify `.gitignore` entries.

### Item 1: SC-1 — `__ensure_gitbucket()` provisions JDK to `.tools/jdk/` on first call

- [ ] **RED phase.** Write a failing test that verifies `__ensure_gitbucket()` provisions JDK to `.tools/jdk/` on first call. (**sub-agent**)
  - Context: `{issue_number: 2165}`
  - SC-ID: SC-1
- [ ] **Z3 check RED.** Run `solve --task check` to validate RED state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **RED doublecheck.** Dispatch `verification-before-completion --task verify` to confirm RED test is valid. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Z3 check RED doublecheck.** Run `solve --task check` to validate RED doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **Post-RED enforcement.** Dispatch `post-red-enforcement` to enforce RED gate. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Z3 check post-RED.** Run `solve --task check` to validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **GREEN phase.** Implement `__ensure_gitbucket()` JDK provisioning logic. (**sub-agent**)
  - Context: `{issue_number: 2165}`
  - SC-ID: SC-1
- [ ] **Z3 check GREEN.** Run `solve --task check` to validate GREEN state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **Post-GREEN enforcement.** Dispatch `post-green-enforcement` to enforce GREEN gate. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Z3 check post-GREEN.** Run `solve --task check` to validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **Checkpoint tag create.** Dispatch `checkpoint-tag-create` to create checkpoint tag. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Checkpoint commit.** Dispatch `git-workflow --task commit-prep` to save checkpoint. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Structural checks.** Dispatch `finishing-a-development-branch --task checklist` for lint/typecheck. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **GREEN doublecheck.** Dispatch `verification-before-completion --task verify` to confirm GREEN implementation. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **GREEN VbC.** Dispatch `verification-before-completion --task completion` for verification before completion. (**sub-agent**)
  - Context: `{issue_number: 2165}`

### Item 2: SC-10 — `.tools/` cache is gitignored and not tracked

- [ ] **RED phase.** Write a failing test that verifies `.tools/` and `.jdk/` entries exist in `.gitignore`. (**sub-agent**)
  - Context: `{issue_number: 2165}`
  - SC-ID: SC-10
- [ ] **Z3 check RED.** Run `solve --task check` to validate RED state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **RED doublecheck.** Dispatch `verification-before-completion --task verify` to confirm RED test is valid. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Z3 check RED doublecheck.** Run `solve --task check` to validate RED doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **Post-RED enforcement.** Dispatch `post-red-enforcement` to enforce RED gate. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Z3 check post-RED.** Run `solve --task check` to validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **GREEN phase.** Add `.tools/` and `.jdk/` entries to `.opencode/.gitignore`. (**sub-agent**)
  - Context: `{issue_number: 2165}`
  - SC-ID: SC-10
- [ ] **Z3 check GREEN.** Run `solve --task check` to validate GREEN state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **Post-GREEN enforcement.** Dispatch `post-green-enforcement` to enforce GREEN gate. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Z3 check post-GREEN.** Run `solve --task check` to validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **Checkpoint tag create.** Dispatch `checkpoint-tag-create` to create checkpoint tag. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Checkpoint commit.** Dispatch `git-workflow --task commit-prep` to save checkpoint. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Structural checks.** Dispatch `finishing-a-development-branch --task checklist` for lint/typecheck. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **GREEN doublecheck.** Dispatch `verification-before-completion --task verify` to confirm GREEN implementation. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **GREEN VbC.** Dispatch `verification-before-completion --task completion` for verification before completion. (**sub-agent**)
  - Context: `{issue_number: 2165}`

## Phase 2 — GitBucket JAR provisioning + gitignore (SC-2, SC-10)

Download latest GitBucket WAR to `.tools/gitbucket/` and verify `.gitignore` entries.

### Item 1: SC-2 — `__ensure_gitbucket()` downloads latest GitBucket WAR to `.tools/gitbucket/` on first call

- [ ] **RED phase.** Write a failing test that verifies `__ensure_gitbucket()` downloads latest GitBucket WAR to `.tools/gitbucket/`. (**sub-agent**)
  - Context: `{issue_number: 2165}`
  - SC-ID: SC-2
- [ ] **Z3 check RED.** Run `solve --task check` to validate RED state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **RED doublecheck.** Dispatch `verification-before-completion --task verify` to confirm RED test is valid. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Z3 check RED doublecheck.** Run `solve --task check` to validate RED doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **Post-RED enforcement.** Dispatch `post-red-enforcement` to enforce RED gate. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Z3 check post-RED.** Run `solve --task check` to validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **GREEN phase.** Implement GitBucket WAR download logic in `__ensure_gitbucket()`. (**sub-agent**)
  - Context: `{issue_number: 2165}`
  - SC-ID: SC-2
- [ ] **Z3 check GREEN.** Run `solve --task check` to validate GREEN state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **Post-GREEN enforcement.** Dispatch `post-green-enforcement` to enforce GREEN gate. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Z3 check post-GREEN.** Run `solve --task check` to validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **Checkpoint tag create.** Dispatch `checkpoint-tag-create` to create checkpoint tag. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Checkpoint commit.** Dispatch `git-workflow --task commit-prep` to save checkpoint. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Structural checks.** Dispatch `finishing-a-development-branch --task checklist` for lint/typecheck. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **GREEN doublecheck.** Dispatch `verification-before-completion --task verify` to confirm GREEN implementation. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **GREEN VbC.** Dispatch `verification-before-completion --task completion` for verification before completion. (**sub-agent**)
  - Context: `{issue_number: 2165}`

## Phase 3 — GitBucket startup and port discovery (SC-3)

Start GitBucket on auto-assigned port (`--port=0`), discover port from log/port file.

### Item 1: SC-3 — GitBucket starts on auto-assigned port, port discovered from log/port file

- [ ] **RED phase.** Write a failing behavioral test that verifies GitBucket starts on auto-assigned port and port is discoverable. (**sub-agent**)
  - Context: `{issue_number: 2165}`
  - SC-ID: SC-3
- [ ] **Z3 check RED.** Run `solve --task check` to validate RED state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **RED doublecheck.** Dispatch `verification-before-completion --task verify` to confirm RED test is valid. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Z3 check RED doublecheck.** Run `solve --task check` to validate RED doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **Post-RED enforcement.** Dispatch `post-red-enforcement` to enforce RED gate. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Z3 check post-RED.** Run `solve --task check` to validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **GREEN phase.** Implement GitBucket startup with `--port=0` and port discovery logic. (**sub-agent**)
  - Context: `{issue_number: 2165}`
  - SC-ID: SC-3
- [ ] **Z3 check GREEN.** Run `solve --task check` to validate GREEN state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **Post-GREEN enforcement.** Dispatch `post-green-enforcement` to enforce GREEN gate. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Z3 check post-GREEN.** Run `solve --task check` to validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **Checkpoint tag create.** Dispatch `checkpoint-tag-create` to create checkpoint tag. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Checkpoint commit.** Dispatch `git-workflow --task commit-prep` to save checkpoint. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Structural checks.** Dispatch `finishing-a-development-branch --task checklist` for lint/typecheck. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **GREEN doublecheck.** Dispatch `verification-before-completion --task verify` to confirm GREEN implementation. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **GREEN VbC.** Dispatch `verification-before-completion --task completion` for verification before completion. (**sub-agent**)
  - Context: `{issue_number: 2165}`

## Phase 4 — Token generation (SC-4)

Generate `GB_TOKEN` from admin API on startup.

### Item 1: SC-4 — `GB_TOKEN` env var is set from admin API token generation

- [ ] **RED phase.** Write a failing behavioral test that verifies `GB_TOKEN` env var is set after GitBucket startup. (**sub-agent**)
  - Context: `{issue_number: 2165}`
  - SC-ID: SC-4
- [ ] **Z3 check RED.** Run `solve --task check` to validate RED state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **RED doublecheck.** Dispatch `verification-before-completion --task verify` to confirm RED test is valid. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Z3 check RED doublecheck.** Run `solve --task check` to validate RED doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **Post-RED enforcement.** Dispatch `post-red-enforcement` to enforce RED gate. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Z3 check post-RED.** Run `solve --task check` to validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **GREEN phase.** Implement token generation via admin API and `GB_TOKEN` env var export. (**sub-agent**)
  - Context: `{issue_number: 2165}`
  - SC-ID: SC-4
- [ ] **Z3 check GREEN.** Run `solve --task check` to validate GREEN state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **Post-GREEN enforcement.** Dispatch `post-green-enforcement` to enforce GREEN gate. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Z3 check post-GREEN.** Run `solve --task check` to validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **Checkpoint tag create.** Dispatch `checkpoint-tag-create` to create checkpoint tag. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Checkpoint commit.** Dispatch `git-workflow --task commit-prep` to save checkpoint. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Structural checks.** Dispatch `finishing-a-development-branch --task checklist` for lint/typecheck. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **GREEN doublecheck.** Dispatch `verification-before-completion --task verify` to confirm GREEN implementation. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **GREEN VbC.** Dispatch `verification-before-completion --task completion` for verification before completion. (**sub-agent**)
  - Context: `{issue_number: 2165}`

## Phase 5 — Test repo creation and remote wiring (SC-5)

Create test repo on GitBucket, wire as test project's `origin` remote.

### Item 1: SC-5 — Test repo created on GitBucket and wired as test project's `origin` remote

- [ ] **RED phase.** Write a failing behavioral test that verifies test repo creation and `origin` remote wiring. (**sub-agent**)
  - Context: `{issue_number: 2165}`
  - SC-ID: SC-5
- [ ] **Z3 check RED.** Run `solve --task check` to validate RED state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **RED doublecheck.** Dispatch `verification-before-completion --task verify` to confirm RED test is valid. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Z3 check RED doublecheck.** Run `solve --task check` to validate RED doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **Post-RED enforcement.** Dispatch `post-red-enforcement` to enforce RED gate. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Z3 check post-RED.** Run `solve --task check` to validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **GREEN phase.** Implement test repo creation via `gb create-repo` and `git remote add origin` wiring. (**sub-agent**)
  - Context: `{issue_number: 2165}`
  - SC-ID: SC-5
- [ ] **Z3 check GREEN.** Run `solve --task check` to validate GREEN state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **Post-GREEN enforcement.** Dispatch `post-green-enforcement` to enforce GREEN gate. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Z3 check post-GREEN.** Run `solve --task check` to validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **Checkpoint tag create.** Dispatch `checkpoint-tag-create` to create checkpoint tag. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Checkpoint commit.** Dispatch `git-workflow --task commit-prep` to save checkpoint. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Structural checks.** Dispatch `finishing-a-development-branch --task checklist` for lint/typecheck. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **GREEN doublecheck.** Dispatch `verification-before-completion --task verify` to confirm GREEN implementation. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **GREEN VbC.** Dispatch `verification-before-completion --task completion` for verification before completion. (**sub-agent**)
  - Context: `{issue_number: 2165}`

## Phase 6 — Reset function (SC-6)

Kill process, delete data dir, re-start fresh.

### Item 1: SC-6 — `__reset_gitbucket()` kills process, deletes data dir, re-starts fresh

- [ ] **RED phase.** Write a failing behavioral test that verifies `__reset_gitbucket()` kills process, deletes data dir, and re-starts. (**sub-agent**)
  - Context: `{issue_number: 2165}`
  - SC-ID: SC-6
- [ ] **Z3 check RED.** Run `solve --task check` to validate RED state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **RED doublecheck.** Dispatch `verification-before-completion --task verify` to confirm RED test is valid. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Z3 check RED doublecheck.** Run `solve --task check` to validate RED doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **Post-RED enforcement.** Dispatch `post-red-enforcement` to enforce RED gate. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Z3 check post-RED.** Run `solve --task check` to validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **GREEN phase.** Implement `__reset_gitbucket()` function. (**sub-agent**)
  - Context: `{issue_number: 2165}`
  - SC-ID: SC-6
- [ ] **Z3 check GREEN.** Run `solve --task check` to validate GREEN state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **Post-GREEN enforcement.** Dispatch `post-green-enforcement` to enforce GREEN gate. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Z3 check post-GREEN.** Run `solve --task check` to validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **Checkpoint tag create.** Dispatch `checkpoint-tag-create` to create checkpoint tag. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Checkpoint commit.** Dispatch `git-workflow --task commit-prep` to save checkpoint. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Structural checks.** Dispatch `finishing-a-development-branch --task checklist` for lint/typecheck. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **GREEN doublecheck.** Dispatch `verification-before-completion --task verify` to confirm GREEN implementation. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **GREEN VbC.** Dispatch `verification-before-completion --task completion` for verification before completion. (**sub-agent**)
  - Context: `{issue_number: 2165}`

## Phase 7 — Clean-all integration (SC-7)

`--clean-all` kills GitBucket process, preserves `.tools/` cache.

### Item 1: SC-7 — `with-test-home --clean-all` kills GitBucket process, preserves `.tools/` cache

- [ ] **RED phase.** Write a failing behavioral test that verifies `--clean-all` kills GitBucket process and preserves `.tools/` cache. (**sub-agent**)
  - Context: `{issue_number: 2165}`
  - SC-ID: SC-7
- [ ] **Z3 check RED.** Run `solve --task check` to validate RED state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **RED doublecheck.** Dispatch `verification-before-completion --task verify` to confirm RED test is valid. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Z3 check RED doublecheck.** Run `solve --task check` to validate RED doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **Post-RED enforcement.** Dispatch `post-red-enforcement` to enforce RED gate. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Z3 check post-RED.** Run `solve --task check` to validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **GREEN phase.** Implement `do_clean_all()` GitBucket kill logic in `with-test-home`. (**sub-agent**)
  - Context: `{issue_number: 2165}`
  - SC-ID: SC-7
- [ ] **Z3 check GREEN.** Run `solve --task check` to validate GREEN state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **Post-GREEN enforcement.** Dispatch `post-green-enforcement` to enforce GREEN gate. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Z3 check post-GREEN.** Run `solve --task check` to validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **Checkpoint tag create.** Dispatch `checkpoint-tag-create` to create checkpoint tag. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Checkpoint commit.** Dispatch `git-workflow --task commit-prep` to save checkpoint. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Structural checks.** Dispatch `finishing-a-development-branch --task checklist` for lint/typecheck. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **GREEN doublecheck.** Dispatch `verification-before-completion --task verify` to confirm GREEN implementation. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **GREEN VbC.** Dispatch `verification-before-completion --task completion` for verification before completion. (**sub-agent**)
  - Context: `{issue_number: 2165}`

## Phase 8 — BEHAVIOR_NEEDS_REMOTE flag and multi-test reset (SC-8, SC-9)

Opt-in flag for remote tests, clean state between tests via reset.

### Item 1: SC-8 — Test with `BEHAVIOR_NEEDS_REMOTE=1` can create issue on GitBucket and verify labels

- [ ] **RED phase.** Write a failing behavioral test that verifies `BEHAVIOR_NEEDS_REMOTE=1` enables issue creation and label verification on GitBucket. (**sub-agent**)
  - Context: `{issue_number: 2165}`
  - SC-ID: SC-8
- [ ] **Z3 check RED.** Run `solve --task check` to validate RED state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **RED doublecheck.** Dispatch `verification-before-completion --task verify` to confirm RED test is valid. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Z3 check RED doublecheck.** Run `solve --task check` to validate RED doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **Post-RED enforcement.** Dispatch `post-red-enforcement` to enforce RED gate. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Z3 check post-RED.** Run `solve --task check` to validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **GREEN phase.** Implement `BEHAVIOR_NEEDS_REMOTE=1` flag handling in `behavior_run()` and end-to-end issue creation flow. (**sub-agent**)
  - Context: `{issue_number: 2165}`
  - SC-ID: SC-8
- [ ] **Z3 check GREEN.** Run `solve --task check` to validate GREEN state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **Post-GREEN enforcement.** Dispatch `post-green-enforcement` to enforce GREEN gate. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Z3 check post-GREEN.** Run `solve --task check` to validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **Checkpoint tag create.** Dispatch `checkpoint-tag-create` to create checkpoint tag. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Checkpoint commit.** Dispatch `git-workflow --task commit-prep` to save checkpoint. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Structural checks.** Dispatch `finishing-a-development-branch --task checklist` for lint/typecheck. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **GREEN doublecheck.** Dispatch `verification-before-completion --task verify` to confirm GREEN implementation. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **GREEN VbC.** Dispatch `verification-before-completion --task completion` for verification before completion. (**sub-agent**)
  - Context: `{issue_number: 2165}`

### Item 2: SC-9 — Multiple tests sharing GitBucket instance get clean state via reset

- [ ] **RED phase.** Write a failing behavioral test that verifies multiple tests sharing GitBucket instance get clean state via `__reset_gitbucket()`. (**sub-agent**)
  - Context: `{issue_number: 2165}`
  - SC-ID: SC-9
- [ ] **Z3 check RED.** Run `solve --task check` to validate RED state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **RED doublecheck.** Dispatch `verification-before-completion --task verify` to confirm RED test is valid. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Z3 check RED doublecheck.** Run `solve --task check` to validate RED doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **Post-RED enforcement.** Dispatch `post-red-enforcement` to enforce RED gate. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Z3 check post-RED.** Run `solve --task check` to validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **GREEN phase.** Implement multi-test reset orchestration in `behavior_run()`. (**sub-agent**)
  - Context: `{issue_number: 2165}`
  - SC-ID: SC-9
- [ ] **Z3 check GREEN.** Run `solve --task check` to validate GREEN state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **Post-GREEN enforcement.** Dispatch `post-green-enforcement` to enforce GREEN gate. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Z3 check post-GREEN.** Run `solve --task check` to validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2165, contract_path: skills/writing-plans/contracts/solve-input.yaml}`
- [ ] **Checkpoint tag create.** Dispatch `checkpoint-tag-create` to create checkpoint tag. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Checkpoint commit.** Dispatch `git-workflow --task commit-prep` to save checkpoint. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Structural checks.** Dispatch `finishing-a-development-branch --task checklist` for lint/typecheck. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **GREEN doublecheck.** Dispatch `verification-before-completion --task verify` to confirm GREEN implementation. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **GREEN VbC.** Dispatch `verification-before-completion --task completion` for verification before completion. (**sub-agent**)
  - Context: `{issue_number: 2165}`

## Phase 9 — Documentation (no SCs)

Update AGENTS.md with container pattern, env vars, lifecycle.

### Item 1: Documentation update

- [ ] **GREEN phase.** Update `.opencode/tests-v2/AGENTS.md` with GitBucket container pattern, env vars, and lifecycle documentation. (**sub-agent**)
  - Context: `{issue_number: 2165}`
  - SC-ID: (no SC — documentation only)
- [ ] **Structural checks.** Dispatch `finishing-a-development-branch --task checklist` for lint/typecheck. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **GREEN VbC.** Dispatch `verification-before-completion --task completion` for verification before completion. (**sub-agent**)
  - Context: `{issue_number: 2165}`

## Post-implementation

- [ ] **SC count gate.** Dispatch `sc-count-gate` to verify all 10 SCs have verdicts. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Pre-PR gate.** Dispatch `verification-before-completion --task verify` to check all SC verdicts — BLOCK if any FAIL. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Audit.** Dispatch the appropriate audit task (verification-audit) via `task(subagent_type="general")`. (**orchestrator**)
  - Context: `{issue_number: 2165, spec_local_dir: .opencode/.issues/2165, artifact_evidence_dir: tmp/2165/artifacts}`
  - If non-clean-pass (FAIL or DONE_WITH_CONCERNS): remediate root cause, then restart audit.
  - On clean PASS: collect `artifact_path` and pass as `auditor_artifact_paths` to cross-validate.
- [ ] **Cross-validate.** Dispatch `audit --task cross-validate` for consensus check. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Regression check.** Dispatch `test-driven-development --task patterns` for regression test patterns. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Review prep.** Dispatch `git-workflow --task review-prep` to prepare PR review. (**sub-agent**)
  - Context: `{issue_number: 2165}`
- [ ] **Create PR.** Dispatch `pr-creation-workflow --task create` to create pull request. (**sub-agent**)
  - Context: `{issue_number: 2165, authorization_scope: ..., halt_at: ...}`
- [ ] **Completion.** Dispatch `completion-core --task completion` for executive summary. (**sub-agent**)
  - Context: `{issue_number: 2165}`

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-07-27T20:20:00Z | `plan_created` | Plan file at `.opencode/.issues/2165/plan.md`, 9 phases, 10 SCs |
