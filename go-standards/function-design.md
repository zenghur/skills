# Function Design

## 1. Control Complexity

> **[@CoT-required]**: When reviewing function design, execute Review Process Step 1-3 before giving conclusions.

Focus on cyclomatic complexity, not line count.

**Guidelines**:
- Cyclomatic complexity ≤15 (measure with `gocyclo`)
- Nesting depth ≤3
- Single responsibility
- A 40-line linear function > 20-line spaghetti

```go
// ❌ Bad: High complexity, deep nesting
func ProcessOrder(order *Order) error {
    if order != nil {
        if order.Items != nil {
            if len(order.Items) > 0 {
                for _, item := range order.Items {
                    if item.Quantity > 0 {
                        if item.Price > 0 {
                            // Deep nesting...
                        }
                    }
                }
            }
        }
    }
    return nil
}

// ✅ Good: Low complexity, clear structure
func ProcessOrder(order *Order) error {
    if err := validateOrder(order); err != nil {
        return err
    }
    if err := processItems(order.Items); err != nil {
        return err
    }
    return updateOrderStatus(order, StatusCompleted)
}
```

## 2. Single Responsibility

One function = one clear purpose.

```go
// ❌ Bad: Mixed responsibilities
func CreateUserAndSendEmail(name, email string) error {
    user := &User{Name: name, Email: email}
    if err := db.Create(user).Error; err != nil {
        return err
    }
    subject := "Welcome"
    body := fmt.Sprintf("Hello %s, welcome!", name)
    return sendEmail(email, subject, body)
}

// ✅ Good: Separated
func CreateUser(name, email string) (*User, error) {
    user := &User{Name: name, Email: email}
    if err := db.Create(user).Error; err != nil {
        return nil, err
    }
    return user, nil
}

func SendWelcomeEmail(user *User) error {
    body := fmt.Sprintf("Hello %s, welcome!", user.Name)
    return sendEmail(user.Email, "Welcome", body)
}
```

## 3. Minimize Parameters

- 1-3 params: Ideal
- 4-5 params: Acceptable when related
- 6+ params: Consider struct or Option pattern

```go
// ❌ Bad: Too many params
func CreateOrder(userID, productID string, quantity int, price, discount float64, currency, note string) (*Order, error) {
    // ...
}

// ✅ Good: Struct for related params
type CreateOrderRequest struct {
    UserID    string
    ProductID string
    Quantity  int
    Price     Money
    Note      string
}

func CreateOrder(req *CreateOrderRequest) (*Order, error) { ... }

// ✅ Good: Functional Option for extensibility
func NewServer(addr string, opts ...ServerOption) *Server {
    server := &Server{addr: addr}
    for _, opt := range opts {
        opt(server)
    }
    return server
}
```

## 4. Avoid Side Effects

```go
// ❌ Bad: Hidden modification
var globalCounter int

func GetUserCount() int {
    globalCounter++  // Side effect!
    return globalCounter
}

// ✅ Good: No side effect
func GetUserCount() int {
    return globalCounter  // Read-only
}

func IncrementUserCount() {
    globalCounter++  // Clearly expresses modification
}
```

## 5. Separate Commands from Queries

```go
// ❌ Bad: Both command and query
func SetUserAge(user *User, age int) bool {
    if age < 0 || age > 150 {
        return false
    }
    user.Age = age
    return true
}

// ✅ Good: Separated
func ValidateAge(age int) error {
    if age < 0 || age > 150 {
        return errors.New("invalid age")
    }
    return nil
}

func SetUserAge(user *User, age int) {
    user.Age = age
}
```

## 6. Guard Clauses

Handle exceptional cases first with early returns:

> **[@CoT-required]**: When reviewing guard clauses, execute Review Process Step 1-3 before giving conclusions.

```go
// ❌ Bad: Deep nesting
func ProcessOrder(order *Order) error {
    if order != nil {
        if order.Items != nil {
            if len(order.Items) > 0 {
                // Main logic...
            }
        }
    }
    return nil
}

// ✅ Good: Guard clauses, flat structure
func ProcessOrder(order *Order) error {
    if order == nil {
        return errors.New("order is nil")
    }
    if len(order.Items) == 0 {
        return errors.New("order has no items")
    }

    // Main logic...
    return nil
}
```

### Patterns

- `if err != nil { return err }` first
- Invert conditions to return early
- Avoid else branches when possible

## 7. Code Smells

Recognize and address these patterns:

| Smell | Description | Solution |
|-------|-------------|----------|
| **Rigidity** | One change triggers cascade | Decouple, single responsibility |
| **Fragility** | Easy to break | Add tests, refactor |
| **Duplication** | Same code repeated | DRY, extract functions |
| **High Complexity** | Cyclomatic > 15 | Split functions |
| **Deep Nesting** | > 3 levels | Guard clauses, extract |
| **Long Parameter List** | 6+ params | Struct or Option pattern |
| **Divergent Change** | One class modified for multiple reasons | Single responsibility |
| **Shotgun Surgery** | One change involves many classes | Merge related logic |
| **Feature Envy** | Function uses another class's data excessively | Move function to data's class |
| **Data Clumps** | Data always together | Encapsulate as struct |

## 8. Code Organization

### File Organization

Organize by responsibility within a file:

```go
// ✅ Good: Top-down organization
package service

// 1. Public types and interfaces first
type UserService struct {
    repo UserRepository
}

type UserRepository interface {
    FindByID(ctx context.Context, id string) (*User, error)
    Save(ctx context.Context, user *User) error
}

// 2. Constructor
func NewUserService(repo UserRepository) *UserService {
    return &UserService{repo: repo}
}

// 3. Public methods
func (s *UserService) GetUser(ctx context.Context, id string) (*User, error) {
    return s.repo.FindByID(ctx, id)
}

// 4. Private methods last
func (s *UserService) validate(user *User) error { ... }
```

## 9. Refactoring

### 9.1 Feature Preservation

> **[@CoT-required]**: When reviewing refactoring, execute Review Process Step 1-3 before giving conclusions.

**CRITICAL**: Refactoring MUST preserve ALL existing functionality.

Before refactoring:
1. Document ALL features and behaviors
2. Create feature checklist
3. Note edge cases and error handling paths
4. Establish rollback plan

After refactoring:
1. Verify each feature still works
2. Run full test suite
3. Check edge cases

### 9.2 Dead Code Cleanup

> **[@CoT-required]**: After refactoring, scan for and remove ALL dead code. Execute Review Process Step 1-3 before giving conclusions.

**CRITICAL**: Refactoring MUST NOT leave dead code behind. Git preserves history — code is not lost, just removed from active maintenance.

After refactoring passes all tests:
1. Search for unreachable functions, unused variables, and unreferenced constants
2. Remove commented-out code blocks
3. Remove imports that are no longer needed
4. Verify no references remain (`grep` for removed symbols)

```go
// ❌ Bad: Dead code left after refactoring
func processOrderLegacy(order *Order) error {
    // Old implementation kept "just in case"
    ...
}

// ✅ Good: Delete it — git has the history
```

**Why**: Dead code increases maintenance burden, confuses readers, and rots over time. If you need it back, `git log` will find it.

### 9.3 Extract Function

```go
// ❌ Before: Long function doing multiple things
func ProcessOrder(order *Order) error {
    if order == nil {
        return errors.New("order is nil")
    }
    if len(order.Items) == 0 {
        return errors.New("order has no items")
    }
    var total float64
    for _, item := range order.Items {
        total += item.Price * float64(item.Quantity)
    }
    if order.Discount > 0 {
        total = total * (1 - order.Discount)
    }
    order.TotalAmount = total
    order.Status = StatusProcessed
    return nil
}

// ✅ After: Each function has one job
func ProcessOrder(order *Order) error {
    if err := validateOrder(order); err != nil {
        return err
    }
    total := calculateTotal(order.Items)
    total = applyDiscount(total, order.Discount)
    updateOrderAmount(order, total)
    return nil
}

func validateOrder(order *Order) error {
    if order == nil {
        return errors.New("order is nil")
    }
    if len(order.Items) == 0 {
        return errors.New("order has no items")
    }
    return nil
}

func calculateTotal(items []Item) float64 {
    var total float64
    for _, item := range items {
        total += item.Price * float64(item.Quantity)
    }
    return total
}

func applyDiscount(amount, discount float64) float64 {
    if discount > 0 {
        return amount * (1 - discount)
    }
    return amount
}

func updateOrderAmount(order *Order, total float64) {
    order.TotalAmount = total
    order.Status = StatusProcessed
}
```

### 9.4 Use Value Objects

```go
// ❌ Before: Primitive obsession
func CreateOrder(productID string, quantity int, price float64, currency string) (*Order, error) {
    // ...
}

// ✅ After: Value objects
type ProductID string
type Quantity int
type Money struct {
    Amount   float64
    Currency string
}

func CreateOrder(productID ProductID, quantity Quantity, price Money) (*Order, error) {
    // ...
}
```

### 9.5 Incremental Changes

Large refactorings → small, verifiable steps:

1. Make the change in the smallest possible scope
2. Run tests after each small change
3. Commit after each verifiable step
4. If something breaks, you know exactly what caused it

### 9.6 Rollback Plan

Before refactoring:
- Ensure clean git state or branch
- Know how to revert
- Consider feature flags for gradual rollout

## 10. Production-Grade Code [@CoT-required]

Never ship incomplete or placeholder code:

```go
// ❌ Bad: Placeholder implementation
func GetUser(id string) (*User, error) {
    return nil, errors.New("TODO: implement")  // Never defer implementation
}

// ❌ Bad: Mock data in production
var mockUsers = []*User{{Name: "test"}}  // Test data in production code

// ❌ Bad: Stub function
func ProcessPayment(amount int) error {
    return nil  // No-op — will silently fail
}

// ✅ Good: Complete implementation
func GetUser(ctx context.Context, id string) (*User, error) {
    var user User
    if err := db.WithContext(ctx).First(&user, id).Error; err != nil {
        return nil, fmt.Errorf("get user %s: %w", id, err)
    }
    return &user, nil
}
```

**Rules:**
- No "TODO", "FIXME", or placeholder comments — either implement now or create a tracked issue
- No mock data, stub functions, or placeholder implementations in production code
- All functions must have complete, working implementations
- Test mocks are only allowed in test files (`_test.go`)
- Every feature must be fully implemented with proper error handling — no "quick fixes"

**Why**: Incomplete code accumulates technical debt and causes production incidents. If you ship it broken, you'll fix it under pressure later — at higher cost.

## 11. Pre-Commit: Format + Lint + Vet [@CoT-required]

Before every commit, run:

```bash
gofmt -w .
goimports -w .
go vet ./...
golangci-lint run ./...
```

## 12. Comments

### Core Principles

> **[@CoT-required]**: When reviewing comments, execute Review Process Step 1-3 before giving conclusions.

- Comments are a remedy, not a default
- Code should express intent; comments explain **why**, not **what**
- Keep comments updated with code changes
- No outdated or misleading comments

### Good Comments

```go
// ✅ Good: Explain intent (Why)
// Use binary search because data is sorted by time
func FindRecentEvent(events []Event, threshold time.Time) *Event {
    // ...
}

// ✅ Good: Warning
// Note: This function is not thread-safe, must lock before calling
func UpdateCache(key string, value interface{}) { ... }

// ✅ Good: TODO with tracking
// TODO(user123): Optimize performance, consider using cache
func GetPopularProducts() []Product { ... }
```

### Bad Comments

```go
// ❌ Bad: Redundant
// Constructor
func NewUser() *User { ... }

// ❌ Bad: Commented out code
// func oldProcess() {
//     ...
// }

// ❌ Bad: Log-style (use Git instead)
// 2023-03-16: Fixed null pointer issue
func Process() { ... }
```

### Function Documentation

Public functions must have documentation comments:

```go
// CreateUser creates a new user and saves to database.
// name cannot be empty, email must be valid format.
// Returns created user object or error.
func CreateUser(name, email string) (*User, error) { ... }
```
