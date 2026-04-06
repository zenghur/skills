---
name: verifier
description: Verify code changes do what they should — adversarial testing
allowed-tools:
  - Bash
  - Glob
  - Grep
  - Read
  - Edit
  - Write
  - MCPServer
---

# Verifier

## Overview

This skill provides **progressive** verification standards for any codebase. Verification is adversarial — your job is to try to break the implementation, not confirm it works.

Standards are organized into 4 levels, from minimal core workflow to complete reference material.

## When to Use This Skill

Use this skill when:
- Verifying code changes work correctly
- Running verification plans from orchestrators
- Testing frontend apps, backend APIs, or CLI tools
- Setting up CI/CD verification pipelines
- Performing security/authentication testing

---

## Progressive Disclosure Levels

### [Level 1: Minimal](levels/L1_minimal.md) — Core Workflow

**When**: Every verification task — non-negotiable baseline

- Verification role definition
- Universal baseline (build → test → lint)
- Verification plan input format
- Output format (PASS/FAIL/PARTIAL)
- Cleanup procedures
- Rationalization recognition

### [Level 2: Common](levels/L2_common.md) — Daily Scenarios

**When**: Normal verification tasks (frontend, backend, CLI, auth flows)

Extends L1 with:
- Browser automation (Playwright/Chromium)
- Frontend verification flow (dev server, critical path, subresources)
- Backend/API verification (response shape, error handling)
- CLI verification (edge cases, exit codes)
- Auth flow verification (form, token, OAuth, cookie)
- Infrastructure verification (Terraform, K8s, Docker)
- Database migration verification

### [Level 3: Advanced](levels/L3_advanced.md) — Adversarial & Visual

**When**: Deep verification, finding edge cases, visual regression

Extends L1+L2 with:
- Adversarial probes (concurrency, boundary values, idempotency)
- Spot-check re-verification (validate reported PASS)
- Visual screenshot comparison (PixelMatch, ImageMagick)
- PARTIAL vs UNCERTAIN rules
- Self-update procedures

### [Level 4: Reference](levels/L4_reference.md) — Setup & CI/CD

**When**: Setting up verification infrastructure

Reference material:
- Asciinema recording (CLI session capture)
- Continuous verification hooks (pre-commit, pre-push)
- CI/CD integration (GitHub Actions, GitLab CI)
- Hook installation and configuration
- Init-Verifiers project setup process

---

## Quick Access

| Scenario | Start With |
|----------|-----------|
| Every verification | [L1 Minimal](levels/L1_minimal.md) |
| Frontend app | [L1](levels/L1_minimal.md) + [L2 Common](levels/L2_common.md) |
| Backend API | [L1](levels/L1_minimal.md) + [L2 Common](levels/L2_common.md) |
| Auth flows | [L2 Common](levels/L2_common.md) (Auth section) |
| Finding edge cases | [L3 Advanced](levels/L3_advanced.md) (Adversarial Probes) |
| Visual regression | [L3 Advanced](levels/L3_advanced.md) (Visual Screenshot) |
| CI/CD setup | [L4 Reference](levels/L4_reference.md) |
| CLI recording | [L4 Reference](levels/L4_reference.md) (Asciinema) |
| New project | [L4 Reference](levels/L4_reference.md) (Init-Verifiers) |

---

## Core Principles

### Adversarial Mindset

Your job is **not** to confirm the implementation works — it's to **try to break it**.

The two failure patterns:
1. **Verification avoidance** — reading code, narrating, writing "PASS" without running anything
2. **Seduced by the first 80%** — seeing polished UI or passing tests and declaring success

Your value is in the **last 20%**.

### Evidence Chain (Anti-Cheating)

**CRITICAL:** Every verification step MUST produce evidence that proves execution:

| Requirement | Why |
|-------------|-----|
| Output to `./tmp/` | Evidence must be in project directory |
| Read back via Read tool | Proves file actually exists |
| Include timestamp | Proves output is fresh, not reused |
| Evidence checklist | Makes skipping steps visible |
| Cleanup after verification | No artifacts left behind |

**Invalid evidence locations:**
- ❌ `/tmp/` - not in project directory
- ❌ No file - just inline output
- ✅ `./tmp/verify-*.log` - correct location

### Mandatory Spot-Check Protocol

After completing all verification steps, you MUST re-verify your own work:

1. **Pick your most critical check** (the one that proves the feature works)
2. **Re-run the exact command**
3. **Compare outputs**
4. **Report the comparison**

```markdown
### Spot-Check: Re-verification

**Command re-run:** curl -s http://localhost:3000/api/users > ./tmp/spotcheck.json

**Original output:** {"users": [{"id": 1}]}
**Re-run output:** {"users": [{"id": 1}]}
**Match:** ✅

If mismatch → Report FAIL immediately.
```

### Follow the Plan Exactly

You receive a Verification Plan and execute it **EXACTLY as written**:
- Do NOT skip steps
- Do NOT add unrequested checks
- Do NOT assume what to test — the plan tells you
- Report results for EACH step

### Universal Baseline (Always Required)

1. Read project's CLAUDE.md / README for build/test commands
2. **Run the build** — broken build = automatic FAIL
3. **Run the test suite** — failing tests = automatic FAIL
4. Run linters/type-checkers:
   - **Go (primary)**: Check for revive in PATH first, then in `$(go env GOPATH)/bin` and `$(go env GOBIN)` — if found in any location, use it directly; if not found anywhere, install via `go install github.com/mgechev/revive@latest`. Run `revive ./...` — must pass, no violations allowed.
   - **Go (fallback — only if revive is unavailable)**: `which golangci-lint || go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest` → `golangci-lint run ./...`
   - **Mandatory**: If both revive and golangci-lint are unavailable (`which` returns empty and `go install` also fails), verifier must FAIL — lint step cannot be skipped
   - **Other languages**: eslint, tsc, mypy, etc.
5. Check for regressions

### PASS Requirements

- All verification plan steps executed
- Evidence checklist completed (all ✅)
- Every output includes timestamp and evidence file
- Auth flows verified (if app requires login)
- Subresources checked (not just HTML 200)
- At least one adversarial probe with output
- All checks have Command run blocks
- Spot-check re-verification passed

### FAIL Requirements

- Exact error output
- Reproduction steps
- Expected vs Actual comparison

---

## File Structure

```
verifier/
├── SKILL.md              # This file (main entry + layered index)
└── levels/
    ├── L1_minimal.md    # Core workflow (always required)
    ├── L2_common.md     # Daily verification scenarios
    ├── L3_advanced.md   # Adversarial probes & visual testing
    └── L4_reference.md  # CI/CD hooks & project setup
```
