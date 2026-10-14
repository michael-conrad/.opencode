# SPEC: Connector-card reload semantics (gb-cli, gh-cli)

Date: 2026-10-14 · Scope: deck content change in the `.opencode` deck — the two
connector-card descriptions (`skills/gb-cli/SKILL.md`,
`skills/gh-cli/SKILL.md`) plus one deck-debt ledger entry. Rides the
submodule's PR process; description edits are deck-governed (`skill-creator`).
Developer-directed conversion of `.opencode#2547` (instruction, 2026-10-14).

---

## Why

### F1 — The descriptions are one-shot-satisfiable: no reload semantics (observed incident, `.opencode#2547`)

Both connector-card descriptions gate loading with "Load before **any** command
or code that contacts GitBucket/GitHub …" — phrased entirely as a first-contact
trigger. Nothing states duration (the card remains in force for the rest of the
session) or re-triggering (a new operation class under the same utility is a
fresh trigger). A consuming agent that loaded the card for one matched intent
treated the trigger as satisfied for the rest of the session and made
ungoverned platform contacts in other operation classes with the card's
protective rules out of force.

Observed incident (2026-10-07 deploy session, downstream deployment; full
record in `.opencode#2547`):

1. `gb-cli` loaded legitimately for PR operations (compliant segment).
2. Post-merge cleanup and a later issue-reconciliation instruction produced
   `gb issue view` / `gb api` contacts with the card not loaded.
3. Tooling-defect workaround work then probed GitBucket with GitHub-shaped
   PATCH endpoints — repeated 404s against a route GitBucket lacks — and issued
   an empty-label PUT that wiped a label (restored), all with the card's
   protective rules out of force.

Those protective rules exist in the current card as: rule 3 (construct
carefully; `--help` before guessing), rule 4 (platform awareness — the exact
PATCH-404 gap the incident hit is documented there today), rule 6 (failures
are information; never retry blind). The ticket cites "rules 3–5"; rule
numbering has since shifted with the #2564/#2589 revisions — substance
unchanged. The failure recurred within one session, so load-then-discard is a
demonstrated behavior pattern, not a hypothetical.

### F2 — Current state, verified 2026-10-14 against the deck checkout

- `skills/gb-cli/SKILL.md` frontmatter description: no reload or duration
  semantics (verified by reading; grep for `reload|stays in force|fresh
  trigger|rest of the session` across both SKILL.md files, `routing.md`, and
  `floor.md` → zero hits).
- The gb-cli card was revised since filing (provenance #2564, #2589) without
  touching load-scope wording; the gh-cli card is untouched since #2490.
- The `routing.md` connector row names the cards and carries no duration
  semantics — recorded as affected in the ticket; see Out of scope.

Pre-edit description text (verification baseline for SC-2):

- **gb-cli:** "Load before any command or code that contacts GitBucket — using
  the gb CLI, GitBucket API calls, or anything needing GitBucket credentials
  for issues, pull requests, releases, or repository operations. Also load when
  authoring or running test-harness scenarios, scripts, or automation that will
  invoke gb or GitBucket endpoints at runtime, and when any GitBucket operation
  fails or behaves unexpectedly. Authentication is built into gb; never
  hand-roll GitBucket API code or hunt for credentials."
- **gh-cli:** "Load before any command or code that contacts GitHub — using the
  gh CLI, making GitHub API calls in any language, opening or updating
  PRs/issues/releases, reading repositories, or anything needing GitHub
  credentials. Authentication is built into gh; never hand-roll GitHub API
  calls, never hunt for tokens or passwords. Also load when GitHub operations
  fail unexpectedly."

### Predicate classification

The reload rule itself is **intent-decidable**: what counts as a "new operation
class" is judgment, and the description is consumed by agent judgment at
dispatch time — no scripted enforcement exists or is admitted (static checks on
intent are the deck's founding defect). The success criteria split accordingly:
SC-1/SC-2/SC-3 and SC-5/SC-6/SC-7 are fact-decidable (readable text facts);
SC-4 is behavioral (runtime evidence via the tests-v2 harness and its
clean-room evaluator, never a scripted pattern match over a transcript).
SC-5–SC-7 amend agent-facing markdown: the reference-integrity check runs on
both edited files before commit (SC-12 enforcement, #2489).

---

## What

- **C1 — Extend both connector-card descriptions with reload semantics,
  additively.** Each description gains: once loaded, the card stays in force
  for the rest of the session; a new operation class under the same utility
  (issues vs PRs vs API passthrough) is a fresh trigger — reload before the
  first use of each class. Phrasing stays deliberately pushy per card
  standards (agents undertrigger); no user-phrase matching; both abstraction
  levels preserved. No rule-body change, no `floor.md` change, no `routing.md`
  change.
- **C2 — Record the governance decision in the deck-debt ledger
  (`.opencode#2534`).** One ledger entry following the ledger's entry format:
  the 2026-10-07 incident as the admission-gate observed failure, the decision
  (reload semantics admitted into both connector descriptions), the reference
  to `.opencode#2547`, and the PR link placeholder per ledger convention.

### Revision 2026-10-14 — developer-directed scope extension: supervision stack into test-framework surfaces

During implementation (SC-4's GREEN verification), three supervision defects
were observed and root-caused; the developer directed that the revised
supervision approach be recorded in the test-framework documentation and the
test-framework skill card. Observed failures (this session, GREEN attempts
1–4 and the RED run's abort):

- **Orphaned run trees.** Killing the behavior_run wrapper left the
  with-test-home/opencode process pair orphaned (reparented to init), which
  kept generating for 15+ minutes unmanaged; a later tree-kill again missed a
  survivor. Nothing in the supervision doctrine requires verifying the whole
  process tree is actually dead after an abort.
- **Single-signal hang misdiagnosis.** A frozen session-WAL was treated as a
  hang indicator; it was later shown to be the post-smoke steady state. Hang
  verdicts need converging signals, and the authoritative server-side truth
  (the ollama service log) was never consulted — a `journalctl -u ollama`
  look would have settled attempt 2's diagnosis in one step instead of an
  inference chain.
- **Unmonitored launches strand recovery.** Runs launched without
  `BEHAVIOR_SEMANTIC_MONITOR=1` produce no determination record, so §10.7
  resumption is hard-blocked by the SC-8 determination gate when a hang
  strikes — recovery was only reachable via the §10.5 full re-run fallback.

- **C3 — Amend the test-framework documentation
  (`tests-v2/AGENTS.md`, §14 supervision/monitoring area) with the layered
  hang-diagnosis and abort-completeness approach.** (a) Hang verdicts require
  converging signals: session-DB flatness, WAL-growth stall, GPU utilization,
  and the ollama service log (`journalctl -u ollama`) — no single signal
  (including WAL freeze alone, which has a legitimate post-smoke steady
  state) is a hang verdict; the server log is the tiebreaker. (b) A server
  restart or error appearing in the service log during a run marks the run
  environment-suspect: abort, export, diagnose — never blind retry. (c)
  Abort completeness: after any run kill, enumerate the run's surviving
  processes (by recorded PID descendants and by test-home environment) and
  kill them; verify zero survivors before proceeding. (d) The
  "supervision loop stays inside the repository" clause is amended: for
  behavioral-run supervision, read-only host checks (`journalctl -u ollama`,
  `nvidia-smi`) are mandated per-poll surfaces per developer direction of
  2026-10-14; no host-state mutation is authorized.
- **C4 — Amend the behavioral-testing skill card (rule 9, supervision) with
  the same approach, card-sized.** The card gains: the layered
  hang-diagnosis rule with the server log as tiebreaker; the
  abort-completeness (kill-tree verification) step; and the launch mandate
  that orchestrated SC-verification runs set `BEHAVIOR_SEMANTIC_MONITOR=1`
  so determination records exist (unmonitored runs cannot resume through the
  §10.7 path). Card body only — no description change, no floor/routing
  change.

---

## Success criteria

| ID | Criterion | Evidence type | Verification instrument |
|----|-----------|---------------|-------------------------|
| SC-1 | Both connector-card frontmatter descriptions (`skills/gb-cli/SKILL.md`, `skills/gh-cli/SKILL.md`) state the reload semantics: (a) once loaded the card remains in force for the rest of the session, and (b) a new operation class under the same utility is a fresh load trigger requiring reload before the first use of that class. | structural | Read both frontmatter descriptions; each states both semantics. |
| SC-2 | The description edits are additive: every clause of the pre-edit text quoted under F2 remains present and unweakened post-edit in both files — the first-contact trigger with its operation enumeration, the gb-cli runtime-automation trigger, the failure-trigger clause, and the never-hand-roll / no-credential-hunting prohibitions. | structural | Read both post-edit descriptions; each pre-edit clause still present. |
| SC-3 | The deck-debt ledger (`.opencode#2534`) carries an entry recording the 2026-10-07 incident as the observed failure, the reload-semantics decision, and a reference to `.opencode#2547`. | structural | Read the #2534 issue record (body and comments); an entry with those three elements is present. |
| SC-4 | In a fresh behavioral session against the updated deck, an agent that has loaded gb-cli for one operation class loads gb-cli again before its first gb contact in a different operation class. | behavioral | tests-v2 harness scenario (`behavior_run`; GitBucket container per `BEHAVIOR_NEEDS_REMOTE`) reproducing the incident's transition shape — card-loaded PR segment, post-merge cleanup, then an issue-operation contact — with a real-domain task against the container repo; the clean-room evaluator reads `session.yaml` as the primary source (Skill-load event for gb-cli positioned between the class transition and the new class's first gb tool call) and returns the verdict per the behavioral-testing card. |
| SC-5 | `tests-v2/AGENTS.md` documents the layered hang-diagnosis rule: a hang verdict requires converging signals (session-DB flatness, WAL-growth stall, GPU utilization, ollama service log via `journalctl -u ollama`), no single signal alone is a hang verdict, the server log is the tiebreaker, and a server restart/error during a run marks the run environment-suspect (abort, export, diagnose — never blind retry). | structural | Read §14 of `tests-v2/AGENTS.md`; the layered rule, the single-signal prohibition, and the environment-suspect handling are all stated. |
| SC-6 | `tests-v2/AGENTS.md` documents abort completeness: after any run kill, the run's surviving processes are enumerated (recorded-PID descendants and test-home environment) and killed, with zero survivors verified before proceeding. | structural | Read §14 of `tests-v2/AGENTS.md`; the kill-tree verification step is stated. |
| SC-7 | The behavioral-testing skill card's supervision rule states: the layered hang-diagnosis signals including `journalctl -u ollama` as the server-side tiebreaker (read-only host checks authorized for run supervision), the abort-completeness step, and the launch mandate that orchestrated SC-verification runs set `BEHAVIOR_SEMANTIC_MONITOR=1` for determination-record compliance. | structural | Read the behavioral-testing `SKILL.md` supervision rule; all three elements are stated and no other rule text is weakened. |

---

## Out of scope

- **`routing.md` connector row** — unchanged: routing dispatches on intent;
  duration semantics belong to the descriptions the row points at. The ticket
  lists routing.md as affected-observed but proposes no remediation there.
- **Rule-body changes** (e.g., when raw `gb api` is allowed) — ticket
  non-goal; existing rule 2 already covers it.
- **`floor.md` additions** — ticket non-goal; card-scoped change, not
  pre-dispatch decision surface (always-loaded surface discipline).
- **gh-cli behavioral verification** — the harness provisions a GitBucket
  container, not a GitHub one, and clean-room isolation forbids credential
  passthrough to real remote APIs; a gh-cli behavioral SC is infeasible under
  the isolation contract, so the SC is scoped to the observed failure's path
  (gb-cli). gh-cli's behavioral equivalence is carried by the identical
  semantics text (SC-1) and is accepted as structurally verified only.
- **Description rewrite beyond the additive extension** — re-phrasing existing
  triggers or re-ordering clauses is out; SC-2 pins the edit as additive.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
