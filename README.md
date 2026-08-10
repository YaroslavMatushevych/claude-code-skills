# claude-code-skills

Personal collection of [Claude Code](https://claude.com/claude-code) plugins/skills. I use these myself; sharing in case they're useful to you too.

Install the marketplace once, then install whichever skills you want:

```
/plugin marketplace add YaroslavMatushevych/claude-code-skills
/plugin install context-budget-statusline@yaroslav-skills
/plugin install committing-with-intent@yaroslav-skills
/plugin install drafting-pr-descriptions@yaroslav-skills
/plugin install dont-lie@yaroslav-skills
/plugin install humanizer@yaroslav-skills
/plugin install crafting-presentations@yaroslav-skills
```

## context-budget-statusline

Adds cumulative session token usage to the statusline, next to cwd/branch/model/cost, and color-codes it: amber at 100k tokens, red at 150k. Follows Matt Pocock's rule of thumb for when to clear context and start fresh. Thresholds are configurable via env vars.

Install and details: [`skills/context-budget-statusline/SKILL.md`](skills/context-budget-statusline/SKILL.md).

## committing-with-intent

Commit messages should explain why a change was made, not restate the diff. Also enforces a hard rule: never force-push or push to a shared/default branch without asking first, regardless of deadline pressure or "just handle it" instructions. Pressure-tested against exactly that scenario: it held.

Based on recurring complaints from Hacker News, Reddit, and a filed [Claude Code GitHub issue](https://github.com/anthropics/claude-code/issues/33402) about agents force-pushing without confirmation.

Details: [`skills/committing-with-intent/SKILL.md`](skills/committing-with-intent/SKILL.md).

## drafting-pr-descriptions

Structures PR descriptions around what changed and why, what's risky, and what was actually tested, not a restated diff. The core problem this fixes: reviewers can tell when a PR description implies more review effort went in than actually did, and it costs trust.

Details: [`skills/drafting-pr-descriptions/SKILL.md`](skills/drafting-pr-descriptions/SKILL.md).

## dont-lie

Don't state anything as fact, code behavior or any real-world date/name/statistic, unless you can point to it: a file:line, a command's actual output, a source you actually checked, or the user asserting it with ownership, not relaying their own hazy memory. No source, say "not checked." Re-checks when a claim's destination gets more permanent (casual chat to client slide) even if already discussed earlier.

Details: [`skills/dont-lie/SKILL.md`](skills/dont-lie/SKILL.md).

## humanizer

Removes AI writing tells from prose (em dashes, forced rule-of-three, filler phrases, signposting like "let's dive in") and extends the same idea to code: redundant comments, padded docstrings, generic PR/commit filler. Built on [blader/humanizer](https://github.com/blader/humanizer) (MIT) and Wikipedia's [Signs of AI Writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) project: patterns 1-33 are theirs, 34-36 (code comments/docstrings/commits/PRs) added here by me.

Details: [`skills/humanizer/SKILL.md`](skills/humanizer/SKILL.md).

## crafting-presentations

Works for any presentation tool (Keynote, PowerPoint, Google Slides, Marp/reveal.js, Beamer, or code): minimal on-slide text (a number, a phrase, a comparison), everything else (story, caveats, transitions) in speaker notes. Relative type scale, color pattern, paced reveals, and meme guidance, with one worked React/Tailwind/Framer Motion example for anyone building a deck as code. Calls for `humanizer` on all new copy before shipping.

Details: [`skills/crafting-presentations/SKILL.md`](skills/crafting-presentations/SKILL.md).

## Commit convention

Conventional Commits (`feat:`, `fix:`, `refactor:`, `docs:`, `chore:`), subject line only unless the reasoning genuinely isn't obvious from the subject.

## License

MIT. See [LICENSE](LICENSE). `humanizer` carries its own [LICENSE](skills/humanizer/LICENSE) for the upstream-derived content.
