# Spec Compliance Reviewer Prompt Template

Use this template when dispatching a spec compliance reviewer subagent.

**Purpose:** Verify implementer built what was requested (nothing more, nothing less)

**Source attribution:** This prompt pattern is adapted from [obra/superpowers `subagent-driven-development`](https://github.com/obra/superpowers/tree/main/skills/subagent-driven-development).

## When to Dispatch

Dispatch the spec compliance reviewer AFTER the implementer sub-agent has completed its work. The reviewer MUST NOT be dispatched before implementation — it reviews the actual code output against the original spec.

**Prerequisites:**
- Implementer sub-agent has returned a `status: DONE` result
- Code changes exist on the feature branch
- All tests pass (verified by the implementer)

## Dispatch Template

```
Task tool (general-purpose):
  description: "Review spec compliance for Task N"
  prompt: |
    You are reviewing whether an implementation matches its specification.

    ## Worktree Context

    worktree.path: <worktree.path value or 'not set'>

    If worktree.path is set, ALL file reads MUST prefix paths with worktree.path/. ALL bash commands MUST use workdir=worktree.path. If worktree.path is not set, use project root.

    ## What Was Requested

    [FULL TEXT of task requirements]

    ## What Implementer Claims They Built

    [From implementer's report]

    ## CRITICAL: Do Not Trust the Report

    The implementer finished suspiciously quickly. Their report may be incomplete,
    inaccurate, or optimistic. You MUST verify everything independently.

    **DO NOT:**
    - Take their word for what they implemented
    - Trust their claims about completeness
    - Accept their interpretation of requirements

    **DO:**
    - Read the actual code they wrote
    - Compare actual implementation to requirements line by line
    - Check for missing pieces they claimed to implement
    - Look for extra features they didn't mention

    ## Your Job

    Read the implementation code and verify:

    **Missing requirements:**
    - Did they implement everything that was requested?
    - Are there requirements they skipped or missed?
    - Did they claim something works but didn't actually implement it?

    **Extra/unneeded work:**
    - Did they build things that weren't requested?
    - Did they over-engineer or add unnecessary features?
    - Did they add "nice to haves" that weren't in spec?

    **Misunderstandings:**
    - Did they interpret requirements differently than intended?
    - Did they solve the wrong problem?
    - Did they implement the right feature but wrong way?

    **Verify by reading code, not by trusting report.**

    ## Branch Model Context

    This project uses the `feature→dev→main` three-branch workflow:
    - Feature branches target `dev`, not `main`
    - Verify changes are on the correct feature branch
    - Verify no changes to `main` or `dev` branches

    ## Integration Checklist

    Verify the implementation integrates correctly with repo workflow skills:
    - Does it follow established patterns in the codebase?
    - Does it conflict with any existing workflow gates?
    - Are there any missing integration points with approval-gate, git-workflow, or verification skills?

    Report:
    - ✅ Spec compliant (if everything matches after code inspection)
    - ❌ Issues found: [list specifically what's missing or extra, with file:line references]
```

## Review Methodology

The reviewer follows a systematic approach:

1. **Read spec requirements** — extract each acceptance criterion
2. **Read actual code** — inspect each file changed by the implementer
3. **Line-by-line comparison** — map each requirement to implementation
4. **Missing detection** — requirements with no implementation evidence
5. **Extra detection** — implementation not traced to any requirement
6. **Integration check** — verify patterns match codebase conventions

## Result Contract

The reviewer returns one of:

```yaml
status: PASS  # All requirements met, no extras
missing: []
extras: []
issues: []
```

```yaml
status: FAIL  # Requirements missing, extras found, or misunderstandings
missing: [requirement_id: description]
extras: [file:line: description]
issues: [file:line: description]
```

## Context Required

- Related skills: `divide-and-conquer` (parent skill)
- Related tasks: `implementer-prompt`, `code-quality-reviewer-prompt`