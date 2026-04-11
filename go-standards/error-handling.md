# Error Handling

## 1. Errors as Return Values [@CoT-required]

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

## 2. Use errors.Is() for Error Comparison [@CoT-required]

Never use `==` to compare errors. Use `errors.Is()` or `errors.As()`.

```go
// ❌ Bad
if err == ErrNotFound { ... }

// ✅ Good
if errors.Is(err, ErrNotFound) { ... }
if errors.As(err, &validationErr) { ... }
```

## 3. Zero-Value Pattern

> **[@CoT-required]**: When reviewing error handling, execute Review Process Step 1-3 before giving conclusions.

When a function returns (value, error) and error is not nil, other returns must be zero values:

```go
// ✅ Good
func GetUser(id uint) (*User, error) {
    var user User
    if err := db.First(&user, id).Error; err != nil {
        return nil, err
    }
    return &user, nil
}

// ✅ Good: All returns zero when error
func GetUserInfo(id uint) (string, int, error) {
    var user User
    if err := db.First(&user, id).Error; err != nil {
        return "", 0, err
    }
    return user.Name, user.Age, nil
}
```

## 4. Error Wrapping

```go
// ❌ Bad: Lost context
func ProcessPayment(orderID string) error {
    order, err := GetOrder(orderID)
    if err != nil {
        return err
    }
    // ...
}

// ✅ Good: Wrapped context
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

## 5. Custom Error Types

```go
type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation error: %s - %s", e.Field, e.Message)
}

err := ValidateUser(user)
var validationErr *ValidationError
if errors.As(err, &validationErr) {
    // Handle validation error
}
```

## 6. No Redundant Nil Checks

> **[@CoT-required]**: Before writing a `!= nil` or `== nil` check on a pointer, trace the pointer's origin to determine if it can actually be nil. If the source makes it impossible to be nil, the check is redundant and must not be written.

**CoT Analysis Steps:**
1. **Origin**: Where did this pointer come from? (constructor, DI container, global, function return)
2. **Guarantee**: Can the origin guarantee non-nil (for `!=`) or already-handled-nil (for `==`)? (initialized at startup, constructor sets it, function already returns on nil, etc.)
3. **Decision**: If the check is guaranteed unnecessary by origin → remove it. If uncertain → keep the check.

```go
// ❌ Bad: Redundant != nil check — config is initialized at startup
func (s *Service) Start() error {
    if s.config != nil {  // s.config set in NewService, never nil
        return s.config.Validate()
    }
    return nil
}

// ✅ Good: No redundant check — config guaranteed non-nil
func (s *Service) Start() error {
    return s.config.Validate()  // config is never nil
}

// ❌ Bad: Redundant != nil check — logger injected at construction
type Handler struct {
    logger *Logger  // Set in NewHandler, always non-nil
}

func (h *Handler) Handle() {
    if h.logger != nil {  // Redundant — logger is never nil after construction
        h.logger.Info("handling")
    }
}

// ✅ Good: No redundant check needed
func (h *Handler) Handle() {
    h.logger.Info("handling")  // logger is guaranteed non-nil
}

// ❌ Bad: Redundant == nil check — error already indicates nil
func GetUser(id string) (*User, error) {
    user, err := db.Find(id)
    if user == nil {  // Redundant — if err != nil, user is nil by zero value
        return nil, ErrUserNotFound
    }
    return user, nil
}

// ✅ Good: Check error, not the value
func GetUser(id string) (*User, error) {
    user, err := db.Find(id)
    if err != nil {
        return nil, ErrUserNotFound
    }
    return user, nil
}

// ❌ Bad: Redundant == nil check — already nil-checked earlier
func Process(user *User) error {
    if user == nil {
        return ErrUserNil
    }
    if user.Profile == nil {  // Redundant — user.Profile cannot be nil here
        return ErrProfileNil
    }
    return nil
}

// ✅ Good: Remove the redundant second check
func Process(user *User) error {
    if user == nil {
        return ErrUserNil
    }
    return nil
}
```

**Key insight**: Both `!= nil` and `== nil` can be redundant. `!= nil` is redundant when the pointer is guaranteed non-nil (DI, startup init). `== nil` is redundant when the error already captures the nil case, or when a prior check already established the pointer is non-nil. Only check nil when the origin makes nil possible.

## 7. Error Must Not Be Ignored

> **[@CoT-required]**: When reviewing error handling, execute Review Process Step 1-3 before giving conclusions.

Every `error` returned by a function call must be explicitly handled. No exceptions.

**Allowed handling patterns (choose one):**

1. **Propagate** — return to caller
   ```go
   if err := db.Create(&user).Error; err != nil {
       return fmt.Errorf("create user: %w", err)
   }
   ```

2. **Log and continue** — if the error is non-fatal and the operation can reasonably continue
   ```go
   if err := metric.Record(m); err != nil {
       logger.Warn("failed to record metric", "error", err)
   }
   ```

3. **Wrap with context** — `fmt.Errorf` with `%w` when returning to caller
   ```go
   return fmt.Errorf("process order %s: %w", orderID, err)
   ```

**Forbidden patterns:**

```go
// ❌ Forbidden: Ignored error via _
_ = os.WriteFile("cfg.json", data, 0644)

// ❌ Forbidden: Empty if statement
if err != nil {
}

// ❌ Forbidden: Commented-out handling
// if err != nil {
//     return err
// }
```

## 8. Complex State Determination Protocol (Mandatory for Dynamic State Questions)

When encountering state questions like "could `ws.handler` be nil after connection is established", you MUST execute the following instead of asking the user:

1. **Trace to constructor**: Use tools to read the struct's initialization function (e.g., `NewXXX()`) and confirm initial assignment.
2. **Global scan for modification points**: Use regex search to find all assignments to that field (e.g., `ws.handler =`), especially nil assignments (`= nil`).
3. **Guilty until proven innocent**: If no clear nil assignment is found in steps 1-2, conclude "lifecycle-immutable, marked as redundant". Do not assume "there may be external black-box modifications".

**Invalid output (never produce):**
- ❌ "Pending verification: depends on whether handler guarantees non-nil throughout the connection lifecycle..."
- ❌ "Could you confirm if ws.handler becomes nil after connection is established?"

**Valid output (must produce):**
- ✅ "【State Tracking】Traced to `NewHTTPClient()` — req initialized and body set once. Global search found no `req.body = nil` reset in handler. Applying guilty-until-proven-innocent principle, marking the nil check in handler.go:42 as 【Redundant】."
- ✅ "【State Tracking】Traced to `net.Conn` — interface type, cannot guarantee non-nil. Cannot apply redundant-check rule. Kept as-is."
