---
number: 2029
title: "[BUG] pipeline-readiness-gate.md in wrong task directory — spec-creation pipeline references spec-creation-decomposition/tasks/ but file is in spec-creation-validation/tasks/"
state: OPEN
---

## Wrong Task File Location

The spec-creation pipeline (SKILL.md) step 14 references `pipeline-readiness-gate.md` from `spec-creation-decomposition/tasks/`, but the file actually exists at `spec-creation-validation/tasks/pipeline-readiness-gate.md`.

## Impact

When the orchestrator dispatches step 14 via `task(..., prompt: "Read spec-creation-decomposition/tasks/pipeline-readiness-gate.md first")`, the sub-agent receives FILE_NOT_FOUND because the file is in a different sub-skill directory.

## Suggested Fix

Either:
1. Move `pipeline-readiness-gate.md` from `spec-creation-validation/tasks/` to `spec-creation-decomposition/tasks/`
2. Or update the pipeline reference in spec-creation SKILL.md to point to the correct directory

## Discovered During

Session 2026-07-20, spec #7 creation for hermes-ingest-pubmed. The sub-agent dispatched for step 14 returned BLOCKED with FILE_NOT_FOUND.
