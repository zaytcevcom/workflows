#!/bin/bash
set -e

if echo "${GITHUB_SERVER_URL}" | grep -q "gitea\|gitea.io"; then
  export IS_GITEA="true"
  echo "Detected Gitea instance"
else
  export IS_GITEA="false"
fi

PROMPT_PATH="${PROMPT_FILE:-$GITHUB_ACTION_PATH/prompt.txt}"

if [ -n "$CUSTOM_PROMPT" ]; then
  echo "Using custom prompt"
  echo "$CUSTOM_PROMPT" | cursor-agent --force --model "$MODEL" --output-format=text --print
else
  echo "Using prompt from $PROMPT_PATH"
  if [ ! -f "$PROMPT_PATH" ]; then
    echo "❌ Prompt file not found at $PROMPT_PATH"
    exit 1
  fi
  PROMPT_CONTENT=$(sed "s|\${GITHUB_REPOSITORY}|${GITHUB_REPOSITORY}|g; \
                        s|\${GITHUB_PR_NUMBER}|${GITHUB_PR_NUMBER}|g; \
                        s|\${GITHUB_PR_HEAD_SHA}|${GITHUB_PR_HEAD_SHA}|g; \
                        s|\${GITHUB_PR_BASE_SHA}|${GITHUB_PR_BASE_SHA}|g; \
                        s|\${BLOCKING_REVIEW}|${BLOCKING_REVIEW}|g; \
                        s|\${IS_GITEA}|${IS_GITEA}|g" "$PROMPT_PATH")
  echo "$PROMPT_CONTENT" | cursor-agent --force --model "$MODEL" --output-format=text --print
fi

