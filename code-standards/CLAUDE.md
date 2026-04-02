# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a **coding standards skill** repository containing comprehensive guidelines for Go backend and Vue 3 + TypeScript frontend development. When working in other projects, apply these standards to ensure consistency.

## Key Files

- `SKILL.md` — Complete coding standards documentation (46KB)
- `references/code_examples.md` — Correct/incorrect code patterns demonstrating the standards
- `references/02_guidelines.md` — **Quick reference** for LLM usage (primary)
- `references/01_foundations.md` — **Supplementary reading** for philosophy and "why"

## Development Commands

```bash
# Install revive linter (required for lint checks)
go install github.com/mgechev/revive@latest

# Static analysis
go vet ./...

# Lint check (required before any PR)
revive ./...

# Format code
gofmt -w .
goimports -w .
```

## Core Architecture Principles

### Separation of Concerns
- **Backend (Go)**: Handles ALL business logic, calculations, data aggregation, and database operations
- **Frontend (Vue 3 + TypeScript)**: ONLY handles presentation, receives pre-calculated data from backend
- Backend trust: Frontend trusts backend to provide ready-to-display data

### Key Backend Standards (Go)
- Internal interface data uses **camelCase** naming
- External system integration: use field names as-is, do not transform to camelCase. Only our own APIs follow camelCase.
- Database fields use **snake_case** with explicit `gorm:"column:field_name"` tags
- All DDL fields must have **NOT NULL** constraint
- Use struct model for gorm updates (not `map[string]interface{}`)
- Timestamps use **int64** (UnixMilli)
- No raw SQL for CRUD — use gorm model methods
- **Never** use `go` keyword directly — use `goroutine.SafeGo` or `goroutine.SafeGoWithContext`
- No mock data, stub functions, or TODO placeholders in production code
- Functions returning error must return zero values for other returns when error is not nil
- Use `errors.Is()` and `errors.As()` for error comparison (never `==`)
- Cyclomatic complexity should be ≤15

### Key Frontend Standards (Vue 3 + TypeScript)
- Use Vue 3 Composition API with `<script setup>` syntax
- No business logic or complex calculations in frontend
- TypeScript strict mode, no `any` type
- Pinia for global state only, no business logic in stores

## Code Quality Requirements

Every code modification must:
1. Compile successfully (`go build`)
2. Pass revive lint check (`revive ./...`)
3. Follow naming conventions (camelCase for interfaces)
4. Include no magic numbers or strings (use constants)
5. Have complete implementations (no placeholders)

## When Applying These Standards

Use these standards when:
- Writing new code (backend or frontend)
- Reviewing pull requests
- Refactoring existing code
- Setting up database models or DDD architecture layers
