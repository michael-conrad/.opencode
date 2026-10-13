<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: mirrored from the remote-tracked content of .opencode#2551 (github.com/michael-conrad/.opencode/issues/2551) on 2026-10-13 under the mirror-repair rule (issues §7); remote body pointer corrected 2554 → 2551 in the same action. Authoritative analysis lives here. -->

# Spec: .opencode#2551 — Consumable-framework effort bound absent — agent performed hours of hand-verification of Gradle-resolved library internals and wrote fabricated verification tests

## Bug (agent-behavior defect, complete analysis)

### Observed behavior

Session 2026-10-07/08 (hermes-admin#9 implementation, agent OpenCode
(huggingface/zai-org/GLM-5.3-Flash)): implementing the #9 auth subsystem, the agent spent
multiple wall-clock hours hand-verifying Spring Boot 4.1.1, Spring Session JDBC 4.1.1, and
Vaadin Flow 25.3 INTERNALS — javap bytecode disassembly of `VaadinSecurityConfigurer`,
extracting sources JARs, tracing `JdbcIndexedSessionRepository` query construction,
API-migration archaeology (TestRestTemplate removal, `VaadinWebSecurity` removal) — for
libraries the project merely consumes via Gradle.

Developer rulings (same session):

- "wtf are you doing? this is a mini project with no real code committed and it is taking your hours upon hours for a simple spec?"
- "what the actual fuck? you are NOT maintaining Vaadin or Spring. they are consumables."
- Sharpening: "consumables are bundled and provided by gradle. not by bespoke trash and they do not need fabricated tests to check that gradle does as gradle says it does."

### Root cause analysis (three defect classes)

**Class 1 — Unbounded consumables-curation.** Verification guidance
("live-verify over training data", `research`, `systematic-debugging`) is one-directional: it
mandates verification without bounding depth appropriate to a CONSUMED dependency — so deep
internals archaeology read as diligence, not defect. Consumed frameworks need: documented API
at the declared version, one docs pass, resolved-version recording; anything deeper requires
per-occurrence developer instruction.

**Class 2 — Fabricated verification tests.** Same missing boundary produced tests verifying
not application behavior but what Gradle/framework already guarantee:

- source-content inspection ("does SecurityConfig.java contain this string") — config narration;
- environment re-read of a property pin — tautology (framework does what it says);
- token-surface repo scan — a placeholder with assertion-shaped body.

These passed as RED/GREEN evidence with no defect existing. The implement card's "never test
an artifact the build system already guarantees" exists but did not fire: principle-bullet,
no enforcement, no offender examples.

**Class 3 — Narration-as-work sprawl (amplifier).** Every internals detour was scaffolded
with visible methodology (javap dumps, debug-print tests, hypothesis chains) presenting as
progress while producing zero deliverable code. The floor's halt formula covers unsureness
but has no reciprocal gate on unbounded self-directed exploration — a "simple spec" consumed
hours with no mechanism firing on the narration/deliverable ratio.

### Why existing guidance did not prevent it

| Guiding artifact | Content | Why it failed |
|---|---|---|
| implement §5 | "never test an artifact the build system already guarantees" | principle bullet, no enforcement hook, no offenders; did not fire mid-cycle |
| implement §4 | library-first | positive-side only; no verification-effort bound |
| research card | live verification | mandates verification without depth boundary; read as license for archaeology |
| floor standing formula | halt when unsure | agent wasn't unsure — over-verifying; no halt |
| work card | stage gates | gates authorization, not effort; correctly-scoped plan still ballooned |

### Requested upstream fix (deck-level; developer authorizes scope)

1. Bounded-effort consumables rule (implement card as a gate, or floor): documented-API
   implementation at declared version, one docs pass, resolved-version recording; deeper
   internals verification only on per-occurrence developer instruction.
2. Fabricated-tests gate with concrete offender classes (source-text inspection;
   environment/framework re-read tautologies; assertion-shaped placeholders) enforced at
   RED/GREEN time.
3. Narration-to-deliverable bound: when methodology-only turns exceed a small threshold in a
   work cycle, surface the ratio and halt for direction (open-ended, per standing formula).

### Repro context

- Repo NewsRx/hermes-admin, issue hermes-admin#9 (auth subsystem spec).
- Agent OpenCode (huggingface/zai-org/GLM-5.3-Flash).
- Timeline: baseline green → Item-1 commit ~30 min in → internals verification until
  developer interruptions; three interruption exchanges before the pattern stopped.
- Project-side remediation spec: hermes-admin#23 (SOP amendment). This report covers the
  upstream deck defect (guidance gaps that permitted the behavior).
