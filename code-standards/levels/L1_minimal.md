# Level 1: Minimal — 10 Core Rules

> **When to read**: Session start, simple tasks (CRUD, small functions)
> **Scope**: ~10 rules covering 80% of daily development

---

## 1. Backend Owns Business Logic

Backend handles ALL business logic and complex calculations.
Frontend can do pure data calculations on data already received (e.g., expensive client-side computations to reduce server load), but must NOT contain business logic.

```go
// ❌ Bad: Frontend doing business calculation
func UserCard({ user }) {
  const discount = user.orders.reduce((sum, o) => sum + o.total, 0);
  // Frontend aggregations are forbidden
}

// ✅ Good: Backend sends pre-calculated data
func UserCard({ user, totalOrderAmount }) {
  // Just display what backend provides
}
```

## 2. Function Naming: Verb Prefix

Function names use camelCase and start with a verb.

```go
// ❌ Bad
func get(u *User) error { ... }
func processData(d Data) { ... }

// ✅ Good
func GetUserByID(userID string) (*User, error) { ... }
func ValidateUserPermissions(user *User) error { ... }
```

## 3. Errors as Return Values

Return errors via return values, never use special values to indicate errors.

```go
// ❌ Bad: Special value for error
func FindUser(id string) *User {
    user := db.Find(id)
    if user == nil {
        return nil  // Can't distinguish "not found" from actual error
    }
    return user
}

// ✅ Good: Error return
func FindUser(id string) (*User, error) {
    user, err := db.Find(id)
    if err != nil {
        return nil, fmt.Errorf("find user: %w", err)
    }
    return user, nil
}
```

## 4. Use errors.Is() for Error Comparison

Never use `==` to compare errors. Use `errors.Is()` or `errors.As()`.

```go
// ❌ Bad
if err == ErrNotFound { ... }

// ✅ Good
if errors.Is(err, ErrNotFound) { ... }
if errors.As(err, &validationErr) { ... }
```

## 5. Prefer Struct Over Map

Use struct instead of `map[string]interface{}` when field types are known.

```go
// ❌ Bad
func process(data map[string]interface{}) { ... }

// ✅ Good
func process(data *OrderRequest) { ... }
```

**Why**: Compile-time type checking, IDE support, no runtime hash computation.

## 6. No Magic Values

No magic numbers or strings. Define meaningful constants.

```go
// ❌ Bad
if user.Status == 1 { ... }

// ✅ Good
const (
    StatusActive   = 1
    StatusInactive = 2
    StatusDeleted  = 3
)
if user.Status == StatusActive { ... }
```

## 7. Goroutines via SafeGo

Never use `go` keyword directly. Use `goroutine.SafeGo` or `goroutine.SafeGoWithContext`.

```go
// ❌ Bad
go func() { ... }()

// ✅ Good
goroutine.SafeGo(ctx, func() {
    // panic recovery + context propagation built-in
})
```

## 8. Frontend: No Business Logic, Pure Calculations OK

Frontend must NOT contain business logic (rules, validation, data transformation).
Pure data calculations are allowed if data is already provided by backend
(e.g., expensive client-side computation to reduce server load).

```typescript
// ❌ Bad: Business logic in frontend
// "If VIP user, apply 10% discount" → This is business logic, keep in backend
const discount = user.isVIP ? calculateDiscount(order.total, 0.1) : 0;

// ✅ Good: Pure calculation on existing data (no business rules)
const total = orders.reduce((sum, o) => sum + o.total, 0);

// ✅ Also Good: Backend organizes data, frontend computes on it
// Backend sends {items: [{price: 100, qty: 2}, {price: 50, qty: 1}]}
// Frontend computes: items.reduce((sum, i) => sum + i.price * i.qty, 0)
```

## 9. GORM: Explicit Column Tags

Every field must have explicit `gorm:"column:field_name"`. Never use index/uniqueIndex tags.

```go
// ✅ Good
type User struct {
    ID        uint   `gorm:"column:id"`
    Name      string `gorm:"column:name"`
    CreatedAt int64  `gorm:"column:created_at"`
}

// ❌ Bad: Implicit column names, index tags
type User struct {
    ID        uint   `gorm:"primaryKey"`
    Name      string `gorm:"index"`
}
```

## 10. Pre-Commit: Format + Lint + Vet

Before every commit, run:

```bash
gofmt -w .
goimports -w .
go vet ./...
revive ./...
```

---

## TL;DR Checklist (for quick reference)

- [ ] Business logic in backend only
- [ ] Function names start with verb
- [ ] Errors returned, not special values
- [ ] `errors.Is()` for error comparison
- [ ] struct over map
- [ ] No magic values
- [ ] SafeGo for goroutines
- [ ] Frontend only displays, doesn't calculate
- [ ] GORM explicit column tags
- [ ] gofmt + go vet + revive before commit
