---
description: "Test {env:TEST_DESCRIPTION} in markdown frontmatter"
model: "{env:TEST_MODEL}"
mode: primary
---

# Test Environment Variable Interpolation

This command tests the new {env:VAR} interpolation feature in markdown frontmatter.

## Usage

1. Set environment variables:

   ```bash
   export TEST_MODEL="gpt-4"
   export TEST_DESCRIPTION="Dynamic model selection test"
   ```

2. Run this command to see interpolation in action

## Expected Behavior

The frontmatter fields should be interpolated:

- `description` should become "Test Dynamic model selection test"
- `model` should become "gpt-4" (from TEST_MODEL env var)
- `mode` should remain "primary" (no interpolation)

## Verification

You can verify the interpolation worked by checking how this agent was loaded - the model should be set to whatever TEST_MODEL environment variable contains.

This demonstrates the feature requested in GitHub issue #5054 for dynamic model selection across agents using environment variables.
