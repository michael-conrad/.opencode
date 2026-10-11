<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2567 — rubric relocated from the retired vision-specialist agent card, reframed caller-agnostic -->

# Vision Critique Rubric

A caller-agnostic standard for visual analysis and design review — usable by
the invoking agent reading images natively and by any subagent dispatched for
the work.

**Image-as-file-path mechanics:** subagents do not receive image data inline —
they receive file paths and must read the images themselves. When dispatching
vision work to a subagent, pass image paths; the primary reading natively gets
the image directly. Either way, the analysis rules below are identical.

**Probe capability when unknown:** before assuming a model can see, check it —
`ollama show <model>` for a local/cloud Ollama model's capabilities, or
`opencode models` for what the provider catalog resolves.

## Image resolution and detail (read this first)

Image quality is set by the caller, not by the analyzer. Generation settings
(temperature, top_p) control generation only — they cannot change how an image
is resized or tiled before it reaches the model.

Before answering, assess whether the supplied resolution is adequate for the
task:

- Fine detail (small print, hairline rules, icon glyphs, screen text under
  ~10px on a 1920x1080 capture, a full newsletter page) requires a high
  resolution input. If the image is visibly downsampled or illegible at the
  region you must read, do not guess.
- Ask the caller to re-provide the image at higher resolution, crop/zoom the
  region of interest, or split a dense document into per-region captures.
  A focused crop is often more useful than a single downsampled full frame.
- Never fabricate detail you cannot see. If text or layout is illegible at
  the supplied resolution, say so explicitly instead of guessing. State the
  resolution you were given and what you could and could not verify.

## Core workflow

1. **Look before you conclude.** Describe the artifact's structure in your own
   words (layout, hierarchy, visual weight, color, spacing, typography) before
   offering judgment. This forces genuine analysis rather than pattern-matching.
2. **Be exhaustive, not generic.** Inventory every distinct visual element:
   headers, body text, images, captions, dividers, footers, buttons, icons,
   whitespace. For design work, note alignment, contrast ratios, and spacing
   relationships.
3. **Quote evidence.** When you cite a problem (or a strength), anchor it to a
   concrete location: region of the image, approximate coordinates, the exact
   text you are reading, or the color values. A critique with no anchor is not
   usable.
4. **Separate facts from recommendations.** Report what you observe as
   observations; propose changes as recommendations. Never blur the two.
5. **State confidence.** Distinguish what you are certain of, what you
   inferred, and what you could not verify.

## Task-specific standards

### Design review / critique
- Evaluate against explicit criteria: hierarchy, alignment, whitespace, color
  contrast (call out WCAG AA/AAA at risk), typography, responsiveness cues.
- Give a prioritized findings list: Critical / Major / Minor / Nit.
- End with concrete, actionable change suggestions, not vague praise.

### Screenshot / UI analysis
- Read and transcribe visible text accurately. Flag truncated or clipped text.
- Identify components and their state (enabled, disabled, hover, selected, error).
- Note accessibility signals: focus indicators, alt-text presence, contrast.

### Document / PDF page inspection
- Transcribe the reading order. Preserve heading levels and body/table structure.
- Flag layout anomalies: overlapping elements, misaligned columns, broken
  tables, orphaned text, clipped margins.
- Report OCR-sensitive content (small type, ligatures, special glyphs) and
  whether it was legible.

### General visual QA
- Compare against the described intent. List every discrepancy, however minor.
- Provide a pass/fail verdict per check item with evidence.

## Output discipline
- Use clear section headings. Prefer tables or bullet lists over prose walls.
- Lead with the most important finding. Do not bury the critical issue.
- If asked for a decision (approve / reject / needs work), give one, with
  reasons.
- Keep tone professional and specific. No filler, no generic praise, no
  hedging where you have evidence.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
