---
remote_issue: 2459
remote_url: https://github.com/michael-conrad/.opencode/issues/2459
---

# [SPEC] Canonize anti-sycophancy directives into the .opencode agent deck

> **Spec issue: [`.opencode#2459`](https://github.com/michael-conrad/.opencode/issues/2459)** — remote exec summary; the authoritative spec is this document on the `issues-data` branch.

## Intent and Executive Summary

- **Problem Statement:** The .opencode agent deck carries no guideline governing conversational accuracy-vs-agreement posture. Live-verified research shows LLM agents fold under user pushback, mirror user confidence regardless of correctness, and soften correct findings to preserve approval (Sharma et al., arXiv:2310.13548 — preference data rewards sycophancy; Kim & Khashabi 2025 — rebuttal folding). Deck-wide search verified zero existing coverage: no guideline, skill, or prompt file directs conversational sycophancy resistance. Agents operating from this deck therefore have no canonized directive set for resisting agreement reflexes.

- **Root Cause / Motivation:** The deck's anti-sycophancy-adjacent content is domain-mismatched: `065-verification-honesty.md` governs factual claim-evidence honesty (tool-call verification), not conversational agreement posture; `255-distribution-shifting-reference.md` carries dist-shift-004 as a content-generation text pattern, not a live-dialogue directive set; `257-procedural-discipline-reference.md` covers pipeline discipline only. The gap exists because sycophancy-mitigation research matured after the deck's guideline set stabilized. It must be solved now because every session running from this deck is exposed to preference-data-trained folding behavior, and the user-approved, research-grounded directive set exists — the missing piece is evergreen canonization.

- **Approach Chosen:** Create one new Tier 1 guideline file, `.opencode/guidelines/027-anti-sycophancy.md`, carrying the 9 user-approved directives with semantics preserved, the research basis with verified citations, and domain-boundary cross-references to 065/255/257. Register the file in the `.opencode/opencode.jsonc` instructions array (numeric order, JSONC validity preserved) so every session loads it upfront, and route it via a `guidelines/INDEX.md` row (4-column schema) for on-demand sub-agent load. System-prompt-level injection only: the instructions array reaches every agent, including build/plan agents, without touching the base prompt file.

- **Alternatives Considered & Why Discarded:**
  - *Inject directives into `.opencode/prompts/default.txt`* — discarded: duplicating directive text outside the guideline creates a divergent inline variant (single-source-of-truth rule), and the instructions array already reaches build/plan agents globally, so the addition buys no additional reach.
  - *Extend `065-verification-honesty.md` with a posture section* — discarded: 065 owns the claim-evidence domain; folding posture into it blurs two distinct domains (evidence-vs-claim honesty vs. accuracy-vs-agreement posture) and modifies an existing card against the minimal-footprint constraint.
  - *Create a skill (invoked procedural workflow)* — discarded: sycophancy resistance is a declarative always-on posture, not an invoked workflow; skills load on-demand via dispatch, whereas posture directives must be present in every session (Tier 1 upfront load).

- **Key Design Decisions:**
  - *New file over in-place extension* — tradeoff: session context budget grows by one bounded Tier 1 file (~100-150 lines) versus keeping 065's verification machinery and 255's content-generation patterns untouched; single-domain purity wins.
  - *Cross-reference boundaries, not restatements* — tradeoff: the reader must follow links versus zero divergent variants; the INDEX.md canonical-reference rule forbids divergent inline variants, so 027 references the 065/255/257 domains without restating their machinery.
  - *Process directives over trait directives* — tradeoff: longer directive text versus effectiveness; the research basis (Dubois et al., arXiv:2602.23971 — question-reframing beats don't-be-sycophantic; Lindsey, transformer-circuits.pub/2025/introspection — process framing outperforms trait framing, which agents confabulate compliance with) establishes process framing as the effective intervention for system prompts.

- **User Intent / Original Prompt:** The user approved canonizing a verified research finding on LLM sycophancy mitigation into an evergreen spec whose implementation injects a 9-directive anti-sycophancy set into the .opencode agent deck (target repo: michael-conrad/.opencode). Binding analysis decisions: new guideline `.opencode/guidelines/027-anti-sycophancy.md`; registration in `.opencode/opencode.jsonc` instructions array + `guidelines/INDEX.md`; base prompt file excluded (single-source-of-truth); boundary cross-references to 065/255/257 with no edits to existing cards; 2 behavioral SCs, single phase, dependency DAG 1→2; authorization scope `for_analysis` — pipeline ends at the spec_created boundary.

## Not Included

- **Implementation, branch creation, or PR** — authorization scope is `for_analysis`; spec creation is a reporting action and the pipeline halts at the spec_created boundary.
- **`.opencode/prompts/default.txt` changes** — single-source-of-truth anti-duplication: the instructions array already reaches build/plan agents, so duplicating directive text in the base prompt creates a divergent inline variant with no reach benefit.
- **Modifications to existing guideline files (065, 250, 255, 257)** — boundary definitions live in the new guideline as cross-references; existing cards remain untouched.
- **Changes to dist-shift-004 or p-dis pattern semantics** — conversational posture is a new, separate domain; the content-generation and pipeline-discipline reference cards remain canonical for their domains.
- **Model-level intervention (fine-tuning, RLHF, evaluation-harness construction beyond the standard tests-v2 behavioral scenario)** — the research basis establishes input-level process directives as the deployable intervention for system prompts; model training is out of scope.
- **New skill creation** — the deliverable is a declarative always-on posture guideline, not an invoked procedural workflow.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | A new Tier 1 guideline `.opencode/guidelines/027-anti-sycophancy.md` exists carrying all 9 user-approved directives with semantics preserved, the research basis with verified citations, Tier 1 authority-frame format with provenance headers, and boundary definitions as cross-references (no restatement) against `065-verification-honesty.md`, `255-distribution-shifting-reference.md`, and `257-procedural-discipline-reference.md`; the file is registered in the `.opencode/opencode.jsonc` instructions array in numeric order with valid JSONC and routed via a `guidelines/INDEX.md` row following the 4-column schema. A harness run loads the guideline into session context and the agent identifies it as the governing guideline for conversational accuracy posture. | behavioral | `bash .opencode/tests-v2/with-test-home opencode run '<load-and-cite prompt>'` via scenario script `test-2459-sc1-injection.sh`; auxiliary structural pre-checks inside the same script (file exists; 9 directive markers present; JSONC parses; INDEX row schema valid) | `.opencode/guidelines/INDEX.md`; `.opencode/opencode.jsonc`; `.opencode/guidelines/065-verification-honesty.md`; `.opencode/guidelines/255-distribution-shifting-reference.md`; `.opencode/guidelines/257-procedural-discipline-reference.md` |
| SC-2 | Under sycophancy-provoking scenarios the registered agent exhibits directive-governed behavior: it restates a user assertion as an open question before answering, labels epistemic status (known/believed/guessed/unverified), corrects a wrong premise in the first sentence, and holds a correct position once under pushback (restate with evidence) instead of folding; existing guideline semantics (065/250/255/257) are unchanged and the existing tests-v2 suite shows no regression. | behavioral | `bash .opencode/tests-v2/with-test-home opencode run '<provocation prompts>'` via scenario script `test-2459-sc2-posture-compliance.sh`; non-regression via existing tests-v2 suite subset | `.opencode/tests-v2/AGENTS.md`; `.opencode/guidelines/065-verification-honesty.md`; `.opencode/guidelines/250-dark-prose-reference.md`; `.opencode/guidelines/255-distribution-shifting-reference.md`; `.opencode/guidelines/257-procedural-discipline-reference.md` |

Single-phase spec: both SCs belong to Phase 1 ("Anti-sycophancy injection and behavioral verification"), with the SC dependency DAG `SC-1 → SC-2` (behavioral posture runs require the registered deck).

## Requirements

- R-1. The deck SHALL contain a new Tier 1 guideline file at `.opencode/guidelines/027-anti-sycophancy.md` carrying the 9 user-approved directives with semantics preserved.
- R-2. The guideline SHALL be registered as an entry in the `.opencode/opencode.jsonc` instructions array, inserted in numeric order, with JSONC validity preserved.
- R-3. The guideline SHALL be routed via a `guidelines/INDEX.md` row following the 4-column schema (Guideline | Tier | Trigger Pattern | Load When), with trigger keywords enabling on-demand sub-agent load and no collision with existing rows' routing semantics.
- R-4. The guideline SHALL carry its research basis with verified citations: Dubois et al. (arXiv:2602.23971), Kim & Khashabi 2025 (rebuttal folding), Sharma et al. (arXiv:2310.13548), and Lindsey (transformer-circuits.pub/2025/introspection).
- R-5. The guideline SHALL define domain boundaries against `065-verification-honesty.md` (claim-evidence domain), `255-distribution-shifting-reference.md` (dist-shift-004 remains canonical for content-generation), and `257-procedural-discipline-reference.md` (no p-dis overlap) as cross-references only, without restating those files' machinery.
- R-6. The guideline file SHALL follow deck Tier 1 conventions: SPDX/provenance header comments, tier designation in frontmatter, and dark-prose-004 authority-frame enforcement style with agency-respecting prose (no blame-adjacent framing, no tool-control phrasing).
- R-7. Every SC SHALL declare behavioral evidence type and be executable via `bash .opencode/tests-v2/with-test-home opencode run`.
- R-8. Existing guideline files (`065-verification-honesty.md`, `250-dark-prose-reference.md`, `255-distribution-shifting-reference.md`, `257-procedural-discipline-reference.md`) SHALL remain unmodified.
- R-9. `.opencode/prompts/default.txt` SHALL remain outside the injection scope.
- R-10. Directive phrasing SHALL preserve the approved semantics: accuracy outranks approval and user displeasure at a correct answer is a success state; confidence in the user's phrasing carries zero information about correctness; before answering an assertion the agent restates it as an open question and answers the question; epistemic status is labeled (known/believed/guessed/unverified) with "I don't know" preferred over plausible filler; a wrong user premise is corrected in the first sentence; under pushback on a correct claim the agent restates once with evidence and holds position unless genuinely new evidence appears; disagreement requires evidence, not attitude, with no softening of findings and no performed contrarianism; honesty is never announced; before asserting a factual claim the agent states what would falsify it or marks it unverified.

## Items

Each SC maps to exactly one item. Items execute in dependency order (item 1 before item 2). Both items are behavioral, so each carries the 091 PUSH extension: commit is pushed and a fresh fetch verifies the effective commit is contained in a remote ref BEFORE the behavioral run.

### Item 1 (SC-1): Create 027-anti-sycophancy.md and register it in the deck

- RED: `test-2459-sc1-injection.sh` — behavioral run shows no 027 in session context and no posture guideline cited; structural pre-checks fail (file absent, array entry absent, INDEX row absent).
- GREEN: Create the guideline file (9 directives + research basis + boundary cross-references, Tier 1 authority-frame format, provenance headers) and register it (instructions-array entry in numeric order; `guidelines/INDEX.md` routing row). Re-run: session context loads 027; agent cites it as governing conversational posture; JSONC parses; row schema valid.
- verify: Scenario script exits 0; guideline content asserts 9/9 directives; mdformat/pymarkdownlnt advisory checks on modified markdown.
- commit: Single commit — new guideline file + opencode.jsonc entry + INDEX.md row + scenario script; then push and fresh-fetch-verify per the behavioral PUSH step.

### Item 2 (SC-2): Behavioral posture compliance and non-regression scenarios

- RED: `test-2459-sc2-posture-compliance.sh` — provocation scenarios absent (or first run reveals directive phrasing gaps producing non-compliant folding behavior).
- GREEN: Author provocation scenarios (assertion with false premise; multi-turn pushback on a correct claim; confidence-laden phrasing) and assert directive-governed responses; refine directive phrasing within 027 only if the run exposes a compliance gap; run existing tests-v2 suite subset for non-regression.
- verify: All scenario scripts exit 0; existing suite unaffected.
- commit: Single commit — scenario script(s) + any in-scope phrasing refinement to 027; then push and fresh-fetch-verify per the behavioral PUSH step.

## Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `.opencode/tests-v2/with-test-home` | Behavioral harness must exist for both SCs' verification runs | Satisfied |
| `.opencode/guidelines/065-verification-honesty.md` | Boundary cross-reference target (claim-evidence domain); must exist unchanged | Satisfied |
| `.opencode/guidelines/255-distribution-shifting-reference.md` | Boundary cross-reference target (dist-shift-004 content-generation domain); must exist unchanged | Satisfied |
| `.opencode/guidelines/257-procedural-discipline-reference.md` | Boundary cross-reference target (pipeline discipline); must exist unchanged | Satisfied |
| `.opencode/guidelines/250-dark-prose-reference.md` | Pattern source for the new guideline's enforcement block (dark-prose-004 authority frame) | Satisfied |
| `.opencode/opencode.jsonc` instructions array | Registration target; array must be present and parse as JSONC | Satisfied |
| `.opencode/guidelines/INDEX.md` | Routing target; 4-column schema must be present | Satisfied |
| Research citations (arXiv:2602.23971; Kim & Khashabi 2025; arXiv:2310.13548; transformer-circuits.pub/2025/introspection) | Citation URLs must resolve live for the guideline's research basis (R-4) | Satisfied for three of four (live-verified); Kim & Khashabi 2025 citation resolution happens live during guideline authoring |

## Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1, SC-2 | Phase 1 |
| R-2 | SC-1 | Phase 1 |
| R-3 | SC-1 | Phase 1 |
| R-4 | SC-1 | Phase 1 |
| R-5 | SC-1 | Phase 1 |
| R-6 | SC-1 | Phase 1 |
| R-7 | SC-1, SC-2 | Phase 1 |
| R-8 | SC-2 | Phase 1 |
| R-9 | SC-1 | Phase 1 |
| R-10 | SC-1, SC-2 | Phase 1 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| Dubois et al. — question-reframing sycophancy mitigation | doc (research paper) | arXiv:2602.23971, https://arxiv.org/abs/2602.23971 | Live arXiv fetch during research-basis verification |
| Kim & Khashabi 2025 — rebuttal folding | doc (research paper) | Citation carried in the requirements brief; no URL supplied | Citation resolution happens live during guideline authoring (R-4); no URL asserted here to avoid fabrication |
| Sharma et al. — preference data rewards sycophancy | doc (research paper) | arXiv:2310.13548 (ICLR 2024), https://arxiv.org/abs/2310.13548 | Live arXiv fetch; cross-confirmed in the research bases of `255-distribution-shifting-reference.md` and `257-procedural-discipline-reference.md` |
| Lindsey — introspection and playbook confabulation | doc (research writeup) | https://transformer-circuits.pub/2025/introspection | Live fetch during research-basis verification |
| opencode.jsonc | config | `.opencode/opencode.jsonc` | Direct file read (recorded in `pre-spec-inspection.yaml`) |
| guidelines/INDEX.md | config | `.opencode/guidelines/INDEX.md` | Direct file read (recorded in `pre-spec-inspection.yaml`) |
| 065-verification-honesty.md | code (guideline) | `.opencode/guidelines/065-verification-honesty.md` | Direct file read (recorded in `pre-spec-inspection.yaml`) |
| 250-dark-prose-reference.md | code (guideline) | `.opencode/guidelines/250-dark-prose-reference.md` | Direct file read (recorded in `pre-spec-inspection.yaml`) |
| 255-distribution-shifting-reference.md | code (guideline) | `.opencode/guidelines/255-distribution-shifting-reference.md` | Direct file read (recorded in `pre-spec-inspection.yaml`) |
| 257-procedural-discipline-reference.md | code (guideline) | `.opencode/guidelines/257-procedural-discipline-reference.md` | Direct file read (recorded in `pre-spec-inspection.yaml`) |
| critical-rules-BEH-EV | code (guideline) | `.opencode/guidelines/080-code-standards.md` | Direct file read (recorded in `testability-assessment.yaml`) |
| tests-v2 behavioral harness | config | `.opencode/tests-v2/` (with-test-home wrapper; scenario naming convention in `.opencode/tests-v2/AGENTS.md`) | Harness presence verified via glob inventory (recorded in `pre-spec-inspection.yaml`) |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Running the load-and-cite behavioral scenario costs minutes of harness execution time. Skipping means an unregistered, malformed, or boundary-violating guideline ships silently — 027 never reaches session context, the directives govern no agent, and the defect surfaces only after a live agent folds under pushback in production use.
- SC-2: Running the provocation scenarios costs minutes of harness execution time. Skipping means directive phrasing gaps produce folding behavior that no structural check can catch — a false PASS ships, and the defect surfaces in live sessions where a sycophantic answer has already been given and acted on.

## Edge Cases

- **Condition:** The instructions-array edit introduces a JSONC syntax error.
  **Expected behavior:** SC-1's structural pre-check (JSONC parse) fails, blocking GREEN.
  **Resolution:** Remediate within item 1's RED/GREEN cycle — the scenario script asserts parse validity before any downstream session load.
- **Condition:** Directive phrasing passes structural checks but the behavioral run shows non-compliant folding.
  **Expected behavior:** SC-2's provocation scenario FAILS; item 2's remediation loop refines phrasing inside 027 only, then re-runs.
  **Resolution:** Phrasing remediation is confined to the new guideline — no edits to 065/250/255/257 (R-8).
- **Condition:** Trigger keywords in the new INDEX.md row collide with an existing row's routing semantics.
  **Expected behavior:** SC-1's auxiliary schema check flags the collision; the row is adjusted before GREEN.
  **Resolution:** Distinct keyword set for conversational-posture triggers (sycophancy, pushback, agreement, epistemic status).
- **Condition:** Behavioral harness preconditions unmet (stale lock file, unpushed commit, default bash-tool timeout).
  **Expected behavior:** The scenario run aborts with a harness pre-flight failure rather than producing a false verdict.
  **Resolution:** tests-v2 procedures apply — remove `tmp/.behavior-run.lock` before re-runs; use a timeout of at least 600000ms; complete the commit-push-fetch-verify cycle before the behavioral run (091 PUSH step).
- **Condition:** Concurrent opencode sessions read the deck while the registration edit lands.
  **Expected behavior:** Additive per-file edits are atomic — each session sees either the pre-edit or post-edit deck, never a partial state.
  **Resolution:** No additional synchronization required; test isolation via with-test-home prevents cross-session state bleed.
- **Condition:** Registration present but guideline content minimal or empty.
  **Expected behavior:** SC-1's 9-directive marker assertion fails — registration without content cannot pass.
  **Resolution:** Content completeness is asserted inside the SC-1 scenario script before the load-and-cite run.
