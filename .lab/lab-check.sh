#!/usr/bin/env bash
# Lab-specific checks for the Leaky Server lab.
rc=0
if [ -f fix.sh ] && bash -n fix.sh 2>/dev/null; then
  echo "- ✅ fix.sh exists and is valid bash"
else
  echo "- ❌ fix.sh is missing or has a syntax error"; rc=1
fi
if [ -f fix.sh ] && grep -q 'set -e' fix.sh; then
  echo "- ✅ fix.sh uses strict mode (set -e...)"
else
  echo "- ❌ fix.sh should start with strict mode: set -euo pipefail"; rc=1
fi
if [ -f evidence/verify.txt ] && grep -q 'ALL CHECKS PASSED' evidence/verify.txt; then
  echo "- ✅ evidence/verify.txt shows ALL CHECKS PASSED"
else
  echo "- ❌ evidence/verify.txt must contain 'ALL CHECKS PASSED' (run: sudo ./verify.sh | tee evidence/verify.txt)"; rc=1
fi
if [ -f evidence/panic.txt ] && grep -q 'FAIL' evidence/panic.txt; then
  echo "- ✅ evidence/panic.txt shows what the panic fix broke"
else
  echo "- ❌ evidence/panic.txt must show failing checks after panic.sh"; rc=1
fi
exit $rc
