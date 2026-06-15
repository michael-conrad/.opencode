# Plan: Workstream D — New submodule-sync Task for git-workflow

**Spec:** #1212
**Authorization scope:** `for_plan` | `halt_at: plan_created` | `pr_strategy: none`
**Type:** Separate (2-phase, new file + dispatch table update)

## Summary

Create a new `submodule-sync.md` task file under git-workflow skill and add a dispatch table row to the SKILL.md. The task syncs dirty submodule pointers to latest dev tip — used for mid-feature submodule currency and user "sync submodules" requests.

## Expanded SC Table

| ID | Criterion | Evidence Type | Pipeline Step Binding | Re-Entry Step | Verification Gate | Artifact Path |
|----|-----------|---------------|----------------------|---------------|-------------------|---------------|
| SC-D1 | `submodule-sync.md` exists at `.opencode/skills/git-workflow/tasks/submodule-sync.md` | structural | Phase 1: `green-phase` | N/A | `structural-checks` | `.opencode/skills/git-workflow/tasks/submodule-sync.md` |
| SC-D2 | git-workflow SKILL.md dispatch table has a row referencing `submodule-sync` for `"sync submodules" / "update submodules"` triggers | string | Phase 2: `green-phase` | N/A | `structural-checks` | `.opencode/skills/git-workflow/SKILL.md` |
| SC-D3 | Task procedure covers all submodule sync operations (detect via `.gitmodules`, checkout dev, pull --ff-only, return to parent, report results) | semantic | Phase 1: `adversarial-audit` | green-doublecheck | `cross-validate` | `.opencode/skills/git-workflow/tasks/submodule-sync.md` |

## Pre-Work

1. Create feature branch from dev: `feature/1212-submodule-sync-task`
2. Tag `.opencode` submodule: `opencode-config/checkpoint/1212/pre-opencode`

### Step 0.5: Pipeline-Readiness Gate

- [ ] Verify `./tmp/sc-pipeline-readiness.yaml` exists with `status: PASS`
- [ ] If missing or FAIL: HALT — pipeline must be re-primed before plan execution
- [ ] Verify spec-to-plan handoff artifact at `./tmp/1212/artifacts/spec-to-plan-handoff-*.yaml` with `status: PASS`
- [ ] If handoff FAIL: HALT — spec-to-plan handoff must pass before plan can be executed
- [ ] Authorize verification-enforcement task: reference `verification-enforcement --task verify` for spec fact verification before implementation

---

## Phase 1: Create submodule-sync Task File

**Concern Boundary HANDOFF:**
- **Entering:** File creation concern — new artifact generation within git-workflow skill scope
- **Leaving (to Phase 2):** Completed task file ready for cross-referencing by dispatch table update
- **Handoff point:** `submodule-sync.md` file path and SC-D1 status passed to Phase 2

**Concern:** New task file implementing the submodule sync procedure (SC-D1, SC-D3).

**Files to modify:**
- `NEW: .opencode/skills/git-workflow/tasks/submodule-sync.md`

**Entry Criteria:** Spec approved, feature branch exists, submodule tagged, pipeline-readiness PASS, spec-to-plan handoff PASS.

**Exit Criteria:** `submodule-sync.md` exists with procedure covering: `.gitmodules` detection, per-submodule checkout dev and pull --ff-only, return to parent repo, result reporting.

### Dispatch Table (Phase 1)

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 1212, "phase": 1, "spec_path": ".opencode/.issues/1212/spec.md"}` | SC-D1, SC-D3 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1212, "phase": 1}` | SC-D1, SC-D3 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 1212, "phase": 1, "test_command": "test -f .opencode/skills/git-workflow/tasks/submodule-sync.md", "expected_result": "FAIL (file doesn't exist yet)"}` | SC-D1 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 1212, "phase": 1}` | SC-D1 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 1212, "phase": 1}` | SC-D1 |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 1212, "phase": 1, "description": "Create submodule-sync.md with full procedure"}` | SC-D1, SC-D3 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 1212, "phase": 1}` | SC-D1 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-D1 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 1212, "phase": 1}` | SC-D1 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 1212, "phase": 1}` | SC-D3 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 1212, "phase": 1}` | SC-D1, SC-D3 |
| G12: adversarial-audit | sub-task | yes (blind) | resolve-models | `{"task": "execute adversarial-audit from implementation-pipeline", "audit_phase": "plan_creation", "audit_type": "plan-fidelity", "issue_number": 1212, "phase": 1}` | SC-D3 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 1212, "phase": 1}` | SC-D1, SC-D3 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 1212, "phase": 1}` | — |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 1212, "phase": 1}` | SC-D1, SC-D3 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 1212, "phase": 1}` | SC-D1, SC-D3 |

### Task File Content Description

The file follows the pattern from `provenance.md`:

```
# Task: submodule-sync

## Purpose
Sync dirty submodule pointers to latest dev tip. Used for mid-feature submodule currency and user "sync submodules" requests.

## Entry Criteria
- One or more submodules have dirty pointers in parent repo
- `.gitmodules` exists in worktree

## Procedure
- [ ] 1. Detect submodules: read `.gitmodules` for `[submodule "..."]` paths
- [ ] 2. For each submodule path:
      - `git checkout dev && git pull origin dev --ff-only`
      - On failure: log the submodule path and error; continue to next submodule
- [ ] 3. Return to parent repo: `git -C <parent> checkout <original-branch>`
- [ ] 4. Report: which submodules were synced successfully, which (if any) failed

## Exit Criteria
All accessible submodules point to latest dev tip. Failed submodules reported but do not block.

## Cross-References
- `git-workflow/SKILL.md` §Tag Convention — hash permanence tags preserve SHAs before sync
- `pre-work` task — submodule tagging at feature start
- Sub-Agent Tasks for Submodule Operations table — submodule ops NEVER done inline
```

---

## Inter-Phase Handoff (Phase 1 → Phase 2)

- [ ] Update Z3 state file: `solve state update` with Phase 1 gate states
- [ ] Run `solve check`: confirm Phase 1 dependency contract still SAT
- [ ] Verify checkpoint tag exists for Phase 1: `opencode-config/checkpoint/1212/phase-1-opencode`
- [ ] Append lifecycle manifest event for Phase 1 completion
- [ ] Concern boundary transition: file creation concern → dispatch table update concern
- [ ] Handoff data: SC-D1 PASS status, file path `.opencode/skills/git-workflow/tasks/submodule-sync.md`

---

## Phase 2: Update git-workflow SKILL.md Dispatch Table

**Concern Boundary HANDOFF:**
- **Entering (from Phase 1):** Dispatch table update concern — new row insertion referencing existing task file
- **Prior concern completed:** File creation (Phase 1 — `submodule-sync.md` exists)
- **Information received from Phase 1:** Task file path verified, SC-D1 PASS confirmed

**Concern:** Add dispatch table row referencing submodule-sync for "sync submodules" / "update submodules" triggers (SC-D2).

**Files to modify:**
- `.opencode/skills/git-workflow/SKILL.md` — Trigger Dispatch Table (between "provenance" row and "completion" row)

**Entry Criteria:** Phase 1 complete, task file exists, inter-phase handoff PASS, checkpoint tag exists.

**Exit Criteria:** Dispatch table has exactly one new row for "sync submodules" / "update submodules" → `submodule-sync`.

### Dispatch Table (Phase 2)

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 1212, "phase": 2, "spec_path": ".opencode/.issues/1212/spec.md"}` | SC-D2 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1212, "phase": 2}` | SC-D2 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 1212, "phase": 2, "test_command": "grep -q 'sync submodules' .opencode/skills/git-workflow/SKILL.md", "expected_result": "FAIL (row doesn't exist yet)"}` | SC-D2 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 1212, "phase": 2}` | SC-D2 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 1212, "phase": 2}` | SC-D2 |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 1212, "phase": 2, "description": "Insert new dispatch table row in git-workflow SKILL.md"}` | SC-D2 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 1212, "phase": 2}` | SC-D2 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-D2 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 1212, "phase": 2}` | SC-D2 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 1212, "phase": 2}` | SC-D2 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 1212, "phase": 2}` | SC-D2 |
| G12: adversarial-audit | sub-task | yes (blind) | resolve-models | `{"task": "execute adversarial-audit from implementation-pipeline", "audit_phase": "plan_creation", "audit_type": "concern-separation", "issue_number": 1212, "phase": 2}` | SC-D2 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 1212, "phase": 2}` | SC-D2 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 1212, "phase": 2}` | — |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 1212, "phase": 2}` | SC-D2 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 1212, "phase": 2}` | SC-D2 |

### Dispatch Table Row

```
| "sync submodules" / "update submodules" | submodule-sync | sub-task | {submodule_paths} |
```

### Invocation Row (add to Invocation section)

```
| submodule-sync | `task(..., prompt: "execute submodule-sync task from git-workflow")` |
```

---

## Post-All-Phases Sweep

After Phase 2 final gate completes:

### FINISHING CHECKLIST
- [ ] Orchestrator routes to finishing-a-development-branch sub-agent
- [ ] Verify `git status` is clean
- [ ] Run lint/typecheck from scratch: `uvx ruff check --fix src/ test/`, `uvx ruff format src/ test/`, `uvx pyright src/`
- [ ] Run markdown lint: `uvx pymarkdownlnt scan -r .opencode/guidelines/ docs/`
- [ ] Run markdown format: `uvx --with mdformat-frontmatter --with mdformat-tables --with mdformat-config --with mdformat-gfm mdformat --number --compact-tables --check .opencode/guidelines/ docs/`
- [ ] Run enforcement tests: `bash .opencode/tests/test-enforcement.sh --changed`

### IMPLEMENTATION CHECKLIST GENERATION
- [ ] Generate `implementation-checklist.md` at `.opencode/.issues/1212/implementation-checklist.md`
- [ ] Include all SCs with verification methods and PASS/FAIL status
- [ ] Include phase-by-phase gate status summary

### PR CREATION
- [ ] Orchestrator routes to git-workflow pr-creation
- [ ] `github_create_pull_request` with base `dev`, head `feature/1212-submodule-sync-task`
- [ ] Extract `html_url` from API response — NEVER construct from template
- [ ] PR title: "Workstream D: Add submodule-sync task for git-workflow"

### POST-MERGE CLEANUP
- [ ] Orchestrator routes to git-workflow cleanup
- [ ] Delete merged branches
- [ ] Close issue #1212 (after PR merge confirmed)
- [ ] Sync dev branch

---

## Verification Methods

- **SC-D1 (structural):** `test -f .opencode/skills/git-workflow/tasks/submodule-sync.md` → exits 0
- **SC-D2 (string):** `grep -q 'sync submodules.*submodule-sync' .opencode/skills/git-workflow/SKILL.md` → exits 0
- **SC-D3 (semantic):** Read `submodule-sync.md` and verify all four operation types present: `.gitmodules` detection, checkout dev + pull --ff-only, return to parent, result reporting