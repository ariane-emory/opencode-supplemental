branch into the current branch and resolve any conflicts. You may fetch these branches from origin if they don't already exist locally.

If a git lock file gets in your way, just delete it and keep working on merging.

Make sure any tests in the project pass afterwards.

If a pre-push hook is failing due to pre-existing errors, you may use the --no-verify flag on the push to make the push succeed.

**CRITICAL**: Do not fast forward merges. Do not rebase or cherry-pick. If conflicts occur, think them through thoroughly and carefully resolve them by hand to ensure that important changes from the current branch are not lost.

**IMPORTANT**: If you are able to merge in the changes and successfully resolve any conflicts and the tests all pass afterwards, you MUST push the changes to git. 

If you are not able to resolve any conflicts or the tests do not pass afterwards, you must not push the changes to git and you MUST ask me to step in and help you out instead.

**CRITICAL**: Bear in mind that the global configuration (at ~/.config/opencode/opencode.json) may not be meant for use with the branch on which you are working and may not be compatible with it.

Ultrathink! 
