#!/usr/bin/env bash
rc=0
if [ -f fix.sh ] && bash -n fix.sh 2>/dev/null; then echo "- ✅ fix.sh exists and is valid bash"
else echo "- ❌ fix.sh is missing or has a syntax error"; rc=1; fi
if [ -f fix.sh ] && grep -q 'set -e' fix.sh; then echo "- ✅ fix.sh uses strict mode (set -e...)"
else echo "- ❌ fix.sh should start with strict mode: set -euo pipefail"; rc=1; fi
if grep -qE '^ALL CHECKS PASSED \(' SUBMISSION.md; then echo "- ✅ SUBMISSION.md shows ALL CHECKS PASSED"
else echo "- ❌ paste the verify.sh output showing 'ALL CHECKS PASSED' into SUBMISSION.md"; rc=1; fi
if grep -q 'FAIL ' SUBMISSION.md; then echo "- ✅ SUBMISSION.md shows what the panic fix broke"
else echo "- ❌ paste the failing verify.sh output (after panic.sh) into SUBMISSION.md"; rc=1; fi
exit $rc
