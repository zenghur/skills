# Code Standards LLM Chain of Thought — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add mandatory Chain of Thought template to code-standards skill, requiring LLM to output rule localization → inspection process → conclusion before any review conclusion.

**Architecture:** Insert LLM-Review-Process template into SKILL.md as mandatory prefix for all review operations. Annotate each rule in L1 with `[@CoT-required]`. Add CoT enforcement notes to section headers in L2/L3/L4.

**Tech Stack:** Markdown documentation only (no code changes)

---

## Files to Modify

| File | Responsibility |
|------|---------------|
| `code-standards/SKILL.md` | Add LLM-Review-Process template section |
| `code-standards/levels/L1_minimal.md` | Add `[@CoT-required]` annotation to each of 10 rules |
| `code-standards/levels/L2_common.md` | Add CoT enforcement note to each major section header |
| `code-standards/levels/L3_advanced.md` | Add CoT enforcement note to each major section header |
| `code-standards/levels/L4_reference.md` | Add template reference and Step 1 instruction to each Checklist |

---

## Task 1: Add LLM-Review-Process Template to SKILL.md

**Files:** Modify: `code-standards/SKILL.md`

- [ ] **Step 1: Add template section after "Progressive Disclosure Levels" header, before the level index table**

In `SKILL.md`, find the line that reads:
```markdown
## Progressive Disclosure Levels
```

Insert the new section **after** the `---` separator that follows the Overview section (line ~25) and **before** the "Progressive Disclosure Levels" header.

The text to insert:

```markdown
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
```

- [ ] **Step 2: Commit**

```bash
git add code-standards/SKILL.md
git commit -m "$(cat <<'EOF'
feat(code-standards): add mandatory LLM Review Chain of Thought template

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"
```

---

## Task 2: Annotate L1 Minimal with `[@CoT-required]`

**Files:** Modify: `code-standards/levels/L1_minimal.md`

For each of the 10 rules in L1_minimal.md, add `[@CoT-required]` annotation to the rule heading.

- [ ] **Step 1: Annotate rule 1**

Change `## 1. Backend Owns Business Logic` to `## 1. Backend Owns Business Logic [@CoT-required]`

- [ ] **Step 2: Annotate rule 2**

Change `## 2. Function Naming: Verb Prefix` to `## 2. Function Naming: Verb Prefix [@CoT-required]`

- [ ] **Step 3: Annotate rule 3**

Change `## 3. Errors as Return Values` to `## 3. Errors as Return Values [@CoT-required]`

- [ ] **Step 4: Annotate rule 4**

Change `## 4. Use errors.Is() for Error Comparison` to `## 4. Use errors.Is() for Error Comparison [@CoT-required]`

- [ ] **Step 5: Annotate rule 5**

Change `## 5. Prefer Struct Over Map` to `## 5. Prefer Struct Over Map [@CoT-required]`

- [ ] **Step 6: Annotate rule 6**

Change `## 6. No Magic Values` to `## 6. No Magic Values [@CoT-required]`

- [ ] **Step 7: Annotate rule 7**

Change `## 7. Goroutines via SafeGo` to `## 7. Goroutines via SafeGo [@CoT-required]`

- [ ] **Step 8: Annotate rule 8**

Change `## 8. Frontend: No Business Logic, Pure Calculations OK` to `## 8. Frontend: No Business Logic, Pure Calculations OK [@CoT-required]`

- [ ] **Step 9: Annotate rule 9**

Change `## 9. GORM: Explicit Column Tags` to `## 9. GORM: Explicit Column Tags [@CoT-required]`

- [ ] **Step 10: Annotate rule 10**

Change `## 10. Pre-Commit: Format + Lint + Vet` to `## 10. Pre-Commit: Format + Lint + Vet [@CoT-required]`

- [ ] **Step 11: Commit**

```bash
git add code-standards/levels/L1_minimal.md
git commit -m "$(cat <<'EOF'
feat(code-standards): annotate all L1 rules with [@CoT-required]

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"
```

---

## Task 3: Add CoT Enforcement Notes to L2 Common

**Files:** Modify: `code-standards/levels/L2_common.md`

Add a CoT enforcement note at the beginning of each major section.

- [ ] **Step 1: Add note to "## 1. Naming Conventions" section**

After the `### 1.1 Basic Naming Rules` line (line ~11), insert:

```markdown
> **[@CoT-required]**: When reviewing naming conventions, execute LLM-Review-Process Step 1-3 before giving conclusions.
```

- [ ] **Step 2: Add note to "## 2. Error Handling" section**

After the line `### 2.1 Zero-Value Pattern` (line ~78), insert the same note.

- [ ] **Step 3: Add note to "## 3. Database Standards (GORM)" section**

After the line `### 3.1 Field Tags` (line ~150), insert the same note.

- [ ] **Step 4: Add note to "## 4. Logging Standards" section**

After the line `### 4.1 Logger Usage` (line ~191), insert the same note.

- [ ] **Step 5: Add note to "## 6. Comments" section**

After the line `### 6.1 Core Principles` (line ~252), insert the same note.

- [ ] **Step 6: Add note to "## 7. Guard Clauses" section**

After the line `Handle exceptional cases first with early returns:` (line ~309), insert the same note.

- [ ] **Step 7: Add note to "## 8. Code Formatting" section**

After the line `### 8.1 Vertical Formatting` (line ~350), insert the same note.

- [ ] **Step 8: Add note to "## 9. Test Synchronization" section**

After the line `### 9.1 Sync with Code Changes` (line ~409), insert the same note.

- [ ] **Step 9: Add note to "## 12. Frontend Standards (Vue 3 + TypeScript)" section**

After the line `### 12.1 No Business Logic, Pure Calculations Allowed` (line ~517), insert the same note.

- [ ] **Step 10: Commit**

```bash
git add code-standards/levels/L2_common.md
git commit -m "$(cat <<'EOF'
feat(code-standards): add CoT enforcement notes to L2 sections

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"
```

---

## Task 4: Add CoT Enforcement Notes to L3 Advanced

**Files:** Modify: `code-standards/levels/L3_advanced.md`

- [ ] **Step 1: Add note to "## 1. DDD Architecture" section**

After the line `### 1.1 Layered Structure` (line ~13), insert:

```markdown
> **[@CoT-required]**: When reviewing DDD architecture, execute LLM-Review-Process Step 1-3 before giving conclusions.
```

- [ ] **Step 2: Add note to "## 2. Goroutine & Concurrency Safety" section**

After the line `### 2.1 Goroutine Safety Rules` (line ~88), insert the same note.

- [ ] **Step 3: Add note to "## 3. Function Design" section**

After the line `### 3.1 Control Complexity` (line ~214), insert the same note.

- [ ] **Step 4: Add note to "## 4. Refactoring" section**

After the line `### 4.1 Feature Preservation` (line ~369), insert the same note.

- [ ] **Step 5: Commit**

```bash
git add code-standards/levels/L3_advanced.md
git commit -m "$(cat <<'EOF'
feat(code-standards): add CoT enforcement notes to L3 sections

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"
```

---

## Task 5: Add Template Reference to L4 Reference Checklists

**Files:** Modify: `code-standards/levels/L4_reference.md`

- [ ] **Step 1: Modify "## Backend Checklist" header**

Change the `## Backend Checklist` line to:

```markdown
## Backend Checklist

> **[@CoT-required]**: Before checking items, execute LLM-Review-Process Step 1 (Rule Localization) to identify which checklist items apply to this review.
```

- [ ] **Step 2: Modify "## Frontend Checklist" header**

Change the `## Frontend Checklist` line to:

```markdown
## Frontend Checklist

> **[@CoT-required]**: Before checking items, execute LLM-Review-Process Step 1 (Rule Localization) to identify which checklist items apply to this review.
```

- [ ] **Step 3: Modify "## Code Review Checklist" header**

Change the `## Code Review Checklist` line to:

```markdown
## Code Review Checklist

> **[@CoT-required]**: Before checking items, execute LLM-Review-Process Step 1 (Rule Localization) to identify which checklist items apply to this review.
```

- [ ] **Step 4: Modify "## Daily Development Checklist" header**

Change the `## Daily Development Checklist` line to:

```markdown
## Daily Development Checklist

> **[@CoT-required]**: Before checking items, execute LLM-Review-Process Step 1 (Rule Localization) to identify which checklist items apply to this review.
```

- [ ] **Step 5: Commit**

```bash
git add code-standards/levels/L4_reference.md
git commit -m "$(cat <<'EOF'
feat(code-standards): add CoT template references to L4 checklists

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"
```

---

## Verification

After all tasks complete, run to confirm all changes are committed:

```bash
git log --oneline -6
```

Expected output:
```
[feat] add CoT template references to L4 checklists
[feat] add CoT enforcement notes to L3 sections
[feat] add CoT enforcement notes to L2 sections
[feat] annotate all L1 rules with [@CoT-required]
[feat] add mandatory LLM Review Chain of Thought template
[docs] add spec for code-standards LLM CoT enforcement  # (spec commit)
```

---

## Spec Coverage Check

| Spec Requirement | Task |
|-----------------|------|
| SKILL.md 新增 LLM-Review-Process 模板 | Task 1 |
| L1_minimal.md 每条铁律前增加 `[@CoT-required]` 标注 | Task 2 |
| L2_common.md 各子章节开头增加 CoT 强制说明 | Task 3 |
| L3_advanced.md 各子章节开头增加 CoT 强制说明 | Task 4 |
| L4_reference.md Checklist 页面增加模板引用说明 | Task 5 |
| 零丢失：现有规则内容完全保留 | All tasks — only adding annotations, no content removal |
