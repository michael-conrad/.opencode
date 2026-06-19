# Plan — #1278: Fix Persona identity framing, add unified checklists, add solve/plan tool steps

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order.

## Architecture

Two skill cards (`spec-creation/SKILL.md`, `writing-plans/SKILL.md`) and two task files (`write.md`, `create.md`) are modified. Five new contract template YAML files are created. Changes are independent per skill card but share the same structural pattern.

**Tech stack:** Markdown, YAML, Z3 (solve tool), PDDL (plan tool)

---

## Phase 1: Fix Persona sections

**Concern:** Identity framing — replace first-person identity frames with third-person dispatch framing in both SKILL.md files.

**Files:** `.opencode/skills/spec-creation/SKILL.md`, `.opencode/skills/writing-plans/SKILL.md`

**SCs:** SC-1, SC-2, SC-16

### Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "verify spec coherence for Phase 1", "issue_number": 1278, "phase": 1, "github.owner": "michael-conrad", "github.repo": ".opencode"}` | SC-1, SC-2, SC-16 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "capture pre-change Persona text from both SKILL.md files", "issue_number": 1278, "phase": 1}` | SC-1, SC-2, SC-16 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "write behavioral RED test verifying agent does NOT use third-person dispatch framing for spec-creation", "issue_number": 1278, "phase": 1}` | SC-1, SC-2, SC-16 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "verify RED test fails — agent still uses first-person identity", "issue_number": 1278, "phase": 1}` | SC-1, SC-2, SC-16 |
| G5: green-phase | sub-task | yes (blind) | general | `{"task": "replace Persona sections in spec-creation/SKILL.md and writing-plans/SKILL.md with third-person dispatch framing per spec Phase 1", "issue_number": 1278, "phase": 1}` | SC-1, SC-2, SC-16 |
| G6: checkpoint-commit | inline | N/A | N/A | — | SC-1, SC-2, SC-16 |
| G7: structural-checks | sub-task | yes (blind) | general | `{"task": "verify SC-1, SC-2, SC-16 via grep assertions", "issue_number": 1278, "phase": 1}` | SC-1, SC-2, SC-16 |
| G8: green-doublecheck | sub-task | yes (blind) | general | `{"task": "re-run behavioral GREEN test — verify agent now uses third-person dispatch framing", "issue_number": 1278, "phase": 1}` | SC-1, SC-2, SC-16 |
| G9: green-vbc | sub-task | yes (blind) | general | `{"task": "run verification-before-completion for Phase 1 SCs", "issue_number": 1278, "phase": 1}` | SC-1, SC-2, SC-16 |
| G10: adversarial-audit | sub-task | yes (blind) | general | `{"task": "run adversarial-audit --task plan-fidelity and --task concern-separation for Phase 1", "issue_number": 1278, "phase": 1, "audit_phase": "plan_creation"}` | SC-1, SC-2, SC-16 |
| G11: cross-validate | sub-task | yes (blind) | general | `{"task": "cross-validate Phase 1 changes against spec SCs", "issue_number": 1278, "phase": 1}` | SC-1, SC-2, SC-16 |
| G12: regression-check | sub-task | yes (blind) | general | `{"task": "verify no regressions in existing SKILL.md functionality", "issue_number": 1278, "phase": 1}` | SC-1, SC-2, SC-16 |
| G13: review-prep | sub-task | yes (blind) | general | `{"task": "prepare review summary for Phase 1", "issue_number": 1278, "phase": 1}` | SC-1, SC-2, SC-16 |
| G14: exec-summary | sub-task | yes (blind) | general | `{"task": "produce execution summary for Phase 1", "issue_number": 1278, "phase": 1}` | SC-1, SC-2, SC-16 |

### Concern Boundary
- **Leaving:** No prior concern (first phase)
- **Entering:** Identity framing — Persona sections in both SKILL.md files
- **Handoff:** Modified SKILL.md files with correct Persona sections feed into Phase 2

---

## Phase 2: Add dispatch-annotated checklists to SKILL.md Operating Protocols

**Concern:** Operating Protocol structure — replace bullet-item Operating Protocols with sequential `- [ ] N.` checklists annotated with dispatch type, task name, contract YAML paths, template reference, and chain annotation.

**Files:** `.opencode/skills/spec-creation/SKILL.md`, `.opencode/skills/writing-plans/SKILL.md`

**SCs:** SC-3, SC-4

### Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "verify spec coherence for Phase 2", "issue_number": 1278, "phase": 2}` | SC-3, SC-4 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "capture pre-change Operating Protocol sections from both SKILL.md files", "issue_number": 1278, "phase": 2}` | SC-3, SC-4 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "write behavioral RED test verifying agent does NOT follow dispatch-annotated checklist format", "issue_number": 1278, "phase": 2}` | SC-3, SC-4 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "verify RED test fails", "issue_number": 1278, "phase": 2}` | SC-3, SC-4 |
| G5: green-phase | sub-task | yes (blind) | general | `{"task": "replace Operating Protocol bullet items with dispatch-annotated checklists per spec Phase 2", "issue_number": 1278, "phase": 2}` | SC-3, SC-4 |
| G6: checkpoint-commit | inline | N/A | N/A | — | SC-3, SC-4 |
| G7: structural-checks | sub-task | yes (blind) | general | `{"task": "verify SC-3, SC-4 via grep assertions", "issue_number": 1278, "phase": 2}` | SC-3, SC-4 |
| G8: green-doublecheck | sub-task | yes (blind) | general | `{"task": "re-run behavioral GREEN test", "issue_number": 1278, "phase": 2}` | SC-3, SC-4 |
| G9: green-vbc | sub-task | yes (blind) | general | `{"task": "run verification-before-completion for Phase 2 SCs", "issue_number": 1278, "phase": 2}` | SC-3, SC-4 |
| G10: adversarial-audit | sub-task | yes (blind) | general | `{"task": "run adversarial-audit --task plan-fidelity and --task concern-separation for Phase 2", "issue_number": 1278, "phase": 2, "audit_phase": "plan_creation"}` | SC-3, SC-4 |
| G11: cross-validate | sub-task | yes (blind) | general | `{"task": "cross-validate Phase 2 against spec", "issue_number": 1278, "phase": 2}` | SC-3, SC-4 |
| G12: regression-check | sub-task | yes (blind) | general | `{"task": "verify no regressions", "issue_number": 1278, "phase": 2}` | SC-3, SC-4 |
| G13: review-prep | sub-task | yes (blind) | general | `{"task": "prepare review summary for Phase 2", "issue_number": 1278, "phase": 2}` | SC-3, SC-4 |
| G14: exec-summary | sub-task | yes (blind) | general | `{"task": "produce execution summary for Phase 2", "issue_number": 1278, "phase": 2}` | SC-3, SC-4 |

### Concern Boundary
- **Leaving:** Persona identity framing (Phase 1)
- **Entering:** Operating Protocol structure — checklist format with dispatch annotations
- **Handoff:** Phase 1 modified SKILL.md files are the base for Phase 2 checklist additions

---

## Phase 3: Create contract template YAML files

**Concern:** Contract templates — create template YAML files under `.opencode/skills/spec-creation/contracts/` and `.opencode/skills/writing-plans/contracts/` with `{{placeholder}}` values.

**Files:**
- `.opencode/skills/spec-creation/contracts/requirements-input-template.yaml`
- `.opencode/skills/spec-creation/contracts/write-input-template.yaml`
- `.opencode/skills/spec-creation/contracts/write-output-template.yaml`
- `.opencode/skills/writing-plans/contracts/create-input-template.yaml`
- `.opencode/skills/writing-plans/contracts/create-output-template.yaml`

**SCs:** SC-7, SC-8, SC-9, SC-10, SC-11, SC-12

### Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "verify spec coherence for Phase 3", "issue_number": 1278, "phase": 3}` | SC-7, SC-8, SC-9, SC-10, SC-11, SC-12 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "verify no contract template files exist yet", "issue_number": 1278, "phase": 3}` | SC-7, SC-8, SC-9, SC-10, SC-11, SC-12 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "write RED test verifying template files do NOT exist", "issue_number": 1278, "phase": 3}` | SC-7, SC-8, SC-9, SC-10, SC-11, SC-12 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "verify RED test confirms files absent", "issue_number": 1278, "phase": 3}` | SC-7, SC-8, SC-9, SC-10, SC-11, SC-12 |
| G5: green-phase | sub-task | yes (blind) | general | `{"task": "create 5 contract template YAML files with {{placeholder}} values per spec Phase 3", "issue_number": 1278, "phase": 3}` | SC-7, SC-8, SC-9, SC-10, SC-11, SC-12 |
| G6: checkpoint-commit | inline | N/A | N/A | — | SC-7, SC-8, SC-9, SC-10, SC-11, SC-12 |
| G7: structural-checks | sub-task | yes (blind) | general | `{"task": "verify SC-7 through SC-12 via file existence and grep assertions", "issue_number": 1278, "phase": 3}` | SC-7, SC-8, SC-9, SC-10, SC-11, SC-12 |
| G8: green-doublecheck | sub-task | yes (blind) | general | `{"task": "re-run GREEN test verifying all 5 template files exist with placeholders", "issue_number": 1278, "phase": 3}` | SC-7, SC-8, SC-9, SC-10, SC-11, SC-12 |
| G9: green-vbc | sub-task | yes (blind) | general | `{"task": "run verification-before-completion for Phase 3 SCs", "issue_number": 1278, "phase": 3}` | SC-7, SC-8, SC-9, SC-10, SC-11, SC-12 |
| G10: adversarial-audit | sub-task | yes (blind) | general | `{"task": "run adversarial-audit --task plan-fidelity and --task concern-separation for Phase 3", "issue_number": 1278, "phase": 3, "audit_phase": "plan_creation"}` | SC-7, SC-8, SC-9, SC-10, SC-11, SC-12 |
| G11: cross-validate | sub-task | yes (blind) | general | `{"task": "cross-validate Phase 3 against spec", "issue_number": 1278, "phase": 3}` | SC-7, SC-8, SC-9, SC-10, SC-11, SC-12 |
| G12: regression-check | sub-task | yes (blind) | general | `{"task": "verify no regressions", "issue_number": 1278, "phase": 3}` | SC-7, SC-8, SC-9, SC-10, SC-11, SC-12 |
| G13: review-prep | sub-task | yes (blind) | general | `{"task": "prepare review summary for Phase 3", "issue_number": 1278, "phase": 3}` | SC-7, SC-8, SC-9, SC-10, SC-11, SC-12 |
| G14: exec-summary | sub-task | yes (blind) | general | `{"task": "produce execution summary for Phase 3", "issue_number": 1278, "phase": 3}` | SC-7, SC-8, SC-9, SC-10, SC-11, SC-12 |

### Concern Boundary
- **Leaving:** Operating Protocol checklists (Phase 2)
- **Entering:** Contract template YAML files — static definitions in skill directories
- **Handoff:** Phase 2 SKILL.md changes reference template paths that Phase 3 creates

---

## Phase 4: Reformat task files to pure `- [ ] N.` format

**Concern:** Task file format — convert write.md and create.md to pure checklist format with no `### Step` headers.

**Files:** `.opencode/skills/spec-creation/tasks/write.md`, `.opencode/skills/writing-plans/tasks/create.md`

**SCs:** SC-5, SC-6

### Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "verify spec coherence for Phase 4", "issue_number": 1278, "phase": 4}` | SC-5, SC-6 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "capture pre-change format of write.md and create.md", "issue_number": 1278, "phase": 4}` | SC-5, SC-6 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "write RED test verifying write.md and create.md still have ### Step headers", "issue_number": 1278, "phase": 4}` | SC-5, SC-6 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "verify RED test confirms headers present", "issue_number": 1278, "phase": 4}` | SC-5, SC-6 |
| G5: green-phase | sub-task | yes (blind) | general | `{"task": "reformat write.md and create.md to pure - [ ] N. checklist format per spec Phase 4", "issue_number": 1278, "phase": 4}` | SC-5, SC-6 |
| G6: checkpoint-commit | inline | N/A | N/A | — | SC-5, SC-6 |
| G7: structural-checks | sub-task | yes (blind) | general | `{"task": "verify SC-5, SC-6 via grep assertions", "issue_number": 1278, "phase": 4}` | SC-5, SC-6 |
| G8: green-doublecheck | sub-task | yes (blind) | general | `{"task": "re-run GREEN test verifying no ### Step headers remain", "issue_number": 1278, "phase": 4}` | SC-5, SC-6 |
| G9: green-vbc | sub-task | yes (blind) | general | `{"task": "run verification-before-completion for Phase 4 SCs", "issue_number": 1278, "phase": 4}` | SC-5, SC-6 |
| G10: adversarial-audit | sub-task | yes (blind) | general | `{"task": "run adversarial-audit --task plan-fidelity and --task concern-separation for Phase 4", "issue_number": 1278, "phase": 4, "audit_phase": "plan_creation"}` | SC-5, SC-6 |
| G11: cross-validate | sub-task | yes (blind) | general | `{"task": "cross-validate Phase 4 against spec", "issue_number": 1278, "phase": 4}` | SC-5, SC-6 |
| G12: regression-check | sub-task | yes (blind) | general | `{"task": "verify no regressions", "issue_number": 1278, "phase": 4}` | SC-5, SC-6 |
| G13: review-prep | sub-task | yes (blind) | general | `{"task": "prepare review summary for Phase 4", "issue_number": 1278, "phase": 4}` | SC-5, SC-6 |
| G14: exec-summary | sub-task | yes (blind) | general | `{"task": "produce execution summary for Phase 4", "issue_number": 1278, "phase": 4}` | SC-5, SC-6 |

### Concern Boundary
- **Leaving:** Contract template YAML files (Phase 3)
- **Entering:** Task file format — pure checklist format for sub-agent consumption
- **Handoff:** Phase 4 reformatted task files are read by sub-agents only (orchestrator never reads them)

---

## Phase 5: Z3 SAT and plan tool validation

**Concern:** Validation — generate solve contracts, run solve check, run plan plan for both workflows.

**Files:** `.opencode/.issues/1278/` (solve contracts and plan artifacts)

**SCs:** SC-13, SC-14, SC-15

### Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "verify spec coherence for Phase 5", "issue_number": 1278, "phase": 5}` | SC-13, SC-14, SC-15 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "verify no solve/plan artifacts exist yet", "issue_number": 1278, "phase": 5}` | SC-13, SC-14, SC-15 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "write RED test verifying solve check and plan plan are NOT yet passing", "issue_number": 1278, "phase": 5}` | SC-13, SC-14, SC-15 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "verify RED test confirms tools not yet passing", "issue_number": 1278, "phase": 5}` | SC-13, SC-14, SC-15 |
| G5: green-phase | sub-task | yes (blind) | general | `{"task": "generate solve contracts for both workflows, run solve check, run plan plan, document results", "issue_number": 1278, "phase": 5}` | SC-13, SC-14, SC-15 |
| G6: checkpoint-commit | inline | N/A | N/A | — | SC-13, SC-14, SC-15 |
| G7: structural-checks | sub-task | yes (blind) | general | `{"task": "verify solve/plan artifacts exist", "issue_number": 1278, "phase": 5}` | SC-13, SC-14, SC-15 |
| G8: green-doublecheck | sub-task | yes (blind) | general | `{"task": "re-run behavioral GREEN test verifying solve returns SAT and plan returns SOLVED", "issue_number": 1278, "phase": 5}` | SC-13, SC-14, SC-15 |
| G9: green-vbc | sub-task | yes (blind) | general | `{"task": "run verification-before-completion for Phase 5 SCs", "issue_number": 1278, "phase": 5}` | SC-13, SC-14, SC-15 |
| G10: adversarial-audit | sub-task | yes (blind) | general | `{"task": "run adversarial-audit --task plan-fidelity and --task concern-separation for Phase 5", "issue_number": 1278, "phase": 5, "audit_phase": "plan_creation"}` | SC-13, SC-14, SC-15 |
| G11: cross-validate | sub-task | yes (blind) | general | `{"task": "cross-validate Phase 5 against spec", "issue_number": 1278, "phase": 5}` | SC-13, SC-14, SC-15 |
| G12: regression-check | sub-task | yes (blind) | general | `{"task": "verify no regressions", "issue_number": 1278, "phase": 5}` | SC-13, SC-14, SC-15 |
| G13: review-prep | sub-task | yes (blind) | general | `{"task": "prepare review summary for Phase 5", "issue_number": 1278, "phase": 5}` | SC-13, SC-14, SC-15 |
| G14: exec-summary | sub-task | yes (blind) | general | `{"task": "produce execution summary for Phase 5", "issue_number": 1278, "phase": 5}` | SC-13, SC-14, SC-15 |

### Concern Boundary
- **Leaving:** Task file reformatting (Phase 4)
- **Entering:** Validation — Z3 SAT and plan tool verification
- **Handoff:** Phase 1-4 changes are the subject of Phase 5 validation

---

## Inter-Phase Handoff

Between each phase, the orchestrator MUST:

1. Update Z3 state: `./.opencode/tools/solve state update --state-path .opencode/.issues/1278/<skill>-state.yaml`
2. Run `./.opencode/tools/solve check --contract-path .opencode/.issues/1278/<skill>-contract.yaml` — confirm SAT
3. Verify checkpoint tag: `git tag -l 'opencode-config/checkpoint/1278/phase-<N>-.opencode'`
4. Append lifecycle manifest event for phase N completion

## Post-All-Phases Sweep

After Phase 5 final gate:

- [ ] Finishing checklist — route to finishing sub-agent: `git status` clean, lint/typecheck, coverage
- [ ] PR creation — route to `git-workflow pr-creation`, extract `html_url` from response
- [ ] Post-merge cleanup — route to `git-workflow cleanup`

## SC Coverage

| SC ID | Phase | Evidence Type | Verification Method |
|-------|-------|---------------|---------------------|
| SC-1 | 1 | `string` | `grep -q "This skill produces specs by dispatching sub-agents" .opencode/skills/spec-creation/SKILL.md` |
| SC-2 | 1 | `string` | `grep -q "This skill produces plans by dispatching sub-agents" .opencode/skills/writing-plans/SKILL.md` |
| SC-3 | 2 | `string` | `grep -c "^- \[ \] \[sub-task:" .opencode/skills/spec-creation/SKILL.md` >= 4 AND `grep -c "chain:" .opencode/skills/spec-creation/SKILL.md` >= 10 |
| SC-4 | 2 | `string` | `grep -c "^- \[ \] \[sub-task:" .opencode/skills/writing-plans/SKILL.md` >= 2 AND `grep -c "chain:" .opencode/skills/writing-plans/SKILL.md` >= 6 |
| SC-5 | 4 | `string` | `grep -c "^- \[ \]" .opencode/skills/spec-creation/tasks/write.md` > 0 AND `grep -c "^### Step" .opencode/skills/spec-creation/tasks/write.md` == 0 |
| SC-6 | 4 | `string` | `grep -c "^- \[ \]" .opencode/skills/writing-plans/tasks/create.md` > 0 AND `grep -c "^### Steps" .opencode/skills/writing-plans/tasks/create.md` == 0 |
| SC-7 | 3 | `string` | `test -f .opencode/skills/spec-creation/contracts/requirements-input-template.yaml` AND `grep -q "{{"` that file |
| SC-8 | 3 | `string` | `test -f .opencode/skills/spec-creation/contracts/write-input-template.yaml` AND `grep -q "{{"` that file |
| SC-9 | 3 | `string` | `test -f .opencode/skills/spec-creation/contracts/write-output-template.yaml` AND `grep -q "{{"` that file |
| SC-10 | 3 | `string` | `test -f .opencode/skills/writing-plans/contracts/create-input-template.yaml` AND `grep -q "{{"` that file |
| SC-11 | 3 | `string` | `test -f .opencode/skills/writing-plans/contracts/create-output-template.yaml` AND `grep -q "{{"` that file |
| SC-12 | 3 | `string` | Every `template:` path in both SKILL.md Operating Protocols must exist |
| SC-13 | 5 | `behavioral` | `./.opencode/tools/solve check --contract-path .opencode/.issues/1278/spec-creation-contract.yaml` returns SAT |
| SC-14 | 5 | `behavioral` | `./.opencode/tools/solve check --contract-path .opencode/.issues/1278/writing-plans-contract.yaml` returns SAT |
| SC-15 | 5 | `behavioral` | `./.opencode/tools/plan plan --problem .opencode/.issues/1278/phase-plan-problem.yaml` returns SOLVED_SATISFICING or SOLVED_OPTIMALLY |
| SC-16 | 1 | `string` | `grep -c "intelligent agents, not dumb terminals" .opencode/skills/spec-creation/SKILL.md` == 1 AND same for writing-plans |

## Authorization Context

```
authorization_scope: for_pr
halt_at: pr_created
pr_strategy: stacked
pipeline_phase: plan_creation
authorization_source: "User approved .opencode#1278 on 2026-06-18"
```
