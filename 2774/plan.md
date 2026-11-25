# .opencode#2774 — Plan: remote-first number-acquisition recipe (card text)

## Goal

Implement `.opencode#2774`'s spec: rewrite spec card rule 5's filing block
into the remote-first acquisition recipe with the selection prohibition,
relocate the counter-advance obligation to the issues card §2 as post-filing
store maintenance, add the tracker-existence decidability sentence at both
pinned sites, and replace the three platform-coupled `--github`/`github_url`
spellings with `--remote-url`/`remote_url`. Card text only;
`tools/local-issues` is untouched (spec §2, developer exclusion 2026-11-24).

## Execution surface

- `.opencode/skills/spec/SKILL.md` — rule 5 filing block (lines ≈57–80)
- `.opencode/skills/issues/SKILL.md` — §2 creation block (lines ≈26–29) and
  operating-contract boundary sentence (lines ≈196–197)
- Both files live in the `.opencode` submodule; work runs on a feature
  branch of that submodule, PR against `michael-conrad/.opencode`.

## Dependency order

Items 1 → 2 → 3 → 4 → 5 → 6, each building on verified prior state:

1. **Item 1 first** — it rewrites rule 5's filing block wholesale; every
   later rule-5 edit happens on the post-rewrite text, so no item touches
   pre-rewrite sentences.
2. **Item 2 second** — adds the number-derivation prohibition to the
   post-Item-1 rule 5 block; same block as Item 1, so it must land on the
   rewritten text once, never on pre-rewrite sentences.
3. **Item 3 third** — removes the counter-advance paragraph from the
   post-Item-2 rule 5 block (Item 1's rewrite already absorbed the
   remoteless reserve-state sentence) and inserts the counter prose into
   issues §2; the SC-3 absence check then evaluable exactly once.
4. **Item 4 fourth** — adds the decidability sentence to the stabilized
   blocks of both cards (Item 3's insertion on the issues side is final
   before this edit).
5. **Item 5 fifth** — the issues-card spelling replacements depend on Items
   2–4 having settled the surrounding text (the §2 mirror-write sentence and
   boundary sentence are edited once, after their content is final);
   spec-side spelling is already final inside Item 1's rewrite and is
   verified here together with the issues sites.
6. **Item 6 last** — the behavioral scenario observes the deck's filing
   behavior only after every card-text edit (Items 1–5) is on the branch.

## Items (one per SC)

### Item 1 — SC-1: rule 5 acquisition recipe (R-1)

- **Deliverable:** spec rule 5's filing block, rewritten to state the
  acquisition recipe in R-1's order, with the remote-returned number stated
  as *the* number and the remote body carried at the first create.
- **GREEN:** Rewrite spec rule 5's opening filing block to state the
  acquisition recipe as an imperative: (1) when a tracker exists, file the
  remote issue first via `gh`/`gb` as the *first* create, carrying the
  remote-body-format summary body at that first create (no bare-placeholder
  filing); (2) the number the remote create returns **is** the number — no
  verification pass, no second-guessing; (3) register the local record at
  that number via `local-issues create --number repo#N`; (4) write the
  pointer via `update --remote-url`. The rewritten block carries the
  remoteless reserve-state sentence (counter reserves numbers only in
  remoteless stores) so Item 3 deletes the counter-advance paragraph
  completely, without a carve-out.
- **RED (written first):** `grep -c 'the number the remote create returns'`
  in `skills/spec/SKILL.md` returns 0 against current trunk (verified:
  recipe absent today).
- **Instrument:** read/`grep` of rule 5's block for the recipe's four steps
  in order, the remote-body-at-first-create statement, and the remote
  number stated as *the* number.

### Item 2 — SC-2: rule 5 number-derivation prohibition (R-2)

- **Deliverable:** normative prohibition sentence inside spec rule 5's
  filing block.
- **GREEN:** Add to rule 5's filing block (post-Item-1 text) the normative
  prohibition: `.issues/.counter` and `{N}/` folder enumeration are never
  inputs to a new issue's number; deriving or predicting a number from
  local store state when a tracker exists is a defect, however the
  prediction is framed.
- **RED:** `grep -c 'never inputs to a new issue' skills/spec/SKILL.md`
  returns 0 against current trunk.
- **Ordering:** after Item 1 — same block, no double edit.
- **Instrument:** grep of the rule 5 block for the prohibition wording.

### Item 3 — SC-3: counter-advance obligation relocation (R-3)

- **Deliverable:** counter-advance prose absent from spec rule 5 and present
  in the issues card §2 as post-filing store maintenance.
- **GREEN:** Delete the counter-advance paragraph (current lines 76–80, "The
  local counter reserves numbers only in remoteless stores. On every remote
  filing…") from spec rule 5 except the remoteless reserve-state sentence
  Item 1 already carried into the rewrite. Insert the counter-advance
  prose into the issues card §2 creation block as post-filing store
  maintenance — advance `.counter` to max(counter, filed number) after
  every remote filing into a synced store; advance to the store's highest
  `{N}/` if drifted behind; the counter is reserve-state hygiene
  (remoteless-selection semantics unchanged) and never a number-selection
  input.
- **RED:** `grep -n '.counter' skills/issues/SKILL.md` §2 block — no
  counter sentence currently exists there (verified absent).
- **Ordering:** after Items 1–2, to avoid double-editing the same sentences.
- **Instrument:** grep of both blocks — absence (counter-advance) in rule
  5's filing block, presence in issues §2.

### Item 4 — SC-4: tracker-existence decidability sentence at both sites (R-4)

- **Deliverable:** one decidability sentence in spec rule 5's filing block
  and one in issues §2's creation block.
- **GREEN:** Add one sentence to spec rule 5's filing block and one to
  issues §2's creation block: tracker existence is fact-decidable from the
  session-init routing table (per-repo platform + writability), never
  determined by listing remote or local issues.
- **RED:** grep both blocks for "session-init routing table" — absent
  before.
- **Ordering:** after Item 3 — the issues §2 block is final before this
  addition.
- **Instrument:** grep of `skills/spec/SKILL.md` rule 5 block and
  `skills/issues/SKILL.md` §2 block for the decidability sentence naming
  the session-init routing table and excluding listing-based determination.

### Item 5 — SC-5: platform-agnostic pointer spellings at three sites (R-5)

- **Deliverable:** the three pinned card sites carrying zero
  `--github`/`github_url` spellings and the agnostic
  `--remote-url`/`remote_url` spellings.
- **GREEN:** Replace, in the three pinned sites: spec rule 5's link step
  (line 60 `update --github` → `update --remote-url` — already composed
  into Item 1's rewrite); issues §2's mirror write (lines 28–29, `github_url`
  field → `remote_url` field, `update --github` → `update --remote-url`);
  the issues card operating-contract boundary sentence (lines 196–197, same
  substitution). The tool's legacy `--github` flag name itself and
  `local-issues-cli.md` are untouched.
- **RED:** the three sites currently carry `--github`/`github_url`
  (verified by grep, 2026-11-24, spec Documentation Sources).
- **Ordering:** after Items 1–4 (Item 1's rewrite absorbs the rule-5 site;
  Issues edits land on the post-Item-2/3/4 §2 text).
- **Instrument:** grep of both cards at the three mapping points — zero
  `--github`/`github_url` in card prose, `--remote-url`/`remote_url`
  present.

### Item 6 — SC-6: behavioral verification (R-1, R-2)

- **Deliverable:** executed behavioral evidence that an agent filing a new
  issue into a remote-host store files the remote issue first and acquires
  the number from the remote create, with no `.counter` read or folder
  enumeration preceding number acquisition.
- **RED (authored test first):** the tests-v2 scenario asserting the
  filing sequence fails against a checkout carrying the pre-change card
  text (the acquisition recipe is absent from rule 5 today — no agent
  session can exhibit the sequence).
- **GREEN:** with Items 1–5 on the branch, the scenario's agent session
  exhibits the remote-first sequence.
- **Instrument:** behavioral harness scenario (tests-v2) observing the
  filing sequence. **Heavy tier — excluded from default runs**; routes on
  demand per the test-discipline card. Load the `behavioral-testing` skill
  at execution time.
- **Ordering:** after Items 1–5 — observes behavior only post-edit.

## Traceability

| Item | SC | R |
|------|----|---|
| 1 | SC-1 | R-1 |
| 2 | SC-2 | R-2 |
| 3 | SC-3 | R-3 |
| 4 | SC-4 | R-4 |
| 5 | SC-5 | R-5 |
| 6 | SC-6 | R-1, R-2 |

## Verification summary

Items 1–5: greps after each GREEN, all five content SCs re-checked on the
feature branch before PR. Item 6: heavy-tier behavioral scenario, on-demand.
PR body carries the executed grep outputs as evidence; SC-6 is heavy-tier
and its disposition is recorded per the test-discipline card.
