---
name: godot
description: "Load when building, running, or exporting a Godot project — working with its scenes, resources, and project configuration, running it without a display, or producing export builds."
license: MIT
provenance: AI-authored, .opencode#2557
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2557; CLI surface verified against live Godot 4.x docs 2026-10-07 -->

# godot

This card owns Godot project work as a build/run concern: running the project,
importing resources, and producing export builds. Verified against the Godot
4.x command-line documentation (4.7 era, 2026-10-07); the CLI surface is stable
across 4.5–4.7.

## Running the project

- Run the project (main scene) without a display:
  `godot --headless` — headless implies the headless display driver and a dummy
  audio driver.
- Run a specific scene: `godot <scene.tscn>` (positional path), or
  `godot --scene <path-or-uid>`. Target the project directory with
  `--path <dir>` (or `--upwards` when the working directory is a
  subdirectory of the project).

## Importing resources

- Import/refresh the project's resources headlessly (CI, first checkout):
  `godot --headless --import` — starts the editor, imports resources, then
  quits (`--import` implies `--editor` and `--quit`). Run this before headless
  test/export runs on a fresh tree so imported resources exist.

## Exporting builds

- Export presets live in **`export_presets.cfg`** in the project root; each
  preset carries a developer-chosen name.
- Produce a release export:
  `godot --headless --export-release "<PresetName>" <output-path>` — the
  preset name must match `export_presets.cfg` exactly (quote names with
  spaces); the output path is relative to the project directory and must
  include the output filename; the target directory must exist.
- Variants: `--export-debug` (debug template), `--export-pack` (PCK/ZIP chosen
  by output extension), `--export-patch <preset> <path>` with `--patches` for
  patched packs. Debug/pack exports imply `--import` first.
- Exporting requires an editor binary plus installed export templates.

## Canonical-command sourcing

Run/export commands come from the repository's declared build manifest — ask
when the manifest does not declare them; never guess. Godot projects typically
declare the editor version and the export preset names the project ships with.

## Build/run-relevant structure

- `project.godot` is the project declaration; scenes (`.tscn`) and resources
  reference each other by path or UID — moving files means updating
  references (the editor's import step fixes up most of it; verify with a
  headless import).
- GDScript conventions matter here only where they touch build/run behavior
  (e.g. autoload singletons and scene paths); broader language conventions
  await a dedicated card on evidence.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
