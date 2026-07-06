---
trigger_on: example, spec example, example structure
tier: 2
load_when: sub-agent
---

# Planning: Spec Examples

## Examples of Different Valid Structures

This document provides examples of different valid structures for specs at various complexity levels. There is no single "correct" format — the right structure depends on the spec's complexity, domain, and audience.

**Key principle:** A spec that covers all required content areas (problem, context, success criteria) is valid regardless of its section headers. A spec with the "correct" headers but missing content is invalid.

The examples below show how the same content area can be covered at different levels of detail and with different organizational choices.

______________________________________________________________________

## Example 1: Bug Report — Different Complexity Levels

### Minimal Bug Report (one-line fix, obvious cause)

> **Problem:** `process_data()` crashes on empty input, raising `IndexError` at `src/core/processor.py:42`.
>
> **Fix:** Add empty list guard.
>
> **Success Criteria:** ✅ Empty input returns empty result. ✅ Non-empty input unchanged.

**Why this works:** The problem, fix, and criteria are obvious. No separate context section needed — it's self-evident. The one-line description is sufficient because any agent can understand the issue from the problem statement alone.

### Standard Bug Report (needs investigation context)

> **Intent and Executive Summary**
>
> **Problem Statement:** OAuth2 refresh_token expiry causes users to be unexpectedly logged out.
>
> **Root Cause / Motivation:** 15% of users who don't log in for more than 7 days are affected. Token expiry is not handled gracefully.
>
> **Approach Chosen:** Catch `TokenExpiredError` and re-authenticate with stored credentials.
>
> **Alternatives Considered & Why Discarded:** Extending token lifetime rejected for security reasons; forcing re-login rejected as poor UX.
>
> **Key Design Decisions:** Re-authenticate with stored credentials rather than prompting user; surface network/credential failures appropriately.
>
> **Problem:** OAuth2 refresh_token fails on expiry, causing unexpected logout for ≈15% of users who don't log in for more than 7 days.
>
> **Expected Behavior:** Automatically re-authenticate using stored credentials when refresh token expires.
>
> **Root Cause:** `refresh_token()` in `src/auth/oauth_client.py` catches `TokenExpiredError` but re-raises instead of calling `authenticate()`.
>
> **Fix Approach:** Catch `TokenExpiredError` and call `authenticate()` with stored credentials.
>
> **Side Effects:** None — existing refresh logic unchanged for valid tokens.
>
> **Success Criteria:**
> 1. ✅ Users with expired refresh tokens auto-re-authenticated
> 2. ✅ Auth failures surface appropriate error messages
> 3. ✅ No credentials logged or exposed
> 4. ✅ Existing refresh logic unchanged for valid tokens
>
> **Edge Cases:** Credentials no longer valid → prompt re-login. Network failure → propagate error. Rate limiting → backoff and retry.
>
> **Related Issues:** #100 (persistent sessions), #150 (token rotation)

**Why this works:** The problem affects real users, has a non-obvious root cause, and has multiple edge cases. The standard format provides enough structure for an agent to implement correctly without additional context. A fresh agent can pick this up and know exactly what to do.

### Comprehensive Bug Report (cross-cutting, multi-system)

For bugs that involve multiple systems, affect production users significantly, or have complex deployment considerations, use the full spec structure with context section, affected files table, root cause analysis with evidence, detailed edge cases, risk assessment, and phased implementation. The extra structure serves the complexity.

______________________________________________________________________

## Example 2: Feature Specification — Different Complexity Levels

### Minimal Feature Spec (single-function addition)

> **Objective:** Add `retry_count` parameter to `fetch_data()` in `src/api/client.py` so callers can control retry behavior.
>
> **Problem:** Currently `fetch_data()` retries indefinitely on transient failures, causing timeout cascades.
>
> **Success Criteria:**
> 1. ✅ `fetch_count(retry_count=3)` retries exactly 3 times then raises
> 2. ✅ Default behavior unchanged
> 3. ✅ Existing tests pass
>
> **Edge Cases:** retry_count=0 means no retries (fail immediately).

**Why this works:** The change is small, localized, and self-explanatory. A single paragraph covers the essential content areas. No need for affected files tables, risk assessments, or phased implementation — those would add noise, not value.

### Standard Feature Spec (multi-file change with dependencies)

> **Intent and Executive Summary**
>
> **Problem Statement:** Article metadata queries are slow, causing poor page load performance.
>
> **Root Cause / Motivation:** API calls average 150ms response time because queries hit PostgreSQL directly instead of a cache layer.
>
> **Approach Chosen:** Add Redis as a cache layer with 1-hour TTL and fallback to DB when Redis is unavailable.
>
> **Alternatives Considered & Why Discarded:** Memcached considered but Redis already deployed per infra team; in-memory cache rejected due to stateless deployment architecture.
>
> **Key Design Decisions:** 1-hour TTL balances freshness against cache hit rate; fallback to DB ensures availability over consistency.
>
> **Objective:** Add Redis caching layer for frequently accessed article metadata.
>
> **Problem:** Article metadata API calls average 150ms response time, causing slow page loads. 85% cache hit potential identified.
>
> **Context:** Current queries hit PostgreSQL directly. Most queries target the same ≈1000 recently-published articles. Article metadata changes infrequently. Redis already deployed per infra team.
>
> **Fix Approach:** Redis as cache layer with 1-hour TTL. Fallback to DB when Redis unavailable.
>
> **Affected Files:**
> | File | Anchor | Changes |
> |------|--------|---------|
> | `src/api/articles.py` | `get_article_metadata()` | Add cache check before DB query |
> | `src/cache/__init__.py` | new file | Redis client wrapper |
> | `src/config.py` | "Configuration" section | Add Redis connection config |
>
> **Constraints:** Must not exceed 512MB Redis memory. Must handle Redis unavailable gracefully.
>
> **Success Criteria:**
> 1. ✅ API response time <20ms for cached queries
> 2. ✅ Cache hit rate >80%
> 3. ✅ Graceful fallback when Redis unavailable
> 4. ✅ Cache invalidation on article update
>
> **Edge Cases:** Redis unavailable → fallback to DB. Cache full → LRU eviction. Article updated → invalidate entry.
>
> **Risk Assessment:** Redis memory limit (Low prob, High impact). Cache invalidation bugs (Med prob, Med impact).

**Why this works:** The change touches multiple files and has infrastructure dependencies. The standard format provides affected files, constraints, and risk assessment. Without these, an implementer might miss the Redis unavailable edge case or the memory constraint.

Documentation Sources section: standard and complex specs MUST include a table documenting where the spec author verified each factual claim. Minimal specs and simple bug reports may omit it:

> **Documentation Sources:**
> | Source Category | What Was Consulted | Purpose |
> |----------------|-------------------|---------|
> | Local docs | `README.md`, `docs/architecture.md` | Understand existing caching architecture |
> | Direct source search | `srclight_search_symbols("cache")`, `grep -r "redis" src/` | Identify existing cache patterns |
> | Documentation URLs | [redis-py docs](https://redis-py.readthedocs.io/) | Verify Redis client API signatures |
> | MCP search | `srclight_get_signature("get_article_metadata")` | Verify function signature for cache integration |
> | Live verification | `uv run pytest test/test_articles.py -k "metadata"` | Confirm test coverage before making changes |

### Comprehensive Feature Spec (large, cross-cutting change)

For features that span multiple systems, require phased deployment, or have significant risk, use the full structure with phased implementation, extended risk assessment with blast radius analysis, detailed decision rationale with alternatives, and dependencies table. The comprehensive format serves the complexity.

______________________________________________________________________

## Example 3: Guideline Update — Different Complexity Levels

### Minimal Guideline Update (adding a rule)

> **Problem:** Guidelines don't address when to use `--no-verify` with git commands.
>
> **Proposed Change:** Add prohibition to `000-critical-rules.md`.
>
> **Success Criteria:** Guidelines load correctly. Search finds new content.

**Why this works:** Small change, obvious impact, no architectural implications.

### Standard Guideline Update (philosophy or process change)

> **Problem:** Spec templates enforce rigid structure that causes agents to fill in sections mechanically rather than reasoning about what content each spec needs.
>
> **Current State:** `143-planning-spec-templates.md` presents complete templates as "use this template" and `spec-creation/tasks/create.md` provides a 12-section mandatory list that agents treat as required regardless of spec complexity.
>
> **Proposed Change:** Replace rigid templates with intent-driven prose guidelines and varied examples at different complexity levels.
>
> **Decision Rationale:** Templates trigger mechanical filling. Intent descriptions let agents reason about what structure serves each specific spec. The existing prose-driven skills (brainstorming, plan-fidelity-auditor) demonstrate this approach works.
>
> **Success Criteria:**
> 1. ✅ No mandatory templates remain
> 2. ✅ Examples show different valid structures for different complexity levels
> 3. ✅ Verification uses content-coverage questions, not section header checks

**Why this works:** The change has philosophical implications across multiple files. The standard format provides current state, proposed change, and decision rationale. A fresh agent can understand both what and why.

______________________________________________________________________

## Self-Containment Principles

Regardless of spec format (minimal, standard, or comprehensive), these principles apply to ALL specs:

| Principle | Why |
|-----------|-----|
| No "as discussed above" | A fresh agent has no memory of earlier conversation |
| Stable anchors, not line numbers | Line numbers break on every edit |
| Code snippets for key changes | Prevents misunderstandings about what code does |
| Related issues include summaries | Bare links without context are useless |
| Decision rationale documented | Without it, implementers may choose different approaches |

**Golden Rule:** If a new agent with no memory context cannot implement the spec correctly from the spec alone, the spec is incomplete — regardless of how well it follows any template.

______________________________________________________________________

## Sub-issue Structure (Multi-task Spec)

When a spec has multiple phases/tasks, each phase SHOULD be tracked as a separate sub-issue.

**Parent Issue:** Contains the full spec with all phases.

**Sub-issues CREATED:** One per phase, with descriptive titles referencing the parent.

**Single-task exemption:** When a spec has exactly one task, no sub-issues are required.

**See `issue-operations` skill → `link-sub-issue` task for the complete auto-create workflow and phase-level structure.**

______________________________________________________________________

*Source: Reframed from template compliance to varied valid structures per spec #821*

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-04-25T00:00:00Z"
rules:
  - id: spec-examples-001
    title: "Spec validity requires content coverage not section headers"
    conditions:
      all:
        - "spec_has_correct_headers == true"
        - "content_areas_covered == false"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [spec-creation, spec-auditor]
    source: "144-planning-spec-examples.md §Key principle"

  - id: spec-examples-002
    title: "Specs must be self-contained for fresh agents"
    conditions:
      all:
        - "fresh_agent_can_implement == false"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [spec-creation, spec-auditor]
    source: "144-planning-spec-examples.md §Self-Containment Principles"

  - id: spec-examples-003
    title: "Multi-task specs require sub-issue structure"
    conditions:
      all:
        - "spec_has_multiple_phases == true"
        - "sub_issues_exist == false"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [issue-operations]
    source: "144-planning-spec-examples.md §Sub-issue Structure"

  - id: spec-examples-004
    title: "Single-task specs exempt from sub-issue requirement"
    conditions:
      all:
        - "spec_task_count == 1"
    actions:
      - PROCEED
    conflicts_with: []
    requires: []
    triggers: [issue-operations]
    source: "144-planning-spec-examples.md §Sub-issue Structure"
```