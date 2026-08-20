#!/bin/sh
# Claude Code status line, token-budget theme.
#
# Shows cwd / git branch / model / context% / context tokens / cost.
# The token segment is the same underlying number as ctx:%, just in absolute
# tokens instead of a percentage. It's what's currently sitting in the
# context window (from context_window.total_input_tokens/total_output_tokens
# in the hook payload), not a lifetime sum of everything the session has ever
# used. It drops after /compact or /clear, same as ctx:%.
# Color-coded so you notice before context bloat hurts response quality.
# Defaults follow Matt Pocock's rule of thumb: clear the window (/clear or
# new session) once you're north of ~150k tokens. Thresholds are absolute
# token counts, not scaled to context_window_size, so on a 1M-token extended
# context model they fire at ~10-15% of actual capacity, not ~75%.
#
# Thresholds are overridable via env vars (export before launching Claude Code):
#   STATUSLINE_AMBER_THRESHOLD (default 100000)
#   STATUSLINE_RED_THRESHOLD   (default 150000)
#   STATUSLINE_CACHE_TTL_SECONDS (default 3600, Anthropic's 1hr prompt-cache
#     lifetime on a subscription. Drops to 300 once you're drawing on usage
#     credits, so lower this if that applies to you.)
#
# Also shows one merged cache-freshness segment, built from two signals that
# are deliberately combined rather than shown side by side:
#   1. Reactive: cache_read_input_tokens vs cache_creation_input_tokens from
#      the LAST completed turn (context_window.current_usage). A turn that's
#      mostly cache_creation (a fresh write) rather than cache_read (a cheap
#      hit) means the cache had already gone cold when that turn ran.
#   2. Proactive: time since the transcript file's last write vs. the TTL
#      above. How long until your NEXT message would miss the cache, before
#      you've even sent it.
# They're merged, not two adjacent segments, because a miss resets both the
# TTL countdown *and* the file's mtime at once. Right after a real cache miss
# you'd see "cache: 59m left" looking perfectly healthy in isolation, when it
# actually means a full-price re-index just happened moments ago. The
# reactive signal takes priority in the label whenever a miss is detected.

input=$(cat)

cwd=$(printf '%s\n' "$input" | jq -r '.workspace.current_dir // .cwd // empty')
dir=$(basename "$cwd")
model=$(printf '%s\n' "$input" | jq -r '.model.display_name // empty')

# Git branch (skip optional locks to avoid blocking)
branch=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" -c core.fsmonitor=false symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" -c core.fsmonitor=false rev-parse --short HEAD 2>/dev/null)
fi

# Context used percentage
used=$(printf '%s\n' "$input" | jq -r '.context_window.used_percentage // empty')

# Token usage - current context window contents (drops after /compact/clear)
total_input=$(printf '%s\n' "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(printf '%s\n' "$input" | jq -r '.context_window.total_output_tokens // 0')
tokens_used=$((total_input + total_output))

# Session cost. The payload nests cost data under .cost.total_cost_usd
cost=$(printf '%s\n' "$input" | jq -r '.cost.total_cost_usd // empty')

# Thresholds (override via env vars)
AMBER_THRESHOLD="${STATUSLINE_AMBER_THRESHOLD:-100000}"
RED_THRESHOLD="${STATUSLINE_RED_THRESHOLD:-150000}"

# Colors: plain ANSI 256, swap these to match your own theme.
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

# --- Cache freshness ---------------------------------------------------

fmt_mins() {
  # $1 = seconds -> "Xm" (or "Xh Ym" past 60 minutes)
  s="$1"
  m=$((s / 60))
  if [ "$m" -ge 60 ]; then
    printf '%dh %dm' "$((m / 60))" "$((m % 60))"
  else
    printf '%dm' "$m"
  fi
}

TTL_SECONDS="${STATUSLINE_CACHE_TTL_SECONDS:-3600}"
transcript_path=$(printf '%s\n' "$input" | jq -r '.transcript_path // empty')

# One merged segment, not two independent ones. Two adjacent-but-separate
# segments let "cache: 59m left" (proactive countdown) get read on its own
# and mistaken for "still fully warm", but 59m left is exactly what you'd
# see the instant AFTER a miss re-establishes a fresh window, since the miss
# itself resets both the countdown *and* the transcript's mtime. The reactive
# hit/miss signal is the one that actually answers "did a miss just happen",
# so it takes priority in the combined label whenever both are available.
#
# Deliberately NOT using the transcript file's mtime for the countdown (v1.1.1
# and earlier did, and it was wrong). Claude Code periodically appends
# background bookkeeping entries, subtype "away_summary" among them, part of
# the `claude --resume` feature, that touch the file without being a real,
# cache-relevant turn. That kept resetting the idle clock to ~0 regardless of
# how long it had actually been since the last real API response, so the
# countdown read close to the full TTL almost permanently. Confirmed by
# checking real away_summary timestamps against real turn timestamps in an
# actual transcript, where they don't line up. Using the last ASSISTANT
# entry's own `timestamp` field instead ties the countdown to the same real
# turn the reactive hit/miss signal already reads, immune to background writes.

# Both signals come from the same last-assistant-turn line, read once.
hit_pct=""
remaining=""
if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
  # Scan the last few assistant lines newest-first and use the first one that
  # actually parses. Two distinct causes can make a line fail: (1) `echo`
  # interpreting a literal `\n` inside message content as a real newline
  # instead of passing it through, fixed by using `printf '%s\n'` everywhere
  # below instead of `echo`, since printf never reinterprets escapes in a %s
  # argument; (2) genuinely raw control bytes in captured content, for example
  # a tool result that echoed ANSI color codes (printf doesn't fix that one,
  # so this scan-back-to-a-valid-line fallback stays as defense in depth).
  candidates=$(tail -n 400 "$transcript_path" | grep '"type":"assistant"' | tail -n 20)
  reversed=$(printf '%s\n' "$candidates" | { tail -r 2>/dev/null || tac 2>/dev/null || sed '1!G;h;$!d'; })
  usage_line=""
  while IFS= read -r candidate_line; do
    if [ -n "$candidate_line" ] && printf '%s' "$candidate_line" | jq -e . > /dev/null 2>&1; then
      usage_line="$candidate_line"
      break
    fi
  done <<EOF
$reversed
EOF
  if [ -n "$usage_line" ]; then
    cache_read=$(printf '%s\n' "$usage_line" | jq -r '.message.usage.cache_read_input_tokens // empty' 2>/dev/null)
    cache_write=$(printf '%s\n' "$usage_line" | jq -r '.message.usage.cache_creation_input_tokens // empty' 2>/dev/null)
    if [ -n "$cache_read" ] && [ -n "$cache_write" ]; then
      total_cache=$((cache_read + cache_write))
      if [ "$total_cache" -gt 0 ]; then
        hit_pct=$((cache_read * 100 / total_cache))
      fi
    fi

    ts=$(printf '%s\n' "$usage_line" | jq -r '.timestamp // empty' 2>/dev/null)
    if [ -n "$ts" ]; then
      # Strip fractional seconds and trailing Z: "2026-08-20T08:51:50.022Z" -> "2026-08-20T08:51:50"
      ts_stripped="${ts%.*}"
      turn_epoch=$(TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%S" "$ts_stripped" "+%s" 2>/dev/null \
        || TZ=UTC date -d "$ts" +%s 2>/dev/null)
      if [ -n "$turn_epoch" ]; then
        now=$(date -u +%s)
        idle=$((now - turn_epoch))
        remaining=$((TTL_SECONDS - idle))
      fi
    fi
  fi
fi

if [ -n "$hit_pct" ] && [ "$hit_pct" -lt 50 ]; then
  # A miss happened on the last turn we have data for. Lead with that, not
  # the countdown it reset. State actual elapsed time rather than assuming
  # "just now": that turn could have been seconds ago, or the most recent
  # thing we know about could itself be old (no newer turn to report on yet).
  if [ -n "$idle" ] && [ "$idle" -ge 0 ] && [ "$idle" -lt 120 ]; then
    when="just now"
  elif [ -n "$idle" ] && [ "$idle" -ge 0 ]; then
    when="$(fmt_mins "$idle") ago"
  else
    when="last turn"
  fi
  if [ -n "$remaining" ] && [ "$remaining" -gt 0 ]; then
    append "$(printf '%bcache: missed %s (%s%% hit) → %s left%b' "$RED" "$when" "$hit_pct" "$(fmt_mins "$remaining")" "$RESET")"
  else
    append "$(printf '%bcache: missed %s (%s%% hit)%b' "$RED" "$when" "$hit_pct" "$RESET")"
  fi
elif [ -n "$remaining" ]; then
  if [ "$remaining" -le 0 ]; then
    append "$(printf '%bcache: expired %s ago%b' "$RED" "$(fmt_mins $((0 - remaining)))" "$RESET")"
  elif [ "$remaining" -le 300 ]; then
    append "$(printf '%bcache: %s left%b' "$AMBER" "$(fmt_mins "$remaining")" "$RESET")"
  else
    append "$(printf '%bcache: %s left%b' "$GREY" "$(fmt_mins "$remaining")" "$RESET")"
  fi
fi

printf '%b\n' "$output"
