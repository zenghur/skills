# Skills

Coding standards and review guidelines for Go backend and Vue 3 + TypeScript frontend development.

## Skills

| Skill | Description | Use When |
|-------|-------------|----------|
| [go-standards](go-standards/SKILL.md) | Go coding standards | Writing or reviewing Go code |
| [frontend-standards](frontend-standards/SKILL.md) | Vue 3 + TypeScript standards | Writing or reviewing frontend code |
| [code-review](code-review/SKILL.md) | Code review process and checklists | Conducting code reviews |
| [security-standards](security-standards/SKILL.md) | Security standards | Security audits, auth, XSS/CSRF |
| [testing-standards](testing-standards/SKILL.md) | Testing standards | Writing tests, coverage requirements |

## Claude Code Installation

### Option 1: Clone to Local Skills Directory

```bash
# Clone this repo to your Claude Code skills directory
git clone https://github.com/zenghur/skills.git ~/.claude/skills/my-standards

# Or symlink
ln -s /path/to/skills ~/.claude/skills/my-standards
```

### Option 2: Per-Project Reference

In your project root, add a `CLAUDE.md` that references these skills:

```markdown
## Skills

Use these skills for this project:

- `/path/to/skills/go-standards` - Go coding standards
- `/path/to/skills/frontend-standards` - Vue 3 + TypeScript standards
- `/path/to/skills/code-review` - Code review process
- `/path/to/skills/security-standards` - Security standards
- `/path/to/skills/testing-standards` - Testing standards
```

### Option 3: Invoke via Skill Tool

In Claude Code, use the `Skill` tool to invoke:

```
/skill go-standards
/skill frontend-standards
/skill code-review
/skill security-standards
/skill testing-standards
```

### Option 4: Git Submodule (Recommended for Teams)

```bash
git submodule add https://github.com/zenghur/skills.git skills
```

Then reference in project `CLAUDE.md`:

```markdown
## Local Skills

Our coding standards: ./skills/go-standards/SKILL.md
```

## Quick Start

### Writing Go Code

```
code-review + go-standards
```

### Writing Vue/TypeScript Code

```
code-review + frontend-standards
```

### Full Stack Code Review

```
code-review + go-standards + frontend-standards + security-standards
```

## go-standards

Go coding standards organized into focused modules:

- **naming.md** — camelCase, verb prefix, no magic values
- **error-handling.md** — errors.Is(), zero-value, wrapping
- **concurrency.md** — SafeGo, channels, goroutine leak prevention
- **database.md** — GORM explicit column tags, NOT NULL
- **function-design.md** — Complexity ≤15, single responsibility, refactoring

## frontend-standards

Vue 3 + TypeScript standards:

- Backend owns business logic — frontend only displays
- Pure calculations allowed — math on existing data
- Vue 3 Composition API with `<script setup>`
- TypeScript strict mode, no `any`

## code-review

Three-phase review protocol:

1. **Full Blind Scan** — Global regex search, no bias
2. **Structured Grouping** — Classify findings by dimension
3. **Rule-Anchored Analysis** — Apply rules one by one

### Absolute Prohibitions

- No speculative language (`probably...`, `likely...`)
- No early conclusions before full scan
- No reverse questioning — give conclusions, not ask
- No pending items — resolve through code analysis

## security-standards

Modules:

- **defense-in-depth.md** — Layered defense
- **input-validation.md** — SQL/NoSQL injection prevention
- **authentication.md** — Password hashing, session management
- **authorization.md** — RBAC access control
- **xss.md** — XSS prevention and CSP
- **csrf.md** — CSRF protection
- **tls.md** — TLS 1.3 configuration
- **cryptography.md** — Algorithms and key management
- **logging.md** — Security logging and audit

## testing-standards

Modules:

- **coverage.md** — Unit ≥70%, Integration ≥50%, E2E ≥30%
- **patterns.md** — Table-driven tests
- **sync.md** — Test synchronization with code changes

## Development Commands

```bash
# Go linting
go vet ./...
golangci-lint run ./...
gofmt -w .
goimports -w .
```
