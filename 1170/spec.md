## Intent and Executive Summary

| Field | Value |
|-------|-------|
| Problem | Tamer planner returns `UNSOLVABLE_INCOMPLETELY` for a simple 14-step fully-serial chain (13 `next` links). The bounded search depth is insufficient for chain length > ~8 steps. |
| Approach | Change default engine for classical problems from Tamer to `fast-downward` (lama-first). Tamer remains default for temporal/numeric problems. Add problem-kind detection to auto-select appropriate engine. |
| Key Decisions | Engine selection based on `problem.kind` — classical → fast-downward, temporal/numeric → Tamer. No new flags. Preserves Tamer for problems it handles well (temporal, numeric with ICE). |
| Alternatives | Increase Tamer search bound (not exposed via UP API). Add `--engine` recommendation in error message (less effective). |
| Scope | `.opencode/tools/plan` — `_action_plan()` engine selection logic |

## Problem

The Tamer planner's Weighted A* search (weight=0.8, hadd heuristic) has an implicit depth bound that fails on serial chains beyond ~8 steps. A 14-step chain (13 transitions) triggers `UNSOLVABLE_INCOMPLETELY` in ~1ms.

Research confirms:
- Tamer is optimized for temporal/numeric planning with ICE (Intermediate Conditions and Effects)
- For classical planning, Fast Downward (lama-first) handles 100+ step serial chains trivially
- Unified-planning engine selection already filters by `problem.kind`
- Fast Downward supports classical planning; Tamer supports classical + numeric + temporal

Current behavior: always uses Tamer (hardcoded default at line 518: `engine = args.engine or "tamer"`)

## Requirements

### R-1: Auto-select engine based on problem kind

In `_action_plan()`:
1. After building problem, inspect `problem.kind`
2. If problem has temporal features (`problem.kind.has_temporal_features()`) OR numeric features with bounded types → use Tamer
3. Else (classical) → use `fast-downward` (lama-first)
4. Explicit `--engine` flag always overrides auto-selection

### R-2: Preserve Tamer for temporal/numeric problems

Tamer must remain the engine for:
- Temporal planning (durative actions, timed goals)
- Numeric planning with bounded types
- Problems with ICE (Intermediate Conditions and Effects)

### R-3: Maintain explicit --engine override

User-provided `--engine` flag takes precedence over auto-selection.

## Out of Scope

- Adding new engine parameters (weight, heuristic)
- Behavioral tests (content-verification sufficient for string SCs)
- Modifying Tamer itself (upstream)

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Classical problems (no temporal/numeric) use `fast-downward` by default | `string` |
| SC-2 | Temporal problems use `tamer` by default | `string` |
| SC-3 | Numeric problems with bounded types use `tamer` by default | `string` |
| SC-4 | Explicit `--engine` flag overrides auto-selection | `string` |
| SC-5 | 14-step serial chain solves successfully with default engine | `behavioral` |

## AI Agent Instructions

This issue is an executive summary for human stakeholders. The authoritative spec and plan are at this local path. AI agents MUST read the local spec/plan files for implementation and MUST NOT base implementation on this summary.

🤖 Co-authored with AI: OpenCode (nemotron-3-ultra-free)