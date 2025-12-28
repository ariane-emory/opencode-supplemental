- process the 'fix' branches before moving on to the others.
- all of the remotes these branches are on should already be configured, you MUST NOT add new remotes.

IMPORTANT: Create a MERGED-BRANCHES.md document in the project's root directory in which to record which branches were merged to produce the new integration branch. Include a Markdown table displaying which branches were merged in this document and a merge log detailing the merges that were performed. Add this file to git.

Use your task todo list tools to keep track of which steps in the procedure you have completed and which branches remain for you to merge. You MUST include every branch in your todo list to help make sure that you don't forget any.

**CRITICAL**: You MUST NOT try to process branches in batches or in parallel, it usually doesn't work out right: you MUST process the branches individually, one at a time.

**CRITICAL - NEVER REBASE THE INTEGRATION BRANCH**: Do NOT use `git pull --rebase` or `git rebase` on the integration branch. Rebasing will clobber merge commits and lose changes from previously merged branches. If there are conflicts with the remote integration branch, use `git pull --no-rebase` or `git push --force` since this is a single-use integration branch for testing purposes.

**CRITICAL BRANCH HYGIENE**: Throughout this entire process, you MUST remain on the integration branch. DO NOT switch to `dev` or any other branch until the very end when performing the post-integration verification. All merges, commits, and pushes should happen while on the integration branch. The `dev` branch should NEVER receive any of the integration commits.

For each of these branches, you SHOULD:

- Merge the branch while staying on the integration branch: `git merge branch-name --no-ff`
- Try your very best to carefully resolve any conflicts that occur. When resolving conflicts, think them through carefully and thoroughly. When multiple branches modify the same file, make sure to incorporate changes from BOTH sides - don't just pick one side.
- **CRITICAL VERIFICATION**: After each merge, you MUST verify that key changes from the branch are actually present in the integration branch. Check for specific functions, types, or code patterns that the branch was supposed to introduce. A merge that reports "Already up to date" may indicate the changes were NOT actually merged.
- Record the result of handling this branch in MERGED-BRANCHES.md.
- Remember to update your todo list.

Since you may need to read files to resolve conflicts, you must always use the Read tool on files prior to using the Edit tool on them to avoid errors.

If a git lock file gets in your way, you SHOULD just delete it and keep working on merging.

Any tests in the project (including 'bun turbo typecheck') MUST pass after merging each branch into the new integration branch.

For each of the feature branches, if you are able to merge in the changes into the integration branch and successfully resolve any conflicts and the tests all pass afterwards, you MUST push the changes to the integration branch on origin on git before proceeding on to the next feature branch.

There is a 'test' pre-pushhook in this repository, so it is possible a push may fail with an error message. If this occurs, you MUST attempt fix the error and try again until the test passes. If, after trying your best, you still cannot fix the error, you may use `git push --no-verify` to bypass the hook.

**CRITICAL**: You must proceed until you have merged all of these branches!  Only if you've tried everything you can think of to resolve a conflict without success and are nonetheless unable to resolve the conflict or the tests do not pass afterwards, do not push the changes to git, in this case you MUST stop and ask me to step in and help you out instead. Only do this is you've tried everything you can think of! Otherwise, proceed until ALL branches have been merged.

Ultrathink! 

## Verifying Merge Results

After each merge, you MUST verify the merge was successful by checking that the branch's key changes are present. Do NOT rely solely on git's merge output - "Already up to date" or a fast-forward merge may indicate the changes were NOT properly integrated.

**Verification procedure for each branch:**
1. Before merging, check the PR diff or branch diff to identify key changes (new functions, types, file modifications)
2. After merging, grep for those specific changes in the integration branch
3. If key changes are missing, re-merge using `git merge origin/branch-name --no-ff`

**Example verification:**
```fish
# Before merge: identify what the branch adds
gh pr diff 36 --repo owner/repo
# or
git diff origin/dev...origin/feat/my-feature --stat

# After merge: verify the changes exist
grep -rn "newFunctionName" packages/
grep -rn "NewTypeName" packages/
```

**Common merge pitfalls to watch for:**
- "Already up to date" - The branch may have already been merged, or you may be merging a stale local branch
- Fast-forward merges when there should be changes - Use `--no-ff` flag and verify changes
- Conflicts that silently drop one side - Always review conflict resolutions carefully
- Multiple branches modifying the same file - Later merges may need to incorporate changes from BOTH the integration branch AND the feature branch
- **REBASING THE INTEGRATION BRANCH** - This is the most dangerous pitfall! Never rebase an integration branch as it will destroy merge commits and lose changes

## Finishing touches

Modify the configuration file at ./.opencode/opencode.jsonc to include this property to set my preferred theme:

```jsonc
{
  "theme": "my-matrix",
  // remainder of content left as-is.
}
```

## Set Integration Branch Version

Update the VERSION constant in `packages/opencode/src/installation/index.ts` to display the integration branch name instead of "local". Find this line:

```typescript
export const VERSION = typeof OPENCODE_VERSION === "string" ? OPENCODE_VERSION : "local"
```

And change `"local"` to the integration branch date:

```typescript
export const VERSION = typeof OPENCODE_VERSION === "string" ? OPENCODE_VERSION : "YYYY-MM-DD-HH-MM"
```

(Replace `YYYY-MM-DD-HH-MM` with the actual branch timestamp, e.g., `2025-12-17-01-17`)

The version MUST match the 'YYYY-MM-DD-HH-MM' format, and must not contain the string 'opencode' or a version number like '0.0.0'.

This change in the VERSION MUST hold true when building a binary version by using `bun run build` in packages/opencode: the binary MUST NOT display the version in a diferent format such as '0.0.0-integration/2025-12-21-22-21-b1-20251222'.

This ensures the TUI sidebar shows which integration branch is running when using the development wrapper script. Commit this change along with the other finishing touches.

## Troubleshooting Remote Tracking Issues

**Problem**: `git push` tries to push to upstream instead of origin with error:
```
fatal: The upstream branch of your current branch does not match the name of your current branch
```

**Solution**: Fix branch configuration:
```fish
# Replace BRANCH-NAME with the actual integration branch name
set BRANCH_NAME integration/YYYY-MM-DD-HH-MM
git config branch.$BRANCH_NAME.remote origin
git config --unset branch.$BRANCH_NAME.merge
```

**Prevention**: Always verify branch configuration after creating integration branches:
```fish
git config --list | grep branch.integration
# Ensure .remote=origin and no .merge setting exists
```

## Post-Integration Verification

**CRITICAL**: After completing all integration work, verify that the `dev` branch was never modified (it should still match `origin/dev` exactly):

```fish
# Verify dev still matches origin/dev exactly (without switching to it)
git log origin/dev..dev --oneline
# MUST show nothing (empty output)
# If this shows commits, something went wrong - dev should never move during integration
```

**Why this matters**: The integration process should NEVER touch `dev`. All work happens on the integration branch. If `dev` has moved forward, it means the integration commits were accidentally committed to the wrong branch.

**What to do if dev has moved forward (this indicates an error occurred)**:
This should not happen if the instructions were followed correctly. If it does happen:
1. **STOP** and inform the user that `dev` was accidentally modified
2. The user will need to decide whether to:
   - Reset `dev` back to `origin/dev` (losing those commits from `dev`)
   - Move those commits to the integration branch if they're missing there

**Final checklist**:
- [ ] All requested branches have been merged into the integration branch
- [ ] Integration branch has been pushed to origin
- [ ] MERGED-BRANCHES.md including Markdown table is complete and committed
- [ ] Tests pass on the integration branch
- [ ] Verified: `dev` branch still matches `origin/dev` (hasn't moved forward)
- [ ] Currently on the integration branch with clean working tree 

**IMPORTANT**: You MUST complete the ENTIRE plan and merge ALL of the requested branches into the new integration branch!

