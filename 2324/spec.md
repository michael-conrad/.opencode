---
title: '[SPEC-FIX] executing-plans skill present on disk but not registered in available_skills — blocks for_pr plan-execution gate'
status: open
labels:
- needs-approval
remote_issue: 2324
remote_url: https://github.com/michael-conrad/.opencode/issues/2324
---

> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2324/

## Intent and Executive Summary

- **Problem Statement:** The `executing-plans` skill exists on disk at `.opencode/skills/executing-plans/SKILL.md` (with `tasks/read-plan.md` and `tasks/dispatch-phase.md`) and satisfies every skill-discovery precondition documented by the opencode runtime, yet it is absent from the `<available_skills>` registry presented to agents: the live registry presents 51 entries, but those entries are not the same set as the 51 `SKILL.md` cards under `.opencode/skills/` — the built-in `customize-opencode` skill fills a registry slot while `executing-plans` is the one deck card missing from the registry. The approval-gate skill's Mandatory Routing Rule requires dispatching `executing-plans` under `for_pr` scope before PR creation, so the mandatory plan-execution gate cannot fire for any `for_pr`-scoped work until the runtime surfaces the card.

- **Root Cause / Motivation:** There is no repo-side registration manifest to edit — the `<available_skills>` registry is generated solely by the opencode runtime, which discovers skills by scanning `.opencode/skills/*/SKILL.md` (plus global/compatible locations) at runtime. Exhaustive elimination of the runtime's documented failure causes was performed live this session and all resolve clean: the filename is spelled correctly, the frontmatter carries required `name`/`description` fields, the name matches its directory and passes the documented name pattern, no `permission.skill` deny configuration exists in project or global agent config, no competing definition exists in any other discovery location, and no duplicate skill names or name/directory mismatches exist across the deck. Because every repo-side precondition holds while the single-card omission persists, the remaining defect locus is runtime registry state — a stale process-level snapshot or a runtime scanner defect — not missing repository content. This must be solved now because the `for_pr` pipeline gate is unexecutable until the card resolves at runtime.

- **Approach Chosen:** Diagnose-before-modify, in two branches decided by a fresh-runtime reproduction: run an isolated opencode session through the test harness (`with-test-home`) against the current `.opencode` checkout and observe whether the registry omits the card there too. Branch A — the fresh runtime lists the card: the developer's long-running host process holds a stale snapshot; apply the registry-refresh/remediation step, record the operational resolution, and proceed to load and gate verification. Branch B — the fresh runtime also omits the card: file an evidence-backed defect report against the upstream opencode runtime project per R-4 and report BLOCKED on this issue pending the upstream fix; no workaround is permitted. Either way, completion then verifies `skill({name: "executing-plans"})` loads the card and that the approval-gate `for_pr` routing rule executes against the restored target using the existing `#1364` behavioral scenarios.

- **Alternatives Considered & Why Discarded:**
  - **Add an `executing-plans` entry to a repo-side registration manifest** — Discarded: no such manifest exists; the registry is runtime-generated purely from filesystem scan per the live Agent Skills documentation, so there is no entry to add (this was the defect of the previous spec revision).
  - **Edit the `SKILL.md` frontmatter to trigger re-discovery** — Discarded: the frontmatter already satisfies every documented validation rule, content changes are excluded by scope, and editing valid content does not address a runtime-state cause.
  - **Bypass the gate (route `for_pr` scope directly to PR creation)** — Discarded: direct PR creation without plan execution is classified as a CRITICAL VIOLATION by the approval-gate Mandatory Routing Rule.

- **Key Design Decisions:**
  - **Diagnose-before-modify:** exhaustive precondition elimination precedes any change. Tradeoff: slower start versus preventing the wrong-locus edit the audit flagged as the primary implementability risk.
  - **Isolated-runtime ground truth:** the fresh-runtime reproduction runs through `with-test-home` isolation, separating repository state from long-running host-process state. Tradeoff: harness setup cost versus eliminating stale-session false positives from the diagnosis.
  - **Escalation before workaround:** if Branch B holds, the only permitted action is the upstream defect report — never a gate bypass. Tradeoff: the `for_pr` gate stays blocked longer versus preserving the invariant that plans execute before PRs.

- **User Intent / Original Prompt:** The spec was filed from live-session observation that `executing-plans` is present on disk but absent from `<available_skills>`, blocking the `for_pr` plan-execution gate introduced by issue #1364 (merged PR #2321). It is being revised to remediate the DRAFT verdict from the spec-audit of michael-conrad/.opencode#2324, addressing all eight FAIL dimensions and bidirectional findings.

## Not Included

- **Changes to the `executing-plans` SKILL.md content or task cards** — the frontmatter is verified valid against the documented schema; the card content is not the defect locus.
- **Changes to the approval-gate routing rule text** — the rule text is verified correct and matches intent; only its runtime executability is deficient.
- **Behavioral test authoring** — the existing `#1364` behavioral scenarios already cover the `for_pr` dispatch path; new authoring is tracked separately.
- **Full-skill-deck registration-gap audit** — auditing all 51 cards for registry gaps exceeds this spec's single-skill scope; tracked separately.
- **Source changes to the opencode runtime project** — different repository; a persistent runtime defect is addressed exclusively through the R-4 upstream defect report.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | A fresh isolated opencode runtime session opened against the current `.opencode` checkout presents `executing-plans` in its `<available_skills>` registry. | behavioral | Run `bash .opencode/tests-v2/with-test-home opencode run '<probe>'` where `<probe>` is exactly: `List the skill names present in your available_skills listing. Then invoke skill({name: "executing-plans"}). Report (a) whether executing-plans appeared in the listing and (b) whether the invocation returned card content or a missing-skill error.`; inspect the exported session.yaml (via `.opencode/tools/session-to-timeline`) for the registry content presented to the model. |
| SC-2 | In a fresh runtime session satisfying SC-1, `skill({name: "executing-plans"})` resolves and returns the executing-plans skill card content without a missing-skill error. | behavioral | From the same probe artifacts, inspect the session.yaml skill-tool result part: it MUST contain the card body (identifiable by its Overview heading) rather than a skill-not-found error. |
| SC-3 | With SC-1 and SC-2 restored, an agent operating under `for_pr` authorization scope with an existing approved plan dispatches `executing-plans` before any PR creation, per the approval-gate Mandatory Routing Rule. | behavioral | Execute the existing behavioral scenario `bash .opencode/tests-v2/behaviors/1364-sc1-for-pr-existing-plan-executing-plans.sh` (bash tool timeout >= 600 seconds); a clean-room sub-agent evaluates the produced session.yaml per the two-SC pattern (artifact generation plus independent evaluation). |

Each SC maps to exactly one item in the Items section.

## Requirements

- R-1. The opencode runtime SHALL include `executing-plans` in `<available_skills>` for sessions opened against this repository's `.opencode` checkout.
- R-2. The `skill({name: "executing-plans"})` invocation SHALL return the full executing-plans skill card content without a missing-skill error in any session satisfying R-1.
- R-3. Under `for_pr` authorization scope with an existing approved plan, the approval-gate Mandatory Routing Rule SHALL be executable as written: its mandated `executing-plans` dispatch target MUST resolve at runtime, with zero modifications to the routing rule text.
- R-4. If the fresh-runtime diagnosis establishes that the registry omission persists while every documented discovery precondition holds, the agent SHALL file an evidence-backed defect report against the upstream opencode runtime project — containing the disk state, frontmatter validation results, permission-config absence, competing-definition absence, registry observation, and runtime version — and record the report URL on issue #2324; no workaround is permitted.

## Items

### Item 1 (SC-1): Restore runtime registry inclusion of executing-plans

- RED: Fresh-runtime reproduction via `with-test-home` shows the `<available_skills>` registry omits `executing-plans` while all documented discovery preconditions hold on disk — reproducing the observed live-session state.
- GREEN: Apply the remediation selected by the diagnosis branch. Branch A (fresh runtime lists the card): the long-running host process holds a stale snapshot; perform the registry-refresh remediation (restart the host runtime process), record the operational resolution, and re-run the probe until the entry appears. Branch B (fresh runtime omits the card): execute R-4 — assemble and file the upstream defect report, record its URL on #2324, and report BLOCKED pending upstream.
- verify: session.yaml exported from the probe run shows `executing-plans` among the registry entries presented to the model.
- commit: Diagnostic evidence and the resolution record committed under `.issues/2324/research/`.

### Item 2 (SC-2): skill() load succeeds against the restored registry entry

- RED: In the pre-fix fresh runtime, the probe's `skill({name: "executing-plans"})` invocation fails with a missing-skill error.
- GREEN: After Item 1's remediation, the identical probe invocation resolves and returns the executing-plans card content.
- verify: session.yaml tool-result inspection shows the card body (Overview heading present) instead of an error part.
- commit: Resolution-record update committed under `.issues/2324/research/`.

### Item 3 (SC-3): for_pr routing dispatches executing-plans

- RED: The existing `1364-sc1-for-pr-existing-plan-executing-plans` scenario cannot satisfy its dispatch assertion because its target skill is unavailable at runtime — the current state.
- GREEN: With SC-1 and SC-2 restored, the scenario completes with the agent dispatching `executing-plans` before any PR creation.
- verify: Clean-room sub-agent reads the scenario's session.yaml artifacts and evaluates the dispatch sequence independently per the two-SC pattern; the orchestrator records the verdict.
- commit: Behavioral evidence artifacts preserved under `tmp/behavioral-evidence-*` per retention policy; the evaluation verdict recorded under `.issues/2324/`.

## Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| Issue #1364 / PR #2321 (michael-conrad/.opencode) | Introduced the `for_pr` Mandatory Routing Rule and re-added the skill directory; MUST remain merged for this spec's premise to hold | Satisfied |
| `with-test-home` harness (`.opencode/tests-v2/`) | Required execution environment for the SC-1 and SC-3 probes | Satisfied |
| Existing behavioral scenarios `1364-sc1-for-pr-existing-plan-executing-plans.sh` (and companion `1364-sc2`) | SC-3 verification reuses them unchanged; they MUST exist as merged | Satisfied |
| approval-gate SKILL.md Mandatory Routing Rule | Defines the expected behavior SC-3 verifies | Satisfied |

## Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-2 | Phase 1 |
| R-3 | SC-3 | Phase 2 |
| R-4 | SC-1 (Branch B failure handling) | Phase 1 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| OpenCode Agent Skills documentation | doc | https://opencode.ai/docs/skills/ | Live fetch (2026-08-25): discovery locations (`.opencode/skills/<name>/SKILL.md` et al.), walk-up-to-worktree scan rule, recognized frontmatter fields, name validation pattern, description length rule, permission-based hiding, troubleshooting checklist |
| executing-plans skill card | code | `.opencode/skills/executing-plans/SKILL.md` | Read: frontmatter `name: executing-plans` matches directory name; description present and within the documented length limit; tasks `read-plan.md` and `dispatch-phase.md` present |
| approval-gate skill card | code | `.opencode/skills/approval-gate/SKILL.md`, "Mandatory Routing Rule" section | Read/grep: under `for_pr` scope with an existing plan the agent MUST dispatch `executing-plans` before PR creation |
| `.opencode` README | doc | `.opencode/README.md`, "Skills (`skills/`)" section | Read: describes skills as self-contained modules with YAML frontmatter for self-discovery |
| Project agent config | config | `.opencode/opencode.jsonc` | Read: contains no `permission` block and no skill exclusion entries |
| Global agent config | config | `~/.config/opencode/opencode.jsonc` | Grep: contains no skill or executing-plans references |
| Competing discovery locations | config | `~/.config/opencode/skills/`, `~/.claude/skills/`, `~/.agents/skills/`, parent directories | File-existence checks: none of these locations exist, so no shadowing or duplicate definitions are possible |
| Skilldeck inventory | code | all 51 `SKILL.md` files under `.opencode/skills/` | Automated scan: every card's frontmatter name matches its directory; zero duplicate names; the live registry holds 51 entries whose set differs from the 51-card deck by one swap — built-in `customize-opencode` present, `executing-plans` absent |
| Submodule git history | code | `.opencode` git log for `skills/executing-plans/` | `git log`/`git show`: deletion commit, re-add commit (#1364), merge of PR #2321 |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

Under Branch B, SC-1 cannot pass until the upstream runtime defect is fixed; the spec then reports BLOCKED on issue #2324 with the R-4 report URL — it MUST NOT be closed, partially passed, or worked around.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls.

- **SC-1:** Running the isolated-runtime probe costs one harness setup plus one model round-trip — skipping costs implementing against an unproven defect locus and repeating the wrong-locus edit the audit flagged. Correctness is the only metric.
- **SC-2:** Inspecting the load-result artifacts costs one session.yaml read — skipping costs declaring the gate restorable while the dispatch target still errors, discovered only mid-`for_pr` execution. Correctness is the only metric.
- **SC-3:** Re-running the existing behavioral scenario costs one model run plus one clean-room evaluation — skipping costs trusting that a restored registry entry restores the mandatory gate, leaving silent PR-first bypasses undetected. Correctness is the only metric.

## Edge Cases

- **Failure mode — Branch B (omission persists in fresh runtime):** Condition: the isolated runtime reproduces the omission with all documented preconditions satisfied. Expected behavior: execute R-4 — file the upstream defect report and record it on #2324; make no workaround change. Resolution: when the upstream fix lands, re-run the SC-1 probe and resume the chain.
- **State transition — stale host-process snapshot:** Condition: the fresh runtime lists the card but the developer's long-running session does not. Expected behavior: treat the omission as operational, not repository, state. Resolution: restart the host runtime process; record the operational step in the resolution record; new sessions then scan the deck fresh.
- **Input boundary — future frontmatter regression:** Condition: a later edit breaks name/directory match or description length on any card. Expected behavior: the runtime drops the affected card silently. Resolution: the existing `skildeck lint` skill-deck-completeness category flags such defects; no new work in this spec.
- **Concurrency — deck mutation during probing:** Condition: another session modifies `.opencode/skills/` while probes run. Expected behavior: probe results remain stable. Resolution: the harness clones the checkout at the pinned submodule HEAD into the isolated home, so mid-probe edits cannot contaminate observations.
- **Recovery — partial restoration:** Condition: the registry lists the card but `skill()` load still fails. Expected behavior: Item 2 isolates the load-layer failure. Resolution: capture both probe artifact sets and attach them to the R-4 report to localize the defect for upstream.

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-25 | Removed the false `.opencode/AGENTS.md` "Skill Self-Discovery" citation and replaced the "add a registration entry" approach (no registration manifest exists — registry is runtime-generated by filesystem scan per live docs); resolved the automatic-discovery vs manual-registration contradiction by identifying the actual mechanism and relocating the defect locus to runtime registry state with exhaustive precondition elimination as evidence; defined `<available_skills>` terminology uniformly as the runtime-generated registry; moved the full-skill-deck audit to Not Included; added Requirements, Success Criteria, Items, Dependencies, Traceability, Documentation Sources, Enforcement Gate, Cost Frame, and Edge Cases sections per `spec-structure-standards.md`; preserved the original valid goals (restore availability, verify `skill()` load, verify `for_pr` dispatch) as SC-1..SC-3 | Spec-audit DRAFT verdict on michael-conrad/.opencode#2324 — remediation of HOLISTIC-1/2/3/4/5/7/8/10 FAIL dimensions and their bidirectional findings | Spec-audit verdict remediation directive (revision_reason supplied in the revise task dispatch context)
| 2026-08-26 | Added the missing dark-prose-007 computation-frame preamble line (`Cost is measured in defect-discovery-latency, not tool calls.`) directly under the `## Cost Frame` heading before the per-SC bullets; per-SC bullets, all SCs, and all other sections unchanged | Spec-audit cycle-2 verdict on michael-conrad/.opencode#2324 — sole FAIL criterion SC-13-cost-frame-dark-prose-007: Cost Frame omitted the computation-frame line that cost-model-standards.md §Cost-Frame Formula (dark-prose-007) lists as the first component and §Per-SC Cost-Frame Format places as the section preamble | Spec-audit cycle-2 verdict remediation directive (revision_reason supplied in the revise task dispatch context)
| 2026-08-26 | Reworded the Problem Statement and the Skilldeck inventory Documentation Sources row so the 51-card disk deck and the 51-entry live registry cannot be read as set-equal (live fact: the registry substitutes the built-in `customize-opencode` entry for the omitted `executing-plans` card); rewrote R-4 to end "; no workaround is permitted", deleting the "before applying any workaround" clause that presupposed a permissible post-report workaround against the Approach Chosen / Key Design Decisions / Enforcement Gate no-workaround invariant; replaced SC-1's unspecified `<probe>` placeholder with the exact probe prompt text embedded in its Verification Method cell; normalized the two `available-skills registry` spellings to `<available_skills>` registry (SC-1 criterion cell, Item 1 RED) | Spec-audit cycle-3 verdict on michael-conrad/.opencode#2324 — HOLISTIC-2 Internal Consistency FAIL (two validated contradiction pairs: registry-count arithmetic L14/L109; R-4 workaround-permission conflict vs L18/L28/L116) and HOLISTIC-3 Completeness FAIL (`<probe>` placeholder with no concrete probe prompt anywhere; dual registry spellings despite Change Control asserting uniform definition) | Spec-audit cycle-3 verdict remediation directive (revision_reason supplied in the revise task dispatch context)

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
Co-authored with AI: OpenCode (opencode/x-preview-f-free)
