# Code Examples and Common Errors

This document provides comprehensive code examples demonstrating correct and incorrect patterns for all coding standards.

## 1. Naming Examples

### 1.1 Meaningful Names

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

### 1.2 Function Naming

```go
// ❌ Bad: Unclear purpose
func get(u *User) error { ... }
func processData(d Data) { ... }

// ✅ Good: Verb prefix, clearly expresses behavior
func GetUserByID(userID string) (*User, error) { ... }
func ValidateUserPermissions(user *User) error { ... }
```

### 1.3 Interface Naming

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

### 1.4 Avoid Misleading Names

```go
// ❌ Bad: Misleading naming
var userList map[string]*User  // Actually a map, not a list
var accountData *Account        // "Data" is a meaningless suffix

// ✅ Good: Accurate description
var userMap map[string]*User
var account *Account
```

### 1.5 Consistent Terminology

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

## 2. Function Design Examples

### 2.1 Keep Functions Small

```go
// ❌ Bad: Long, deeply nested function
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

// ✅ Good: Short, single responsibility
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
```

### 2.2 Single Responsibility Principle

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

### 2.3 Minimize Parameters

```go
// ❌ Bad: Too many parameters
func CreateOrder(userID string, productID string, quantity int, price float64, discount float64) (*Order, error) {
    // ...
}

// ✅ Good: Use struct to encapsulate
type CreateOrderRequest struct {
    UserID    string
    ProductID string
    Quantity  int
    Price     float64
    Discount  float64
}

func CreateOrder(req *CreateOrderRequest) (*Order, error) {
    // ...
}
```

### 2.4 Avoid Side Effects

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

### 2.5 Separate Commands from Queries

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

## 3. Error Handling Examples

### 3.1 Multiple Return Values Pattern

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

// ❌ Bad: Returning non-zero value with error
func GetUserWrong(id uint) (*User, error) {
    var user User
    if err := db.First(&user, id).Error; err != nil {
        return &User{Name: "default"}, err  // WRONG! Should return nil
    }
    return &user, nil
}

// ❌ Bad: Returning nil when no error
func GetUserWrong2(id uint) (*User, error) {
    var user User
    if err := db.First(&user, id).Error; err != nil {
        return nil, err
    }
    return nil, nil  // WRONG! Should return valid user
}
```

### 3.2 Use Errors Instead of Special Values

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

### 3.3 Error Wrapping

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

### 3.4 Custom Error Types

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

### 3.5 Common Error Patterns

```go
// Pattern 1: Single value + error
func FindUser(id uint) (*User, error) {
    if id == 0 {
        return nil, errors.New("invalid id")  // nil, error
    }
    // ... query logic
    return &user, nil  // valid value, nil
}

// Pattern 2: Multiple values + error
func GetUserStats(id uint) (int, float64, error) {
    if id == 0 {
        return 0, 0.0, errors.New("invalid id")  // 0, 0.0, error
    }
    // ... calculation logic
    return count, avg, nil  // valid values, nil
}

// Pattern 3: Slice/Map + error
func ListUsers() ([]User, error) {
    var users []User
    if err := db.Find(&users).Error; err != nil {
        return nil, err  // nil slice, error
    }
    return users, nil  // valid slice, nil (can be empty slice, but not nil)
}
```

## 4. Comment Examples

### 4.1 Good Comments

```go
// ✅ Good: Explain intent (Why not How)
// Use binary search instead of linear search because data is sorted by time
func FindRecentEvent(events []Event, threshold time.Time) *Event {
    // ...
}

// ✅ Good: TODO comment with issue reference
// TODO(hurzeng): Optimize performance, consider using cache (#123)
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

### 4.2 Bad Comments to Avoid

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

## 5. Logging Examples

### 5.1 Structured Logging (REQUIRED)

The project uses structured logging with key-value pairs. Log keys MUST use camelCase naming following Go/revive conventions (e.g., `userID`, `sessionID`, `apiKey`). Abbreviations like ID, URL, API should remain uppercase in camelCase. Always use `InfoW`, `WarnW`, `ErrorW`, `DebugW` series functions.

#### Correct Structured Logging

```go
// Correct: Use key-value pairs with camelCase keys (abbreviations stay uppercase)
logger.G().InfoW("User login successful",
    "userID", user.ID,
    "sessionID", session.ID,
    "ip", request.ClientIP,
)

// Correct: Error logging with context
logger.G().ErrorW("Failed to process API request",
    "apiPath", r.URL.Path,
    "method", r.Method,
    "error", err,
)

// Correct: Simple message without values
logger.G().InfoW("Service started")

// Correct: Duration and timing
logger.G().InfoW("Request completed", "duration", time.Since(start))
e.logger.InfoW("Page viewed", "pageID", pageID, "userID", userID, "duration", duration)

// Correct: Using InfoW series functions (recommended)
logger.G().InfoW("API request received", "apiPath", r.URL.Path, "method", r.Method, "userID", userID)
logger.G().ErrorW("Database query failed", "query", queryName, "table", tableName, "error", err)
```

#### Incorrect Structured Logging (DO NOT DO THIS)

```go
// WRONG: Using formatted strings in log messages
logger.G().InfoW(fmt.Sprintf("API request: %s %s", r.Method, r.URL.Path))

// WRONG: String concatenation
logger.G().InfoW("User logged in: " + userName + " from " + ip)

// WRONG: Using fmt.Sprintf
logger.G().ErrorW(fmt.Sprintf("Failed to process request %s: %v", r.URL.Path, err))

// WRONG: Not using camelCase for keys (note: userID not userId per Go conventions)
logger.G().InfoW("API request received", "user_id", userID, "api_path", r.URL.Path)

// WRONG: Using old format methods (these methods no longer exist)
logger.G().Infof("Service started on port: %d", port)  // Method removed!
logger.G().Info("WebSocket connected")                // Method removed!
```

### 5.2 Security in Logging

```go
// Correct: Use English, do not print sensitive information
logger.G().InfoW("User authenticated", "userID", user.ID)
logger.G().WarnW("Database connection timeout", "attempt", retryCount)
logger.G().ErrorW("Failed to process request", "apiPath", r.URL.Path, "error", err)

// Incorrect: Printing sensitive information
logger.G().InfoW("API key loaded", "apiKey", apiKey) // Prohibited!
logger.G().InfoW("User credentials", "password", password) // Prohibited!
```

### 5.3 Key Naming Reference Table (Go/revive Conventions)

Abbreviations (ID, URL, API, HTTP, etc.) should remain uppercase in camelCase: `userID`, `apiURL`, `httpRequest`.

| Context | Correct Key | Incorrect Key |
|---------|-------------|---------------|
| User ID | `userID` | `user_id`, `userId`, `UserID` |
| Session ID | `sessionID` | `session_id`, `sessionId`, `SessionID` |
| API Path | `apiPath` | `api_path`, `ApiPath` |
| Request ID | `requestID` | `request_id`, `requestId`, `RequestID` |
| Product ID | `productID` | `product_id`, `productId`, `ProductID` |
| Page ID | `pageID` | `page_id`, `pageId`, `PageID` |
| Error | `error` | `err`, `Error` |
| Duration | `duration` | `Duration`, `dur` |
| Page View | `pageView` | `page_view`, `PageView` |
| Status | `status` | `Status` |
| Click Count | `clickCount` | `click_count`, `ClickCount` |
| Response Time | `responseTime` | `response_time`, `ResponseTime` |
| API Key | `apiKey` | `api_key`, `APIKey` |
| API URL | `apiURL` | `api_url`, `apiUrl`, `APIURL` |
| HTTP Request | `httpRequest` | `http_request`, `HttpRequest`, `HTTPRequest` |

## 6. Database Field Standards Examples

### 6.1 Correct GORM Tag Usage

```go
type UserModel struct {
    ID        uint   `gorm:"column:id;primaryKey"`
    Username  string `gorm:"column:username"`
    Email     string `gorm:"column:email"`
    CreatedAt int64  `gorm:"column:created_at"`
    UpdatedAt int64  `gorm:"column:updated_at"`
}

// Correct: Explicit DDL definition
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

// Incorrect: Using AutoMigrate
db.AutoMigrate(&UserModel{}) // Prohibited!
```

## 7. Concurrency Examples

### 7.1 Prefer Channels Over Shared Memory

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

### 7.2 Avoid Goroutine Leaks

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

### 7.3 SafeGo Pattern (REQUIRED)

```go
// ❌ Bad: Direct goroutine usage
go func() {
    processTask(task)
}()

// ✅ Good: Use SafeGo with panic recovery
goroutine.SafeGo(func() {
    processTask(task)
})

// ✅ Good: Use SafeGoWithContext for context propagation
goroutine.SafeGoWithContext(ctx, func(ctx context.Context) {
    processTaskWithContext(ctx, task)
})
```

## 8. Performance Optimization Examples

### 8.1 Avoid Unnecessary Memory Allocation

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

### 8.2 Use sync.Pool for Object Reuse

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

## 9. Code Smells Identification

### 9.1 Code Smells Table

| Code Smell | Description | Solution |
|------------|-------------|----------|
| **Rigidity** | Hard to change, one change triggers cascade | Decouple, single responsibility |
| **Fragility** | Easy to break, one change breaks other features | Add tests, refactor |
| **Duplication** | Same code appears in multiple places | DRY principle, abstract common functions |
| **Long Function** | Function exceeds 20 lines | Split into multiple small functions |
| **Large Class** | Class takes on too many responsibilities | Single responsibility, split class |
| **Long Parameter List** | More than 3 parameters | Use struct to encapsulate |
| **Divergent Change** | One class modified for multiple reasons | Single responsibility |
| **Shotgun Surgery** | One change involves multiple classes | Merge related logic |
| **Feature Envy** | Function uses another class's data excessively | Move function to data's class |
| **Data Clumps** | Multiple data always appear together | Encapsulate as struct |

## 10. Refactoring Examples

### 10.1 Before Refactoring: Feature Inventory (REQUIRED)

Before starting any refactoring, document all existing features:

```go
// Feature Inventory for UserService
// Date: 2024-01-15
// Refactoring: Extract authentication logic to separate service
//
// Existing Features (ALL must be preserved):
// 1. User login with username/password
// 2. User login with email/password
// 3. Session creation and management
// 4. Login attempt rate limiting (max 5 attempts)
// 5. Account lockout after failed attempts
// 6. Password hashing with bcrypt
// 7. JWT token generation
// 8. Refresh token rotation
// 9. Login audit logging
// 10. IP address tracking for security
//
// Edge Cases to Preserve:
// - Empty username/email handling
// - Invalid password format handling
// - Expired session handling
// - Concurrent login handling
// - Account already locked handling
//
// Security Features to Preserve:
// - SQL injection protection
// - Brute force protection
// - Session hijacking prevention
// - Secure token storage
```

### 10.2 Extract Function Refactoring

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

### 10.3 Use Value Objects Refactoring

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

### 10.4 Correct Refactoring Process

```go
// Step 1: Keep original code working while adding new structure
// Step 2: Create feature checklist for verification
// Step 3: Refactor incrementally with tests passing at each step

// BEFORE: Original monolithic function
func (s *UserService) Login(username, password string) (*Session, error) {
    // Feature 1: Rate limiting
    if s.isRateLimited(username) {
        s.logger.InfoW("Login rate limited", "username", username)
        return nil, ErrRateLimited
    }
    
    // Feature 2: Find user
    user, err := s.repo.FindByUsername(username)
    if err != nil {
        s.incrementFailedAttempt(username)
        return nil, ErrInvalidCredentials
    }
    
    // Feature 3: Check account lockout
    if user.IsLocked {
        return nil, ErrAccountLocked
    }
    
    // Feature 4: Verify password
    if !s.verifyPassword(password, user.PasswordHash) {
        s.incrementFailedAttempt(username)
        return nil, ErrInvalidCredentials
    }
    
    // Feature 5: Create session
    session := s.createSession(user)
    
    // Feature 6: Audit logging
    s.auditLog.Log("login_success", user.ID)
    
    return session, nil
}

// AFTER: Refactored with ALL features preserved
func (s *UserService) Login(username, password string) (*Session, error) {
    // Feature 1: Rate limiting - PRESERVED
    if s.rateLimiter.IsLimited(username) {
        s.logger.InfoW("Login rate limited", "username", username)
        return nil, ErrRateLimited
    }
    
    // Feature 2: Find user - PRESERVED
    user, err := s.userFinder.Find(username)
    if err != nil {
        s.rateLimiter.Increment(username)  // Feature preserved
        return nil, ErrInvalidCredentials
    }
    
    // Feature 3: Check account lockout - PRESERVED
    if user.IsLocked() {
        return nil, ErrAccountLocked
    }
    
    // Feature 4: Verify password - PRESERVED
    if !s.passwordVerifier.Verify(password, user.PasswordHash()) {
        s.rateLimiter.Increment(username)  // Feature preserved
        return nil, ErrInvalidCredentials
    }
    
    // Feature 5: Create session - PRESERVED
    session, err := s.sessionManager.Create(user)
    if err != nil {
        return nil, err
    }
    
    // Feature 6: Audit logging - PRESERVED
    s.auditor.Log(AuditEventLoginSuccess, user.ID())
    
    return session, nil
}
```

### 10.5 Incorrect Refactoring (FEATURE LOSS)

```go
// WRONG: Features silently removed during refactoring
func (s *UserService) Login(username, password string) (*Session, error) {
    // Feature 1 (rate limiting) - LOST!
    
    user, err := s.repo.FindByUsername(username)
    if err != nil {
        // Feature 2 (failed attempt tracking) - LOST!
        return nil, ErrInvalidCredentials
    }
    
    // Feature 3 (account lockout check) - LOST!
    
    if !bcrypt.CheckPasswordHash(password, user.PasswordHash) {
        return nil, ErrInvalidCredentials
    }
    
    session := &Session{UserID: user.ID}
    
    // Feature 6 (audit logging) - LOST!
    
    return session, nil
}

// This refactoring LOST 4 features:
// 1. Rate limiting
// 2. Failed attempt tracking
// 3. Account lockout check
// 4. Audit logging
```

### 10.6 Hidden Features to Watch For

```go
// These features are often accidentally removed during refactoring:

// 1. Implicit caching
func (s *UserService) GetUser(id uint) (*User, error) {
    // Hidden: Cache check before database lookup
    if cached, ok := s.cache.Get(fmt.Sprintf("user:%d", id)); ok {
        return cached.(*User), nil  // This caching might be forgotten
    }
    
    user, err := s.repo.FindByID(id)
    if err != nil {
        return nil, err
    }
    
    s.cache.Set(fmt.Sprintf("user:%d", id), user, time.Hour)  // Cache write
    return user, nil
}

// 2. Background side effects
func (s *OrderService) CreateOrder(order *Order) error {
    if err := s.repo.Create(order); err != nil {
        return err
    }
    
    // Hidden: Async notification
    go func() {
        s.notifier.Notify(order.UserID, "order_created")  // Might be forgotten
    }()
    
    // Hidden: Metrics update
    s.metrics.OrderCount.Inc()  // Might be forgotten
    
    return nil
}

// 3. Validation side effects
func (s *UserService) Register(user *User) error {
    // Hidden: Normalization before validation
    user.Email = strings.ToLower(strings.TrimSpace(user.Email))
    
    if err := s.validator.Validate(user); err != nil {
        return err
    }
    
    // Hidden: Password hashing
    hashedPassword, err := bcrypt.HashPassword(user.Password)
    if err != nil {
        return err
    }
    user.Password = hashedPassword
    
    return s.repo.Create(user)
}

// 4. Error enhancement
func (s *PaymentService) ProcessPayment(payment *Payment) error {
    if err := s.gateway.Charge(payment); err != nil {
        // Hidden: Error wrapping with context
        return fmt.Errorf("payment processing failed for order %d: %w", 
            payment.OrderID, err)  // Context might be lost
    }
    return nil
}
```

### 10.7 Post-Refactoring Verification Checklist

```go
// Verification tests for each feature
func TestLogin_RefactoringVerification(t *testing.T) {
    // Feature 1: Rate limiting
    t.Run("rate_limiting_preserved", func(t *testing.T) {
        // Test that rate limiting still works
    })
    
    // Feature 2: Find user
    t.Run("user_lookup_preserved", func(t *testing.T) {
        // Test that user lookup still works
    })
    
    // Feature 3: Account lockout
    t.Run("account_lockout_preserved", func(t *testing.T) {
        // Test that lockout check still works
    })
    
    // Feature 4: Password verification
    t.Run("password_verification_preserved", func(t *testing.T) {
        // Test that password check still works
    })
    
    // Feature 5: Session creation
    t.Run("session_creation_preserved", func(t *testing.T) {
        // Test that session creation still works
    })
    
    // Feature 6: Audit logging
    t.Run("audit_logging_preserved", func(t *testing.T) {
        // Test that audit logging still works
    })
    
    // Edge case: Empty username
    t.Run("empty_username_handling_preserved", func(t *testing.T) {
        // Test edge case still handled
    })
    
    // Security: SQL injection protection
    t.Run("sql_injection_protection_preserved", func(t *testing.T) {
        // Test security feature still works
    })
}
```

## 11. Test Examples

### 11.1 Table-Driven Tests

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

### 11.2 Fast, Independent, Repeatable Tests

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

## 12. Magic Values Elimination

```go
// ❌ Bad: Using magic numbers and magic strings
func CalculateDiscount(price float64, userType string) float64 {
    if userType == "vip" {
        return price * 0.8 // Magic number 0.8
    } else if userType == "svip" {
        return price * 0.7 // Magic number 0.7
    }
    return price
}

func CheckOrderStatus(status int) string {
    if status == 1 { // Magic number 1
        return "pending" // Magic string
    } else if status == 2 { // Magic number 2
        return "completed" // Magic string
    }
    return "unknown"
}

// ✅ Good: Use meaningful constants
const (
    UserTypeNormal = "normal"
    UserTypeVIP    = "vip"
    UserTypeSVIP   = "svip"
)

const (
    VIPDiscountRate  = 0.8
    SVIPDiscountRate = 0.7
)

const (
    OrderStatusPending   = 1
    OrderStatusCompleted = 2
    OrderStatusCancelled = 3
)

const (
    OrderStatusTextPending   = "pending"
    OrderStatusTextCompleted = "completed"
    OrderStatusTextCancelled = "cancelled"
)

func CalculateDiscount(price float64, userType string) float64 {
    switch userType {
    case UserTypeVIP:
        return price * VIPDiscountRate
    case UserTypeSVIP:
        return price * SVIPDiscountRate
    default:
        return price
    }
}

func CheckOrderStatus(status int) string {
    switch status {
    case OrderStatusPending:
        return OrderStatusTextPending
    case OrderStatusCompleted:
        return OrderStatusTextCompleted
    case OrderStatusCancelled:
        return OrderStatusTextCancelled
    default:
        return "unknown"
    }
}
```

## 13. DDD Layering Examples

### 13.1 Correct DDD Layer Structure

```go
// Domain layer (does not depend on infrastructure)
type UserSession struct {
    ID        string
    UserID    string
    ExpiresAt int64
    // Business logic methods
}

// Application layer (coordinates domain objects)
type SessionService struct {
    sessionRepo SessionRepository
}

// Infrastructure layer (implements interfaces)
type SessionRepositoryImpl struct {
    db *gorm.DB
}
```

### 13.2 Violating DDD Dependency Rules

```go
// ❌ Bad: Domain layer depending on infrastructure
import "github.com/your-org/your-project/internal/infrastructure/persistence"

type Order struct {
    // Domain objects should not directly depend on infrastructure
}

// ✅ Good: Depend through interfaces
type OrderRepository interface {
    Save(order *Order) error
}
```

## 14. Duplicate Code Elimination

```go
// ❌ Bad: Duplicate validation logic
func CreateUser(name, email string) error {
    if name == "" {
        return errors.New("name is required")
    }
    if email == "" {
        return errors.New("email is required")
    }
    // ...
}

func UpdateUser(name, email string) error {
    if name == "" {
        return errors.New("name is required")
    }
    if email == "" {
        return errors.New("email is required")
    }
    // ...
}

// ✅ Good: Extract common validation function
func validateUserData(name, email string) error {
    if name == "" {
        return errors.New("name is required")
    }
    if email == "" {
        return errors.New("email is required")
    }
    return nil
}

func CreateUser(name, email string) error {
    if err := validateUserData(name, email); err != nil {
        return err
    }
    // ...
}

func UpdateUser(name, email string) error {
    if err := validateUserData(name, email); err != nil {
        return err
    }
    // ...
}
```

## 15. Timestamp Handling Examples

```go
// Database model
type UserSessionModel struct {
    ID        uint   `gorm:"primaryKey"`
    CreatedAt int64  `gorm:"not null"` // int64 timestamp
}

// API response
func (h *Handler) GetSession(c *gin.Context) {
    session := &dto.Session{
        ID:        sessionModel.ID,
        CreatedAt: sessionModel.CreatedAt, // Return int64 timestamp
    }
    response.Success(c, session)
}

// ❌ Bad: Using time.Time in API response
type Trade struct {
    CreatedAt time.Time `json:"createdAt"` // Should not transmit time.Time
}

// ✅ Good: Using int64 timestamp
type Trade struct {
    CreatedAt int64 `json:"createdAt"` // Use int64 timestamp
}
```

## 16. IDE Configuration and Tool Support

### 16.1 IDE Configuration
- Enable Go language linting tools
- Configure automatic formatting (gofmt)
- Set up code review rules
- Install golangci-lint: `go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest`

### 16.2 Pre-commit Checks
- Add pre-commit hook to check standards
- Use static analysis tools to check code quality
- Run unit tests to ensure functionality correctness
- Run `golangci-lint run ./...` to check code style

### 16.3 Code Quality Tools

```bash
# Install golangci-lint
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# Static analysis
go vet ./...

# Code linting
golangci-lint run ./...

# Formatting
gofmt -w .
goimports -w .

# Simplify code
goreturns -w .

# Check code complexity
gocyclo -over 15 .
```

### 16.4 Performance Analysis Tools

```bash
# CPU profiling
go test -cpuprofile=cpu.prof -bench=.
go tool pprof cpu.prof

# Memory profiling
go test -memprofile=mem.prof -bench=.
go tool pprof mem.prof

# Test coverage
go test -cover ./...
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out -o coverage.html
```
