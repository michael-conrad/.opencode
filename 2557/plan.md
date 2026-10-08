<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2557 — plan derived from .opencode/.issues/2557/spec.md -->

# PLAN — Restore build/run verification practice and the language/build-framework skill-card family

Source spec: `.issues/2557/spec.md` (validated — clean-pass revision; each SC judged
against `skills/spec/references/validation-standards.md` defect classes at planning
time: all 16 trace to the three reported facets or the #2249/#2439 provenance, carry
matching instruments, and exhibit no invented/untestable/either/or/ambiguous/
misclassified/self-impure/trivial classes).

## Surface conventions (apply to every item)

- Top-level cards: frontmatter `name` (quoted description), `license: MIT`,
  `provenance` line; SPDX comment block after the closing `---`; lean body.
- Detail cards (`references/*.md`): SPDX comment header, no frontmatter — matches
  every live detail card (`spec/references/validation-standards.md` et al.).
- SC-8's frontmatter parenthetical is read as binding the four new top-level
  SKILL.md cards; the seven detail cards follow the live references convention
  (SPDX header, no frontmatter) — the deck-wide format all eleven paths share.
- Descriptions for the four new cards + widened `programming-principles` are
  verbatim from spec R-14 — quoted, single string, no lexical triggers.
- Root-agnostic everywhere: no repo names, no absolute paths; build/test commands
  always sourced from the repo's declared build manifest.
- Every new/updated card passes the skill-creator admission gate (R-11): observed
  failure = this regression's three facets + session telemetry; consumers and
  triggers as designed; predicate classification (DI mandate intent-decidable;
  build-verification boundary checks fact-decidable); domain match; net-zero
  dispositions as specified.

## Items (dependency-ordered)

### Item 1 — Prerequisite: `formal-tooling` frontmatter defect (SC-9, SC-14)

- **Deliverable:** `skills/formal-tooling/SKILL.md` — move the three SPDX comment
  lines out of the frontmatter block (after the closing `---`), matching every
  other card; description stays as-is.
- **RED:** `skildeck lint` reports 4 pre-existing ERROR findings against
  `skills/formal-tooling/SKILL.md` (description-unquoted is a block-relative
  parse artifact of the misplaced comments; 3× unknown-field for the HTML
  comments inside frontmatter). The SC-9/SC-14 instrument requires 0 findings —
  this pre-existing defect blocks it and is remediated, not passed through
  (#2553 suite-green rule).
- **GREEN:** `skildeck lint` → 0 findings.
- **Instrument:** `./.opencode/tools/skildeck lint` (baseline captured: 4 ERROR).

### Item 2 — Behavioral scenario scripts + fixtures authored (SC-1..SC-7, SC-16)

- **Deliverable:** eight artifact-only generator scripts in
  `tests-v2/behaviors/` named `2557-sc{N}-<slug>.sh`, plus fixtures:
  - `2557-sc1-build-verification` — repo with a build manifest declaring canonical
    build/test commands; prompt applies a build-affecting change (packaging config).
  - `2557-sc2-shadowjar-spi` — Gradle project with `META-INF/services` providers;
    prompt requires fat-jar (shadowJar) configuration.
  - `2557-sc3-di-approach` — language project with an idiomatic DI option; prompt
    requests a service + unit tests.
  - `2557-sc4-di-tier-selection` — single real-domain prompt naming one language
    with a contested/guidance-only tier; the clean-room evaluation confirms the
    selection is tier-guided against the shared table the deck now carries.
  - `2557-sc5-di-markup-exclusion` — HTML/CSS styling task prompt.
  - `2557-sc6-release-gate` — `BEHAVIOR_NEEDS_MULTI_SUBMODULES=1`; fixture seeds a
    release state where the canonical build fails in the temp checkout (and a
    second fixture variant where a submodule gitlink names a SHA absent from the
    submodule remote); prompt: promote the release (tag it).
  - `2557-sc7-ask-record-commands` — repo whose build manifest declares no build/test
    commands; two-turn flow: initial run (agent asks rather than guesses), then
    resume via `--resume-home` + `--continue` with the developer's confirmation;
    agent records the confirmed command in the build manifest.
  - `2557-sc16-callout-loads` — real-domain task in a carded language; evaluation
    confirms language/tool cards + `programming-principles` loaded before the first
    code modification.
  All scripts: cross-reference header, `behavior_run`, exit 0, no assertions; all
  fixture state in `fixtures/setup/<scenario>.sh` or `fixtures/issues/{N}/`; §14
  monitoring applies at run time.
- **RED:** none at this item (structural authoring) — the scripts' RED/GREEN
  evidence is produced at Items 4 and 13.
- **GREEN:** each script runs artifact-only and exits 0; `bash -n` passes on all
  eight; scripts carry the mandatory cross-reference header.
- **Instrument:** `bash -n` over the eight scripts; header grep; template-shape
  comparison against `2550-sc5-validate-clean-spec.sh`.

### Item 3 — Currency pass over the restored recommended-packages table (SC-15)

- **Deliverable:** record file `.issues/2557/artifacts/currency-pass-2026-10.md`
  (in this issue store): per-row live-source verification of the `#2249` table's
  fourteen ecosystems (Python, C#/.NET, Java, Angular/Vue/Svelte, Kotlin, Scala,
  Dart/Flutter, TypeScript, Go, Rust, C++, Swift, Ruby, React/Web Components) +
  the `dependency-injector` maintenance-status check. Each row: verification date,
  source URL(s), verdict, and correction where the live landscape differs (the
  Java row's known drift — "Dagger for GWT-style" → verified Spring / Guice /
  Dagger 2 practice — must be documented). Research dispatches carry source URLs
  and gap reporting.
- **RED:** no record file exists at `.issues/2557/artifacts/`.
- **GREEN:** record exists with per-row citations and dated verdicts; drift
  corrections named (Java row at minimum).
- **Instrument:** file-existence + per-row source-URL read.
- **Sequencing:** precedes Item 5 (the tier table lands only after verification),
  per the spec's sequencing note.

### Item 4 — RED behavioral evidence for SC-1..SC-7, SC-16 (eight runs + clean-room evals)

- **Deliverable:** one artifact-generation run per scenario script (Item 2) against
  the pre-change deck (the commit that carries the scripts but none of Items 5–12's
  content), each followed by a clean-room evaluation dispatch reading session.yaml.
  Ordered precondition cycle per run: commit → push → fetch/verify → run; §14
  semantic monitoring; bash tool timeout ≥ 600s; default model, no substitution.
- **RED:** for each SC, the clean-room evaluation confirms the behavior is absent —
  no shallow-checkout build verification (SC-1), no INCLUDE/SPI handling (SC-2),
  no DI approach (SC-3, SC-4), no exclusion in force (SC-5), no promotion gate
  (SC-6), guessing instead of asking (SC-7), no card loads before code edits
  (SC-16). This re-demonstrates the live regression the spec documents.
- **GREEN:** RED evidence recorded per SC (artifact dirs + evaluation verdicts).
- **Instrument:** `tests-v2` harness runs + clean-room evals (two-SC pattern §6a).
- **Commit discipline:** the script-only commit is pushed and remote-verified
  before the first RED run (harness gate enforces).

### Item 5 — `programming-principles` extension + shared DI + practices detail cards (SC-3, SC-4, SC-5, SC-8, SC-9, SC-10, SC-14, SC-15)

- **Deliverable:**
  - `skills/programming-principles/SKILL.md` — description replaced with the R-14
    widened text; body re-anchored to decision moments: the six working design
    principles unchanged; one-line summaries of industry expectations (versioning
    discipline, compatibility) with a load directive to `references/practices.md`;
    the mandatory-read directive to `references/dependency-injection.md`.
  - `skills/programming-principles/references/dependency-injection.md` — generic
    mandate ("use a DI approach," not "use framework X"; approach problem solving
    and unit tests from the standpoint of an available DI approach); the full
    three-tier table from the Item 3 currency-passed record (Clear standard /
    Contested / Guidance-only); selection guidance (code analysis + spec
    requirements, never a fixed pin; combinations where the table documents
    multiple idiomatic options); HTML/CSS exclusion; infra-tooling carveout
    phrased root-agnostically ("agent-deck infrastructure tooling is exempt").
  - `skills/programming-principles/references/practices.md` — semver discipline as
    expectation-not-operation (version-manager owns bump operations,
    changelog-generator owns release-notes artifacts) + the backward-compat/
    deprecation expectations restored from defunct `087-no-backward-compat`
    (clean breaks on internal refactors; deprecation cycles only for public APIs
    with external consumers); evidence-gated growth note.
- **RED:** file reads — the widened description, the mandatory-read directive, the
  currency-passed table, and the practices content do not exist; SC-10's
  mandated strings absent.
- **GREEN:** all reads pass; the tier table matches the Item 3 record.
- **Instrument:** file reads against R-1/R-5 text; skildeck lint; reference-integrity.

### Item 6 — `python` card family (SC-8, SC-9, SC-12, SC-14)

- **Deliverable:** `skills/python/SKILL.md` (R-14 description verbatim; body claims
  the Python-project intent space, routes to detail cards) + detail cards:
  - `references/uv.md` — runner discipline (run/test through the project
    environment, never bare interpreters); dependency-set resolution and lockfile
    handling; canonical-command sourcing from the build manifest; the Python
    specialization of build verification (environment setup in the shallow
    checkout → build → assert `dist/` outputs).
  - `references/pyproject.md` — project-definition authoring: metadata, dependency
    declaration, build-backend selection, tool sections, entry points.
  - `references/conventions.md` — typing (Pydantic/Dataclasses, modern built-in
    generics `list[str]`/`dict[str, Any]`, `Any` only when third-party-imposed);
    pathlib exclusivity; f-strings; print discipline (data output and
    user-facing information only — no narration/signal prints); the
    `dependency-injector` pin (container-first pattern, no hand-rolled containers
    or module-level singletons) deferring the mandate to the shared card.
    Project-local defunct rules (pipeline-rerun constraint, DB enum-mapping)
    excluded — they stay in project AGENTS.md files.
- **RED:** none of the four paths exists; SC-12's presence/absence reads fail.
- **GREEN:** all four paths exist; content matches R-2; SC-12 reads pass.
- **Instrument:** file reads (SC-12); skildeck lint; reference-integrity;
  repo-name/absolute-path grep.

### Item 7 — `java` card family (SC-8, SC-9, SC-10, SC-14)

- **Deliverable:** `skills/java/SKILL.md` (R-14 description verbatim; pairs with
  `gradle`) + `references/dependency-injection.md` — Java DI practice: Spring as
  clear standard, Dagger and Guice idioms, constructor-injection patterns;
  defers mandate + tier classification to the shared card (no table restatement).
- **RED:** paths absent; full-table restatement cannot be asserted absent.
- **GREEN:** paths exist; deferral reads pass.
- **Instrument:** file reads (SC-10 second clause); lint; integrity; grep.

### Item 8 — `gradle` card family (SC-2, SC-8, SC-9, SC-14)

- **Deliverable:** `skills/gradle/SKILL.md` (R-14 description verbatim; top-level
  per the containment rule) — body carries wrapper discipline and
  canonical-command sourcing from the repo's build manifest +
  `references/packaging-spi.md` — shadowJar INCLUDE semantics, SPI preservation
  (`mergeServiceFiles()` / `META-INF/services`), fat-jar outputs verification
  (service-registration assertions as the outputs check).
- **RED:** paths absent; no shadowJar/SPI content anywhere in the live deck
  (spec-verified zero hits).
- **GREEN:** paths exist; content matches R-4.
- **Instrument:** file reads; lint; integrity; grep.

### Item 9 — `godot` card (SC-8, SC-9, SC-14)

- **Deliverable:** `skills/godot/SKILL.md` (R-14 description verbatim; running and
  exporting the game as dominant claimed intents) — body carries project
  structure, headless run/import, export presets, canonical-command sourcing;
  GDScript conventions only where build/run-relevant. Content verified against
  live Godot 4.x CLI documentation during authoring (training-data staleness
  guard).
- **RED:** path absent.
- **GREEN:** path exists; content matches R-6.
- **Instrument:** file reads; lint; integrity; grep.

### Item 10 — Pipeline call outs in `spec`, `plan`, `implement` (SC-13, SC-14)

- **Deliverable:** each main body gains the call-out directive (R-7 wording):
  identify the languages and build tools in scope and load their cards (where
  cards exist), and load `programming-principles` for the engineering-principles
  layer — `spec`: language standards and tool expectations shape what the
  requirements can demand; `plan`: conventions and packaging expectations shape
  item decomposition and per-item verification; `implement`: the load happens
  before any code is written.
- **RED:** file reads — no call-out directive exists in any of the three bodies.
- **GREEN:** all three bodies carry the directive with per-card wording.
- **Instrument:** file reads (SC-13); lint; integrity.

### Item 11 — Build-verification row, verify evidence bar, release-promoter gate (SC-1, SC-6, SC-7, SC-11, SC-14)

- **Deliverable:**
  - `skills/implement/references/implementation-workflow.md` — pre-implementation
    table gains the row identifying the language/toolchain of the files about to
    be modified and loading their cards; post-implementation table gains the
    build-verification row (shallow temp-copy checkout `git clone --depth 1`;
    canonical build sourced from the repo's declared build manifest; final-outputs
    assertion) triggered on build-affecting changes — the conflated structural
    row's build mention is retired into it (net-zero disposition, R-8).
  - `skills/verify/SKILL.md` — evidence demands for build-affecting changes
    include the build run output and the outputs assertion, consumed as executed
    evidence (R-9).
  - `skills/release-promoter/SKILL.md` — description regains the verification-gate
    mention; new `references/operating-protocol.md` restored from
    `attic/skills/release-promoter/tasks/operating-protocol.md` under current card
    standards: SPDX header, root-agnostic genericization (build-manifest
    discovery phrased per the spec's definition, attic's hardcoded submodule-path
    examples generalized), SC-6 mechanism preserved exactly (shallow clone,
    `--init --depth 1`, never `--remote`/`--recursive`, resolved==pinned drift
    assertion hard-fail, manifest discovery with MANIFEST_FAIL, build+test
    zero-failure with BUILD_FAIL, once-per-release, no retries). Main body gains
    the gate as step 0 with the load directive to the detail card.
- **RED:** file reads — no build-verification row; no build evidence demands in
  verify; no gate in release-promoter.
- **GREEN:** all reads pass (SC-11).
- **Instrument:** file reads (SC-11); lint; integrity; grep.

### Item 12 — Structural gate closeout (SC-8, SC-9, SC-14)

- **Deliverable:** none (verification item) — the full structural battery over the
  changed set: file-existence + frontmatter parse across the eleven paths (SC-8);
  `skildeck lint` → 0 findings (SC-9, SC-14); description-contract reads against
  R-14 texts (SC-9); `reference-integrity` scan PASS; repository-name/
  absolute-path grep over the changed set returns nothing (SC-14).
- **RED/GREEN:** the battery fails before Items 5–11, passes after.
- **Instrument:** the four checks named above, output captured.

### Item 13 — GREEN behavioral evidence for SC-1..SC-7, SC-16 (eight runs + clean-room evals)

- **Deliverable:** one artifact-generation run per scenario script against the
  completed deck (all structural items committed + pushed), each followed by a
  clean-room evaluation dispatch reading session.yaml. Same precondition cycle,
  monitoring, and timeout mandates as Item 4.
- **RED:** n/a (GREEN phase) — the Item 4 RED evidence is the contrast baseline.
- **GREEN:** for each SC, the clean-room evaluation confirms the behavior is
  present — shallow checkout + manifest-sourced build + outputs assertion (SC-1);
  INCLUDE + SPI preservation + jar outputs check (SC-2); DI approach applied
  where idiomatic (SC-3); tier-guided selection consistent with the shared table
  (SC-4); no DI on markup (SC-5); gate sequence blocks on the seeded failure
  (SC-6); ask + record, no guessing (SC-7); card loads precede first code
  modification (SC-16).
- **Instrument:** `tests-v2` harness runs + clean-room evals.

## Traceability

| Plan item | Spec SCs |
|---|---|
| 1 | SC-9, SC-14 (instrument precondition) |
| 2 | SC-1..SC-7, SC-16 (scenario authoring) |
| 3 | SC-15 |
| 4 | SC-1..SC-7, SC-16 (RED evidence) |
| 5 | SC-3, SC-4, SC-5, SC-8, SC-9, SC-10, SC-14, SC-15 |
| 6 | SC-8, SC-9, SC-12, SC-14 |
| 7 | SC-8, SC-9, SC-10, SC-14 |
| 8 | SC-2, SC-8, SC-9, SC-14 |
| 9 | SC-8, SC-9, SC-14 |
| 10 | SC-13, SC-14 |
| 11 | SC-1, SC-6, SC-7, SC-11, SC-14 |
| 12 | SC-8, SC-9, SC-14 |
| 13 | SC-1..SC-7, SC-16 (GREEN evidence) |

SC-16's second instrument (session-store dispatch query re-run after landing,
compared to the Problem Statement baseline) is temporally bound to post-merge —
it is recorded as a post-landing observation for the deck-debt ledger; the
PR-time instrument is the Item 2/4/13 scenario.

## Verification-coverage note

Behavioral evidence cost is the spec's declared bar: eight scenarios × (RED run
+ clean-room eval) + (GREEN run + clean-room eval) = 16 model runs + 16 clean-room
dispatches. Each is individually mandated by the targeted-execution rule (one run
per SC need; no combining, no whole-suite sweeps). Ceremony-retirement check: each
scenario catches a defect that escapes without it (the regression's facets are the
survival condition) — none greps prose for phrasing.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
