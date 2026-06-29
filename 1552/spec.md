# [SPEC-FIX] Remove 'simple specs may skip' complexity classification escape hatch in spec-creation

**Issue:** https://github.com/michael-conrad/.opencode/issues/1552

## Executive Summary

Remove the minimal/standard/complex tiered structure from `spec-creation/tasks/write.md`. All specs MUST include the same mandatory sections. No complexity-based exemption from spec completeness.

## Problem

The tiered structure (minimal/standard/complex) with "MAY" language gives the agent broad discretion to decide what a spec needs. The agent self-classifies as "minimal" and skips mandatory sections (preamble, documentation sources, edge cases).

## Fix

- Line 178: Replace "Simple specs may skip this section." with "This section is MANDATORY for all specs."
- Lines 389-391: Remove minimal/standard/complex tiered structure. Replace with: "All specs MUST include: Intent and Executive Summary (mandatory preamble), Problem, Context, Fix Approach, Success Criteria, Edge Cases, Documentation Sources."

## Files Affected

- `spec-creation/tasks/write.md` line 178
- `spec-creation/tasks/write.md` lines 389-391

## Behavioral Test

Prompt agent to create a "minimal bug-fix spec." Assert agent includes all mandatory sections (preamble, documentation sources, etc.).

## Dependencies

None.
