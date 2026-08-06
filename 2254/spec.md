> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/2254/

## Problem

A history-grounded read-only audit of the spec-writer and spec-audit skill card sets (`spec-creation`, `audit`) and the consolidated reference standards (`.opencode/reference/`) identified internal-consistency drifts between what each card declares (dispatch format, structural sections, role naming, task references, evidence-type taxonomy source, validation criteria) and the actual on-disk reality. These drifts cause agents to dispatch tasks using a deprecated prompt format the reference docs forbid, resolve cross-references to non-existent task files, read the evidence-type taxonomy from a redirect source instead of the canonical one, evaluate a spec against a different 11-dimension set than the auditor uses, and route to tasks whose cards do not exist. Root cause: both skill sets retain content from before several migrations (flat-architecture refactor, DiMo 4-role audit dispatch, Workflows-section format, consolidated `.opencode/reference/` location). Because agent-facing text is consumed as routing instructions, each drift is a defect vector.

## Scope

- Apply exactly ONE prescriptive resolution per finding, each mapped one-to-one to a success criterion
- Changes confined to agent-facing skill/reference markdown files in `.opencode/` (skills/spec-creation, skills/audit, reference/)
- All changes are string/structural conformance; behavioral SCs apply only where the change affects runtime dispatch behavior
- Canonical dispatch prompt format: `Follow the instructions in [<skill>/tasks/<task>.md](...)` — no `execute X from Y` coded strings
- Workflows-only structure: audit SKILL.md converts TDT/Invocation/Tasks table to Workflows section; spec-creation removes redundant Task Files table
- Common evidence-type taxonomy: one canonical reference document as single source; validate task and audit load it dynamically
- Issue-number anchoring precondition: spec-creation analyze BLOCKs on unbound/placeholder issue number; remote-stub-first when remote API available
- Anti-bifurcation mandate: no bifurcated/backwards-compat paths in agent-facing instructions

**Out of scope:**
- No `src/` code changes
- No changes to non-agent-facing documentation
- No behavioral test suite changes beyond what the SCs require

## Approach

Consolidate the evidence-type taxonomy into one canonical reference document and make both the spec-creation validate task and the audit skill load it dynamically. Convert the audit SKILL.md from Trigger Dispatch Table + Invocation + Tasks table to a Workflows section with 4 DiMo steps. Remove the redundant Task Files table from spec-creation. Repair role-card frontmatter name fields to match filenames (Investigator/Validator/Evaluator/Arbiter). Repoint broken cross-references to monolithic role-task files to role-split files. Update stale reference-doc task names (inspect/decompose/write/check/file) to actual (analyze/create/validate/revise). Flatten three subdirectory audit tasks to flat role files and remove stub index files. Correct completion task routing and repoint dangling approval-gate `--task verify-authorization`. Rewrite the audit description to canonical agent-intent format. Remove redundant behavioral-sc-evaluator.md. Point taxonomy citations at the canonical reference. Missing evidence-type declaration becomes a hard FAIL routed to the remediation workflow (no warn/default/backwards-compat tier).

## Impact

- **Risk 1: Behavioral SCs misclassified** — Mitigation: behavioral SCs applied only where the change affects runtime dispatch behavior, per the evidence-type classification gate
- **Risk 2: Cross-references repointed to wrong files** — Mitigation: each repoint verified against actual on-disk task files during implementation
- **Risk 3: Taxonomy consolidation breaks existing consumers** — Mitigation: single canonical reference loaded dynamically by both validate and audit; missing declaration is a hard FAIL routed to remediation

Key dependencies: `.opencode/reference/` consolidated standards, spec-creation and audit skill decks, DiMo 4-role audit dispatch.

Call to action: Approve this spec to authorize the analyze/create pipeline to finalize success criteria and produce the authoritative spec and artifacts on the issues-data branch.

🤖 OpenCode (ollama-cloud/deepseek-v4-flash:0731) created
