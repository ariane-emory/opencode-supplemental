GOAL: Synchronize local repository to match remote repositories exactly. This is a RECEIVE-ONLY operation that fetches changes from remotes and updates local branches accordingly. This is typically used in fork workflows where upstream is the source of truth.

**CRITICAL FISH SHELL SYNTAX NOTE**: All fish shell code blocks in this document MUST be executed as multi-line code with proper indentation. DO NOT convert to single-line semicolon-separated commands, as this will cause "'end' outside of a block" errors. Fish shell requires proper line breaks for block structures (if/for/while/end).

RULES:
1. All branches on origin must be made available locally
2. All branches that exist locally must be brought up to date with their remote counterparts (may include branches manually checked-out from remotes other than origin)
3. NEVER modify remote repositories - this is a READ-ONLY synchronization operation

**CRITICAL PRINCIPLE**: Remote repositories are ALWAYS the single source of truth. Only delete branches that truly have no remote counterpart anywhere.

**CRITICAL**: You MUST NOT merge local changes with upstream changes! We want the local state to exactly match remote state, any local changes MUST ALWAYS be discarded in favour of the upstream state. DO NOT MERGE!

**ABSOLUTE PROHIBITION**: NEVER use any `git push` command or any other command that modifies remote repositories. This operation is RECEIVE-ONLY.

First, record the current branch name to return to it at the end (unless it was pruned, in which case switch back to dev instead):

**IMPORTANT**: Fish shell variables do NOT persist between separate command invocations. You MUST save the original branch name to a temp file so it can be retrieved later, OR remember it yourself and use it explicitly in the final step.

```fish
set original_branch (git branch --show-current)
echo "Original branch: $original_branch"
echo "$original_branch" > /tmp/original_branch.txt
```

Then, you MUST fetch every remote to make sure they're up to date:

```fish
git fetch --all --prune
```

**CRITICAL CLEANUP STEP**: First, clean up any branches that have NO remote counterpart anywhere. Some local branches might come from remotes other than origin, these should be kept if they still exist on their originating remote!

**FISH SHELL SYNTAX WARNING**: Execute as multi-line code, NOT as single-line semicolon-separated commands.

**CRITICAL BUG TO AVOID**: Local branches can be named with a remote prefix (e.g., `franlol/subagents-in-the-sidebar`). When checking if these have a remote counterpart, do NOT blindly construct `$remote/$branch` as this creates invalid paths like `franlol/franlol/subagents-in-the-sidebar`. Instead, check if the branch name starts with a remote prefix and handle it specially, OR use `git branch -r` output directly to find matches.

```fish
# Get list of ALL remote tracking branches (full names like "origin/dev", "franlol/subagents-in-the-sidebar")
git branch -r | grep -v HEAD | sed 's|^[ *]*||' | sort > /tmp/all_remote_tracking_branches.txt

# Get list of all local branches
git branch | sed 's|^[* ] ||' | sort > /tmp/local_branches.txt

# ONLY delete branches that don't exist on ANY remote
for branch in (cat /tmp/local_branches.txt)
    set found_remote ""
    
    # Method 1: Check if local branch name matches a remote tracking branch directly
    # This handles cases like local "franlol/subagents-in-the-sidebar" matching remote "franlol/subagents-in-the-sidebar"
    if grep -q "^$branch\$" /tmp/all_remote_tracking_branches.txt
        set found_remote "direct-match"
        echo "Keeping branch $branch (matches remote tracking branch directly)"
        continue
    end
    
    # Method 2: Check if any remote has this branch (for branches without remote prefix in name)
    # This handles cases like local "dev" matching "origin/dev" or "upstream/dev"
    for remote in (git remote)
        if git rev-parse --verify "$remote/$branch" >/dev/null 2>&1
            set found_remote "$remote"
            break
        end
    end
    
    # Method 3: Check if branch name starts with a known remote prefix
    # This handles cases like local "franlol/subagents-in-the-sidebar" needing to check "franlol/subagents-in-the-sidebar"
    if test -z "$found_remote"
        for remote in (git remote)
            if string match -q "$remote/*" "$branch"
                # Branch name starts with this remote's prefix, check if it exists
                if git rev-parse --verify "$branch" >/dev/null 2>&1
                    # Check if the remote tracking branch exists
                    if git rev-parse --verify "refs/remotes/$branch" >/dev/null 2>&1
                        set found_remote "$remote"
                        break
                    end
                end
            end
        end
    end
    
    if test -n "$found_remote"
        echo "Keeping branch $branch (found on $found_remote)"
    else
        echo "Deleting orphaned local branch (no remote counterpart): $branch"
        git branch -D "$branch" 2>/dev/null || echo "Failed to delete $branch"
    end
end

echo "Cleanup complete. Remaining local branches:"
git branch
```

**ENHANCED VERIFICATION STEP**: After cleanup, create fresh lists for each remote:

```fish
# Get fresh list of origin branches only (NOTE: proper spacing for git branch -r output)
git branch -r | grep '  origin/' | grep -v HEAD | sed 's|^  origin/||' | sort > /tmp/origin_branches.txt

# Get list of upstream branches only (NOTE: proper spacing for git branch -r output)
git branch -r | grep '  upstream/' | grep -v HEAD | sed 's|^  upstream/||' | sort > /tmp/upstream_branches.txt

# Get fresh list of all local branches
git branch | sed 's|^[* ] ||' | sort > /tmp/local_branches.txt

# Show what we're working with
echo "Origin branches: "(cat /tmp/origin_branches.txt | wc -l)
echo "Upstream branches: "(cat /tmp/upstream_branches.txt | wc -l)  
echo "Local branches: "(cat /tmp/local_branches.txt | wc -l)

# DEBUG: Show first few branches to verify filtering worked correctly
echo "First 3 origin branches:"
head -3 /tmp/origin_branches.txt
echo "First 3 upstream branches:"
head -3 /tmp/upstream_branches.txt
```

**CLEANUP**: Remove any git lock files that might interfere:

```fish
if test -f .git/index.lock
    echo "Removing git lock file..."
    rm -f .git/index.lock
end
```

PHASE 1: Create missing origin branches and sync all existing local branches

**FISH SHELL SYNTAX WARNING**: Execute as multi-line code, NOT as single-line semicolon-separated commands.

```fish
# 1. ONLY create branches that exist on origin but NOT locally (origin is source of truth for what should exist)
for branch in (cat /tmp/origin_branches.txt)
    if not git rev-parse --verify "$branch" >/dev/null 2>&1
        echo "Creating missing origin branch locally: $branch"
        git checkout -b "$branch" "origin/$branch" 2>/dev/null || echo "Failed to create $branch from origin"
    end
end

# 2. Update ALL existing local branches to match their remote counterparts
for branch in (cat /tmp/local_branches.txt)
    echo "Syncing existing local branch: $branch"
    
    # Find which remote has this branch
    if git rev-parse --verify "origin/$branch" >/dev/null 2>&1
        set remote_branch "origin/$branch"
    else if git rev-parse --verify "upstream/$branch" >/dev/null 2>&1
        set remote_branch "upstream/$branch"
    else if git branch -r | grep -v HEAD | grep -q "/$branch\$"
        set remote_branch (git branch -r | grep -v HEAD | grep "/$branch\$" | head -1 | sed 's|^[* ] ||')
    else
        echo "No remote counterpart found for $branch - DISCARDING"
        git branch -D "$branch" 2>/dev/null || echo "Failed to delete $branch"
        continue
    end
    
    git checkout "$branch" 2>/dev/null || echo "Failed to checkout $branch"
    git reset --hard "$remote_branch"
    echo "Reset $branch to match $remote_branch"
end
```

PHASE 2: Synchronize local branches to match their remote counterparts (RECEIVE-ONLY)

**CRITICAL FISH SHELL SYNTAX WARNING**: The following code MUST be executed as multi-line fish shell code. DO NOT convert to single-line semicolon-separated commands, as this will cause "'end' outside of a block" errors.

```fish
# CRITICAL: Only update local branches to match their remote counterparts
# This is a RECEIVE-ONLY operation - NEVER modify remotes
for branch in (cat /tmp/local_branches.txt)
    echo "Syncing local branch with remote: $branch"
    
    # Checkout the branch
    git checkout "$branch" 2>/dev/null || echo "Failed to checkout $branch"
    
    # Reset to match the appropriate remote branch
    if git rev-parse --verify "origin/$branch" >/dev/null 2>&1
        git reset --hard "origin/$branch"
        echo "Reset $branch to match origin/$branch"
    else if git rev-parse --verify "upstream/$branch" >/dev/null 2>&1
        git reset --hard "upstream/$branch"
        echo "Reset $branch to match upstream/$branch"
    else
        echo "No remote counterpart found for $branch - keeping current state"
    end
end
```

VERIFICATION STEPS (CRITICAL):

```fish
# After creating missing branches, verify all branches exist
echo "=== VERIFICATION ==="
echo "Local branches after sync:"
git branch | sed 's|^[* ] ||' | sort

echo "=== BRANCH COUNT COMPARISON ==="
echo "Origin branch count: "(cat /tmp/origin_branches.txt | wc -l)
echo "Upstream branch count: "(cat /tmp/upstream_branches.txt | wc -l)
echo "Local branch count: "(git branch | sed 's|^[* ] ||' | wc -l)

# Cross-check with upstream if needed
if test (cat /tmp/upstream_branches.txt | wc -l) -ne (git branch | sed 's|^[* ] ||' | wc -l)
    echo "WARNING: Branch count mismatch detected!"
    git ls-remote --heads upstream | wc -l
end
```

FINAL VERIFICATION (CRITICAL):

```fish
echo "=== FINAL VERIFICATION ==="

# Verify key branches match across all remotes (sample a few important branches)
for branch in main dev master
    if git rev-parse --verify "$branch" >/dev/null 2>&1
        if git rev-parse --verify "origin/$branch" >/dev/null 2>&1
            if git rev-parse --verify "upstream/$branch" >/dev/null 2>&1
                set match_count (git rev-parse "$branch" "origin/$branch" "upstream/$branch" | uniq | wc -l)
                if test $match_count -eq 1
                    echo "✓ $branch matches across all remotes"
                else
                    echo "✗ $branch has mismatches across remotes"
                end
            end
        end
    end
end

# Read original branch from temp file (since fish variables don't persist between invocations)
set original_branch (cat /tmp/original_branch.txt)

# Verify we're back on the original branch
set current_branch (git branch --show-current)
if test "$current_branch" = "$original_branch"
    echo "✓ Successfully returned to original branch: $original_branch"
else
    echo "✗ Not on original branch. Current: $current_branch, Expected: $original_branch"
    # Try to return to original branch, fall back to dev if it was deleted
    if git rev-parse --verify "$original_branch" >/dev/null 2>&1
        git checkout "$original_branch"
    else
        echo "Original branch $original_branch no longer exists, switching to dev"
        git checkout dev
    end
end

echo "=== SYNC COMPLETE ==="
```

ERROR HANDLING GUIDELINES:

- **Git lock files**: Automatically remove `.git/index.lock` if encountered
- **Branch creation failures**: Continue with other branches, report failures at end
- **Checkout failures**: Attempt to create branch first, then checkout again
- **CRITICAL**: No push operations should occur during this RECEIVE-ONLY synchronization

IMPORTANT NOTES:

- No local changes are important. If any conflict occurs you MUST always resolve it in favor of the remote branch
- This is a RECEIVE-ONLY synchronization operation. The goal is to make local branches match their remote counterparts exactly
- NEVER push changes to remotes during this operation
- Branches manually checked out from other remotes (terakael, franlol, etc.) are preserved if they don't exist on origin

COMMON PITFALLS TO AVOID:

- **CRITICAL**: NEVER use `git push --delete` or any command that modifies remote repositories
- **CRITICAL**: NEVER push changes to remotes during this operation - this is RECEIVE-ONLY
- **CRITICAL**: Don't mix branches from different remotes - always filter by specific remote (origin/ vs upstream/)
- **CRITICAL**: Use fish-compatible sed syntax: `sed 's|^[* ] ||'` instead of `sed 's/^[* ] //'`
- **CRITICAL**: `git branch -r` output has leading spaces - use `grep '  origin/'` not `grep '^origin/'`
- **CRITICAL**: Always verify branch existence before attempting operations: `git rev-parse --verify "$branch"`
- **CRITICAL**: Handle ambiguous branch names - use explicit remote/branch format like `git checkout --track origin/dev`
- **CRITICAL**: Clean up orphaned branches from previous failed syncs BEFORE starting new sync
- Don't assume `git fetch --all` makes branches available locally - remote tracking branches don't automatically create local branches
- **CRITICAL**: Handle git lock files that can prevent operations
- Don't use hardcoded paths or branch names - always use variables
- **CRITICAL**: When deleting local branches, switch off the current branch first if it's being deleted

LESSONS LEARNED:

- **CRITICAL BUG**: Local branches can be named with remote prefixes (e.g., `franlol/subagents-in-the-sidebar`). When checking for remote counterparts, do NOT construct `$remote/$branch` blindly - this creates invalid paths like `franlol/franlol/subagents-in-the-sidebar`. Instead, check if the branch name already matches a remote tracking branch directly by comparing against `git branch -r` output.
- **CRITICAL**: Fish shell variables do NOT persist between separate command invocations in this environment. Always save important values to temp files (e.g., `/tmp/original_branch.txt`) so they can be retrieved in later steps.
- **NEVER assume what constitutes "garbage branches"** - user's fork (origin) is the source of truth for what should exist locally
- **CRITICAL**: Only delete LOCAL branches that have NO remote counterpart ANYWHERE, not just branches that don't exist on origin
- **CRITICAL**: NEVER modify remote repositories during synchronization - this is RECEIVE-ONLY
- Remote tracking branches (remotes/origin/branch) are NOT the same as local branches
- Always create missing local branches BEFORE attempting to checkout or reset them  
- Use `git checkout -b <branch> origin/<branch>` to create local branches from remote tracking branches
- Fish shell has different sed syntax requirements than bash
- The verification step using `comm` command is essential to catch missing branches early
- **CRITICAL**: When determining what to delete, check ALL remotes, not just origin
- Git lock files can appear during complex operations and need to be handled
- **CRITICAL**: Always clean up orphaned branches from previous failed syncs BEFORE starting new sync
- Multiple remotes can have branches with same names (like `dev`), causing ambiguity - use explicit remote/branch format
- `git branch -r` output has leading spaces that must be accounted for in grep patterns
- **CRITICAL**: NEVER create ALL upstream branches locally - this creates branches that don't belong on origin
- When sync fails partway through, it can leave a mess of mixed branches from different remotes that needs manual cleanup
- **CRITICAL**: Cannot delete the current branch - must switch to another branch first
- **BIGGEST LESSON**: Remote repositories are ALWAYS the single source of truth. Local branches without remote counterparts are garbage.
- **CATASTROPHIC LESSON**: NEVER use `git push --delete` under any circumstances during synchronization

Use your todo list tools to keep track of your progress.

After you have finished, return to the branch on which you started.

**FINAL CRITICAL REMINDER**: The goal is to make local branches match their remote counterparts exactly, NOT to create all upstream branches locally. Only branches that exist on remotes should ever exist locally. 

**ABSOLUTE RULE**: Remote repositories are ALWAYS the single source of truth. If a branch doesn't exist on any remote, it's garbage and should be deleted locally.

**ABSOLUTE PROHIBITION**: NEVER use `git push --delete` or any command that modifies remote repositories. This operation is RECEIVE-ONLY.
