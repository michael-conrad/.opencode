---
name: test-discipline
description: "Load when creating or revising a SPEC or PLAN whose success criteria match tests, and when writing, classifying, or verifying tests against updated code paths — every test is marked with its tier at creation, heavy tiers never enter default runs, and verification runs the real code. Also load when deciding what evidence a test provides (ephemeral observation vs committed artifact), when a test suite has grown heavy on the default path, and when PR-check work needs the pr-validation execution surface."
license: MIT
provenance: "AI-authored, filed from developer direction 2026-11-06; admitted per the deck governance card — observed failure: agent test accumulation across sessions with heavyweight per-ticket tests surviving deploy builds, print-dominated observational scaffolding, heavy default path, and a missing run-real-code anchor (research evidence on the issue's artifacts branch; vendor corroboration: Anthropic harness post, OpenAI Codex guidance, Google SWE-book test sizing, Fowler/Shore mock critiques); admits with no retire: the deck carried no test-classification surface before this card"
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: developer direction 2026-11-06 (.opencode#2724); evidence basis held on the issue's artifacts branch in the issue store -->

# test-discipline — run real code, mark tests at creation, keep the default gate light

The deck's authoring directives require tests every cycle; this card supplies
what those directives were missing: a vocabulary that classifies each test at
the moment it is written, a weight policy for what runs by default, and the
anchor that actual verification executes the real implementation.

## 1. Mark on creation

Every test an agent writes is classified at write time with its tier marker.
Nothing enters a test file unmarked.

| Tier | What it is | Run placement |
|------|------------|---------------|
| `ephemeral` | Scratch observation — print-debug probes, intermediate-value checks. Never committed as a test file; lives in the session's own space. |
| `pr-validation` | Proves this PR fixes this ticket. Runs at PR-check time only; dispositioned at merge (promote into the suite, consolidate with an existing test, or retire) — never by default into the suite. |
| `smoke` | SUT starts + critical paths. Default always-run. Seconds-scale. |
| `regression` | Changed area + direct dependents. Default gate (rides with smoke). |
| `heavy-regression` | Permitted, opt-in only: excluded from every default run; scheduled runs, or an explicit developer request. |

**Granularity rule:** push verification down the tiers as far as the change
allows — a heavier-tier test earns its place only when lower tiers cannot
reach the behavior. A PR-ticket failure reachable by a 2-second smoke check
never authorizes a heavyweight harness.

**Novelty, stated:** no vendor or framework documents ticket-scoped test
markers (ephemeral / pr-validation) or a promote/consolidate/retire
disposition check as of 2026-11-06 — the vocabulary is deck-invented, grounded
in the researched tiering/flakiness failures, not cited as industry consensus.
The light-default/heavy-on-demand split, by contrast, is the documented
convention of mature toolchains (Rust `#[ignore]`, pytest `-m 'not slow …'`,
Gradle integrationTest source set, fast-gate vs post-integration lifecycle
splits).

## 2. Run real code — the primary verification norm

Verify an updated code path by executing the real implementation: the repro
command, the real application boot, the real dependencies. Mock-interaction
tests are the fallback for awkward or dangerous collaborators only (networks
that must not be hit, payloads that cannot be produced) — never the sole
evidence that a fix works. A green mock suite is a claim about the mock; the
run-real-code pass is the claim about the change.

## 3. Light default, heavy on demand

The always-run gate stays seconds-to-low-minutes — smoke + changed-area
regression. The full suite, benchmarks, mutation testing, and broad e2e runs
execute on demand, on schedule, or at release boundaries only. Heavier
regression tests are permissible so long as they are on-demand; nothing
heavyweight rides the per-commit path.

Directive surfaces (implement, implementation-workflow, systematic-debugging,
plan) state their run-specific rows and cite this card; this card owns the
tier definitions.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
