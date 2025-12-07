#!/bin/bash
set -e
export PATH="$HOME/.local/bin:$PATH"
if ! command -v cursor-agent &> /dev/null; then
  echo "❌ cursor-agent not found in PATH"
  exit 1
fi
echo "✅ cursor-agent installed successfully"
cursor-agent --version || true

