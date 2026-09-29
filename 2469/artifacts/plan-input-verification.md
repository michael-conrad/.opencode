# Verification Ledger — .opencode#2469 Plan Creation

Written once at plan-input verification time (writing-plans → create step 3a). All subsequent plan
steps read THIS ledger, not the sources.

## Issue State

- Issue: `.opencode#2469` — "[SPEC] Scope .opencode behavioral-test mandates to .opencode-targeted work"
- Issues prefix: `.opencode/.issues/`
- Spec: `.opencode/.issues/2469/spec.md` — exists ✓ (read: 5-field preamble, Not Included §2,
  8 SCs §3, R-1..R-7 §4, Items 1–8 §5, Dependencies §6, Traceability §7, Enforcement Gate §9,
  Cost Frame §10, Edge Cases §11, Change Control §12)
- Spec revision history: two 2026-09-28 revisions (7 findings + 3 findings), latest state is authoritative.
- No linked plan exists yet (per change-control note); this task creates it.
- Target repo: `michael-conrad/.opencode` (ALL files touched by this spec live in the `.opencode` repo).

## SC List (with Evidence Types — from spec §3)

| SC | File | Evidence | Verify Method |
|----|------|----------|---------------|
| SC-1 | `.opencode/tests-v2/AGENTS.md` | string | grep anchor text |
| SC-2 | `.opencode/guidelines/020-go-prohibitions.md` §1 | string | grep qualifier + Read-link |
| SC-3 | `.opencode/guidelines/080-code-standards.md` (critical-rules-060) | string | grep qualifier + Read-link |
| SC-4 | `.opencode/guidelines/091-incremental-build.md` (behavioral variant) | string | grep conditionality text |
| SC-5 | `.opencode/skills/test-driven-development/SKILL.md` (§Evidence Type Taxonomy) | string | grep prose + unchanged table |
| SC-6 | `.opencode/reference/spec-structure-standards.md` (evidence table behavioral row) | string | grep table row |
| SC-7 | behavioral RED — artifact generation | behavioral | `with-test-home` → `opencode run` → `session.yaml` |
| SC-8 | behavioral GREEN — clean-room evaluation | behavioral | clean-room sub-agent evaluates SC-7 artifacts |

## Structure Artifact Mappings (from `artifacts/structure.yaml` — exists ✓)

- Phase 1: SC-1 (Item 1) — anchor; must precede Read-link consumers.
- Phase 2: SC-2, SC-3, SC-4 (Items 2–4) — guideline qualifiers; independent within phase.
- Phase 3: SC-5, SC-6 (Items 5–6) — SC-5 precedes SC-6 within phase.
- Phase 4: SC-7 (Item 7) — behavioral RED artifact-generation; GREEN leg requires phases 1–3.
- Phase 5: SC-8 (Item 8) — clean-room evaluation consuming phase-4 artifacts.
- DAG edges: 2→1, 3→1, 4→1, 4→2, 4→3, 5→4. Acyclic ✓. Triplet colocation verified ✓.

## Workflow / Dispatch Surface (verified once)

- Per-task cycle (implementation-workflow reference card): RED → GREEN → COMMIT (per SC, no batching);
  pre-implementation: `pre-regression` + `pre-regression-verify`; post-implementation: audit, z3-check,
  structural-checks, pre-pr-gate, regression-check, review-prep, create-pr, exec-summary.
- Dispatch canonical strings verified from reference card (test-driven-development red/green/phase-0/phase-4;
  verification-before-completion verify; orchestrator commit-inline; git-workflow-pr review-prep/create;
  completion-core completion; finishing-a-development-branch checklist).
- Behavioral precondition (tests-v2 §4): commit → push → fresh fetch → verify effective commit in remote ref
  → run; applies to phases 4 and 5.
- Behavioral instrument (verified command form): `bash .opencode/tests-v2/with-test-home opencode run '<message>'`.

## CLI Surface Flags Actually Needed

- `./.opencode/tools/local-issues update --number N --labels <full list>` (step 9 local canonical write)
- CLI quirks verified live: positional issue argument is rejected by both `update` (requires
  `--number`) and bare numbers (requires `repo#N` qualifier on `--number` values). Live-tested
  `./.opencode/tools/local-issues update --number ".opencode#2469" --labels ...` — result below.

## Results (appended at task end)

- Plan written: `.opencode/.issues/2469/plan.md` (staged: skeleton → 5 section edits → guard + read-back)
- Verification ledger: this file
- Pre-Flight Guard: `ORCHESTRATOR_ONLY_PLAN` block embedded verbatim at plan line 18
- Label `spec-cleared`: written to local `issue.yaml` (canonical, verified) + remote via `gh issue edit` (best-effort, succeeded)