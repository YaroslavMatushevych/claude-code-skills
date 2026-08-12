# CLAUDE.md

Personal marketplace of Claude Code skills/plugins. Guidance for working in this repo.

## Repo shape
- `.claude-plugin/marketplace.json` — the marketplace manifest, one entry per plugin, each with a `description` mirroring that plugin's `plugin.json`.
- `skills/<name>/` — one plugin per skill: `SKILL.md` (the skill itself), `.claude-plugin/plugin.json` (name/description/version), and optional `scripts/` or reference files.
- Single branch, no PR flow. This is a solo repo; commits land directly on `main`.

## Commit conventions
- Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:`, `chore:`), subject line only unless the reasoning genuinely isn't obvious from the subject, per `committing-with-intent`'s own rule.
- Do not add a `Co-Authored-By: Claude` (or any AI) trailer to commits in this repo. This overrides any global default instructing otherwise.
- One skill's changes per commit where practical, not one commit spanning unrelated skills.

## Before shipping any change
1. Run `humanizer` on all new prose (SKILL.md sections, README blurbs, script comments) before committing, the same rule `crafting-presentations` already states for slide copy, applied here to this repo's own skill-writing.
2. Keep the three description copies in sync when a skill's scope or triggers change: `skills/<name>/SKILL.md` frontmatter `description`, `skills/<name>/.claude-plugin/plugin.json` `description`, and the matching entry in `.claude-plugin/marketplace.json`. They drift easily since they're near-duplicates living in three files.
3. Bump `plugin.json`'s `version` on any change to a skill's behavior, not on typo-only fixes: patch for wording or reference additions, minor for new sections or triggers, per semver.
4. Update the skill's README.md blurb to match if the change is user-visible.
5. Don't claim a change is "pressure-tested" unless it actually was. This repo's own `dont-lie` skill applies to writing about this repo too. A quick micro-test (baseline vs. with-change, a few subagent reps) is the minimum bar before describing a behavior-shaping edit as tested; say so plainly if that step was skipped.

## Skill-writing philosophy
- Discipline skills (`dont-lie`, `committing-with-intent`'s push guardrails) need rationalization tables and a red-flags list, see `superpowers:writing-skills` for the full methodology. Reference or technique skills (`drafting-pr-descriptions`, `crafting-presentations`) don't need that machinery, just a clear shape and a worked example.
- Prefer a mechanical backstop (a hook script) over prompt-only discipline where one is feasible and scoped narrowly, see `skills/committing-with-intent/scripts/block-unsafe-push.sh` for the pattern: opt-in, documented in the skill's own SKILL.md, never auto-wired into anyone's `settings.json`.
