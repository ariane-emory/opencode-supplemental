Fetch upstream and then synchronize the local dev branch with the upstream/dev branch.

The local dev branch and origin/dev MUST be at the exact same commit hash as upstream/dev when you are done. 

*CRITICAL*: The local dev branch and origin/dev MUST be at the exact same commit hash as upstream/dev when you are done, this is not negotiable! You MUST NOT try to fix errors in upstream/dev, if upstream/dev has errors in it we need those errors in dev too!

If a git lock file gets in your way, you SHOULD just delete it and keep working on merging.

Once you have finished, if local dev and upstream/dev are at different commit hashes, then you MUST push the local dev branch to origin.

Afterwards, you MUST return to the branch we were on when we started.
