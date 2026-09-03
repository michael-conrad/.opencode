# Full Spec — Issue #2427 (.opencode)
# Tier-1 context-injection reduction — scopes A/B/C/D/E/G.
# NO size-threshold PASS/FAIL criteria (#2411) — size figures are diagnostic evidence only.
issue: 2427
remote_issue: 2429
remote_url: https://github.com/michael-conrad/.opencode/issues/2429
labels:
  - needs-approval
  - spec-draft

> **Full spec and artifacts: [`.opencode/.issues/2427/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2427)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2427/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings
>
> **Scope G (developer-directed revision):** test-framework semantic continuous monitoring mandate — behavioral runs are launched in background, polled at intervals, and each poll semantically evaluates the live session event stream; off-track/loop states hard-abort the run. See SC-10, R-21/R-22, Item 10, and the §10.7 amendment in tests-v2/AGENTS.md.

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | The always-injected Tier-1 guideline corpus duplicates semantic rules across multiple injected files and injects scenario-governed content that applies only in specific sessions. Duplicated content risks divergence between copies; scenario-governed content at Tier 1 is dead weight for every session that never enters the scenario. Additionally, the 000-critical-rules.md file lacks two targeted carve-outs (infrastructure-failure inline execution; anti-recitation) whose absence forces agents into halt/loop and recitation behavior on mechanically safe actions. |
| 2 | **Root Cause / Motivation** | The corpus grew by accretion: scenario-scoped sections (orchestrator context mechanics, discussion etiquette, tool installation tables, Python-only standards) were placed in Tier-1 files where every session pays the injection cost, and the same rules were written into two homes (020 §4 ↔ 085; AGENTS.md Pair Mode ↔ 116; gb install content ↔ skill neighborhood) without a single canonical-owner decision. It must be solved now because every session start injects the full corpus (~225,798 B across 15 files, verified by stat — diagnostic evidence only), and the duplication plus misplacement defects compound with each new rule added to the wrong tier. |
| 3 | **Approach Chosen** | Preserve the #497 hard-constraint core (human-only merge, approval gate, no self-authorization, attribution mandates) in Tier-1 files; add the two 000-critical-rules.md carve-outs (scope A: infrastructure-failure inline-execution authorization with mandatory disclosure; scope B: anti-recitation clause for safe reversible actions) as numbered binary-condition procedures; split 020-go-prohibitions.md and 080-code-standards.md by moving scenario-governed sections to Tier-2 files with semantically equivalent content; trim AGENTS.md scenario sections to pointers; reconcile every duplicate to exactly one canonical home; register all demoted content in INDEX.md routing and retain imperative Read [Text](path) pointers in the Tier-1 cores. Scope G (developer-directed revision) adds a test-framework mandate: every behavioral opencode run is launched in background and polled at intervals; each poll reads the live session DB and semantically evaluates the event stream (tool calls, reasoning sizes, text parts) to judge whether the agent is progressing toward the scenario goal or has gone off-track, with hard-abort signals and recorded semantic diagnosis replacing blind timeout burn and blind resume loops. |
| 4 | **Alternatives Considered & Why Discarded** | (a) **Delete scenario content outright.** Discarded — the rules remain valid in their scenarios; deletion would break behavioral tests and lose semantics (binding requirement: semantics must remain). (b) **Hard byte/token/percentage reduction thresholds as SCs.** Discarded — prohibited by #2411; savings are an emergent property of correctly implementing content-based SCs, never a PASS/FAIL criterion. (c) **Remove echo blocks ([critical-rules-*] duplicates) in the same pass.** Discarded — echo blocks are enforcement-test grep targets; their removal requires coupled test-suite migration and is deferred to a separate follow-up spec (out-of-scope F). (d) **Blind session-resume loops as the sole hang recovery (scope G alternative).** Discarded — §10.7 resumption blindly continues from where the run stalled without judging whether the agent was progressing; a stuck or looping run resumed blindly burns the full timeout again. The semantic monitoring mandate (SC-10) judges progression each poll and hard-aborts off-track runs; resumption remains the recovery path for runs that were genuinely progressing when killed (e.g., bash tool timeout). |
| 5 | **Key Design Decisions** | (1) Echo blocks travel WITH their sections (OQ-1, developer-resolved) — scope C/D move whole sections; enforcement-test grep targets are re-pointed in the sweep phase (SC-8). (2) Dedup to single canonical homes, not dual-copy moves: 085 is canonical for project-local tools, 116 for pair mode. (3) New Tier-2 files use the standard frontmatter schema (trigger_on, tier: 2, load_when) and are NOT added to the opencode.jsonc instructions array — that would defeat the split. (4) Pointer form is exclusively imperative `Read [Text](path)` — research cards (confidence 0.85/0.9) confirm the "See X" citation form is defective and never loaded. (5) The 000 additions use numbered binary-condition procedure form, not prose mandates, per the 0.9-confidence research card finding. (6) Scope G monitoring is semantic, not heuristic-only: mechanical signals (identical tool input >=3x, task() parts stuck running >=2 consecutive polls, reasoning >20K chars with <=1 new tool call) trigger abort, but the poll ALSO reads the event stream semantically each interval — a run with no goal-relevant completed tool call across 2+ consecutive polls while reasoning grows is judged off-track even when no mechanical threshold fires. (7) Evidence for behavioral SCs is behavioral, never structural: monitored-run SCs record the poll log or semantic diagnosis alongside session.yaml (EVIDENCE_TYPE_MISMATCH gate). |
| 6 | **User Intent / Original Prompt** | Reduce Tier-1 context injection by scopes A (infrastructure-failure carve-out), B (anti-recitation clause), C (split 020-go-prohibitions by placement), D (split 080-code-standards by placement), E (trim AGENTS.md scenario sections) — duplication and incorrect-placement defects; semantics must remain (rewrites OK if rule/guide/intent unchanged); no size-threshold SCs; the #497 core stays in main context; echo-block removal is a separate follow-up spec. Scope G (developer-directed revision, 2026-09-03): update the test framework to mandate semantic continuous monitoring of behavioral runs — background launch + interval polling, live session DB reads, semantic off-track judgment, hard-abort signals, abort recovery with semantic diagnosis, and monitoring evidence recorded with behavioral SC verdicts; amends the §10.7 resumption known limitation (with-test-home provisions a NEW test home per invocation, so --continue cannot reach a prior run's DB — resumption across invocations requires a shared-home mechanism; the semantic monitoring mandate replaces blind resume loops). |

## 2. Not Included

- **[Echo-block removal (scope F)]** — [critical-rules-*] echo blocks are enforcement-test grep targets; removing them requires coupled test-suite migration and is deferred to a separate follow-up spec. Echo blocks inside moved sections travel with their sections (OQ-1 disposition).
- **[Changes to authorization semantics]** — only WHERE rule text lives changes; what authorizes what is untouched (NR-2).
- **[Changes to attribution requirements]** — 080 attribution/provenance sections stay mandatory and Tier-1, explicitly untouched (NR-3, #2131 continuity).
- **[opencode.jsonc instructions array restructuring]** — the 14-entry array is unchanged; new Tier-2 files are NOT appended (NR-4, R-10, R-20).
- **[session-enforcement.ts / env-loader.ts changes]** — verified zero guideline coupling (NR-5).
- **[Size-reduction targets as success criteria]** — prohibited by #2411; injection-size measurements are informational evidence only (NR-6).
- **[Behavioral test suite restructuring beyond the sweep]** — only prompts/assertions referencing moved content are re-pointed (NR-7). Amended by scope G: the tests-v2 harness itself (AGENTS.md documentation + behaviors/helpers.sh monitoring protocol) is now in-scope via SC-10 — NR-7 still excludes scenario-suite restructuring, but the monitoring mandate is harness-level, not a scenario restructure.
- **[#2416 AGENTS.md content additions]** — #2416 (approved-for-pr) adds text to the same AGENTS.md file; this spec stacks on feature/2402-finishing-checklist-trailer-remediation and its Phase-4 edits must rebase cleanly alongside #2416's changes (sequencing constraint, not content conflict).

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | 000-critical-rules.md SHALL contain the infrastructure-failure carve-out (scope A): a numbered procedure with binary conditions under which, after >=2 consecutive tool-level sub-agent dispatch failures, inline execution of read-only/verification work is authorized WITH explicit disclosure in the agent's output. | behavioral | New behavioral scenario via `bash .opencode/tests-v2/with-test-home opencode run '<simulated >=2 dispatch-failure message>'`; assert session stderr shows the agent discloses and proceeds inline within read-only/verification limits (RED: halts/loops before the carve-out exists). |
| SC-2 | 000-critical-rules.md SHALL contain the anti-recitation clause (scope B): rule citations belong in enforcement artifacts (test scripts, pre-commit hooks), not in agent deliberation; on a safe reversible action the agent acts and discloses instead of reciting rules before acting. | behavioral | New behavioral scenario via `with-test-home opencode run '<safe reversible action message>'`; assert session stderr shows the agent performing the action with disclosure and zero citation-only turns (RED: recitation-only before the clause exists). |
| SC-3 | 020-go-prohibitions.md Tier-1 core SHALL retain authorization semantics, prohibited authorization patterns, halt rules, the authorization-free-actions list, and silent-halt-with-search; the scenario-governed sections (1.1 Orchestrator Context Discipline, 1.6 Discussion Mode Mandates, 4 Project-Local Tool Installation) SHALL be moved to Tier-2 file(s) with semantically equivalent content; the 020 core SHALL retain one-line `Read [Text](path)` pointer per demoted concern. | behavioral | Structural grep for retained sections in 020 core + absent moved sections + pointer lines; behavioral routing spot-check via `with-test-home opencode run` asserting the agent reaches the moved rule through the pointer/INDEX row. |
| SC-4 | 080-code-standards.md Tier-1 core SHALL retain attribution/provenance/byline-preservation mandates plus cross-reference/numbering/YAML standards; Python-specific sections (Typing, Design Principles body, Modern Python, DI mandates, Print Statements, Libraries & Packages, Pipeline Rerun Constraint) SHALL be moved to a Tier-2 file with semantically equivalent content; the 080 core SHALL retain a `Read [Text](path)` pointer; the attribution sections SHALL be untouched. | behavioral | Structural grep for attribution sections intact + moved sections absent from core + pointer present; behavioral DI-reachability check re-running the 2243-sc1-style scenario against the Tier-2 destination post-sweep. |
| SC-5 | AGENTS.md gb CLI install table/version-pinning/TOOL_MISSING content SHALL be moved to a Tier-2 location with semantics preserved; the editor MCP tool table SHALL be moved to a Tier-2 reference; the Pair Mode section SHALL be replaced by a pointer to the existing 116-pair-mode.md canonical home (dedup — no second copy); the one-line gb skill-dispatch mandate SHALL be retained. | behavioral | Structural grep for pointers replacing the three sections + retained mandate line; behavioral spot-check that a gb-install or pair-mode question routes the agent to the canonical content. |
| SC-6 | Each duplicated rule class SHALL have exactly ONE canonical Tier-2 home post-change: project-local tools (020 section 4 vs 085 → 085 canonical), pair mode (AGENTS.md vs 116 → 116 canonical), gb install reference (AGENTS.md vs gb-cli skill area → one location). | structural | `grep -rn` across `.opencode/guidelines/` and `.opencode/AGENTS.md` for each rule class's key semantics; assert single occurrence per class after the change. |
| SC-7 | INDEX.md SHALL contain a Tier-2 routing row for every demoted content class with trigger patterns matching the content (context-discipline, discussion-mode, python-standards classes; existing 085/116 rows reused where canonical). | structural | Read INDEX.md post-change; assert one routing row per demoted class with trigger patterns matching the moved content; new destination files carry frontmatter `tier: 2`. |
| SC-8 | All Read-links and test SCENARIO_PROMPTs referencing moved sections SHALL be re-pointed; zero dangling section anchors SHALL remain; the affected behavioral scenarios (2243-sc1, 2249-sc6, 2249-sc7 pair, pipeline-scoped-halt) SHALL pass via with-test-home after the sweep. | behavioral | `grep -rn "guidelines/020-go-prohibitions\|guidelines/080-code-standards" .opencode/skills/ .opencode/guidelines/` returns no dangling anchors; run the named scenarios via `bash .opencode/tests-v2/with-test-home` — PASS. |
| SC-9 | Post-change, human-only merge (000-critical-rules.md), approval gate/no-self-authorization (010-approval-gate.md), and attribution mandates (080-code-standards.md) SHALL remain in Tier-1 injected files, and the opencode.jsonc instructions array SHALL be unchanged (14 entries, byte-identical). | structural | `git diff .opencode/opencode.jsonc` empty; grep for the human-only-merge rule in 000, the zero-tolerance table in 010, and the attribution sections in 080 — all present. |
| SC-10 | The tests-v2 harness SHALL mandate semantic continuous monitoring of every behavioral opencode run (scope G): the run is launched in background and polled at intervals; each poll reads the live session DB (newest `tmp/test-home-*/.local/share/opencode/opencode.db`) and semantically evaluates the event stream (tool calls, reasoning sizes, text parts) to judge whether the agent is progressing toward the scenario goal or has gone off-track. Hard-abort signals: identical tool input >=3x, task() parts stuck in running >=2 consecutive polls, reasoning >20K chars with <=1 new tool call, or semantically judged off-track (no goal-relevant completed tool call across 2+ consecutive polls while reasoning grows). On abort: kill the run, export session.yaml per §10.5, record the semantic diagnosis. Behavioral SC verdicts whose evidence comes from monitored runs SHALL record the monitoring evidence (poll log or semantic diagnosis) alongside session.yaml. The §10.7 resumption section SHALL document the known limitation: with-test-home provisions a NEW test home per invocation, so `--continue` cannot reach a prior run's DB — resumption across invocations requires a shared-home mechanism; the semantic monitoring mandate replaces blind resume loops. | behavioral | Verdict basis: behavioral — a monitored run where the semantic poll detects an off-track/loop state and aborts (session.yaml shows the stalled state; poll log/semantic diagnosis records the abort decision), vs an unmonitored run that burns the full timeout (RED comparison). Verification via session.yaml artifacts showing the poll protocol was executed: poll log artifact with per-poll event-stream reads + semantic judgment, abort record with §10.5 export, and §10.7 amendment visible in tests-v2/AGENTS.md. |

## 4. Requirements

- R-1. 000-critical-rules.md SHALL contain an infrastructure-failure carve-out (scope A) authorizing inline execution for read-only/verification work after repeated tool-level sub-agent dispatch failures, WITH mandatory disclosure.
- R-2. 000-critical-rules.md SHALL contain an anti-recitation clause (scope B) establishing that rule citations belong in enforcement artifacts, not in agent deliberation; on a safe reversible action, the agent acts and discloses instead of re-deriving protocol.
- R-3. 020-go-prohibitions.md SHALL retain authorization semantics, prohibited authorization patterns, and halt rules in Tier-1, and SHALL move scenario-governed sections (Orchestrator Context Discipline, Discussion Mode Mandates, Project-Local Tool Installation) to Tier-2 routing.
- R-4. 080-code-standards.md SHALL retain attribution/provenance mandates in Tier-1, and SHALL move Python-specific sections (Typing, Design Principles body, Modern Python, DI mandates, Print Statements, Libraries & Packages, Pipeline Rerun Constraint) to Tier-2 routing.
- R-5. AGENTS.md SHALL trim scenario-specific sections (gb CLI install table, version pinning, TOOL_MISSING, editor MCP tool table, Pair Mode section) to Tier-2 routing pointers.
- R-6. Every moved rule SHALL remain semantically equivalent (same requirements, forbiddances, and mandates); rewrites, rephrasing, restructuring, and condensation during the move are permitted — verbatim text is NOT required.
- R-7. Every moved rule SHALL remain reachable via Tier-2 INDEX.md routing (load-on-demand) or conditional load.
- R-8. Human-only merge, no self-authorization, the approval gate, and attribution mandates SHALL remain in main context (Tier-1 injected files) per the #497 hard constraint.
- R-9. Echo-block removal (scope F) SHALL NOT occur in this spec — it is deferred to a separate follow-up spec; sections containing echo blocks move WITH their blocks.
- R-10. The opencode.jsonc instructions array SHALL NOT change (14 entries; new Tier-2 files are NOT added to the array).
- R-11. New Tier-2 destination files SHALL carry the standard YAML frontmatter (trigger_on, tier: 2, load_when) and SHALL be registered in INDEX.md with trigger patterns matching their content.
- R-12. Consumers of moved section anchors SHALL be updated: skill Read-links pointing into moved 020/080/AGENTS.md sections, behavioral test SCENARIO_PROMPTs hardcoding the 080 path for DI content, and 085's mutual Read-link into 020 section 4.
- R-13. Duplicates SHALL be reconciled to ONE canonical home (020 section 4 vs 085; AGENTS.md Pair Mode vs 116; gb install content vs gb-cli skill neighborhood) — dedup, not dual-copy move.
- R-14. Tier-1 cores SHALL retain a one-line imperative `Read [Text](path)` pointer for each demoted concern (the "See X" citation form is defective and MUST NOT be used).
- R-15. Enforcement-test compatibility SHALL be preserved: test-enforcement.sh FILE_SCENARIO_MAP keys on unchanged file paths; scenarios asserting moved content receive path-updated prompts in a dedicated sweep phase.
- R-16. NO hard byte/token/percentage/line-count reduction thresholds SHALL be used as PASS/FAIL criteria (#2411); savings are emergent, and SCs define WHAT moves, retains, and removes.
- R-17. This spec's implementation SHALL stack on feature/2402-finishing-checklist-trailer-remediation; AGENTS.md Phase-4 edits must rebase cleanly alongside approved #2416 same-file additions.
- R-18. This spec SHALL NOT supersede closed #2131 outcomes; 080 attribution sections remain explicitly untouched.
- R-19. pymarkdownlnt scan and mdformat --check SHALL pass on all modified guideline files (advisory, read-only modes only).
- R-20. No Tier-1 file SHALL be removed from the opencode.jsonc instructions array (the WARNING comment documents the #497 regression).
- R-21. The tests-v2 harness (AGENTS.md documentation + behaviors/helpers.sh monitoring helper or documented protocol) SHALL mandate semantic continuous monitoring of every behavioral opencode run: background launch, interval polling, live session DB read (newest `tmp/test-home-*/.local/share/opencode/opencode.db`) with semantic evaluation of the event stream (tool calls, reasoning sizes, text parts) against the scenario goal each poll.
- R-22. The monitoring protocol SHALL define hard-abort signals (identical tool input >=3x; task() parts stuck in running >=2 consecutive polls; reasoning >20K chars with <=1 new tool call; semantically judged off-track — no goal-relevant completed tool call across 2+ consecutive polls while reasoning grows) and the abort recovery procedure (kill the run, export session.yaml per §10.5, record the semantic diagnosis). Behavioral SC verdicts relying on monitored runs SHALL record monitoring evidence (poll log or semantic diagnosis) alongside session.yaml, and tests-v2/AGENTS.md §10.7 SHALL document the with-test-home new-home-per-invocation resumption limitation.

## 5. Items

### Item 1 (SC-1): Add infrastructure-failure carve-out to 000-critical-rules.md

- RED: Behavioral scenario — clean-room agent in a simulated >=2 consecutive dispatch-failure situation halts/loops with no carve-out present; assert via session stderr tool calls.
- GREEN: Add the numbered binary-condition carve-out (~15 lines) to 000-critical-rules.md; re-run the scenario — agent discloses and proceeds inline within read-only/verification limits.
- verify: Run the new behavioral scenario via `bash .opencode/tests-v2/with-test-home opencode run`; assert stderr shows disclosure + inline execution of read-only/verification work only.
- commit: 000-critical-rules.md plus its new behavioral scenario.

### Item 2 (SC-2): Add anti-recitation clause to 000-critical-rules.md

- RED: Behavioral scenario — agent recites protocol before a mechanically simple, safe, reversible action; session stderr shows citation-only turns.
- GREEN: Add the anti-recitation clause (~10 lines); re-run — agent acts and discloses with zero citation-only turns.
- verify: Run the new behavioral scenario via `with-test-home opencode run`; assert stderr shows the safe action performed with disclosure.
- commit: 000-critical-rules.md plus its new behavioral scenario.

### Item 3 (SC-3): Split 020 — move scenario-governed sections to Tier-2

- RED: Structural — INDEX lacks routing rows for the context-discipline/discussion/project-local classes; the 020 core still contains the three scenario sections.
- GREEN: Move sections 1.1, 1.6, and 4 to new Tier-2 file(s) with semantically equivalent content; reconcile section 4 into 085 as canonical (dedup); add INDEX rows and one-line `Read [Text](path)` pointers in the 020 core.
- verify: grep the 020 core for retained authorization/halt content, absent moved sections, and present pointers; behavioral routing spot-check via `with-test-home opencode run`.
- commit: 020-go-prohibitions.md, new Tier-2 file(s), 085-project-local-tools.md, INDEX.md.

### Item 4 (SC-4): Split 080 — move Python-specific sections to Tier-2

- RED: Structural — no Tier-2 python-standards file exists; the 080 core still carries the Python sections.
- GREEN: Move Typing, Design Principles body, Modern Python, DI mandates, Print Statements, Libraries & Packages, and Pipeline Rerun Constraint to a new Tier-2 file with frontmatter and semantically equivalent content; add the INDEX row and the 080-core Read [Text](path) pointer; attribution sections untouched.
- verify: grep the 080 core for attribution sections intact, moved sections absent, pointer present; behavioral DI-reachability via the re-pointed 2243-sc1 scenario.
- commit: 080-code-standards.md, new Tier-2 python-standards file, INDEX.md.

### Item 5 (SC-5): Trim AGENTS.md scenario sections to Tier-2 routing

- RED: Structural — AGENTS.md carries the gb install table, editor MCP tool table, and Pair Mode table; no single canonical homes exist.
- GREEN: Replace with one-line `Read [Text](path)` pointers (Pair Mode → existing 116-pair-mode.md; gb install → Tier-2 reference location; editor table → Tier-2 reference location); retain the one-line gb skill-dispatch mandate.
- verify: grep AGENTS.md for pointers replacing the three sections; behavioral spot-check that a gb-install or pair-mode question routes to canonical content.
- commit: AGENTS.md plus its routing destinations.

### Item 6 (SC-6): Duplicate reconciliation verification

- RED: grep finds more than one occurrence per duplicated rule class.
- GREEN: Each rule class resolves to one canonical home (completed by items 3-5 edits; this item verifies and fixes stragglers).
- verify: grep for each class's key semantics — exactly one occurrence per class across `.opencode/guidelines/` and `.opencode/AGENTS.md`.
- commit: any straggler dedup fixes in guidelines/.

### Item 7 (SC-7): INDEX.md routing completeness

- RED: INDEX lacks rows for the demoted classes.
- GREEN: All demoted classes have Tier-2 rows with accurate trigger patterns (partially done inside items 3-5; this item verifies the full row set).
- verify: read INDEX.md — one row per class; new files carry `tier: 2` frontmatter.
- commit: INDEX.md row corrections if any.

### Item 8 (SC-8): Consumer sweep — Read-links + test prompts

- RED: grep sweep finds dangling section anchors; affected scenarios fail.
- GREEN: Re-point all skill Read-links and SCENARIO_PROMPT paths referencing moved content; re-run the affected scenarios (2243-sc1, 2249-sc6, 2249-sc7 pair, pipeline-scoped-halt) via `with-test-home` — PASS.
- verify: `grep -rn "guidelines/020-go-prohibitions\|guidelines/080-code-standards" .opencode/skills/ .opencode/guidelines/` returns zero dangling anchors; scenario runs PASS.
- commit: swept skill files and behavioral test prompts.

### Item 9 (SC-9): #497 guard verification

- RED: n/a (guard — RED is the pre-change state check that the core rules are present before any edits).
- GREEN: grep for human-only merge in 000, the zero-tolerance table in 010, and the attribution sections in 080 — all present post-change; `git diff .opencode/opencode.jsonc` is empty; the instructions array holds 14 entries.
- verify: structural greps + git diff as named.
- commit: none (verification-only item; evidence recorded).

### Item 10 (SC-10): Test-framework semantic continuous monitoring mandate (scope G)

- RED: Behavioral — run a scenario that drives an off-track/loop state (e.g., a prompt that induces repeated identical tool input or reasoning growth with no goal-relevant tool calls) UNMONITORED and observe it burn the full timeout with no abort and no diagnosis recorded.
- GREEN: Add the monitoring mandate to tests-v2/AGENTS.md (new subsection or amend §10.5/§10.7, authority-frame MANDATORY/PROHIBITED tables per dark-prose-007 cost frame) and implement the monitoring helper or documented poll protocol in tests-v2/behaviors/helpers.sh: background launch, interval poll, live session DB read (newest `tmp/test-home-*/.local/share/opencode/opencode.db`), semantic event-stream evaluation (tool calls, reasoning sizes, text parts) against the scenario goal, hard-abort signals, kill + §10.5 export + semantic-diagnosis recording on abort.
- verify: Run the monitored variant — session.yaml shows the stalled event stream; poll log/semantic diagnosis artifact records the abort decision; the abort beats the full-timeout baseline. §10.7 amendment documents the with-test-home new-home-per-invocation limitation. Monitored-run SC verdicts record monitoring evidence alongside session.yaml.
- commit: tests-v2/AGENTS.md, tests-v2/behaviors/helpers.sh (or the protocol's implementation files), plus the monitoring evidence artifacts.

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| Issue #2402 branch (feature/2402-finishing-checklist-trailer-remediation) | This spec's implementation stacks on it; branch must exist and be current | Pending (stacking base) |
| Issue #2411 (approved-for-pr) | Binding constraint — no size-threshold PASS/FAIL SCs; read before plan creation | Satisfied (verified live in .opencode/.issues/2411/spec.md) |
| Issue #2416 (approved-for-pr) | Same-file PARTIAL-OVERLAP on AGENTS.md — sequencing via branch stacking; Phase-4 edits must rebase cleanly | Pending (sequencing constraint) |
| Issue #2131 (closed, PR #2238) | Prior 080 compaction — continuity constraint; no supersession; attribution untouched | Satisfied (closed) |
| Issue #497 (closed) | Hard constraint — Tier-1 core preservation rationale; opencode.jsonc WARNING comment documents the regression | Satisfied (constraint inherited) |
| `.opencode/guidelines/116-pair-mode.md` | Canonical home for Pair Mode dedup — must be read before item 5 | Satisfied (exists, 118 lines) |
| `.opencode/guidelines/085-project-local-tools.md` | Canonical home for project-local tools dedup — must be read before item 3 | Satisfied (exists, 52 lines) |
| Research cards: cross-reference-lobotomization.md, imperative-verb-forms-load-directives.md, thinking-block-verification-checkpoint.md | Read before implementation — pointer form and procedure-form findings (confidence >= 0.85) | Satisfied (consulted; findings in research-card-consultation.yaml) |
| `.opencode/tests-v2/with-test-home` | All behavioral verification MUST run through it (never bare `opencode run`) | Satisfied (exists) |

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Item 1 |
| R-2 | SC-2 | Item 2 |
| R-3 | SC-3 | Item 3 |
| R-4 | SC-4 | Item 4 |
| R-5 | SC-5 | Item 5 |
| R-6 | SC-3, SC-4, SC-5 | Items 3, 4, 5 |
| R-7 | SC-7 | Item 7 |
| R-8 | SC-9 | Item 9 |
| R-9 | SC-3, SC-4 (guard) | Items 3, 4 |
| R-10 | SC-9 | Item 9 |
| R-11 | SC-7 | Item 7 |
| R-12 | SC-8 | Item 8 |
| R-13 | SC-6 | Item 6 |
| R-14 | SC-3, SC-4, SC-5 | Items 3, 4, 5 |
| R-15 | SC-8 | Item 8 |
| R-16 | All SCs (authoring constraint) | All |
| R-17 | SC-5 (sequencing) | Item 5 |
| R-18 | SC-4 (continuity) | Item 4 |
| R-19 | SC-3, SC-4, SC-5 (lint gate) | Items 3, 4, 5 |
| R-20 | SC-9 | Item 9 |
| R-21 | SC-10 | Item 10 |
| R-22 | SC-10 | Item 10 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| Pre-spec inspection (files, defects, couplings) | analysis artifact | `.opencode/.issues/2427/artifacts/pre-spec-inspection.yaml` | stat/read/grep of all 15 injected files this session |
| Requirements output | analysis artifact | `.opencode/.issues/2427/artifacts/requirements-output.yaml` | extracted from developer binding scope + live verification |
| Decompose output (SCs, items, DAG) | analysis artifact | `.opencode/.issues/2427/artifacts/decompose-output.yaml` | atomicity/DAG traced manually per pipeline-readiness gate |
| Concern map (boundaries, destinations) | analysis artifact | `.opencode/.issues/2427/artifacts/concern-map.yaml` | read of 020/080/AGENTS.md sections + 085/116 overlap checks |
| Blast radius (affected files, consumers) | analysis artifact | `.opencode/.issues/2427/artifacts/blast-radius.yaml` | grep of skill Read-links + test scripts |
| Code path inventory (injection/routing/test paths) | analysis artifact | `.opencode/.issues/2427/artifacts/code-path-inventory.yaml` | read of opencode.jsonc lines 76-93 + FILE_SCENARIO_MAP lines 129-139 |
| Cross-cutting matrix (sibling issues) | analysis artifact | `.opencode/.issues/2427/artifacts/cross-cutting-matrix.yaml` | live issue-state checks (#2411, #2416, #2131, #2419) |
| Interface compatibility (anchors, prompts) | analysis artifact | `.opencode/.issues/2427/artifacts/interface-compatibility.yaml` | grep of Read-links + SCENARIO_PROMPT paths |
| State analysis (git/issue/tmp state) | analysis artifact | `.opencode/.issues/2427/artifacts/state-analysis.yaml` | git log + local-issues counter verification |
| Testability assessment (test coverage, gaps) | analysis artifact | `.opencode/.issues/2427/artifacts/testability-assessment.yaml` | grep of behavioral scripts (2243, 2249, 2131, 2293 series) |
| Pipeline readiness gate | analysis artifact | `.opencode/.issues/2427/artifacts/pipeline-readiness.yaml` | 5 checks PASS (atomicity, ordering, concern, phase, tiering) |
| Research card consultation | research artifact | `.opencode/.issues/2427/artifacts/research-card-consultation.yaml` | glob `.issues/research-cards/*.md` + frontmatter grep; 3 cards incorporated (confidence >= 0.85) |
| opencode.jsonc instructions array | config | `.opencode/opencode.jsonc` (lines 76-93) | read this session — 14 entries verified |
| 116-pair-mode.md (canonical Pair Mode home) | code | `.opencode/guidelines/116-pair-mode.md` | read this session — exists, 118 lines |
| 085-project-local-tools.md (canonical tools home) | code | `.opencode/guidelines/085-project-local-tools.md` | read this session — exists, 52 lines, carries the 8 key rules |
| test-enforcement.sh FILE_SCENARIO_MAP | code | `.opencode/tests-v2/test-enforcement.sh` (lines 129-139) | read this session — path-keyed mapping verified |
| #2411 spec (size-threshold prohibition) | issue | `.opencode/.issues/2411/spec.md` | read this session — SC text verified live |
| tests-v2/AGENTS.md §10.5/§10.7 (timeout recovery, resumption) | code | `.opencode/tests-v2/AGENTS.md` (lines 597-680) | read this session — §10.5 fallback procedure and §10.7 resumption mandate verified live; scope G amends §10.7 |
| tests-v2/behaviors/helpers.sh (monitoring integration point) | code | `.opencode/tests-v2/behaviors/helpers.sh` | read this session — exists, 35652 B; scope G adds the monitoring helper or documented poll protocol |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Running the carve-out behavioral scenario costs minutes of execution time — a bounded delay that surfaces a halt/loop defect at gate 1. Skipping costs the full rework cycle when agents hang on infrastructure failures in production sessions — diagnosis, spec-fix, re-review — each costing more than the skipped test.
- **SC-2:** Running the anti-recitation behavioral scenario costs minutes of execution time. Skipping means recitation loops ship into every session, burning context on citation-only turns until a downstream agent fails on a deadline task.
- **SC-3:** Running the 020 split's structural greps and one routing spot-check costs seconds to minutes. Skipping means authorization law and context mechanics share one file again — the next agent demoting content breaks the authorization core, and the defect surfaces as an enforcement-test failure in CI days later.
- **SC-4:** Running the 080 split's greps and the DI-reachability re-run costs minutes. Skipping means Python standards at Tier 1 mislead non-Python sessions and the DI test prompts break silently — discovered only when the behavioral suite next runs.
- **SC-5:** Running the AGENTS.md trim's structural checks costs seconds. Skipping means install tables and tool inventories keep injecting every session, and the duplicated Pair Mode rules drift apart until a pair-mode session follows the stale copy.
- **SC-6:** Running the dedup grep sweep costs seconds. Skipping means dual canonical homes persist — divergent copies compound into contradictory rules that agents resolve arbitrarily.
- **SC-7:** Running the INDEX completeness check costs one read. Skipping means a demoted rule becomes unreachable — the agent that needs it never loads it, and the semantic-preservation goal silently fails at first use.
- **SC-8:** Running the consumer sweep and the four named scenarios costs minutes via with-test-home. Skipping means dangling Read-links and broken test prompts surface as CI failures and misrouted agents — 100× more expensive to diagnose downstream.
- **SC-9:** Running the #497 guard greps and git diff costs seconds. Skipping risks repeating the documented regression: a PR merged because the human-only-merge rule was missing from context — the highest-cost failure mode in the deck's history.
- **SC-10:** Running the monitored behavioral scenario costs minutes of execution time — the poll intervals plus one abort-and-diagnose cycle, a bounded delay that surfaces a stuck-run defect at gate 1 instead of burning the full 600-900s timeout on every looped run. Skipping means every off-track behavioral run burns its full timeout in CI, hung runs are blindly resumed (§10.7) only to stall at the same point again, and the defect-discovery loop costs a full rework cycle per hung scenario — diagnosis, spec-fix, re-review — each cycle costing far more than the monitoring harness. The one-time harness build cost is amortized across every behavioral scenario the deck runs; the per-run polling cost is seconds of SQLite reads against an already-present session DB.

## 11. Edge Cases

- **Condition:** A scenario-governed section's content overlaps two classes (e.g., an echo block inside a moved section).
  **Expected behavior:** The block moves WITH its section (OQ-1 disposition); enforcement-test grep targets are re-pointed in the sweep phase.
  **Resolution:** Sweep phase (item 8) re-points all grep targets; no content removal.
- **Condition:** A consumer Read-links a moved section anchor that no longer exists in the source file.
  **Expected behavior:** The sweep phase re-points every such link to the new canonical location before completion.
  **Resolution:** `grep -rn` sweep with zero-dangling-anchor evidence (SC-8).
- **Condition:** INDEX.md trigger pattern for a new Tier-2 file collides with an existing row's pattern.
  **Expected behavior:** The pattern is disambiguated so exactly one row matches a given trigger intent; verified 022/025/082 number ranges are free.
  **Resolution:** Item 7 verifies one-row-per-class with accurate patterns; frontmatter schema (trigger_on, tier: 2, load_when) is mandatory on new files.
- **Condition:** Behavioral scenario run exceeds the bash tool timeout (35B-model inference).
  **Expected behavior:** The scenario runs with a >=600s timeout via `with-test-home`; stale `tmp/.behavior-run.lock` is removed before re-runs.
  **Resolution:** Harness constraints from tests-v2/AGENTS.md lessons (scope-limited execution by default).
- **Condition:** #2416's approved AGENTS.md additions land on the stacking base while this spec's Phase 4 edits the same file.
  **Expected behavior:** Phase-4 edits rebase cleanly on feature/2402; no content conflict (disjoint sections).
  **Resolution:** Branch-stacking sequencing per R-17; rebase-always hygiene at implementation.
- **Condition:** The 020 §3 "Specialized Execution Gates" section is an empty header (verified this session).
  **Expected behavior:** The empty header is removed during the 020 split rather than moved.
  **Resolution:** Item 3 GREEN step; no semantics lost (nothing to preserve).
- **Condition:** A moved section's semantics are ambiguous at destination (rewriter unsure of original intent).
  **Expected behavior:** The mover preserves the original section text and defers condensation rather than guessing; semantic equivalence (R-6) is the invariant, verbatim text is not required but is the safe default.
  **Resolution:** Auditor semantic-comparison check downstream; block progress on doubt (fail-fast).
- **Condition:** All sub-agent dispatch attempts fail at implementation time (infrastructure failure — the exact condition scope A addresses).
  **Expected behavior:** The implementer applies the new carve-out procedure: >=2 consecutive tool-level failures authorize inline read-only/verification execution WITH disclosure.
  **Resolution:** Scope A (item 1) makes the carve-out available before any split work begins (item 1 precedes items 3-9 in the DAG).
- **Condition:** A monitored behavioral run crosses a hard-abort signal mid-inference (scope G).
  **Expected behavior:** The poll detects the signal, kills the run, exports session.yaml per §10.5, and records the semantic diagnosis — the run does NOT burn the remaining timeout.
  **Resolution:** Monitoring protocol (item 10) — abort path writes both session.yaml and the poll log/diagnosis artifact; the scenario verdict is evaluated on the partial evidence, which §10.5 confirms is valid.
- **Condition:** An agent attempts `--continue` session resumption across a `with-test-home` invocation boundary (scope G, §10.7 known limitation).
  **Expected behavior:** Resumption CANNOT reach the prior run's DB — with-test-home provisions a NEW test home per invocation, so the prior session id is unreachable via `--continue`; the agent MUST NOT loop blind resume attempts.
  **Resolution:** §10.7 amendment documents the limitation: resumption across invocations requires a shared-home mechanism (out of scope G's mandate — the semantic monitoring mandate replaces blind resume loops); within-invocation resumption remains per §10.7, and cross-invocation recovery follows the monitoring abort path (kill + export + diagnose).
- **Condition:** The semantic poll judges a run off-track while no mechanical signal (identical input, stuck task(), reasoning-size threshold) has fired.
  **Expected behavior:** The semantic judgment alone (no goal-relevant completed tool call across 2+ consecutive polls while reasoning grows) authorizes abort — mechanical signals are necessary-but-not-sufficient triggers, not the only abort path.
  **Resolution:** R-22 lists the semantic off-track judgment as one of the four hard-abort signals; the poll log records the semantic reasoning for audit.

---

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-09-03 | Initial spec — scopes A/B/C/D/E (SC-1..SC-9, R-1..R-20, Items 1-9). | Developer-directed scope from issue creation. | Developer (issue #2427 authorization) |
| 2026-09-03 | Scope G added (developer-directed revision): new SC-10, R-21, R-22, Item 10; amended §1 Approach row 3, Alternatives row 4, Key Decisions row 5, User Intent row 6; amended NR-7 in §2; added traceability rows R-21/R-22; added Documentation Sources rows (tests-v2/AGENTS.md §10.5/§10.7, behaviors/helpers.sh); added SC-10 cost frame per dark-prose-007; added three scope-G edge cases (abort mid-run, cross-invocation resume limitation, semantic-only abort). Updated sc-summary.yaml sc_count 9→10 with SC-10 entry. | Developer-directed revision reason: "Add a new scope and SC updating the test framework to mandate semantic continuous monitoring of behavioral runs." | Developer (for_pr scope-continuation — per approval-gate, this revision does NOT halt for re-authorization; recorded here and plan regeneration follows) |

---

Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)
