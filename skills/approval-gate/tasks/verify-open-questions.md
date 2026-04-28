# Task: verify-open-questions

## Purpose

Check for unresolved open questions in the spec before implementation. Unresolved questions represent ambiguity that could lead to incorrect implementation — every open question must be resolved or determined to be non-blocking before implementation proceeds.

## Entry Criteria

- Authorization verified
- Blockers checked (via `verify-blockers` if applicable)

## Exit Criteria

- All open questions resolved or determined to be non-blocking
- Ready to proceed with implementation (or HALT with blocker)

## Procedure

### Step 1: Check Spec for Open Questions

Read the spec body for an "Open Questions" section or `?` markers indicating unresolved items.

Open questions can appear in various formats:
- Explicit `## Open Questions` section with numbered questions
- Inline `?` markers in requirements (e.g., "Should this handle edge case X?")
- `TBD` or `TODO` annotations
- Implied questions from ambiguous requirements

### Step 2: Verify Resolution

For each open question found in the spec body:
- Check if the answer is documented in the spec itself
- Check if the answer is "TBD" or a placeholder — these are NOT resolved
- Search ALL issue comments for developer responses that answer the question
- Document any unresolved questions

### Step 3: Check Comments for Answers

Search ALL comments on the issue for answers or discussions resolving the open questions:

```python
comments = github_issue_read(method="get_comments", issue_number=N)

for each open question found:
    for comment in comments:
        if comment contains answer or discussion resolving the question:
            if comment.author is developer (MEMBER/OWNER/COLLABORATOR):
                mark question as "resolved in comments"
            else:
                mark question as "discussion found, no developer answer"
```

If an answer exists in comments but not in the spec body → `STRUCTURE-VIOLATION` (recommend updating spec).

### Step 4: Verify Question Is Genuinely a Blocker

Not every open question blocks implementation:

```
For each unresolved open question:
    - Is the question blocking implementation, or is it a design preference?
    - If implementation can proceed regardless of the answer → NOT a blocker
    - If the answer changes the implementation approach → IS a blocker
    - Do NOT treat all open questions as implementation blockers
```

**Blocker classification:**
- **Blocking:** Answer changes the implementation approach (e.g., "Which API version?" when the API version determines all method calls)
- **Non-blocking:** Answer is a design preference (e.g., "Should we use blue or green?" when both work)
- **Clarification:** Answer improves quality but doesn't change core approach (e.g., "What error message format?" when the error handling is already defined)

### Step 5: Verify No New Questions in Comments

Check ALL comments for questions not listed in the spec's "Open Questions" section:

```python
comments = github_issue_read(method="get_comments", issue_number=N)

# Check ALL comments for questions not listed in spec's Open Questions section
for comment in comments:
    if comment contains a question not in spec:
        flag as MISSING-ELEMENT (conditional: add to open questions)
```

Developers may have raised new questions in comments that aren't reflected in the spec body.

### Step 6: HALT if Unresolved Blockers Exist

If ANY blocking open questions remain unresolved:
- Post comment listing unresolved questions
- HALT and wait for developer answers

**HALT format:**
```
**Blockers:** <count> unresolved blocking questions found in spec #<N>

Questions:
- <Q1>: <classification>
- <Q2>: <classification>

Resolve these questions before implementation can proceed.

🤖 <AgentName> (<ModelId>) ⛔ blocked
```

## Handling Open Questions

| Status | Action |
|--------|--------|
| All resolved | Proceed to implementation |
| Non-blocking unresolved | Note in report, proceed with implementation |
| Blocking unresolved | HALT and post questions |
| Answers unclear | Ask for clarification (this is a genuine question, not an authorization prompt) |

## Task-Specific Findings

See `enforcement/adversarial-verification.md` for the three-tier classification model (auto-fix, conditional, flag-for-review) and evidence artifact format.

## Context Required

- Related tasks: `verify-authorization`, `verify-codebase`
- `065-verification-honesty.md`: Verification claims must be backed by tool call evidence
- `spec-auditor --task ground-truth`: Adversarial verification model