## Problem

When implementing code, the AI agent routinely skips creating tests. Instead of writing a TestNG/JUnit test first (RED), then implementing (GREEN), it uses file-existence checks (`ls`) or grep-based pattern matching as "verification." This produces code that is structurally present but behaviorally unverified.

## Root Cause

The agent's default behavior is to treat "verification" as structural checks (file exists, grep for pattern) rather than behavioral tests (write a test, run it, confirm PASS). This is a systemic issue in the agent's implementation pipeline — it defaults to the cheapest verification method instead of the correct one.

## Evidence

- WeekliesPDFs issue #2: Plan steps originally called for "grep-based verification" and "file-existence checks" instead of TestNG tests. The project has TestNG configured in root `build.gradle` and submodules, with existing tests in xBaseJ, SHARED-DAO, NewsRxUI, DaoCore2, etc.
- The agent's coherence gate and plan writer both accepted structural-only verification without flagging the missing tests.
- The agent's `writing-plans` skill produced RED steps that said "Write a compilation test or grep-based verification" — an either/or that defaults to the wrong choice.

## Expected Behavior

1. Every implementation step MUST follow TDD: write a test first (RED), implement (GREEN), verify test passes
2. Use the project's existing test framework (TestNG, JUnit) — do not invent new frameworks
3. Do NOT accept file-existence checks or grep as substitutes for behavioral tests
4. The plan writer MUST NOT produce RED steps with either/or language that allows skipping test creation
5. The coherence gate MUST flag plans that lack test creation steps

## Severity

High — produces code that is structurally present but behaviorally unverified. Defects are discovered downstream instead of at implementation time.