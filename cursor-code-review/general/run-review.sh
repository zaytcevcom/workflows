#!/bin/bash
set -e

export PATH="$HOME/.local/bin:$PATH"

if echo "${GITHUB_SERVER_URL}" | grep -q "gitea\|gitea.io"; then
  export IS_GITEA="true"
  echo "Detected Gitea instance"
else
  export IS_GITEA="false"
fi

run_cursor_agent() {
  local prompt_content="$1"
  local max_retries=3
  local retry_delay=5
  local attempt=1
  
  set +e
  while [ $attempt -le $max_retries ]; do
    if [ $attempt -gt 1 ]; then
      echo "⚠️ Retry attempt $attempt of $max_retries after ${retry_delay}s delay..."
      sleep $retry_delay
      retry_delay=$((retry_delay * 2))
    fi
    
    local error_output
    error_output=$(echo "$prompt_content" | cursor-agent --force --model "$MODEL" --output-format=text --print 2>&1)
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
      set -e
      return 0
    fi
    
    if echo "$error_output" | grep -qiE "NGHTTP2_INTERNAL_ERROR|ConnectError|network|connection|stream.*closed"; then
      if [ $attempt -lt $max_retries ]; then
        echo "⚠️ Network error detected (attempt $attempt/$max_retries):"
        echo "$error_output" | head -5
        echo "Retrying..."
        attempt=$((attempt + 1))
        continue
      else
        echo "❌ Failed to connect to Cursor API after $max_retries attempts."
        echo ""
        echo "Error details:"
        echo "$error_output" | head -10
        echo ""
        echo "💡 This is usually a temporary network issue. Possible solutions:"
        echo "   1. Wait a few minutes and re-run the workflow"
        echo "   2. Check your internet connection and Cursor API status"
        echo "   3. Verify your CURSOR_API_KEY is valid"
        set -e
        exit 1
      fi
    else
      echo "$error_output"
      set -e
      exit $exit_code
    fi
  done
  set -e
}

PROMPT_PATH="${PROMPT_FILE:-$GITHUB_ACTION_PATH/prompt.txt}"

if [ -n "$CUSTOM_PROMPT" ]; then
  echo "Using custom prompt"
  run_cursor_agent "$CUSTOM_PROMPT"
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
  run_cursor_agent "$PROMPT_CONTENT"
fi

