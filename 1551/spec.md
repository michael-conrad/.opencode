# [SPEC-FIX] Remove 'simple specs may omit' documentation sources escape hatch in verification-enforcement

**Issue:** https://github.com/michael-conrad/.opencode/issues/1551

## Executive Summary

Remove "Simple specs may omit it" from `verification-enforcement/SKILL.md:15`. Documentation Sources section is MANDATORY for ALL specs.

## Problem

The agent self-classifies a spec as "simple" and omits the mandatory Documentation Sources section that documents live-source verification. This weakens the verification-enforcement mandate.

## Fix

Replace "Simple specs may omit it." with "This section is MANDATORY for ALL specs."

## Files Affected

- `verification-enforcement/SKILL.md` line 15

## Behavioral Test

Prompt agent to create a "simple spec." Assert agent includes Documentation Sources section with live-source verification evidence.

## Dependencies

None.
