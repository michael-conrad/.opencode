---
trigger_on: verify, verification, memory, stale, training data, evidence
tier: 1
load_when: sub-agent
---

# Verification Honesty — Never Rely on Memory When Instructed to Check

## Zero Tolerance Rule

**Reporting unverified information as verified — or using memory recall instead of actual verification — is a process-integrity failure. Agents who present memory as evidence produce work that cannot be trusted.**

When instructed to check, verify, confirm, look up, or ensure something — the agent MUST perform actual verification work using tools, commands, or queries. Memory alone is NOT sufficient.

## Core Principle

**When instructed to check, verify, confirm, look up, or ensure anything — the agent MUST perform actual verification work using tools, commands, or queries. Memory alone is NOT sufficient.**

The agent must never shortcut verification by recalling information from memory (session context, prior tool calls, or training data) instead of performing actual verification.

## Evidence Requirement

When the agent performs verification, it MUST show evidence:

- **Tool calls visible**: The actual `read`, `bash`, `grep`, `pycharm_*`, or `srclight_*` call used
- **Command output shown**: The relevant portion of output confirming the result
- **Explicit attribution**: "Verified by running `git status`" not just "git status is clean"

### What COUNTS as Evidence

✅ **Verified:**

- "X is Y — verified by `git status` just now" (with tool call visible)
- "Running `pytest test/` confirms all tests pass" (with output shown)
- "Checked `.env.example` — the variable name is `OLLAMA_API_URL`" (with read tool shown)
- Calling a tool and reporting the result in the same exchange

❌ **NOT Evidence:**

- "I checked earlier that X is Y" (memory recall without re-verification)
- "The file contains Z (from my earlier read)" (stale reference)
- "X is Y" without any visible tool call or command
- "As we know, X is Y" (training knowledge presented as verified)

## No Exceptions

- **Fresh session**: Still must verify — training data is not verification
- **Same session, earlier check**: Still must re-check — state may have changed
- **"Obvious" facts**: Still must verify — obvious things are wrong surprisingly often
- **Previous tool output**: Still must re-run — unless the output is from the immediately preceding exchange

## Evidence Hierarchy

| Tier | Source | Classification | When Permitted |
|------|--------|----------------|----------------|
| **Direct evidence** | Live tool call in current session (file read, signature lookup, test execution, API query) | Evidence | As sole basis for PASS judgment |
| **Process metadata** | PR merge status, issue state, labels, comments | Context only | May inform where to look, NEVER basis for PASS |
| **Session memory** | Tool call from earlier in same exchange | Evidence (single-exchange window) | ONLY if from immediately preceding exchange |
| **Session memory (stale)** | Tool call from earlier in same session (not last exchange) | Context only | Treat as unverified; re-read if state may have changed |
| **Cross-session memory** | Recollection from previous session | PROXY — always stale | NEVER evidence; must re-verify |
| **Training data** | Model weights / parametric knowledge | PROXY — always stale | NEVER evidence; suggest-only with staleness disclaimer |

## Pre-Response Factual Claim Gate

**Producing a response with factual claims and zero preceding tool calls is a CRITICAL VIOLATION.** Every factual claim in agent output MUST be preceded by at least one tool call that verifies it.

### Procedure

1. **Identify each factual claim** in the response you are about to produce. A factual claim is any assertion about code state, API behavior, file existence, configuration values, environment variables, or system state.

2. **For each claim, check if it has been verified by a tool call in the current session.** Session-scoped verification: verify once per fact per session, not per exchange. If the fact was verified in an earlier exchange in the same session and no state-change trigger has occurred, it MAY be reused without re-verification.

3. **If not verified, make a tool call before producing the claim.** Use the appropriate tool for the claim type: `read` for file contents, `srclight_get_signature` for API signatures, `grep` for code patterns, `bash` for command output, `github_*` for issue/PR state.

4. **If the tool call contradicts the claim, correct it.** The tool call result is authoritative — the claim must match the evidence.

5. **If no tool can verify the claim, omit it.** Do not produce unverifiable claims. Do not use training data as a substitute for verification.

### Halt Condition

A response that contains factual claims but has zero preceding tool calls in the same exchange is a CRITICAL VIOLATION. The agent MUST halt and report the violation before producing the response.

### Session-Scoped Verification

Verification is session-scoped: a fact verified once in the current session MAY be reused without re-verification, UNLESS a state-change trigger has occurred (user explicitly says something changed, API response indicates change, 5+ minutes elapsed with other agents active, session boundary, resource modified by the agent itself).

## 🚫 FORBIDDEN

- Reporting values from memory without re-running the verification
- Claiming "I checked earlier" without showing the current tool call
- Using training knowledge as a substitute for actual tool calls
- Assuming state hasn't changed since a previous check
- Omitting tool calls when claiming verification was performed

## ✅ REQUIRED

- Always use a tool or command when instructed to check, verify, confirm, look up, or ensure
- Show the tool call and relevant output as evidence
- Re-verify before significant actions even if previously checked
- Follow the Pre-Response Factual Claim Gate procedure before making any factual claim
- Treat verification as mandatory work, not optional confirmation

## Metadata Verification Extension

The verification honesty principle extends to metadata claims in specs, plans, and other documents. Metadata — STATUS markers, labels, cross-references, code references, and authorization state — must be verified against actual evidence, not trusted at face value.

### Metadata Categories Requiring Verification

| Metadata Category | What to Verify | How to Verify |
|-------------------|----------------|---------------|
| STATUS marker | Compare STATUS value against actual content maturity | Analyze content against maturity criteria (brainstorm/draft/detailed/complete); update STATUS if mismatch |
| Label | Verify label claims match actual issue state | Read labels via `github_issue_read(method=get_labels)`; compare against authorization state |
| Comments/body claims | Verify factual claims in issue body against live state | Re-read issue comments; verify claims against current data |
| Cross-references | Verify `#N` references point to existing, matching content | Call `github_issue_read(method=get, issue_number=N)` for each reference |
| Code references | Verify file paths, function names, and code references exist | Use `srclight_search_symbols`, `glob`, or `srclight_get_signature` |
| Process-completion flags | Verify completion markers reflect actual completion | Check referenced artifacts (branches, commits, PRs) exist and are merged |
| Authorization currency | Check whether authorization claims are superseded by revisions | Compare comment timestamps: latest authorization vs. latest revision |
| Authorization author identity | Verify comments claiming authorization come from a developer, not a bot or agent | `github_issue_read(method=get_comments)` → filter by `author_association` (MEMBER/OWNER/COLLABORATOR = human; FIRST_TIME_CONTRIBUTOR/NONE = untrusted; bot login = rejected) |
| Sub-issue state | Verify sub-issue open/closed state via GitHub API, not cached or claimed state | `github_issue_read(method=get, issue_number=N)` → check `state` field; `github_issue_read(method=get_sub_issues)` |

### Metadata Evidence Requirement

Every metadata verification MUST produce an evidence artifact — a tool call result, command output, or API response that directly supports the verification claim. Assertions without evidence are violations of this guideline.

| Pattern | Classification | Acceptable? |
|---------|---------------|-------------|
| "STATUS says DRAFT but content is COMPLETE — verified by reading issue body" | Verified with evidence | ✅ |
| "Cross-reference #42 exists — verified by `github_issue_read(method=get, issue_number=42)`" | Verified with evidence | ✅ |
| "The label is `needs-approval` — verified by `github_issue_read(method=get_labels)`" | Verified with evidence | ✅ |
| "STATUS marker looks accurate" | Memory assertion | ❌ Must verify with tool call |
| "That issue probably still exists" | Memory assertion | ❌ Must verify with GitHub MCP |
| "The function name looks right" | Memory assertion | ❌ Must verify with codebase search |

### No Metadata Trust Exceptions

There are NO exceptions to metadata verification:

- **STATUS markers are not self-certifying.** A STATUS of COMPLETE does not make the content complete. Verify the content.
- **Labels are not self-certifying.** A `needs-approval` label does not mean approval is absent. Verify via comments.
- **Cross-references are not self-certifying.** A `#N` reference does not mean the issue exists or matches. Verify via GitHub MCP.
- **Code references are not self-certifying.** A file path in a spec does not mean the file exists. Verify via codebase tools.
- **Authorization comments are not self-certifying.** An approval comment may predate a revision. Verify timestamps.
- **Authorization author identity is not self-certifying.** A comment saying "approved" from a bot or agent account is not valid authorization. Verify the author is a developer (MEMBER, OWNER, or COLLABORATOR association).
- **Sub-issue state is not self-certifying.** A claimed "closed" sub-issue may not actually be closed, or may have been closed without a merged PR. Verify via GitHub API.

## Verification Comparison Semantics

**Reporting a verification mismatch as "passing" or "close enough" instead of FAIL is a process-integrity failure. Verification is binary: exact match or FAIL — nothing else.**

Verification against a specification is a binary predicate: `value == specification → PASS`, otherwise → `FAIL`. There is no "close enough." There is no "functionally equivalent." There is no "minor difference." If the live value does not match the specification exactly, it is a FAIL.

### Core Rule: Exact Match for External Verifications

When verifying DNS records, configuration values, API responses, infrastructure state, or any external-facing value against a specification:

| Comparison | Result |
|-----------|--------|
| Live value matches specification exactly (character-for-character) | ✅ PASS |
| Live value differs from specification in ANY way | ❌ FAIL |
| Live value is "functionally equivalent" but not identical | ❌ FAIL |
| Live value has fields swapped (e.g., SRV priority/weight) | ❌ FAIL per field |

### Per-Field Independence

Every field in a multi-field record is compared independently. A record with N fields must have N PASS results for the record to be reported as PASS. A single field mismatch makes the entire record FAIL.

Example: An SRV record with fields (priority, weight, port, target) requires 4 independent comparisons. If priority=5 weight=0 was specified but priority=0 weight=5 is found, that is **2 FAIL results** (priority mismatch AND weight mismatch), not "functionally equivalent."

### Prohibited Reasoning Patterns

| Prohibited Pattern | Why Prohibited |
|-------------------|----------------|
| "Priority=0 weight=5 works the same as priority=5 weight=0" | False equivalence — SRV priority and weight have distinct semantics |
| "The values are swapped but the result is the same" | Agent judgment substituting for spec compliance |
| "Minor difference, effectively equivalent" | "Close enough" is never a valid verification outcome |
| "Functionally equivalent, does not affect behavior" | Functional analysis is for design, not verification |
| "Semantically close enough to pass" | Verification is binary: exact match or FAIL |

### Verification Report Format

When reporting verification results for external values:

```markdown
| Field | Expected (from source) | Actual (live) | Result |
|-------|----------------------|---------------|--------|
| priority | 5 | 0 | ❌ FAIL |
| weight | 0 | 5 | ❌ FAIL |
| port | 443 | 443 | ✅ PASS |
| target | server.example.com | server.example.com | ✅ PASS |
```

**Footnotes and notes about "minor differences" are FORBIDDEN.** If it does not match, it is FAIL. No exceptions.

### When Semantic Comparison Is Allowed

`semantic` comparison mode (where multiple implementations achieve the same spec intent) is ONLY allowed for code behavior verification, and requires:

1. Explicit per-field justification for why semantic comparison applies
2. Documentation of what "same intent" means for that specific field
3. The default is ALWAYS `exact` — semantic mode must be explicitly chosen and justified

**For ALL external verifications (DNS, configuration, infrastructure, API responses), `exact` mode is mandatory. No exceptions. No semantic comparison.**

## Anti-Evasion Rules — Cost, Availability, and Necessity Are Not Excuses

Evasion patterns are predictable. When a behavioral test cannot run, agents produce three categories of rationalization instead of the required FAIL verdict. Each category is a Tier 2 prohibition with a mandatory remediation-first protocol.

### Pattern (a): Claiming Model Unavailability Without Tool-Call Evidence

An agent claiming a model is unavailable MUST produce tool-call evidence before the claim is accepted. "The model timed out" is not evidence — `opencode models` output showing the model is not listed, or a timed-out execution log showing the timeout duration, is evidence.

**Remediation-first protocol (minimum 2 steps before FAIL):**
1. Run `opencode models` to verify model availability
2. Attempt alternative model selection (select a different available model)
3. Increase timeout and retry
4. Only after 2+ remediation attempts: report FAIL with tool-call evidence of each attempt

### Pattern (b): Claiming "Too Slow" as Justification for Skipping Behavioral Testing

Read [§1 ALWAYS DO](020-go-prohibitions.md) — Cost-blind verification: resource cost is NEVER a factor in verification decisions. "This would take too long" is not an acceptable reason to skip or substitute behavioral verification. Correctness is the only metric — there is no score for tool-call economy.

**Remediation-first protocol (minimum 2 steps before FAIL):**
1. Increase timeout configuration (BEHAVIOR_TIMEOUT, BEHAVIOR_SEMANTIC_TIMEOUT)
2. Run behavioral test with increased timeout
3. Attempt alternative model with faster inference
4. Only after 2+ remediation attempts: report FAIL with evidence of each attempt

### Pattern (c): Claiming Behavioral Testing "Not Needed" for Runtime-Behavioral Changes

Read [§Test Integrity Mandate](080-code-standards.md) — removing or weakening behavioral assertions is a CRITICAL VIOLATION. When a change affects runtime behavior (agent dispatch decisions, enforcement gate outcomes, tool selection, pipeline routing, conditional branching, test execution results), behavioral testing is not optional — it is the only sufficient evidence type. Declaring an SC as `structural` to avoid behavioral testing when the change affects runtime behavior is an automatic uplift to `behavioral`.

**Remediation-first protocol (minimum 2 steps before FAIL):**
1. Reclassify evidence type from `structural`/`string` to `behavioral` per the substrate classification
2. Design and execute a behavioral test that verifies the runtime behavior change
3. If behavioral test environment unavailable: apply patterns (a) and (b) remediation steps
4. Only after 2+ remediation attempts: report FAIL with EVIDENCE_TYPE_MISMATCH classification

### 🚫 FORBIDDEN

- Claiming model unavailability without tool-call evidence (`opencode models` output, execution logs)
- Claiming "too slow" or "too many tool calls" as justification for skipping any verification step
- Declaring a runtime-behavioral change as `structural` to avoid behavioral testing
- Producing an INCONCLUSIVE verdict when EVIDENCE_TYPE_MISMATCH is detected — the verdict MUST be FAIL
- Skipping remediation steps before reporting FAIL — exhaustion before escalation

### ✅ REQUIRED

- Produce tool-call evidence before claiming model unavailability
- Run behavioral tests regardless of estimated cost or duration
- Apply automatic evidence type uplift when a change affects runtime behavior
- Attempt at least 2 remediation steps (alternative model, timeout increase, infrastructure check) before reporting FAIL
- Report EVIDENCE_TYPE_MISMATCH with FAIL verdict when structural evidence is submitted for a runtime-behavioral change

### [critical-rules-009] Schema/API/Code Verification — claiming knowledge without verification
Claiming schema compliance or API correctness without verification means you are asserting facts you have not checked. Every unverified claim is a defect waiting for CI to discover. All code/API claims require live tool-call evidence — see `065-verification-honesty.md` → "Pre-Response Factual Claim Gate".


### [critical-rules-009] Verification Dishonesty — reporting memory as verified
Reporting memory as verification means you are presenting guesses as facts. Every claim presented without a tool call is trust you have not earned. Professional agents never report unverified information as verified — see `065-verification-honesty.md`.


### [critical-rules-009] Metadata-as-Evidence — workflow metadata is not evidence of implementation
Issue state and PR merge status are process metadata, not evidence of acceptance criteria being met. Treating labels as proof means accepting administrative artifacts as behavioral evidence. Issue state, PR merge status, and labels are NOT evidence of completion.


### [critical-rules-009] Memory/Training-Data-as-Evidence — memory and training data are always stale
Memory and training data are always stale — they represent what was true when the model was trained, not what is true now. Every factual claim must be backed by a live tool-call artifact in the current session. Agents who rely on memory produce work that cannot be trusted.


### [critical-rules-009] Skipping verification-enforcement During Content Generation
Generating content without verification means publishing unverified claims. Specs with unverified statements produce plans that implement the wrong thing. All content (specs, plans, docs, correspondence) must pass the verification gate — see `verification-enforcement` skill.


### [critical-rules-015] Plan ≠ Execution — treating documentation as evidence of completion
A plan is a map, not a destination. Treating plan completion as implementation completion means you are mistaking intent for delivery. Professional engineers verify behavior, not documentation — see `verification-enforcement` skill → "Plan ≠ Execution Evidence Rule".


### [critical-rules-016] Fabricating URLs
Constructing URLs from template variables instead of extracting them from the API response is what amateurs do when they want their compare links to point to the wrong repository — and their issue URLs to break the moment they are posted. Professional engineers extract every post-creation URL from the API response `html_url` field — never from guesswork templates. Pre-creation URLs use verified session-init values with character-match verification. The detailed rules below are not suggestions — they separate reliable PRs from broken links.

#### URL Sourcing Rule 1: Post-Creation URLs — Extract from API Response (NEVER construct)

For URLs to resources that have been **created by an API call** (PR URL, Issue URL), the agent MUST extract the `html_url` field from the API response — never construct from template variables.

**Procedural enforcement in skill tasks:** The following skill task files contain mandatory URL extraction steps:
- `git-workflow-pr/tasks/pr-creation.md` Step 7 — PR URL extraction from `github_create_pull_request`
- `git-workflow-pr/tasks/review-prep.md` — PR URL extraction after PR creation
- `approval-gate/tasks/post-implementation.md` — PR URL extraction after PR creation
- `issue-operations/tasks/link-sub-issue.md` Step 4 — Sub-issue URL extraction from `github_issue_write`
- `issue-operations/tasks/creation.md` — Issue URL extraction from `github_issue_write`
- `issue-operations/tasks/completion.md` — Issue URL extraction from `github_issue_write`
- `verification-before-completion/tasks/completion.md` — Issue URL extraction from `github_issue_write`
- `implementation-workflow reference card` — PR URL extraction after PR creation
- `finishing-a-development-branch/tasks/checklist.md` — URL extraction checklist verification

- **PR URL:** Extract from `github_create_pull_request` response `html_url` field
- **Issue URL:** Extract from `github_issue_write` response `html_url` field
- **Template construction is FORBIDDEN** for post-creation URLs
- The API response is the single source of truth for post-creation URLs

#### URL Sourcing Rule 2: Pre-Creation URLs — Construct from Verified Session-Init Values

For URLs to resources that **haven't been created yet** (Compare URL before push), the agent MUST construct from session-init values with a mandatory character-match verification step:

1. Read `<github.owner>`, `<github.repo>`, `<gitbucket.html_url>` from session init
2. Construct the URL using those exact values
3. **Character-match verification:** Confirm the constructed URL contains the exact `<github.owner>` and `<github.repo>` strings from session init (character-for-character match, no typos, no cached values)
4. If any mismatch: HALT and report

#### Original Fabricating URLs Rule (superseded by Rule 1 and Rule 2 above)

- ✅ REQUIRED: Follow URL Sourcing Rule 1 and Rule 2 above


### [critical-rules-009] Session-Verified State Trust — re-reading without state-change trigger
Re-reading a resource that was confirmed in-session is re-reading verified state — wasteful overhead. Trusting session-verified state without re-reading is professional efficiency, not laziness.


### [critical-rules-009] Verification Deduplication
Re-verifying evidence that a prior skill already collected means doubling work without doubling confidence. Professional engineers cite prior evidence artifacts — amateurs re-check what was already verified.


### [critical-rules-020] Soft-Passing Verification Mismatches
Reporting "functionally equivalent" as PASS means accepting defects into the codebase under a euphemism. Amateurs soft-pass. Professionals demand exact matches.


### [critical-rules-033] Claiming Verification Without Tool-Call Evidence in Sub-Agent Results
Reporting verification without tool-call evidence means presenting guesses as facts. Amateurs claim. Professionals prove.


### [critical-rules-hard-fail] Hard Failure Discipline — FAIL is a hard gate, never reclassifiable

A FAIL signal at any pipeline stage (auditor verdict, sub-agent result, cleanup gate, SC-verification gate, phase-completion gate) is a **hard gate** — it must be remediated, not sidestepped. `DONE_WITH_CONCERNS` is coerced to FAIL — caveats are defects, not completions. The bright-line coercion rule in `skills/writing-plans/reference/implementation-workflow.md` Trigger Dispatch Table governs this coercion.

**Remediation-first sequence (mandated by #763):**
1. **Remediate** the root cause — diagnose what produced the FAIL
2. **Re-verify** — When the original FAIL came from an audit, "re-verify" means dispatching a clean-room re-audit via `skill({name: "audit"})` + `task()`. A self-check, inline re-read, or orchestrator-level re-verification is NOT sufficient — the re-audit must be independent of the remediator's context. For non-audit FAILs, repeat the verification command/assertion that produced the FAIL.
3. **Proceed** only on confirmed PASS from re-verification
4. **HALT only on double-failure** — if re-verification also fails, report blocker with both failure artifacts

**Prohibited patterns:**
- **Reclassification** — turning a FAIL into "PASS with caveats" or "functionally equivalent" is soft-passing by another name (Read [critical-rules-020](guidelines/000-critical-rules.md))
- **INCONCLUSIVE** — a verdict of INCONCLUSIVE for a gate that produces deterministic PASS/FAIL is a reclassification, not a finding. INCONCLUSIVE is prohibited as a gate verdict at all pipeline stages. The auditor files have been updated to remove INCONCLUSIVE — see `audit` task files
- **HALT without remediation attempt** — a FAIL that halts the pipeline without any remediation attempt is abandoning the root cause instead of fixing it. Professional engineers always attempt remediation before escalation. See `763-remediation-first`

Professional engineers remediate then re-verify — amateurs reclassify, soft-pass, or INCONCLUSIVE to avoid doing the work. Read [065-verification-honesty.md](guidelines/065-verification-honesty.md) → "Hard Failure Discipline".

