<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->
<!-- Co-authored with AI: OpenCode (deepseek-v4-flash-free) -->

# Research Card: create.md Remote Issue Body Format Defect

## Research Question
What is the correct remote issue body format for spec-creation/tasks/create.md, given contradictory definitions in Step 7r and Step 7a?

## Finding
The cards-based format (Exec Summary → Cards → Key Decisions → Risk Callouts → AI Agent Instructions) from Step 7a is correct. Step 7r's 6-part flat format (Problem/Scope/Approach/Impact) is redundant and will be removed.

## Resolutions

### 1. Remote format choice (2026-07-12)
- Remove Step 7r's 6-part flat format — structurally incompatible with cards format
- Merge Step 7r's AI Agent Instructions, URL rules, constraints table into Step 7a
- No explicit "Out of Scope" section needed — dependency ordering in Cards suffices
- Step 7a becomes the single authoritative remote format definition

### 2. Preamble/compliance boundary (2026-07-12)
- STATUS/CREATED/License/Provenance preamble → local `.issues/{N}/spec.md` only
- Compliance blockquote → local `.issues/{N}/spec.md` only
- Remote issue body gets neither — purely exec summary cards format

## References
- `.opencode/skills/spec-creation/tasks/create.md` lines 611–669 (Step 7r), 697–736 (Step 7a)
- Issue #1877 (canonical format example)
- Issue #1900 (previously had wrong format, corrected to match)

## Confidence
- Confidence: 0.95
- Tags: create.md, spec-creation, remote-format, step-7r, step-7a
