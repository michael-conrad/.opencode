# Test-discipline card: run-real-code anchor, light-default/heavy-on-demand, mark-on-creation test classes

Source: developer direction (2026-11-06, filed this spec's session) — "we need a special skill card created or to have programming principles updates whose description indicates it should be referenced when creating SPECs and PLANs so that the SC matching tests can be properly marked as ephemeral vs for PR only vs smoke/regression with appropriate granularity … the card really needs to try and anchor the agent on testing updated code paths via actually running the code and that the default always run regression/smoke tests should not be heavy but that heavier regression tests are permissible so long as they are only on demand." Evidence basis: [research/2026-11-06-agent-test-accumulation-heavy-tests.yaml](research/2026-11-06-agent-test-accumulation-heavy-tests.yaml) (exhaustive two-pass research, 8 dispatches, key primaries spot-verified in session).

## Problem

The deck's authoring and verification directives push agents to write tests every cycle (`implement` "Test tiers: smoke + regression are the default for every cycle and PR"; `implementation-workflow` tier table; `systematic-debugging` #5 "Add the failing case as a behavioral test"), but no deck surface classifies tests **at creation** or sets a **weight policy** for what runs by default. The documented failure pattern (research card, pass 1 + pass 2):

1. **Accumulation.** Agent test content accumulates across implementation sessions; heavyweight tests written solely to validate one PR/issue ticket survive into every deploy build (FA: "Test folders bloat faster than source folders in most repositories using assistants"; "the same mock setup pasted into a dozen test files"; dedup-blind generation "that resemble existing ones without recognizing that the behavior has already been verified elsewhere"). Cross-session per-ticket accrual is documented anecdotally only (research gaps — stated, not overstated); what IS vendor-verified is the lifecycle absence — no public vendor or framework standard defines a ticket-scoped-test lifecycle (F9).
2. **Low-value mass.** Agent "tests" are frequently observational scaffolding, not regression value: print statements dominate assertion checks (practitioner-measured print:assertion ratio 4.8:1 — codex-practice), test-writing frequency does not correlate with task resolution, and prompt-induced test-volume changes do not alter outcomes (arXiv:2602.07900 — FB); agent-generated files are measurably flakier (candidate rate 0.41 vs 0.30; 204,673-file AIDev study framing them as "stealth technical debt" — FC).
3. **Heavy default.** Heavy tests on the per-commit/default path are the named industry anti-pattern: Google isolates large tests "so as not to impact developer workflow" (F1, SWE-book ch.11).
4. **Missing anchor.** Verification by actually running the updated code is vendor-confirmed best practice and absent from the deck as a norm: Anthropic's harness post shows unit-tests+curl failing and actual end-to-end verification "dramatically improving performance" (F7, anthropic-harness); OpenAI Codex prescribes "re-run the repro steps after the fix" separate from "the smallest relevant test suite" (codex-prompting). Theory corroboration: SWE-book ch.13 (real implementations first choice; mock overuse "rarely finding bugs"), Fowler ("mockist tests… run green but mask inherent errors"), Shore's Testing Without Mocks (F6).
5. **On-demand heavy tier.** Light-default/heavy-on-demand is documented convention in every mature toolchain (Rust `#[ignore]` + `-- --ignored`, pandas `-m 'not slow …'`, Gradle integrationTest suite, Böckeler fast-gate/post-integration split) (F2: the documented per-toolchain exclusion mechanisms; F8: the fast-gate vs post-integration lifecycle split) — the deck has heavy suites but no on-demand classification (F2, F8).

The class vocabulary for ticket-scoped tests (ephemeral / pr-validation) is **novel-but-grounded**: no vendor documents marker tags like validation-only/ephemeral or a promote/consolidate/retire checkpoint as of 2026-11-06 (research F9, novelty_flag); the deck inventing it here is grounded in the tiering/flakiness evidence, and the card should own that novelty rather than cite it as industry consensus.

## Scope

One new deck skill card, `test-discipline` (engineering cluster, adjacent to `programming-principles`), filed and admitted through the deck's governance card. File: `.opencode/skills/test-discipline/SKILL.md`. No edits to other cards in this spec — the directive-surface rewrites (implement, implementation-workflow, systematic-debugging, plan) are sibling `.opencode#2725`.

## Requirements

- R-1 (structural): the card's description SHALL trigger on spec creation, plan creation, and test authoring/verification, so the card is loaded when SPECs and PLANs are created and SC-matching tests are classified.
- R-2 (structural): the card SHALL define the mark-on-creation vocabulary — every test an agent writes is classified at write time with its tier marker:
  - `ephemeral` — scratch observation (print-debug probes, intermediate-value checks); never committed as a test file,
  - `pr-validation` — proves this PR fixes this ticket; run at PR-check time only; dispositioned (promote / consolidate / retire) at merge, never by default into the suite,
  - `smoke` — default always-run; SUT starts + critical paths; seconds-scale,
  - `regression` — changed area + direct dependents; default gate,
  - `heavy-regression` — permitted, opt-in only: excluded from every default run; scheduled or explicitly requested,
  with the granularity rule: push verification down the tiers as far as the change allows; a heavier-tier test earns its place only when lower tiers cannot reach the behavior.
- R-3 (structural): the card SHALL carry the run-real-code anchor as the primary verification norm: verify an updated code path by executing the real implementation (repro command, real app boot, real dependencies); mock-interaction tests are the fallback for awkward or dangerous collaborators only, never the sole evidence.
- R-4 (structural): the card SHALL carry the light-default policy — the always-run gate stays seconds-to-low-minutes (smoke + changed-area regression); full suite, benchmarks, mutation testing, and broad e2e run on demand, scheduled, or at release boundaries only.
- R-5 (behavioral): a fresh-dispatch agent creating a plan for a sample SC under the card SHALL produce SC-matching test items classified per the vocabulary, SHALL route heavy-tier items on-demand, and SHALL NOT list ephemeral scratch as authored test artifacts in the plan output.
- R-6 (structural): the card SHALL carry provenance and admission-gate evidence per the deck governance card (skill-creator).

## Success criteria

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | card exists at `.opencode/skills/test-discipline/SKILL.md`; description names spec creation, plan creation, and test authoring/verification triggers | structural | read card frontmatter description |
| SC-2 | card defines all five classes, each class's run placement, and the granularity rule | structural | read card body |
| SC-3 | card carries the run-real-code anchor (execute the real implementation; mocks are fallback, never sole evidence) | structural | read card body |
| SC-4 | card carries the light-default policy (always-run gate seconds-to-low-minutes; heavy suites on-demand/scheduled/release-boundary) | structural | read card body |
| SC-5 | fresh agent's plan for a sample SC classifies test items per the vocabulary; heavy-tier items routed on-demand; no ephemeral scratch listed as authored test artifacts | behavioral | dispatched behavioral probe |
| SC-6 | card frontmatter carries provenance and admission-gate evidence | structural | read card frontmatter + governance record |

## Out of scope

- Directive-surface rewrites (implement, implementation-workflow, systematic-debugging, plan) — sibling `.opencode#2725`.
- Changes to the spec card's validation-standards criteria set (deck governance, separate).
- CI workflows, hooks, or mechanical enforcement of run placements — the card classifies; no script decides.
- Language cards (java, gradle, python) — their existing unit-test/DI guidance is untouched.

## Approach

New standalone card (chosen); the alternative — extending `programming-principles` — was weighed and rejected: the content is a load-hooked discipline cluster (trigger on spec/plan authoring), distinct from that card's design-principles subject, and the description-level load trigger is what the platform resolves by description match. Admission evidence is required by skill-creator either way, so the standalone form loses nothing and gains an independent description trigger. Vocabulary sourced from the research card's synthesis (card_ready_material section); the novelty of the ephemeral/pr-validation classes is stated in the card text itself (per research F9).

## Impact

- Consumers: agents authoring specs, plans, and tests — one on-demand card gained; deck governance review (skill-creator admission gate).
- Risk: low — no runtime code, no CI surface, no workflow-tooling change; the always-injected floor is unchanged.
- Blast radius: the vocabulary states once in this card (single-sourcing); directive surfaces reference it per the sibling spec.
