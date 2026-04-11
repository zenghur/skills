# Code Review Checklists

## Backend Checklist (Summary)

> **Note**: This checklist summarizes rules from go-standards.

| Category | Rule | Canonical Source |
|----------|------|-----------------|
| Business logic | Backend owns ALL business logic | [go-standards/database](../go-standards/database.md#6-backend-owns-business-logic-cot-required) |
| Goroutines | Never use `go` keyword directly | [go-standards/concurrency](../go-standards/concurrency.md#1-goroutine-safety-rules) |
| Errors | Use `errors.Is()` and `errors.As()` | [go-standards/error-handling](../go-standards/error-handling.md#2-use-errorsis-for-error-comparison-cot-required) |
| Zero-value | Functions returning error follow zero-value pattern | [go-standards/error-handling](../go-standards/error-handling.md#3-zero-value-pattern) |
| GORM | Explicit `gorm:"column:field_name"` tags | [go-standards/database](../go-standards/database.md#1-field-tags) |
| GORM | No index/uniqueIndex tags, NOT NULL constraints | [go-standards/database](../go-standards/database.md#2-ddl-principles) |
| GORM | Use struct for updates, not map[string]interface{} | [go-standards/database](../go-standards/database.md#3-update-operations) |
| Naming | camelCase, verb prefix, no magic values | [go-standards/naming](../go-standards/naming.md) |
| Nil checks | No redundant nil checks for initialized deps | [go-standards/error-handling](../go-standards/error-handling.md#6-no-redundant-nil-checks) |
| Code quality | Single responsibility, cyclomatic complexity ≤15 | [go-standards/function-design](../go-standards/function-design.md#1-control-complexity) |
| Code quality | No mock data, TODO/FIXME in production | [go-standards/function-design](../go-standards/function-design.md#10-production-grade-code-cot-required) |
| Comments | Comments explain "why" not "how" | [go-standards/function-design](../go-standards/function-design.md#12-comments) |
| Format | gofmt + goimports + go vet before commit | [go-standards/function-design](../go-standards/function-design.md#11-pre-commit-format-lint-vet-cot-required) |

> **[@CoT-required]**: Before checking items, execute Review Process Step 1 (Rule Localization) to identify which checklist items apply to this review.

---

## Frontend Checklist (Summary)

> **Note**: This checklist summarizes rules from frontend-standards.

| Category | Rule | Canonical Source |
|----------|------|-----------------|
| Business logic | No business logic in frontend | [frontend-standards/vue3-typescript](../frontend-standards/vue3-typescript.md#1-no-business-logic-pure-calculations-allowed) |
| Business logic | No complex calculations or data aggregation | [frontend-standards/vue3-typescript](../frontend-standards/vue3-typescript.md#1-no-business-logic-pure-calculations-allowed) |
| Vue | Vue 3 Composition API with `<script setup>` | [frontend-standards/vue3-typescript](../frontend-standards/vue3-typescript.md#4-component-structure) |
| TypeScript | Strict mode, no `any` types | [frontend-standards/vue3-typescript](../frontend-standards/vue3-typescript.md#7-code-quality-standards) |
| Pinia | Global state only, no business logic | [frontend-standards/vue3-typescript](../frontend-standards/vue3-typescript.md#5-state-management) |
| Data | Timestamps formatted via utility, not computed | [go-standards/database](../go-standards/database.md#5-timestamp-handling) |
| Production | No mock data, TODO/FIXME placeholders | [go-standards/function-design](../go-standards/function-design.md#10-production-grade-code-cot-required) |
| Security | No tokens/keys in localStorage (use HttpOnly cookies) | [frontend-standards/vue3-typescript](../frontend-standards/vue3-typescript.md#14-security-xss-prevention) |
| Security | No v-html with user data (use v-text) | [frontend-standards/vue3-typescript](../frontend-standards/vue3-typescript.md#14-security-xss-prevention) |
| Security | External URLs validated against allowlist | [frontend-standards/vue3-typescript](../frontend-standards/vue3-typescript.md#14-security-xss-prevention) |
| Security | CSP headers configured | [security-standards/xss](../security-standards/xss.md#3-csp-header) |

> **[@CoT-required]**: Before checking items, execute Review Process Step 1 (Rule Localization) to identify which checklist items apply to this review.

---

## Code Review Checklist (Summary)

> **Note**: This checklist summarizes review checkpoints. Apply the Review Operation Flow (three-phase: Full Blind Scan → Structured Grouping → Rule-Anchored Analysis) for systematic review.

| Review Type | Key Questions | Canonical Source |
|-------------|---------------|------------------|
| General | Readable? Obvious bugs? Better approach? | [go-standards/function-design](../go-standards/function-design.md) |
| Error handling | Complete? Follows zero-value pattern? | [go-standards/error-handling](../go-standards/error-handling.md) |
| Security | Input validation? Injection protected? AuthZ? | [security-standards](../security-standards/SKILL.md) |
| Business logic | Logic in backend only? | [go-standards/database](../go-standards/database.md#6-backend-owns-business-logic-cot-required) |
| Performance | Cyclomatic complexity ≤15? No hidden allocations? | [go-standards/function-design](../go-standards/function-design.md#1-control-complexity) |
| Tests | Coverage adequate? Regression tests for bug fixes? | [testing-standards](../testing-standards/SKILL.md) |
| Refactoring | Features preserved? Incremental steps? | [go-standards/function-design](../go-standards/function-design.md#9-refactoring) |
| Dead code | All unused code removed after refactoring? | [go-standards/function-design](../go-standards/function-design.md#92-dead-code-cleanup) |

> **[@CoT-required]**: Before checking items, execute Review Process Step 1 (Rule Localization) to identify which checklist items apply to this review.

---

## Daily Development Checklist (Summary)

> **Note**: Daily items for quick self-check before commit.

| Check | Canonical Source |
|-------|------------------|
| Naming: verb prefix, camelCase, no magic values | [go-standards/naming](../go-standards/naming.md) |
| Error handling: errors.Is(), zero-value pattern | [go-standards/error-handling](../go-standards/error-handling.md) |
| Business logic in backend only | [go-standards/database](../go-standards/database.md#6-backend-owns-business-logic-cot-required) |
| gofmt + go vet + golangci-lint before commit | [go-standards/function-design](../go-standards/function-design.md#11-pre-commit-format-lint-vet-cot-required) |
| Comments explain "why" not "how" | [go-standards/function-design](../go-standards/function-design.md#12-comments) |
| Functions: single responsibility, ≤15 complexity | [go-standards/function-design](../go-standards/function-design.md#1-control-complexity) |
| No mock data, TODO/FIXME placeholders | [go-standards/function-design](../go-standards/function-design.md#10-production-grade-code-cot-required) |

> **[@CoT-required]**: Before checking items, execute Review Process Step 1 (Rule Localization) to identify which checklist items apply to this review.

---

## Security Review Checklist

| Category | Rule | Canonical Source |
|----------|------|-----------------|
| Input validation | All external input validated? | [security-standards/input-validation](../security-standards/input-validation.md) |
| SQL Injection | Parameterized queries only? | [security-standards/input-validation](../security-standards/input-validation.md#2-sql-injection-defense-patterns) |
| Authentication | Passwords hashed with bcrypt? | [security-standards/authentication](../security-standards/authentication.md#1-password-storage) |
| Session | HttpOnly, Secure, SameSite cookies? | [security-standards/authentication](../security-standards/authentication.md#2-session-management) |
| Authorization | RBAC implemented? | [security-standards/authorization](../security-standards/authorization.md) |
| XSS | No v-html? CSP configured? | [security-standards/xss](../security-standards/xss.md) |
| CSRF | Tokens validated on mutations? | [security-standards/csrf](../security-standards/csrf.md) |
| TLS | TLS 1.3 only? | [security-standards/tls](../security-standards/tls.md) |
| Logging | Sensitive data sanitized? | [security-standards/logging](../security-standards/logging.md) |

> **[@CoT-required]**: Before checking items, execute Review Process Step 1 (Rule Localization) to identify which checklist items apply to this review.
