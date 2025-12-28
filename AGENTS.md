# Universal guidelines for every project

- You MUST NOT create documentation files unless the user asks you explicitly to do so.

# Agent Guidelines for opencode Configuration

## Build & Test Commands for the included prompt-enhancer tool
- **Build**: `cd prompt-enhancer && go build -o prompt-enhancer .`
- **Test all**: `cd prompt-enhancer && go test -v`
- **Test single**: `cd prompt-enhancer && go test -v -run TestName`
- **No lint command** found in this codebase

## Code Style for the included prompt-enhancer tool
- **Language**: Go 1.25.2, TypeScript for plugins
- **Imports**: Standard library first, third-party next, group by blank lines
- **Comments**: Only package-level and complex function comments; avoid inline comments
- **Types**: Use explicit types for structs; leverage type inference for variables
- **Naming**: camelCase for private, PascalCase for exported; descriptive names preferred
- **Error handling**: Return errors, don't panic; wrap errors with context using fmt.Errorf
- **Constants**: Group related constants using const blocks with clear naming

## Project-Specific Rules
- Prompt enhancer uses `~/` path expansion for config files at `~/.config/opencode/`
- Command aliases: `ask` maps to `question`
- RFC argument parsing: `rfc` or `RFC` as positional arg (2nd or 3rd position)
- Log invocations to `~/.config/opencode/prompt-enhancer/log.md` with timestamps
- The source code for opencode is linked at `./opencode-source` just in case you need to study it.
