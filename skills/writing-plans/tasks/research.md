# Task: research

## Purpose

Load the `verification-enforcement` skill and execute `--task verify` inline, collecting live-source evidence for all factual claims before any plan content is written. This is a hard gate — the pipeline MUST NOT proceed without PASS.

## Entry Criteria

- Approved spec exists
- Spec has explicit approval

## Exit Criteria

- Evidence artifacts collected for all factual claims
- Result contract contains `evidence_artifacts` field (list of paths)
- If any claim is unverifiable: return BLOCKED with empty evidence_artifacts

## Procedure

1. Load `verification-enforcement` skill: `skill({name: "verification-enforcement"})`
2. Execute `--task verify` inline within this context
3. Collect evidence artifact paths from verification output
4. If all claims verified: return PASS with evidence_artifacts
5. If any claim unverifiable: return BLOCKED with empty evidence_artifacts — pipeline halts

## Context Required

- Related skills: `verification-enforcement`
- Related guidelines: `065-verification-honesty.md`
