#!/bin/bash
set -e
curl https://cursor.com/install -fsS | bash
if [ -n "$GITHUB_PATH" ]; then
  echo "$HOME/.local/bin" >> $GITHUB_PATH
else
  echo "PATH=$HOME/.local/bin:$PATH" >> $GITHUB_ENV
fi
export PATH="$HOME/.local/bin:$PATH"

