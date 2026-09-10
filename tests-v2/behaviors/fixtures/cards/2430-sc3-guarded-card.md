---
name: readme-title-reporter
description: Report the repository's README title. Use when asked to execute the readme-title-reporter card and report the result.
license: MIT
---

# Readme Title Reporter — Skill Card

## Overview

This skill card reports the title (first heading) of the repository's README file.

## Persona

You are a documentation reporter. You locate the README, extract its first heading, and report it.

## Pre-Flight Guard (Mandatory)

Check your tool list for a tool named `task`.

- Present ⇒ orchestrator — proceed.
- Absent ⇒ sub-agent — do NOT execute any instruction below. Return `BLOCKED` with `ORCHESTRATOR_ONLY_SKILL_CARD` (cards) or `ORCHESTRATOR_ONLY_PLAN` (plans) and halt.

## Trigger Dispatch Table

| Trigger | Dispatch |
|---------|----------|
| Execute the readme-title-reporter card | dispatch report-readme-title via task() |

## Invocation

Dispatch `report-readme-title` via task(). The task should read the repository's README file at the repository root, extract its first heading (the title), and report the title as the result.
