---
remote_issue: 1204
remote_url: "https://github.com/michael-conrad/.opencode/issues/1204"
last_sync: "2026-06-14T17:36:26Z"
source: github
---

## Summary

Hundreds of "agent MUST" rules across guidelines and skills have no runtime enforcement — the agent reads the rule and chooses to follow it voluntarily. Research confirms no framework has solved this problem. The practical middle ground between advisory prose and behavioral tests is **semantic verification**: each rule becomes an SC in the dispatch table standard gate set, verified by a clean-room VbC sub-agent (G11) that reads the phase's deliverables and judges compliance.

This spec defines the canonical rule registry, the rule-check gate protocol, and the VbC expansion to verify rule compliance alongside SC verification. It does not replace #1196 (yaml+symbolic → Z3 contracts) — that spec handles formal constraint checking for pipeline-invariant rules. This spec handles everything else: rules about dispatch table structure, output format, communication patterns, and code conventions that semantic inspection can verify.

## Core Principle

A rule is either:
1. **Externally enforced** — backed by a hook, Z3 evidence gate, or behavioral test. Already handled by existing mechanisms.
2. **Semantically verified** — a clean-room VbC sub-agent reads the deliverable and judges compliance against the rule text. This spec.
3. **Advisory** — explicitly labeled as best-practice guidance with no enforcement. No action needed.

This spec targets category 2: rules that should not be advisory but cannot have behavioral tests or formal contracts.

## Root Cause

Rules were written as prose in guidelines with no corresponding SC in the dispatch table gate set. The VbC gate (G11) verifies spec SCs but does not check guideline compliance. The semantic infrastructure exists (clean-room sub-agent, read + judge) — the binding between guidelines and SCs is missing.

## Affected Components

| Component | Change |
|-----------|--------|
| `.opencode/.guidelines/rules-registry.yaml` | New file: canonical mapping of guideline rules → SC identifiers with evidence type and applicability scope |
| `.opencode/skills/verification-before-completion/` | Add rule-check gate protocol: read registry, fetch applicable rules, deliverable scope, PASS/FAIL per rule |
| `.opencode/skills/implementation-pipeline/SKILL.md` | Add standard gate G12: RULE-COMPLIANCE (after adversarial-audit and cross-validate, before regression-check) |
| `.opencode/guidelines/*.md` | No changes to rule prose — rules stay as written. The registry maps them to SCs. |
| `.opencode/.guidelines/INDEX.md` | Add entry for rules-registry.yaml |

## Spec

### Phase 1: Create Rules Registry

Create `.opencode/.guidelines/rules-registry.yaml` — a single YAML file mapping enforceable guideline rules to SC identifiers:

```yaml
# Each entry maps a guideline rule to an SC that the VbC sub-agent checks.
# applicability: which deliverables the rule applies to
#   dispatch_table: the phase's dispatch table rows
#   plan: the plan document
#   spec: the spec document
#   code: implementation code
#   output: any chat or posted content
registry:
  - rule_ref: "000-critical-rules.md §critical-rules-034 — no orchestrator inline work"
    sc_id: "RC-001"
    applicability: [dispatch_table, code]
    evidence_type: semantic
    description: "All dispatch table rows with sub-task dispatch type must use task(). No file edits or analysis performed by orchestrator."

  - rule_ref: "000-critical-rules.md §critical-rules-044 — no preloaded sub-agent context"
    sc_id: "RC-002"
    applicability: [dispatch_table]
    evidence_type: semantic
    description: "Every dispatch table row's Receives Context column must contain a task objective, not file paths, step definitions, or expected outcomes."

  - rule_ref: "020-go-prohibitions.md §1 — no solicitation"
    sc_id: "RC-003"
    applicability: [output]
    evidence_type: semantic
    description: "Agent output must not solicit work, phases, steps, or approvals from the developer."

  - rule_ref: "020-go-prohibitions.md §1 — no question tool"
    sc_id: "RC-004"
    applicability: [output]
    evidence_type: semantic
    description: "Agent must not use the question tool or present multiple-choice options."

  - rule_ref: "080-code-standards.md §Print Statements — no narration prints"
    sc_id: "RC-005"
    applicability: [code]
    evidence_type: semantic
    description: "Code must not contain print statements that narrate changes, signal features, or self-document."

  - rule_ref: "091-incremental-build.md §Per-Item TDD Cycle — RED before GREEN"
    sc_id: "RC-006"
    applicability: [plan, dispatch_table]
    evidence_type: semantic
    description: "Every phase dispatch table must have a RED gate (expected FAIL) before its GREEN gate (expected PASS)."

  - rule_ref: "060-tool-usage.md §2 — no absolute paths"
    sc_id: "RC-007"
    applicability: [code, output]
    evidence_type: semantic
    description: "No absolute paths beginning with / in any tool call or command."
```

Initial entries limited to high-signal rules that are frequently violated and trivially checkable by semantic inspection. The registry is append-only — new rules are added via PR.

The SC prefix is `RC-{N}` (Rule Compliance) to distinguish from spec SCs.

### Phase 2: Add RULE-COMPLIANCE Gate to Standard Gate Set

Add G12 to the standard implementation-pipeline gate set in `implementation-pipeline/SKILL.md`:

| Step Label | Dispatches To | Artifact Produced |
|------------|---------------|-------------------|
| `rule-compliance` | `verification-before-completion` with rule registry context | rule compliance report YAML |

Placement: after `cross-validate` (G11 in current numbering), before `regression-check` (G13). Renumber steps G14-G16 accordingly.

The gate receives:
- The applicable rules from `rules-registry.yaml` filtered by `applicability` scope matching the phase's deliverable type
- The phase's deliverables (dispatch table rows, plan text, code diff, output)
- No orchestrator reasoning, no cached results

### Phase 3: Add Rule-Check Protocol to VbC

In `verification-before-completion`, add a task file `tasks/rule-compliance.md`:

1. Load `rules-registry.yaml` — filter entries by `applicability` matching the phase's deliverable type
2. For each applicable rule:
   - Read the rule text from the referenced guideline file
   - Read the phase deliverable (dispatch table, plan, code diff, or output)
   - Judge: does the deliverable comply with the rule?
   - Return PASS, FAIL, or N/A (rule does not apply to this deliverable)
3. For each FAIL: cite the specific violation in the deliverable (line number, section, or excerpt)
4. Produce artifact at `./tmp/{issue-N}/artifacts/rule-compliance-{phase}.yaml`

Entry criteria: rules-registry.yaml exists and is parseable, rule_refs are resolvable (guideline files exist at referenced locations).

Exit criteria: all applicable rules RETURN PASS or N/A. If any FAIL, pipeline blocks — orchestrator must remediate and re-run G12.

### Phase 4: Wire into Standard Gate Set

Add G12 to every dispatch table template that the plan writer (from #1191) generates:

```
| G12: RULE-COMPLIANCE | sub-task | yes (blind) | general | {"rule_applicability":"dispatch_table","issue":{issue}},"phase": {phase}} | RC-001 through RC-{N} |
```

The `rule_applicability` field in Receives Context tells the VbC sub-agent which deliverable type to inspect. This field is set based on the phase's primary deliverable type.

### Phase 5 (deferred): Rule Registry Expansion

The initial registry has 7 entries. Expansion is append-only — new rules are added as PRs against the registry. Guidelines:
- Each entry must have a clear PASS/FAIL criterion (no "apply judgment" rules)
- Rules about agent reasoning (e.g., "agent must think before acting") are not eligible — semantic inspection cannot read reasoning
- Rules about tool usage patterns with observable side effects are eligible (e.g., "no absolute paths" is checkable by reading the code diff)
- Each entry must be resolvable to a specific guideline file + section

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `rules-registry.yaml` exists with at least 7 entries covering dispatch_table, code, and output applicability | `string` |
| SC-2 | Each registry entry has a clear PASS/FAIL criterion and resolvable guideline reference | `string` |
| SC-3 | RULE-COMPLIANCE gate exists in implementation-pipeline's dispatch routing table | `string` |
| SC-4 | VbC rule-check sub-agent loads registry, filters by applicability, reads guideline text, judges compliance, returns PASS/FAIL/N/A per rule | `behavioral` |
| SC-5 | VbC rule-check returns FAIL with specific violation citation for known non-compliant deliverable | `behavioral` |
| SC-6 | Pipeline blocks on RULE-COMPLIANCE FAIL — orchestrator cannot proceed without remediation | `behavioral` |

## Non-Goals

- Not replacing #1196 (yaml+symbolic → Z3 contracts) — that spec handles formal constraint verification for pipeline-invariant rules. This spec handles semantic verification for everything else.
- Not removing existing "agent MUST" prose from guideline files — the rules remain as written. They gain an SC rather than being deleted.
- Not making every guideline rule registry-eligible — only rules with clear PASS/FAIL criteria and observable deliverables qualify.
- Not adding behavioral tests for every rule — the semantic verification IS the enforcement layer for this category.

## Environment

- Repo: `michael-conrad/.opencode`
- Branch: `feature/rule-compliance-gate`

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)