---
name: code-standards
description: This skill provides comprehensive coding standards for Go backend and Vue 3 + TypeScript frontend projects. Use this skill when writing, reviewing, or refactoring code to ensure consistency, maintainability, and adherence to best practices. The skill emphasizes separation of concerns where backend handles all business logic and calculations, while frontend focuses solely on presentation.
---

# Code Standards

## Overview

This skill provides **progressive** coding standards for Go backend and Vue 3 + TypeScript frontend development. Standards are organized into 4 levels, from minimal core rules to complete reference material.

## When to Use This Skill

Use this skill when:
- Writing new code (backend or frontend)
- Refactoring existing code
- Reviewing pull requests
- Fixing code quality issues
- Setting up database models (backend)
- Implementing DDD architecture layers (backend)
- Creating Vue components (frontend)
- Managing application state (frontend)

---

## LLM Review Operation Flow (Mandatory)

**Applies to**: All code review, PR review, security audit, and refactoring verification.

Before giving any conclusion or suggestion, you MUST follow this three-step chain of thought:

### Step 1: Rule Localization

State which rules from which level you are checking.

```
Review Scope:
- Rule Source: [L1 / L2 / L3 / L4]
- Specific Rules: [Rule Number] [One-line rule description]
```

### Step 2: Inspection Process

For each rule, show your checking steps explicitly:

```
Rule [Number]: [Description]
Inspection:
- [Specific check 1]: Result
- [Specific check 2]: Result
```

### Step 3: Conclusion Output

Only then give your conclusion:

```
Conclusion: [Compliant / Non-Compliant / Needs Improvement]
Basis: [Which rules and checks support this conclusion]
Recommendation: [If applicable, must derive naturally from Step 2 findings]
```

**Enforcement**: Rules marked `[@CoT-required]` in L1 trigger this full three-step process. Other levels use the same process for all review operations.

---

## Progressive Disclosure Levels

### [Level 1: Minimal](levels/L1_minimal.md) — 10 Core Rules

**When**: Session start, simple tasks (CRUD, small functions)

The 10 iron rules covering 80% of daily development scenarios.

### [Level 2: Common](levels/L2_common.md) — Daily Development

**When**: Normal feature development (writing a service, handler, component)

Extends Level 1 with: Naming, Error Handling, Database, Logging, Comments, Guard Clauses, Testing, Code Formatting.

### [Level 3: Advanced](levels/L3_advanced.md) — Complex Architecture

**When**: Complex architecture design, DDD implementation, concurrent systems

Extends Level 1+2 with: DDD Architecture, Goroutine & Concurrency Safety, Function Design, Refactoring Principles, Code Smells, Performance Optimization.

### [Level 4: Reference](levels/L4_reference.md) — Complete Checklists & Security

**When**: Code review, security audits, deep-dive scenarios

Complete checklists (Backend, Frontend, Security, Daily, Code Review) + complete Security Standards (Defense in Depth, Input Validation, Authentication, Cryptography, XSS, CSRF, RBAC, TLS, Memory Safety, Audit Logging).

---

## Quick Access

| Scenario | Start With |
|----------|-----------|
| Simple CRUD | [L1 Minimal](levels/L1_minimal.md) |
| Write a service | [L1](levels/L1_minimal.md) + [L2 Common](levels/L2_common.md) |
| Design DDD architecture | [L1](levels/L1_minimal.md) + [L2](levels/L2_common.md) + [L3 Advanced](levels/L3_advanced.md) |
| Code review | [L4 Reference](levels/L4_reference.md) (Checklists) |
| Security audit | [L4 Reference](levels/L4_reference.md) (Security Standards) |
| All content | Read all levels in order |

---

## Core Principles

These principles underpin all levels:

### Separation of Concerns
- **Backend**: Handles ALL business logic, calculations, and complex data aggregation
- **Frontend**: No business logic, can do pure data calculations on data already received
- **No Business Logic in Frontend**: Frontend must not contain rules, decisions, or business logic
- **Backend Trust**: Frontend trusts backend to provide all necessary data in ready-to-display format

### Production-Grade Code
- **No Mock Data**: Never use mock data, mock functions, or placeholder implementations in production code
- **No Stub Functions**: All functions must have complete, working implementations
- **No TODO Placeholders**: No "TODO", "FIXME", or placeholder code that defers implementation
- **No Temporary Solutions**: Every piece of code must be production-ready, not a quick fix or workaround
- **Complete Implementation**: All features must be fully implemented with proper error handling
- **Testable Code**: Code must be written with testing in mind, but test mocks are only allowed in test files

### Code Quality Standards
- **Readability**: Code should clearly express intent without excessive reliance on comments
- **Maintainability**: Easy to modify and extend
- **Testability**: Code should be easy to write unit tests for

### Boy Scout Rule
Leave the code cleaner than you found it. Every commit should improve the codebase - even small improvements like renaming a variable or extracting a long function count as progress.

### Refactoring Principles
- **Feature Preservation**: Refactoring MUST preserve ALL existing functionality - no features should be lost
- **Behavior Equivalence**: After refactoring, the system must behave identically to before
- **No Silent Removals**: Never remove functionality during refactoring without explicit requirement
- **Feature Inventory**: Before refactoring, list all existing features to ensure none are missed
- **Verification Required**: After refactoring, verify each feature still works correctly
- **Incremental Refactoring**: Large refactorings should be broken into smaller, verifiable steps
- **Rollback Ready**: Keep the ability to rollback if issues are discovered post-refactoring

---

## Additional Resources

- [Code Examples](references/code_examples.md) — Correct/incorrect code patterns demonstrating the standards
- [Foundations](references/01_foundations.md) — Supplementary reading for philosophy and "why"
- [Guidelines](references/02_guidelines.md) — Quick reference for LLM usage

---

## File Structure

```
code-standards/
├── SKILL.md              # This file (main entry + layered index)
├── CLAUDE.md             # Claude Code project guidance
├── levels/
│   ├── L1_minimal.md    # 10 core rules
│   ├── L2_common.md     # Daily development rules
│   ├── L3_advanced.md   # Complex architecture rules
│   └── L4_reference.md  # Checklists + Security Standards
└── references/
    ├── code_examples.md
    ├── 01_foundations.md
    └── 02_guidelines.md
```
