# Spec: Missing Automated Label Application During Remote Platform Issue Creation (Issue #1538)

**Source:** .opencode/.issues/1550/findings.md  
**Created:** 2026-06-27  
**Parent:** [#1384](https://github.com/michael-conrad/.opencode/issues/1384) (sub-issue)

## Problem

On creation via github-mcp or gitbucket-api platforms, no `needs-approval` / `approved-for-*` labels are applied to new issue. Local platform works correctly (passes concrete labels); remote platforms pass empty label array.

## Root Cause

`creation.md` Step 2.1 says "pass labels" but specifies no values; approval-gate references non-existent `apply-label` task.

## Required Actions

1. Add concrete label specification to creation.md Step 2.1 for github-mcp and gitbucket-api platforms
2. Create approval-gate apply-label task file implementing approved-for-* label application based on authorization scope
