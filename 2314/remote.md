---
remote_issue: 2314
remote_url: "https://github.com/michael-conrad/.opencode/issues/2314"
last_sync: 2026-10-02T12:10:00Z
source: github
---

> **Full spec and artifacts: [`.opencode.issues/2314/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2314)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode.issues/2314/` — implementation plan (5 phases), card catalogue, dependency contracts, research, audit findings

## Problem

When a spec issue body contains success criteria and affected file paths, a sub-agent can be dispatched directly to implementation from the spec content — bypassing the mandatory writing-plans pipeline entirely. Subsequent regressions show supervision-layer gaps too: the §14 behavioral-run monitor polls endlessly with no terminal verdict, and behavioral run agents can escape their fixture onto the real issue store.

## Spec Reference

Read the full spec at `.opencode.issues/2314/spec.md` on the `issues-data` branch (19 atomic SCs, requirements R-1..R-11, root causes 1-7, change control).

## Scope

- `PLAN_MISSING` dispatch-boundary gate across five deck surfaces (spec-creation, executing-plans, 000-critical-rules, dispatch-vocabulary table, plus bypass-path surfaces git-workflow pre-work and TDD RED)
- Behavioral block/permit legs proving gate behavior end-to-end via real `opencode run` evidence
- §14 semantic continuous monitoring compliance for this issue's behavioral legs (env flag, Read-link, monitor evidence, poll cadence, abort handling)
- Absolute §14-monitor termination bound (SC-18) — terminating even progressing runs with a `terminate-with-root-cause` classification via a documented env knob
- Fixture issue-store sandbox (SC-19) — run agents confined to injected fixture issue data

**Out of scope:** §14 poll-cadence/abort-semantics re-specification; plan-generation behavior changes; behavioral-run supervision for other issues' legs; other skill-to-skill handoff boundaries.

## Approach

The gate is routing text at the dispatch boundaries — the dispatch decision point, not file-write time — backed by a Tier 1 CRITICAL VIOLATION entry and a canonical `PLAN_MISSING` vocabulary registration. Behavioral enforcement scenarios prove block (plan-less, even when developer-authorized) and permit (plan-bearing) outcomes through real `opencode run` stderr evidence under supervision. The monitor gains a non-deferrable absolute termination bound composing after suppression rules, and the fixtures sandbox issue-store access so behavioral evidence remains attributable to fixture-scoped behavior.

## Impact

- **Risk: false-positive blocks break pipeline availability** — mitigated by dedicated permit SCs (SC-6, SC-8) asserting plan-bearing dispatch proceeds without a block
- **Risk: resolver knob mis-tuned terminates healthy runs** — mitigated by documented bounded defaults and the bound's existence-only semantics (staleness stays with the coherence gate)
- **Risk: fixture sandbox over-restricts access to the fixture issue itself** — mitigated: the boundary is fixture-vs-real-store only; fixture-issue access is permitted
- **Dependency:** behavioral legs require committed+pushed submodule state per tests-v2 §4; supervised runs require §14 monitor evidence per §14 step 6

**Call to action:** implement the 5 phases in dependency order (dispatch-gate-logic → behavioral-enforcement → behavioral-run-supervision → bypass-path-gates → regression-hardening); all 19 SCs must pass with evidence-type-matched artifacts before completion.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
