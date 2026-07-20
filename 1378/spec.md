## Problem

Spec authors (AI agents) routinely declare `structural` evidence type for SCs that verify changes to agent-facing configuration files — SKILL.md descriptions, trigger dispatch tables, invocation tables, sub-agent routing sections, task files, and enforcement blocks. These changes affect **runtime agent behavior** (dispatch decisions, tool selection, pipeline routing, enforcement gate outcomes), which means the BEH-EV classification gate (`000-critical-rules.md` §critical-rules-BEH-EV) automatically uplifts them to `behavioral`.

The result is a systematic mismatch: specs pass content-verification (structural evidence exists) but fail cross-validate (EVIDENCE_TYPE_MISMATCH). The mismatch is caught at audit time, not at spec-writing time — the most expensive possible detection point.

**Root cause:** The spec-creation workflow has no mandatory step for classifying whether a change affects runtime agent behavior. The author chooses evidence type based on convenience ("structural is easier to verify") rather than substrate classification ("does this change affect runtime behavior?").

**Evidence:** Issue #1376's spec declared all 15 SCs as `structural`. The cross-validate correctly flagged all 15 as EVIDENCE_TYPE_MISMATCH because SKILL.md descriptions, trigger dispatch tables, invocation tables, and sub-agent routing sections all control what the agent does at runtime.

## Defects

| # | Location | Defect | Severity |
|---|----------|--------|----------|
| 1 | `spec-creation/tasks/write.md` | No mandatory BEH-EV classification step when authoring SCs. Author can declare `structural` for runtime-behavioral changes without being flagged. | CRITICAL |
| 2 | `writing-plans/tasks/create.md` | Plan format validation rules (lines 106-119) have no evidence type coherence check. A plan should flag when an SC declares `structural` but the affected files are agent-facing configuration. | MAJOR |
| 3 | `adversarial-audit/tasks/verification-audit.md` | Audit methodology accepts structural evidence (grep, ls) for behavioral SCs without a pre-check. Should return EVIDENCE_TYPE_MISMATCH at audit time, not silently accept. | MAJOR |
| 4 | `080-code-standards.md` §Evidence Type Taxonomy | No explicit presumption that changes to SKILL.md, task files, and guidelines are runtime-behavioral. Adding this would help spec authors self-correct. | MINOR |

## Fix

### 1. `spec-creation/tasks/write.md` — Mandatory BEH-EV classification step

Add a mandatory step between SC definition and spec finalization:

```
### Step N: Evidence Type Classification Gate

For each SC in the spec, classify whether the change affects runtime agent behavior:

- **YES** → evidence type MUST be `behavioral`. The author MUST NOT declare `structural` or `string` to make verification easier.
- **NO** → evidence type may be `structural`, `string`, `semantic`, or `behavioral` as appropriate.

**Classification rule (substrate-determined):** The question "does this change affect runtime behavior?" is determined by what the change DOES, not by what the author intends. A change to SKILL.md description, trigger dispatch table, invocation table, sub-agent routing, task file procedure, or enforcement block is presumptively runtime-behavioral.

**Presumptive runtime-behavioral file types:**
- `SKILL.md` — any section (description, overview, trigger dispatch table, invocation, sub-agent routing)
- `tasks/*.md` — any task file (procedure steps, entry/exit criteria, routing instructions)
- `guidelines/*.md` — any guideline file (enforcement blocks, symbolic rules, trigger patterns)
- `enforcement/*.md` — any enforcement module
- `contracts/*.yaml` — any contract template

**Evidence:** If the SC is classified as behavioral, the verification method MUST include a behavioral test (e.g., `opencode-cli run` with stderr inspection, or clean-room semantic inspector). Structural evidence (grep, ls) is INSUFFICIENT for behavioral SCs.
```

### 2. `writing-plans/tasks/create.md` — Evidence type coherence check

Add a validation rule to the plan format validation section:

```
13. Evidence type coherence: For each SC, check if the affected files are agent-facing configuration (SKILL.md, tasks/*.md, guidelines/*.md, enforcement/*.md). If YES and the SC declares `structural` or `string` evidence type, FLAG as EVIDENCE_TYPE_MISMATCH — the plan should not proceed until the spec is corrected.
```

### 3. `adversarial-audit/tasks/verification-audit.md` — Pre-check evidence type

Add a step between Step 4 (SC_CONFLICT Detection) and Step 5 (Validate Structural SCs):

```
### Step 4.5: Evidence Type Pre-Check

Before evaluating any SC, verify the evidence type is correct for the change being verified:

- [ ] 1. For each SC, read the affected file paths from the spec
- [ ] 2. If the affected files are agent-facing configuration (SKILL.md, tasks/*.md, guidelines/*.md, enforcement/*.md):
   - The SC's evidence type MUST be `behavioral` (per BEH-EV classification gate)
   - If the SC declares `structural` or `string`: return EVIDENCE_TYPE_MISMATCH with FAIL verdict
- [ ] 3. If the affected files are NOT agent-facing configuration:
   - Accept the declared evidence type at face value
- [ ] 4. Record the evidence type check result in the verdict artifact
```

### 4. `080-code-standards.md` §Evidence Type Taxonomy — Presumption for agent-facing files

Add to the Evidence Type Taxonomy section:

> **Presumption for agent-facing configuration:** Changes to SKILL.md, task files (`tasks/*.md`), guidelines (`guidelines/*.md`), and enforcement modules (`enforcement/*.md`) are presumptively runtime-behavioral. The author MUST classify each SC against the substrate-determined question ("does this change affect runtime behavior?") rather than declaring `structural` for convenience. This presumption can be rebutted only with explicit justification in the spec body.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `spec-creation/tasks/write.md` contains mandatory BEH-EV classification step with presumptive runtime-behavioral file types | structural | `grep` for "Evidence Type Classification Gate" and "presumptively runtime-behavioral" in write.md |
| SC-2 | `writing-plans/tasks/create.md` validation rules include evidence type coherence check | structural | `grep` for "evidence type coherence" in create.md |
| SC-3 | `adversarial-audit/tasks/verification-audit.md` has Step 4.5 Evidence Type Pre-Check | structural | `grep` for "Evidence Type Pre-Check" in verification-audit.md |
| SC-4 | `080-code-standards.md` §Evidence Type Taxonomy contains presumption for agent-facing configuration files | structural | `grep` for "presumptively runtime-behavioral" in 080-code-standards.md |
| SC-5 | Behavioral enforcement test: spec-creation agent declares `behavioral` for SKILL.md change SCs | behavioral | `opencode-cli run` with prompt to create spec for SKILL.md change → verify SCs declare `behavioral` not `structural` |
| SC-6 | Behavioral enforcement test: verification-audit returns EVIDENCE_TYPE_MISMATCH for structural evidence on behavioral SC | behavioral | `opencode-cli run` with prompt to audit spec with structural SCs for SKILL.md change → verify EVIDENCE_TYPE_MISMATCH verdict |

## Labels

`[SPEC-FIX]`, `skill`, `guideline`

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)