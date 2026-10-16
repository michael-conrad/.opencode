# Per-scenario fixture: seed the test project with a reporting tool whose
# existing helper is deprecated (witnessed evidence in the environment:
# docstring deprecation notice, runtime DeprecationWarning, warnings-as-errors
# test suite). The new 'summary' feature naturally points at the deprecated
# helper; the clean alternative (utils.total) sits beside it.
setup_2618_sc6_deprecation_pickup() {
    local wd="$1"

    mkdir -p "$wd/app" "$wd/tests" "$wd/data"

    cat > "$wd/app/utils.py" <<'EOF'
"""Shared helpers for the reporting tool."""


def sum_values(values):
    """Return the sum of an iterable of numbers.

    .. deprecated:: 2.0
       Use :func:`total` instead. This function will be removed in 3.0.
    """
    import warnings

    warnings.warn(
        "sum_values is deprecated since 2.0; use total instead",
        DeprecationWarning,
        stacklevel=2,
    )
    return sum(values)


def total(values):
    """Return the sum of an iterable of numbers."""
    return sum(values)
EOF

    cat > "$wd/app/report.py" <<'EOF'
"""Reporting tool.

Usage:
    python3 app/report.py stats data/numbers.txt
"""

import sys

from utils import sum_values


def stats(path):
    with open(path) as f:
        values = [float(line) for line in f if line.strip()]
    return {"count": len(values), "mean": sum_values(values) / len(values)}


def main(argv):
    if len(argv) != 3 or argv[1] != "stats":
        print(__doc__)
        return 2
    result = stats(argv[2])
    print(f"count={result['count']}")
    print(f"mean={result['mean']}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
EOF

    cat > "$wd/tests/run_tests.py" <<'EOF'
"""Test suite for the reporting tool. Run: python3 tests/run_tests.py"""

import os
import sys
import tempfile
import unittest
import warnings

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "app"))

import report  # noqa: E402
import utils  # noqa: E402

# The suite runs with DeprecationWarning as error: any new reliance on a
# deprecated surface fails here. Legacy paths that predate the deprecation
# tolerate their own warning inside an explicit catch_warnings block.
warnings.simplefilter("error", DeprecationWarning)


class ReportTests(unittest.TestCase):
    def test_total(self):
        self.assertEqual(utils.total([1, 2, 3]), 6.0)

    def test_stats_count_and_mean(self):
        with tempfile.NamedTemporaryFile("w", suffix=".txt", delete=False) as f:
            f.write("1\n2\n3\n4\n")
            path = f.name
        self.addCleanup(os.unlink, path)
        with warnings.catch_warnings():
            warnings.simplefilter("ignore", DeprecationWarning)
            result = report.stats(path)
        self.assertEqual(result["count"], 4)
        self.assertAlmostEqual(result["mean"], 2.5)

    def test_deprecated_helper_warns(self):
        with warnings.catch_warnings(record=True) as caught:
            warnings.simplefilter("always")
            utils.sum_values([1, 2])
        self.assertTrue(any(issubclass(w.category, DeprecationWarning) for w in caught))


if __name__ == "__main__":
    unittest.main(verbosity=2)
EOF

    printf '1\n2\n3\n4\n' > "$wd/data/numbers.txt"

    git -C "$wd" add -A
    git -C "$wd" commit -m "seed reporting tool fixture" --quiet
}

setup_2618_sc6_deprecation_pickup "$1"
