Check out the $ARGUMENTS branch, merge the local dev branch into it and resolve any conflicts. You can take my word that both of these branches already exist, so you don't have to waste time checking if they do before you start.

**CRITICAL**: Make sure that you first discard any uncommited local changes before merging the dev branch in, it would a catastrophic failure if any unrelated local changes were accidentally commited/pushed into our target branch! You MUST NOT stash any pre-existing local changes, you MUST discard them!

If a git lock file gets in your way, just delete it and keep working on merging.

Make sure any tests in the project pass afterwards. You may ignore any pre-existing test failures in the dev branch, but we don't want to add any new test failures relative to dev.

If a pre-push hook is failing due to pre-existing errors, you may use the --no-verify flag on the push to make the push succeed.

**CRITICAL**: Do not fast forward merges. Do not rebase or cherry-pick. If conflicts occur, think them through thoroughly and carefully resolve them by hand to ensure that important changes from the current branch are not lost.

**IMPORTANT**: If you are able to merge in the changes and successfully resolve any conflicts and the tests all pass afterwards, you MUST push the changes to git.

**CRITICAL**: You MUST NOT correct pre-existing errors from dev! You MUST only correct new errors introduced by the merge, pre-existing errors MUST be preserved.

If you are not able to resolve any conflicts or the tests do not pass afterwards, you MUST NOT push the changes to git and you MUST ask me to step in and help you out instead. If any conflics did occur but you were able to resolve them, report on how the conflics were resolved.

Ultrathink! 
