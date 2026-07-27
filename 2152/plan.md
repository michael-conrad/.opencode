---
plan_schema_version: "1.0"
issue: 2152
title: "Fix Pre-Response Gate and Dispatch-Routing — explicit post-load dispatch step, restart-from-checkpoint, non-programmatic"
dispatch:
  - phase: phase-1
    concern: "Post-load dispatch step (default.txt + AGENTS.md)"
    scs: [SC-1, SC-2, SC-3]
    items:
      - item: item-1
        sc: SC-1
        skill: implementation-pipeline
        task: assemble-work
      - item: item-2
        sc: SC-2
        skill: implementation-pipeline
        task: assemble-work
      - item: item-3
        sc: SC-3
        skill: implementation-pipeline
        task: assemble-work
  - phase: phase-2
    concern: "Poisoned pipeline wording replacement (guideline files)"
    scs: [SC-4, SC-5, SC-6]
    items:
      - item: item-4
        sc: SC-4
        skill: implementation-pipeline
        task: assemble-work
      - item: item-5
        sc: SC-5
        skill: implementation-pipeline
        task: assemble-work
      - item: item-6
        sc: SC-6
        skill: implementation-pipeline
        task: assemble-work
---

# Plan: Fix Pre-Response Gate and Dispatch-Routing

## Pre-Implementation Steps

- [ ] **Coherence gate.** Dispatch `audit --task coherence-extraction` to verify spec/plan coherence before RED routing. Context: `{issue_number: 2152}`. (**sub-agent**)
  - If coherence check fails: remediate and re-run before proceeding.
- [ ] **Baseline check.** Dispatch `implementation-pipeline --task pre-red-baseline` to capture pre-change state of all affected files. Context: `{issue_number: 2152}`. (**sub-agent**)
  - Captures baseline of: `.opencode/prompts/default.txt`, `.opencode/AGENTS.md`, `.opencode/guidelines/000-critical-rules.md`, `.opencode/guidelines/020-go-prohibitions.md`.

---

## Phase 1: Post-load dispatch step (default.txt + AGENTS.md)

**Concern:** Add explicit Step 2.5 to the Pre-Response Gate in both `default.txt` and `AGENTS.md`, and cross-reference it from the Sub-Agent Routing Boundary section.

**SCs covered:** SC-1, SC-2, SC-3

**Dependency:** Phase 1 must complete before Phase 2.

**Intra-phase order:** item-1 (SC-1) → item-3 (SC-3) → item-2 (SC-2). SC-1 creates the Step 2.5 target in default.txt first. SC-3 cross-references that target. SC-2 replicates the same wording to AGENTS.md.

**Evidence type note:** All items in this phase use `string` evidence type (content-verification grep). Steps requiring Z3/solve state verification, behavioral enforcement gates, or behavioral test execution are documented as N/A with justification.

### Item 1 — SC-1: Pre-Response Gate Step 2.5 in default.txt

- [ ] **Pre-red-baseline.** Capture baseline of `.opencode/prompts/default.txt` lines 5-15 (Pre-Response Gate). (**sub-agent**)
  - Context: `{issue_number: 2152, affected_file: .opencode/prompts/default.txt, sc: SC-1}`
- [ ] **Red phase.** Content-verification: grep for absence of "Step 2.5" or "read the loaded SKILL.md's Trigger Dispatch Table" in `.opencode/prompts/default.txt`. (**sub-agent**)
  - Context: `{issue_number: 2152, affected_file: .opencode/prompts/default.txt, sc: SC-1, evidence_type: string}`
  - Assertion: grep pattern `Step 2\.5` returns no match.
- [ ] **z3-check-red.** N/A (string evidence type — content-verification grep is self-verifying; no Z3 state machine verification needed).
- [ ] **red-doublecheck.** N/A (string evidence type — the red-phase grep assertion IS the verification; a separate `verification-before-completion --task verify` dispatch would be redundant for a self-verifying grep assertion).
- [ ] **z3-check-red-doublecheck.** N/A (string evidence type — no Z3 state machine verification needed; same rationale as z3-check-red).
- [ ] **post-red-enforcement.** N/A (string evidence type — post-red-enforcement is a behavioral enforcement test gate; no behavioral tests exist for this change).
- [ ] **z3-check-post-red.** N/A (string evidence type — no Z3 verification needed; same rationale as z3-check-red).
- [ ] **Green phase.** Text insertion: add Step 2.5 to the Pre-Response Gate in `.opencode/prompts/default.txt` after the existing Step 2 (call skill()). Step 2.5 reads: "Read the loaded SKILL.md's Trigger Dispatch Table and Invocation section to determine the correct dispatch string. Then dispatch the task card via task() using that canonical string." (**sub-agent**)
  - Context: `{issue_number: 2152, affected_file: .opencode/prompts/default.txt, sc: SC-1}`
- [ ] **z3-check-green.** N/A (string evidence type — no Z3 state machine verification needed; same rationale as z3-check-red).
- [ ] **post-green-enforcement.** N/A (string evidence type — post-green-enforcement is a behavioral enforcement test gate; no behavioral tests exist for this change).
- [ ] **z3-check-post-green.** N/A (string evidence type — no Z3 verification needed; same rationale as z3-check-red).
- [ ] **Green doublecheck.** Content-verification: grep for presence of "Step 2.5" and "Trigger Dispatch Table" in `.opencode/prompts/default.txt`. (**sub-agent**)
  - Context: `{issue_number: 2152, affected_file: .opencode/prompts/default.txt, sc: SC-1, evidence_type: string}`
  - Assertion: grep pattern `Step 2\.5` returns at least 1 match.
- [ ] **Checkpoint tag create.** Create checkpoint tag: `michael-conrad/checkpoint/2152/phase-1-item-1-opencode`. (**sub-agent**)
  - Context: `{issue_number: 2152, tag: michael-conrad/checkpoint/2152/phase-1-item-1-opencode}`
- [ ] **Checkpoint commit.** Commit the change with message: "SC-1: Add Step 2.5 to Pre-Response Gate in default.txt". (**sub-agent**)
  - Context: `{issue_number: 2152, commit_message: "SC-1: Add Step 2.5 to Pre-Response Gate in default.txt"}`

### Item 3 — SC-3: Sub-Agent Routing Boundary cross-reference

- [ ] **Pre-red-baseline.** Capture baseline of `.opencode/prompts/default.txt` lines 42-58 (Sub-Agent Routing Boundary). (**sub-agent**)
  - Context: `{issue_number: 2152, affected_file: .opencode/prompts/default.txt, sc: SC-3}`
- [ ] **Red phase.** Content-verification: grep for absence of cross-reference to Step 2.5 in the Sub-Agent Routing Boundary section. (**sub-agent**)
  - Context: `{issue_number: 2152, affected_file: .opencode/prompts/default.txt, sc: SC-3, evidence_type: string}`
  - Assertion: grep pattern `Step 2\.5` in lines 42-58 returns no match.
- [ ] **z3-check-red.** N/A (string evidence type — content-verification grep is self-verifying; no Z3 state machine verification needed).
- [ ] **red-doublecheck.** N/A (string evidence type — the red-phase grep assertion IS the verification; redundant for self-verifying grep assertion).
- [ ] **z3-check-red-doublecheck.** N/A (string evidence type — no Z3 state machine verification needed).
- [ ] **post-red-enforcement.** N/A (string evidence type — no behavioral enforcement test gate needed).
- [ ] **z3-check-post-red.** N/A (string evidence type — no Z3 verification needed).
- [ ] **Green phase.** Text insertion: add a cross-reference sentence to the Sub-Agent Routing Boundary section that reads: "The procedure in Step 2.5 above describes how the orchestrator reads the SKILL.md's Trigger Dispatch Table and Invocation section, then dispatches the task card via task()." (**sub-agent**)
  - Context: `{issue_number: 2152, affected_file: .opencode/prompts/default.txt, sc: SC-3}`
- [ ] **z3-check-green.** N/A (string evidence type — no Z3 state machine verification needed).
- [ ] **post-green-enforcement.** N/A (string evidence type — no behavioral enforcement test gate needed).
- [ ] **z3-check-post-green.** N/A (string evidence type — no Z3 verification needed).
- [ ] **Green doublecheck.** Content-verification: grep for presence of cross-reference text in the Sub-Agent Routing Boundary section. (**sub-agent**)
  - Context: `{issue_number: 2152, affected_file: .opencode/prompts/default.txt, sc: SC-3, evidence_type: string}`
  - Assertion: grep pattern `Step 2\.5` in lines 42-58 returns at least 1 match.
- [ ] **Checkpoint tag create.** Create checkpoint tag: `michael-conrad/checkpoint/2152/phase-1-item-3-opencode`. (**sub-agent**)
  - Context: `{issue_number: 2152, tag: michael-conrad/checkpoint/2152/phase-1-item-3-opencode}`
- [ ] **Checkpoint commit.** Commit the change with message: "SC-3: Add cross-reference to Step 2.5 in Sub-Agent Routing Boundary". (**sub-agent**)
  - Context: `{issue_number: 2152, commit_message: "SC-3: Add cross-reference to Step 2.5 in Sub-Agent Routing Boundary"}`

### Item 2 — SC-2: AGENTS.md Universal Skill Dispatch Gate Step 2.5

- [ ] **Pre-red-baseline.** Capture baseline of `.opencode/AGENTS.md` Universal Skill Dispatch Gate (4-step procedure). (**sub-agent**)
  - Context: `{issue_number: 2152, affected_file: .opencode/AGENTS.md, sc: SC-2}`
- [ ] **Red phase.** Content-verification: grep for absence of "Step 2.5" or "read the loaded SKILL.md's Trigger Dispatch Table" in `.opencode/AGENTS.md` Universal Skill Dispatch Gate. (**sub-agent**)
  - Context: `{issue_number: 2152, affected_file: .opencode/AGENTS.md, sc: SC-2, evidence_type: string}`
  - Assertion: grep pattern `Step 2\.5` returns no match.
- [ ] **z3-check-red.** N/A (string evidence type — content-verification grep is self-verifying; no Z3 state machine verification needed).
- [ ] **red-doublecheck.** N/A (string evidence type — the red-phase grep assertion IS the verification; redundant for self-verifying grep assertion).
- [ ] **z3-check-red-doublecheck.** N/A (string evidence type — no Z3 state machine verification needed).
- [ ] **post-red-enforcement.** N/A (string evidence type — no behavioral enforcement test gate needed).
- [ ] **z3-check-post-red.** N/A (string evidence type — no Z3 verification needed).
- [ ] **Green phase.** Text insertion: add parallel Step 2.5 to the AGENTS.md Universal Skill Dispatch Gate, matching the wording from SC-1. (**sub-agent**)
  - Context: `{issue_number: 2152, affected_file: .opencode/AGENTS.md, sc: SC-2}`
- [ ] **z3-check-green.** N/A (string evidence type — no Z3 state machine verification needed).
- [ ] **post-green-enforcement.** N/A (string evidence type — no behavioral enforcement test gate needed).
- [ ] **z3-check-post-green.** N/A (string evidence type — no Z3 verification needed).
- [ ] **Green doublecheck.** Content-verification: grep for presence of "Step 2.5" and "Trigger Dispatch Table" in `.opencode/AGENTS.md` Universal Skill Dispatch Gate. (**sub-agent**)
  - Context: `{issue_number: 2152, affected_file: .opencode/AGENTS.md, sc: SC-2, evidence_type: string}`
  - Assertion: grep pattern `Step 2\.5` returns at least 1 match.
- [ ] **Checkpoint tag create.** Create checkpoint tag: `michael-conrad/checkpoint/2152/phase-1-item-2-opencode`. (**sub-agent**)
  - Context: `{issue_number: 2152, tag: michael-conrad/checkpoint/2152/phase-1-item-2-opencode}`
- [ ] **Checkpoint commit.** Commit the change with message: "SC-2: Add Step 2.5 to AGENTS.md Universal Skill Dispatch Gate". (**sub-agent**)
  - Context: `{issue_number: 2152, commit_message: "SC-2: Add Step 2.5 to AGENTS.md Universal Skill Dispatch Gate"}`

### Phase 1 checkpoint

- [ ] **Phase checkpoint tag.** Create aggregate checkpoint tag: `michael-conrad/checkpoint/2152/phase-1-opencode`. (**sub-agent**)
  - Context: `{issue_number: 2152, tag: michael-conrad/checkpoint/2152/phase-1-opencode}`

---

## Phase 2: Poisoned pipeline wording replacement (guideline files)

**Concern:** Replace "poisoned pipeline" metaphor with procedure language, correct restart target, and downgrade tier.

**SCs covered:** SC-4, SC-5, SC-6

**Dependency:** Phase 2 depends on Phase 1 (prompt changes first, then guideline changes).

**Intra-phase order:** item-4 (SC-4) → item-5 (SC-5) → item-6 (SC-6). SC-4 replaces the metaphor text first. SC-5 corrects the restart target in the same sections. SC-6 changes tier classification in the same sections.

**Evidence type note:** All items in this phase use `string` evidence type (content-verification grep). Steps requiring Z3/solve state verification, behavioral enforcement gates, or behavioral test execution are documented as N/A with justification.

### Item 4 — SC-4: Replace "poisoned pipeline" with procedure language

- [ ] **Pre-red-baseline.** Capture baseline of `.opencode/guidelines/000-critical-rules.md` (critical-rules-034) and `.opencode/guidelines/020-go-prohibitions.md` (§1.2, lines 222, 503-534). (**sub-agent**)
  - Context: `{issue_number: 2152, affected_files: [.opencode/guidelines/000-critical-rules.md, .opencode/guidelines/020-go-prohibitions.md], sc: SC-4}`
- [ ] **Red phase.** Content-verification: grep for presence of "poisoned pipeline" in both guideline files. (**sub-agent**)
  - Context: `{issue_number: 2152, affected_files: [.opencode/guidelines/000-critical-rules.md, .opencode/guidelines/020-go-prohibitions.md], sc: SC-4, evidence_type: string}`
  - Assertion: grep pattern `poisoned pipeline` returns at least 1 match in each file.
- [ ] **z3-check-red.** N/A (string evidence type — content-verification grep is self-verifying; no Z3 state machine verification needed).
- [ ] **red-doublecheck.** N/A (string evidence type — the red-phase grep assertion IS the verification; redundant for self-verifying grep assertion).
- [ ] **z3-check-red-doublecheck.** N/A (string evidence type — no Z3 state machine verification needed).
- [ ] **post-red-enforcement.** N/A (string evidence type — no behavioral enforcement test gate needed).
- [ ] **z3-check-post-red.** N/A (string evidence type — no Z3 verification needed).
- [ ] **Green phase.** Text replacement: replace all "poisoned pipeline" text with procedure language: "Orchestrator inline work detected → HALT. Discard pipeline execution state. Published artifacts edited in place. Restart from last known good commit checkpoint tag per Checkpoint Rollback Exception. Non-waivable." Apply to both `000-critical-rules.md` and `020-go-prohibitions.md`. (**sub-agent**)
  - Context: `{issue_number: 2152, affected_files: [.opencode/guidelines/000-critical-rules.md, .opencode/guidelines/020-go-prohibitions.md], sc: SC-4}`
- [ ] **z3-check-green.** N/A (string evidence type — no Z3 state machine verification needed).
- [ ] **post-green-enforcement.** N/A (string evidence type — no behavioral enforcement test gate needed).
- [ ] **z3-check-post-green.** N/A (string evidence type — no Z3 verification needed).
- [ ] **Green doublecheck.** Content-verification: grep for absence of "poisoned pipeline" and presence of procedure language in both files. (**sub-agent**)
  - Context: `{issue_number: 2152, affected_files: [.opencode/guidelines/000-critical-rules.md, .opencode/guidelines/020-go-prohibitions.md], sc: SC-4, evidence_type: string}`
  - Assertion: grep pattern `poisoned pipeline` returns no match; grep pattern `last known good commit checkpoint tag` returns at least 1 match per file.
- [ ] **Checkpoint tag create.** Create checkpoint tag: `michael-conrad/checkpoint/2152/phase-2-item-4-opencode`. (**sub-agent**)
  - Context: `{issue_number: 2152, tag: michael-conrad/checkpoint/2152/phase-2-item-4-opencode}`
- [ ] **Checkpoint commit.** Commit the change with message: "SC-4: Replace 'poisoned pipeline' with procedure language in guidelines". (**sub-agent**)
  - Context: `{issue_number: 2152, commit_message: "SC-4: Replace 'poisoned pipeline' with procedure language in guidelines"}`

### Item 5 — SC-5: Correct restart target

- [ ] **Pre-red-baseline.** Capture baseline of `.opencode/guidelines/020-go-prohibitions.md` restart target references. (**sub-agent**)
  - Context: `{issue_number: 2152, affected_file: .opencode/guidelines/020-go-prohibitions.md, sc: SC-5}`
- [ ] **Red phase.** Content-verification: grep for "verify-authorization" in restart context in `.opencode/guidelines/020-go-prohibitions.md`. (**sub-agent**)
  - Context: `{issue_number: 2152, affected_file: .opencode/guidelines/020-go-prohibitions.md, sc: SC-5, evidence_type: string}`
  - Assertion: grep pattern `verify-authorization` in restart context returns at least 1 match.
- [ ] **z3-check-red.** N/A (string evidence type — content-verification grep is self-verifying; no Z3 state machine verification needed).
- [ ] **red-doublecheck.** N/A (string evidence type — the red-phase grep assertion IS the verification; redundant for self-verifying grep assertion).
- [ ] **z3-check-red-doublecheck.** N/A (string evidence type — no Z3 state machine verification needed).
- [ ] **post-red-enforcement.** N/A (string evidence type — no behavioral enforcement test gate needed).
- [ ] **z3-check-post-red.** N/A (string evidence type — no Z3 verification needed).
- [ ] **Green phase.** Text replacement: replace "verify-authorization" with "last known good commit checkpoint tag" in all restart target references in `.opencode/guidelines/020-go-prohibitions.md`. (**sub-agent**)
  - Context: `{issue_number: 2152, affected_file: .opencode/guidelines/020-go-prohibitions.md, sc: SC-5}`
- [ ] **z3-check-green.** N/A (string evidence type — no Z3 state machine verification needed).
- [ ] **post-green-enforcement.** N/A (string evidence type — no behavioral enforcement test gate needed).
- [ ] **z3-check-post-green.** N/A (string evidence type — no Z3 verification needed).
- [ ] **Green doublecheck.** Content-verification: grep for "last known good commit checkpoint tag" in `.opencode/guidelines/020-go-prohibitions.md`. (**sub-agent**)
  - Context: `{issue_number: 2152, affected_file: .opencode/guidelines/020-go-prohibitions.md, sc: SC-5, evidence_type: string}`
  - Assertion: grep pattern `last known good commit checkpoint tag` returns at least 1 match.
- [ ] **Checkpoint tag create.** Create checkpoint tag: `michael-conrad/checkpoint/2152/phase-2-item-5-opencode`. (**sub-agent**)
  - Context: `{issue_number: 2152, tag: michael-conrad/checkpoint/2152/phase-2-item-5-opencode}`
- [ ] **Checkpoint commit.** Commit the change with message: "SC-5: Correct restart target from verify-authorization to checkpoint tag". (**sub-agent**)
  - Context: `{issue_number: 2152, commit_message: "SC-5: Correct restart target from verify-authorization to checkpoint tag"}`

### Item 6 — SC-6: Tier downgrade from Tier 1 to Tier 2

- [ ] **Pre-red-baseline.** Capture baseline of `critical-rules-034` section in `.opencode/guidelines/000-critical-rules.md` and corresponding section in `.opencode/guidelines/020-go-prohibitions.md`. (**sub-agent**)
  - Context: `{issue_number: 2152, affected_files: [.opencode/guidelines/000-critical-rules.md, .opencode/guidelines/020-go-prohibitions.md], sc: SC-6}`
- [ ] **Red phase.** Content-verification: grep for "CRITICAL VIOLATION" header on critical-rules-034 in both files. (**sub-agent**)
  - Context: `{issue_number: 2152, affected_files: [.opencode/guidelines/000-critical-rules.md, .opencode/guidelines/020-go-prohibitions.md], sc: SC-6, evidence_type: string}`
  - Assertion: grep pattern `CRITICAL VIOLATION.*critical-rules-034` returns at least 1 match.
- [ ] **z3-check-red.** N/A (string evidence type — content-verification grep is self-verifying; no Z3 state machine verification needed).
- [ ] **red-doublecheck.** N/A (string evidence type — the red-phase grep assertion IS the verification; redundant for self-verifying grep assertion).
- [ ] **z3-check-red-doublecheck.** N/A (string evidence type — no Z3 state machine verification needed).
- [ ] **post-red-enforcement.** N/A (string evidence type — no behavioral enforcement test gate needed).
- [ ] **z3-check-post-red.** N/A (string evidence type — no Z3 verification needed).
- [ ] **Green phase.** Text replacement: remove "CRITICAL VIOLATION" header from critical-rules-034 entries, add Tier 2 classification with justification: "cannot be mechanically enforced". Apply to both files. (**sub-agent**)
  - Context: `{issue_number: 2152, affected_files: [.opencode/guidelines/000-critical-rules.md, .opencode/guidelines/020-go-prohibitions.md], sc: SC-6}`
- [ ] **z3-check-green.** N/A (string evidence type — no Z3 state machine verification needed).
- [ ] **post-green-enforcement.** N/A (string evidence type — no behavioral enforcement test gate needed).
- [ ] **z3-check-post-green.** N/A (string evidence type — no Z3 verification needed).
- [ ] **Green doublecheck.** Content-verification: grep for "cannot be mechanically enforced" and absence of "CRITICAL VIOLATION" header on critical-rules-034 in both files. (**sub-agent**)
  - Context: `{issue_number: 2152, affected_files: [.opencode/guidelines/000-critical-rules.md, .opencode/guidelines/020-go-prohibitions.md], sc: SC-6, evidence_type: string}`
  - Assertion: grep pattern `cannot be mechanically enforced` returns at least 1 match per file; grep pattern `CRITICAL VIOLATION.*critical-rules-034` returns no match.
- [ ] **Checkpoint tag create.** Create checkpoint tag: `michael-conrad/checkpoint/2152/phase-2-item-6-opencode`. (**sub-agent**)
  - Context: `{issue_number: 2152, tag: michael-conrad/checkpoint/2152/phase-2-item-6-opencode}`
- [ ] **Checkpoint commit.** Commit the change with message: "SC-6: Downgrade orchestrator-inline-work rule from Tier 1 to Tier 2". (**sub-agent**)
  - Context: `{issue_number: 2152, commit_message: "SC-6: Downgrade orchestrator-inline-work rule from Tier 1 to Tier 2"}`

### Phase 2 checkpoint

- [ ] **Phase checkpoint tag.** Create aggregate checkpoint tag: `michael-conrad/checkpoint/2152/phase-2-opencode`. (**sub-agent**)
  - Context: `{issue_number: 2152, tag: michael-conrad/checkpoint/2152/phase-2-opencode}`

---

## Post-Implementation Steps

- [ ] **SC-7: Structural verification — no programmatic enforcement changes.** Confirm no new files in `.opencode/plugins/`, `.opencode/hooks/`, or `.opencode/tools/`; confirm no new enforcement code in diffs. (**inline**)
  - Context: `{issue_number: 2152, sc: SC-7, evidence_type: structural}`
  - Run: `ls .opencode/plugins/ .opencode/hooks/ .opencode/tools/` and compare against baseline.
  - Run: `git diff --stat` to confirm no new enforcement-related files.
- [ ] **Regression check.** N/A (string/structural evidence type — all changes are text-only content-verification; no behavioral tests exist to regress against).
- [ ] **Behavioral test remediation.** N/A (string/structural evidence type — no behavioral tests are involved in this plan; all SCs use string or structural evidence).
- [ ] **Structural checks.** Dispatch `finishing-a-development-branch --task checklist` for lint/typecheck on all modified files. (**sub-agent**)
  - Context: `{issue_number: 2152}`
- [ ] **Green VbC.** Dispatch `verification-before-completion --task completion` to produce SC verdicts with evidence artifacts. (**sub-agent**)
  - Context: `{issue_number: 2152}`
- [ ] **SC count gate.** Dispatch `implementation-pipeline --task sc-count-gate` to verify all 7 SCs have verdicts. (**sub-agent**)
  - Context: `{issue_number: 2152}`
- [ ] **Pre-PR gate.** Dispatch `verification-before-completion --task verify` to read all SC verdicts and BLOCK if any FAIL. (**sub-agent**)
  - Context: `{issue_number: 2152}`
- [ ] **Audit.** Dispatch `audit --task verification-audit` for adversarial review of all changes. (**sub-agent**)
  - Context: `{issue_number: 2152, spec_local_dir: .opencode/.issues/2152, artifact_evidence_dir: tmp/2152/artifacts}`
  - If non-clean-pass: remediate root cause, then re-run audit.
- [ ] **Cross-validate.** Dispatch `audit --task cross-validate` for consensus check. (**sub-agent**)
  - Context: `{issue_number: 2152}`
- [ ] **Review prep.** Dispatch `git-workflow --task review-prep` to prepare PR review context. (**sub-agent**)
  - Context: `{issue_number: 2152}`
- [ ] **Create PR.** Dispatch `pr-creation-workflow --task create` to create the pull request. (**sub-agent**)
  - Context: `{issue_number: 2152, authorization_scope: for_pr, halt_at: pr_created}`
- [ ] **Executive summary.** Dispatch `completion-core --task completion` for final summary. (**sub-agent**)
  - Context: `{issue_number: 2152}`

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-07-27T18:38:00Z | `plan_created` | Plan file: `.opencode/.issues/2152/plan.md`, Phases: 2 (Phase 1: Post-load dispatch step, Phase 2: Poisoned pipeline wording replacement), Items: 6, SCs: 7 |
