---
description: Fetch all remotes and prune any local branches that have been deleted on origin.
agent: build
model: opencode/big-pickle
---

First, store the current branch name so you can return to it later.

Then, fetch every remote to make sure they're up to date.

Next, prune stale remote tracking branches FIRST, then identify and delete ALL local branches that no longer exist remotely.

The local dev branch MUST be at the exact same commit hash as upstream/dev when you are done. Use `git reset --hard upstream/dev` to force local dev to match upstream exactly.

If a git lock file gets in your way, you SHOULD just delete it and keep working.

Afterwards, return to the original branch you started on.

- **CRITICAL**: This is a RECEIVE-ONLY operation. DO NOT push any changes to any remotes during this procedure.

Key improvements for fish shell:
- Store original branch: `set original_branch (git branch --show-current)`
- Fetch all remotes: `git fetch --all`
- Prune stale tracking refs FIRST: `git remote prune origin`
- Find branches with gone remotes: `git branch -vv | grep ': gone]' | awk '{print $1}'`
- Delete ALL gone branches: `git branch -D (git branch -vv | grep ': gone]' | awk '{print $1}')`
- Verify no gone branches remain: `git branch -vv | grep ': gone]'` (should return empty)
- Reset dev to upstream: `git checkout dev && git reset --hard upstream/dev`
- Return to original branch: `git checkout $original_branch`
- NEVER push during this procedure - this is receive-only
