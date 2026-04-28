# Task: verify-single

## Purpose

Verify a single claim against evidence using modality-aware dispatch. This is the single-claim version of the `verify` task, designed for targeted verification of individual claims without the overhead of a full multi-claim verification workflow.

## Entry Criteria

- A single claim to verify (with text and optional modality hint)
- A content payload describing the evidence to verify against
- The `multimodal-dispatch` skill is available for routing

## Exit Criteria

A `ClaimResult` is produced with PASS/FAIL/UNVERIFIED status, evidence, and the model used.

## Procedure

### Step 1: Detect Content Modality

Inspect the content payload to determine the appropriate modality:

| Content Field | Modality |
|---------------|----------|
| `text` only | `text` |
| `image_paths` non-empty | `vision` |
| `audio_paths` non-empty | `audio` (likely UNVERIFIED) |
| Mixed content | Use `dispatch-multi` |

If the caller provided a modality hint, use it as a starting point. The `multimodal-dispatch --task resolve` task validates the hint against content and overrides if contradicted.

### Step 2: Dispatch via multimodal-dispatch

Invoke `multimodal-dispatch --task dispatch` with:
- `task-prompt`: "Verify this claim against the provided evidence: <claim_text>. Return PASS if the evidence supports the claim, FAIL if the evidence contradicts the claim, or UNVERIFIED if you cannot determine the answer."
- `modality`: The detected or hinted modality
- `content`: The content payload

### Step 3: Construct ClaimResult

From the `DispatchResult`, build a `ClaimResult`:

```json
{
  "claim_id": "C1",
  "status": "<PASS | FAIL | UNVERIFIED>",
  "evidence": "<summary>",
  "evidence_artifacts": ["<tool_call_ref>", ...],
  "model_used": "<model_tag>",
  "modality": "<resolved_modality>"
}
```

**Status determination rules:**

| Outcome | Status | When |
|---------|--------|------|
| Model confirms claim with evidence | PASS | Explicit confirmation |
| Model contradicts claim with evidence | FAIL | Explicit contradiction |
| Model cannot determine | UNVERIFIED | Insufficient evidence |
| No model available for modality | UNVERIFIED | Modality unsupported |

**FAIL is never downgraded to PASS.** This invariant is absolute per `000-critical-rules.md` §Soft-Passing Verification Mismatches. A claim that fails verification stays FAIL regardless of how "close" it is to passing. Only the stakeholder can decide to accept a deviation.

### Step 4: Return ClaimResult

Return the single `ClaimResult`. The calling skill uses this to build its own result. No further processing is required for single-claim verification.

## Error Handling

| Error | Resolution |
|-------|-----------|
| `multimodal-dispatch` returns `unverified` | `ClaimResult.status = UNVERIFIED` with gap description |
| `multimodal-dispatch` returns `failed` | `ClaimResult.status = FAIL` with error details |
| Content payload is empty | `ClaimResult.status = UNVERIFIED` with "no content provided" |
| Model unavailable for modality | `ClaimResult.status = UNVERIFIED` with modality gap description |

## Comparison Modes

| Mode | When to Use | Comparison |
|------|------------|------------|
| `exact` | DNS records, config values, API responses, infrastructure state | Character-for-character match |
| `semantic` | Code behavior where multiple implementations achieve same spec intent | Intent-level match with justification |

The default comparison mode for ALL external verifications is `exact` — character-for-character match. `semantic` mode is ONLY for code behavior where multiple implementations achieve the same spec intent, and requires explicit per-field justification.

## Context Required

- Depends on: `multimodal-dispatch` (model selection and dispatch)
- Invoked by: `verify` task (for individual claims), or directly by skills needing single-claim verification
- Related tasks: `verify`, `completion`
- `065-verification-honesty.md`: FAIL claims cannot be downgraded

Co-authored with AI: <AgentName> (<ModelId>)