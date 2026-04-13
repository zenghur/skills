---
name: go-standards
description: Go coding standards skill covering naming conventions, error handling, concurrency safety, database standards, and function design. Use when writing or reviewing Go code.
---

# Go Standards

## Overview

Go coding standards organized into focused modules for precision and maintainability.

## Modules

| Module | Description |
|--------|-------------|
| [Naming](naming.md) | camelCase, verb prefix, no magic values |
| [Error Handling](error-handling.md) | errors.Is(), zero-value, wrapping |
| [Concurrency](concurrency.md) | SafeGo, channels, goroutine leak prevention |
| [Database](database.md) | GORM explicit column tags, NOT NULL constraints |
| [Function Design](function-design.md) | Complexity ≤15, single responsibility |
| [JSON Marshaling](json-marshaling.md) | No string concat, use struct marshal |

## Core Principles (Summary)

| Principle | Canonical Location |
|-----------|-------------------|
| Backend owns business logic | [Database](database.md#6-backend-owns-business-logic-cot-required) |
| SafeGo for goroutines | [Concurrency](concurrency.md#1-goroutine-safety-rules) |
| errors.Is() for error comparison | [Error Handling](error-handling.md#2-use-errorsis-for-error-comparison-cot-required) |
| Zero-value pattern | [Error Handling](error-handling.md#3-zero-value-pattern) |
| GORM explicit column tags | [Database](database.md#1-field-tags) |
| Cyclomatic complexity ≤15 | [Function Design](function-design.md#1-control-complexity) |
| No mock data, TODO/FIXME | [Function Design](function-design.md#10-production-grade-code-cot-required) |
| Struct marshal JSON | [JSON Marshaling](json-marshaling.md#1-禁止字符串拼接-json) |

## File Structure

```
go-standards/
├── SKILL.md              # Main entry
├── naming.md             # Naming conventions
├── error-handling.md     # Error handling patterns
├── concurrency.md        # Concurrency safety
├── database.md           # GORM and database standards
├── function-design.md    # Function design principles
└── json-marshaling.md    # JSON serialization standards
```

## Development Commands

```bash
# Install golangci-lint
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# Static analysis
go vet ./...

# Lint check (required before any PR)
golangci-lint run ./...

# Format code
gofmt -w .
goimports -w .
```
