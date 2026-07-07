# Task: verify

## Purpose

Run the pre-generation verification gate. Before a content-generating skill produces any output, this task dispatches content audits for every factual claim the agent intends to make. The agent declares its intended claims, dispatches independent auditors to verify each content section against local source data, and assembles the results. Claims that cannot be verified are marked for later resolution.

## Entry Criteria

A content-generating skill is about to produce output. The agent has identified what content it will generate and what claims that content will make.

## Exit Criteria

Evidence artifacts have been collected for all claims, or unverifiable claims have been marked with `⚠️ UNVERIFIED` for the revisit pass to resolve.

## Procedure

The orchestrator begins by identifying the content sections that the generating skill intends to produce. These sections correspond to the natural divisions of the output — for a spec, this might be objectives, constraints, success criteria, and affected files; for a runbook, this might be environment context, diagnosis, mitigation steps, and verification criteria. The orchestrator does not need to know the exact content yet — it needs to know the claims that will be made, broadly categorized.

For each content section, the orchestrator dispatches an content audit via `audit --task content-audit`. This replaces the previous single-sub-agent approach with independent verification:

1. The orchestrator calls `skill({name: "audit"})` then tasks `content-audit` with `{ document_section, source_data_paths }` — clean-room, no orchestrator preload, no GitHub routing fields
2. The `content-audit` task dispatches a single sub-agent who independently verifies every numerical claim, file reference, and factual assertion against local source data
3. Each auditor returns per-claim verdicts: PASS (verified), FAIL (contradicted by source), or FABRICATED (no source evidence exists)
4. The two auditor verdicts are cross-validated for consensus
5. The result contract returns per-claim verdicts and evidence artifact paths

The evidence artifact format is:

```
Claim: <what the content asserts>
Domain: <verification domain — numerical, file-reference, config-value, code-behavior, docs-claim>
Source: <tool call or document that provided the evidence>
Verified: <yes|no>
Marker: <if no, ⚠️ UNVERIFIED>
Reason: <if no, why verification failed>
```

The orchestrator assembles the evidence artifacts from all content-audit dispatches. If every claim has a `Verified: yes` artifact, the generation proceeds with full confidence. If some claims are marked `⚠️ UNVERIFIED`, the generation proceeds — but the unverified claims must be marked with `⚠️ UNVERIFIED` in the generated content so the revisit pass can find and attempt to resolve them.

No claim appears in generated content without an evidence artifact. If the agent has no tool call to support a claim, it must not assert the claim as verified. This is the core principle: no tool call means no claim, and no evidence means no assertion.

## Context Required

- Invoked by: content-generating skills as their first substantive step
- Followed by: the content generation steps of the invoking skill
- Related tasks: `revisit` (post-generation resolution), `enforce` (orchestrator gate)
- Related skills: `audit --task content-audit` (verification of claims)