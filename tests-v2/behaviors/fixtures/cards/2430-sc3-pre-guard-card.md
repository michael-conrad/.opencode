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

## Pre-Flight Guard

The orchestrator should be careful about context when using this card. Sub-agents should generally be dispatched via task() for execution work, and skill cards like this one are normally loaded by the orchestrator before any sub-agent dispatch happens. The orchestrator is responsible for routing and should keep the card in its own context rather than forwarding it. Keeping this division of labor in mind helps produce good results.

## Trigger Dispatch Table

| Trigger | Dispatch |
|---------|----------|
| Execute the readme-title-reporter card | dispatch report-readme-title via task() |

## Invocation

Dispatch `report-readme-title` via task(). The task should read the repository's README file at the repository root, extract its first heading (the title), and report the title as the result.
