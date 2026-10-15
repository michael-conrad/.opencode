# Coverage Audit — routing.md removal (spec §2 fixed criteria set)

number: 2617
date: 2026-10-15
deck_state: .opencode @ f5f82527 (pre-removal)
method: two independent fresh-context audit passes (the first re-dispatched on the
developer's instruction), each deriving the row→surface map from the live deck's card
frontmatter descriptions and floor content; orchestrator reconciliation against the spec's
§2 preliminary map, with every disagreement adjudicated on live-deck evidence (spec Design
Decision 4). No scripted coverage matching — all coverage judgments are fresh-context review;
scripts verified only mechanical facts.

## Audit passes

- **Pass 1** (task ses_ec0467c0affeCaYHm7Tq1T8J5m): read all 35 card descriptions + floor.
- **Pass 2** (task ses_ec0435a64ffeyPROZhtnyIlwmv, re-dispatch): read all card descriptions +
  floor in full; instructed to note card bodies separately.

## Reconciled map (28 rows: R1–R27 + footer)

| Row | Post-removal dispatch surface (live, quoted) | Verdict |
|-----|----------------------------------------------|---------|
| R1 | work desc: "Load before any file modification, branch creation, or implementation start in any repo… Routes every change through spec → plan → implement → PR scaled to the change's need"; floor §Pipeline + §52 work-gate row | covered (both passes) |
| R2 | explore desc: "Load when requirements are being explored, decomposed, or brainstormed before a spec exists" | covered (both) |
| R3 | spec desc: "Load when creating or revising a specification document" | covered (both) |
| R4 | plan desc: "Load when writing an implementation plan from an approved spec" | covered (both) |
| R5 | implement desc: "Load when executing an approved plan or making any change during the implementation work cycle" | covered (both) |
| R6 | verify desc: "Load when checking a deliverable against its stated requirements before any completion or PR-readiness claim" | covered (both) |
| R7 | verify desc — **no audit trigger today**; floor §52 authorization-vocabulary token `audit` ("audits run on a fixed criteria set… verify card") is the only carrier | **partial — REMEDIATING** (both passes agree) |
| R8 | git-workflow-branch desc: "Always load before creating any git branch or starting any work on a task in any repo" | covered (both) |
| R9 | git-workflow-commit desc: "Always load before staging files or creating ANY commit" | covered (both) |
| R10 | git-workflow-pr desc: "Load before opening any pull request, preparing work for review, or updating an existing PR"; floor §52 "(procedure in `git-workflow-pr`)" | covered (both) |
| R11 | git-workflow-cleanup desc: "Load after any pull request merges…"; floor §52 "`pr merged` → cleanup" | covered (both) |
| R12 | git-workflow-conflict desc: "Load when git reports conflicts during any rebase, merge, or cherry-pick, or when a push/PR shows merge contention" | covered (both) |
| R13 | issues desc: "Load when creating, reading, updating, commenting on, linking, or closing any issue — local .issues/ stores, GitHub, or GitBucket" | covered (both); "reading/resolving" maps to "reading, updating… closing" — adjudicated covered, no remediation |
| R14 | gh-cli desc ("before any command or code that contacts GitHub"), gb-cli desc (GitBucket), playwright-cli desc ("any browser automation"); **notebooks** → floor external-access table (notebook MCP row — no connector card exists; floor-carried per §2 R14); **hf** → dead reference in the table, no card exists, nothing is owed — removal remediates (§2 R14 disposition) | covered (spec-fixed dispositions; both passes' hf/notebook flags re-adjudicated to §2's recorded outcomes) |
| R15 | wiki-operations desc covers edit/creation/sync, `.wiki.git` checkout, sidebar/footer, provisioning, publishing, recovery; **conversion element absent** (pass 1: partial; pass 2: covered-as-intent; §2 preliminary: partial) — disagreement resolved to the stricter reading per the card standards' pushiness rule | **partial — REMEDIATING** |
| R16 | ci-boundary desc: "Load before creating or modifying CI for ANY repository — pipelines, runners, workflows, or submodule checkout configuration" | covered (both) |
| R17 | research desc ("information is needed beyond current context… root-cause analysis") + systematic-debugging desc ("encountering a bug, error, unexpected behavior, or failing test") | covered (both) |
| R18 | email-management desc: "Load when the session involves email — gmail, inbox, drafts, sending, or mail searches" | covered (both) |
| R19 | programming-principles desc: "Load when designing or writing code… or when reviewing code" — **"auditing code" absent**; floor's `audit` token routes to verify, creating misroute pressure for code-audit phrasings (both passes agree; §2 preliminary said covered — fresh derivation overrides per Design Decision 4) | **partial — REMEDIATING** |
| R20 | reference-currency desc: "Load before authoring any plan or spec that references deck paths or task-card dispatch strings, and before dispatching on any embedded routing reference" | covered (both) |
| R21 | skill-creator desc ("creating or editing ANY file under skills/, guidelines/, floor.md, or routing.md") + floor deck-governance line; both surfaces lose their routing clause in the conformance edit, trigger survives | covered (both) |
| R22 | changelog-generator + version-manager + release-promoter descriptions (all three elements trigger); floor §52 "`create a release pr` → release pipeline" | covered (both) |
| R23 | sre-runbook desc: "Load when documenting an operational runbook, incident response procedure, or recovery playbook" | covered (both) |
| R24 | correspondence desc: "Load when drafting stakeholder emails, status updates, or any external communication" | covered (both) |
| R25 | multimodal-dispatch desc: "Load when routing work to models by content modality — vision tasks, image or screen inspection" | covered (both) |
| R26 | formal-tooling desc: "Load when workflow correctness needs machine checking — constraint solving, satisfiability checks, counterexamples, proofs… plan generation, validation, and grounding" | covered (both) |
| R27 | behavioral-testing desc: "Load for ANY opencode behavior testing — running a behavioral SC, verifying agent behavior, executing or monitoring an `opencode run`… deciding how to produce behavioral evidence at all" | covered (both) |
| Footer | **skill-creator §Vendor-card boundary (card body) carries the taxonomy verbatim** — live-verified at f5f82527: "Vendor-generated cards (e.g. `hf skills add`) are referenced and regenerated by their owning tool — never hand-edited. Card origins: deck-authored (governed) / vendor-generated / project-local." — the §2-fixed destination, needing no relocation | covered (adjudicated) |

## Adjudications (fresh-derivation vs recorded-map disagreements)

1. **FOOTER — both passes reported uncovered/partial.** Both passes scoped their inspection to
   frontmatter descriptions + floor text and excluded card bodies (pass 2 was explicitly
   instructed to weight descriptions over bodies). The §2-fixed destination is the
   `skill-creator` §Vendor-card boundary body section, which carries the taxonomy verbatim —
   verified live by the orchestrator (`sed -n '71,76p' skills/skill-creator/SKILL.md`, quoted
   above). **Adjudicated covered** on live evidence; the footer's payload is reference content
   carried by the deck, not a load-trigger intent.
2. **R14 — hf and notebooks elements.** Both passes flagged them; §2's R14 row already
   dispositioned both (hf: dead reference, nothing owed, removal remediates; notebooks:
   floor-carried by design — no connector card exists). **Adjudicated covered** per the fixed
   criteria set; no remediation owed.
3. **R15 — pass 2 said covered-as-intent.** Overruled to the stricter reading: the row's
   explicit "wiki submodule conversion" element is absent from the description, the §2
   preliminary verdict and pass 1 both call it partial, and the card standards demand
   deliberately pushy descriptions. **Remediation stands.**
4. **R19 — §2 preliminary said covered (via "reviewing code").** Both fresh passes found
   "auditing code" absent with misroute pressure from the floor's `audit` → verify token.
   Per Design Decision 4 a fresh-vs-recorded disagreement is a finding. **Remediation adopted**
   — the description gains the auditing element; verify's R7 remediation names its target as
   artifacts (spec/plan/deliverable), keeping the two audit surfaces distinct.

## Remediation decisions (executed under skill-creator governance; developer-directed carve-out, content standards bind)

| Card | Element added | Row |
|------|---------------|-----|
| `skills/verify/SKILL.md` | on-demand audit trigger — audit an existing artifact (a spec, plan, or deliverable) on demand against the criteria set its producing card owns | R7 |
| `skills/wiki-operations/SKILL.md` | wiki submodule conversion element | R15 |
| `skills/programming-principles/SKILL.md` | "auditing code" added to the design/review trigger list | R19 |

## Non-row findings (recorded, handled outside this audit)

- floor.md loading-on-demand paragraph, floor.md deck-governance line, `.opencode/AGENTS.md`,
  `opencode.jsonc`, `prompts/default.txt`, and skill-creator's frontmatter all reference
  `routing.md` and go dead at removal — conformed by plan Item 4 (the spec's enumerated
  conformance points; blast-radius grep at f5f82527 found no other live hits).
- The audit passes counted 35 then 32 card descriptions — counting variance in how
  directories were enumerated (35 skill directories exist); no coverage impact (every card's
  description was read in both passes).

## Verdict

**Zero uncovered rows.** Every row of the §2 enumeration (27 rows + footer) lands on a live
post-removal dispatch surface — card description and/or floor content (footer taxonomy via
the §2-fixed skill-creator §Vendor-card boundary section). Three under-triggering descriptions
(R7, R15, R19) are remediated before the removal lands, per the audit-first ordering. The
removal proceeds.
