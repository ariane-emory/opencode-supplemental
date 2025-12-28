I want to be able to run the exact same version that runs when I do 'bun dev' from anywhere. You should be able to achieve this by creating a wrapper script and symlinking it to /opt/homebrew/bin.

## CRITICAL: Two Separate Repositories - NO CONFUSION ALLOWED

**⚠️ THE INSTALLATION USES ONLY `/Volumes/K/Code/go/opencode-deploy/` (aliased as `~/osd`)**

The system has TWO completely separate opencode repositories. This installation task uses **EXCLUSIVELY** the opencode-deploy repository:

| Repository | Path | Alias | Purpose | **USE IN THIS TASK?** |
|------------|------|-------|---------|----------------------|
| **opencode-deploy** | `/Volumes/K/Code/go/opencode-deploy` | `~/osd` | Contains integration branches for deployment | ✅ **YES - THIS IS THE ONLY ONE WE USE** |
| **opencode** | `/Volumes/K/Code/go/opencode` | `~/os` | Main development repository (different branch) | ❌ **NO - DO NOT USE THIS AT ALL** |

**You are working in `/Volumes/K/Code/go/opencode-deploy/` (or `~/osd`). The `/Volumes/K/Code/go/opencode/` (or `~/os`) directory is COMPLETELY UNRELATED to this installation and must not be referenced, consulted, or used in any way.**

**Before proceeding**:

1. **Verify you are in the correct repository**: Run `pwd` - you should see `/Volumes/K/Code/go/opencode-deploy` or a path containing `opencode-deploy`
2. **Verify the git remote**: Run `git remote -v` - it should point to the origin repository (ariane-emory/opencode), NOT the upstream repository (sst/opencode).
3. **Check which branch you're on**: `git branch --show-current` - find the latest integration branch (has date/time in name)
4. **Confirm you're NOT in ~/os**: Run `pwd` and verify it does NOT show a path containing just `opencode` without `-deploy`
5. All file paths in the wrapper script must be derived from `/Volumes/K/Code/go/opencode-deploy/` using dynamic path resolution

## Implementation Steps:

Use your todo list to keep track of your progress in completing these steps.

**WORKING DIRECTORY: You must be in `/Volumes/K/Code/go/opencode-deploy/` (or `~/osd`) for all steps. Verify with `pwd` before each step.**

1. **FIRST: Change to the correct repository directory**
   - Run: `cd /Volumes/K/Code/go/opencode-deploy` (or `cd ~/osd`)
   - Verify with: `pwd` should show `/Volumes/K/Code/go/opencode-deploy`
   - Verify with: `git remote -v` should show opencode-deploy, NOT opencode

2. **Check if wrapper script already exists** at `packages/opencode/bin/opencode-dev` (IN THE OPENCODE-DEPLOY REPO)
   - If it exists, READ it first before modifying: the wrapper script may already have been created during previous installation. If it is present and has the correct content, you may use it as is and may skip rewriting it.
   - Check if it has the correct implementation (uses `realpathSync`, `spawnSync`, forwards arguments)
   - If it's outdated or broken, update it to match the template below

3. **Create or update wrapper script** at `packages/opencode/bin/opencode-dev` (IN THE OPENCODE-DEPLOY REPO) with the code below

4. **CRITICAL: Ensure source code restores working directory** - This step is MANDATORY!
   - Read `packages/opencode/src/index.ts` to check if it has the working directory restoration code
   - Look for code that reads `process.env.OPENCODE_ORIGINAL_CWD` near the top of the file (after imports)
   - If missing, add this code IMMEDIATELY after the imports and BEFORE any other code:
   
   ```typescript
   // Restore original working directory if running via wrapper script
   if (process.env.OPENCODE_ORIGINAL_CWD) {
     process.chdir(process.env.OPENCODE_ORIGINAL_CWD)
   }
   ```
   
   - **Why this is critical**: The wrapper script sets `OPENCODE_ORIGINAL_CWD` to preserve the user's working directory, but the opencode application MUST read this variable and restore the directory at startup. Without this code, opencode will always start in the opencode-deploy directory instead of the user's actual working directory.
   - Commit this change if you had to add it
   
5. **Make it executable** with `chmod +x packages/opencode/bin/opencode-dev`

6. **Check existing symlinks** with `ls -la /opt/homebrew/bin/ | grep opencode`
   - Remove any outdated symlinks that might conflict
   - Verify they don't point to `/Volumes/K/Code/go/opencode/` (the wrong repository)

7. **Create symlink** from `/opt/homebrew/bin/opencode-dev` pointing to the wrapper script using absolute path:
   - `sudo ln -s /Volumes/K/Code/go/opencode-deploy/packages/opencode/bin/opencode-dev /opt/homebrew/bin/opencode-dev`

8. **Update main `opencode` symlink** (optional but recommended):
   - `sudo rm /opt/homebrew/bin/opencode` (if exists)
   - `sudo ln -s /Volumes/K/Code/go/opencode-deploy/packages/opencode/bin/opencode-dev /opt/homebrew/bin/opencode`
   - Commit and push your changes to the `opencode-dev` wrapper script to the integration branch.
   - **NOTE: The symlink target must be `/Volumes/K/Code/go/opencode-deploy/`, NOT `/Volumes/K/Code/go/opencode/`**

9. **Verify functionality** with test commands from a different directory (e.g., `/tmp`)

## Wrapper Script Template:

```bash
#!/usr/bin/env bun
import { spawnSync } from "child_process"
import { realpathSync } from "fs"
import { dirname } from "path"

// Get the absolute path to this script and find project root
const scriptPath = realpathSync(import.meta.path)
const scriptDir = dirname(scriptPath)
const projectRoot = dirname(scriptDir)

// Preserve the user's original working directory
const originalCwd = process.cwd()
process.env.OPENCODE_ORIGINAL_CWD = originalCwd

// Change to the opencode project directory to ensure dependencies are found
process.chdir(projectRoot)

// Run the development version of opencode with forwarded arguments
const args = ["run", "--conditions=browser", "./src/index.ts", ...process.argv.slice(2)]
const result = spawnSync("bun", args, {
  cwd: projectRoot,
  stdio: "inherit",
  env: process.env,
})

if (result.error) {
  console.error(result.error.message)
  process.exit(1)
}

process.exit(typeof result.status === "number" ? result.status : 0)
```

## Important Requirements:

1. **Use Bun, not Node.js**: The project uses Bun runtime, not Node.js. The executable must use `#!/usr/bin/env bun` shebang line.

2. **Working Directory**: The wrapper script must preserve the user's original working directory while ensuring opencode can find its dependencies.

3. **Development Mode**: The command should run `bun run src/index.ts` (same as `bun dev` script), not the compiled binary.

4. **Argument Forwarding**: The wrapper script must forward all command-line arguments (`process.argv.slice(2)`) to the opencode process so commands like `--help`, `--version`, and `run "message"` work correctly.

## Common Pitfalls:

- **CRITICAL: Don't forget to add working directory restoration code to src/index.ts** - The wrapper script sets `OPENCODE_ORIGINAL_CWD` but the opencode application must READ and USE it. Without the `process.chdir(process.env.OPENCODE_ORIGINAL_CWD)` code in `src/index.ts`, opencode will always start in the opencode-deploy directory instead of the user's actual working directory. This is the #1 most common mistake!
- **ALWAYS VERIFY YOU'RE IN THE CORRECT REPOSITORY FIRST** - Confirm `pwd` shows `/Volumes/K/Code/go/opencode-deploy`, NOT `/Volumes/K/Code/go/opencode`. Run `git remote -v` to double-check.
- **DO NOT USE `/Volumes/K/Code/go/opencode/` (~/os) IN ANY WAY** - This repository is completely separate. The wrapper script, symlinks, and all file operations must use ONLY `/Volumes/K/Code/go/opencode-deploy/` paths.
- **DO NOT copy, reference, or consult files from ~/os** - The main opencode repository may be on a different branch and is unrelated to this deployment installation.
- **ALWAYS read the file first** - If `packages/opencode/bin/opencode-dev` already exists, READ it before attempting to write/edit it (the Edit tool requires this). Make sure it's from the opencode-deploy repo, not the opencode repo.
- **Check for old symlinks pointing to the WRONG repository** - Use `ls -la /opt/homebrew/bin/ | grep opencode` and verify each symlink with `readlink -f` to ensure it points to `/Volumes/K/Code/go/opencode-deploy/`, NOT `/Volumes/K/Code/go/opencode/`. Delete any symlinks pointing to the wrong repository.
- **Use absolute paths in symlinks** - When creating symlinks, ALWAYS use `/Volumes/K/Code/go/opencode-deploy/packages/opencode/bin/opencode-dev` (never `/Volumes/K/Code/go/opencode/...`).
- **Verify you're on the correct branch** - Before creating the wrapper, confirm you're on the intended integration branch with `git branch --show-current`.
- **Don't use hardcoded paths** - Never hardcode paths in the wrapper script. Always use dynamic path resolution with `realpathSync(import.meta.path)`. This ensures the wrapper always points to wherever the script actually is in the opencode-deploy repository.
- **Don't use the existing `bin/opencode` directly** - it will fail with "package manager failed to install the right version" error.
- **Don't use `#!/usr/bin/env node`** - the project requires Bun runtime.
- **Don't forget to preserve the original working directory** - use OPENCODE_ORIGINAL_CWD to maintain user's context while ensuring opencode can find its dependencies.
- **Don't omit `--conditions=browser`** - this flag is required for proper execution of the TypeScript source.
- **Don't forget to forward command-line arguments** - without `...process.argv.slice(2)`, commands like `opencode --help` and `opencode run "message"` will just start the TUI instead of working as expected.
- **Don't use async functions** - use `spawnSync` and `realpathSync` for simpler control flow.
- **Don't accidentally use files from ~/os** - Some tools might suggest using ~/os paths. Ignore those suggestions. This task uses ONLY ~/osd (opencode-deploy).

## Tricky Parts Discovered During Implementation:

### **Command-Line Argument Forwarding**

**Problem**: Initial wrapper script ignored arguments like `--help`, `--version`, `run "message"` and always started TUI.

**Root Cause**: The script was hardcoded to run `./src/index.ts` without forwarding user arguments.

**Solution**: Forward all command-line arguments using `...process.argv.slice(2)`:

```typescript
// Before (broken):
const result = spawnSync("bun", ["run", "--conditions=browser", "./src/index.ts"], {...})

// After (working):
const args = ["run", "--conditions=browser", "./src/index.ts", ...process.argv.slice(2)]
const result = spawnSync("bun", args, {...})
```

**Why this works**: `process.argv.slice(2)` extracts user arguments (skipping node/bun executable and script name), allowing opencode to parse commands like `--help`, `--version`, and `run "message"` correctly.

### **Path Resolution for Project Root**

**Problem**: Need to find the opencode project root from within the wrapper script to ensure dependencies are accessible.

**Solution**: Use `realpathSync(import.meta.path)` to get script location, then navigate up two directories:

```typescript
const scriptPath = realpathSync(import.meta.path); // Absolute path to this script
const scriptDir = dirname(scriptPath); // packages/opencode/bin/
const projectRoot = dirname(scriptDir); // packages/opencode/
```

**Why this approach**: `import.meta.path` gives the actual file location (resolving symlinks), and `dirname(dirname())` reliably gets us from `bin/opencode-dev` to the project root where `package.json` and dependencies are located.

### **Working Directory Preservation**

**Problem**: Need to run opencode from project directory (for dependencies) while preserving user's original working directory.

**Solution**: Store original CWD in environment variable before changing directory:

```typescript
const originalCwd = process.cwd();
process.env.OPENCODE_ORIGINAL_CWD = originalCwd;
process.chdir(projectRoot); // Change to project for dependencies
```

**Why this works**: opencode reads `OPENCODE_ORIGINAL_CWD` to know where the user started, while `process.chdir()` ensures Bun can find `node_modules` and project dependencies.

### **Synchronous vs Asynchronous Operations**

**Problem**: Initial attempts used async `spawn()` with event handlers, making error handling and exit codes complex.

**Solution**: Use synchronous `spawnSync()` for simpler control flow:

```typescript
// Use spawnSync for blocking execution with immediate result
const result = spawnSync("bun", args, {
  cwd: projectRoot,
  stdio: "inherit",
  env: process.env,
});

// Simple error handling and exit code propagation
if (result.error) {
  console.error(result.error.message);
  process.exit(1);
}
process.exit(typeof result.status === "number" ? result.status : 0);
```

**Why this approach**: `spawnSync()` blocks until completion, making it easier to handle errors and propagate exit codes correctly, matching the behavior of a direct command execution.

## Troubleshooting:

### Problem: Working directory is always opencode-deploy regardless of where opencode was started

**Symptoms**: When you start opencode from any directory (e.g., `/tmp`, `~`), the TUI footer shows the opencode-deploy directory path instead of your actual working directory

**Cause**: The wrapper script sets `OPENCODE_ORIGINAL_CWD` environment variable, but the opencode source code in `src/index.ts` is missing the code to read and restore this working directory

**Solution**: Add the working directory restoration code to `packages/opencode/src/index.ts` immediately after the imports:

```typescript
// Restore original working directory if running via wrapper script
if (process.env.OPENCODE_ORIGINAL_CWD) {
  process.chdir(process.env.OPENCODE_ORIGINAL_CWD)
}
```

**Verification**: After adding this code, test from a different directory:
```bash
cd /tmp && opencode  # TUI footer should show /tmp, not opencode-deploy
cd ~ && opencode     # TUI footer should show ~, not opencode-deploy
```

### Problem: TUI starts instead of showing help/version

**Symptoms**: Running `opencode --version` or `opencode --help` starts the TUI and ignores the arguments

**Cause**: The wrapper script is missing argument forwarding (`...process.argv.slice(2)`)

**Solution**: Update the wrapper script to include the args array:

```typescript
const args = [
  "run",
  "--conditions=browser",
  "./src/index.ts",
  ...process.argv.slice(2),
];
```

### Problem: TUI clears screen and exits immediately

**Symptoms**: Running `opencode` clears the terminal screen but then returns to the shell prompt without starting the TUI

**Causes**:

1. Wrapper script has a hardcoded incorrect path (should use dynamic path resolution, not hardcoded paths)
2. **Symlink points to WRONG repository clone** - pointing to `/Volumes/K/Code/go/opencode/` instead of `/Volumes/K/Code/go/opencode-deploy/`

**Solution**:

1. Check which symlink is being used: `which opencode` and `ls -la /opt/homebrew/bin/opencode`
2. Verify the symlink points to the CORRECT repository: `readlink -f /opt/homebrew/bin/opencode`
   - **MUST show**: `/Volumes/K/Code/go/opencode-deploy/packages/opencode/bin/opencode-dev`
   - **MUST NOT show**: `/Volumes/K/Code/go/opencode/packages/opencode/bin/...` (without "-deploy")
3. Update the wrapper script to use dynamic path resolution (see template above)
4. **Delete the incorrect symlink and recreate it pointing to `/Volumes/K/Code/go/opencode-deploy/`**:
   ```bash
   sudo rm /opt/homebrew/bin/opencode
   sudo ln -s /Volumes/K/Code/go/opencode-deploy/packages/opencode/bin/opencode-dev /opt/homebrew/bin/opencode
   ```

### Problem: "Package manager failed to install" error

**Cause**: Using the compiled `bin/opencode` binary instead of the development wrapper script

**Solution**: Always use `bin/opencode-dev` as the target for symlinks, not `bin/opencode`

## Verification:

After installation, test from a different directory (IMPORTANT: test from `/tmp` or `~`, NOT from the project directory):

```bash
# Test version
cd /tmp && opencode-dev --version  # Should output: "local"
cd /tmp && opencode --version       # Should output: "local" (if you updated main symlink)

# Test help
cd /tmp && opencode-dev --help | head -10  # Should show help text with opencode banner

# Test TUI startup (will timeout, that's expected)
cd /tmp && timeout 2 opencode-dev  # Should start TUI with "Build anything..." prompt

# Verify working directory preservation
cd ~ && timeout 2 opencode-dev  # TUI footer should show your home directory path
cd /tmp && timeout 2 opencode-dev  # TUI footer should show /tmp, NOT opencode-deploy
```

Success indicators:

- `--help` shows help text with opencode banner
- `--version` shows "local" (not "0.0.0-dev-..." which would indicate an old build)
- `timeout 2 opencode-dev` starts the TUI (times out after 2 seconds, that's normal)
- No arguments starts the TUI successfully
- Working directory shown in TUI footer matches where you ran the command

Failure indicators:

- **TUI shows opencode-deploy directory when started from elsewhere** → Missing working directory restoration code in src/index.ts (see step 4)
- TUI clears screen and exits immediately → Hardcoded path or wrong symlink
- TUI starts when using `--help` or `--version` → Missing argument forwarding
- Command not found → Symlink not created or wrong location
- "Package manager failed" error → Using wrong binary

## Post-Installation Diagnostics:

If issues occur, run these diagnostic commands:

```bash
# 1. Check which command is being executed
which opencode
which opencode-dev

# 2. Verify symlink targets - CHECK THEY POINT TO opencode-deploy, NOT opencode
ls -la /opt/homebrew/bin/opencode
ls -la /opt/homebrew/bin/opencode-dev

# 3. Check if symlink resolves correctly - MUST show opencode-deploy in the path
readlink -f /opt/homebrew/bin/opencode
readlink -f /opt/homebrew/bin/opencode-dev

# 4. View the wrapper script content
cat $(readlink -f /opt/homebrew/bin/opencode)

# 5. Verify you're using the CORRECT repository (opencode-deploy, not opencode)
pwd  # Should show /Volumes/K/Code/go/opencode-deploy
cd /Volumes/K/Code/go/opencode-deploy && git branch --show-current && git log --oneline -3

# 6. CONFIRM you are NOT accidentally using the wrong repository
ls -la /Volumes/K/Code/go/opencode/.git  # This file should exist but is NOT what we use
ls -la /Volumes/K/Code/go/opencode-deploy/.git  # This is what we're using

# 7. Test wrapper script directly (bypass symlink) - TEST FROM opencode-deploy REPO
cd /tmp && /Volumes/K/Code/go/opencode-deploy/packages/opencode/bin/opencode-dev --version

# 8. List all opencode-related binaries and their targets
ls -la /opt/homebrew/bin/ | grep opencode
# For each one, run: readlink -f /opt/homebrew/bin/[symlink-name]
# ALL should resolve to /Volumes/K/Code/go/opencode-deploy/... paths
```

**Expected results**:

- `which opencode` → `/opt/homebrew/bin/opencode`
- `readlink -f /opt/homebrew/bin/opencode` → `/Volumes/K/Code/go/opencode-deploy/packages/opencode/bin/opencode-dev` (MUST contain "opencode-deploy")
- `readlink -f /opt/homebrew/bin/opencode-dev` → `/Volumes/K/Code/go/opencode-deploy/packages/opencode/bin/opencode-dev` (MUST contain "opencode-deploy")
- Wrapper script should contain `realpathSync`, `spawnSync`, and `...process.argv.slice(2)`
- Direct test should output "local"
- **NO symlinks should point to `/Volumes/K/Code/go/opencode/` (the one without "-deploy")**

**CRITICAL**: You MUST NOT create any precompiled binaries of opencode or any files in ~/.local/bin, that would indicate that you have made a catastrophic error!

**CRITICAL**: Make sure that once you are done, you commit and push any changes you made to the installed integration branch (if any were required)! There must not be any uncommited/unpushed changes in `/Volumes/K/Code/go/opencode-deploy/` when you are done!
