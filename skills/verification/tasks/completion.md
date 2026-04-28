# Task: completion

## Purpose

Ensure the verification workflow documents its results and produces a status report regardless of outcome. This task is the completion guarantee for verification — it runs whenever the workflow halts, whether all claims passed, some failed, or an error prevented verification.

## Entry Criteria

The verification workflow is halting. This includes:
- All claims verified successfully (all PASS)
- Partial verification with some unverified claims (no available model or modality)
- Claims that failed verification (FAIL status)
- An error that prevented verification from completing

## Exit Criteria

- Verification results documented with PASS/FAIL/UNVERIFIED per claim
- Status report produced in chat
- FAIL claims escalated to developer
- No orphaned state remains
- Byline present as last element of chat output

## Procedure

### Step 1: Document Results

Compile a status report summarizing all verification operations:

```
Verification Status: <complete | partial | escalated>
Claims Verified (PASS): <count>
Claims Failed (FAIL): <count>
Claims Unverified: <count>

Failed claims:
- <claim_id>: <reason>

Unverified claims:
- <claim_id>: <modality> — <reason>
```

Status determination:
- `complete`: All claims have PASS status
- `partial`: Some claims UNVERIFIED but none FAIL
- `escalated`: At least one claim has FAIL status requiring developer action

### Step 2: Clean Up

- Clear any temporary verification state in `./tmp/` (never `/tmp/`)
- Ensure multimodal-dispatch cache is left in valid state
- Document any gaps in modality coverage for future sessions
- Remove temporary evidence files after documenting their contents

### Step 3: Report

Produce the status report in chat output. The completion task is idempotent — invoking it multiple times produces the same result.

Follow the completion-core reference for:
- Push branch (if applicable, idempotent)
- Generate URL (if applicable)
- Report executive summary in chat (always runs)

### Step 4: FAIL Escalation

If any claims have FAIL status, they MUST be escalated to the developer. FAIL claims are never silently downgraded or omitted from the report. The escalation format is:

```
ESCALATION: <claim_id> — <evidence that contradicts the claim>
```

**Per `000-critical-rules.md` §Soft-Passing Verification Mismatches:**
- FAIL is never downgraded to PASS
- "Functionally equivalent" is NOT a valid downgrade reason
- "Minor difference" is NOT a valid downgrade reason
- "Semantically close" is NOT a valid downgrade reason
- If the stakeholder wants to accept a deviation, that is their decision — not the agent's

### Step 5: Evidence Table

Produce the final evidence table for all claims:

| Claim ID | Status | Evidence | Model |
|----------|--------|----------|-------|
| C1 | PASS | <tool-call reference> | <model> |
| C2 | FAIL | <contradicting evidence> | <model> |
| C3 | UNVERIFIED | <gap description> | N/A |

## Report Format

```
**Summary:**

<1-2 sentences describing verification outcome>

**Outcome:** <What was verified, what failed, what was unverified>

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

- Invoked by: end of verification workflow
- Related tasks: `verify`, `verify-single`
- Completion-core reference: `.opencode/skills/completion-core/completion-core.md`
- `065-verification-honesty.md`: FAIL claims cannot be downgraded

Co-authored with AI: <AgentName> (<ModelId>)