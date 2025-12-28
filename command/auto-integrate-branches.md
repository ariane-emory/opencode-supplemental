---
description: Integrate feature branches (auto).
agent: build

---
!`cat ~/.config/opencode/md/integrate-branches--prologue.md`
Using the dev branch as the starting point, you MUST start a new branch named integration/!`date +%Y-%m-%d-%H-%M` with explicit tracking to origin to avoid upstream tracking issues.
!`cat ~/.config/opencode/md/integrate-branches--body.md`
!`git for-each-ref --format='%(refname:short)' refs/remotes/origin | sed '/^origin$/d; s#^origin/##' | grep ^fix\/`
!`git for-each-ref --format='%(refname:short)' refs/remotes/origin | sed '/^origin$/d; s#^origin/##' | grep -v ^integration\/ | grep -v ^fix\/ | grep -v ^repair\/ | grep -v ^merged\/ | grep -v ^pr\/ | grep -v ^merging\/ | grep -v ^obsolete\/ | grep -v ^failed\/ | grep -v ^wip\/ | grep -v '^dev$'`
!`cat ~/.config/opencode/md/yoink-branches.md`
!`cat ~/.config/opencode/md/integrate-branches--epilogue.md`
$ARGUMENTS
