# SPEC: completion-core Skill Description Compliance Fix

## Problem Summary

completion-core SKILL.md fails audit #1384 on three dimensions: D2 FAIL (description does not map to actual TDT dispatch triggers), D3 INCOMPLETE (does not cover all TDT conditions), and D4 FAIL ("MUST be clear and structured" addresses output quality, not dispatch requirement).

## Current Description

> Use when completing skill task workflows with push, URL generation, lifecycle event append, and executive summary reporting. Completion signals MUST be clear and structured — always required.

## Proposed Description

> Use when signaling workflow completion after a sub-agent returns: pushing branches, generating URLs, or appending lifecycle events. Dispatch via skill() + task() — REQUIRED for all audit completions.

## Required Action

Update the `description` field in `.opencode/skills/completion-core/SKILL.md` frontmatter to use the proposed text above.
