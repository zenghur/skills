# Code Examples and Common Errors

This document provides comprehensive code examples demonstrating correct and incorrect patterns for all coding standards.

## 1. Logging Examples

### Structured Logging (REQUIRED)

The project uses structured logging with key-value pairs. Always use `Infow`, `Warnw`, `Errorw`, `Debugw` methods.

#### Correct Structured Logging
```go
// Correct: Use key-value pairs with snake_case keys
logger.G().Infow("Order executed", 
    "symbol", order.Symbol,
    "side", order.Side,
    "price", order.Price,
    "quantity", order.Quantity,
)

// Correct: Error logging with context
logger.G().Errorw("Failed to process order",
    "order_id", order.ID,
    "symbol", order.Symbol,
    "error", err,
)

// Correct: Simple message without values
logger.G().Infow("WebSocket connected")

// Correct: Duration and timing
logger.G().Infow("Cycle completed", "duration", time.Since(start))
e.logger.Infow("Position closed", "symbol", symbol, "pnl", pnl, "reason", reason)
```

#### Incorrect Structured Logging (DO NOT DO THIS)
```go
// WRONG: Using formatted strings in log messages
logger.G().Infow("Order executed: %s %s @ %.2f", order.Symbol, order.Side, order.Price)

// WRONG: String concatenation
logger.G().Infow("Position closed: " + symbol + " PnL: " + fmt.Sprintf("%.2f", pnl))

// WRONG: Using fmt.Sprintf
logger.G().Errorw(fmt.Sprintf("Failed to process order %s: %v", order.ID, err))

// WRONG: Not using snake_case for keys
logger.G().Infow("Order executed", "orderID", order.ID, "orderSymbol", order.Symbol)

// WRONG: Using old format methods (these methods no longer exist)
logger.G().Infof("Order executed: %s", order.Symbol)  // Method removed!
logger.G().Info("WebSocket connected")                // Method removed!
```

### Security in Logging
```go
// Correct: Use English, do not print sensitive information
logger.G().Infow("User authenticated", "user_id", user.ID)
logger.G().Warnw("Database connection timeout", "attempt", retryCount)
logger.G().Errorw("Failed to process order", "order_id", order.ID, "error", err)

// Incorrect: Printing sensitive information
logger.G().Infow("API key loaded", "api_key", apiKey) // Prohibited!
logger.G().Infow("User credentials", "password", password) // Prohibited!
```

### Key Naming Reference Table
| Context | Correct Key | Incorrect Key |
|---------|-------------|---------------|
| Order ID | `order_id` | `orderId`, `OrderID` |
| User ID | `user_id` | `userId`, `UserID` |
| Symbol | `symbol` | `Symbol` |
| Price | `price` | `Price` |
| Error | `error` | `err`, `Error` |
| Duration | `duration` | `Duration`, `dur` |
| Quantity | `quantity` | `qty`, `Quantity` |
| Status | `status` | `Status` |
| Balance | `balance` | `Balance` |
| PnL | `pnl` | `PnL`, `profit_loss` |

## 2. Timestamp Handling Examples

### Correct Timestamp Processing
```go
// Database model
type TradeModel struct {
    ID        uint   `gorm:"primaryKey"`
    CreatedAt int64  `gorm:"not null"` // int64 timestamp
}

// API response
func (h *Handler) GetTrade(c *gin.Context) {
    trade := &dto.Trade{
        ID:        tradeModel.ID,
        CreatedAt: tradeModel.CreatedAt, // Return int64 timestamp
    }
    response.Success(c, trade)
}
```

## 3. DDD Layering Examples

### Correct DDD Layer Structure
```go
// Domain layer (does not depend on infrastructure)
type Order struct {
    ID    string
    Price float64
    // Business logic methods
}

// Application layer (coordinates domain objects)
type OrderService struct {
    orderRepo OrderRepository
}

// Infrastructure layer (implements interfaces)
type OrderRepositoryImpl struct {
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
