---
description: Integrate feature branches (auto) with GLM.
agent: build
model: zai-coding-plan/glm-4.7
---
!`cat ~/.config/opencode/md/integrate-branches--prologue.md`
integration/!`date +%Y-%m-%d-%H-%M`
!`cat ~/.config/opencode/md/integrate-branches--body.md`
!`git for-each-ref --format='%(refname:short)' refs/remotes/origin | sed '/^origin$/d; s#^origin/##' | grep ^fix\/`
!`git for-each-ref --format='%(refname:short)' refs/remotes/origin | sed '/^origin$/d; s#^origin/##' | grep -v ^integration\/ | grep -v ^fix\/ | grep -v ^repair\/ | grep -v ^merged\/ | grep -v ^pr\/ | grep -v ^merging\/ | grep -v ^obsolete\/ | grep -v ^failed\/ | grep -v '^dev$'`
!`cat ~/.config/opencode/md/yoink-branches.md`
!`cat ~/.config/opencode/md/integrate-branches--epilogue.md`
$ARGUMENTS
