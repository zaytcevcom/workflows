#!/bin/bash
set -e
echo "Checking for critical issues..."
echo "CRITICAL_ISSUES_FOUND: ${CRITICAL_ISSUES_FOUND:-unset}"

if [ "${CRITICAL_ISSUES_FOUND:-false}" = "true" ]; then
  echo "❌ Critical issues found and blocking review is enabled. Failing the workflow."
  exit 1
else
  echo "✅ No blocking issues found."
fi

