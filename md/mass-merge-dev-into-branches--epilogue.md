
Address each of these branches individually in sequence starting with the dev branch. Use your todo list to keep track of your progress. For each branch in this list, perform the following procedure:

1. Check the branch out and 'git pull' to make sure it is up to date with its remote counterpart. If conflicts occur, resolve them in favour of the remote counterpart. **IMPORTANT**: If git reports local changes would be overwritten by merge, use `git reset --hard origin/[branch-name]` to discard ALL local changes and match the remote state exactly.

2. Merge in any changes from dev, and if conflicts occur, carefully make efforts to resolve them. **CRITICAL**: Do not fast forward merges. Do not rebase. If conflicts occur, think them through thoroughly and carefully resolve them by hand to ensure that important changes from the current branch are not lost.

3. Make sure that any tests in the project pass afterwards.

4. If you are able to merge in the changes from dev and successfully resolve any conflicts that occur and the tests (other than the enterprise test) all pass afterwards, you MUST push the changes to origin. When resolving conflicts, think them through carefully and thoroughly. Be tenacious, don't give up, analyze any conflicts thoroughly and solve them, being careful to ensurre you do not destroy the core feature the branch was meant to implement in the first place. Only as a last resort if you are not able to resolve the conflicts may you not push the changes to git and instead abort your work and ask me to step in and help you resolve the problem.

5. **CRITICAL**: Don't forget to keep your todo list updated as you complete processing each branch!

By the time you're finished, all of these branches should be zero commits behind dev.

Afterwards, return to the branch we were on at the start.

**CRITICAL**: You MUST NOT try to process branches in batches! Doing that usually doesn't work out right: ALWAYs process branches one at a time.

IMPORTANT: Remember that we're using the fish shell, NOT bash, when writing your commands.

**CRITICAL**: Don't forget to keep your todo list updated as you complete processing each branch!

Ultrathink! 
