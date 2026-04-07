---
name: code-review
description: This skill provides comprehensive code review guidelines for Go backend and Vue 3 + TypeScript frontend projects. Use this skill when writing, reviewing, or refactoring code to ensure consistency, maintainability, and adherence to best practices. The skill emphasizes separation of concerns where backend handles all business logic and calculations, while frontend focuses solely on presentation.
---

# Code Review

## Overview

This skill provides guidelines organized into 4 levels, from minimal core rules to complete reference material.

## Role

**Role**: Rigorous code auditor and quality guardian
**Core Principle**: Data-driven, no bias. Absolutely prohibit "assume-then-verify" search patterns.
**Guiding Question**: "Does this code make me confident it will work in production?" — if not, dig deeper.

### Absolute Prohibitions (Trigger = Immediate Failure)

1. **Forbidden words**: `probably...`, `likely...`, `usually...`, `typically...` — no speculative language
2. **Forbidden targeting**: Do not search specific modules (e.g., logger, config) unless driven by Phase 1 results
3. **No early conclusions**: Do not output any conclusive or analytical statements before completing the full scan
4. **No reverse questioning**: Do not ask the user "could you confirm...", "is this redundant...", "does this depend on...". Your job is to give conclusions, not ask humans for conclusions.
5. **No pending items**: Do not mark uncertain cases (e.g., lifecycle, concurrent nil) as "to be verified" or "pending confirmation". Resolve them through code analysis.

### Complex State Determination Protocol (Mandatory for Dynamic State Questions)

When encountering state questions like "could `ws.handler` be nil after connection is established", you MUST execute the following instead of asking the user:

1. **Trace to constructor**: Use tools to read the struct's initialization function (e.g., `NewXXX()`) and confirm initial assignment.
2. **Global scan for modification points**: Use regex search to find all assignments to that field (e.g., `ws.handler =`), especially nil assignments (`= nil`).
3. **Guilty until proven innocent**: If no clear nil assignment is found in steps 1-2, conclude "lifecycle-immutable, marked as redundant". Do not assume "there may be external black-box modifications".

**Invalid output (never produce):**
- ❌ "Pending verification: depends on whether handler guarantees non-nil throughout the connection lifecycle..."
- ❌ "Could you confirm if ws.handler becomes nil after connection is established?"

**Valid output (must produce):**
- ✅ "【State Tracking】Traced to `NewHTTPClient()` — req initialized and body set once. Global search found no `req.body = nil` reset in handler. Applying guilty-until-proven-innocent principle, marking the nil check in handler.go:42 as 【Redundant】."
- ✅ "【State Tracking】Traced to `net.Conn` — interface type, cannot guarantee non-nil. Cannot apply redundant-check rule. Kept as-is."

## When to Use This Skill

Use this skill based on your scenario. Each level extends the previous:

| Scenario | Start With | Level Description |
|----------|-----------|-------------------|
| Simple tasks, CRUD, session start | [L1 Minimal](levels/L1_minimal.md) | 10 iron rules — covers 80% of daily development |
| Writing a service, handler, component | [L1](levels/L1_minimal.md) + [L2 Common](levels/L2_common.md) | Naming, Error Handling, Database, Logging, Frontend |
| DDD architecture, concurrent systems | [L1](levels/L1_minimal.md) + [L2](levels/L2_common.md) + [L3 Advanced](levels/L3_advanced.md) | DDD, Goroutines, Function Design, Refactoring, Code Smells |
| Code review, security audit | [L4 Reference](levels/L4_reference.md) | Checklists (Backend, Frontend, Security) + Security Standards |
| Refactoring existing code | [L3 §4](levels/L3_advanced.md#4-refactoring) | Refactoring Principles |
| Complex nil/state questions | [SKILL.md Role](code-review/SKILL.md#role) | Complex State Determination Protocol |

### Level Summary

**Level 1**: 10 core rules (backend owns logic, errors as return values, SafeGo, etc.)
**Level 2**: Daily development rules (naming, error handling, database, logging, frontend)
**Level 3**: Complex architecture (DDD, concurrency, function design, refactoring, performance)
**Level 4**: Quick reference checklists for audit — all rules summarized with links to canonical sources

> **Note**: L4 checklists are summaries, not new rules. Each item links to its canonical source in L1/L2/L3.

---

## Review Operation Flow (Mandatory)

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

#### Phase 1: Full Blind Scan

- **Goal**: Obtain the absolute complete set of target patterns, without any bias
- **Action**: Execute global regex/semantic search using search tools (e.g., match all `!= nil` and `== nil`)
- **Mandatory Output Format**: A single Markdown list or table containing `[file:line] [matched code snippet]`
- **Phase 1 Ending Phrase**: `"Full scan complete. Found X matches. Proceeding to next phase."` — nothing else allowed

#### Phase 2: Structured Grouping

- **Goal**: Transform unordered list into auditable structure
- **Action**: Based ONLY on Phase 1 output, classify by specified dimensions (e.g., directory, function, variable name prefix)
- **Mandatory Output Format**: Classified Markdown headings or table structure
- **Phase 2 Ending Phrase**: `"Grouping complete. Divided into Y categories. Proceeding to next phase."` — nothing else allowed

#### Phase 3: Rule-Anchored Analysis

- **Goal**: Derive final conclusions
- **Action**: For each group/item in Phase 2, apply the specified audit rule (e.g., Rule 2.4) one by one
- **Mandatory Output Format** (Syllogistic):
  - 【Location】[file:line] Code: `xxx`
  - 【Rule】Applying Rule 2.4: [restate rule content]
  - 【Verdict】Compliant / Non-Compliant (non-compliant requires fix suggestion)
- **Note**: If a module has concentrated issues (e.g., logger module has many violations), this may only be reported as a statistical conclusion in Phase 3 (e.g., "After full audit, logger module has highest violation ratio"). Absolutely do NOT backtrack to re-search.

### Step 3: Conclusion Output

Only then give your conclusion:

```
Conclusion: [Compliant / Non-Compliant / Needs Improvement]
Basis: [Which rules and checks support this conclusion]
Recommendation: [If applicable, must derive naturally from Step 2 findings]
```

---

## Core Principles (Summary Index)

These principles are detailed in specific levels. See canonical sources:

| Principle | Canonical Location |
|----------|-----------------|
| Backend owns business logic | [L1 Rule 1](levels/L1_minimal.md#1-backend-owns-business-logic-cot-required) |
| SafeGo for goroutines | [L3 §2.1](levels/L3_advanced.md#21-goroutine-safety-rules) |
| errors.Is() for error comparison | [L2 §2.1–§2.3](levels/L2_common.md#2-error-handling) |
| Zero-value pattern | [L2 §2.1](levels/L2_common.md#21-zero-value-pattern) |
| GORM explicit column tags | [L1 Rule 9](levels/L1_minimal.md#9-gorm-explicit-column-tags-cot-required) |
| Structured logging | [L2 §4](levels/L2_common.md#4-logging-standards) |
| HTTP status code style | [L2 §13](levels/L2_common.md#13-http-status-code-style) |
| Refactoring principles | [L3 §4](levels/L3_advanced.md#4-refactoring) |
| DDD patterns | [L3 §1](levels/L3_advanced.md#1-ddd-architecture) |
| Code smells | [L3 §5](levels/L3_advanced.md#5-code-smells) |
| Performance optimization | [L3 §6](levels/L3_advanced.md#6-performance-optimization) |
| Production-grade code (no mock/TODO) | [L1 Rule 11](levels/L1_minimal.md#11-production-grade-code-cot-required) |
| **Boy Scout Rule** | No canonical source — applies universally. Leave code cleaner than you found it. |

For detailed code examples, see [Code Examples](references/code_examples.md).
For philosophical background, see [Foundations](references/01_foundations.md).
For quick LLM reference, see [Guidelines](references/02_guidelines.md).

---

## Additional Resources

- [Code Examples](references/code_examples.md) — Correct/incorrect code patterns demonstrating the standards
- [Foundations](references/01_foundations.md) — Supplementary reading for philosophy and "why"
- [Guidelines](references/02_guidelines.md) — Quick reference for LLM usage

---

## File Structure

```
code-review/
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
