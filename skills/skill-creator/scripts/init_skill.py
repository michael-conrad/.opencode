#!/usr/bin/env -S uv run --script
# fmt: off
"exec" "uv" "run" "--script" "$0" "$@" # MUST GO BEFORE PEP 723 HEADER

# PEP 723 HEADER MUST BE AFTER BASH GUARD
# /// script
# requires-python = "~=3.12"
# dependencies = []
# ///

# fmt: on
"""
Skill Initializer - Creates a new skill from template

Usage:
    uv run .opencode/skills/skill-creator/scripts/init_skill.py <skill-name> --path <path>

Examples:
    uv run .opencode/skills/skill-creator/scripts/init_skill.py my-new-skill --path .opencode/skills
    uv run .opencode/skills/skill-creator/scripts/init_skill.py my-api-helper --path .opencode/skills
    uv run .opencode/skills/skill-creator/scripts/init_skill.py custom-skill --path /custom/location
"""

import sys
from pathlib import Path

SKILL_TEMPLATE = """---
name: {skill_name}
description: "[TODO: Use when ...]"
license: MIT
provenance: AI-generated
---

# {skill_title}

## Overview

[TODO: 1-2 sentences explaining what this skill enables. No procedure text.]

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work
     that should be delegated to a sub-agent produces defective
     deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless
     explicitly marked as inline/orchestrator in this skill
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`,
     `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Trigger Dispatch Table

- [ ] **"[TODO: trigger phrase]"** → `[TODO: task-name]` (dispatch-type)
  - Context: `{field1, field2}`
  - Task file: `{skill_name}/tasks/[TODO: task-name].md`

## Invocation

`skill({name: "{skill_name}"})` — call the skill, then call via task():

- [ ] **`[TODO: task-name]`** → `task(..., prompt: "execute [TODO: task-name] task from {skill_name}")`

**CLI equivalent (for human TUI use):** `/skill {skill_name} --task <task>`

## Sub-Agent Routing

- Standard context: `{{worktree.path, github.owner, github.repo, authorization_scope, halt_at, pr_strategy, pipeline_phase}}`
- Exclusions: orchestrator reasoning, expected outcomes, inline file paths, agent memory, cached verification results
- Auditor tasks use subagent_type from `resolve-models` result contract — NOT `general`
- `pre-analysis` receives only `{{issue_number, task_description, github.owner, github.repo}}`

## Cross-References

Skills: [TODO: related skills]. Guidelines: [TODO: related guidelines].
"""

EXAMPLE_SCRIPT = '''#!/usr/bin/env python3
"""
Example helper script for {skill_name}

This is a placeholder script that can be executed directly.
Replace with actual implementation or delete if not needed.

Example real scripts from other skills:
- pdf/scripts/fill_fillable_fields.py - Fills PDF form fields
- pdf/scripts/convert_pdf_to_images.py - Converts PDF pages to images
"""

def main():
    print("This is an example script for {skill_name}")
    # TODO: Add actual script logic here
    # This could be data processing, file conversion, API calls, etc.

if __name__ == "__main__":
    main()
'''

EXAMPLE_REFERENCE = """# Reference Documentation for {skill_title}

This is a placeholder for detailed reference documentation.
Replace with actual reference content or delete if not needed.

Example real reference docs from other skills:
- product-management/references/communication.md - Comprehensive guide for status updates
- product-management/references/context_building.md - Deep-dive on gathering context
- bigquery/references/ - API references and query examples

## When Reference Docs Are Useful

Reference docs are ideal for:
- Comprehensive API documentation
- Detailed workflow guides
- Complex multi-step processes
- Information too lengthy for main SKILL.md
- Content that's only needed for specific use cases

## Structure Suggestions

### API Reference Example
- Overview
- Authentication
- Endpoints with examples
- Error codes
- Rate limits

### Workflow Guide Example
- Prerequisites
- Step-by-step instructions
- Common patterns
- Troubleshooting
- Best practices
"""

EXAMPLE_ASSET = """# Example Asset File

This placeholder represents where asset files would be stored.
Replace with actual asset files (templates, images, fonts, etc.) or delete if not needed.

Asset files are NOT intended to be loaded into context, but rather used within
the output <AgentName> produces.

Example asset files from other skills:
- Brand guidelines: logo.png, slides_template.pptx
- Frontend builder: hello-world/ directory with HTML/React boilerplate
- Typography: custom-font.ttf, font-family.woff2
- Data: sample_data.csv, test_dataset.json

## Common Asset Types

- Templates: .pptx, .docx, boilerplate directories
- Images: .png, .jpg, .svg, .gif
- Fonts: .ttf, .otf, .woff, .woff2
- Boilerplate code: Project directories, starter files
- Icons: .ico, .svg
- Data files: .csv, .json, .xml, .yaml

Note: This is a text placeholder. Actual assets can be any file type.
"""

def title_case_skill_name(skill_name):
    """Convert hyphenated skill name to Title Case for display."""
    return " ".join(word.capitalize() for word in skill_name.split("-"))

def init_skill(skill_name, path):
    """
    Initialize a new skill directory with template SKILL.md.

    Args:
        skill_name: Name of the skill
        path: Path where the skill directory should be created

    Returns:
        Path to created skill directory, or None if error
    """
    # Determine skill directory path
    skill_dir = Path(path).resolve() / skill_name

    # Check if directory already exists
    if skill_dir.exists():
        print(f"❌ Error: Skill directory already exists: {skill_dir}")
        return None

    # Create skill directory
    try:
        skill_dir.mkdir(parents=True, exist_ok=False)
        print(f"✅ Created skill directory: {skill_dir}")
    except Exception as e:
        print(f"❌ Error creating directory: {e}")
        return None

    # Create SKILL.md from template
    skill_title = title_case_skill_name(skill_name)
    skill_content = SKILL_TEMPLATE.format(
        skill_name=skill_name, skill_title=skill_title
    )

    skill_md_path = skill_dir / "SKILL.md"
    try:
        skill_md_path.write_text(skill_content)
        print("✅ Created SKILL.md")
    except Exception as e:
        print(f"❌ Error creating SKILL.md: {e}")
        return None

    # Create resource directories with example files
    try:
        # Create scripts/ directory with example script
        scripts_dir = skill_dir / "scripts"
        scripts_dir.mkdir(exist_ok=True)
        example_script = scripts_dir / "example.py"
        example_script.write_text(EXAMPLE_SCRIPT.format(skill_name=skill_name))
        example_script.chmod(0o755)
        print("✅ Created scripts/example.py")

        # Create references/ directory with example reference doc
        references_dir = skill_dir / "references"
        references_dir.mkdir(exist_ok=True)
        example_reference = references_dir / "api_reference.md"
        example_reference.write_text(EXAMPLE_REFERENCE.format(skill_title=skill_title))
        print("✅ Created references/api_reference.md")

        # Create assets/ directory with example asset placeholder
        assets_dir = skill_dir / "assets"
        assets_dir.mkdir(exist_ok=True)
        example_asset = assets_dir / "example_asset.txt"
        example_asset.write_text(EXAMPLE_ASSET)
        print("✅ Created assets/example_asset.txt")
    except Exception as e:
        print(f"❌ Error creating resource directories: {e}")
        return None

    # Print next steps
    print(f"\n✅ Skill '{skill_name}' initialized successfully at {skill_dir}")
    print("\nNext steps:")
    print("1. Edit SKILL.md to complete the TODO items and update the description")
    print(
        "2. Customize or delete the example files in scripts/, references/, and assets/"
    )
    print("3. Run the validator when ready to check the skill structure")

    return skill_dir

def main():
    if len(sys.argv) < 4 or sys.argv[2] != "--path":
        print(
            "Usage: uv run .opencode/skills/skill-creator/scripts/init_skill.py <skill-name> --path <path>"
        )
        print("\nSkill name requirements:")
        print("  - Hyphen-case identifier (e.g., 'data-analyzer')")
        print("  - Lowercase letters, digits, and hyphens only")
        print("  - Max 40 characters")
        print("  - Must match directory name exactly")
        print("\nExamples:")
        print(
            "  uv run .opencode/skills/skill-creator/scripts/init_skill.py my-new-skill --path .opencode/skills"
        )
        print(
            "  uv run .opencode/skills/skill-creator/scripts/init_skill.py my-api-helper --path .opencode/skills"
        )
        print(
            "  uv run .opencode/skills/skill-creator/scripts/init_skill.py custom-skill --path /custom/location"
        )
        sys.exit(1)

    skill_name = sys.argv[1]
    path = sys.argv[3]

    print(f"🚀 Initializing skill: {skill_name}")
    print(f"   Location: {path}")
    print()

    result = init_skill(skill_name, path)

    if result:
        sys.exit(0)
    else:
        sys.exit(1)

if __name__ == "__main__":
    main()

