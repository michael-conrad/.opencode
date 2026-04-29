# Task: result-validation

Post-dispatch result validation: detect empty, malformed, or overflow results from sub-agents and execute fallback or recovery.

## Purpose

When `assemble-work` receives a sub-agent result, it MUST validate the result before recording it in the work state file. Invalid results — empty output, malformed YAML, missing required fields, or overflow signals — require specific handling to prevent silent data loss or workflow corruption.

**This task enforces `000-critical-rules.md` §Skipping Post-Flight Checks for Sub-Agents and §Claiming Verification Without Tool-Call Evidence.**

## Pre-Conditions

- A sub-agent has returned a result from a dispatched task
- The result has not yet been validated or recorded in the work state file

## Validation Protocol

### Step 1: Empty Result Detection

A sub-agent returned no output at all (empty string or null result contract).

**Action:**
1. FALLBACK to inline execution
2. Report warning in chat: "Sub-agent [name] returned empty result — falling back to inline execution"
3. NEVER transition from empty result to silent halt (critical violation per `000-critical-rules.md` §Silent Agent Termination)

### Step 2: Malformed Result Detection

The result contract has invalid YAML structure or missing required fields.

**Required fields check:**
- `status`: MUST be present and one of `DONE`, `DONE_WITH_CONCERNS`, `BLOCKED`, `OVERFLOW`
- `files_changed`: MUST be present (may be empty list)
- `summary`: MUST be present and non-empty

**Action:**
1. Attempt to extract usable data from the malformed result
2. If extraction succeeds: Record what was extracted, note the malformation in work state
3. If extraction fails: FALLBACK to inline execution + report warning in chat
4. NEVER accept a result with `status: DONE` when required fields are missing

### Step 3: Overflow Result Detection

The sub-agent's context window exceeded during execution. The result will have `status: OVERFLOW`.

**Action:**
1. Invoke `overflow-signal` task for re-dispatch protocol
2. The overflow task determines whether to re-dispatch with smaller scope or report to orchestrator
3. NEVER silently discard overflow results

### Step 4: Evidence Verification

Every verification claim in the result contract MUST reference a tool-call artifact.

**Action:**
1. Scan result contract for claims presented as verified
2. For each claim, confirm a tool-call reference exists (tool name, parameters, output excerpt)
3. Claims without tool-call evidence → mark as UNVERIFIED
4. UNVERIFIED claims in result contract → downgrade status to `DONE_WITH_CONCERNS`

### Step 5: Deliverable Substance Check

Verify that claimed deliverables actually exist and contain expected content.

**Action:**
1. For each file in `files_changed`, verify the file exists via `glob` or `read`
2. For each success criterion mapped to a file, verify content matches spec requirements
3. Files that don't exist → flag as `PHANTOM_FILE` in work state
4. If any `PHANTOM_FILE` found → return `DONE_WITH_CONCERNS`

## Post-Flight Check Summary

| Check | Pass Action | Fail Action |
|-------|-------------|-------------|
| Non-empty result | Record result | FALLBACK to inline + warn |
| Valid YAML structure | Record result | Attempt extraction or FALLBACK |
| Required fields present | Record result | Note malformation or FALLBACK |
| No OVERFLOW status | Record result | Invoke overflow-signal |
| Evidence for claims | Record result | Mark UNVERIFIED, downgrade status |
| Deliverables exist | Record result | Flag PHANTOM_FILE, downgrade status |

## Result Contract

```json
{
  "status": "valid | malformed | empty | overflow | concerns",
  "original_status": "DONE | DONE_WITH_CONCERNS | BLOCKED | OVERFLOW",
  "concerns": ["list of validation concerns"],
  "fallback_used": true | false,
  "phantom_files": ["list of files that don't exist"]
}
```

## Completion Guarantee

If this task halts at any point, invoke `divide-and-conquer --task completion` before halting.