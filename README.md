# claude-code-skills

Personal collection of [Claude Code](https://claude.com/claude-code) plugins/skills — reusable tools I want available across projects, and share with anyone who finds them useful.

## context-budget-statusline

A statusline for Claude Code that adds cumulative session **token usage** next to the cwd/branch/model/cost segments, and color-codes it so bloated context is visible before it hurts response quality. Default thresholds follow Matt Pocock's rule of thumb: amber at 100k tokens, red at 150k — the point he recommends clearing the context window and starting fresh.

No dependencies beyond `jq` (already required by any Claude Code statusline) and a POSIX shell.

### Option 1 — copy-paste, no plugin, no clone (fastest)

```bash
curl -o ~/.claude/statusline-command.sh \
  https://raw.githubusercontent.com/YaroslavMatushevych/claude-code-skills/main/skills/context-budget-statusline/statusline-command.sh
chmod +x ~/.claude/statusline-command.sh
```

Then add this to `~/.claude/settings.json`:

```json
{ "statusLine": { "type": "command", "command": "~/.claude/statusline-command.sh" } }
```

That's it — restart Claude Code and the statusline is live.

### Option 2 — Claude Code plugin

```
/plugin marketplace add YaroslavMatushevych/claude-code-skills
/plugin install context-budget-statusline@yaroslav-skills
```

### Customizing thresholds

Override without editing the script:

```bash
export STATUSLINE_AMBER_THRESHOLD=80000
export STATUSLINE_RED_THRESHOLD=120000
```

Colors are plain ANSI 256 vars at the top of `statusline-command.sh` — change them to match your terminal theme.

Full details: [`skills/context-budget-statusline/SKILL.md`](skills/context-budget-statusline/SKILL.md).

## License

MIT — see [LICENSE](LICENSE).
