#!/bin/sh
# Claude Code status line — token-budget theme
#
# Shows cwd / git branch / model / context% / context tokens / cost.
# The token segment is the same underlying number as ctx:%, just in absolute
# tokens instead of a percentage — it's what's currently sitting in the
# context window (from context_window.total_input_tokens/total_output_tokens
# in the hook payload), not a lifetime sum of everything the session has ever
# used. It drops after /compact or /clear, same as ctx:%.
# Color-coded so you notice before context bloat hurts response quality —
# defaults follow Matt Pocock's rule of thumb: clear the window (/clear or
# new session) once you're north of ~150k tokens. Thresholds are absolute
# token counts, not scaled to context_window_size, so on a 1M-token extended
# context model they fire at ~10-15% of actual capacity, not ~75%.
#
# Thresholds are overridable via env vars (export before launching Claude Code):
#   STATUSLINE_AMBER_THRESHOLD (default 100000)
#   STATUSLINE_RED_THRESHOLD   (default 150000)

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
dir=$(basename "$cwd")
model=$(echo "$input" | jq -r '.model.display_name // empty')

# Git branch (skip optional locks to avoid blocking)
branch=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" -c core.fsmonitor=false symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" -c core.fsmonitor=false rev-parse --short HEAD 2>/dev/null)
fi

# Context used percentage
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Token usage - current context window contents (drops after /compact/clear)
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
tokens_used=$((total_input + total_output))

# Session cost — the payload nests cost data under .cost.total_cost_usd
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')

# Thresholds (override via env vars)
AMBER_THRESHOLD="${STATUSLINE_AMBER_THRESHOLD:-100000}"
RED_THRESHOLD="${STATUSLINE_RED_THRESHOLD:-150000}"

# Colors — plain ANSI 256, swap these to match your own theme.
#   PRIMARY   \033[38;5;33m   (blue)
#   ACCENT    \033[1;38;5;39m (bold bright blue)
#   White     \033[38;5;231m
#   Mid-grey  \033[38;5;246m
#   Amber     \033[38;5;214m
#   Red       \033[38;5;196m
PRIMARY='\033[38;5;33m'
ACCENT='\033[1;38;5;39m'
WHITE='\033[38;5;231m'
GREY='\033[38;5;246m'
AMBER='\033[38;5;214m'
RED='\033[38;5;196m'
RESET='\033[0m'

# Separator in mid-grey
SEP="${GREY} │ ${RESET}"

# Build output segments, inserting │ separators between each present segment.
output=""

# Helper: append a segment (handles the separator logic)
append() {
  if [ -z "$output" ]; then
    output="$1"
  else
    output="${output}${SEP}$1"
  fi
}

append "$(printf '%b%s%b' "$WHITE" "$dir" "$RESET")"

if [ -n "$branch" ]; then
  append "$(printf '%bgit:(%b%s%b)%b' "$GREY" "$PRIMARY" "$branch" "$GREY" "$RESET")"
fi

if [ -n "$model" ]; then
  append "$(printf '%b%s%b' "$GREY" "$model" "$RESET")"
fi

if [ -n "$used" ]; then
  append "$(printf '%bctx:%s%%%b' "$ACCENT" "$(printf '%.0f' "$used")" "$RESET")"
fi

if [ "$tokens_used" -gt 0 ]; then
  # Color-code tokens based on thresholds: red at RED_THRESHOLD+, amber at AMBER_THRESHOLD+
  if [ "$tokens_used" -ge "$RED_THRESHOLD" ]; then
    token_color="$RED"
  elif [ "$tokens_used" -ge "$AMBER_THRESHOLD" ]; then
    token_color="$AMBER"
  else
    token_color="$GREY"
  fi
  # Format with k suffix for readability (e.g., 95k, 120k)
  tokens_display=$(awk -v t="$tokens_used" 'BEGIN { printf "%.0fk", t/1000 }')
  append "$(printf '%b%s tokens%b' "$token_color" "$tokens_display" "$RESET")"
fi

if [ -n "$cost" ]; then
  append "$(printf '%b$%s%b' "$GREY" "$(printf '%.2f' "$cost")" "$RESET")"
fi

printf '%b\n' "$output"
