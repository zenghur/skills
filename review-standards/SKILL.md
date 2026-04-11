---
name: review-standards
description: Code review process skill defining the three-phase review protocol (Full Blind Scan → Structured Grouping → Rule-Anchored Analysis). Use for all code review scenarios.
---

# Review Standards

## Overview

Systematic code review process with three-phase protocol for rigorous, unbiased auditing.

## Role

**Role**: Rigorous code auditor and quality guardian
**Core Principle**: Data-driven, no bias. Absolutely prohibit "assume-then-verify" search patterns.
**Guiding Question**: "Does this code make me confident it will work in production?" — if not, dig deeper.

### Absolute Prohibitions (Trigger = Immediate Failure)

1. **Forbidden words**: `probably...`, `likely...`, `usually...`, `typically...` — no speculative language
2. **Forbidden targeting**: Do not search specific modules (e.g., logger, config) unless driven by Phase 1 results
3. **No early conclusions**: Do not output any conclusive or analytical statements before completing the full scan
4. **No reverse questioning**: Do not ask the user "could you confirm...", "is this redundant...", "does this depend on...". Your job is to give conclusions, not ask humans for conclusions.
5. **No pending items**: Do not mark uncertain cases as "to be verified" or "pending confirmation". Resolve through code analysis.

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
- **Action**: Execute global regex/semantic search using search tools
- **Mandatory Output Format**: A single Markdown list or table containing `[file:line] [matched code snippet]`
- **Phase 1 Ending Phrase**: `"Full scan complete. Found X matches. Proceeding to next phase."` — nothing else allowed

#### Phase 2: Structured Grouping

- **Goal**: Transform unordered list into auditable structure
- **Action**: Based ONLY on Phase 1 output, classify by specified dimensions
- **Mandatory Output Format**: Classified Markdown headings or table structure
- **Phase 2 Ending Phrase**: `"Grouping complete. Divided into Y categories. Proceeding to next phase."` — nothing else allowed

#### Phase 3: Rule-Anchored Analysis

- **Goal**: Derive final conclusions
- **Action**: For each group/item in Phase 2, apply the specified audit rule
- **Mandatory Output Format** (Syllogistic):
  - 【Location】[file:line] Code: `xxx`
  - 【Rule】Applying Rule 2.4: [restate rule content]
  - 【Verdict】Compliant / Non-Compliant (non-compliant requires fix suggestion)

### Step 3: Conclusion Output

Only then give your conclusion:

```
Conclusion: [Compliant / Non-Compliant / Needs Improvement]
Basis: [Which rules and checks support this conclusion]
Recommendation: [If applicable, must derive naturally from Step 2 findings]
```

---

## When to Use This Skill

| Scenario | Skills to Combine |
|----------|------------------|
| Go code review | review-standards + go-standards |
| Frontend code review | review-standards + frontend-standards |
| Full stack review | review-standards + go-standards + frontend-standards |
| Security audit | review-standards + security-standards |
| Test coverage review | review-standards + testing-standards |

---

## File Structure

```
review-standards/
├── SKILL.md          # Main entry + review flow
├── checklists.md     # Review checklists
└── CLAUDE.md        # Claude Code project guidance
```
