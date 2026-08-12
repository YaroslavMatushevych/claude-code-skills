#!/bin/sh
# Optional companion to the committing-with-intent skill.
#
# The skill's push guardrails (never force-push, never push straight to the
# default branch, without asking first) are prompt-based: they hold under
# normal pressure but still rely on the model choosing to follow them. This
# script is a mechanical backstop instead: a PreToolUse hook that blocks the
# two exact commands the skill already forbids, before they run, regardless
# of what the model decided in the moment.
#
# Not installed automatically by this plugin. Wire it in yourself if you
# want the hard backstop (see the skill's "Optional: mechanical backstop"
# section for the full explanation):
#
#   1. Copy this file somewhere stable, e.g. ~/.claude/hooks/block-unsafe-push.sh
#   2. chmod +x it
#   3. Add to ~/.claude/settings.json (or a project's .claude/settings.json):
#      {
#        "hooks": {
#          "PreToolUse": [
#            {
#              "matcher": "Bash",
#              "hooks": [{ "type": "command", "command": "~/.claude/hooks/block-unsafe-push.sh" }]
#            }
#          ]
#        }
#      }
#
# Scope is deliberately narrow, matching only what the skill itself forbids:
# `git push --force`/`--force-with-lease`, and a push that names main/master/
# trunk explicitly. Ordinary pushes to a feature branch are untouched — this
# is not a blanket "block all git push" hook.
#
# Limitation: this is plain string matching on the command, not a real git-
# aware check. A `git push` with no branch argument that happens to be on
# main isn't caught (the hook has no reliable way to know the current branch
# without running git itself, which this intentionally keeps simple). Don't
# treat this as an exhaustive guardrail — it's a backstop for the common
# case, not a replacement for the skill's own "ask before pushing" rule.

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

case "$command" in
  *"git push"*"--force"*|*"git push"*" -f "*|*"git push"*" -f")
    echo "Blocked by block-unsafe-push.sh: force-push detected ('$command'). Ask the user before force-pushing, every time, per the committing-with-intent skill." >&2
    exit 2
    ;;
esac

case "$command" in
  *"git push"*"origin main"*|*"git push"*"origin master"*|*"git push"*"origin trunk"*|*"git push"*" main"*|*"git push"*" master"*|*"git push"*" trunk"*)
    echo "Blocked by block-unsafe-push.sh: push naming a default branch detected ('$command'). Confirm with the user before pushing straight to main/master/trunk, per the committing-with-intent skill." >&2
    exit 2
    ;;
esac

exit 0
