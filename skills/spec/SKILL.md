---
name: spec
description: "Load when creating or revising a specification document — success criteria, evidence types, traceability. Also load when a spec needs revision from review findings. Success criteria come from the developer's stated requirements and observed failures only — inventing extra criteria is scope creep. Every criterion is classified behavioral (runtime effect) or structural by its nature, and carries a verification instrument."
license: MIT
provenance: AI-authored, .opencode#2490; single-sourcing discipline, .opencode#2660; triage-conversion spec-stage entry, .opencode#2707; SC subject-matter discipline, .opencode#2713; single-repo scope rule, .opencode#2712; search-before-filing mandate, .opencode#2756
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490; #2550 validate step, validation-standards reference; #2557 language/tool call out; pointer-resolution guarantee, .opencode#2597; producer-side self-check, .opencode#2601; single-sourcing discipline in self-containment, .opencode#2660; SC subject-matter discipline in rule 4, .opencode#2713; single-repo scope rule, .opencode#2712; search-before-filing mandate in rule 5, .opencode#2756 -->

# spec — specification creation and revision

1. **Extract, don't invent.** Requirements come from the developer's statements
   and the exploration record. If a criterion cannot be traced to a developer
   statement or an observed failure, delete it — that is the scope-creep guard.
   **Entry from triage conversion (.opencode#2707).** A triaged bug report
   converted in place (the `issues` card's work-entry conversion) enters the
   spec stage as the spec artifact: the converted record is the spec-stage
   input, and this card's discipline — extraction, SC classification,
   validation — applies to it from there.
2. **Single-repo scope (.opencode#2712).** A spec's scope covers exactly one
   repository — the repository owning the files the requirements touch,
   resolved via the session-init `path`-prefix routing — and the spec is
   filed in that repository's issue store (the home-store rule: scope repo
   and filing home coincide). **Split discipline for spanning
   requirements:** when a spec's requirements touch files under more than
   one repo's session-init `path` prefix — a fact-decidable determination
   from the paths, never a judgment call — the spec stage produces one spec
   per repository, each filed in its own repo's issue store per the `issues`
   card's creation flow, each naming its siblings by qualified
   `owner/repo#N` reference, rather than one bundled spec. Spanning work
   that is legitimately one job is split, not forbidden — the rule
   decomposes it; prohibition is not the design.
3. **Load the cards in scope.** Identify the languages and build tools the
   change touches and load their cards (where cards exist), and load
   `programming-principles` for the engineering-principles layer — language
   standards and tool expectations shape what the requirements can demand.
4. **Every SC is testable.** State what to check and how: behavioral SCs get a
   runtime verification instrument; structural SCs get a fact-decidable check.
   Evidence types are classified by the change's nature, not by intent.
   **Subject matter (.opencode#2713).** Every SC asserts the deliverable's
   behavior — a runtime effect the deliverable owns — or its content — what
   the deliverable states or contains — and nothing else. What the build
   system or toolchain already guarantees is never an SC subject: compilation,
   packaging, and a tool succeeding at its own job are the toolchain's
   obligations, and an instrument that observes the toolchain observes
   nothing the deliverable owns. A byte-exact instrument is reserved for a
   criterion whose stated requirement is itself identity or preservation —
   guarding sections of a file the same change edits, point-in-time records,
   content-preservation moves; a byte-exact check never substitutes for a
   behavioral or content criterion, never serves as a reduction target, and
   never restates the change's declared scope. An artifact-content claim (the
   fat jar contains the service registration) stays a content criterion — the
   toolchain prohibition targets what the toolchain guarantees by
   construction, never what an artifact contains.
 5. **Write and persist.** Acquire the number from the store's remote
   tracker first — tracker existence is fact-decidable from the
   session-init routing table (per-repo platform + writability), never
   determined by listing remote or local issues. When a tracker exists,
   the acquisition recipe is imperative, in this order: (1) file the
   remote issue (`gh`/`gb`) as the *first* create, carrying the remote
   body at that first create (never a bare-placeholder filing); (2) the
   number the remote create returns **is** the number — no verification
   pass, no second-guessing; (3) register the local record at that number
   via `create --number repo#N`; (4) write the pointer via
   `update --remote-url`. `.issues/.counter` and `{N}/` folder enumeration
   are **never inputs to a new issue's number**; deriving or predicting a
   number from local store state when a tracker exists is a defect,
   however the prediction is framed. The counter reserves numbers only in
   remoteless stores.
   The local-artifacts pointer written into the remote
   body must resolve to the actual local folder at write time; a mid-flow
   local write failure BLOCKs the flow — the remote body is never left
   carrying an unresolvable pointer. The remote body follows
   [the remote-body-format reference](references/remote-body-format.md)
   — sizing doctrine (fuller-but-still-exec-summary, self-sufficient for
   developer judgment), required sections, and the closing blockquoted
   artifacts link; the full spec and all artifacts live in
   `.issues/{N}/` and stay local-authoritative. The local `spec.md` itself
   follows
   [the spec structure standards](references/spec-structure-standards.md) —
   the mandatory section inventory (intent preamble, requirements, classified
   success criteria with instruments, traceability, documentation sources) —
   and the layout rule is anti-imitation: store artifacts are data, not
   templates; the layout comes from that standard, never from a prior store
   artifact, however similar the change.
   **Search before filing .opencode#2756.** Before filing any new spec —
   this flow, a triage conversion, or any other filing path — the agent
   searches the repository's issue store specs (the `.issues/{N}/` folders'
   spec artifacts) and the repository's linked remote tracker for a spec
   already covering the same requirement or behavior class, matching on the
   requirement or behavior class rather than the filing's wording. When a
   match exists, the requirement routes into that existing spec — amended
   or extended in place under rule 6's revision discipline, or under the
   `issues` card's conversion mechanics when the situation is a conversion
   — and no new spec number is filed.
6. **Revision discipline.** Findings from review produce targeted revisions;
   superseded criteria are removed, never accumulated. **Self-containment
   (normative):** the artifact is the single source of truth and must read
   standalone — revisions edit the artifact in place, superseded text is
   deleted in the same action, and spec content never lives in comments.
   Self-containment carries the single-sourcing discipline: the artifact
   states each operative fact once, in the section that owns it — surfaces in
   the scope table, rules in the requirements, checks as mappings whose
   element lists the mapped requirement owns, measured history in the
   evidence, the artifact's own loop history in the issue's validation record
   where the record rule applies — and every other mention points at its
   owner. The
   body footer allowlist is normative: only spec content (behavior, analysis,
   SCs, fixes, evidence) plus the byline footer — no process or tracking
   indicators of any kind (no revision-history blocks, approval-state
   markers, comment-policy statements, or superseded-content pointers). No
   STATUS fields — the spec defines what is required, implemented or not.
7. **Validate before approval.** A completed spec includes one fresh-context
   validation dispatch executed before the developer approval gate. Before
   dispatching, the writer applies
   [the validation standards](references/validation-standards.md) to the
   completed draft in their own context and remediates what they find — a
   duty-of-care pass whose purpose is to spend the fresh-context dispatch on
   judgment-level defects rather than mechanical-consistency ones. It is
   hygiene, not a gate: it never replaces the dispatch, and a self-passed
   verdict is no verdict. The dispatch itself is unchanged: a reviewer
   with no prior context on the spec reads it against the same standards
   and returns PASS or FAIL. On FAIL, revise the named findings in place
   and re-validate; the loop repeats until a verdict with zero findings, per
   the standards reference's loop section. The approval gate is unchanged
   and follows validation. Revising
   an existing spec (this card's revision path) validates the revised spec
   against the same standards reference — one criteria source exists in the
   deck; an on-demand audit of a prior spec restates those criteria verbatim
   from the same reference.
8. **Approval is a human gate.** The spec waits for the developer's
   authorization before `plan` — and a terminal-stage approval
   (`approved for pr`, `approved for implementation`, …) from the vocabulary
   in `floor.md` *is* that authorization; the stage is not re-asked.
9. **Email actions.** Mid-flow email work — drafting, sending, or mailbox
   checks — dispatches to the `email-ops` subagent, which holds the gmail
   tool permissions; the flow itself never calls gmail tools directly.
10. **Deprecation encounters at authoring time.** A spec that touches a
   witnessed deprecation follows [the deprecation encounter protocol](../guidelines/deprecation-encounter-protocol.md):
   new requirements never specify deprecated surface; a load-bearing
   deprecation with no route around becomes a temporary-use exception
   carve-out cross-referencing the owning `[BITROT]` ticket and is escalated
   with the proposed text — the carve-out adjusts this spec, it never widens
   its scope.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
