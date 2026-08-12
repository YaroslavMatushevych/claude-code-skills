---
name: drafting-pr-descriptions
description: Use when opening a pull request or writing/updating a PR description, before running `gh pr create` or filling in a repo's PR template.
---

# Drafting PR Descriptions

## Overview
Reviewers' top complaint about AI-written PRs is effort asymmetry: a description that implies review work (risk called out, testing verified) the author didn't actually do. The fix is matching the description's confidence to the work actually behind it, not making it sound more human.

## The description IS these parts, in order
1. **What & why**: 2-4 sentences naming the actual function/module/bug, not "improves code quality" or "refactors for clarity."
2. **Risk**: shared code, migrations, config, or public API that this change could break. If genuinely nothing, write "None identified" instead of dropping the section.
3. **Testing**: what was actually run or checked. Never write "Tested thoroughly" or "Added tests" unless a test was actually added/run in this session.
4. **Linked ticket**: pull the ticket ID from the branch name (e.g. `feature/ABC-123-...`) or a recent commit trailer, and link it. If none exists, leave it out; don't invent one.

Before filling any of this in, check for the repo's own template: `find .github -iname 'PULL_REQUEST_TEMPLATE*' -o -iname 'pull_request_template*'`. If one exists, fill *its* sections instead of replacing them with the generic shape above.

## Size gates the length
A description longer than the diff it's describing is its own tell. Scale the four sections to the diff, don't fill all of them out of habit:
| Diff size | Budget |
|---|---|
| Small (under ~50 lines) | What & why in 1-2 sentences, skip Risk if genuinely none, one-line Testing |
| Medium (~50-200 lines) | The full four-part shape above |
| Large (200+ lines) | Full shape, plus a short files-changed list with suggested review order if the diff touches more than a handful of files |

## When the why isn't known
Don't invent a plausible-sounding motivation to fill the section. Ask: what bug or ticket prompted this, what broke or was slow before, what does this unblock. A description that honestly says "why: not stated, ask the author" is better than a fabricated rationale that happens to sound right.

## Don'ts
- Don't claim testing or verification that didn't happen.
- Don't pad with emoji or bullet-heavy generic filler ("This PR improves performance and reliability ✨").
- Don't silently swap out the repo's own PR template for a generic one.
- Don't write a paragraph that could describe any PR: every sentence should be wrong if applied to a different diff.

## Example

**Bad (generic, unverifiable, AI-sounding):**
> This PR refactors the authentication module for better maintainability and adds improvements to error handling. Thoroughly tested and ready for review. 🚀

**Good (specific, honest about what was done):**
> Moves token refresh out of `AuthProvider` into a dedicated `useTokenRefresh` hook so the 401-retry logic isn't duplicated in the three places that call it.
>
> **Risk:** touches the retry path every authenticated request goes through. A bug here fails all API calls, not just one screen.
>
> **Testing:** added a unit test for the refresh-race case (two requests hitting a 401 simultaneously); manually verified login/logout/refresh in dev.
>
> Closes JIRA-4821

## Quick reference
| Section | Skip only if | Never |
|---|---|---|
| What & why | Never skip | Say "various improvements," or invent a motivation nobody stated |
| Risk | Truly none, then say so explicitly | Omit the section silently |
| Testing | Never skip | Claim untested work as tested |
| Ticket link | No ticket exists | Fabricate a ticket ID |
