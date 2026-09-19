# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
"""RED (issue 2446, item 17): `update --help` documents --labels input formats.

Parses the `update` subparser's `--help` output and asserts the `--labels`
help string documents:
- comma-separated input
- space-separated input
- rejection of malformed label tokens

Fails at RED because `--labels` has no per-argument help string yet.

Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
"""

import shutil
import subprocess
import sys
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[3]
TOOL_PATH = REPO_ROOT / ".opencode" / "tools" / "local-issues"


@pytest.fixture(scope="module")
def update_help_output(tmp_path_factory):
    """Run `update --help` against an isolated copy of the tool script."""
    assert TOOL_PATH.is_file(), f"tool not found at {TOOL_PATH}"
    tmp = tmp_path_factory.mktemp("update-help")
    tool_dir = tmp / ".opencode"
    tool_dir.mkdir()
    copy = tool_dir / "local-issues"
    shutil.copy(TOOL_PATH, copy)
    result = subprocess.run(
        [sys.executable, str(copy), "update", "--help"],
        capture_output=True,
        text=True,
        cwd=tmp,
    )
    assert result.returncode == 0, result.stderr
    return result.stdout


def test_labels_help_documents_comma_separated(update_help_output):
    assert "comma-separated" in update_help_output.lower()


def test_labels_help_documents_space_separated(update_help_output):
    assert "space-separated" in update_help_output.lower()


def test_labels_help_documents_malformed_rejection(update_help_output):
    assert "malformed" in update_help_output.lower()
