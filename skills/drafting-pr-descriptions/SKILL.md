---
name: drafting-pr-descriptions
description: Use when opening a pull request or writing/updating a PR description, before running `gh pr create` or filling in a repo's PR template.
---

# Drafting PR Descriptions

## Overview
Reviewers' top complaint about AI-written PRs isn't tone, it's effort asymmetry: a description that implies review work (risk called out, testing verified) the author didn't actually do. The fix isn't "sound more human" — it's writing a description only as confident as the work behind it.

## The description IS these parts, in order
1. **What & why** — 2–4 sentences naming the actual function/module/bug, not "improves code quality" or "refactors for clarity."
2. **Risk** — what could break: shared code, migrations, config, public API. If genuinely nothing, write "None identified" — don't drop the section.
3. **Testing** — what was actually run or checked. Never write "Tested thoroughly" or "Added tests" unless a test was actually added/run in this session.
4. **Linked ticket** — pull the ticket ID from the branch name (e.g. `feature/ABC-123-...`) or a recent commit trailer; link it. If none exists, leave it out — don't invent one.

Before filling any of this in, check for the repo's own template: `find .github -iname 'PULL_REQUEST_TEMPLATE*' -o -iname 'pull_request_template*'`. If one exists, fill *its* sections — don't replace it with the generic shape above.

## Don'ts
- Don't claim testing or verification that didn't happen.
- Don't pad with emoji or bullet-heavy generic filler ("This PR improves performance and reliability ✨").
- Don't silently swap out the repo's own PR template for a generic one.
- Don't write a paragraph that could describe any PR — every sentence should be wrong if applied to a different diff.

## Example

**Bad (generic, unverifiable, AI-sounding):**
> This PR refactors the authentication module for better maintainability and adds improvements to error handling. Thoroughly tested and ready for review. 🚀

**Good (specific, honest about what was done):**
> Moves token refresh out of `AuthProvider` into a dedicated `useTokenRefresh` hook so the 401-retry logic isn't duplicated in the three places that call it.
>
> **Risk:** touches the retry path every authenticated request goes through — a bug here fails all API calls, not just one screen.
>
> **Testing:** added a unit test for the refresh-race case (two requests hitting a 401 simultaneously); manually verified login/logout/refresh in dev.
>
> Closes JIRA-4821

## Quick reference
| Section | Skip only if | Never |
|---|---|---|
| What & why | Never skip | Say "various improvements" |
| Risk | Truly none — then say so explicitly | Omit the section silently |
| Testing | Never skip | Claim untested work as tested |
| Ticket link | No ticket exists | Fabricate a ticket ID |
