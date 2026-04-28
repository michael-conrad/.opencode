# Task: completion

## Purpose

Ensure the multimodal-dispatch workflow documents its results and produces a status report regardless of outcome. This task is the completion guarantee for multimodal-dispatch — it runs whenever the workflow halts, whether dispatch was successful, partial, or failed.

## Entry Criteria

The multimodal-dispatch workflow is halting. This includes:
- Successful dispatch and result collection from all modalities
- Partial results where some modalities were unavailable
- Model probe failures that prevented dispatch
- Configuration errors in modality routing
- An error that prevented any dispatch

## Exit Criteria

- Dispatch results documented with model attribution
- Status report produced in chat
- Capability cache left in valid state
- No orphaned state remains
- Byline present as last element of chat output

## Procedure

### Step 1: Document Results

Compile a status report summarizing all dispatch operations:

```
Multimodal Dispatch Status: <completed | partial | unverified | failed>
Models Used: <list of model names invoked>
Modalities Processed: <list of modalities with status>
Unverified Modalities: <list of modalities that had no available model>
```

Status determination:
- `completed`: All requested modalities dispatched and returned results
- `partial`: Some modalities dispatched successfully, others failed or had no model
- `unverified`: No modality could be verified (all models unavailable or failed)
- `failed`: Dispatch process encountered errors that prevented completion

### Step 2: Clean Up

- Clear any temporary dispatch state in `./tmp/` (never `/tmp/`)
- Ensure the capability snapshot cache is left in a valid state
- If any dispatch operations produced partial results, document what was completed and what was not
- Remove any temporary probe files created during capability detection

### Step 3: Model Attribution

For each model used in dispatch, record:
- Model identifier (exact tag from probe)
- Modality it was dispatched for (text, vision, audio)
- Result status (success, partial, failed)
- Token usage or cost metrics (if available)

### Step 4: Report

Produce the status report in chat output. The completion task is idempotent — invoking it multiple times produces the same result.

Follow the completion-core reference for:
- Push branch (if applicable, idempotent check — don't push if already pushed)
- Generate URL (if applicable)
- Report executive summary in chat (always runs)

### Step 5: Capability Cache Update

If multimodal-dispatch made new capability discoveries during the session:
- Update the local capability cache with newly discovered models
- Note any models that were found but not usable (rate-limited, incompatible, etc.)
- This cache speeds up future dispatch decisions

## Report Format

```
**Summary:**

<1-2 sentences describing dispatch outcome>

**Outcome:** <What modalities were successfully dispatched, or why dispatch failed>

<URL if applicable, ALWAYS LAST>

🤖 <AgentName> (<ModelId>) <status>
```

### Format Verification Before Halt (MANDATORY)

**Idempotent — safe to invoke multiple times. This verification runs before EVERY halt, regardless of path.**

- [ ] Executive summary present as **first** element
- [ ] Outcome line present after summary
- [ ] URL present IF relevant (after outcome, before byline)
- [ ] AI byline present as **LAST** element
- [ ] No stale todowrite items remain (all cleared or N/A)

## Context Required

- Invoked by: end of multimodal-dispatch workflow
- Related tasks: `probe`, `resolve`, `dispatch`, `dispatch-multi`
- Completion-core reference: `.opencode/skills/completion-core/completion-core.md`

Co-authored with AI: <AgentName> (<ModelId>)