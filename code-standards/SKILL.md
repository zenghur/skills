---
name: code-standards
description: This skill provides comprehensive coding standards for Go backend and Vue 3 + TypeScript frontend projects. Use this skill when writing, reviewing, or refactoring code to ensure consistency, maintainability, and adherence to best practices. The skill emphasizes separation of concerns where backend handles all business logic and calculations, while frontend focuses solely on presentation.
---

# Code Standards

## Overview

This skill provides comprehensive coding standards for Go backend and Vue 3 + TypeScript frontend development. These standards ensure consistency, maintainability, and adherence to best practices.

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

## Core Principles

### Separation of Concerns
- **Backend**: Handles ALL business logic, calculations, and data aggregation
- **Frontend**: ONLY handles presentation, receives pre-calculated data from backend
- **No Business Logic in Frontend**: Frontend should never perform complex calculations
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

## Backend Standards (Go)

### 1. Naming and Formatting

#### 1.1 Basic Naming Rules
- **Internal interface data**: Use camelCase naming
- **External system integration**: When consuming external APIs (REST, gRPC, etc.), use field names as-is from the external system. **Do not transform** external field names to match internal conventions. Only our own APIs are guaranteed to follow camelCase.
- **Comments**: Use English, follow Google conventions
- **Package names**: Use lowercase letters, avoid underscores
- **Function names**: Use camelCase, start with a verb

#### 1.2 Meaningful Names

Names should clearly express intent, purpose, and usage.

```go
// ❌ Bad: Vague, meaningless
var d int
const max = 100
x := getUser()

// ✅ Good: Clear, descriptive
var duration int
const MaxConnections = 100
activeUser := getUser()
```

#### 1.3 Function Naming

```go
// ❌ Bad: Unclear purpose
func get(u *User) error { ... }
func processData(d Data) { ... }

// ✅ Good: Verb prefix, clearly expresses behavior
func GetUserByID(userID string) (*User, error) { ... }
func ValidateUserPermissions(user *User) error { ... }
```

#### 1.4 Interface Naming

Use verb + -er suffix convention:

```go
// ❌ Bad
type I interface { ... }
type UserInterface interface { ... }

// ✅ Good: Verb + er suffix
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Writer interface {
    Write(p []byte) (n int, err error)
}

type UserRepository interface {
    FindByID(id string) (*User, error)
    Save(user *User) error
}
```

#### 1.5 Avoid Misleading Names

```go
// ❌ Bad: Misleading naming
var userList map[string]*User  // Actually a map, not a list
var accountData *Account        // "Data" is a meaningless suffix

// ✅ Good: Accurate description
var userMap map[string]*User
var account *Account
```

#### 1.6 Consistent Terminology

```go
// ❌ Bad: Mixed terminology
func fetchUser() { ... }
func getUserData() { ... }
func queryAccount() { ... }

// ✅ Good: Unified terminology
func GetUser() { ... }
func GetUserData() { ... }
func GetAccount() { ... }
```

### 2. Database Field Standards
- **gorm tag**: Must be explicit, every field must have `gorm:"column:field_name"`
- **Database field naming**: Use snake_case naming
- **gorm tag restrictions**: Only write column fields, do not use gorm's index, uniqueIndex features
- **DDL definition**: Create table definitions must explicitly write DDL, cannot use gorm's AutoMigrate feature
- **DDL principle**: What you see is what you get, table structure is clearly defined by DDL
- **DDL NOT NULL**: All DDL fields must have NOT NULL constraint, code must not check IS NULL/IS NOT NULL
- **Update with Model**: When updating database records, use struct model instead of map[string]interface{}
- **Type Safety**: Model-based updates provide compile-time type checking
- **Field Tracking**: Model updates only modify non-zero fields, avoiding accidental zero-value overwrites
- **IDE Support**: Struct fields enable autocomplete and refactoring
- **No Raw SQL for CRUD**: Use gorm model methods for INSERT/UPDATE/DELETE operations, avoid writing raw SQL
- **Model Methods**: Use `db.Create()`, `db.Save()`, `db.Updates()`, `db.Delete()` instead of raw SQL
- **Query Allowed**: Raw SQL is allowed for complex queries that gorm cannot express easily
- **DDL Exception**: Raw SQL is allowed for DDL operations (CREATE TABLE, ALTER TABLE, etc.)
- **Type Safety**: Model methods provide compile-time type checking and IDE support

### 3. Logging Standards
- **Global unified logger**: MUST use wrapped logger instance (e.g., `logger.G()`, `logger.L()`, etc.), NEVER use raw `fmt.Println`, `log.Println` or similar. Multiple logger instances are allowed, naming is flexible as long as semantically appropriate
- **Structured logging**: Use `InfoW`, `DebugW`, `WarnW`, `ErrorW` series functions or `Infow`, `Debugw`, `Warnw`, `Errorw` with key-value pairs
- **Key naming**: Log keys MUST use camelCase naming (e.g., `orderId`, `userId`, `apiKey`), NEVER use snake_case (e.g., `order_id`, `user_id`)
- **Language**: Use English for logs, clear and understandable
- **Security**: Do not print sensitive fields (token, access key, secret key, etc.)
- **Level**: Reasonably use Info, Warn, Error levels

### 4. Timestamp Handling
- **Database storage**: Unified use of int64 timestamps (UnixMilli)
- **Frontend-backend transmission**: Use int64 timestamps
- **Frontend display**: Frontend responsible for converting to local time, displaying year-month-day hour:minute:second

### 5. DDD Architecture Standards
- **Layered structure**: Strictly follow Domain-Driven Design layering
- **Dependency direction**: Outer layers depend on inner layers, inner layers do not depend on outer layers
- **Domain model**: Business logic concentrated in the domain layer
- **Infrastructure**: External dependencies abstracted through interfaces

### 6. Code Quality Standards

#### 6.1 Compilation and Linting
- **Compilation check**: Every modification must ensure code compiles successfully
- **Linter check**: Code style must pass revive lint check (https://github.com/mgechev/revive)
- **Fix priority**: Compilation errors and lint errors must be fixed first

#### 6.2 Eliminate Duplication
- **Avoid duplication**: Eliminate duplicate code, extract common logic into reusable functions or modules
- **DRY Principle**: Don't Repeat Yourself - abstract common functions

#### 6.3 Avoid Magic Values
- **No magic values**: Prohibit using magic numbers and magic strings, define them as meaningful constants

```go
// ❌ Bad: Magic numbers
if user.Status == 1 { ... }

// ✅ Good: Meaningful constants
const (
    StatusActive   = 1
    StatusInactive = 2
    StatusDeleted  = 3
)

if user.Status == StatusActive { ... }
```

#### 6.4 Prefer Struct Over Map
- **Prefer struct over map**: Use struct instead of map[string]interface{} when field types are known at compile time
- **Type Safety**: Structs provide compile-time type checking, map does not
- **Performance**: Struct access is faster than map lookup, no runtime hash computation needed
- **IDE Support**: Structs enable IDE autocomplete and refactoring tools
- **Documentation**: Struct fields are self-documenting with clear names and types

#### 6.5 Early Initialization
- **Early Initialization**: Initialize dependencies at startup, avoid redundant nil checks
- **No Defensive Nil Checks**: Only check for nil when the value can legitimately be nil (optional dependencies, failed initialization)
- **Trust Initialization**: If a dependency is initialized at startup, trust it exists throughout the lifecycle
- **Fail Fast**: If initialization fails, fail immediately rather than checking nil everywhere

### 7. Error Handling Standards

#### 7.1 Multiple Return Values Pattern
- **Multiple return values**: When a function returns multiple values including error, if error is not nil, other return values must be zero values
- **Success case**: When error is nil, other return values must be valid non-zero values
- **Consistency**: Always follow this pattern for all functions returning error

```go
// ✅ Good: Return zero values when error is not nil
func GetUser(id uint) (*User, error) {
    var user User
    if err := db.First(&user, id).Error; err != nil {
        return nil, err  // Return nil (zero value for pointer) when error
    }
    return &user, nil  // Return valid value when no error
}

// ✅ Good: Return zero values for all non-error returns
func GetUserInfo(id uint) (string, int, error) {
    var user User
    if err := db.First(&user, id).Error; err != nil {
        return "", 0, err  // Return "" and 0 (zero values) when error
    }
    return user.Name, user.Age, nil  // Return valid values when no error
}
```

#### 7.2 Use Errors Instead of Special Values

```go
// ❌ Bad: Return special value to indicate error
func FindUser(id string) *User {
    user := db.Find(id)
    if user == nil {
        return nil  // Cannot distinguish between not found and error
    }
    return user
}

// ✅ Good: Return error
func FindUser(id string) (*User, error) {
    user, err := db.Find(id)
    if err != nil {
        return nil, fmt.Errorf("find user: %w", err)
    }
    return user, nil
}
```

#### 7.3 Error Comparison and Wrapping
- **Error Comparison**: Use `errors.Is()` for error value comparison, NEVER use `==` for comparing errors
- **Error Type Assertion**: Use `errors.As()` for error type assertion, NEVER use type assertion directly
- **Error Wrapping**: Use `fmt.Errorf("context: %w", err)` to wrap errors with context
- **Unwrap Chain**: `errors.Is()` and `errors.As()` traverse the error chain automatically

```go
// ❌ Bad: Lose error context
func ProcessPayment(orderID string) error {
    order, err := GetOrder(orderID)
    if err != nil {
        return err  // Lost call stack info
    }
    // ...
}

// ✅ Good: Wrap error with context
func ProcessPayment(orderID string) error {
    order, err := GetOrder(orderID)
    if err != nil {
        return fmt.Errorf("get order %s: %w", orderID, err)
    }
    
    if err := chargeCustomer(order); err != nil {
        return fmt.Errorf("charge customer for order %s: %w", orderID, err)
    }
    return nil
}
```

#### 7.4 Custom Error Types

```go
// Define domain errors
type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation error: %s - %s", e.Field, e.Message)
}

// Usage
func ValidateUser(user *User) error {
    if user.Name == "" {
        return &ValidationError{
            Field:   "name",
            Message: "cannot be empty",
        }
    }
    return nil
}

// Check error type
err := ValidateUser(user)
var validationErr *ValidationError
if errors.As(err, &validationErr) {
    // Handle validation error
}
```

### 8. Business Logic Placement
- **All calculations**: Must be performed in the backend
- **Data aggregation**: Must be done in the backend before sending to frontend
- **Complex computations**: Must be handled by backend services
- **Frontend responsibility**: Only receive and display pre-calculated data

### 9. API Field Alignment (Backend Authority)

When frontend and backend API field definitions conflict or don't match:

- **Backend wins**: Backend field definitions are the authoritative source of truth
- **Frontend adapts**: Frontend must align its types/interfaces to match backend response
- **No negotiation**: Do not ask backend to change fields to accommodate frontend preferences
- **Explicit contracts**: Backend response shapes must be documented and stable

```go
// ✅ Backend defines the contract
type UserResponse struct {
    UserID      int64  `json:"userId"`
    DisplayName string `json:"displayName"`
    CreatedAt   int64  `json:"createdAt"`  // Backend decides field names and types
}

// Frontend MUST adapt to this contract
// ❌ Bad: Requesting backend change "userId" to "id" for frontend convenience
// ✅ Good: Frontend type aligns with backend response
type User {
    userId      int64
    displayName string
    createdAt   int64
}
```

### 9. Goroutine and Concurrency Safety Standards

#### 9.1 Goroutine Safety
- **PROHIBITED**: Never use the `go` keyword directly to start a goroutine
- **REQUIRED**: Always use `goroutine.SafeGo` or `goroutine.SafeGoWithContext` to start goroutines
- **Panic Recovery**: SafeGo provides automatic panic recovery with stack trace logging
- **Stack Trace**: Panic stack traces are limited to 65536 bytes (2^16) to prevent excessive log output
- **Context Propagation**: Use `SafeGoWithContext` when context propagation is needed

#### 9.2 Prefer Channels Over Shared Memory

```go
// ❌ Bad: Shared memory + mutex
var counter int
var mu sync.Mutex

func Increment() {
    mu.Lock()
    counter++
    mu.Unlock()
}

// ✅ Good: Use channel
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

#### 9.3 Avoid Goroutine Leaks

```go
// ❌ Bad: Potential goroutine leak
func Process(ch chan int) {
    go func() {
        for {
            val := <-ch  // If ch is closed and no receiver, goroutine blocks forever
            processValue(val)
        }
    }()
}

// ✅ Good: Provide exit mechanism
func Process(ctx context.Context, ch chan int) {
    go func() {
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
    }()
}
```

### 10. Comment Standards

#### 10.1 Core Principles
- **Comments are a remedy**: Prefer expressing intent through code itself
- **Consistency**: Comments must accurately describe what the code does, never contradict the actual implementation
- **Keep Updated**: When modifying code, always update related comments immediately
- **No Outdated Comments**: Remove or update comments that no longer reflect the current code behavior
- **No Misleading Comments**: Comments should not describe functionality that doesn't exist or has been removed
- **Self-Documenting Code**: Prefer clear naming over comments when possible
- **Comment Purpose**: Explain "why" not "what" - the code itself shows what it does

#### 10.2 Good Comments

```go
// ✅ Good: Explain intent (Why not How)
// Use binary search instead of linear search because data is sorted by time
func FindRecentEvent(events []Event, threshold time.Time) *Event {
    // ...
}

// ✅ Good: TODO comment
// TODO(hurzeng): Optimize performance, consider using cache
func GetPopularProducts() []Product {
    // ...
}

// ✅ Good: Warning information
// Note: This function is not thread-safe, must lock before calling
func UpdateCache(key string, value interface{}) {
    // ...
}

// ✅ Good: Go documentation comment (exported function)
// CreateUser creates a new user and saves to database.
// name cannot be empty, email must be valid format.
// Returns created user object or error.
func CreateUser(name, email string) (*User, error) {
    // ...
}
```

#### 10.3 Bad Comments to Avoid

```go
// ❌ Bad: Redundant comment
// Constructor
func NewUser() *User { ... }

// Returns username
func (u *User) GetName() string { return u.Name }

// ❌ Bad: Commented out code
// func oldProcess() {
//     ...
// }

// ❌ Bad: Log-style comments (should use Git)
// 2023-03-16: Fixed null pointer issue
// 2023-03-17: Optimized performance
func Process() { ... }
```

#### 10.4 Function Documentation
- **Function Comments**: Public functions must have documentation comments explaining purpose and usage
- **Complex Logic**: Add comments for complex algorithms or non-obvious business rules
- **TODO Management**: TODO comments must include issue tracker reference and be actively tracked

### 11. Test Synchronization Standards

#### 11.1 Test Synchronization
- **Sync with Code Changes**: When modifying code, corresponding test cases MUST be updated simultaneously
- **New Features**: New functionality requires new test cases before merge
- **Bug Fixes**: Bug fixes must include regression test cases
- **Refactoring**: Refactored code must update existing tests to match new structure
- **API Changes**: Interface changes require updating integration tests
- **No Orphaned Tests**: Remove tests for deleted code, update tests for modified code
- **Test Coverage**: Maintain or improve test coverage with each change
- **Test First**: For bug fixes, write failing test case first, then fix the code

#### 11.2 Test Naming Convention

Use table-driven tests:

```go
// ✅ Good: Table-driven test
func TestCreateUser(t *testing.T) {
    tests := []struct {
        name    string
        input   CreateUserRequest
        want    *User
        wantErr error
    }{
        {
            name: "valid user",
            input: CreateUserRequest{
                Name:  "Alice",
                Email: "alice@example.com",
            },
            want: &User{
                Name:  "Alice",
                Email: "alice@example.com",
            },
            wantErr: nil,
        },
        {
            name: "empty name",
            input: CreateUserRequest{
                Name:  "",
                Email: "bob@example.com",
            },
            want:    nil,
            wantErr: &ValidationError{Field: "name"},
        },
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := CreateUser(tt.input)
            
            if !errors.Is(err, tt.wantErr) {
                t.Errorf("CreateUser() error = %v, want %v", err, tt.wantErr)
            }
            if !reflect.DeepEqual(got, tt.want) {
                t.Errorf("CreateUser() = %v, want %v", got, tt.want)
            }
        })
    }
}
```

#### 11.3 Test Coverage

```bash
# Run tests and generate coverage report
go test -cover ./...

# Generate detailed coverage report
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out -o coverage.html
```

#### 11.4 Test Principles
- **Fast**: Tests should run quickly
- **Independent**: Tests should not depend on each other
- **Repeatable**: Tests should produce same result every time
- **Self-Validating**: Tests should clearly pass or fail

```go
// ✅ Good: Fast, independent, repeatable test
func TestCalculateDiscount(t *testing.T) {
    // Does not depend on external database or network
    tests := []struct {
        price    float64
        discount float64
        want     float64
    }{
        {100, 0.1, 90},
        {200, 0.2, 160},
        {50, 0, 50},
    }
    
    for _, tt := range tests {
        got := CalculateDiscount(tt.price, tt.discount)
        if got != tt.want {
            t.Errorf("CalculateDiscount(%.2f, %.2f) = %.2f, want %.2f",
                tt.price, tt.discount, got, tt.want)
        }
    }
}
```

#### 11.5 Test Directory Structure

Backend tests are placed alongside the code they test using `_test.go` suffix:

```
backend/
├── cmd/server/main.go
├── internal/
│   ├── domain/
│   │   ├── user.go
│   │   └── user_test.go          # Unit tests: domain logic
│   ├── service/
│   │   ├── user_service.go
│   │   └── user_service_test.go  # Unit tests: service layer
│   └── handler/
│       ├── user_handler.go
│       └── user_handler_test.go  # Unit tests: handlers (with httptest)
├── integration/
│   ├── user_integration_test.go  # Integration tests: multi-layer flows
│   └── order_integration_test.go
└── e2e/
    └── user_flow_test.go         # E2E tests: full API workflows
```

**Test type guidelines**:
| Type | Location | Scope | Database |
|------|----------|-------|----------|
| Unit test | `*_test.go` next to code | Single function/package | Mock or none |
| Integration test | `integration/` | Multiple layers | Real database |
| E2E test | `e2e/` | Full API flow | Real database |

**Test fixtures and temporary files**:
- **Fixtures**: Store in `testdata/` directory next to the test file
- **Temporary files**: Use `os.MkdirTemp()` or `t.TempDir()`, cleanup in `defer`
- **Temporary directory**: Use `tmp/` at project root for test-generated files (already gitignored)
- **Downloaded assets**: Use `testdata/` for static fixtures, `tmp/` for dynamic content
- **Never hardcode fixture paths**: Use `testdata` package variable or `os.DirFS`

```go
// ✅ Good: Using testdata for fixtures
var testDataFS = os.DirFS("testdata")

func TestParseConfig(t *testing.T) {
    data, err := fs.ReadFile(testDataFS, "valid_config.yaml")
    // ...
}

// ✅ Good: Temporary file cleanup
func TestExportCSV(t *testing.T) {
    tmpDir := t.TempDir()  // Go 1.15+, auto-cleanup
    outputPath := filepath.Join(tmpDir, "export.csv")
    // ...
}
```

**Naming conventions**:
- Unit tests: `{package}_{subject}_test.go` (e.g., `user_service_test.go`)
- Integration tests: `{subject}_integration_test.go`
- E2E tests: `{flow}_e2e_test.go`
- Fixtures: `{description}.{ext}` in `testdata/` (e.g., `testdata/valid_user.json`)

### 12. Guard Clause Standards
- **Handle Exceptions First**: Check and handle exceptional cases before normal logic
- **Invert Conditions**: Use inverted conditions to return early, avoid deep nesting
- **Flat Code Structure**: Reduce nesting levels, keep code flat and readable
- **Early Return**: Return as soon as possible when conditions are not met
- **Readability**: Guard clauses make the main logic more visible and easier to understand
- **Pattern**: `if err != nil { return }` before proceeding with normal logic
- **Avoid Else**: Prefer early return over else branches when possible

### 13. Refactoring Standards

#### 13.1 Feature Inventory
- **Feature Inventory**: Before refactoring, document ALL existing features and behaviors
- **Feature Checklist**: Create a checklist of features to verify after refactoring
- **No Feature Loss**: Every feature that exists before refactoring MUST exist after refactoring
- **Behavior Verification**: Test each feature after refactoring to confirm it still works
- **Edge Cases**: Pay special attention to edge cases and error handling paths
- **Hidden Features**: Watch for implicit behaviors (caching, logging, validation) that may be overlooked
- **API Compatibility**: Ensure public APIs remain compatible unless explicitly changing them
- **Configuration Preserved**: All configuration options must continue to work
- **Performance Characteristics**: Document and preserve important performance behaviors
- **Security Features**: Never remove or weaken security measures during refactoring
- **Incremental Changes**: Large refactorings should be split into smaller, reviewable changes
- **Rollback Plan**: Have a plan to revert changes if issues are discovered

#### 13.2 Extract Function

```go
// ❌ Before refactoring: Long function
func ProcessOrder(order *Order) error {
    // Validate order
    if order == nil {
        return errors.New("order is nil")
    }
    if len(order.Items) == 0 {
        return errors.New("order has no items")
    }
    
    // Calculate total
    var total float64
    for _, item := range order.Items {
        total += item.Price * float64(item.Quantity)
    }
    
    // Apply discount
    if order.Discount > 0 {
        total = total * (1 - order.Discount)
    }
    
    // Update order
    order.TotalAmount = total
    order.Status = StatusProcessed
    
    return nil
}

// ✅ After refactoring: Extract functions
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

#### 13.3 Use Value Objects

```go
// ❌ Before refactoring: Using primitive types
func CreateOrder(productID string, quantity int, price float64, currency string) (*Order, error) {
    // ...
}

// ✅ After refactoring: Using value objects
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

### 14. Function Design Standards

#### 14.1 Control Complexity

Focus on cyclomatic complexity rather than line count. A function should do one thing well.

**Guidelines**:
- **Cyclomatic complexity ≤15**: Use `gocyclo` to measure, split if exceeds
- **Nesting depth ≤3**: Deep nesting indicates need for extraction or guard clauses
- **Single responsibility**: Function should have one clear purpose
- **Readability first**: A 40-line linear function is better than 20 lines of spaghetti

```go
// ❌ Bad: High complexity, deep nesting
func ProcessOrder(order *Order) error {
    if order != nil {
        if order.Items != nil {
            if len(order.Items) > 0 {
                for _, item := range order.Items {
                    if item.Quantity > 0 {
                        // Processing logic...
                        if item.Price > 0 {
                            // Deeper nesting...
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
        return fmt.Errorf("validate order: %w", err)
    }
    
    if err := processItems(order.Items); err != nil {
        return fmt.Errorf("process items: %w", err)
    }
    
    return updateOrderStatus(order, StatusCompleted)
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

func processItems(items []Item) error {
    for _, item := range items {
        if err := processItem(item); err != nil {
            return fmt.Errorf("process item %s: %w", item.ID, err)
        }
    }
    return nil
}

// ✅ Also acceptable: Longer but linear and readable
func BuildReport(data *ReportData) *Report {
    report := &Report{}
    report.Title = data.Title
    report.GeneratedAt = time.Now()
    report.Summary = calculateSummary(data)
    report.Details = buildDetails(data.Items)
    report.Totals = calculateTotals(data)
    // More linear operations...
    return report
}
```

**Measure complexity**:
```bash
# Check cyclomatic complexity
gocyclo -over 15 .
```

#### 14.2 Single Responsibility Principle

One function should do one thing only.

```go
// ❌ Bad: Mixed responsibilities
func CreateUserAndSendEmail(name, email string) error {
    // Create user
    user := &User{Name: name, Email: email}
    if err := db.Create(user).Error; err != nil {
        return err
    }
    
    // Send email
    subject := "Welcome"
    body := fmt.Sprintf("Hello %s, welcome!", name)
    return sendEmail(email, subject, body)
}

// ✅ Good: Separated responsibilities
func CreateUser(name, email string) (*User, error) {
    user := &User{Name: name, Email: email}
    if err := db.Create(user).Error; err != nil {
        return nil, fmt.Errorf("create user: %w", err)
    }
    return user, nil
}

func SendWelcomeEmail(user *User) error {
    subject := "Welcome"
    body := fmt.Sprintf("Hello %s, welcome!", user.Name)
    if err := sendEmail(user.Email, subject, body); err != nil {
        return fmt.Errorf("send welcome email: %w", err)
    }
    return nil
}
```

#### 14.3 Minimize Parameters

Fewer parameters are generally better, but use judgment based on context.

**Guidelines**:
- **1-3 parameters**: Ideal, easy to understand and use
- **4-5 parameters**: Acceptable when logically related
- **6+ parameters**: Consider refactoring with struct or Option pattern

```go
// ❌ Bad: Too many unrelated parameters
func CreateOrder(userID string, productID string, quantity int, price float64, discount float64, currency string, note string) (*Order, error) {
    // ...
}

// ✅ Good: Use struct to encapsulate related parameters
type CreateOrderRequest struct {
    UserID    string
    ProductID string
    Quantity  int
    Price     Money
    Note      string
}

func CreateOrder(req *CreateOrderRequest) (*Order, error) {
    // ...
}

// ✅ Also acceptable: Related parameters that naturally belong together
func DrawRectangle(x, y, width, height int, color string) {
    // These parameters are logically related, no need for struct
}

// ✅ Good: Functional Option pattern for optional parameters
func NewServer(addr string, opts ...ServerOption) *Server {
    server := &Server{addr: addr}
    for _, opt := range opts {
        opt(server)
    }
    return server
}

// Usage
server := NewServer(":8080",
    WithTimeout(30*time.Second),
    WithTLS(certFile, keyFile),
)
```

#### 14.4 Avoid Side Effects

Functions should not hide modifications to external state.

```go
// ❌ Bad: Hidden side effect
var globalCounter int

func GetUserCount() int {
    globalCounter++  // Side effect: modifies global state
    return globalCounter
}

// ✅ Good: No side effect, predictable behavior
func GetUserCount() int {
    return globalCounter  // Read-only, no modification
}

func IncrementUserCount() {
    globalCounter++  // Clearly expresses modification intent
}
```

#### 14.5 Separate Commands from Queries

Functions should either perform an action OR return a result, not both.

```go
// ❌ Bad: Both performs action and returns result
func SetUserAge(user *User, age int) bool {
    if age < 0 || age > 150 {
        return false
    }
    user.Age = age
    return true
}

// ✅ Good: Separate command from query
func ValidateAge(age int) error {
    if age < 0 || age > 150 {
        return errors.New("invalid age")
    }
    return nil
}

func SetUserAge(user *User, age int) {
    user.Age = age
}

// Usage
if err := ValidateAge(age); err != nil {
    return err
}
SetUserAge(user, age)
```

### 15. Code Formatting Standards

#### 15.1 Use gofmt

Always use `gofmt` and `goimports` for automatic code formatting.

```bash
# Format code
gofmt -w .

# Format and organize imports
goimports -w .
```

#### 15.2 Vertical Formatting

Related code should be grouped together, organized top-down.

```go
// ✅ Good: Top-down, high-level logic first
// handler.go

package handler

// Handler handles HTTP requests
type Handler struct {
    service *Service
}

// NewHandler creates Handler instance
func NewHandler(service *Service) *Handler {
    return &Handler{service: service}
}

// HandleGetUser handles get user request
func (h *Handler) HandleGetUser(w http.ResponseWriter, r *http.Request) {
    // High-level logic
    userID := r.URL.Query().Get("id")
    user, err := h.service.GetUser(userID)
    if err != nil {
        respondError(w, err)
        return
    }
    respondJSON(w, user)
}

// Private helper functions follow
func respondJSON(w http.ResponseWriter, data interface{}) {
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(data)
}

func respondError(w http.ResponseWriter, err error) {
    // ...
}
```

#### 15.3 Horizontal Formatting

```go
// ❌ Bad: Too long line
if user != nil && user.IsActive && user.HasPermission("admin") && time.Now().Before(user.ExpiryTime) {
    // ...
}

// ✅ Good: Reasonable line breaks
if user != nil &&
    user.IsActive &&
    user.HasPermission("admin") &&
    time.Now().Before(user.ExpiryTime) {
    // ...
}

// ✅ Good: Extract conditions
isValidUser := user != nil && user.IsActive
hasPermission := user.HasPermission("admin")
isNotExpired := time.Now().Before(user.ExpiryTime)

if isValidUser && hasPermission && isNotExpired {
    // ...
}
```

### 16. Code Organization Standards

#### 16.1 File Organization

```go
// ✅ Good: Organize files by responsibility
// internal/service/user_service.go

package service

import (
    "context"
    "errors"
)

// Public types and interfaces first
type UserService struct {
    repo UserRepository
}

type UserRepository interface {
    FindByID(ctx context.Context, id string) (*User, error)
    Save(ctx context.Context, user *User) error
}

// Public methods
func NewUserService(repo UserRepository) *UserService {
    return &UserService{repo: repo}
}

func (s *UserService) GetUser(ctx context.Context, id string) (*User, error) {
    return s.repo.FindByID(ctx, id)
}

// Private methods last
func (s *UserService) validate(user *User) error {
    // ...
}
```

### 17. Performance Optimization Standards

#### 17.1 Avoid Unnecessary Memory Allocation

```go
// ❌ Bad: Frequent allocation
func Concatenate(parts []string) string {
    var result string
    for _, part := range parts {
        result += part  // Allocates new memory each time
    }
    return result
}

// ✅ Good: Use strings.Builder
func Concatenate(parts []string) string {
    var builder strings.Builder
    for _, part := range parts {
        builder.WriteString(part)
    }
    return builder.String()
}
```

#### 17.2 Use sync.Pool for Object Reuse

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

### 18. Code Smells Identification

Recognize and address these code smells:

| Code Smell | Description | Solution |
|------------|-------------|----------|
| **Rigidity** | Hard to change, one change triggers cascade | Decouple, single responsibility |
| **Fragility** | Easy to break, one change breaks other features | Add tests, refactor |
| **Duplication** | Same code appears in multiple places | DRY principle, abstract common functions |
| **High Complexity** | Function cyclomatic complexity > 15 | Split into smaller, focused functions |
| **Deep Nesting** | More than 3 levels of indentation | Use guard clauses, extract functions |
| **Large Class** | Class takes on too many responsibilities | Single responsibility, split class |
| **Long Parameter List** | 6+ parameters, hard to track | Use struct or Option pattern |
| **Divergent Change** | One class modified for multiple reasons | Single responsibility |
| **Shotgun Surgery** | One change involves multiple classes | Merge related logic |
| **Feature Envy** | Function uses another class's data excessively | Move function to data's class |
| **Data Clumps** | Multiple data always appear together | Encapsulate as struct |

### 19. Tool Recommendations

#### 19.1 Code Quality Tools

```bash
# Install revive linter
go install github.com/mgechev/revive@latest

# Static analysis
go vet ./...

# Code linting
revive ./...

# Formatting
gofmt -w .
goimports -w .

# Simplify code
goreturns -w .

# Check code complexity
gocyclo -over 15 .
```

#### 19.2 Performance Analysis Tools

```bash
# CPU profiling
go test -cpuprofile=cpu.prof -bench=.
go tool pprof cpu.prof

# Memory profiling
go test -memprofile=mem.prof -bench=.
go tool pprof mem.prof
```

## Backend Checklist

- [ ] Interface fields use camelCase
- [ ] All fields have explicit `gorm:"column:field_name"` tag
- [ ] No index/uniqueIndex tags in gorm struct
- [ ] DDL fields all have NOT NULL constraint
- [ ] Use struct model for gorm updates, not map[string]interface{}
- [ ] No raw SQL for CRUD operations, use gorm model methods
- [ ] Do not print sensitive information
- [ ] Use English logs with wrapped logger instance (NEVER use `fmt.Println`, `log.Println`, etc.)
- [ ] Use structured logging (`InfoW`, `WarnW`, `ErrorW`, `DebugW`)
- [ ] Log keys use camelCase naming
- [ ] No `fmt.Sprintf` or string concatenation in log messages
- [ ] Database fields use int64 timestamps
- [ ] API responses use int64 timestamps
- [ ] Business logic in domain layer
- [ ] No duplicate code blocks
- [ ] No magic numbers and magic strings
- [ ] Prefer struct over map[string]interface{} for known fields
- [ ] No redundant nil checks for initialized dependencies
- [ ] Dependencies initialized at startup, not checked repeatedly
- [ ] Compiles successfully and passes lint
- [ ] Functions returning error follow zero-value pattern
- [ ] Use `errors.Is()` for error comparison (NEVER use `==`)
- [ ] Use `errors.As()` for error type assertion
- [ ] All calculations are performed in backend
- [ ] Data is aggregated before sending to frontend
- [ ] No direct `go` keyword usage, use `goroutine.SafeGo` or `goroutine.SafeGoWithContext`
- [ ] No mock data or placeholder implementations
- [ ] No TODO/FIXME placeholders in production code
- [ ] Comments accurately describe current code behavior
- [ ] No outdated or misleading comments
- [ ] Public functions have documentation comments
- [ ] Test cases updated when code changes
- [ ] New features have corresponding test cases
- [ ] Bug fixes include regression tests
- [ ] Guard clauses used to handle exceptions first
- [ ] Early returns reduce nesting levels
- [ ] Code structure is flat and readable
- [ ] All existing features documented before refactoring
- [ ] Feature checklist created and verified after refactoring
- [ ] No functionality lost during refactoring
- [ ] Edge cases and error handling verified post-refactoring
- [ ] Security features preserved during refactoring
- [ ] Functions have controlled complexity (cyclomatic complexity ≤15)
- [ ] Functions have single responsibility
- [ ] Function parameters reasonable (≤5 acceptable, 6+ consider struct/option pattern)
- [ ] No hidden side effects in functions
- [ ] Commands separated from queries
- [ ] Code formatted with gofmt/goimports
- [ ] Package structure follows standard layout
- [ ] Avoid unnecessary memory allocations
- [ ] Recognized and addressed code smells

---

---

## Security Standards

> "Security is not a product, but a process." — Bruce Schneier

This section distills key security principles from:
- **Security Engineering** (Ross Anderson)
- **Applied Cryptography** (Bruce Schneier)
- **The Web Application Hacker's Handbook** (Dafydd Stuttard & Marcus Pinto)
- **Building Secure Software** (John Viega & Gary McGraw)
- **The Art of Deception** (Kevin Mitnick)

---

### 1. Defense in Depth (Security Engineering)

**Core Principle**: Never rely on a single layer of defense. Assume each layer can fail.

| Layer | Defense | Failure Mode |
|-------|---------|--------------|
| Network | Firewall, WAF | Misconfiguration |
| Application | Input validation, authZ | Bypass via injection |
| Data | Encryption at rest | Leaked backups |
| Human | Training | Social engineering |

```go
// ❌ Bad: Single point of failure
func DeleteUser(userID string) error {
    return db.Delete(&User{}, userID).Error  // No authorization check!
}

// ✅ Good: Defense in depth
func DeleteUser(ctx context.Context, requesterID, userID string) error {
    // Layer 1: Authentication (who is making the request?)
    requester, err := auth.GetCurrentUser(ctx)
    if err != nil {
        return ErrUnauthenticated
    }

    // Layer 2: Authorization (can they delete this user?)
    if requester.ID != userID && !requester.IsAdmin {
        return ErrForbidden
    }

    // Layer 3: Audit logging (who did what, when?)
    audit.Log(ctx, "user.deleted", map[string]interface{}{
        "requester_id": requesterID,
        "user_id": userID,
        "timestamp": time.Now().UnixMilli(),
    })

    // Layer 4: Soft delete (recoverable)
    return db.Model(&User{}).Where("id = ?", userID).
        Update("deleted_at", time.Now().UnixMilli()).Error
}
```

---

### 2. Secure Input Validation (Building Secure Software + Web App Hacker's Handbook)

**Core Principle**: Validate all input at the trust boundary. Never trust external data.

#### 2.1 Validate and Sanitize

```go
// ❌ Bad: Trusting external input directly
func Search(query string) []*Product {
    sql := "SELECT * FROM products WHERE name LIKE '%" + query + "%'"
    // SQL INJECTION vulnerability!
    return db.Raw(sql).Scan()
}

// ✅ Good: Parameterized query with validation
func Search(ctx context.Context, query string) ([]*Product, error) {
    // 1. Length check (DoS prevention)
    if len(query) > 100 {
        return nil, ErrQueryTooLong
    }

    // 2. Character whitelist (allow only safe chars)
    if !regexp.MustCompile(`^[\w\s]+$`).MatchString(query) {
        return nil, ErrInvalidCharacters
    }

    // 3. Parameterized query (prevents SQL injection)
    var products []*Product
    err := db.WithContext(ctx).
        Where("name LIKE ?", "%"+query+"%").
        Find(&products).Error
    if err != nil {
        return nil, fmt.Errorf("search products: %w", err)
    }
    return products, nil
}
```

#### 2.2 SQL Injection Defense Patterns

| Vulnerability | Cause | Fix |
|--------------|-------|-----|
| **Classic Injection** | String concatenation in SQL | Parameterized queries |
| **Second-Order** | Stored malicious data executed later | Output encoding on read |
| **Blind Injection** | True/false responses reveal data | Strict type validation, rate limiting |

```go
// Second-order SQL injection prevention
// Attack scenario: Attacker stores malicious data (e.g., "admin'--") in a profile field.
// When another user views the attacker's profile, this data is used in a query without sanitization.
// The malicious SQL executes on read, not just write.
func GetUserProfile(profileID string) (*Profile, error) {
    var profile Profile
    // Parameterized query prevents SQL injection regardless of malicious content
    err := db.Where("id = ?", profileID).First(&profile).Error
    if err != nil {
        return nil, fmt.Errorf("get user profile %s: %w", profileID, err)
    }
    // The stored malicious content is just data when retrieved—it cannot execute
    // because we never concatenate it into a query string.
    return &profile, nil
}

// Best practice: Validate input on write (to catch obvious attacks early),
// but rely on parameterized queries on both write AND read for defense-in-depth.
```

#### 2.3 NoSQL Injection

```go
// ❌ Bad: MongoDB injection
func FindUser(ctx context.Context, filter map[string]interface{}) (*User, error) {
    // Attack: {"$where": "javascript_code"}
    var user User
    err := db.WithContext(ctx).Where(filter).First(&user).Error
    return &user, err
}

// ✅ Good: Explicit field matching
func FindUserByEmail(ctx context.Context, email string) (*User, error) {
    // Strict validation before query
    if !isValidEmail(email) {
        return nil, ErrInvalidEmail
    }
    var user User
    err := db.WithContext(ctx).
        Where("email = ?", email).
        First(&user).Error
    return &user, err
}
```

---

### 3. Authentication & Session Security (Web App Hacker's Handbook + Security Engineering)

#### 3.1 Password Storage

```go
// ❌ Bad: Plaintext or weak hashing
func StorePassword(userID string, password string) error {
    hash := md5.Sum([]byte(password))  // MD5 is broken!
    return db.Model(&User{}).Where("id = ?", userID).
        Update("password_hash", hex.EncodeToString(hash[:])).Error
}

// ✅ Good: bcrypt with cost factor
import "golang.org/x/crypto/bcrypt"

func StorePassword(userID string, password string) error {
    // bcrypt automatically includes salt
    hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost+2)
    if err != nil {
        return fmt.Errorf("hash password: %w", err)
    }
    return db.Model(&User{}).Where("id = ?", userID).
        Update("password_hash", string(hash)).Error
}

func VerifyPassword(hash, password string) bool {
    err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
    return err == nil
}
```

#### 3.2 Session Management

```go
// ❌ Bad: Predictable or exposed session tokens
func CreateSession(userID string) string {
    token := md5([]byte(userID + time.Now().String()))  // Predictable!
    return token
}

// ✅ Good: Cryptographically random tokens
import "crypto/rand"

func GenerateSessionToken() (string, error) {
    b := make([]byte, 32)  // 256 bits
    if _, err := rand.Read(b); err != nil {
        return "", fmt.Errorf("generate token: %w", err)
    }
    return base64.URLEncoding.EncodeToString(b), nil
}

// Secure session cookie settings
func SetSessionCookie(w http.ResponseWriter, token string) {
    http.SetCookie(w, &http.Cookie{
        Name:     "session_id",
        Value:    token,
        HttpOnly: true,    // No JavaScript access (XSS protection)
        Secure:   true,    // HTTPS only
        SameSite: http.SameSiteStrict,
        Path:     "/",
        MaxAge:   3600,   // 1 hour
    })
}
```

#### 3.3 Brute Force Protection

```go
// Rate limiting with exponential backoff
type LoginAttempt struct {
    UserID    string
    Count     int
    LastTry   int64
}

func (s *LoginAttempt) IsLocked() bool {
    if s.Count < 3 {
        return false
    }
    // Exponential backoff: 1min, 5min, 30min, 2hr, ...
    backoffMinutes := math.Pow(5, float64(s.Count-3))
    return time.Now().UnixMilli() - s.LastTry < int64(backoffMinutes*60*1000)
}

func (s *LoginAttempt) RecordFailure() {
    s.Count++
    s.LastTry = time.Now().UnixMilli()
}

func (s *LoginAttempt) RecordSuccess() {
    s.Count = 0
}
```

---

### 4. Cryptography Best Practices (Applied Cryptography)

**Core Principle**: Don't roll your own crypto. Use proven libraries and algorithms.

#### 4.1 Algorithm Selection

| Use Case | Recommended | Avoid |
|----------|------------|-------|
| Password hashing | bcrypt, scrypt, argon2 | MD5, SHA1, plain SHA256 |
| Symmetric encryption | AES-256-GCM, ChaCha20-Poly1305 | DES, AES-ECB |
| Asymmetric encryption | X25519, ECIES | RSA-1024, RSA-512 |
| Data in transit | TLS 1.3 | SSL, TLS 1.0, TLS 1.1 |
| Digital signatures | Ed25519, ECDSA (P-256+) | RSA-512, DSA |
| Key derivation (password) | argon2, scrypt, bcrypt | PBKDF2 (with < 100k iterations) |
| Key derivation (material) | HKDF | direct hash of secret |

#### 4.2 Encryption Example

```go
import (
    "crypto/aes"
    "crypto/cipher"
    "crypto/rand"
)

type EncryptedData struct {
    Ciphertext []byte
    Nonce     []byte  // GCM nonce, not secret
}

// Encrypt uses AES-256-GCM (authenticated encryption)
func Encrypt(plaintext, key []byte) (*EncryptedData, error) {
    block, err := aes.NewCipher(key)
    if err != nil {
        return nil, fmt.Errorf("create cipher: %w", err)
    }

    gcm, err := cipher.NewGCM(block)
    if err != nil {
        return nil, fmt.Errorf("create GCM: %w", err)
    }

    nonce := make([]byte, gcm.NonceSize())
    if _, err := rand.Read(nonce); err != nil {
        return nil, fmt.Errorf("generate nonce: %w", err)
    }

    // Seal appends ciphertext to nonce (nonce || ciphertext || tag)
    ciphertext := gcm.Seal(nonce, nonce, plaintext, nil)
    nonceSize := gcm.NonceSize()

    return &EncryptedData{
        Ciphertext: ciphertext[nonceSize:],
        Nonce:     nonce,
    }, nil
}

// Decrypt verifies authentication tag before returning plaintext
func (e *EncryptedData) Decrypt(key []byte) ([]byte, error) {
    block, err := aes.NewCipher(key)
    if err != nil {
        return nil, fmt.Errorf("create cipher: %w", err)
    }

    gcm, err := cipher.NewGCM(block)
    if err != nil {
        return nil, fmt.Errorf("create GCM: %w", err)
    }

    if len(e.Ciphertext) < gcm.Overhead() {
        return nil, ErrCiphertextTooShort
    }

    // Open decrypts and verifies tag in one step
    plaintext, err := gcm.Open(nil, e.Nonce, e.Ciphertext, nil)
    if err != nil {
        return nil, fmt.Errorf("decrypt: %w", err)  // Authentication failed!
    }
    return plaintext, nil
}
```

#### 4.3 Key Management

```go
// ❌ Bad: Hardcoded keys
const API_KEY = "sk-1234567890abcdef"

// ✅ Good: Environment-based key loading
type Config struct {
    APIKey    string
    DBKey     []byte
}

func LoadConfig() (*Config, error) {
    apiKey := os.Getenv("API_KEY")
    if apiKey == "" {
        return nil, errors.New("API_KEY environment variable required")
    }

    dbKeyB64 := os.Getenv("DB_ENCRYPTION_KEY")
    if dbKeyB64 == "" {
        return nil, errors.New("DB_ENCRYPTION_KEY environment variable required")
    }

    dbKey, err := base64.StdEncoding.DecodeString(dbKeyB64)
    if err != nil || len(dbKey) != 32 {
        return nil, errors.New("DB_ENCRYPTION_KEY must be 32-byte base64")
    }

    return &Config{
        APIKey: apiKey,
        DBKey:  dbKey,
    }, nil
}
```

---

### 5. XSS Prevention (Web Application Hacker's Handbook)

**Core Principle**: Context-aware output encoding. Never reflect untrusted input unencoded.

#### 5.1 Go HTML Template Auto-Escape

```go
// Go html/template auto-escapes by default
// templates/user.html
// {{.Username}} is automatically escaped for HTML context

// ❌ Bad: Raw HTML insertion (XSS)
func RenderProfile(w http.ResponseWriter, user *User) {
    html := "<h1>" + user.Username + "</h1>"  // XSS if username = "<script>..."
    w.Write([]byte(html))
}

// ✅ Good: Use html/template
func RenderProfile(w http.ResponseWriter, user *User) error {
    tmpl, err := template.ParseFiles("templates/user.html")
    if err != nil {
        return err
    }
    return tmpl.Execute(w, user)  // Auto-escaped
}
```

#### 5.2 JavaScript Context Encoding

```html
<!-- ❌ Bad: User input in JavaScript context without encoding -->
<!-- If Username = '"; alert(1); //'  →  XSS! -->
<script>
var username = "{{.Username}}";
</script>

<!-- ✅ Good: Use JSON encoding for safe JavaScript embedding -->
<script type="application/json">
var user = {{.Username | json}};  // Go's json marshaller escapes for JS
</script>

<!-- ✅ Good: HTML attribute encoding -->
<input value="{{.Username | htmlattr}}">
```

#### 5.3 CSP Header

```go
func SecurityHeaders(h http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        // Content Security Policy
        w.Header().Set("Content-Security-Policy",
            "default-src 'self'; " +
            "script-src 'self' 'nonce-{random}'; " +
            "object-src 'none'; " +
            "base-uri 'self'; " +
            "form-action 'self'")

        // Other security headers
        w.Header().Set("X-Content-Type-Options", "nosniff")
        w.Header().Set("X-Frame-Options", "DENY")
        w.Header().Set("Referrer-Policy", "strict-origin-when-cross-origin")
        // Note: X-XSS-Protection is deprecated in modern browsers (Chrome 84+, 2020)
        // Rely on CSP (Content-Security-Policy) as primary XSS defense

        h.ServeHTTP(w, r)
    })
}
```

---

### 6. CSRF Protection (Web Application Hacker's Handbook)

**Core Principle**: Validate origin of requests. Use tokens for state-changing operations.

```go
// CSRF token generation and validation
import "crypto/subtle"

type CSRFToken struct {
    Secret []byte  // Server-only secret
}

func (t *CSRFToken) Generate(sessionID string) (string, error) {
    // Combine secret with session for time-limited token
    h := hmac.New(sha256.New, t.Secret)
    h.Write([]byte(sessionID))
    h.Write([]byte(strconv.FormatInt(time.Now().UnixMilli()/3600000, 10)))  // Hour granularity
    return base64.URLEncoding.EncodeToString(h.Sum(nil)), nil
}

func (t *CSRFToken) Validate(sessionID, token string) bool {
    expected, err := t.Generate(sessionID)
    if err != nil {
        return false
    }
    // Constant-time comparison to prevent timing attacks
    return hmac.Equal([]byte(token), []byte(expected))
}

// Middleware
func CSRFGuard(handler http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        if r.Method == "POST" || r.Method == "PUT" || r.Method == "DELETE" {
            sessionID := getSessionID(r)
            token := r.FormValue("csrf_token")

            if !csrfToken.Validate(sessionID, token) {
                http.Error(w, "CSRF token invalid", http.StatusForbidden)
                return
            }
        }
        handler.ServeHTTP(w, r)
    })
}
```

---

### 7. Access Control (Security Engineering)

**Core Principle**: Principle of Least Privilege. Grant minimum necessary permissions.

#### 7.1 Role-Based Access Control (RBAC)

```go
// ❌ Bad: Superuser role with unlimited access
func DeleteAllUsers(admin *User) error {
    if admin.Role == "admin" {  // Anyone with "admin" role can do anything!
        return db.Unscoped().Delete(&User{}).Error
    }
    return ErrForbidden
}

// ✅ Good: Explicit permission checks
type Permission string

const (
    PermissionUserRead   Permission = "user:read"
    PermissionUserWrite  Permission = "user:write"
    PermissionUserDelete Permission = "user:delete"
    PermissionAdminManage Permission = "admin:manage"
)

func (u *User) HasPermission(perm Permission) bool {
    switch u.Role {
    case "superadmin":
        return true  // Only superadmin has this
    case "admin":
        return perm != PermissionAdminManage  // Admin cannot manage other admins
    case "moderator":
        return perm == PermissionUserRead || perm == PermissionUserWrite
    case "user":
        return perm == PermissionUserRead
    }
    return false
}

func DeleteUser(ctx context.Context, requesterID, targetID string) error {
    requester, err := getUser(ctx, requesterID)
    if err != nil {
        return err
    }

    // Can only delete users with lower privilege
    if !requester.HasPermission(PermissionUserDelete) {
        return ErrForbidden
    }

    target, err := getUser(ctx, targetID)
    if err != nil {
        return err
    }

    if requester.Role == "admin" && target.Role == "superadmin" {
        return ErrCannotDeleteHigherRole
    }

    return db.Unscoped().Delete(&User{}, targetID).Error
}
```

#### 7.2 Resource-Level Authorization

```go
// Access control at resource level
type Document struct {
    ID       string
    OwnerID  string
    Readers  []string
    Writers  []string
}

func (d *Document) CanRead(userID string) bool {
    return d.OwnerID == userID || slices.Contains(d.Readers, userID)
}

func (d *Document) CanWrite(userID string) bool {
    return d.OwnerID == userID || slices.Contains(d.Writers, userID)
}

func (d *Document) CanDelete(userID string) bool {
    return d.OwnerID == userID  // Only owner can delete
}
```

---

### 8. Secure Communications (Security Engineering + Applied Cryptography)

#### 8.1 TLS Configuration

```go
// ❌ Bad: Weak TLS configuration
&tls.Config{
    MinVersion: tls.VersionTLS10,  // Weak!
}

// ✅ Good: TLS 1.3 only, strong cipher suites
&tls.Config{
    MinVersion: tls.VersionTLS13,
    CurvePreferences: []tls.CurveID{
        tls.X25519,
        tls.CurveP256,
    },
    CipherSuites: []uint16{
        tls.TLS_AES_256_GCM_SHA384,
        tls.TLS_CHACHA20_POLY1305_SHA256,
        tls.TLS_AES_128_GCM_SHA256,
    },
    PreferServerCipherSuites: true,
}
```

#### 8.2 Certificate Validation

```go
// ❌ Bad: Skipping certificate validation
tr := &http.Transport{
    TLSClientConfig: &tls.Config{
        InsecureSkipVerify: true,  // MITM vulnerability!
    },
}

// ✅ Good: Proper certificate validation
// Note: MinVersion: TLS12 allows connecting to older servers that don't support TLS 1.3
// For backend-to-backend communication, prefer MinVersion: TLS13 (see 8.1)
tr := &http.Transport{
    TLSClientConfig: &tls.Config{
        RootCAs:            rootCAs,           // Use system cert pool
        MinVersion:         tls.VersionTLS12,  //兼容旧服务器；内部服务间通信用TLS13
        InsecureSkipVerify: false,
        VerifyPeerCertificate: func(rawCerts [][]byte, verifiedChains [][]*x509.Certificate) error {
            // Additional custom validation if needed
            return nil
        },
    },
}
```

---

### 9. Memory Safety (Building Secure Software)

**Core Principle**: Prevent memory corruption vulnerabilities. In Go, GC prevents most classic memory errors, but concurrency bugs and improper escaping can still cause issues.

```go
// ❌ Bad: Buffer overflow (too much data copied into fixed buffer)
func ProcessBuffer(data []byte) []byte {
    buf := make([]byte, 256)
    copy(buf, data)  // If data > 256, bytes beyond 256 are silently discarded!
    return buf
}

// ✅ Good: Explicit bounds checking
func ProcessBuffer(data []byte) ([]byte, error) {
    const maxSize = 256
    if len(data) > maxSize {
        return nil, fmt.Errorf("data exceeds maximum size %d", maxSize)
    }
    buf := make([]byte, len(data))
    copy(buf, data)
    return buf, nil
}

// ❌ Bad: Data race (concurrent map access)
var sharedMap = make(map[string]string)

func AppendToMap(key, value string) {
    sharedMap[key] = value  // Data race: concurrent map writes
}

// ✅ Good: Thread-safe map access with mutex
type SafeMap struct {
    mu    sync.RWMutex
    items map[string]string
}

func (m *SafeMap) Set(key, value string) {
    m.mu.Lock()
    defer m.mu.Unlock()
    m.items[key] = value
}

func (m *SafeMap) Get(key string) string {
    m.mu.RLock()
    defer m.mu.RUnlock()
    return m.items[key]
}

// ❌ Bad: Escaping sensitive data to heap (potential info leak via memory dump)
func BadExample() string {
    password := "secret-token-12345"
    return password  // password escapes to heap, may persist in memory
}

// ✅ Good: Use crypto/subtle for constant-time operations to avoid info leaks
import "crypto/subtle"

func SecureCompare(a, b string) bool {
    return subtle.ConstantTimeCompare([]byte(a), []byte(b)) == 1
}
```

---

### 10. Logging for Security (Security Engineering)

**Core Principle**: Log security-relevant events. Protect log integrity.

#### 10.1 Security Event Logging

```go
// Security events to log
var SecurityEvents = []string{
    "auth.login.success",
    "auth.login.failure",
    "auth.logout",
    "auth.token.created",
    "auth.token.revoked",
    "user.created",
    "user.deleted",
    "user.permission_changed",
    "data.export",
    "admin.action",
}

func LogSecurityEvent(ctx context.Context, event string, details map[string]interface{}) {
    // Never log sensitive data
    safeDetails := sanitizeForLogging(details)

    logger.InfoW("security_event",
        "event", event,
        "user_id", getUserIDFromContext(ctx),
        "ip", getClientIP(ctx),
        "timestamp", time.Now().UnixMilli(),
        "details", safeDetails,
    )
}

func sanitizeForLogging(details map[string]interface{}) map[string]interface{} {
    // Remove sensitive fields
    sensitive := []string{"password", "token", "secret", "credit_card", "ssn"}
    sanitized := make(map[string]interface{})

    for k, v := range details {
        if !slices.Contains(sensitive, strings.ToLower(k)) {
            sanitized[k] = v
        }
    }
    return sanitized
}
```

#### 10.2 Audit Trail

```go
// Immutable audit log
type AuditLog struct {
    ID        string `gorm:"column:id"`
    Timestamp int64  `gorm:"column:timestamp"`
    ActorID   string `gorm:"column:actor_id"`
    Action    string `gorm:"column:action"`
    Resource  string `gorm:"column:resource"`
    ResourceID string `gorm:"column:resource_id"`
    Result    string `gorm:"column:result"`  // success, failure, denied
    IP        string `gorm:"column:ip"`
    UserAgent string `gorm:"column:user_agent"`
}

// Append-only audit log (prevent modification/deletion)
type AuditLogger struct {
    db *gorm.DB
}

func (a *AuditLogger) Log(ctx context.Context, entry *AuditLog) error {
    entry.ID = generateID()  // UUID for integrity
    entry.Timestamp = time.Now().UnixMilli()
    return a.db.WithContext(ctx).Create(entry).Error
}

// Prevent DELETE on audit logs at database level
// Add trigger or policy: audit_logs table should have no DELETE permission
```

---

### 11. Social Engineering Defense (The Art of Deception)

**Core Principle**: Human is the weakest link. Build systems that are resilient to manipulation.

#### 11.1 Phishing-Resistant Authentication

```go
// Multi-factor authentication
type MFAMethod string

const (
    MFAMethodTOTP  MFAMethod = "totp"    // Authenticator app
    MFAMethodWebAuthn MFAMethod = "webauthn"  // Hardware key (phishing-resistant)
    MFAMethodSMS   MFAMethod = "sms"    // Less secure, fallback only
)

func (a *AuthService) VerifyMFA(ctx context.Context, userID string, method MFAMethod, code string) error {
    user, err := a.getUser(userID)
    if err != nil {
        return err
    }

    switch method {
    case MFAMethodTOTP:
        return a.verifyTOTP(user.SecretTOTP, code)
    case MFAMethodWebAuthn:
        // WebAuthn is phishing-resistant due to origin binding
        return a.verifyWebAuthn(ctx, user.WebAuthnCredential, code)
    case MFAMethodSMS:
        // SMS MFA is vulnerable to SIM swap - warn users
        logger.WarnW("sms_mfa_used",
            "user_id", userID,
            "warning", "SMS MFA is vulnerable to SIM swap attacks")
        return a.verifySMS(user.Phone, code)
    }
}
```

#### 11.2 Suspicious Activity Detection

```go
// Detect anomalies that may indicate account compromise
type LoginAttempt struct {
    UserID    string
    IP        string
    UserAgent string
    Timestamp int64
}

func (s *SecurityService) DetectAnomalousLogin(ctx context.Context, attempt *LoginAttempt) bool {
    // New device?
    if !s.isKnownDevice(attempt.UserID, attempt.IP, attempt.UserAgent) {
        logger.WarnW("new_device_login",
            "user_id", attempt.UserID,
            "ip", attempt.IP,
            "user_agent", attempt.UserAgent)
        // Send notification to user
        s.notifyUser(attempt.UserID, "new_device_login", attempt.IP)
    }

    // Impossible travel? (login from two distant locations in short time)
    if s.impossibleTravel(attempt.UserID, attempt.IP) {
        logger.WarnW("impossible_travel_detected",
            "user_id", attempt.UserID,
            "ip", attempt.IP)
        // Require re-authentication or MFA
        return true
    }

    // Rate limiting
    if s.isRateLimited(attempt.UserID) {
        return true
    }

    return false
}
```

---

### 12. Security Checklist (LLM Prompt Generation)

When writing or reviewing code, use this checklist:

#### Authentication & Authorization
- [ ] Passwords hashed with bcrypt (cost ≥ 12)?
- [ ] Session tokens cryptographically random (256+ bits)?
- [ ] Session cookies have `HttpOnly`, `Secure`, `SameSite=Strict`?
- [ ] Brute force protection with exponential backoff?
- [ ] MFA available for sensitive operations?
- [ ] RBAC with explicit permission checks?
- [ ] Resource-level ownership verified before access?

#### Input Validation
- [ ] All external input validated at trust boundary?
- [ ] SQL queries use parameterized statements?
- [ ] No string concatenation in SQL, HTML, or shell commands?
- [ ] File uploads validated for type and size?
- [ ] URLs validated against allowlist for redirects?

#### Cryptography
- [ ] TLS 1.2+ for network communication?
- [ ] AES-256-GCM or ChaCha20-Poly1305 for encryption?
- [ ] No custom cryptographic implementations?
- [ ] Keys loaded from environment, not hardcoded?
- [ ] Secrets excluded from logs and error messages?

#### XSS & Injection
- [ ] User input HTML-encoded before output?
- [ ] Content-Security-Policy header configured?
- [ ] `HttpOnly` cookies prevent JavaScript access?
- [ ] Output encoding context-aware (HTML, JS, URL, CSS)?

#### CSRF & State
- [ ] CSRF tokens on all state-changing operations?
- [ ] Origin/Referer header validated for sensitive requests?
- [ ] CORS configured with strict allowlist?

#### Security Headers
- [ ] `X-Content-Type-Options: nosniff`?
- [ ] `X-Frame-Options: DENY`?
- [ ] `Referrer-Policy: strict-origin`?
- [ ] CSP header configured?

#### Logging & Monitoring
- [ ] Security events logged (login, logout, permission changes)?
- [ ] Sensitive data excluded from logs?
- [ ] Audit log tamper-proof?
- [ ] Failed login attempts monitored?

#### Dependencies
- [ ] Dependencies scanned for known vulnerabilities?
- [ ] No use of deprecated or vulnerable libraries?
- [ ] Third-party code reviewed for security?

---

## Frontend Standards (Vue 3 + TypeScript)

### 1. Single Responsibility Principle
- **Presentation Only**: Frontend is ONLY responsible for displaying data
- **No Business Logic**: Never implement business calculations in frontend
- **No Data Aggregation**: Never aggregate or transform complex data in frontend
- **Backend Trust**: Trust backend to provide all necessary pre-calculated data

### 2. Data Display Standards
- **Timestamps**: 
  - Receive int64 timestamps from backend
  - Use utility functions to format to local time
  - Display format: YYYY-MM-DD HH:mm:ss or contextual formats
- **Numbers**: 
  - Use backend-provided formatted values when available
  - Simple formatting only (e.g., decimal places, currency symbols)
  - No complex calculations
- **Data Transformation**: 
  - Only simple transformations (sorting, filtering by existing fields)
  - No data aggregation or statistical calculations
  - No derived data calculations

### 3. Component Structure
- **Vue 3 Composition API**: Use `<script setup>` syntax
- **TypeScript**: All code must be strongly typed
- **Props Validation**: Define prop types explicitly
- **Event Naming**: Use kebab-case for custom events
- **Component Naming**: Use PascalCase for component files

### 4. State Management
- **Pinia**: Use Pinia for global state management
- **Local State**: Use `ref` and `reactive` for component-local state
- **No Business Logic in Stores**: Stores should only manage UI state, not business calculations

### 5. API Integration
- **Request Handling**: Use centralized API modules
- **Error Handling**: Display user-friendly error messages
- **Loading States**: Always show loading indicators during async operations
- **No Data Manipulation**: Use data as received from backend

### 6. Code Quality Standards
- **TypeScript strict mode**: Enable strict type checking
- **ESLint**: Follow Vue and TypeScript best practices
- **No `any` type**: Avoid using `any`, define proper types
- **Consistent Formatting**: Use Prettier for code formatting

### 7. Performance Standards
- **Lazy Loading**: Use dynamic imports for large components
- **Computed Properties**: Use for simple derived values (no complex calculations)
- **Watchers**: Avoid deep watchers when possible
- **No Heavy Computations**: Move all heavy calculations to backend

### 8. UI/UX Standards
- **Responsive Design**: Support desktop and mobile devices
- **Accessibility**: Follow WCAG guidelines
- **Loading States**: Show loading indicators for async operations
- **Error States**: Handle and display errors gracefully
- **Empty States**: Show appropriate messages when no data available

### 9. Comment Standards
- **Consistency**: Comments must accurately describe what the code does, never contradict the actual implementation
- **Keep Updated**: When modifying code, always update related comments immediately
- **No Outdated Comments**: Remove or update comments that no longer reflect the current code behavior
- **No Misleading Comments**: Comments should not describe functionality that doesn't exist or has been removed
- **JSDoc for Public APIs**: Use JSDoc comments for exported functions, components, and types
- **Component Documentation**: Complex components should have comments explaining props and usage
- **Explain Why**: Comments should explain business decisions or non-obvious logic, not restate code
- **TODO Management**: TODO comments must include issue tracker reference and be actively tracked

### 10. Test Synchronization Standards
- **Sync with Code Changes**: When modifying code, corresponding test cases MUST be updated simultaneously
- **New Features**: New components or functions require corresponding test cases
- **Bug Fixes**: Bug fixes must include regression test cases
- **Refactoring**: Refactored components must update existing tests
- **Component Tests**: Update component tests when props, events, or behavior change
- **E2E Tests**: Update E2E tests when user flows or UI structure change
- **No Orphaned Tests**: Remove tests for deleted components, update tests for modified ones
- **Test Coverage**: Maintain or improve test coverage with each change

#### 10.1 Test Directory Structure

```
frontend/
├── src/
│   ├── components/
│   │   ├── UserCard.vue
│   │   └── __tests__/
│   │       └── UserCard.test.ts    # Component unit tests
│   ├── views/
│   │   ├── Dashboard.vue
│   │   └── __tests__/
│   │       └── Dashboard.test.ts
│   └── stores/
│       ├── user.ts
│       └── __tests__/
│           └── user.test.ts
├── e2e/
│   ├── specs/
│   │   ├── user-flow.spec.ts       # E2E tests: user workflows
│   │   └── checkout-flow.spec.ts
│   └── fixtures/
│       └── mock-data.ts            # E2E test fixtures
```

**Test type guidelines**:
| Type | Location | Framework | Scope |
|------|----------|-----------|-------|
| Component unit test | `__tests__/` next to component | Vitest + @vue/test-utils | Single component |
| View test | `__tests__/` next to view | Vitest + @vue/test-utils | View with child components |
| Store test | `__tests__/` next to store | Vitest | Pinia store logic |
| E2E test | `e2e/specs/` | Playwright/Cypress | Full user flow |

**Test fixtures and temporary files**:
- **E2E fixtures**: Store in `e2e/fixtures/`, import directly
- **Mock data**: Define in `e2e/fixtures/` or `__tests__/fixtures/`
- **Temporary files**: Use `tmp/` at project root for test-generated files (already gitignored)
- **Environment variables**: Use `.env.test` for E2E test configuration

```typescript
// ✅ Good: E2E fixture usage
import { mockUser, mockOrder } from '../fixtures/mock-data';

test('user can view their orders', async ({ page }) => {
  await page.goto('/orders');
  await page.fill('[data-testid="order-filter"]', mockOrder.id);
  // ...
});

// ✅ Good: Temporary file in tmp/ (gitignored)
import { promises as fs } from 'fs';
import { join } from 'path';

test('export generates CSV file', async () => {
  const tmpDir = join(process.cwd(), 'tmp', 'exports');
  await fs.mkdir(tmpDir, { recursive: true });
  const tmpFile = join(tmpDir, 'export.csv');
  await generateExport(tmpFile);
  const content = await fs.readFile(tmpFile, 'utf-8');
  expect(content).toContain('order_id');
  // cleanup: tmp/ is gitignored, but you can clean up after test
});
```

**Naming conventions**:
- Component tests: `{ComponentName}.test.ts`
- View tests: `{ViewName}.test.ts`
- Store tests: `{StoreName}.test.ts`
- E2E tests: `{flow-name}.spec.ts`
- Fixtures: `mock-{entity}.ts` or `{description}.ts`

### 11. Guard Clause Standards
- **Handle Exceptions First**: Check and handle exceptional cases before normal logic
- **Invert Conditions**: Use inverted conditions to return early, avoid deep nesting
- **Flat Code Structure**: Reduce nesting levels, keep code flat and readable
- **Early Return**: Return as soon as possible when conditions are not met
- **Readability**: Guard clauses make the main logic more visible and easier to understand
- **Pattern**: Check invalid props/state first, return early or show fallback UI
- **Avoid Else**: Prefer early return over else branches when possible

### 12. Refactoring Standards
- **Feature Inventory**: Before refactoring, document ALL existing UI features and behaviors
- **Feature Checklist**: Create a checklist of features to verify after refactoring
- **No Feature Loss**: Every feature that exists before refactoring MUST exist after refactoring
- **UI Behavior Preserved**: All user interactions must work the same way after refactoring
- **Edge Cases**: Watch for conditional rendering, error states, loading states that may be missed
- **Event Handlers**: All event handlers (click, input, etc.) must be preserved
- **Computed Properties**: All computed properties and their behaviors must be maintained
- **Watchers**: All watchers and their side effects must be preserved
- **Styling**: CSS classes and styles must continue to work correctly
- **Accessibility**: ARIA attributes and keyboard navigation must be preserved
- **Responsive Behavior**: Mobile/desktop layouts must continue to work
- **Component Props**: All props and their default values must be preserved
- **Component Events**: All emitted events must be preserved
- **Incremental Changes**: Large refactorings should be split into smaller, reviewable changes

## Frontend Checklist

- [ ] No business logic implemented in frontend
- [ ] No complex calculations in frontend
- [ ] No data aggregation in frontend
- [ ] Timestamps formatted using utility functions
- [ ] Numbers displayed with simple formatting only
- [ ] Using Vue 3 Composition API with `<script setup>`
- [ ] TypeScript types defined for all props and data
- [ ] Pinia used for global state only
- [ ] No business logic in stores
- [ ] Centralized API modules used
- [ ] Loading indicators implemented
- [ ] TypeScript strict mode enabled
- [ ] No `any` types used
- [ ] Responsive design implemented
- [ ] No mock data or placeholder implementations
- [ ] No TODO/FIXME placeholders in production code
- [ ] Comments accurately describe current code behavior
- [ ] No outdated or misleading comments
- [ ] JSDoc comments for exported functions and components
- [ ] Test cases updated when code changes
- [ ] New components/functions have corresponding test cases
- [ ] Bug fixes include regression tests
- [ ] Guard clauses used to handle exceptions first
- [ ] Early returns reduce nesting levels
- [ ] Code structure is flat and readable
- [ ] All existing UI features documented before refactoring
- [ ] Feature checklist created and verified after refactoring
- [ ] No functionality lost during refactoring
- [ ] Event handlers preserved during refactoring
- [ ] Accessibility features preserved during refactoring
- [ ] Responsive behavior verified post-refactoring

### Frontend Security Checklist
- [ ] No sensitive data (tokens, keys) stored in localStorage/sessionStorage
- [ ] API calls use HttpOnly cookies, not localStorage for auth tokens
- [ ] User input sanitized before display (use Vue's v-text, avoid v-html with user data)
- [ ] External URLs validated against allowlist before opening
- [ ] CSP meta tag or header configured (primary XSS defense)
- [ ] No inline scripts or styles with user-controlled content
- [ ] Security headers set by backend (frontend proxy doesn't strip them)
- [ ] Error messages don't expose sensitive system information
- [ ] Third-party scripts audited (no supply chain attacks)

---

## Daily Development Checklist

- [ ] Variables/functions clearly express intent?
- [ ] Functions focused and readable?
- [ ] Cyclomatic complexity reasonable (≤15)?
- [ ] Any duplicate code?
- [ ] Error handling complete?
- [ ] Comments explain "Why" not "How"?
- [ ] Code passes `gofmt` and `go vet`?
- [ ] Unit test coverage?
- [ ] Follows language idioms?

## Code Review Checklist

- [ ] Code readable and understandable?
- [ ] Obvious bugs or performance issues?
- [ ] Better implementation approach?
- [ ] Error handling complete?
- [ ] Sufficient tests?
- [ ] Accurate naming?
- [ ] Duplicate code?
- [ ] Single responsibility for functions?
- [ ] Follows team standards?

### Security Review
- [ ] Input validation on all trust boundaries?
- [ ] SQL injection protected (parameterized queries only)?
- [ ] No string concatenation in SQL/HTML/shell?
- [ ] Authorization checks before sensitive operations?
- [ ] Passwords use bcrypt, not MD5/SHA1?
- [ ] Tokens/keys cryptographically random?
- [ ] Auth tokens in HttpOnly cookies, not localStorage?
- [ ] CSRF tokens on state-changing operations?
- [ ] Output encoding context-aware?
- [ ] No sensitive data in logs or error messages?
- [ ] Security headers configured (CSP, X-Frame-Options, etc.)?
- [ ] Dependencies scanned for vulnerabilities?
- [ ] Hardcoded secrets removed?

### Security Quick Checks
- [ ] External input validated at trust boundary?
- [ ] SQL/command injection protected (parameterized queries)?
- [ ] Passwords hashed with bcrypt?
- [ ] Auth tokens cryptographically random (256+ bits)?
- [ ] Sensitive data excluded from logs?
- [ ] Output encoded for context (HTML, JS, URL)?

---

## Examples

See `references/code_examples.md` for detailed examples demonstrating correct and incorrect patterns for both backend and frontend code.

## Resources

### Backend Resources
- [Effective Go](https://golang.org/doc/effective_go)
- [Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments)
- [Uber Go Style Guide](https://github.com/uber-go/guide)
- Robert C. Martin. *Clean Code: A Handbook of Agile Software Craftsmanship*

### Frontend Resources
- [Vue 3 Documentation](https://vuejs.org/guide/introduction.html)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/)
- [Pinia Documentation](https://pinia.vuejs.org/)

### Security Resources
- [Security Engineering (Ross Anderson)](https://www.cl.cam.ac.uk/~rja14/book.html) — Free online
- [Applied Cryptography (Bruce Schneier)](https://www.schneier.com/books/applied-cryptography/)
- [OWASP Top 10](https://owasp.org/Top10/) — Web application vulnerabilities
- [Go Security Best Practices](https://owasp.org/www-project-go-secure-coding-practices-guide/)
- [Mozilla Security Guidelines](https://wiki.mozilla.org/Security)
