<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2554; consumer-side use of the Ainglish register (ainglish.org, CC0) -->

# Writing discipline — normative prose

This is the deck's writing discipline, triggered from `floor.md`. It is a
discipline, not a dialect: the agent applies judgment wherever it authors
normative prose. Ainglish constructs (the register at
[ainglish.org/register](https://ainglish.org/register)) are optional
instrumentation — plain English that achieves the same disambiguation
satisfies the discipline equally.

## Scope

Everything the agent writes or acts on: deck cards, specs, plans, chat,
commits, PR bodies, issues, code comments. Intensity follows normativity —
rules, authorizations, and scope statements get the full discipline;
descriptive prose gets none.

## The four ambiguity-rule families

Ambiguity is a property of English itself, so incident-by-incident fixes do
not converge. These families cover the deck's recorded misbinding classes.
Write so the reader cannot misbind.

### 1. Actor binding — who does this bind?

Bare "we", "you", and passive voice leave the bound actor to inference, and
an agent reads words, not intent. Recorded failures: a prohibition written
"in ANY context" was read to govern repos it did not name (`.opencode#2293`);
a referenced cleanup task was executed in full, deleting unrequested branches
(`.opencode#1011`); a complaint was mapped to a proceed signal
(`.opencode#1031`).

- Name the actor and the scope in the sentence that grants, withholds, or
  prohibits: not "we will review the draft" but "the implementer reviews;
  the developer approves."
- State what an utterance does NOT cover when a reader could plausibly
  extend it there.
- Where the including-vs-excluding reader is load-bearing, plain English
  parentheticals suffice ("we — including you, the agent — will…");
  the register's `we-including-you` / `we-excluding-you` forms are the
  optional instrumentation for the same job.

### 2. Distributive vs collective plurals

A plural predicate can mean each member separately or the group as one
unit, and obligations, payouts, and verifications differ. "The agents
verified the checkpoint" — three verifications or one joint one? Plain
English fixes it in place: "each agent verified…" vs "the agents verified…
as one group." The register's `each-alone` / `as-one` tags are optional.
This family is general grammar; no deck incident is recorded against it.

### 3. Missing evidence vs unmade decision

"It is undecided" can mean nobody looked or nobody chose, and the next
action differs: retrieve the answer, or route an authorized decision.
Recorded failure: a plan writer treated a spec omission as an invitation to
elaborate (`.opencode#1650`). Write which one it is: "no search has been
run" is a fact about evidence; "this has not been decided" names an open
decision owned by someone. The register's `fact-not-known` /
`choice-not-made` forms are optional.

### 4. Claim confidence + falsifier anchoring

An unhedged claim invites reliance it has not earned. Recorded pattern:
unhedged-claim corrections in the lessons-learned record. Anchor the
falsifier in the claim: "the suite is green — unless the integration tests
fail on a fresh checkout." Date evergreen claims: state what the claim was
current as of. The register's `unless(<F>)` wording and `as_of(<t>)` pin are
optional; plain "unless…" and "as of <date>" carry the same meaning.

## Losslessness boundary

Deck prose stays plain English that happens to be precise. A disambiguation
unreadable to a reader without the register loaded has failed the register's
own anti-cipher charter and does not belong in deck prose. Every construct
maps losslessly back to ordinary English; if the plain-English rendering is
clearer, write that instead.

## Anti-pedantry boundary

Constructs are optional. No construct-counting, no mechanical enforcement,
no scripted ambiguity detection anywhere in the deck — the discipline is
intent-decidable and judgment decides. A sentence that is precise without
any construct is fully conformant.

## Adoption rules

- **Forwards-only.** Existing content is grandfathered; nothing is
  retroactively converted.
- **Whole-card-on-touch.** A substantive write to a card obligates the
  editor to return the entire card's normative prose under this
  discipline — not just the edited passage. The touch is the conversion
  trigger: sections the request did not name are still in scope, and
  "not asked to touch it" does not exempt them.
- **Touch = substantive write.** An edit that carries or alters normative
  content. Purely mechanical fixes (typos, link rot, formatting) do not
  convert.

## Consumer posture — cite, never mirror, evergreen

The deck declares the trigger and these boundary conditions; the register
carries its own rules, and self-apparent register rules (losslessness,
"passed ≠ applied", rejection-as-evidence) bind without re-declaration in
deck law. No register content is copied into the deck.

Consult the live register at use-time — latest available data governs:

- Register (ratified forms): <https://ainglish.org/register>
- Flagship catalogue (worked examples): <https://ainglish.org/flagships>

Amendment in the register is declared supersession and deprecation is
visible, so live consultation cannot silently change meaning.

---
*Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)*
