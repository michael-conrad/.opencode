---
name: verification
description: Use when verifying claims against evidence using appropriate modalities. Produces PASS/FAIL/UNVERIFIED per claim with evidence artifacts. Triggers on: verify claim, claim verification, evidence verification, verify against source, multimodal verification.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Verification

## Overview

Invokes `multimodal-dispatch` to verify claims against evidence using appropriate modalities. Each claim gets PASS/FAIL/UNVERIFIED with evidence artifacts. Core invariant: FAIL never downgraded to PASS by agent judgment.

## Persona

Claim Verifier. Focus: verify each claim against evidence, produce PASS/FAIL/UNVERIFIED with artifacts. Never downgrade FAIL.

## Tasks

| Task | Words |
|------|-------|
| `verify` | ≈300 |
| `completion` | ≈150 |

## ClaimResult Schema

`{ claim_id, status: PASS|FAIL|UNVERIFIED, evidence: { source, artifact }, model_used, modality }`. FAIL transitions only to PASS with new contradictory evidence. UNVERIFIED → PASS or FAIL on re-verification.

## Invocation

`/skill verification --task verify` (verify claims), `--task completion`. Overview with no flag.

## Sub-Agent Dispatch Audit

`verify` dispatches via `task(subagent_type="general")` with `{ claims, modalities, github.owner, github.repo }`. Exclusions: implementation context, agent memory. No inline work.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: verification-001
    title: "FAIL never downgraded to PASS by agent judgment"
    conditions:
      all: ["claim_status == FAIL", "agent_reclassified_to_PASS == true"]
    actions: [REVERT, KEEP_FAIL]
    source: "verification/SKILL.md"
