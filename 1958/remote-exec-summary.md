> **Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/1958/**
>
> **Local artifacts:** `.opencode/.issues/1958/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

The `Read [Text](path)` cross-reference pattern in guidelines is meant to trigger the agent to call the `read` tool on linked files. However, it is unknown which imperative verb form (Read, Load, Fetch, Consult, Open, etc.) most reliably causes the agent to actually invoke the `read` tool — as opposed to relying on memory, training data, or using grep/search as a substitute. A systematic comparison is needed to determine the winning verb form.

## Goals

- Identify which imperative verb form most reliably triggers the `read` tool on linked files
- Produce a test record table with empirical results across 10 candidate verb forms
- Define a repeatable methodology for testing verb variants

## Non-Goals

- Not testing non-imperative forms (declarative, passive voice)
- Not testing the effectiveness of the cross-reference pattern itself (only verb variants)
- Not implementing the winning form in guidelines — that is a follow-up implementation spec

## Scope

- 10 candidate imperative verb forms tested against the default model (qwen3.6:35b-256k)
- Test methodology using existing `test-verb-variant.sh` infrastructure
- Test record table with columns: Verb, Directive text, Model, Did agent call read on target file?, Did agent use grep/search instead?, Did agent use other tool?, Time, Notes

## Approach

Define a candidate verb list (Read, Load, Fetch, Consult, Open, Retrieve, Access, Follow instructions in, Check, Look up), run each variant 2 times through the existing `test-verb-variant.sh` harness, record results in a structured table, and identify the winning verb form for subsequent implementation in guidelines and `default.txt`.

## Impact

- Risk: Model behavior may vary across runs — each variant tested 2 times minimum
- Risk: The `test-verb-variant.sh` script may need minor modifications — documented if so
- Key dependency: Working opencode CLI with `qwen3.6:35b-256k` model
- Call to action: Review and approve this spec to begin systematic testing
