# Code Quality Guidelines — LLM Reference

> "Clarity is better than cleverness. Write programs as if the most important communication was to the developer who will maintain your code in two years."
> — The Art of Unix Programming

This is a **practical reference** for writing high-quality Go code. Each rule provides:
- **What to do** (the rule)
- **Why it matters** (rationale)
- **Correct example** (complete and executable)
- **Incorrect example** (concise)

---

## 1. Naming — Names Reveal Intent

### Rule 1.1: Use Intent-Revealing Names

Names should answer: Why it exists, what it does, how it's used.

```go
// ❌ Bad: Names reveal nothing
var d int
var data map[string]interface{}
func getUser() { ... }
const max = 100

// ✅ Good: Self-documenting
var elapsedTimeInSeconds int
var userProfiles map[string]*User
func GetUserByID(userID string) (*User, error)
const MaxConnectionsPerHost = 100
```

### Rule 1.2: Avoid Disinformation

Names must mean exactly what they say.

```go
// ❌ Bad: Lies about type/behavior
var userList map[string]*User    // It's a map, not a list
var accountData *Account          // "Data" is meaningless
func GetUsers() *User             // Returns ONE user

// ✅ Good: Accurate
var userMap map[string]*User
var account *Account
func GetUserByID(id string) (*User, error)
```

### Rule 1.3: Use Pronounceable Names

You'll say this in meetings. Make it pronounceable.

```go
// ❌ Bad: Unpronounceable
type DtaRcrd102 struct {
    Genymdhms time.Time  // Generation Year Month Day Hour Minute Second
}

// ✅ Good: Pronounceable
type TransactionRecord struct {
    CreatedAt   time.Time
    ModifiedAt  time.Time
    MerchantID  string
}
```

### Rule 1.4: Go/golangci-lint Abbreviation Convention

Keep ID, URL, HTTP uppercase in camelCase.

```go
// ✅ Correct
userID string      // ✓
sessionID string    // ✓
apiKey string       // ✓
httpRequest *http.Request    // ✓

// ❌ Incorrect
userId string      // ✗ lowercase id
ApiKey string      // ✗ exported but wrong casing
```

### Rule 1.5: Avoid Noise Words

Don't add `Info`, `Data`, `Helper`, `Manager` when they add no meaning.

```go
// ❌ Bad: Noise words
var userInfo *UserInfo
var accountData *AccountData
func UserHelper() { ... }

// ✅ Good: Meaningful
var user *User
var account *Account
func ValidateUser(user *User) error
```

---

## 2. Functions — Small and Focused

### Rule 2.1: Keep Functions Small

Aim for <20 lines. Functions doing one thing are easier to test and maintain.

**Cyclomatic complexity must be ≤15** (measured by `gocyclo -over 15`).

### Rule 2.2: Do One Thing

Functions should do one sequential step at one level of abstraction.

```go
// ❌ Bad: Multiple things, mixed abstraction
func ProcessOrder(order *Order) error {
    // Validation (mixed with calculation)
    if order.UserID == "" { return errors.New("user ID required") }
    var total float64
    for _, item := range order.Items { total += item.Price * float64(item.Quantity) }
    // Persistence (buried inside)
    if err := db.Save(order).Error; err != nil { return err }
    return nil
}

// ✅ Good: One thing each, clear sequence
func ProcessOrder(order *Order) error {
    if err := validateOrder(order); err != nil {
        return fmt.Errorf("validate: %w", err)
    }
    order.Total = calculateTotal(order.Items)
    return persistOrder(order)
}

func validateOrder(order *Order) error {
    if order.UserID == "" { return errors.New("user ID required") }
    if len(order.Items) == 0 { return errors.New("order has no items") }
    return nil
}
```

### Rule 2.3: Minimize Arguments

**Ideal**: 0-2 arguments
**Acceptable**: 3 (with justification)
**Suspicious**: 4+ (use struct)

```go
// ❌ Bad: Too many arguments
func SendEmail(to, cc, bcc, subject, body, host, port, user, pass string) error

// ✅ Good: Group related arguments
type Email struct {
    To, CC, BCC, Subject, Body string
}
type SMTP struct {
    Host, Username, Password string
    Port int
}
func SendEmail(msg *Email, cfg *SMTP) error
```

### Rule 2.4: No Side Effects

Functions should not hide modifications to external state.

```go
// ❌ Bad: Hidden side effect
var requestCount int
func HandleRequest(req *Request) {
    requestCount++  // Hidden mutation
    // ...
}

// ✅ Good: State owned by the type
type Handler struct { requestCount int }
func (h *Handler) HandleRequest(req *Request) {
    h.requestCount++
    // ...
}
```

### Rule 2.5: Separate Commands from Queries

Functions should either DO something or ASK something, not both.

```go
// ❌ Bad: Command + query
func SetAndReturnAge(user *User, age int) (int, error) {
    if age < 0 || age > 150 { return 0, errors.New("invalid age") }
    user.Age = age
    return user.Age, nil  // Modifies AND returns
}

// ✅ Good: Separated
func ValidateAge(age int) error { ... }
func SetUserAge(user *User, age int) { user.Age = age }
```

### Rule 2.6: Stepdown Rule

Organize functions top-down: high-level first, details below.

```go
// ✅ Good: Top-down
func OnboardCustomer(ctx context.Context, req *OnboardRequest) (*Customer, error) {
    if err := validateRequest(req); err != nil {
        return nil, fmt.Errorf("validation: %w", err)
    }
    customer := createCustomer(req)
    if err := setupAccounts(ctx, customer); err != nil {
        return nil, fmt.Errorf("setup accounts: %w", err)
    }
    publishCustomerCreatedEvent(customer)
    return customer, nil
}

// Supporting functions follow, all at one level below the caller
func validateRequest(req *OnboardRequest) error { ... }
func createCustomer(req *OnboardRequest) *Customer { ... }
```

---

## 3. Error Handling — Fail Fast and Clearly

### Rule 3.1: Return Errors, Never Panic

Go uses error returns. Respect this design. Never use `panic` for expected conditions.

```go
// ❌ Bad: Panic for expected condition
func GetUser(id string) *User {
    user := findUser(id)
    if user == nil { panic("user not found") }
    return user
}

// ✅ Good: Explicit error
func GetUser(id string) (*User, error) {
    user := findUser(id)
    if user == nil { return nil, ErrUserNotFound }
    return user, nil
}
```

### Rule 3.2: Fail Fast — Validate Early

Catch problems at the boundary, before corruption spreads.

```go
// ❌ Bad: Validate after using data
func Process(order *Order) {
    calculateTotals(order)      // Uses invalid data
    validateOrder(order)       // Too late!
    persistOrder(order)        // Persisted invalid state!
}

// ✅ Good: Validate first, fail fast
func Process(order *Order) error {
    if err := validateOrder(order); err != nil {
        return fmt.Errorf("validate: %w", err)  // Fail immediately
    }
    calculateTotals(order)
    return persistOrder(order)
}
```

### Rule 3.3: Return Zero Values on Error

When returning multiple values with error, non-error values must be zero when error is not nil.

```go
// ✅ Good: Zero values on error
func GetUser(id string) (*User, error) {
    user := findUser(id)
    if err != nil { return nil, err }
    return user, nil
}

// ✅ Good: All non-error returns are zero values
func GetUserInfo(id string) (name string, age int, err error) {
    user := findUser(id)
    if err != nil { return "", 0, err }
    return user.Name, user.Age, nil
}
```

### Rule 3.4: Use errors.Is and errors.As

Never use `==` for error comparison. Never use direct type assertion.

```go
// ❌ Bad: == comparison fails with wrapped errors
if err == ErrUserNotFound { ... }

// ✅ Good: errors.Is traverses wrapped errors
if errors.Is(err, ErrUserNotFound) { ... }

// ❌ Bad: Type assertion fails with wrapped errors
if e, ok := err.(ValidationError); ok { ... }

// ✅ Good: errors.As traverses wrapped errors
var validationErr ValidationError
if errors.As(err, &validationErr) { ... }
```

### Rule 3.5: Wrap Errors with Context

Return errors that explain where they originated and what was being done.

```go
// ❌ Bad: Lost context
func Process(order *Order) error {
    if err := db.Create(order).Error; err != nil {
        return err  // What operation? What order?
    }
    return nil
}

// ✅ Good: Wrapped with context
func Process(ctx context.Context, order *Order) error {
    if err := db.Create(order).WithContext(ctx).Error; err != nil {
        return fmt.Errorf("create order %s: %w", order.ID, err)
    }
    return nil
}
```

---

## 4. Comments — Explain Why, Not What

### Rule 4.1: Comments Are Not Code

Code shows **what**. Comments explain **why** when non-obvious.

```go
// ❌ Bad: Restating the code
// Increment counter by 1
counter++

// Returns the user name
func (u *User) GetName() string { return u.Name }

// ❌ Bad: Commented-out code (use git history!)
// func oldProcess() { ... }

// ✅ Good: Explains non-obvious WHY
// Use binary search because slice is sorted by timestamp.
// Linear search is O(n); binary search is O(log n).
func FindEventByTimestamp(events []Event, target time.Time) *Event { ... }

// ✅ Good: TODO with issue reference
// TODO(zheng): Consider caching after profiling.
// See: github.com/org/project/issues/1234
func GetExpensiveData() Data { ... }
```

### Rule 4.2: Update or Remove Outdated Comments

When modifying code, update related comments immediately. Remove obsolete ones.

### Rule 4.3: Document Public APIs

Export functions should have doc comments explaining purpose, parameters, return values, and notable behaviors.

```go
// ✅ Good: Complete documentation
// CreateUser creates a new user with the provided details.
// Email must be unique; returns ErrEmailExists if duplicate.
// User is inactive until ActivateUser is called.
func CreateUser(ctx context.Context, req *CreateUserRequest) (*User, error)
```

---

## 5. Formatting — Consistency via Tools

### Rule 5.1: Use gofmt — Non-Negotiable

```bash
gofmt -w .
goimports -w .
```

Never fight the formatter. These tools enforce team consistency.

### Rule 5.2: Use go vet Before Commit

```bash
go vet ./...
golangci-lint run ./...
```

Compilation errors and lint errors must be fixed before commit.

### Rule 5.3: Line Length

Aim for lines under 100 characters. Break long boolean expressions.

```go
// ❌ Bad: Too long
if user != nil && user.IsActive && user.HasPermission("admin") && time.Now().Before(user.SessionExpiry) {

// ✅ Good: Extracted conditions
isActive := user != nil && user.IsActive
hasPermission := user.HasPermission("admin")
isSessionValid := time.Now().Before(user.SessionExpiry)
if isActive && hasPermission && isSessionValid {
```

---

## 6. Architecture — SOLID, DDD, and Orthogonality

### Rule 6.1: SRP — Single Responsibility

A type should have only one reason to change.

```go
// ❌ Bad: Multiple reasons to change
type User struct {
    Name string
    SaveToDatabase() error    // Changes if DB changes
    SendEmail() error         // Changes if email changes
    CalculateDiscount() float64 // Changes if pricing changes
}

// ✅ Good: One reason to change each
type User struct { Name string }           // User data
type UserRepository interface { Save(ctx context.Context, user *User) error }
type EmailService interface { Send(ctx context.Context, to, subject string) error }
type DiscountCalculator interface { Calculate(user *User) float64 }
```

### Rule 6.2: OCP — Open for Extension, Closed for Modification

Add new behavior by adding new types, not by modifying existing code.

```go
// ❌ Bad: Adding type requires modifying existing function
func CalculateDiscount(order *Order) float64 {
    if order.Type == "premium" { return order.Total * 0.2 }
    if order.Type == "standard" { return order.Total * 0.1 }
    return 0  // Adding "enterprise" requires modifying this
}

// ✅ Good: Add new type, existing code unchanged
type DiscountStrategy interface { Calculate(order *Order) float64 }
type PremiumDiscount struct{}
func (PremiumDiscount) Calculate(order *Order) float64 { return order.Total * 0.2 }
type StandardDiscount struct{}
func (StandardDiscount) Calculate(order *Order) float64 { return order.Total * 0.1 }
```

### Rule 6.3: LSP — Subtypes Must Be Substitutable

Subtypes must honor their contract. A Square should not inherit from Rectangle if their behaviors differ.

### Rule 6.4: ISP — Prefer Small Interfaces

Clients should not depend on methods they don't use.

```go
// ❌ Bad: Fat interface
type UserService interface {
    CreateUser(user *User) error
    DeleteUser(id string) error
    GetUserByID(id string) (*User, error)
    GetUserByEmail(email string) (*User, error)
    UpdatePassword(id, newPass string) error
    UpdateEmail(id, newEmail string) error
    SendWelcomeEmail(user *User) error  // Implementers that don't email suffer
}

// ✅ Good: Segregated interfaces
type UserCreator interface { CreateUser(user *User) error }
type UserGetter interface { GetUserByID(id string) (*User, error) }
type UserUpdater interface {
    UpdatePassword(id, newPass string) error
    UpdateEmail(id, newEmail string) error
}
```

### Rule 6.5: DIP — Depend on Abstractions

High-level modules should not depend on low-level details.

```go
// ❌ Bad: Concrete dependency
type UserService struct { db *gorm.DB }

// ✅ Good: Depend on interface
type UserService struct { repo UserRepository }
type UserRepository interface {
    FindByID(ctx context.Context, id UserID) (*User, error)
    Save(ctx context.Context, user *User) error
}
```

### Rule 6.6: Orthogonality — Change One Thing, Affect One Place

Design so that changes in A don't require changes in B.

```go
// ❌ Bad: Coupling
type Order struct {
    items []Item
    total float64  // Derived: changes when calculation changes
}
func (o *Order) AddItem(item Item) {
    o.items = append(o.items, item)
    o.total += item.Price  // Order must change if calculation changes
}

// ✅ Good: Orthogonal
type Order struct { items []Item }
type OrderCalculator struct{}
func (c OrderCalculator) Calculate(order *Order) float64 {
    var total float64
    for _, item := range order.Items {
        total += item.Price * float64(item.Quantity)
    }
    return total
}
```

### Rule 6.7: Tell, Don't Ask

Don't query state then decide. Tell objects what to do.

```go
// ❌ Bad: Tell, Don't Ask violation
func ProcessUser(user *User) {
    if user.IsActive && user.HasPermission("admin") {
        grantFullAccess()
    } else {
        grantLimitedAccess()
    }
}

// ✅ Good: Object encapsulates the logic
func ProcessUser(user *User) error {
    return user.GrantAccess()  // User knows its own rules
}
```

### Rule 6.8: Law of Demeter — Only Talk to Immediate Friends

Avoid `a.GetB().GetC().GetD()` chains.

```go
// ❌ Bad: Law of Demeter violation
city := order.GetUser().GetAccount().GetProfile().GetAddress().GetCity()

// ✅ Good: Ask friend directly
city := order.GetCity()  // Order encapsulates the traversal
```

---

## 7. DDD Patterns — Aggregates, Repositories, Events

### Rule 7.1: Aggregates — Transaction Boundaries

Cluster related entities under one root. External code accesses only the root.

```go
// ❌ Bad: No aggregate boundary
type Order struct {
    ID   string
    Items []LineItem
}
item := order.Items[0]
item.Quantity = 9999  // Order never knows!

// ✅ Good: Aggregate root enforces invariants
type Order struct {
    id     string
    items  []LineItem
}
func (o *Order) AddItem(product ProductID, qty int) error {
    if qty <= 0 { return errors.New("quantity must be positive") }
    if len(o.items) >= 100 { return errors.New("max 100 items") }
    o.items = append(o.items, newLineItem(product, qty))
    return nil
}
```

### Rule 7.2: Value Objects — Immutable and Self-Validating

Value objects have no identity; they're defined by their attributes.

```go
// ❌ Bad: Mutable
type Price struct { Amount float64 }
func (p *Price) SetAmount(a float64) { p.Amount = a }  // Breaks value semantics

// ✅ Good: Immutable with constructor
type Price struct { amount float64; currency string }
func NewPrice(amount float64, currency string) (Price, error) {
    if amount < 0 { return Price{}, errors.New("price cannot be negative") }
    if currency == "" { return Price{}, errors.New("currency required") }
    return Price{amount: amount, currency: currency}, nil
}
func (p Price) Amount() float64 { return p.amount }
func (p Price) Currency() string { return p.currency }
```

### Rule 7.3: Repositories — Hide Persistence Details

Repository returns domain objects, not database details.

```go
// ❌ Bad: Leaking GORM details
func (r *UserRepository) Find(id string) *gorm.DB {
    return r.db.Where("id = ?", id)
}

// ✅ Good: Returns domain object
type UserRepository interface {
    FindByID(ctx context.Context, id UserID) (*User, error)
}
```

### Rule 7.4: Domain Events — Explicit State Changes

Publish events for significant occurrences. Decouple producers from consumers.

```go
// ✅ Good: Explicit event
type OrderPlaced struct {
    OrderID    OrderID
    CustomerID CustomerID
    Total      Price
    OccurredAt time.Time
}

func (s *OrderService) Place(order *Order) error {
    if err := s.repo.Save(ctx, order); err != nil {
        return err
    }
    s.eventBus.Publish(OrderPlaced{OrderID: order.ID(), OccurredAt: time.Now()})
    return nil
}
```

### Rule 7.5: Anti-Corruption Layer — Translate External Models

Don't let foreign concepts leak into your domain.

```go
// ❌ Bad: External concepts in domain
type User struct {
    ID string
    StripeCustomerID string    // External!
    SalesforceID string         // External!
}

// ✅ Good: Anti-corruption layer
type User struct { ID UserID; Email Email; Name string }  // Pure domain

type StripeAdapter struct{}
func (a *StripeAdapter) ToDomain(stripeCustomer *StripeCustomer) *User {
    return &User{Email: NewEmail(stripeCustomer.Email), Name: stripeCustomer.Name}
}
```

---

## 8. Refactoring — Small Steps, Verified Behavior

### Rule 8.1: Feature Inventory Before Refactoring

Before touching code, document every feature. After refactoring, verify each still works.

### Rule 8.2: Tests Before Refactoring

Without tests, you cannot verify behavior hasn't changed.

### Rule 8.3: Small Steps

Make tiny changes. Run tests after each. Each step should compile.

```go
// Example: Extract condition variable (one step at a time)

// BEFORE:
if order.Customer.IsPremium && order.Total > 1000 ||
   order.Customer.IsNew && order.Total > 500 {
    applyDiscount(order, 0.1)
}

// STEP 1: Extract first condition
isPremiumLarge := order.Customer.IsPremium && order.Total > 1000
if isPremiumLarge ||
   order.Customer.IsNew && order.Total > 500 {
    applyDiscount(order, 0.1)
}

// STEP 2: Extract second condition
isNewMedium := order.Customer.IsNew && order.Total > 500
if isPremiumLarge || isNewMedium {
    applyDiscount(order, 0.1)
}

// STEP 3: Final extraction
eligible := isPremiumLarge || isNewMedium
if eligible { applyDiscount(order, 0.1) }
```

### Rule 8.4: Common Refactoring Patterns

| Pattern | When |
|---------|------|
| Extract Method | Function > 20 lines or multiple abstraction levels |
| Rename Method | Name doesn't reveal intent |
| Introduce Parameter Object | Parameter list > 5 with related data |
| Replace Conditional with Polymorphism | Type-checking switch that will grow |
| Move Method | Method uses more of another class |
| Replace Magic Literal | Any magic number/string not a constant |

---

## 9. Go-Specific Patterns

### Rule 9.1: Context Propagation

Pass context as first parameter. Never use `context.Background()` in request handlers.

```go
// ❌ Bad: No context or wrong context
func GetUser(id string) (*User, error) {
    return db.Find(id)  // No context
}

// ✅ Good: Context propagation
func GetUser(ctx context.Context, id string) (*User, error) {
    return db.WithContext(ctx).Find(id)
}

// In HTTP handler:
func (h *Handler) HandleGetUser(w http.ResponseWriter, r *http.Request) {
    user, err := h.service.GetUser(r.Context(), r.URL.Query().Get("id"))
    // ...
}
```

### Rule 9.2: defer for Cleanup

Use defer for cleanup that must run regardless of success/failure.

```go
// ✅ Good: Deferred cleanup
func processFile(path string) error {
    f, err := os.Open(path)
    if err != nil { return err }
    defer f.Close()  // Runs regardless of return path

    // Process file
    return nil
}
```

### Rule 9.3: Never Use goroutine Directly — Use SafeGo

Never use `go` keyword directly. Use `goroutine.SafeGo` or `goroutine.SafeGoWithContext`.

```go
// ❌ Bad: Direct goroutine
go func() {
    doWork()
}()

// ✅ Good: SafeGo
goroutine.SafeGo(func() {
    doWork()
})
```

### Rule 9.4: Never Delete Map Elements During Iteration

Deleting elements from a map while iterating over it causes undefined behavior. The iteration may skip elements, or the program may panic.

```go
// ❌ Bad: Undefined behavior — may skip elements or panic
for key, val := range m {
    if shouldDelete(val) {
        delete(m, key)  // Modifies map during iteration!
    }
}

// ✅ Good: Collect keys first, delete after iteration
var keysToDelete []K
for key, val := range m {
    if shouldDelete(val) {
        keysToDelete = append(keysToDelete, key)
    }
}
for _, key := range keysToDelete {
    delete(m, key)
}
```

**Why this matters**: Go's map implementation does not guarantee iteration order, and modifying a map during iteration can cause skipped elements or runtime panics ("fatal error: concurrent map iteration and map write").

### Rule 9.5: Avoid Goroutine Leaks

Always provide exit mechanism for goroutines.

```go
// ❌ Bad: Goroutine leak
func Process(ch chan int) {
    go func() {
        for {
            val := <-ch  // Blocks forever if ch closes
            processValue(val)
        }
    }()
}

// ✅ Good: Exit mechanism
func Process(ctx context.Context, ch chan int) {
    go func() {
        for {
            select {
            case val, ok := <-ch:
                if !ok { return }
                processValue(val)
            case <-ctx.Done():
                return
            }
        }
    }()
}
```

### Rule 9.6: Keep Context Small — Only What Handlers Need

Don't pass large structs in context. Pass IDs and look up as needed.

```go
// ❌ Bad: Large object in context
ctx = context.WithValue(ctx, "user", largeUserObject)

// ✅ Good: Pass ID, look up in handler
ctx = context.WithValue(ctx, UserIDKey, userID)

// In handler:
userID := ctx.Value(UserIDKey).(UserID)
user, err := h.userService.GetUser(ctx, userID)
```


Don't pass large structs in context. Pass IDs and look up as needed.

```go
// ❌ Bad: Large object in context
ctx = context.WithValue(ctx, "user", largeUserObject)

// ✅ Good: Pass ID, look up in handler
ctx = context.WithValue(ctx, UserIDKey, userID)

// In handler:
userID := ctx.Value(UserIDKey).(UserID)
user, err := h.userService.GetUser(ctx, userID)
```

---

## 10. Code Smells — When to Refactor

### Rule 10.1: Recognize Common Smells

| Smell | Description | Fix |
|-------|-------------|-----|
| **Mysterious Name** | Name doesn't reveal intent | Rename |
| **Duplicate Code** | Same logic in multiple places | Extract method |
| **Long Function** | > 20 lines, multiple things | Extract method |
| **Long Parameter List** | > 4 parameters | Introduce parameter object |
| **Shotgun Surgery** | One change requires many small changes | Move features together |
| **Feature Envy** | Method uses another class's data more than its own | Move method |
| **Data Clumps** | Same 3-4 items always together | Extract class |
| **Primitive Obsession** | Using primitives instead of types | Introduce value object |
| **Switch Statements** | Type-checking that will grow | Polymorphism |
| **Message Chains** | `a.GetB().GetC().GetD()` | Hide delegation |

### Rule 10.2: Don't Ship Known Smells

Address code smells before they compound.

---

## 11. Conflict Resolution — When Principles Clash

When rules conflict, use this priority:

| Conflict | Resolution |
|----------|------------|
| **Clarity vs Performance** | Prefer clarity. Optimize only after profiling. |
| **Small Functions vs Readability** | If a 30-line function is clearer than 5 extracted functions, keep it linear. |
| **DRY vs Orthogonality** | Orthogonality wins. Don't sacrifice isolation for DRY. |
| **Early Return vs Single Exit** | Early return wins. Guard clauses reduce nesting. |
| **Comments vs Self-Documenting** | If code needs comment to explain, refactor instead. |
| **Value Objects vs Performance** | Prefer value objects. Copying is rarely the bottleneck. |

---

## 12. Portability — Environment Independence

### Rule 12.1: Avoid OS-Specific Code

Don't assume a specific operating system or environment.

```go
// ❌ Bad: OS-specific assumptions
func GetConfigDir() string {
    if runtime.GOOS == "windows" {
        return os.Getenv("APPDATA")
    }
    return "/etc/myapp"  // Linux assumption
}

// ✅ Good: Use standard library abstractions
func GetConfigDir() string {
    if dir, err := os.UserConfigDir(); err == nil {
        return dir
    }
    return "/etc/myapp"  // Fallback, not assumption
}
```

### Rule 12.2: Use Text-Based Configuration

Human-readable configuration files over binary formats.

```go
// ✅ Good: Text-based (JSON, YAML, TOML, env)
type Config struct {
    DatabaseURL string `json:"database_url"`
    RedisAddr   string `json:"redis_addr"`
}

// Load from file or environment
```

---

## 13. Quick Reference

### Command Reference

```bash
# Format
gofmt -w .
goimports -w .

# Lint
go vet ./...
golangci-lint run ./...

# Test
go test ./...

# Complexity check
gocyclo -over 15 .
```

### Naming Quick Reference

| Type | Convention | Example |
|------|------------|---------|
| Variable | camelCase | `userID`, `totalAmount` |
| Constant | PascalCase | `MaxRetries`, `DefaultTimeout` |
| Function | camelCase, verb prefix | `GetUser`, `ValidateEmail` |
| Interface | verb + -er | `Reader`, `Writer`, `UserRepository` |
| Package | lowercase, short | `user`, `order`, `pricing` |
| Error | `Err` prefix | `ErrUserNotFound`, `ErrInvalidInput` |

### SOLID Quick Reference

| Principle | Summary |
|-----------|---------|
| **S**ingle Responsibility | One reason to change |
| **O**pen/Closed | Extend via new types, not modification |
| **L**iskov Substitution | Subtypes substitutable for base types |
| **I**nterface Segregation | Small, focused interfaces |
| **D**ependency Inversion | Depend on abstractions |

---

## References

- Martin, R. C. (2008). *Clean Code*. Prentice Hall.
- Hunt, A., & Thomas, D. (1999). *The Pragmatic Programmer*. Addison-Wesley.
- Fowler, M. (2018). *Refactoring* (2nd ed.). Addison-Wesley.
- Evans, E. (2003). *Domain-Driven Design*. Addison-Wesley.
- Raymond, E. S. (2003). *The Art of Unix Programming*. Addison-Wesley.
