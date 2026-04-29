# Task: search-prompt-fail

Search GitHub Issues for existing spec/plan candidates before Q/A halt. Present candidates or report failure state.

## Purpose

When an agent receives an implementation request but no matching spec or plan exists, the agent MUST NOT halt silently. This task performs a mandatory search of GitHub Issues for candidate specs/plans/fix-specs matching the request, presents all candidates with URLs, and offers the user a choice to select an existing candidate or create a new spec.

**This task is MANDATORY before any Q/A mode halt.** Skipping it — and going straight to Q/A mode without searching — is a critical violation per `000-critical-rules.md` §Silent Halt Without Prompt.

## Pre-Conditions

- Agent has received an implementation request
- No matching spec or plan was found in the current context
- Agent is about to halt in Q/A mode

## Steps

### Step 1: Label-Based Search

Search GitHub Issues in the repository using label filters:

```
github_search_issues(owner=<github.owner>, repo=<github.repo>, labels=["SPEC"])
github_search_issues(owner=<github.owner>, repo=<github.repo>, labels=["PLAN"])
github_search_issues(owner=<github.owner>, repo=<github.repo>, labels=["SPEC-FIX"])
```

### Step 2: Keyword-Based Search

Search GitHub Issues using keywords from the implementation request:

```
github_search_issues(owner=<github.owner>, repo=<github.repo>, query="<keywords from request>")
```

Extract keywords from:
- Feature name
- Component or module area
- Bug area or symptom description

### Step 3: Evaluate Candidates

For each search result, assess relevance to the request target:

| Match Level | Criteria |
|-------------|----------|
| **Strong** | Issue title directly names the feature/bug; body describes same scope |
| **Partial** | Issue covers related area but different scope; overlapping but not identical |
| **Weak** | Tangentially related; different feature, different component |

### Step 4: Present Candidates or Report Failure

**If candidates found:**

Present all candidates (strong + partial matches) with:
- Issue number and title
- Issue URL
- Brief relevance assessment (why it matches)
- Offer: select an existing candidate OR create a new spec

**If no candidates found:**

Explicitly state the failure state: "No existing spec/plan found for [topic]". Then offer to create a new spec.

### Step 5: Route Based on User Selection

| User Selection | Action |
|----------------|--------|
| Select existing candidate | Route to that issue for implementation |
| Create new spec | Invoke `brainstorming --task explore` then `spec-creation` |
| Neither | HALT with status report |

## Result Contract

```json
{
  "status": "candidates_found | no_candidates | search_failed",
  "candidates": [
    {
      "issue_number": N,
      "title": "...",
      "url": "...",
      "match_level": "strong | partial | weak"
    }
  ],
  "keywords_used": ["..."],
  "search_failure_reason": "string | null"
}
```

## Completion Guarantee

If this task halts at any point, invoke `approval-gate --task completion` before halting.