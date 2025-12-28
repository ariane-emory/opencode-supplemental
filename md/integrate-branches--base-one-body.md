**CRITICAL**: After creating the integration branch, you MUST configure it to track origin (not upstream) to prevent push issues:

```fish
# Replace BRANCH-NAME with the actual integration branch name
set BRANCH_NAME integration/(date +%Y-%m-%d-%H-%M)
git config branch.$BRANCH_NAME.remote origin
git config --unset branch.$BRANCH_NAME.merge
```

This prevents git from trying to push to upstream when integration branches don't exist there.

**VERIFICATION STEP**: After creating and configuring the integration branch, verify the configuration:

```fish
git config --list | grep branch.integration/
# Should show: 
# branch.integration/YYYY-MM-DD-HH-MM.remote=origin
# Should NOT show any .merge configuration
```

**CRITICAL**: You MUST NOT use git cherry-pick, that always destroys the very feature/fix we're trying to merge.

**CRITICAL - MERGE STRATEGY**: Stay on the integration branch and merge each feature branch into it:
```fish
# Stay on integration branch - do NOT checkout the feature branch
git merge feat/branch-name --no-ff -m "Merge feat/branch-name"
```

**CRITICAL**: You may merge only from local copies of the branches, you MUST NOT pull or fetch.

Do NOT switch away from the integration branch during the merge process.

These are the branches we need to merge into the new integration branch:
