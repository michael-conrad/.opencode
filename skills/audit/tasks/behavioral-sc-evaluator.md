<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: behavioral-sc-evaluator

## Purpose

Clean-room evaluation of behavioral SC evidence. Receives ONLY an artifact directory path. Reads raw test output (stdout.log, stderr.log) and renders binary PASS/FAIL per SC. No orchestrator context, no expected outcomes, no cached results.

## Entry Criteria

- Artifact directory path provided (no other context)
- Artifact directory contains at minimum `stdout.log` and `stderr.log`
- SC criteria provided inline (the SC text to evaluate against)

## Exit Criteria

- Binary PASS/FAIL verdict per SC
- Verdict based on actual agent behavior in stdout.log/stderr.log, NOT file existence
- Result contract returned with `status: DONE` and `finding_summary`

## Procedure

### Step 1: Read Artifacts

- [ ] 1. Read `stdout.log` — full agent prose output
- [ ] 2. Read `stderr.log` — tool dispatch trace
- [ ] 3. Read `manifest.yaml` — scenario metadata

### Step 2: Evaluate Each SC

For each SC criterion provided:

- [ ] 1. Read the agent's actual actions from stdout.log and stderr.log
- [ ] 2. Determine: did the agent's behavior satisfy the SC criterion?
- [ ] 3. File-existence alone is NEVER sufficient — the agent must have taken the correct action
- [ ] 4. Render binary verdict: PASS (100% clean, no caveats) or FAIL (anything else)

### Step 3: Return Result Contract

```yaml
status: DONE
artifact_path: "<artifact directory path>"
summary: "Evaluated {N} behavioral SCs: {M} PASS, {K} FAIL"
per_sc:
  - sc_id: "<SC-N>"
    verdict: PASS|FAIL
    justification: "<1-2 sentence explanation based on actual agent output>"
```
