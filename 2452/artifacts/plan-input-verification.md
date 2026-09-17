# Plan Input Verification Ledger — .opencode#2452

Verified once at plan-creation start; all subsequent plan steps re-read THIS ledger, not the sources.

## Issue state + labels
- Issue: .opencode#2452 — "[BUG] spec-creation analyze never consumes the brainstorming handoff — specs drift from developer-approved designs"
- Local `issue.yaml` labels: `approved-for-pr` (canonical source)
- Spec file: `.opencode/.issues/2452/spec.md` (exists, complete with §1–§10, Change Control)

## SC list with evidence types (from spec §3)
| SC | Criterion summary | Evidence Type | Method |
|----|-------------------|---------------|--------|
| SC-1 | TDT analyze dispatch context carries optional `brainstorm_handoff_path`; analyze reads handoff as primary design input (handoff-file read visible in stderr) | behavioral | `opencode run` via tests-v2/with-test-home; `assert_stderr_pattern_present` |
| SC-2 | brainstorming exploration-workflow writes handoff pointer file into `{issues_prefix}{N}/` at issue creation | behavioral | Behavioral run; pointer file existence after issue creation (runtime output); structural check secondary only |
| SC-3a | Field absent + pointer present → analyze discovers and reads pointer target (discovery read in stderr) | behavioral | Behavioral run; `assert_stderr_pattern_present` |
| SC-3b | Neither channel → analyze completes with current behavior, no halt | behavioral | Behavioral run; exits normally, no BLOCKED state |

## Structure artifact mappings (from structure.yaml)
- Phase 1 (SC-1): files spec-creation/SKILL.md + tasks/analyze.md; no dependencies
- Phase 2 (SC-2): file brainstorming/SKILL.md; no dependencies
- Phase 3 (SC-3a, SC-3b): file tasks/analyze.md; depends on phase-1 AND phase-2
- DAG: phase-1→phase-3, phase-2→phase-3; no cycles; triplet colocation verified; cross-phase dependency check verified
- Verification: all behavioral; behavioral variant COMMIT+PUSH precede behavioral run (guidelines/091)

## CLI surface needed
- Label write: `.opencode/tools/local-issues update .opencode#2452 --labels spec-cleared` — NOTE (pinned convention 11): `update --labels` REPLACES the entire labels array; must include existing labels + new one: `approved-for-pr spec-cleared`. Check the tool's actual flag syntax (`--labels` vs `--label`) at write time by reading tool help once.

## Reference-card per-task cycle steps (from implementation-workflow.md)
- Pre-implementation (Tier 1): pre-regression (TDD phase-0), pre-regression-verify (VbC verify)
- Per-item: red (TDD red) → green (TDD green) → post-regression (TDD phase-4) → verify (VbC verify) → commit-inline (orchestrator direct)
- Behavioral items: PUSH after commit, before behavioral run; fresh-fetch containment check
- Post-implementation (Tier 1): audit → z3-check (direct) → structural-checks → pre-pr-gate → regression-check → review-prep → create-pr → exec-summary

## Artifact-derived plan inputs
- Blast radius: LOW-MEDIUM; 3 files edited, all skill-deck text in .opencode submodule
- Cross-cutting: SC-3a, SC-3b cross-cutting (exercise both channels); shared file analyze.md edited by Items 1, 3a, 3b — sequential execution
- Channel precedence: dispatch field > pointer
- Interface boundaries: dispatch context (backward-compatible optional field); pointer file (additive); handoff schema (unchanged, read-only consumer)
- State transitions: handoff-channel-state (none→field/pointer→discovery/degraded); invariants: analyze never halts on missing/stale channels
- Degraded/edge states: stale pointer → record handoff-unavailable, no halt; out-of-scope pointer path → do not follow; both channels → field wins
