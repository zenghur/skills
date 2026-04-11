---
name: frontend-standards
description: Vue 3 + TypeScript frontend standards. Use when writing or reviewing frontend code. Emphasizes separation of concerns: backend owns business logic, frontend handles presentation only.
---

# Frontend Standards

## Overview

Vue 3 + TypeScript frontend coding standards emphasizing:
- **Backend owns business logic**: Frontend only displays, never computes business rules
- **Pure calculations allowed**: Math on existing data is fine

## Modules

| Module | Description |
|--------|-------------|
| [Vue 3 + TypeScript](vue3-typescript.md) | Vue 3 Composition API, TypeScript strict, Pinia |

## Core Principles

| Principle | Canonical Source |
|-----------|------------------|
| No business logic in frontend | [Vue3 TypeScript](vue3-typescript.md#1-no-business-logic-pure-calculations-allowed) |
| Pure calculations allowed | [Vue3 TypeScript](vue3-typescript.md#1-no-business-logic-pure-calculations-allowed) |
| Vue 3 Composition API | [Vue3 TypeScript](vue3-typescript.md#4-component-structure) |
| TypeScript strict mode | [Vue3 TypeScript](vue3-typescript.md#7-code-quality-standards) |

## File Structure

```
frontend-standards/
├── SKILL.md              # Main entry
└── vue3-typescript.md    # Vue 3 + TypeScript standards
```
