# Task: sc-closeout

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Verify every SC from the spec received at least one PASS verdict before issue closure. Runs at the exec-summary step of the implementation pipeline. Blocks issue closure on UNVERIFIED SCs.

## Entry Criteria

- Pipeline execution complete (all 14 steps finished)
- Pipeline artifacts exist at `{project_root}/tmp/{issue-N}/artifacts/pipeline-*.yaml`
- `sc-summary.yaml` exists at `.issues/{issue-N}/sc-summary.yaml`
- Issue closure pending

## Exit Criteria

- All SCs verified PASS or BLOCKED with UNVERIFIED finding
- Issue closure blocked if any SC is UNVERIFIED
- Blocker finding posted to issue comment if blocked

## Procedure

### Step 1: Collect Pipeline Artifacts

- [ ] 1. Glob `{project_root}/tmp/{issue-N}/artifacts/pipeline-*.yaml` for all pipeline step artifacts
- [ ] 2. Read each artifact and extract SC verdicts (PASS/FAIL per SC)
- [ ] 3. Collect all SC verdicts into a unified SC status table

### Step 2: Read SC Summary

- [ ] 1. Read `.issues/{issue-N}/sc-summary.yaml`
- [ ] 2. Extract `sc_coverage.total` and all SC-IDs
- [ ] 3. Verify every SC-ID from the summary has at least one verdict in the pipeline artifacts

### Step 3: Verify All SCs Have PASS Verdicts

- [ ] 1. For each SC-ID from `sc-summary.yaml`:
   - Check if at least one pipeline artifact contains a PASS verdict for this SC
   - If no PASS verdict found: mark as UNVERIFIED
   - If FAIL verdict found without subsequent PASS: mark as FAILED
- [ ] 2. If any SC is UNVERIFIED or FAILED: status = BLOCKED

### Step 4: Report and Block

- [ ] 1. If all SCs PASS: write PASS manifest, proceed to issue closure
- [ ] 2. If any SC is UNVERIFIED or FAILED:
   - Write BLOCKED manifest with list of UNVERIFIED/FAILED SCs
   - Post a BLOCKER finding to the issue comment
   - Block issue closure

### Step 5: Write Close-Out Manifest

Generate timestamp via `.opencode/tools/schema-version`. Store result in `$TIMESTAMP`.

Write `{project_root}/tmp/{issue-N}/artifacts/sc-closeout-$TIMESTAMP.yaml`:

```yaml
schema_version: "1.0"
generated_at: "$TIMESTAMP"
status: PASS | BLOCKED
blocked_reason: "<reason if BLOCKED, else null>"
sc_verdicts:
  - sc_id: SC-1
    verdict: PASS | FAIL | UNVERIFIED
    source_artifact: "pipeline-*.yaml"
  - sc_id: SC-2
    verdict: PASS | FAIL | UNVERIFIED
    source_artifact: "pipeline-*.yaml"
  ...
summary:
  total_scs: <count>
  pass: <count>
  fail: <count>
  unverified: <count>
```

## Context Required

- Preceded by: pipeline exec-summary step
- Feeds into: issue closure (git-workflow cleanup)
- Related artifacts: `{project_root}/tmp/{issue-N}/artifacts/pipeline-*.yaml`, `.issues/{issue-N}/sc-summary.yaml`