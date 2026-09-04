---
name: playwright-cli
description: "Browser automation and web interaction using Playwright for page navigation, form filling, snapshot capture, and test generation. Load via skill() when browsing the web, automating browser interactions, navigating pages, filling forms, capturing snapshots, evaluating JavaScript, mocking network requests, managing storage/cookies/tabs, recording traces or video, running or generating Playwright tests, managing browser sessions, or installing/setting up Playwright. Also load when capturing page content for verification or testing web application behavior. REQUIRED: dispatch via skill() before any browser automation — do not skip this skill. User phrases: browse web, automate browser, fill form, capture snapshot, run Playwright test"
allowed-tools: Bash(playwright-cli:*) Bash(npx:*) Bash(npm:*)
license: Apache-2.0
compatibility: opencode
upstream: https://github.com/microsoft/playwright-cli
upstream_license: Apache-2.0
---

# Browser Automation with playwright-cli

## Persona

Browser automator. Routes browser interaction scripts to sub-agents that independently execute in isolated contexts. An orchestrator that runs browser automation inline instead of dispatching to execution sub-agents has produced a shared-context test, not an isolated verification — every interaction carries state contamination from previous steps, and the isolation that makes browser tests reliable is lost. Professional automators dispatch to isolated sub-agents. Inlining means no test was ever independently executed.

## Worktree Mode

This skill operates in the main repo directory (direct-branch mode). When `WORKTREE_REQUIRED` is set, all file operations MUST prefix paths with `worktree.path`.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Execute each workflow step in the orchestrator's own context per the Trigger Dispatch Table Dispatch value; dispatch a step's task card via `task()` only where the step's Dispatch value is `task-card`
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Quick start

Read [quick start commands](skills/playwright-cli/tasks/commands-reference.md).

## Commands

Read [the complete commands reference](skills/playwright-cli/tasks/commands-reference.md) (Core, Navigation, Keyboard, Mouse, Save as, Tabs, Storage, Network, DevTools).

## Raw output

The global `--raw` option strips page status, generated code, and snapshot sections from the output, returning only the result value. Read [raw output examples](skills/playwright-cli/tasks/commands-reference.md).

## Open parameters

Read [open parameters](skills/playwright-cli/tasks/commands-reference.md).

## Pre-Flight Guard (Mandatory)

**This skill card is orchestrator-only routing metadata.**

If you are a sub-agent (dispatched via `task()`), you MUST NOT consume the routing metadata below. Sub-agents cannot call `task()` and cannot execute orchestrator-level dispatch instructions. Return `BLOCKED` with reason `ORCHESTRATOR_ONLY_SKILL_CARD` and halt.

If you are the orchestrator (loaded this card via `skill({name: "..."})`), proceed to the Workflows section.

## Workflows

### Browse the web

When the agent needs to open a browser, navigate to a page, or perform web automation.

- [ ] 1. **browse** — Opens a browser and navigates to a URL with instructions
  - **Prompt:** `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [browse the web with playwright-cli](.opencode/skills/playwright-cli/tasks/commands-reference.md). url: ", url, ", instructions: ", instructions))`
**Context passed:** `{url, instructions}`
**Returns:** `{status, finding_summary, artifact_path, blocker_reason}`
**Execution mode:** sub-agent dispatch

### Generate a Playwright test

When the agent needs to generate a Playwright test or run a Playwright test.

- [ ] 1. **test** — Generates a Playwright test for the given scope
  - **Prompt:** `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [generate playwright tests](.opencode/skills/playwright-cli/tasks/commands-reference.md). test_scope: ", test_scope))`
**Context passed:** `{test_scope}`
**Returns:** `{status, finding_summary, artifact_path, blocker_reason}`
**Execution mode:** sub-agent dispatch

## Sub-Agent Routing

Sub-agents run via `task(subagent_type="general")` with `{ url, instructions, worktree.path, github.owner, github.repo }`. No inline work.

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

The orchestrator MUST NOT preload execution context into `task()` prompts. Every sub-agent MUST independently discover scope and produce its own result contract.

### Sub-Agent Entry Criteria

A sub-agent receiving a `task()` prompt MUST reject it if the prompt contains:
- Inline file paths to task files
- Inline step or procedure definitions
- Expected outcome structures or schema constraints
- Pre-loaded evidence or orchestrator-derived conclusions

### Orchestrator Entry Criteria

Reading the Workflows section in the orchestrator's own context is small, necessary, routing-relevant work assigned to the orchestrator by allocation-by-context-cost: the skill card is routing metadata the orchestrator must hold, and sub-agents cannot call `skill()` or load skills. The no-preloaded-context substance below is unchanged.

After loading this skill and reading the Workflows section, the orchestrator MUST:
- Use the exact `task(..., prompt: "...")` string from the table
- NOT write a custom prompt with preloaded context
- NOT add orchestrator reasoning, file paths, step sequences, or expected outcomes
- If the canonical dispatch produces an empty result: re-task clean-room with the same canonical string (max 2 retries)
