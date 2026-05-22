#!/bin/bash
# Content-verification test for spec #804: Evidence Type Classification
# SC-1: 080-code-standards.md includes evidence type taxonomy
# SC-2: VbC verify.md includes evidence type column and behavioral enforcement
# SC-3: cross-validate.md includes EVIDENCE_TYPE_MISMATCH gate
# SC-4: spec-audit.md includes per-SC evidence type check
# SC-5: create-pr.md includes Evidence Type column in PR body
# SC-6: 080-code-standards.md EVIDENCE_TYPE_MISMATCH as critical violation
# SC-8: 080-code-standards.md SC-to-Test includes evidence type column requirement
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

OVERALL_RESULT=0

OPencode_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# SC-1: Evidence type taxonomy in 080-code-standards.md
if grep -q "Evidence Type Taxonomy" "$OPencode_DIR/.opencode/guidelines/080-code-standards.md"; then
    echo "✅ SC-1: Evidence Type Taxonomy section found in 080-code-standards.md"
else
    echo "❌ SC-1: Evidence Type Taxonomy section NOT found in 080-code-standards.md"
    OVERALL_RESULT=1
fi

# SC-1: Four evidence types present
for etype in "structural" "string" "semantic" "behavioral"; do
    if grep -q "\`$etype\`" "$OPencode_DIR/.opencode/guidelines/080-code-standards.md" || grep -q "$etype" "$OPencode_DIR/.opencode/guidelines/080-code-standards.md"; then
        echo "✅ SC-1: Evidence type '$etype' found"
    else
        echo "❌ SC-1: Evidence type '$etype' NOT found"
        OVERALL_RESULT=1
    fi
done

# SC-2: VbC verify.md includes evidence type column
if grep -q "Evidence Type" "$OPencode_DIR/.opencode/skills/verification-before-completion/tasks/verify.md"; then
    echo "✅ SC-2: Evidence Type column found in verify.md"
else
    echo "❌ SC-2: Evidence Type column NOT found in verify.md"
    OVERALL_RESULT=1
fi

# SC-2: VbC verify.md includes behavioral SC enforcement section
if grep -q "Behavioral SC Enforcement" "$OPencode_DIR/.opencode/skills/verification-before-completion/tasks/verify.md"; then
    echo "✅ SC-2: Behavioral SC Enforcement section found in verify.md"
else
    echo "❌ SC-2: Behavioral SC Enforcement section NOT found in verify.md"
    OVERALL_RESULT=1
fi

# SC-3: cross-validate.md includes EVIDENCE_TYPE_MISMATCH
if grep -q "EVIDENCE_TYPE_MISMATCH" "$OPencode_DIR/.opencode/skills/adversarial-audit/tasks/cross-validate.md"; then
    echo "✅ SC-3: EVIDENCE_TYPE_MISMATCH gate found in cross-validate.md"
else
    echo "❌ SC-3: EVIDENCE_TYPE_MISMATCH gate NOT found in cross-validate.md"
    OVERALL_RESULT=1
fi

# SC-3: cross-validate.md includes evidence type downgrade procedure
if grep -q "downgrade" "$OPencode_DIR/.opencode/skills/adversarial-audit/tasks/cross-validate.md"; then
    echo "✅ SC-3: Evidence type downgrade procedure found in cross-validate.md"
else
    echo "❌ SC-3: Evidence type downgrade procedure NOT found in cross-validate.md"
    OVERALL_RESULT=1
fi

# SC-4: spec-audit.md includes SC-EVIDENCE-TYPE criterion
if grep -q "SC-EVIDENCE-TYPE" "$OPencode_DIR/.opencode/skills/adversarial-audit/tasks/spec-audit.md"; then
    echo "✅ SC-4: SC-EVIDENCE-TYPE criterion found in spec-audit.md"
else
    echo "❌ SC-4: SC-EVIDENCE-TYPE criterion NOT found in spec-audit.md"
    OVERALL_RESULT=1
fi

# SC-4: spec-audit.md includes evidence type check in procedure (not just table row)
if grep -q "evidence_type" "$OPencode_DIR/.opencode/skills/adversarial-audit/tasks/spec-audit.md"; then
    echo "✅ SC-4: Evidence type check found in spec-audit.md"
else
    echo "❌ SC-4: Evidence type check NOT found in spec-audit.md"
    OVERALL_RESULT=1
fi

# SC-5: create-pr.md includes Evidence Type column
if grep -q "Evidence Type" "$OPencode_DIR/.opencode/skills/git-workflow/tasks/pr-creation/create-pr.md"; then
    echo "✅ SC-5: Evidence Type column found in create-pr.md"
else
    echo "❌ SC-5: Evidence Type column NOT found in create-pr.md"
    OVERALL_RESULT=1
fi

# SC-6: 080-code-standards.md includes EVIDENCE_TYPE_MISMATCH
if grep -q "EVIDENCE_TYPE_MISMATCH" "$OPencode_DIR/.opencode/guidelines/080-code-standards.md"; then
    echo "✅ SC-6: EVIDENCE_TYPE_MISMATCH found in 080-code-standards.md"
else
    echo "❌ SC-6: EVIDENCE_TYPE_MISMATCH NOT found in 080-code-standards.md"
    OVERALL_RESULT=1
fi

# SC-8: 080-code-standards.md SC-to-Test includes evidence type column requirement
if grep -q "Evidence Type column" "$OPencode_DIR/.opencode/guidelines/080-code-standards.md"; then
    echo "✅ SC-8: Evidence Type column requirement found in SC-to-Test section"
else
    echo "❌ SC-8: Evidence Type column requirement NOT found in SC-to-Test section"
    OVERALL_RESULT=1
fi

if [ $OVERALL_RESULT -eq 0 ]; then
    echo "✅ All content-verification assertions passed"
else
    echo "❌ Some content-verification assertions failed"
fi

exit $OVERALL_RESULT