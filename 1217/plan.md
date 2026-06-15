# Plan for #1217: Replace .gitmodules detection with filesystem glob scan

## Spec: #1217

**Goal:** Eliminate `.gitmodules` as a single point of failure for submodule discovery across all 10 git-workflow task files. Replace with a filesystem glob scan (`ls -d .git/ */.git/ */.git`) that discovers repos by checking for `.git` entries directly, then resolves remotes via `git -C <path> remote get-url origin`.

**Architecture:** Pure bash script pattern — no new tools, no new dependencies.

**Tech Stack:** Bash, git, sed for URL parsing. No Python, no Node.js, no new dependencies.

**Plan structure decision:** Separate.
**Reason:** Multi-phase spec (4 phases) with sequential dependencies between phases and distinct concern boundaries for each phase (check-pr, cleanup pipeline, remaining task files, SKILL.md tag convention).

## Conflict Solvability

**Phase ordering validation:** Phase dependencies are strictly sequential — each phase depends on the prior phase completing. No parallel paths, no branching dependencies. Ordering is trivially SAT. No Z3 contract needed for linear sequential ordering.

**Phase dependency chain:**
- Phase 2 depends on Phase 1 (glob scan pattern must exist before cleanup tasks use it)
- Phase 3 depends on Phase 2 (cleanup pattern establishes the routing context pattern)
- Phase 4 depends on Phases 1-3 (all .gitmodule refs cleared before SKILL.md tag rule updated)

## Phase 1: Core Detection Pattern + check-pr

**Concern boundary (entering):** The check-pr task has undefined submodule discovery pseudo-code — no operational detection across repos.

**Concern boundary (leaving):** Single-repo PR query assumption. After this phase, PR queries span all discovered repos.

**Handoff to Phase 2:** The glob scan pattern established here is the shared detection mechanism that Phase 2 reuses in the cleanup pipeline.

**Files:** `tasks/check-pr.md`

**SCs covered:** SC-1, SC-2, SC-9

### Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 1217, "phase": 1}` | SC-1, SC-2 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1217, "phase": 1}` | SC-1, SC-2 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 1217, "phase": 1}` | SC-2 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 1217, "phase": 1}` | SC-2 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 1217, "phase": 1}` | SC-1, SC-2 |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 1217, "phase": 1}` | SC-1, SC-2 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 1217, "phase": 1}` | SC-1, SC-2 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-1, SC-2 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 1217, "phase": 1}` | SC-1 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 1217, "phase": 1}` | SC-2 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 1217, "phase": 1}` | SC-1, SC-2 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 1217, "phase": 1}` | SC-1, SC-2 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 1217, "phase": 1}` | SC-1, SC-2 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 1217, "phase": 1}` | SC-1, SC-2 |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 1217, "phase": 1}` | SC-1, SC-2 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 1217, "phase": 1}` | SC-1, SC-2 |

### Unit 1.1: Core detection pattern

**RED:** The check-pr task has no repo discovery mechanism beyond the main repo's `.git` directory. The procedure references an undefined variable with no binding, no glob scan, and no runtime resolution.

**GREEN:** A filesystem-based glob scan pattern must exist that discovers all git repos at a project root by checking for `.git/`, `*/.git/`, and `*/.git` entries, and resolves remote owner/repo from each discovered repo.

**Z3 contract:** `P1_1` domain variable. 14 gate variables (`P1_1_p1` through `P1_1_p14`). Serial ordering invariants. All-false → SAT. P1_1=true, p1=false → UNSAT.

**Pipeline gate table:**

| Gate | Name | Exit Criterion |
|------|------|----------------|
| 1 | sc-coherence-gate | Spec and plan agree on Phase 1 scope |
| 2 | pre-red-baseline | Current state of check-pr task documented as baseline |
| 3 | red-phase | Content-verification test confirms no glob scan pattern exists; behavioral test confirms single-repo-only PR query |
| 4 | red-doublecheck | RED evidence artifacts are well-formed and show correct baseline state |
| 5 | green-phase | Glob scan pattern replaces undefined pseudo-code in check-pr task |
| 6 | checkpoint-commit | Phase 1 changes committed with checkpoint tag |
| 7 | structural-checks | All structural lint/format checks pass |
| 8 | green-doublecheck | GREEN-side evidence confirms glob scan pattern is self-contained and covers all three glob patterns |
| 9 | green-vbc | All SCs for Phase 1 verified against live code |
| 10 | adversarial-audit | Dual-auditor convergence on Phase 1 deliverables |
| 11 | cross-validate | Consensus between auditors |
| 12 | regression-check | No regressions in parent or submodule repos |
| 13 | review-prep | Review-ready status |
| 14 | exec-summary | Summary reported |

### Unit 1.2: Multi-repo PR query

**RED:** The check-pr task only queries the main repo for PRs — repos discovered by the glob scan are not queried.

**GREEN:** The check-pr task must iterate all glob-discovered repos and query each for open and merged PRs, filtering merged results by `merged_at` field.

**Z3 contract:** `P1_2` domain variable. 14 gate variables (`P1_2_p1` through `P1_2_p14`). Serial ordering. All-false → SAT. P1_2=true, p1=false → UNSAT.

**Pipeline gate table:** Same 14-row structure as Unit 1.1, with exit criteria scoped to multi-repo PR query behavior.

---

## Phase 2: cleanup pipeline sub-tasks

**Concern boundary (entering):** The cleanup pipeline (cleanup.md, branch-cleanup.md, issue-closure.md) needs to operate across all repos. Currently uses `.gitmodules` for submodule path discovery.

**Concern boundary (leaving):** `.gitmodules` parsing in cleanup context. After this phase, cleanup builds `submodule_paths` routing context from glob scan results.

**Handoff from Phase 1:** The core glob scan pattern established in Phase 1 is reused here. Same `ls -d .git/ */.git/ */.git` + remote resolution.

**Files:** `tasks/cleanup.md`, `tasks/cleanup/branch-cleanup.md`, `tasks/cleanup/issue-closure.md`

**SCs covered:** SC-1, SC-3, SC-4, SC-9

### Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 1217, "phase": 2}` | SC-1, SC-3, SC-4 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1217, "phase": 2}` | SC-1, SC-3, SC-4 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 1217, "phase": 2}` | SC-3 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 1217, "phase": 2}` | SC-3, SC-4 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 1217, "phase": 2}` | SC-1, SC-3, SC-4 |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 1217, "phase": 2}` | SC-1, SC-3, SC-4 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 1217, "phase": 2}` | SC-1, SC-3, SC-4 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-1, SC-3, SC-4 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 1217, "phase": 2}` | SC-1 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 1217, "phase": 2}` | SC-3, SC-4 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 1217, "phase": 2}` | SC-1, SC-3, SC-4 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 1217, "phase": 2}` | SC-1, SC-3, SC-4 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 1217, "phase": 2}` | SC-1, SC-3, SC-4 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 1217, "phase": 2}` | SC-1, SC-3, SC-4 |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 1217, "phase": 2}` | SC-1, SC-3, SC-4 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 1217, "phase": 2}` | SC-1, SC-3, SC-4 |

### Unit 2.1: cleanup.md — glob-based submodule_paths

**RED:** The cleanup task detects submodules by checking for a `.gitmodules` file at the project root and parsing it with `git config --file`.

**GREEN:** The cleanup task must use a filesystem glob scan to discover all git repos at the project root and build the `submodule_paths` routing context from the scan results.

**Z3 contract:** `P2_1` domain variable. 14 gate variables (`P2_1_p1` through `P2_1_p14`). Serial ordering.

### Unit 2.2: branch-cleanup.md — glob-based iteration

**RED:** The branch-cleanup task collects submodule paths by reading `.gitmodules` via `git config --file`.

**GREEN:** The branch-cleanup task must iterate over glob-discovered repos for dev sync, merged-branch detection, and branch deletion.

**Z3 contract:** `P2_2` domain variable. 14 gate variables (`P2_2_p1` through `P2_2_p14`). Serial ordering.

### Unit 2.3: issue-closure.md — glob-based fallback

**RED:** The issue-closure task falls back to `.gitmodules` entries for path-to-owner/repo resolution when `submodule_paths` routing context is not provided.

**GREEN:** The issue-closure task must accept and use glob-based `submodule_paths` routing context from the cleanup task, with no `.gitmodules` fallback.

**Z3 contract:** `P2_3` domain variable. 14 gate variables (`P2_3_p1` through `P2_3_p14`). Serial ordering.

---

## Phase 3: Remaining task files

**Concern boundary (entering):** Five remaining task files each have their own `.gitmodules`-based gate check for submodule operations.

**Concern boundary (leaving):** All `.gitmodules` references in individual task files.

**Handoff from Phase 1/2:** Same core glob scan pattern. No new pattern needed.

**Files:** `tasks/release-promotion.md`, `tasks/review-prep/push-and-cleanup.md`, `tasks/pr-creation/enforcement-gate.md`, `tasks/pre-work.md`, `tasks/provenance.md`

**SCs covered:** SC-1, SC-5, SC-6, SC-7, SC-9

### Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 1217, "phase": 3}` | SC-1, SC-5, SC-6, SC-7 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1217, "phase": 3}` | SC-1, SC-5, SC-6, SC-7 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 1217, "phase": 3}` | SC-5 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 1217, "phase": 3}` | SC-5, SC-6, SC-7 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 1217, "phase": 3}` | SC-1, SC-5, SC-6, SC-7 |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 1217, "phase": 3}` | SC-1, SC-5, SC-6, SC-7 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 1217, "phase": 3}` | SC-1, SC-5, SC-6, SC-7 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-1, SC-5, SC-6, SC-7 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 1217, "phase": 3}` | SC-1 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 1217, "phase": 3}` | SC-5, SC-6, SC-7 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 1217, "phase": 3}` | SC-1, SC-5, SC-6, SC-7 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 1217, "phase": 3}` | SC-1, SC-5, SC-6, SC-7 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 1217, "phase": 3}` | SC-1, SC-5, SC-6, SC-7 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 1217, "phase": 3}` | SC-1, SC-5, SC-6, SC-7 |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 1217, "phase": 3}` | SC-1, SC-5, SC-6, SC-7 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 1217, "phase": 3}` | SC-1, SC-5, SC-6, SC-7 |

### Unit 3.1: release-promotion.md

**RED:** The release-promotion task checks for a `.gitmodules` file at the project root to determine whether submodules exist, and lists submodule paths by reading `.gitmodules` config.

**GREEN:** The release-promotion task must use a filesystem glob scan to discover repos and iterate all of them for tag creation and push operations.

**Z3 contract:** `P3_1` domain variable. 14 gate variables.

### Unit 3.2: review-prep/push-and-cleanup.md

**RED:** The push-and-cleanup task checks for `.gitmodules` existence as a gate for dispatching submodule feature-push agents; absence means no submodule dispatch.

**GREEN:** The push-and-cleanup task must use a glob scan to discover repos and dispatch sub-agents for each discovered repo's feature-push operations.

**Z3 contract:** `P3_2` domain variable. 14 gate variables.

### Unit 3.3: pr-creation/enforcement-gate.md

**RED:** The enforcement-gate task checks for `.gitmodules` existence as a gate for performing submodule liveness checks; absence means skip.

**GREEN:** The enforcement-gate task must use a glob scan to discover repos and perform liveness checks for each discovered repo.

**Z3 contract:** `P3_3` domain variable. 14 gate variables.

### Unit 3.4: pre-work.md

**RED:** The pre-work task checks for `.gitmodules` existence as the gate for dispatching submodule-tag-prework sub-agents; absence means skip the submodule step entirely.

**GREEN:** The pre-work task must use a glob scan to discover repos and dispatch sub-agents for each discovered repo's tag-prework operations.

**Z3 contract:** `P3_4` domain variable. 14 gate variables.

### Unit 3.5: provenance.md

**RED:** The provenance task lists `.gitmodules` existence as an entry criterion — if no `.gitmodules` file exists, the task may not execute in submodule-aware mode.

**GREEN:** The provenance task entry criterion must use glob scan to discover repos and produce provenance artifacts for each discovered repo.

**Z3 contract:** `P3_5` domain variable. 14 gate variables.

---

## Phase 4: SKILL.md tag convention

**Concern boundary (entering):** The SKILL.md tag suffix rule derives the submodule identifier from the `.gitmodules` path name.

**Concern boundary (leaving):** `.gitmodules` path reference in tag convention.

**Handoff from Phase 1-3:** The glob scan pattern is already established. This phase only changes the tag suffix source — from `.gitmodules` path to directory name derived from the glob-discovered repo.

**Files:** `SKILL.md`

**SCs covered:** SC-1, SC-8, SC-9

### Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 1217, "phase": 4}` | SC-1, SC-8 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1217, "phase": 4}` | SC-1, SC-8 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 1217, "phase": 4}` | SC-8 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 1217, "phase": 4}` | SC-8 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 1217, "phase": 4}` | SC-1, SC-8 |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 1217, "phase": 4}` | SC-1, SC-8 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 1217, "phase": 4}` | SC-1, SC-8 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-1, SC-8 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 1217, "phase": 4}` | SC-1 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 1217, "phase": 4}` | SC-8 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 1217, "phase": 4}` | SC-1, SC-8 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 1217, "phase": 4}` | SC-1, SC-8 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 1217, "phase": 4}` | SC-1, SC-8 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 1217, "phase": 4}` | SC-1, SC-8 |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 1217, "phase": 4}` | SC-1, SC-8 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 1217, "phase": 4}` | SC-1, SC-8 |

### Unit 4.1: Tag suffix source

**RED:** The SKILL.md tag convention derives the submodule identifier from the `.gitmodules` file path name — not from the actual filesystem directory name of the discovered repo.

**GREEN:** The tag suffix rule must derive the submodule identifier from the directory name of the glob-discovered repo, not from a `.gitmodules` path reference.

**Z3 contract:** `P4_1` domain variable. 14 gate variables (`P4_1_p1` through `P4_1_p14`). Serial ordering.

---

## Core Detection Pattern (shared across all phases)

```bash
REPO_PATHS=$(ls -d .git/ */.git/ */.git 2>/dev/null | sed 's|/$||')
for RP in $REPO_PATHS; do
    REMOTE_URL=$(git -C "$RP" remote get-url origin 2>/dev/null || echo "")
    # Parse owner/repo from SSH (git@github.com:owner/repo.git) or HTTPS (https://github.com/owner/repo.git)
done
```

## Dependencies

- Phase 1 → Phase 2 → Phase 3 → Phase 4 (sequential)
- No external dependencies
- Phase ordering is linear: each phase depends on the prior phase completing. No branching, no parallel paths.

## SC Coverage Summary

| SC ID | Criterion | Evidence Type | Phases |
|-------|-----------|---------------|--------|
| SC-1 | All 10 files replace `.gitmodules` references with filesystem glob scan | `string` | 1, 2, 3, 4 |
| SC-2 | check-pr queries all discovered repos for PRs | `behavioral` | 1 |
| SC-3 | cleanup Step 0 builds submodule_paths from glob scan | `string` | 2 |
| SC-4 | branch-cleanup Step 1.9 iterates all glob-discovered repos | `string` | 2 |
| SC-5 | release-promotion iterates all glob-discovered repos | `string` | 3 |
| SC-6 | pre-work dispatches sub-agents per glob-discovered repo | `string` | 3 |
| SC-7 | provenance.md entry criterion uses glob scan | `string` | 3 |
| SC-8 | SKILL.md tag suffix uses discovered repo directory name | `string` | 4 |
| SC-9 | No recursion — single-level scan only | `string` | 1, 2, 3, 4 |