# Level 3: Advanced — Complex Architecture Rules

> **When to read**: Complex architecture design, DDD implementation, concurrent systems
> **Extends**: Level 1 + Level 2 rules
> **Scope**: DDD Architecture, Goroutine & Concurrency, Function Design, Refactoring

---

## 1. DDD Architecture

### 1.1 Layered Structure

> **[@CoT-required]**: When reviewing DDD architecture, execute LLM-Review-Process Step 1-3 before giving conclusions.

Strictly follow Domain-Driven Design layering:

```
├── domain/           # Entities, Value Objects, Domain Events
│   └── user.go
├── service/          # Application Services, Use Cases
│   └── user_service.go
├── handler/          # Infrastructure: HTTP, gRPC, etc.
│   └── user_handler.go
└── repository/       # Infrastructure: Database, External APIs
    └── user_repository.go
```

### 1.2 Dependency Direction

- Outer layers depend on inner layers
- Inner layers do NOT depend on outer layers
- Domain layer has no external dependencies

### 1.3 Domain Model

Business logic concentrated in the domain layer:

```go
// ✅ Good: Domain entity with business logic
type Order struct {
    ID          string
    CustomerID  string
    Items       []OrderItem
    Status      OrderStatus
    TotalAmount Money
}

func (o *Order) CalculateTotal() Money {
    var total Money
    for _, item := range o.Items {
        total = total.Add(item.Subtotal())
    }
    if o.Discount > 0 {
        total = total.ApplyDiscount(o.Discount)
    }
    return total
}

func (o *Order) CanCancel() bool {
    return o.Status == StatusPending || o.Status == StatusConfirmed
}
```

### 1.4 Infrastructure Abstraction

External dependencies abstracted through interfaces:

```go
// ✅ Good: Interface in domain/service layer
type UserRepository interface {
    FindByID(ctx context.Context, id string) (*User, error)
    Save(ctx context.Context, user *User) error
    Delete(ctx context.Context, id string) error
}

// Infrastructure implements the interface
type PostgresUserRepository struct {
    db *gorm.DB
}

func (r *PostgresUserRepository) FindByID(ctx context.Context, id string) (*User, error) {
    // Implementation
}
```

---

## 2. Goroutine & Concurrency Safety

### 2.1 Goroutine Safety Rules

> **[@CoT-required]**: When reviewing goroutine and concurrency safety, execute LLM-Review-Process Step 1-3 before giving conclusions.

**PROHIBITED**: Never use `go` keyword directly.

**REQUIRED**: Always use `goroutine.SafeGo` or `goroutine.SafeGoWithContext`.

```go
// ❌ Bad
go func() {
    if err := process(); err != nil {
        log.Error(err)
    }
}()

// ✅ Good: Panic recovery + context propagation built-in
goroutine.SafeGo(ctx, func() {
    if err := process(); err != nil {
        logger.ErrorW("process_failed", "err", err)
    }
})
```

### 2.2 Prefer Channels Over Shared Memory

```go
// ❌ Bad: Shared memory + mutex
var counter int
var mu sync.Mutex

func Increment() {
    mu.Lock()
    counter++
    mu.Unlock()
}

// ✅ Good: Channel-based
func Counter(done <-chan struct{}) <-chan int {
    ch := make(chan int)
    go func() {
        defer close(ch)
        counter := 0
        for {
            select {
            case ch <- counter:
                counter++
            case <-done:
                return
            }
        }
    }()
    return ch
}
```

### 2.3 Avoid Goroutine Leaks

```go
// ❌ Bad: Potential leak
func Process(ch chan int) {
    go func() {
        for {
            val := <-ch
            processValue(val)
        }
    }()
}

// ✅ Good: Exit mechanism
func Process(ctx context.Context, ch chan int) {
    goroutine.SafeGo(ctx, func() {
        for {
            select {
            case val, ok := <-ch:
                if !ok {
                    return
                }
                processValue(val)
            case <-ctx.Done():
                return
            }
        }
    })
}
```

### 2.4 Concurrency Patterns

```go
// ✅ Fan-out: Process multiple items concurrently
func ProcessAll(ctx context.Context, items []Item) error {
    errCh := make(chan error, len(items))
    var wg sync.WaitGroup

    for _, item := range items {
        wg.Add(1)
        goroutine.SafeGo(ctx, func() {
            defer wg.Done()
            if err := processItem(item); err != nil {
                errCh <- err
            }
        })
    }

    wg.Wait()
    close(errCh)

    for err := range errCh {
        if err != nil {
            return err
        }
    }
    return nil
}

// ✅ Pipeline: Chain of processing stages
func Pipeline(ctx context.Context, input <-chan int) <-chan string {
    stage1 := Stage1(ctx, input)
    stage2 := Stage2(ctx, stage1)
    return stage3(ctx, stage2)
}
```

---

## 3. Function Design

### 3.1 Control Complexity

> **[@CoT-required]**: When reviewing function design, execute LLM-Review-Process Step 1-3 before giving conclusions.

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

### 3.2 Single Responsibility

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

### 3.3 Minimize Parameters

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

### 3.4 Avoid Side Effects

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

### 3.5 Separate Commands from Queries

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

---

## 4. Refactoring

### 4.1 Feature Preservation

> **[@CoT-required]**: When reviewing refactoring, execute LLM-Review-Process Step 1-3 before giving conclusions.

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

### 4.2 Extract Function

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

### 4.3 Use Value Objects

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

### 4.4 Incremental Changes

Large refactorings → small, verifiable steps:

1. Make the change in the smallest possible scope
2. Run tests after each small change
3. Commit after each verifiable step
4. If something breaks, you know exactly what caused it

### 4.5 Rollback Plan

Before refactoring:
- Ensure clean git state or branch
- Know how to revert
- Consider feature flags for gradual rollout

---

## 5. Code Smells

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

---

## 6. Performance Optimization

### 6.1 Avoid Unnecessary Allocations

```go
// ❌ Bad: Frequent allocation
func Concatenate(parts []string) string {
    var result string
    for _, part := range parts {
        result += part  // Allocates new memory each time
    }
    return result
}

// ✅ Good: strings.Builder
func Concatenate(parts []string) string {
    var builder strings.Builder
    for _, part := range parts {
        builder.WriteString(part)
    }
    return builder.String()
}
```

### 6.2 sync.Pool for Object Reuse

```go
var bufferPool = sync.Pool{
    New: func() interface{} {
        return new(bytes.Buffer)
    },
}

func ProcessData(data []byte) string {
    buf := bufferPool.Get().(*bytes.Buffer)
    defer func() {
        buf.Reset()
        bufferPool.Put(buf)
    }()
    buf.Write(data)
    return buf.String()
}
```

---

## 7. Code Organization

### 7.1 File Organization

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
