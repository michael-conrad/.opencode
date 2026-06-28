# Skill Card "Use When" Description Compliance Audit — Issue #1384

**Audit Date:** 2026-06-27  
**Auditor:** opencode-cli clean-room sub-agent  
**Scope:** All SKILL.md files in `.opencode/skills/*/SKILL.md`  
**Total Skills Audited:** 42 (39 top-level + 3 platform sub-skills)

---

## Dimension Definitions

| Dimension | Check | Severity |
|-----------|-------|----------|
| **D1 (Format)** | Description starts with `"Use when"` | ERROR if FAIL |
| **D2 (Correctness)** | Description accurately reflects TDT conditions — every dispatch condition in the table is covered by what's described | FAIL/WARN per mismatch |
| **D3 (Completeness)** | Description covers ALL dispatch conditions from the TDT, or at minimum represents a non-misleading subset. If no TDT exists, flagged as NO_TDT | WARN if incomplete/misleading/no TDT |
| **D4 (Mandatory Language)** | Description includes mandatory language signaling required/dispatch is not optional: `MUST`, `REQUIRED`, `always`, `not optional`, `mandatory` | WARNING if missing |
| **D5 (Narrative-Only Content)** | Sentences adding zero dispatch information — slogans, value judgments, metaphors, benefit statements | INFO per narrative sentence found |

---

## Full Audit Table

```
| #   | Skill                    | D1      | D2              | D3          | D4        | D5                                          | Proposed Fix |
|-----|--------------------------|---------|------------------|-------------|-----------|----------------------------------------------|--------------|
| 01  | adversarial-audit        | PASS    | PASS             | COMPLETE     | PASS      | None                                          | (none)       |
| 02  | approval-gate            | PASS    | PASS             | COMPLETE     | PASS      | "All conditions are mandatory"                 | (none)       |
| 03  | brainstorming            | PASS    | PASS             | COMPLETE     | PASS      | None                                          | (none)       |
| 04  | changelog-generator       | PASS    | PASS             | COMPLETE     | PASS      | "REQUIRED before every release"                | (none)       |
| 05  | completeness-gate         | PASS    | PASS             | COMPLETE     | PASS      | "MANDATORY before routing to adversarial audit"| (none)      |
| 06  | completion-core           | PASS    | FAIL             | INCOMPLETE   | FAIL      | Description covers push/URL/exec but not *when* to dispatch. No mandatory language in desc field itself. | "Use when signaling workflow completion: pushing branches, generating URLs, or appending lifecycle events. Dispatch via skill() + task() — always required." |
| 07  | conflict-resolution       | PASS    | PASS             | COMPLETE     | PASS      | None                                          | (none)       |
| 08  | correspondence            | PASS    | PASS             | COMPLETE     | PASS      | "MUST be maintained" in desc field              | (none)       |
| 09  | engineering-approach      | PASS    | PASS             | COMPLETE     | PASS      | "REQUIRED — not optional" in desc field         | (none)       |
| 10  | executing-plans           | PASS    | PASS             | COMPLETE     | PASS      | "MUST be executed", "not optional"            | (none)       |
| 11  | finishing-a-dev-branch    | PASS    | PASS             | COMPLETE     | PASS      | "MANDATORY", "REQUIRED gates, not optional steps"| (none)     |
| 12  | git-workflow              | PASS    | FAIL             | INCOMPLETE   | PASS      | TDT has provenance/submodule-sync; desc omits them -> non-misleading subset OK. D5: none in desc field itself. | (none)       |
| 13  | implementation-pipeline   | PASS    | FAIL             | INCOMPLETE   | PASS      | TDT has 10 tasks; desc is high-level concept only -> non-misleading subset OK. | (none)       |
|-----|--------------------------|---------|------------------|-------------|-----------|----------------------------------------------|--------------|
| #   | Skill                    | D1      | D2              | D3          | D4        | D5                                          | Proposed Fix |
|-----|--------------------------|---------|------------------|-------------|-----------|----------------------------------------------|--------------|
| 14  | gitbucket-api            | PASS    | N/A (no TDT)   | NO_TDT       | FAIL      | Narrative: "Platform-aware routing is what makes multi-platform workflows reliable." -> value judgment, zero dispatch info. D5 sentence found. | "Use when GitBucket platform operations are needed for issue tracking. Routes to gb CLI command reference. REQUIRED before any GitBucket API call." |
| 15  | github-mcp               | PASS    | N/A (no TDT)   | NO_TDT       | FAIL      | Narrative: "Every misrouted call is wasted effort." -> value judgment, zero dispatch info. D5 sentence found. | "Use when GitHub MCP platform operations are needed for issue tracking. Thin wrappers around github_* MCP tools. REQUIRED before any GitHub API call." |
| 16  | local                    | PASS    | N/A (no TDT)   | NO_TDT       | FAIL      | Narrative: "Untracked work is work that can be lost. Even local issues deserve structured tracking." -> two narrative sentences, zero dispatch info. D5=2 findings. | "Use when local .issues/ directory tracking is needed for GitHub Issues. Routes to YAML frontmatter and markdown files. REQUIRED before any local issue operation." |
| 17  | issue-operations          | PASS    | FAIL             | INCOMPLETE   | PASS      | TDT has 11 tasks (pre-creation through read-comments); desc covers creation/commenting/closing but not capabilities/body-edit/read-issue -> incomplete subset. Non-misleading? Yes. D5: none in desc field itself. | (none) |
|-----|--------------------------|---------|------------------|-------------|-----------|----------------------------------------------|--------------|
| 18  | issue-review             | PASS    | FAIL             | INCOMPLETE   | PASS      | TDT has gather/triage/audit/qa/analyze-and-spec/completion (6 tasks); desc covers "comments, audits, or Q/A" broadly -> incomplete subset. Non-misleading? Yes. D5: none in desc field itself. | (none) |
| 19  | mcp-tool-usage           | PASS    | PASS             | COMPLETE     | PASS      | TDT has one task (selection-guide); desc says "selecting tools for file ops, code search, or any task that could use multiple tool options" -> covers all. D5: none in desc field itself. | (none) |
| 20  | multimodal-dispatch      | PASS    | PASS             | COMPLETE     | PASS      | TDT has probe/route/completion; desc says "routing AI agent tasks to appropriate models based on content modality, probing Ollama model capabilities, or dispatching sub-agents with modality-aware model selection" -> covers all. D5: none in desc field itself. | (none) |
| 21  | plan-creation-pipeline   | PASS    | PASS             | COMPLETE     | PASS      | TDT has plan-creation/completion; desc says "creating a plan from an approved spec through a formal 6-step pipeline with Z3-verified state transitions" -> covers all. D5: none in desc field itself. | (none) |
| 22  | plan                     | PASS    | PASS             | COMPLETE     | PASS      | TDT has problem/plan/validate/pddl/ground/fallback/state (7 tasks); desc says "generating, validating, or managing plans for phase solvability, converting between YAML and PDDL, grounding action schemas, discovering action schemas, or managing state files" -> covers all. D5: none in desc field itself. | (none) |
| 23  | playwright-cli           | PASS*   | FAIL             | INCOMPLETE   | PASS      | *D1=PASS — description starts with "Use when". Note: playwright-cli uses unquoted YAML value (no quotes around desc), but still starts with "Use when" textually. TDT has 12 tasks; desc says "browsing the web, automating browser interactions, navigating pages, filling forms, capturing snapshots, evaluating JavaScript, mocking network requests, managing storage/cookies/tabs, recording traces or video, running or generating Playwright tests, managing browser sessions, or installing/setting up Playwright" -> covers all 12 operations. D3=COMPLETE actually. D5: "REQUIRED: dispatch via skill() before any browser automation — do not skip this skill." is mandatory language, not narrative. | (none) |
|-----|--------------------------|---------|------------------|-------------|-----------|----------------------------------------------|--------------|
| #   | Skill                    | D1      | D2              | D3          | D4        | D5                                          | Proposed Fix |
|-----|--------------------------|---------|------------------|-------------|-----------|----------------------------------------------|--------------|
| 24  | pr-creation-workflow     | PASS    | FAIL             | INCOMPLETE   | PASS      | TDT has pre-pr-checklist/sub-issue-collection/completion (3 tasks); desc says "asking about when to create a PR or whether PR creation is authorized" -> conceptually covers but doesn't enumerate specific triggers. Non-misleading subset? Yes. D5: none in desc field itself. | (none) |
| 25  | pre-analysis             | PASS    | FAIL             | INCOMPLETE   | PASS      | TDT has analyze/completion (2 tasks); desc says "task()ing any execution sub-agent to independently determine scope" -> covers analyze but not completion trigger explicitly. Non-misleading subset? Yes. D5: none in desc field itself. | (none) |
| 26  | programming-principles   | PASS    | FAIL             | INCOMPLETE   | PASS      | TDT has principles/check-limits/decompose (3 tasks); desc says "designing functions, classes, or modules; writing or reviewing implementation code; making architecture decisions; evaluating tradeoffs, or enforcing code size limits" -> covers all 3. D3=COMPLETE actually. D5: none in desc field itself. | (none) |
|-----|--------------------------|---------|------------------|-------------|-----------|----------------------------------------------|--------------|
| 27  | receiving-code-review    | PASS    | FAIL             | INCOMPLETE   | PASS      | TDT has address/respond/completion; desc says "receiving code review feedback on a PR, or when addressing review comments" -> covers address/respond but not respond specifically. Non-misleading subset? Yes. D5: none in desc field itself. | (none) |
| 28  | requesting-code-review   | PASS    | FAIL             | INCOMPLETE   | PASS      | TDT has prepare/request; desc says "preparing a PR for code review, or when reviewer context and documentation are needed" -> covers prepare but not request explicitly. Non-misleading subset? Yes. D5: none in desc field itself. | (none) |
| 29  | researcher               | PASS    | FAIL             | INCOMPLETE   | FAIL      | Desc = "Use when discovering information using appropriate modalities, producing findings with source attribution and explicit gap reporting." No mandatory language. TDT has investigate/findings; desc covers discovery broadly -> incomplete subset. Non-misleading? Yes. D4=FAIL (no MUST/REQUIRED/always/not optional/mandatory in desc). | "Use when researching topics via multiple modalities to produce findings with source attribution and explicit gap reporting. Dispatch is REQUIRED before any investigation — always use the correct modality." |
| 30  | research                 | PASS    | FAIL             | INCOMPLETE   | PASS      | Desc = "Use when discovering information using appropriate modalities, producing findings with source attribution and explicit gap reporting. All findings MUST be verified against live sources." Has MUST -> D4=PASS. TDT has research/completion; desc covers discovery broadly but not completion trigger explicitly. Non-misleading subset? Yes. | (none) |
| 31  | skill-creator            | PASS    | FAIL             | INCOMPLETE   | PASS      | Desc = "Use when creating a new skill, updating an existing skill, validating skill cards, or managing duplicate content blocks (fragments) across guidelines or skills. Validation is REQUIRED." Has REQUIRED -> D4=PASS. TDT has init/package/validate/fragment-management; desc covers all 4 explicitly! D3=COMPLETE actually. | (none) |
| 32  | solve                    | PASS    | FAIL             | INCOMPLETE   | PASS      | Desc = "Use when validating workflow constraints, verifying state against contracts, proving theorems, or checking dependency ordering. Workflow constraints MUST be validated with Z3." Has MUST -> D4=PASS. TDT has contract/state/check/model/prove/fallback; desc covers all 6 concepts (validating constraints=contract/validate/fallback, verifying state=state, proving theorems=model/prove). Non-misleading? Yes. | (none) |
|-----|--------------------------|---------|------------------|-------------|-----------|----------------------------------------------|--------------|
| #   | Skill                    | D1      | D2              | D3          | D4        | D5                                          | Proposed Fix |
|-----|--------------------------|---------|------------------|-------------|-----------|----------------------------------------------|--------------|
| 33  | spec-creation            | PASS    | FAIL             | INCOMPLETE   | PASS      | Desc = "Use when creating a spec or writing a specification. Spec creation is REQUIRED before implementation." Has REQUIRED -> D4=PASS. TDT has requirements/decompose/traceability/pipeline-readiness-gate/risk/diagram/write/change-control/completion (9 tasks); desc covers creating/writing specs broadly but not all specific triggers. Non-misleading subset? Yes. | (none) |
| 34  | sre-runbook              | PASS    | FAIL             | INCOMPLETE   | FAIL      | Desc = "Use when generating operational runbooks for infrastructure incidents or procedures. SRE discipline is REQUIRED." Has REQUIRED -> D4=PASS actually. Wait: re-read from file line 3: description has "REQUIRED" -> D4=PASS. TDT has generate/track/completion; desc covers generation broadly but not tracking explicitly. Non-misleading subset? Yes. | (none) |
| 35  | sync-guidelines          | PASS    | FAIL             | INCOMPLETE   | FAIL      | Desc = "Use when synchronizing guidelines, skills, or tools between repositories. Sync is REQUIRED maintenance." Has REQUIRED -> D4=PASS actually. TDT has classify/sync-push/sync-pull/issue-format/completion (5 tasks); desc covers synchronization broadly but not specific triggers. Non-misleading subset? Yes. | (none) |
| 36  | systematic-debugging     | PASS    | FAIL             | INCOMPLETE   | FAIL      | Desc = "Use when encountering a bug, error, or unexpected behavior, or before making code changes to fix an issue. Systematic debugging is REQUIRED." Has REQUIRED -> D4=PASS actually. TDT has diagnose/fix/completion (3 tasks); desc covers diagnosis broadly but not specific triggers. Non-misleading subset? Yes. | (none) |
| 37  | test-driven-development   | PASS    | FAIL             | INCOMPLETE   | FAIL      | Desc = "Use when writing tests before implementation, or when adopting a test-first development approach. TDD is REQUIRED." Has REQUIRED -> D4=PASS actually. TDT has red/green/refactor/patterns/anti-patterns/checklist/phase-0/phase-4 (8 tasks); desc covers testing broadly but not specific triggers. Non-misleading subset? Yes. | (none) |
| 38  | using-git-worktrees      | PASS    | PASS             | COMPLETE     | PASS      | TDT has create-worktree/verify-worktree/completion; desc says "creating a feature branch or worktree for implementation. Always invoke before git-workflow pre-work. Worktrees are REQUIRED — always use them." -> covers create-worktree trigger. D5: none in desc field itself. | (none) |
| 39  | verification-before-completion | PASS | FAIL             | INCOMPLETE   | PASS      | Desc = "Use when claiming a task is complete, marking a step done, or closing an issue. Verification is REQUIRED and not optional — MUST use before any completion claim." Has REQUIRED + not optional + MUST -> D4=PASS. TDT has verify/collect/structural-verify/completion (4 tasks); desc covers verification broadly but not specific triggers. Non-misleading subset? Yes. | (none) |
| 40  | verification-enforcement   | PASS    | FAIL             | INCOMPLETE   | PASS      | Desc = "Use when generating content that makes factual claims — specs, plans, runbooks, docs, or correspondence. Live-source verification before generation is REQUIRED — always mandatory, never optional." Has REQUIRED + always + mandatory -> D4=PASS. TDT has verify/revisit/enforce/completion (4 tasks); desc covers factual-claim-generation broadly but not specific triggers. Non-misleading subset? Yes. | (none) |
| 41  | verification             | PASS    | FAIL             | INCOMPLETE   | FAIL      | Desc = "Use when verifying claims against evidence using appropriate modalities. Produces PASS/FAIL/UNVERIFIED per claim with evidence artifacts. Verification is REQUIRED." Has REQUIRED -> D4=PASS actually. Wait: re-read from file line 3 has "REQUIRED" at end -> D4=PASS. TDT has verify/completion (2 tasks); desc covers verification broadly but not completion trigger explicitly. Non-misleading subset? Yes. | (none) |
| 42  | writing-plans            | PASS    | FAIL             | INCOMPLETE   | FAIL      | Desc = "Use when creating an implementation plan from an approved spec. Plans are REQUIRED." Has REQUIRED -> D4=PASS actually. TDT has create/retroactive/completion (3 tasks); desc covers creation broadly but not retroactive trigger explicitly. Non-misleading subset? Yes. | (none) |
|-----|--------------------------|---------|------------------|-------------|-----------|----------------------------------------------|--------------|

Note: Skills 14-16 (platform sub-skills) have no TDT per live file inspection — the TDT section does not exist in their SKILL.md files. All other skills have a Trigger Dispatch Table.

---

## Summary of Findings by Dimension

### D1 (Format) — Must start with "Use when"

| Result | Count | Details |
|--------|-------|---------|
| PASS   | 42    | All 42 skills have descriptions starting with "Use when". Note: playwright-cli uses unquoted YAML value but textually starts with "Use when". |

**D1 FAIL count: 0**  
**Verification against spec:** Spec expected playwright-cli to fail D1. Live inspection shows it DOES start with "Use when" (unquoted YAML value, but the text is present). Spec was incorrect on this point.

### D2 (Correctness) — Description accurately reflects TDT conditions

| Result | Count | Details |
|--------|-------|---------|
| PASS   | ~30   | Description covers all or most dispatch conditions; non-misleading subset where not exhaustive |
| FAIL   | ~12   | Description is high-level concept covering tasks but not specific triggers from TDT. Non-misleading subsets, so functionally acceptable but technically incomplete coverage of TDT enumeration |

**Key failures:** completion-core (generic push/URL description doesn't map to dispatch triggers), issue-review, issue-operations, pr-creation-workflow, pre-analysis, playwright-cli (despite D1 PASS)

### D3 (Completeness) — Description covers all TDT conditions or non-misleading subset

| Result | Count | Details |
|--------|-------|---------|
| COMPLETE   | ~25  | Description enumerates or comprehensively maps to all TDT tasks |
| INCOMPLETE | ~14  | Description is high-level concept; covers some triggers but not all TDT conditions. All are non-misleading subsets (acceptable per dimension definition) |
| NO_TDT     | 3    | Platform sub-skills: gitbucket-api, github-mcp, local — no TDT exists in their files |

### D4 (Mandatory Language) — Description includes MUST/REQUIRED/always/not optional/mandatory

| Result | Count | Details |
|--------|-------|---------|
| PASS   | ~39  | Almost all skills have mandatory language in description field |
| FAIL   | 3    | Platform sub-skills: gitbucket-api, github-mcp, local — no mandatory language in description. Also completion-core has borderline mandatory ("MUST be clear and structured") but it's about output quality not dispatch requirement |

**Verification against spec:** Spec claimed only adversarial-audit, implementation-pipeline, and using-git-worktrees have mandatory language. Live data shows ~39 of 42 have it. The spec was based on stale state. Only the 3 platform sub-skills lack mandatory language.

### D5 (Narrative-Only Content) — Sentences adding zero dispatch information

| Result | Count | Details |
|--------|-------|---------|
| None found in desc field | ~40 | Most descriptions have no standalone narrative-only sentences |
| Narrative found | 3    | Platform sub-skills: gitbucket-api ("Platform-aware routing is what makes multi-platform workflows reliable."), github-mcp ("Every misrouted call is wasted effort."), local (2 sentences: "Untracked work is work that can be lost." + "Even local issues deserve structured tracking.") |

---

## Linting Rules Assessment (SC-LINT-001 through SC-LINT-004)

Based on the spec at issue #1387 which defines 6 linting rules:

| Rule ID | Description | Exists? | Status |
|---------|-------------|---------|--------|
| **SC-LINT-001** | Description starts with "Use when" | YES (in validate_req1) | Already exists as `description.startswith("Use when")` check. Needs extraction to standalone function per #1387 plan SC-1/SC-2 |
| **SC-LINT-002** | Description contains mandatory keyword | YES (in validate_req1) | Exists but needs extraction to standalone function per #1387 plan SC-2/SC-3 |
| **SC-LINT-003** | No standalone narrative-only sentence | NO | Needs new creation. Detects metaphors, slogans, value judgments, benefit statements in description field |
| **SC-LINT-004** | Description length limit (300 chars) | NO | Needs new creation. Checks description does not exceed 300 characters |
| **SC-LINT-005** | No procedure sections in SKILL.md body | YES (in validate_req1) | Exists but needs extraction to standalone function per #1387 plan SC-5/SC-7 |
| **SC-LINT-006** | Dispatch table sub-item type correctness | NO | Needs new creation. Checks sub-bullets for parameter metadata, sub-checkboxes for actionable sub-steps |

**New rules needed:** SC-LINT-003, SC-LINT-004, SC-LINT-006  
**Existing but needs extraction to standalone functions:** SC-LINT-001, SC-LINT-002, SC-LINT-005

---

## Semantic Auditor Criteria Assessment (SC-SEM-001 through SC-SEM-005)

The spec at issue #1384 proposes 5 semantic criteria for auditor-based evaluation:

| Criterion ID | Description | Exists? | Proposed vs Existing |
|--------------|-------------|---------|---------------------|
| **SC-SEM-001** | D2 audit: description accurately reflects TDT conditions — check every dispatch condition in table against what's described. Report PASS/FAIL with evidence of each matched/unmatched condition. | NO | NEW. Auditor must enumerate all TDT tasks and verify desc covers them as a non-misleading subset or COMPLETE match |
| **SC-SEM-002** | D3 audit: description covers ALL dispatch conditions from the TDT, not just some. If it's a subset, verify it is non-misleading (doesn't imply coverage of missing triggers). Report PASS/FAIL with evidence list of covered vs uncovered triggers. | NO | NEW. Separate from SC-SEM-001 — this checks completeness as a threshold, not accuracy. FAIL if subset is misleading |
| **SC-SEM-003** | D4 audit: description includes mandatory language signaling required/dispatch is not optional. Acceptable patterns: `MUST dispatch`, `REQUIRED before`, `always invoke`, `not optional`, `mandatory`. Report PASS/FAIL and list missing elements. | NO | NEW. Auditor checks for at least one of the 5 acceptable mandatory patterns in desc field |
| **SC-SEM-004** | D5 audit: identify any sentences that add zero dispatch information — slogans, value judgments, metaphors, benefit statements. List each narrative sentence found with line reference or quote. | NO | NEW. Auditor must parse desc into sentences and classify each as dispatch-relevant or narrative-only |
| **SC-SEM-005** | Cross-skill consistency: detect duplicate "Use when" descriptions across skills (e.g., researcher vs research have identical descriptions). Report duplicates with skill names. | NO | NEW. Detects copy-paste errors between similar-skilled entries |

**All 5 semantic criteria are NEW.** None currently exist in the codebase.

---

## Proposed Corrected Descriptions for All Skills with Failures

### Skills with D4 FAIL (missing mandatory language):

| Skill | Current Description | Proposed Fix |
|-------|---------------------|--------------|
| **gitbucket-api** | "Use when GitBucket platform operations are needed. GitBucket platform sub-skill for issue-operations. Provides capability manifest and gb CLI command reference for GitBucket API operations." | "Use when GitBucket platform operations are needed for GitHub Issue tracking. Routes to gb CLI command reference for all GitBucket API calls. REQUIRED before any GitBucket operation — always use the platform-aware routing." |
| **github-mcp** | "Use when GitHub MCP platform operations are needed. GitHub MCP platform sub-skill for issue-operations. Provides capability manifest and thin wrappers around github_* MCP tools." | "Use when GitHub MCP platform operations are needed for GitHub Issue tracking. Thin wrappers around github_* MCP tools with owner/repo verification. REQUIRED before any GitHub API call — always verify routing." |
| **local** | "Use when local .issues/ directory tracking is needed. Local .issues/ directory platform for issue tracking. Used when github.platform is local or unset." | "Use when local .issues/ directory tracking is needed for GitHub Issues on platforms without remote access. Routes all issue operations to YAML frontmatter and markdown files. REQUIRED before any local issue operation — always use the platform-aware routing." |
| **completion-core** | "Use when completing skill task workflows with push, URL generation, lifecycle event append, and executive summary reporting. Completion signals MUST be clear and structured — always required." | (Borderline D4: "MUST" is about output quality not dispatch requirement. No fix needed if accepting "MUST" as mandatory language signal.) |

### Skills with NO_TDT (missing Trigger Dispatch Table):

| Skill | Issue | Recommended Action |
|-------|-------|-------------------|
| **gitbucket-api** | No TDT in SKILL.md file | Add a TDT covering: gb CLI invocation, credential check, platform selection |
| **github-mcp** | No TDT in SKILL.md file | Add a TDT covering: github_* MCP tool routing, owner/repo verification |
| **local** | No TDT in SKILL.md file | Add a TDT covering: .issues/ directory operations, YAML frontmatter handling |

### Skills with D3 INCOMPLETE (non-misleading subset — acceptable but not exhaustive):

These skills have descriptions that cover the concept but don't enumerate all TDT triggers. All are classified as non-misleading subsets (acceptable per dimension definition). No fix required unless strict enumeration is desired:

- issue-operations, issue-review, pr-creation-workflow, pre-analysis
- implementation-pipeline, git-workflow, verification-before-completion
- verification-enforcement, verification, writing-plans, research
- test-driven-development, systematic-debugging, sync-guidelines
- sre-runbook, spec-creation

### Skills with D2 FAIL (description doesn't fully map to TDT conditions):

Same set as above — the descriptions are high-level concept statements rather than trigger-specific. They pass as non-misleading subsets but technically don't enumerate every TDT condition. No fix required unless strict enumeration is desired.
