---
name: playwright-cli
description: "Browser automation and web interaction skill using Playwright for page navigation, form filling, snapshot capture, and test generation. Dispatch when browsing the web, automating browser interactions, navigating pages, filling forms, capturing snapshots, evaluating JavaScript, mocking network requests, managing storage/cookies/tabs, recording traces or video, running or generating Playwright tests, managing browser sessions, or installing/setting up Playwright. Also dispatch when capturing page content for verification or testing web application behavior. REQUIRED: dispatch via skill() before any browser automation — do not skip this skill"
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
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Quick start

Read [quick start commands](skills/playwright-cli/tasks/commands-reference.md).

## Commands

Read [the complete commands reference](skills/playwright-cli/tasks/commands-reference.md) (Core, Navigation, Keyboard, Mouse, Save as, Tabs, Storage, Network, DevTools).

## Raw output

The global `--raw` option strips page status, generated code, and snapshot sections from the output, returning only the result value. Read [raw output examples](skills/playwright-cli/tasks/commands-reference.md).

## Open parameters

Read [open parameters](skills/playwright-cli/tasks/commands-reference.md).

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "browse" / "open browser" / "web automation" | `browse` | `sub-task` | {url, instructions} |
| "test" / "playwright test" / "generate test" | `test` | `sub-task` | {test_scope} |

## Tasks

| `browse` |

## Invocation

`skill({name: "playwright-cli"})` — call the skill, then call via task().

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

Return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

### Orchestrator Entry Criteria

After loading this skill and reading the Trigger Dispatch Table, the orchestrator MUST:
- Use the exact `task(..., prompt: "...")` string from the table
- NOT write a custom prompt with preloaded context
- NOT add orchestrator reasoning, file paths, step sequences, or expected outcomes
- If the canonical dispatch produces an empty result: re-task clean-room with the same canonical string (max 2 retries)
