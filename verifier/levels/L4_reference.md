# L4: Reference — CI/CD Hooks, Recording & Project Setup

**When**: Setting up verification infrastructure, recording sessions, CI/CD integration

Reference material for advanced setup and tooling.

---

## Asciinema Recording (CLI Verification)

For CLI tools, use asciinema to record verification sessions.

### Install asciinema

```bash
# macOS
brew install asciinema

# Linux
curl -s https://asciinema.org/install | sh

# pip
pip install asciinema
```

### Recording a Verification Session

```bash
# Start recording to file
asciinema rec /tmp/verify-recording.json

# Run your CLI verification commands
./my-cli --help
./my-cli --input test/data.json
./my-cli --invalid-input

# Stop recording
exit

# Or use the API directly
asciinema rec --stdin /tmp/verify-recording.json &
CLI_PID=$!
./my-cli --full-test
kill $CLI_PID
```

### Recording Options

```bash
# Record idle time (no long pauses)
asciinema rec --idle-time-limit=2 /tmp/session.json

# Record with title
asciinema rec --title="CLI Verification Run" /tmp/session.json

# Quiet mode
asciinema rec --quiet /tmp/session.json
```

### Verify Recording Playback

```bash
# View recording metadata
asciinema cat /tmp/verify-recording.json | head -50

# Playback in terminal
asciinema play /tmp/verify-recording.json

# Export to GIF (requires agg)
agg /tmp/verify-recording.json /tmp/verify-recording.gif
```

---

## Continuous Verification Hooks

### pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Running pre-commit verification..."

npm run lint
if [ $? -ne 0 ]; then
  echo "FAIL: Lint errors found"
  exit 1
fi

npm run type-check
if [ $? -ne 0 ]; then
  echo "FAIL: Type errors found"
  exit 1
fi

echo "PASS: Pre-commit checks passed"
exit 0
```

### pre-push Hook

```bash
#!/bin/bash
# .git/hooks/pre-push

echo "Running pre-push verification..."

npm run test
if [ $? -ne 0 ]; then
  echo "FAIL: Tests failing"
  exit 1
fi

npm run build
if [ $? -ne 0 ]; then
  echo "FAIL: Build failed"
  exit 1
fi

echo "PASS: Pre-push checks passed"
exit 0
```

### post-checkout Hook

```bash
#!/bin/bash
# .git/hooks/post-checkout

if [ -f package.json ]; then
  npm install
fi
```

---

## Verification on CI/CD

### GitHub Actions

```yaml
# .github/workflows/verify.yml
name: Verification

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  verify:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm ci

      - name: Build
        run: npm run build

      - name: Run tests
        run: npm test

      - name: Run verifier
        run: |
          npm run dev &
          DEV_PID=$!
          sleep 10
          npx verifier --plan verification/plan.md
          RESULT=$?
          kill $DEV_PID
          exit $RESULT

      - name: Upload artifacts
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: verification-artifacts
          path: |
            /tmp/screenshots/
            /tmp/recordings/
            /tmp/diffs/
```

### GitLab CI

```yaml
# .gitlab-ci.yml
verify:
  stage: test
  script:
    - npm ci
    - npm run build
    - npm test
    - |
      npm run dev &
      sleep 10
      npx verifier --plan verification/plan.md
      RESULT=$?
      kill %1 || true
      exit $RESULT
  artifacts:
    when: on_failure
    paths:
      - /tmp/screenshots/
      - /tmp/diffs/
```

### Hook Installation

```bash
mkdir -p .git/hooks
chmod +x .claude/hooks/pre-commit
chmod +x .claude/hooks/pre-push
chmod +x .claude/hooks/post-checkout

ln -sf ../../.claude/hooks/pre-commit .git/hooks/pre-commit
ln -sf ../../.claude/hooks/pre-push .git/hooks/pre-push
ln -sf ../../.claude/hooks/post-checkout .git/hooks/post-checkout
```

---

## Init-Verifiers: Project Setup

To initialize verifiers for a new project:

### Phase 1: Detect Project Type

```bash
ls -la
cat package.json 2>/dev/null | jq -r '.scripts'
cat pyproject.toml 2>/dev/null | grep -A5 "tool"
cat Cargo.toml 2>/dev/null | grep "name\|version"
cat go.mod 2>/dev/null | grep "module"

# Determine type
# - package.json + scripts.dev → Frontend
# - pyproject.toml + django/fastapi → Backend
# - Cargo.toml → Rust CLI
# - go.mod → Go CLI
```

### Phase 2: Detect Verification Tools

```bash
cat package.json | jq '.devDependencies | keys | .[]' | grep -i "playwright\|cypress\|jest\|vitest"
env | grep -i "playwright\|chrome"
cat .mcp.json 2>/dev/null | jq '.mcpServers | keys'
which asciinema
```

### Phase 3: Generate Verifier

```
mkdir -p .claude/skills/verifier-frontend-playwright  # Frontend
mkdir -p .claude/skills/verifier-backend-api          # Backend
mkdir -p .claude/skills/verifier-cli                  # CLI
```

### Phase 4: Ask Questions

For each verifier, ask:
1. Dev server command? (e.g., `npm run dev`)
2. Dev server port? (e.g., `3000`)
3. Ready signal? (e.g., `curl -s localhost:3000 | grep "ready"`)
4. Auth required? (yes/no)
5. Auth method? (form/token/oauth/cookie)

### Phase 5: Write SKILL.md

Write the generated SKILL.md to the verifier directory with all project-specific values filled in.

---

## Hook Configuration in Settings

```yaml
# .claude/settings.json
{
  "hooks": {
    "pre-commit": {
      "enabled": true,
      "commands": ["npm run lint", "npm run type-check"],
      "failOnError": true
    },
    "pre-push": {
      "enabled": true,
      "commands": ["npm test", "npm run build"],
      "failOnError": true
    },
    "post-checkout": {
      "enabled": true,
      "commands": ["npm install"],
      "failOnError": false
    }
  }
}
```

---

## Continuous Verification Checklist

```
[ ] Create .claude/hooks/ directory
[ ] Write pre-commit hook
[ ] Write pre-push hook
[ ] Write post-checkout hook
[ ] Make hooks executable
[ ] Symlink to .git/hooks/
[ ] Add .claude/hooks/ to version control
[ ] Set up CI/CD workflow
[ ] Configure artifact upload on failure
[ ] Test hooks locally before commit
```
