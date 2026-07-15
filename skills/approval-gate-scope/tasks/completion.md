# Task: completion

Idempotent completion subtask for approval-gate. Ensures mandatory steps run regardless of where the workflow halted.

## State Check Phase

- [ ] 1. **Authorization result determined:** Was a yes/no decision reached?
- [ ] 2. **Label state:** Check if `approved-for-*` label is already applied

## Skill-Specific Completion

- [ ] 1. **Apply `approved-for-*` label** (if authorization granted):
   - Use `issue-operations -> update-issue` to apply the `approved-for-<scope>` label
   - Record authorization in local state file `.issues/{N}/issue.yaml`
   - The label is stakeholder advisory only — not an authorization signal
   - The local state file is the single source of truth for authorization state
   - No `issue-operations -> comment` calls for authorization-related output

## Shared Completion Delegation

Reference `.opencode/skills/completion-core/completion-core.md` for reporting:

- [ ] 1. Report executive summary in chat (always runs)
- [ ] 2. Action URL (issue URL) as the URL (ALWAYS last)

## Label State Machine

Before adding or removing labels in completion, consult `141-planning-status-tracking.md §10` for the complete label transition matrix and the GitHub `labels` parameter warning (replaces all labels, not additive).

## Completion Guarantee

**MANDATORY:** Regardless of authorization outcome (approved, rejected, blocked, error), produce a status message containing:
- [ ] 1. Authorization decision (approved/rejected/blocked)
- [ ] 2. Issue number and branch (if applicable)
- [ ] 3. What happens next (workflow forward, HALT, or error)
- [ ] 4. **Blocker state** — what constraint caused the halt (authorization/spec/plan/context/error/none)
- [ ] 5. **Developer action required** — exact phrase or step the developer must provide to continue (empty string when no blocker)

When `status == blocked`, fields 4 and 5 MUST be non-empty and specific. Vague phrasing like "needs approval" is STRUCTURE-VIOLATION — the blocker state must name the specific constraint and the developer action must specify the exact phrase or step.

This is the completion guarantee: NO authorization check ends without a status message.

## Report Phase

Generate executive summary in chat:

```
**Summary:**

<Authorization verification result and scope>

**Outcome:** <What the result means for stakeholders>

**Blockers:** <Why stopped + required developer action> (omit when workflow complete)

Issue URL: <html_url from issue-operations -> update-issue or issue-operations -> read-issue API response — NEVER construct from template> <!-- Routes through issue-operations per SPEC #683 -->

🤖 <AgentName> (<ModelId>) <status>
```

**Post-Creation URL Extraction (MANDATORY — per `000-critical-rules.md` §URL Sourcing):**

The Issue URL MUST be extracted from the API response `html_url` field — NEVER constructed from template variables:

- [ ] 1. If the issue was created in this session: Extract `html_url` from the `issue-operations -> update-issue` creation response <!-- Routes through issue-operations per SPEC #683 -->
- [ ] 2. If the issue was read (not created): Extract `html_url` from the `issue-operations -> read-issue` response <!-- Routes through issue-operations per SPEC #683 -->
- [ ] 3. **Template construction is FORBIDDEN for post-creation URLs** — do NOT assemble from `<gitbucket.html_url>`, `<github.owner>`, `<github.repo>`, or issue number
- [ ] 4. If `html_url` is not available in the API response: HALT and report

URL is ALWAYS last per `000-critical-rules.md`.

### Format Verification Before Halt (MANDATORY)

**Idempotent — safe to invoke multiple times. This verification runs before EVERY halt, regardless of path.**

**For chat messages (visible output):**

- [ ] Executive summary present as **first** element (before any URL)
- [ ] Outcome line present after summary
- [ ] Blockers section present when `workflow_state != complete` (between outcome and URL, or between outcome and byline when no URL)
- [ ] Blockers section omitted when workflow is fully complete
- [ ] URL present IF relevant (after outcome/blockers, before byline) — required when branch pushed or issue URL exists, **omitted** when no URL exists
- [ ] AI byline present as **LAST** element (after URL, or after outcome/blockers when no URL)
- [ ] No URL before executive summary
- [ ] No byline before URL/outcome

**For silent stops (no visible output):**

- [ ] Executive summary already reported in a prior chat message
- [ ] No stale todowrite items remain (all cleared or N/A)

**Evidence requirement:** Each checkpoint verification MUST produce a tool-call artifact confirming the element is present or correctly absent. Verbal assertion without tool-call evidence is insufficient.

**URL applicability:**

| Scenario | URL Required? | Action |
| -- | -- | -- |
| Branch pushed | ✅ Yes | Include compare URL between outcome and byline |
| Issue URL available | ✅ Yes | Include issue URL between outcome and byline |
| No URL available | ❌ No | Omit URL element entirely; byline follows outcome directly |
| PR already created | ✅ Yes | Use PR URL label with `pull/<N>` format |

**Auto-fix on failure:** If any element is missing or misordered, fix the output before sending. Missing elements are MISSING-ELEMENT (auto-fix). Wrong ordering is STRUCTURE-VIOLATION (auto-fix). Elements are auto-fixed before output is sent — NOT reported after the fact.

<!-- Issue #25: Authorization Solicitation Regression — Success Criteria: Update completion.md with non-instructional blocker report format, add behavioral enforcement test reference -->

## Blocker Report Format

When the workflow halts due to a blocker (authorization denied, missing spec, validation failure), the completion report MUST use non-instructional, factual language.

### 🚫 PROHIBITED Patterns

| Pattern | Why Forbidden |
| -- | -- |
| "To resolve this, please do X" | Instructional — solicits user action |
| "You can say 'approved' to continue" | Self-authorization bypass |
| "Once you've reviewed, let me know" | Awaiting-response framing |
| "Please provide authorization before I continue" | Direct solicitation |
| "We're blocked — can you approve #N?" | Implied authorization framing |

### ✅ REQUIRED Format

```
**Summary:**

<Blocker detected: one sentence factual statement>

**Outcome:** <What is blocked and why>

**Blockers:** <Constraint name + required developer action>

🤖 <AgentName> (<ModelId>) ⛔ blocked
```

- No instructions or suggestions in the report
- No forward-looking references to next steps
- No questions or prompts for user action
- URL omitted when no relevant URL exists
- Status icon is `⛔` for blockers, not `✅`

### Behavioral Enforcement Test Reference

This format is verified by behavioral enforcement tests in `.opencode/tests/behaviors/test-blocker-report-format.sh`. Any change to this section requires updating the corresponding behavioral test.

**See `.opencode/tests/behaviors/README.md` for test infrastructure details.**

## Adversarial Verification: Completion Claims

**Before claiming completion, verify that all completion claims are backed by evidence — not asserted without verification.**

### Verification Checklist

- **Label state matches authorization:** Check labels via `issue-operations -> read-labels`. If `needs-approval` present AND authorization granted → STRUCTURE-VIOLATION (auto-fix: remove label). If `needs-approval` absent AND no authorization found → VERIFICATION-GAP (FAIL). <!-- Routes through issue-operations per SPEC #683 -->
- **Local state file matches authorization:** Read `.issues/{N}/issue.yaml` and verify authorization scope marker matches the current session authorization. If mismatch → VERIFICATION-GAP (FAIL).
- **Status report matches workflow outcome:** If completion claims "approved" but no local state file authorization found → CONFLICTING (FAIL). If claims "blocked" but blocker issue is closed → VERIFICATION-GAP (FAIL).

### Completion Task Scope Clarification

The `--task completion` subtask is for cleanup-state reporting (labels, comments, verification), NOT for generating the agent's primary visible output.

The agent's visible output is generated:
- [ ] 1. AFTER tool execution
- [ ] 2. BEFORE invoking `--task completion`
- [ ] 3. By the main agent reasoning context, not delegated to completion subtask

**Rule:** If the agent has produced zero chat messages in the current user-turn, invoking `--task completion` does NOT satisfy the output guarantee. Completion runs AFTER output is produced, not INSTEAD of output.

## Enforcement References

- Evidence format + finding classification: see `enforcement/adversarial-verification.md`
- Scope parsing: see `enforcement/scope-parsing.md`

## Pipeline Signal

```
CONTINUE: writing-plans
HALT
```
