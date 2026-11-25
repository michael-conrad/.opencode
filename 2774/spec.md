# .opencode#2774 — Card text: remote-first number-acquisition recipe; `.counter`/folder listing never inputs to a number; platform-agnostic pointer wording

## 1. Intent and Executive Summary

**Problem Statement** — An agent filing a new issue ticket pre-guesses the ticket number from `.issues/.counter` or by enumerating existing `{N}/` store folders — and deliberates about it — instead of acquiring the pre-allocated number by filing the remote issue first, with the remote body already carrying the spec's structured summary at the first create. The live deck prose already mandates remote-first reservation (spec card rule 5; issues card §2; the `AGENTS.md` store guide), yet three counter-pressures keep the old habit alive: the counter-advance sentence sits inside rule 5's filing procedure, coupling store maintenance to number selection; tracker existence is left as an agent judgment instead of being fact-decidable from the session-init routing table; and the filing prose names the platform-coupled `update --github` spelling where the tool already carries the platform-agnostic `update --remote-url`.

**Root Cause / Motivation** — The doctrine ("file the remote issue to reserve the number") exists in the live cards and demonstrably loses: the behavior recurs. Rule 5's own embedded counter mechanics teach the selection habit they sit beside; the tool's `create` path raises its #2723 warning on a non-remote-sourced registration only after the fact; and no sentence states that guessing from store state is itself the defect. (The counter-derivation mechanism that historically minted local numbers lives in the attic-era deck, which still teaches "reserve N from `.issues/.counter`" in its preserved task lists; the current tool mints nothing — its `create` requires `--number` — so the live cure is the card text, and the attic cleanup stays on its own plan.) The cure must make number provenance a single unambiguous reflex: remote file → returned number → local registration at that number.

**Approach Chosen** — Two-card edit set, card text only: rewrite spec rule 5's filing block into the acquisition recipe plus the selection prohibition; relocate the counter-advance obligation to issues card §2 as post-filing store maintenance; add the tracker-existence decidability sentence to both cards' tracker-conditional blocks (spec rule 5's filing block and issues card §2's creation block); replace the three platform-coupled spellings with the agnostic ones. `tools/local-issues` is untouched (developer exclusion, 2026-11-24): the tool-side repair and the diverged-store migration stay in the sibling ticket `michael-conrad/.opencode#2769`.

**Alternatives Considered & Why Discarded** —
1. *Tool-layer refusal of local-minted `create` on remote-host stores* (redeciding #2723's warn-and-proceed) — mechanically the strongest lever, but excluded by the developer's direction this cycle ("do not alter the script local-issues"); it composes with, and is deferred to, 2769's tool work.
2. *Amending spec 2769 in place instead of a new filing* — rejected: 2769's completion gate includes the tool fix and the diverged-store migration (script alterations), which would block the all-or-nothing gate under this card-only scope; the classes overlap but the deliverables differ; the two are cross-linked as siblings instead.
3. *Attic cleanup* (the preserved pre-rip task lists still teach "reserve N from `.issues/.counter`") — rejected for this change: `attic/` is pending soak and deletion under its own plan; editing attic prose adds a surface without touching the live-card behavior this regression targets.

**Key Design Decisions** —
- *Card-text-only enforcement* — tradeoff: weaker than a mechanism-level refusal, but it respects the script exclusion; the recipe plus prohibition wording removes the two ambiguities agents historically reason from (maintenance-vs-selection coupling, tracker-existence judgment).
- *The counter stays in the store* as remoteless reserve state and post-filing hygiene — tradeoff: remoteless-store numbering semantics stay intact while the counter is demoted out of the selection path for remote-host stores.
- *The number the remote create returns is declared the number* — no verification step, no second-guessing pass; the tool's stated inability to verify a reservation (#2723) reads as: agents verify by construction (they filed it), never by listing remote or local issues, and never by API number-enumeration.
- *Platform-agnostic pointer naming in card prose* — `--remote-url`/`remote_url` in all card text; the tool's legacy `--github` flag name itself stays (untouched script); the CLI mechanics reference already documents both spellings and is unchanged.

**User Intent / Original Prompt** (verbatim, dated) —
1. 2026-11-24: "regression: the agent keeps trying to pre-guess assigned issue ticket numbers based on .counter or already existing folders and debates and deliberates instead of simply doing the fast and smart thing of getting a pre-allocated number by filing a remote spec with appropriate starter exec summary text when a remote API is available."
2. 2026-11-24 (design feedback on the brainstorm): "you can't name platforms like this: `--github`" — and the demand for precise edit sites: "how in the fucking hell do I fucking know where you need this new blurb?"
3. 2026-11-24 (stage authorization + scope bound): "proceed to spec, do not alter the script local-issues."

## 2. Not Included

- `.opencode/tools/local-issues` — explicit developer direction, 2026-11-24: "do not alter the script local-issues." The tool-side repair and the diverged-store migration remain in sibling ticket `michael-conrad/.opencode#2769`.
- Tool-layer refusal of local-minted `create` on remote-host stores (#2723 warn-not-refuse redecision) — rides with 2769's tool work, out of this card-only change.
- `skills/issues/references/local-issues-cli.md` wording — CLI mechanics reference; its flag inventory is already correct and flags are unchanged.
- `attic/` cleanup — preserved unloaded, pending soak and deletion under its own plan.
- Renumbering or migrating legacy diverged store folders — 2769's migration item; this spec's recipe governs new filings only.
- Root-repo (`opencode-config`) source changes — none; the deliverable is deck card prose plus this store artifact.

## 3. Requirements

- **R-1** — Spec rule 5's filing procedure SHALL state the number-acquisition order as an imperative recipe: file the remote issue first (`gh`/`gb`) as the *first* create, carrying the remote-body-format summary body (no bare-placeholder filing); the number the remote returns **is** the number; the local record registers at that number via `local-issues create --number repo#N`; the pointer writes via `update --remote-url`.
- **R-2** — Spec rule 5 SHALL carry the normative prohibition: `.counter` and `{N}/` folder enumeration are never inputs to a new issue's number; deriving or predicting a number from local store state when a tracker exists is a defect, however the prediction is framed.
- **R-3** — The counter-advance obligation SHALL move out of spec rule 5's filing procedure into the issues card §2 as post-filing store maintenance, presented as reserve-state hygiene (the remoteless-selection semantics unchanged) — never as a selection input.
- **R-4** — Spec rule 5's filing block and the issues card §2 creation block SHALL each state that tracker existence is fact-decidable from the session-init routing table (per-repo platform + writability), never determined by listing remote or local issues — both cards carry the tracker-conditional, so both blocks carry the decidability sentence.
- **R-5** — The three live card sentences naming `update --github` / `github_url` SHALL use the platform-agnostic spelling (`update --remote-url` / `remote_url`): spec rule 5's link step, issues §2's mirror write, and the operating-contract boundary sentence.

## 4. Success criteria

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | Spec rule 5's filing block carries the acquisition recipe in R-1's order, with the remote-returned number stated as *the* number and the remote body carried at the first create | content | read/grep of `skills/spec/SKILL.md` rule 5 block for the recipe's four steps in order |
| SC-2 | The prohibition sentence — `.counter` and `{N}/` enumeration are never inputs to a new issue's number — is present in spec rule 5 | content | grep of the rule 5 block for the prohibition wording |
| SC-3 | Counter-advance prose is absent from rule 5's filing block and present in the issues card §2 as post-filing store maintenance | content | grep of both card blocks (absence + presence) |
| SC-4 | The tracker-existence decidability sentence is present in both pinned sites — spec rule 5's filing block and issues card §2's creation block — naming the session-init routing table as the fact source and excluding listing-based determination | content | grep of `skills/spec/SKILL.md` rule 5 block and `skills/issues/SKILL.md` §2 block for the decidability sentence in both |
| SC-5 | The three named card sites carry zero `--github`/`github_url` spellings and carry the agnostic `--remote-url`/`remote_url` spellings | content | grep of `skills/spec/SKILL.md` and `skills/issues/SKILL.md` at the three mapping points |
| SC-6 | In an agent session asked to file a new issue into a remote-host store, the agent files the remote issue first and acquires the number from the remote create; no `.counter` read or folder enumeration precedes number acquisition | behavioral | behavioral harness scenario (tests-v2) observing the filing sequence; heavy tier — excluded from default runs |

## 5. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `michael-conrad/.opencode#2769` (open) | sibling ticket carries the tool-side repair and the diverged-store migration reported there; this spec fixes the card-doctrine half, each deliverable tracked in its own ticket | pending |
| `skills/spec/references/remote-body-format.md` | defines the remote-body content carried at the first create | satisfied |
| `skills/spec/references/spec-structure-standards.md` | defines this artifact's layout | satisfied |
| `skills/issues/references/local-issues-cli.md` | flag-level truth for `create --number` and `update --remote-url` | satisfied |
| session-init routing table (per-repo platform + writability) | fact source for R-4's tracker-existence decidability | satisfied |
| `gh auth status` (session-init: logged in) | remote filing path availability for the recipe's first step | satisfied |

## 6. Traceability

| Requirement | Success criteria |
|-------------|------------------|
| R-1 | SC-1, SC-6 |
| R-2 | SC-2, SC-6 |
| R-3 | SC-3 |
| R-4 | SC-4 |
| R-5 | SC-5 |

## 7. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| spec card rule 5 counter + filing prose | deck card | `.opencode/skills/spec/SKILL.md` lines 57–80 | read, 2026-11-24 |
| issues card §2 + operating-contract boundary sentence | deck card | `.opencode/skills/issues/SKILL.md` lines 26–34, 190–204 | read, 2026-11-24 |
| `local-issues` flag surface | tool argparse | `--github`/`--remote-url` on `update`; field map `github`→`github_url`, `remote_url` field; `create --number` required (tool mints nothing) | grep, 2026-11-24 |
| `github_url`/`github_issue` read sites | tool code | `_legacy_item_removable` only (legacy-residue cleanup path; no live behavior reads the field) | grep, 2026-11-24 |
| stale counter-derivation mechanism | attic deck (preserved pre-rip task lists) | attic `spec-creation`/`issue-operations` task cards teach `.counter` reserve; live tool carries none — `_next_number`/counter-reading absent from `.opencode/tools/` code and every docstring (`create` mints nothing, requires `--number`) | grep (absence sweep incl. all docstrings), 2026-11-24 |
| store workspace guide remote-first mandate | store doc | `.opencode/.issues/AGENTS.md` Workflow section (precedent: issue 2450 divergence, `opencode-config#373` recurrence) | read, 2026-11-24 |
| remote issue 2769 body | tracker record | `gh issue view 2769 -R michael-conrad/.opencode` (tool-side repair + migration items) | read, 2026-11-24 |
| session-init routing table | runtime data | per-repo platform + writability fields in session-init output | read, 2026-11-24 |
| attic counter-selection task lists | preserved pre-rip deck | `.opencode/attic/skills/spec-creation/tasks/create.md`, `attic/skills/issue-operations*/tasks/creation.md` | grep, 2026-11-24 |

## 8. Cost Frame

- **SC-1 … SC-5 (content)** — acting: one grep/read pass per card site, seconds, offline; skipping: the prose regression persists silently in exactly the form the developer reported — invisible until an agent session repeats the pre-guessing behavior.
- **SC-6 (behavioral)** — acting: one behavioral harness session (container provisioning, minutes) observing the filing sequence; skipping: the deck change is verified as prose only while the behavioral regression — the change's entire target — persists unverified.

## 9. Edge Cases

| # | Condition | Expected behavior | Resolution |
|---|-----------|-------------------|------------|
| 1 | Remote create (`gh`/`gb`) fails on network or auth | Cannot-continue state: report with evidence and halt per the floor; the flow never falls back to `.counter` minting while a tracker exists | retry on transient evidence; halt otherwise |
| 2 | Store genuinely remoteless (no platform tracker) | Counter-selection path remains, per R-3's unchanged remoteless semantics | none — behavior unchanged |
| 3 | Routing table carries no platform row for the target store | Halt with an open-ended clarification request — never a number guess | developer direction |
| 4 | Mid-flow local write failure after the remote filing | Flow BLOCKs: the remote body is never left carrying an unresolvable pointer (existing rule preserved) | repair at the blocking point before proceeding |
| 5 | Legacy diverged store (counter-derived folders vs remote numbers) | Out of scope: 2769's migration governs; this spec's recipe governs new filings only, renumbering nothing | `michael-conrad/.opencode#2769` |
| 6 | A report warrants multiple specs (e.g. the work-entry conversion path) | Each part files its own remote issue — every part runs the same acquisition recipe; no number reuse or derivation from a previous return | per-issue remote-first |

## 10. Completion gate

Every success criterion (SC-1 through SC-6) passes before the deliverable is complete; partial implementation is not permitted.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
