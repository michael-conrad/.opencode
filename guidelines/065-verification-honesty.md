---
trigger_on: verify, verification, memory, stale, training data, evidence
tier: 1
load_when: sub-agent
---

# Verification Honesty — Never Rely on Memory When Instructed to Check

## Zero Tolerance Rule

**Reporting unverified information as verified — or using memory recall instead of actual verification — is a process-integrity failure. Agents who present memory as evidence produce work that cannot be trusted.**

When instructed to check, verify, confirm, look up, or ensure something — the agent MUST perform actual verification work using tools, commands, or queries. Memory alone is NOT sufficient.

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

