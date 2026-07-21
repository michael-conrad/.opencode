<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: completion

## Purpose

Produce the final judgment on audit workflow completion. Reads `cross-validate`'s `judgment.yaml` and reports the verdict.


## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory for evidence artifacts

Idempotent completion subtask for audit. Ensures mandatory steps ran regardless of where the workflow halted.

## Entry Criteria

- **PRELOADED_CONTEXT_REJECTED gate**: If the orchestrator preloads context (inline file paths, step definitions, expected outcomes, orchestrator-derived conclusions), the sub-agent MUST return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

## Procedure

### Step 0: Pre-clean

- [ ] 0. Pre-clean: remove artifact files for this task from `./tmp/{issue-N}/artifacts/completion/`

### Read cross-validate judgment.yaml

Read `cross-validate`'s `judgment.yaml` from `./tmp/{issue-N}/artifacts/cross-validate/judgment.yaml` and report the verdict.

## Remediation


## Report Phase

Generate executive summary in chat:

```
**Summary:**

<1-2 sentences describing the audit result and stakeholder value>

**Outcome:** <What the verdict means for stakeholders>

<URL if applicable, ALWAYS LAST>

🤖 <AgentName> (<ModelId>) <status>
```

## Pipeline Signal

```
CONTINUE: approval-gate --task verify-authorization
HALT
```

### Format Verification Before Halt (MANDATORY)

**Idempotent — safe to invoke multiple times. This verification runs before EVERY halt, regardless of path.**

- [ ] Executive summary present as **first** element
- [ ] Outcome line present after summary
- [ ] Verdict result (PASS/FAIL) clearly stated in outcome
- [ ] URL present IF relevant (after outcome, before byline)
- [ ] AI byline present as **LAST** element
- [ ] No stale todowrite items remain (all cleared or N/A)

## Live Verification: Completion Evidence (MANDATORY)

**Each completion state check MUST be verified via tool call, not just asserted. Assertions without tool-call artifacts are VERIFICATION-GAP findings per `065-verification-honesty.md`. Evidence is read from YAML artifacts on disk, not passed inline.**

| Claim | Verification Action | Tool Call | Problem Class |
|-------|-------------------|-----------|---------------|

| "YAML verdict artifacts on disk" | Verify artifact files exist | Read `artifact_path` from role result contracts | VERDICT-INTEGRITY |
| "Verdict evaluated" | Verify PASS/FAIL determination | Read YAML artifact on disk | CONSENSUS-GAP |

**Evidence artifact:** Tool call results for each completion state check, plus YAML artifact file reads.

## Sub-Agent Routing

| Scope of Context | Exclusions | Pre-Analysis Contract | Includes Inline Work? |
|---|---|---|---|---|
| `dimo_role_chain_status`, `artifact_paths` | Orchestrator reasoning, expected outcomes, verdict content | N/A — this is a completion task, not a task() routing task | NO |