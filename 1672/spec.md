# [SPEC] DiMo-Aligned Adversarial Audit — Replace Cross-Model Auditor Dispatch with Role-Differentiated Agent Chaining

## Problem Statement

The current adversarial-audit system has grown into a high-maintenance, cloud-dependent architecture with a brittle failure mode:

| Metric | Current Value |
|--------|--------------|
| Auditor card files | 4 model-specific cards (415 lines each = 1,660 total) at `.opencode/agents/auditor-*.md` |
| `resolve-models` tool | 221 lines — randomly selects 2 auditors from different model families |
| `qualified-auditor-pool.sh` | 19 lines |
| Total eliminated lines | ~1,900 |
| Dispatch contract fields | 3 (`spec_local_dir`, `artifact_evidence_dir`, `audit_phase`) |
| Task files | 15, each with generic auditor persona + conditional logic on `audit_phase` |
| Cross-validate | Separate general sub-agent (not integrated into chain) |
| Dispatch model | Sequential: auditor-1 → if PASS → auditor-2 → if PASS → cross-validate |
| Remediation | Restart from `resolve-models` on any FAIL |

**Critical failure mode — `INSUFFICIENT_FAMILIES`:** When only one model family is available locally (e.g., only `deepseek` variants installed), `resolve-models` cannot select 2 auditors from different families and returns `INSUFFICIENT_FAMILIES`. This blocks ALL adversarial audits — the entire pipeline halts because the dispatch precondition cannot be met. This is a hard dependency on having ≥2 model families installed, which is not guaranteed in local/CI environments.

## Proposed Solution

Replace the cross-model-family adversarial audit system with a **DiMo-aligned architecture**: same-model, role-differentiated agent chaining.

### DiMo's Four Roles

| Role | Function |
|------|----------|
| **Generator** | Produces initial answer/verdict |
| **Evaluator** | Assesses correctness, identifies gaps |
| **Knowledge Supporter** | Retrieves and validates evidence |
| **Path Provider** | Constructs reasoning chains |

### DiMo's Two Interaction Protocols

| Protocol | Pattern | Used For |
|----------|---------|----------|
| **Divergent mode** | Parallel proposals → synthesis → discussion | Open-ended audits: spec-audit, content-audit, drift-detection |
| **Logical mode** | Evaluate → Refine → Judge loop | Structured audits: verification-audit, plan-fidelity, closure-verification |

### Proposed Architecture

| Component | Current | Proposed |
|-----------|---------|----------|
| Auditor cards | 4 model-specific (1,660 lines) at `.opencode/agents/auditor-*.md` | 1 role-differentiated card at `.opencode/agents/auditor-role.md` |
| `resolve-models` | 221 lines at `.opencode/tools/resolve-models` | **Eliminated** |
| `qualified-auditor-pool.sh` | 19 lines | **Eliminated** |
| Dispatch contract | 3 fields incl. `audit_phase` | 2 fields (no `audit_phase`) |
| Task files | 15 with conditionals at `.opencode/skills/adversarial-audit/tasks/` | 15 self-contained, each with embedded DiMo role persona |
| Cross-validate | Separate sub-agent | Integrated as **Judger** role in chain |
| Dispatch model | Sequential cross-model | Sequential per-task checklist: role-1 → role-2 → role-3 → etc. |
| Artifact flow | Auditors blind to each other | Downstream roles read upstream artifacts |
| Pre-clean | None | Remove only this task's artifact files before each cycle |
| Artifact directory | Timestamped paths | `./tmp/{issue-N}/artifacts/{task-name}/` with role-named files |
| Remediation | Restart from `resolve-models` | Restart from pre-clean step |
| Model dependency | ≥2 model families | 1 model family (any) |

### Artifact Directory Structure

```
./tmp/{issue-N}/artifacts/{task-name}/
  evidence.yaml     ← Knowledge Supporter output
  reasoning.yaml    ← Path Provider output
  verdict.yaml      ← Evaluator output
  judgment.yaml     ← Judger output
```

### Task Checklist Pattern

```
- [ ] 0. Pre-clean: remove artifact files for this task
- [ ] 1. Dispatch Knowledge Supporter → writes evidence.yaml
- [ ] 2. If FAIL: remediate, restart from step 0
- [ ] 3. Dispatch Path Provider → reads evidence.yaml, writes reasoning.yaml
- [ ] 4. If FAIL: remediate, restart from step 0
- [ ] 5. Dispatch Evaluator → reads evidence.yaml + reasoning.yaml, writes verdict.yaml
- [ ] 6. If FAIL: remediate, restart from step 0
- [ ] 7. Dispatch Judger → reads all artifacts, writes judgment.yaml
- [ ] 8. If FAIL: remediate, restart from step 0
```

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | All 4 model-specific auditor cards removed from `.opencode/agents/` | `structural` | File existence check |
| SC-2 | `resolve-models` tool removed from `.opencode/tools/` | `structural` | File existence check |
| SC-3 | `qualified-auditor-pool.sh` removed | `structural` | File existence check |
| SC-4 | 1 role-differentiated auditor card (`auditor-role.md`) exists at `.opencode/agents/` | `structural` | File existence check |
| SC-5 | Dispatch contract reduced to 2 fields | `string` | Grep task files |
| SC-6 | All 15 task files self-contained with embedded DiMo role persona | `string` | Grep task files |
| SC-7 | Artifact directory uses `./tmp/{issue-N}/artifacts/{task-name}/` | `string` | Grep task files |
| SC-8 | Downstream roles read upstream artifacts | `string` | Grep task files |
| SC-9 | Pre-clean step at top of each task checklist | `string` | Grep task files |
| SC-10 | Sequential dispatch per task checklist | `string` | Grep task files |
| SC-11 | Remediation restarts from pre-clean step | `string` | Grep task files |
| SC-12 | No `INSUFFICIENT_FAMILIES` error state exists | `string` | Grep codebase |
| SC-13 | Behavioral: agent dispatches DiMo role chain | `behavioral` | `opencode-cli run` |
| SC-14 | Behavioral: agent handles single-model-family environment | `behavioral` | `opencode-cli run` |

## Phases

### Phase 1: Eliminate Cross-Model Infrastructure
- Remove 4 auditor card files from `.opencode/agents/auditor-*.md`
- Remove `resolve-models` tool from `.opencode/tools/resolve-models`
- Remove `qualified-auditor-pool.sh`
- Remove `INSUFFICIENT_FAMILIES` error handling from any remaining code

### Phase 2: Create DiMo Role-Differentiated Auditor Card
- Create single `auditor-role.md` at `.opencode/agents/` defining all 4 DiMo roles
- Define both interaction protocols: Divergent mode and Logical mode
- Define Judger role for cross-validate integration

### Phase 3: Refactor 15 Task Files
- Remove `audit_phase` from dispatch contracts
- Embed DiMo role persona in each task file
- Add pre-clean step (step 0) to each task checklist
- Specify artifact read/write paths per role
- Specify downstream role read chain
- Integrate cross-validate as Judger role
- Convert dispatch model to sequential role chain
- Update remediation sections

### Phase 4: Update SKILL.md and Dispatch Logic
- Update `adversarial-audit/SKILL.md` to reference DiMo architecture
- Remove `resolve-models` from dispatch routing
- Update dispatch contract documentation

### Phase 5: Behavioral Tests
- Write behavioral enforcement test for SC-13
- Write behavioral enforcement test for SC-14

## Change Control

| Section | Scope |
|---------|-------|
| `.opencode/agents/auditor-deepseek-flash.md` | Delete |
| `.opencode/agents/auditor-gemma4.md` | Delete |
| `.opencode/agents/auditor-mistral-large.md` | Delete |
| `.opencode/agents/auditor-qwen3.5.md` | Delete |
| `.opencode/agents/auditor-role.md` | Create (new) |
| `.opencode/tools/resolve-models` | Delete |
| `.opencode/tests/qualification/qualified-auditor-pool.sh` | Delete |
| `.opencode/skills/adversarial-audit/tasks/*.md` | Modify (15 files) |
| `.opencode/skills/adversarial-audit/SKILL.md` | Modify |
| `.opencode/tests/behaviors/` | Create 2 behavioral test scripts |
