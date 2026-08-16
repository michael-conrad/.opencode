# Task: create

## Purpose

Generates a structured implementation plan from the structure artifact. The plan is structured markdown with English instructions. Every task in every phase enumerates every step from the implementation-workflow reference card's per-task cycle — no skipping, no combining, no grouping.

The per-task cycle steps are discovered at runtime by reading the implementation-workflow reference card at `skills/writing-plans/reference/implementation-workflow.md`. The plan writer MUST NOT embed a hardcoded copy of the workflow.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- The issue number `{N}` must be provided
- The project root and issues prefix must be set
- The structure artifact must exist at `{issues_prefix}/{N}/artifacts/structure.yaml`
- The spec file must exist at `{issues_prefix}/{N}/spec.md`

## Procedure

1. **Read the implementation-workflow reference card.** Read `skills/writing-plans/reference/implementation-workflow.md`. Extract the Trigger Dispatch Table and the per-task cycle steps — these are the rows that form the RED→GREEN→COMMIT cycle for a single task. The reference card is the single authoritative source for what steps exist. Do NOT hardcode or assume any step ordering.

2. **Read the structure artifact** from `{issues_prefix}/{N}/artifacts/structure.yaml`.
   - If missing: return BLOCKED with `STRUCTURE_ARTIFACT_NOT_FOUND`.
   - Extract: phase list, phase DAG, concern-to-phase mapping, SC-to-phase mapping, skill+task dispatch references per phase.

3. **Read the spec file** from `{issues_prefix}/{N}/spec.md` to extract all success criteria with their evidence types.

4. **Build the plan frontmatter.** Read [plan-structure-standards.md](reference/plan-structure-standards.md) §Plan Frontmatter. Write YAML frontmatter with the required fields.

5. **Build the plan body.** Read [plan-structure-standards.md](reference/plan-structure-standards.md) for structural expectations:
   - Three-tier layout (Tier 1 global pre/post, Tier 2 per-phase, Tier 3 per-item)
   - Per-item daisy chain: RED → GREEN → verify → commit
   - Dispatch indicators: `(**inline**)`, `(**sub-agent**)`, `(**clean-room**)`
   - Step format: numbered checkbox with sub-bullets, no prescriptive code
   - Admonishments: compliance (top only), one-step-at-a-time, step status, self-remediation, enforcement gate
   - Phase file sections: code path coverage, cross-cutting SCs, interface boundaries, state transitions
   - Prohibited patterns: no dispatch tables, no TBD/TODO, no shared cross-references, no zero-indexed, no line numbers, no multi-dispatch steps, no non-standard indicators, no omitted mandatory gates
   - Each item references exactly one SC-ID. No item may cover multiple SCs.

6. **Write pre-implementation steps** at the start of the plan (before any phase):
   - Coherence gate step
   - Baseline check step
   - These appear once per plan, not per phase.

7. **Write post-implementation steps** at the end of the last phase:
   - Structural checks, verification, audit, cross-validate, review-prep, PR creation, completion.
   - These appear once per plan, not per phase.

8. **Write the plan to disk** at `{issues_prefix}/{N}/plan.md`:
   - Read [plan-structure-standards.md](reference/plan-structure-standards.md) §Plan Index Sections for the required index structure.
   - Read [cost-model-standards.md](reference/cost-model-standards.md) and write per-phase cost-frame statements following the dark-prose-007 pattern.
   - Use structured markdown: checkbox lists with dash sub-bullets for context parameters.
   - No machine-parseable cross-references, no identifier IDs (REQ-001, TASK-001), no JSON/YAML code blocks in the body.
   - English text only — the plan is read by the orchestrator, not parsed.

9. **Apply `spec-cleared` label — local `issue.yaml` is PRIMARY CANONICAL.**
   - **PRIMARY — write to local canonical source:** Write `spec-cleared` to the local `{issues_prefix}/{N}/issue.yaml` labels array via `./.opencode/tools/local-issues update <repo>#<N> --labels spec-cleared`. This is the **primary canonical source** for the label state — it MUST be written regardless of remote API success. If this write fails, return BLOCKED with `LOCAL_LABEL_WRITE_FAILED` — the pipeline MUST NOT proceed without the canonical local record.
   - **SECONDARY — best-effort remote write (never blocking):** When a remote API is available, apply the `spec-cleared` label to the spec issue via the platform's label API. This is best-effort/secondary only — if the remote write fails, log the failure and continue; it MUST NOT block the pipeline. The local `issue.yaml` remains the canonical source.
   - The `spec-cleared` label indicates the spec has been freshness-checked and is ready for plan creation.

10. **Return the result contract.**

## Exit Criteria

- The plan has been written to `{issues_prefix}/{N}/plan.md`
- `spec-cleared` is present in the local `{issues_prefix}/{N}/issue.yaml` labels array (canonical — REQUIRED)
- Remote `spec-cleared` label write attempted best-effort; remote failure does not block completion
- The plan frontmatter contains `dispatch:` array with skill+task refs per phase
- Every task in every phase enumerates every step from the implementation-workflow reference card per-task cycle
- All SCs are mapped to at least one phase
- No circular dependencies in the phase DAG
- The plan uses structured markdown: checkbox lists with dash sub-bullets
- No machine-parseable cross-references, no identifier IDs, no JSON/YAML code blocks in the body
- The artifact path has been set in the result contract
- **Validation rule 16:** Each item references exactly one SC-ID. No item may cover multiple SCs.

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<1-3 sentences summarizing SC coverage and dispatch structure>"
artifact_path: "<{issues_prefix}/{N}/plan.md>"
blocker_reason: "<reason if BLOCKED>"
```
