---
name: testing-standards
description: Testing standards covering test coverage requirements, test synchronization principles, and test patterns. Use for all testing-related scenarios.
---

# Testing Standards

## Overview

Testing standards covering coverage requirements, test synchronization, and patterns.

## Modules

| Module | Description |
|--------|-------------|
| [Coverage](coverage.md) | Coverage requirements and thresholds |
| [Test Patterns](patterns.md) | Table-driven tests and other patterns |
| [Synchronization](sync.md) | Test synchronization with code changes |

## Core Principles

| Principle | Canonical Location |
|-----------|-------------------|
| Unit tests ≥70% | [Coverage](coverage.md#coverage-thresholds) |
| Test synchronization | [Sync](sync.md) |
| Table-driven tests | [Patterns](patterns.md) |

## File Structure

```
testing-standards/
├── SKILL.md          # Main entry
├── coverage.md        # Coverage requirements
├── patterns.md       # Test patterns
└── sync.md          # Test synchronization
```
