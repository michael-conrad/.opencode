# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
"""RED (issue 2446, item 5): `_normalize_labels` unit test.

Asserts the pure label-normalization helper in the `local-issues` tool:
- comma-separated input `['a, b']` splits to `['a', 'b']`
- single clean token `['needs-approval']` passes through unchanged

Runs against an isolated copy of the tool script, importing the helper
without touching any real `.issues/` state.

The test fails at RED because `_normalize_labels` does not exist yet.

Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
"""

import importlib.util
import shutil
import subprocess
import sys
from pathlib import Path

import pytest

TOOL_NAME = "local-issues"
REPO_ROOT = Path(__file__).resolve().parents[3]
TOOL_PATH = REPO_ROOT / ".opencode" / "tools" / TOOL_NAME


@pytest.fixture(scope="module")
def local_issues_module():
    """Load the local-issues script as an importable module (isolated copy)."""
    assert TOOL_PATH.is_file(), f"tool not found at {TOOL_PATH}"
    sandbox = Path(__file__).resolve().parent / "__pycache__"
    sandbox.mkdir(exist_ok=True)
    copy = sandbox / f"{TOOL_NAME}-import-target.py"
    shutil.copy(TOOL_PATH, copy)
    spec = importlib.util.spec_from_file_location(TOOL_NAME.replace("-", "_"), copy)
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def test_normalize_labels_splits_comma_separated(local_issues_module):
    assert local_issues_module._normalize_labels(["a, b"]) == ["a", "b"]


def test_normalize_labels_passes_single_token(local_issues_module):
    assert local_issues_module._normalize_labels(["needs-approval"]) == [
        "needs-approval"
    ]


if __name__ == "__main__":
    sys.exit(pytest.main([__file__]))
