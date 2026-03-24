# Code Examples and Common Errors

This document provides comprehensive code examples demonstrating correct and incorrect patterns for all coding standards.

## 1. Logging Examples

### Structured Logging (REQUIRED)

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

### Security in Logging
```go
// Correct: Use English, do not print sensitive information
logger.G().InfoW("User authenticated", "userID", user.ID)
logger.G().WarnW("Database connection timeout", "attempt", retryCount)
logger.G().ErrorW("Failed to process request", "apiPath", r.URL.Path, "error", err)

// Incorrect: Printing sensitive information
logger.G().InfoW("API key loaded", "apiKey", apiKey) // Prohibited!
logger.G().InfoW("User credentials", "password", password) // Prohibited!
```

### Key Naming Reference Table (Go/revive Conventions)

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

## 2. Timestamp Handling Examples

### Correct Timestamp Processing
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
```

## 3. DDD Layering Examples

### Correct DDD Layer Structure
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

## 4. Eliminating Duplicate Code Examples

### Duplicate Code Elimination
```go
// Incorrect: Duplicate validation logic
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

// Correct: Extract common validation function
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

## 5. Avoiding Magic Values Examples

### Magic Values Elimination
```go
// Incorrect: Using magic numbers and magic strings
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

// Correct: Use meaningful constants
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

## Common Error Patterns

### Error 1: Directly Printing Sensitive Information
```go
// Incorrect
log.Infof("Using API key: %s", apiKey)

// Correct
log.Info("API configuration loaded successfully")
```

### Error 2: Inconsistent Time Format
```go
// Incorrect
type Trade struct {
    CreatedAt time.Time `json:"createdAt"` // Should not transmit time.Time
}

// Correct
type Trade struct {
    CreatedAt int64 `json:"createdAt"` // Use int64 timestamp
}
```

### Error 3: Violating DDD Dependency Rules
```go
// Incorrect: Domain layer depending on infrastructure
import "github.com/your-org/your-project/internal/infrastructure/persistence"

type Order struct {
    // Domain objects should not directly depend on infrastructure
}

// Correct: Depend through interfaces
type OrderRepository interface {
    Save(order *Order) error
}
```

### Error 4: Not Extracting Duplicate Code
```go
// Incorrect: Repeated error handling in multiple places
func ProcessOrderA() error {
    result, err := doSomething()
    if err != nil {
        return fmt.Errorf("process order A failed: %w", err)
    }
    return nil
}

func ProcessOrderB() error {
    result, err := doSomething()
    if err != nil {
        return fmt.Errorf("process order B failed: %w", err)
    }
    return nil
}

// Correct: Extract common processing logic
func processWithErrorHandling(operation string, fn func() error) error {
    if err := fn(); err != nil {
        return fmt.Errorf("%s failed: %w", operation, err)
    }
    return nil
}

func ProcessOrderA() error {
    return processWithErrorHandling("process order A", doSomething)
}

func ProcessOrderB() error {
    return processWithErrorHandling("process order B", doSomething)
}
```

### Error 5: Using Magic Numbers and Magic Strings
```go
// Incorrect: Hardcoded numbers and strings
func SetTimeout(duration int) {
    time.Sleep(time.Duration(duration) * time.Second)
}

func main() {
    SetTimeout(30) // Magic number 30, unclear meaning
    
    if role == "admin" { // Magic string "admin"
        // do something
    }
    
    limit := 100 // Magic number 100
    for i := 0; i < limit; i++ {
        // ...
    }
}

// Correct: Use meaningful constants
const (
    DefaultTimeoutSeconds = 30
    MaxRetryAttempts      = 100
    RoleAdmin            = "admin"
    RoleUser             = "user"
)

func SetTimeout(duration int) {
    time.Sleep(time.Duration(duration) * time.Second)
}

func main() {
    SetTimeout(DefaultTimeoutSeconds) // Clear and understandable
    
    if role == RoleAdmin { // Use constant
        // do something
    }
    
    for i := 0; i < MaxRetryAttempts; i++ {
        // ...
    }
}
```

## Database Field Standards Examples

### Correct GORM Tag Usage
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

## 6. Error Handling Examples

### Correct Error Handling with Multiple Return Values
```go
// Correct: Return zero values when error is not nil
func GetUser(id uint) (*User, error) {
    var user User
    if err := db.First(&user, id).Error; err != nil {
        return nil, err  // Return nil (zero value for pointer) when error
    }
    return &user, nil  // Return valid value when no error
}

// Correct: Return zero values for all non-error returns
func GetUserInfo(id uint) (string, int, error) {
    var user User
    if err := db.First(&user, id).Error; err != nil {
        return "", 0, err  // Return "" and 0 (zero values) when error
    }
    return user.Name, user.Age, nil  // Return valid values when no error
}

// Incorrect: Returning non-zero value with error
func GetUserWrong(id uint) (*User, error) {
    var user User
    if err := db.First(&user, id).Error; err != nil {
        return &User{Name: "default"}, err  // WRONG! Should return nil
    }
    return &user, nil
}

// Incorrect: Returning nil when no error
func GetUserWrong2(id uint) (*User, error) {
    var user User
    if err := db.First(&user, id).Error; err != nil {
        return nil, err
    }
    return nil, nil  // WRONG! Should return valid user
}
```

### Common Error Patterns with Multiple Returns
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

## IDE Configuration and Tool Support

### IDE Configuration
- Enable Go language linting tools
- Configure automatic formatting (gofmt)
- Set up code review rules
- Install revive linter: `go install github.com/mgechev/revive@latest`

### Pre-commit Checks
- Add pre-commit hook to check standards
- Use static analysis tools to check code quality
- Run unit tests to ensure functionality correctness
- Run `revive ./...` to check code style

## 7. Refactoring Examples

### Before Refactoring: Feature Inventory (REQUIRED)

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

### Correct Refactoring Process

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

### Incorrect Refactoring (FEATURE LOSS)

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

### Post-Refactoring Verification Checklist

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

### Hidden Features to Watch For

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
