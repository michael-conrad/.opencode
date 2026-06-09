# Plan: #1065 — local-issues Output Format + Cross-Repo Operations

> **Parent spec:** [`.issues/1065/spec.md`](https://github.com/michael-conrad/.opencode/blob/issues-data/1065/spec.md)
> **Planning method:** Formal PDDL planning (`plan` tool) + Z3 validation (`solve` tool)
> **Branch:** `spec/1065-local-issues-plan`
> **Status:** `plan`

---

## Dependency Overview

```
#1059 (infrastructure: submodule worktree auto-discovery) — **MUST be merged first**
  │
  └── #1065 (this issue) — output format + cross-repo ops
       │
       ├── p1: output-format  (SC-1, SC-2, SC-3)
       ├── p2: cross-repo-read (SC-4, SC-5, SC-13)
       ├── p3: mutation-qualified-form (SC-6)
       ├── p4: cross-repo-search (SC-7)
       ├── p5: create-collision-check (SC-8)
       ├── p6: task-card-updates (SC-9, SC-10, SC-11, SC-12)
       └── p7: behavioral-tests (verification)
```

**Constraint:** #1059 is open — infrastructure prerequisite not yet merged. Implementation cannot begin until #1059 PR merges.

---

## Phase Structure

Each phase follows strict RED/GREEN TDD: behavioral test written first (RED + FAIL), then implementation to make it pass (GREEN), then PR merge to unlock next phase.

### Phase 1: Output Format Change (p1-output-format)

| ID | Criterion | Evidence | Verification |
|----|-----------|----------|-------------|
| SC-1 | `list` outputs qualified `{repo}#{N}` format excluding current repo prefix | `string` | grep `local-issues` for qualified-form output |
| SC-2 | `list` outputs `spec_path` column (relative to project root) | `string` | grep `local-issues` for spec_path column |
| SC-3 | `list` sorts: main repo first, submodules alpha, issue number descending per repo | `behavioral` | `opencode-cli run` with cross-repo test setup |

**Dependencies:** None (starts from #1059 merge boundary)
**Phases 2 & 4:** Unlocked by p1 merge

### Phase 2: Cross-Repo Read (p2-cross-repo-read)

| ID | Criterion | Evidence | Verification |
|----|-----------|----------|-------------|
| SC-4 | Bare `read N` scans all repos, returns ALL matches with `{repo}#N` prefix | `string` | grep for `repo` field alongside `number`, `spec_path` in read output |
| SC-5 | Qualified `read opencode-config#7` targets specific repo | `string` | grep for qualified-form acceptance |
| SC-13 | Read scan order: main repo first, child repos alpha | `string` | Code review of scan order |

**Dependencies:** p1 merged
**Phase 3:** Unlocked by p2 merge

### Phase 3: Mutation Qualified-Form (p3-mutation-qualified)

| ID | Criterion | Evidence | Verification |
|----|-----------|----------|-------------|
| SC-6 | `update`/`close`/`delete`/`promote`/`push-body`/`pull-body` reject bare numbers with "Use qualified form" error | `behavioral` | `opencode-cli run` verifying rejection |

**Dependencies:** p2 merged

### Phase 4: Cross-Repo Search (p4-cross-repo-search)

| ID | Criterion | Evidence | Verification |
|----|-----------|----------|-------------|
| SC-7 | `search` defaults to cross-repo scan; output includes `repo` + `spec_path` | `behavioral` | `opencode-cli run` verifying cross-repo search output |

**Dependencies:** p1 merged (parallel to p2, p3)

### Phase 5: Create Collision Check (p5-create-collision)

| ID | Criterion | Evidence | Verification |
|----|-----------|----------|-------------|
| SC-8 | `create --number N` blocks if `{repo}#{N}` exists in ANY repo | `behavioral` | `opencode-cli run` verifying cross-repo collision |

**Dependencies:** p3 merged + p4 merged

### Phase 6: Task Card Updates (p6-task-cards)

| ID | Criterion | Evidence | Verification |
|----|-----------|----------|-------------|
| SC-9 | `list.md` updated with qualified YAML format | `string` | grep task file for new format |
| SC-10 | `read.md` updated with cross-repo behavior | `string` | grep for qualified-form examples |
| SC-11 | `search.md` updated with cross-repo default | `string` | grep for cross-repo scope |
| SC-12 | Mutation task cards use `{repo}#{N}` in examples | `string` | grep all 8 mutation task files |

**Dependencies:** p5 merged

### Phase 7: Behavioral Test Assertions (p7-behavioral-tests)

| ID | Criterion | Evidence | Verification |
|----|-----------|----------|-------------|
| (verification) | All behavioral SCs have RED-phase tests that fail before GREEN | `behavioral` | `opencode-cli run` with enforcement test suite |

**Dependencies:** p6 merged

---

## Formal Plan (PDDL-Generated)

Generated via `plan tool --domain local-issues-plan-v5`. Validated via `solve tool` with Z3 SAT check.

```
Step  Sequence
────  ────────
  1.  RED(p1)       — Write behavioral test: list output format (SC-1,2,3)
  2.  GREEN(p1)     — Implement output format changes in local-issues
  3.  MERGE(p1)     — PR p1 → dev
  4.  RED(p2)       — Write behavioral test: cross-repo read (SC-4,5,13)
  5.  GREEN(p2)     — Implement cross-repo read
  6.  MERGE(p2)     — PR p2 → dev
  7.  RED(p3)       — Write behavioral test: mutation qualified-form (SC-6)
  8.  GREEN(p3)     — Implement qualified-form enforcement
  9.  MERGE(p3)     — PR p3 → dev
 10.  RED(p4)       — Write behavioral test: cross-repo search (SC-7)
 11.  GREEN(p4)     — Implement cross-repo search
 12.  MERGE(p4)     — PR p4 → dev
 13.  RED(p5)       — Write behavioral test: create collision (SC-8)
 14.  GREEN(p5)     — Implement cross-repo collision check
 15.  MERGE(p5)     — PR p5 → dev
 16.  RED(p6)       — Update 11 task card files with new format
 17.  GREEN(p6)     — Verify all task cards updated correctly
 18.  MERGE(p6)     — PR p6 → dev
 19.  RED(p7)       — Full behavioral test suite (all SCs)
 20.  GREEN(p7)     — Fix any test failures
 21.  MERGE(p7)     — Final PR → dev
```

**Note:** The planner serialized p2 before p4 (both depend only on p1, so they could be done in parallel during implementation — the PDDL model's STRIPS semantics produce one valid linearization).

### Dependency Graph

```
p1 ---+--- p2 --- p3 ------+
      |                     |
      +--- p4 --------------+--- p5 --- p6 --- p7
```

### Z3 Validation

State file: `.opencode/.issues/1065/spec-artifacts/state.yaml`
Contract: `.opencode/.issues/1065/spec-artifacts/contract.yaml`

All 21 variables (p1-p7 red/green/merged) set to `true` → **SAT (+ postconditions + invariants)** — plan is internally consistent and all preconditions, postconditions, and invariants are satisfied.

---

## Work Items

| # | Phase | Item | Files Modified |
|---|-------|------|----------------|
| 1 | p1 | `list` output format: qualified `{repo}#{N}` prefix | `.opencode/tools/local-issues` |
| 2 | p1 | `list` output format: `spec_path` column | `.opencode/tools/local-issues` |
| 3 | p1 | `list` output format: sort order (main→submodules→desc number) | `.opencode/tools/local-issues` |
| 4 | p2 | `read` bare number: cross-repo scan with disambiguation | `.opencode/tools/local-issues` |
| 5 | p2 | `read` qualified `{repo}#{N}`: direct target | `.opencode/tools/local-issues` |
| 6 | p2 | Read scan order: main first, children alpha | `.opencode/tools/local-issues` |
| 7 | p3 | Mutation commands reject bare numbers | `.opencode/tools/local-issues` |
| 8 | p4 | `search` defaults to cross-repo; output includes repo+spec_path | `.opencode/tools/local-issues` |
| 9 | p5 | `create --number N` cross-repo collision check | `.opencode/tools/local-issues` |
| 10 | p6 | Update all 11 platform task card files | `.opencode/skills/issue-operations/platforms/local/tasks/*` |
| 11 | p7 | Behavioral enforcement tests referencing SC IDs | `.opencode/tests/behaviors/*` |

---

## Risks

| Risk | Mitigation |
|------|-----------|
| #1059 not merged → all phases blocked | Plan flags this as hard dependency; implementation will HALT until #1059 PR merges |
| Qualified-form `{repo}#{N}` leaked into GitHub API calls | Strip prefix before passing to remote — DEC-4 enforced in code |
| Cross-repo scan latency on large projects | Immediate children only (per #1059 scope), no nested recursion |

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)