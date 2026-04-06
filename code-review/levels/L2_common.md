# Level 2: Common — Daily Development Rules

> **When to read**: Normal feature development (writing a service, handler, component)
> **Extends**: Level 1 rules, adds daily development specifics
> **Scope**: Naming, Error Handling, Database, Logging, Comments, Guard Clauses

---

## 1. Naming Conventions

### 1.1 Basic Naming Rules

> **[@CoT-required]**: When reviewing naming conventions, execute Review Process Step 1-3 before giving conclusions.

- **Internal interface data**: Use camelCase
- **External system integration**: Use field names as-is from external system
- **Comments**: Use English, follow Google conventions
- **Package names**: lowercase, avoid underscores
- **Function names**: camelCase, start with verb

### 1.2 Meaningful Names

```go
// ❌ Bad: Vague
var d int
const max = 100
x := getUser()

// ✅ Good: Descriptive
var duration int
const MaxConnections = 100
activeUser := getUser()
```

### 1.3 Interface Naming

Use verb + -er suffix:

```go
// ❌ Bad
type I interface { ... }
type UserInterface interface { ... }

// ✅ Good
type Reader interface { Read(p []byte) (n int, err error) }
type UserRepository interface {
    FindByID(id string) (*User, error)
    Save(user *User) error
}
```

### 1.4 Avoid Misleading Names

```go
// ❌ Bad
var userList map[string]*User  // It's a map, not a list
var accountData *Account        // "Data" is meaningless

// ✅ Good
var userMap map[string]*User
var account *Account
```

### 1.5 Consistent Terminology

```go
// ❌ Bad: Mixed
func fetchUser() { ... }
func getUserData() { ... }

// ✅ Good: Unified
func GetUser() { ... }
func GetUserData() { ... }
```

---

## 2. Error Handling

### 2.1 Zero-Value Pattern

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

### 2.2 Error Wrapping

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

### 2.3 Custom Error Types

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

### 2.4 No Redundant Nil Checks

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

---

## 3. Database Standards (GORM)

### 3.1 Field Tags

> **[@CoT-required]**: When reviewing database standards, execute Review Process Step 1-3 before giving conclusions.

- Every field must have explicit `gorm:"column:field_name"`
- Never use `index` or `uniqueIndex` tags
- Database fields use `snake_case`

### 3.2 DDL Principles

- Write DDL explicitly, never use `AutoMigrate`
- All fields must have `NOT NULL` constraint
- Never check `IS NULL` / `IS NOT NULL` in code

### 3.3 Update Operations

Use struct model, not `map[string]interface{}`:

```go
// ❌ Bad
db.Model(&user).Updates(map[string]interface{}{
    "name": "new name",
})

// ✅ Good: Type-safe, IDE support
db.Model(&user).Updates(&User{Name: "new name"})
```

### 3.4 CRUD Operations

- **Create**: `db.Create()`
- **Update**: `db.Save()`, `db.Updates()`
- **Delete**: `db.Delete()`
- **Query**: Use gorm methods, not raw SQL

Raw SQL allowed only for:
- Complex queries gorm cannot express
- DDL operations (`CREATE TABLE`, `ALTER TABLE`)

---

## 4. Logging Standards

### 4.1 Logger Usage

> **[@CoT-required]**: When reviewing logging standards, execute Review Process Step 1-3 before giving conclusions.

Use wrapped logger instance. NEVER use raw `fmt.Println` or `log.Println`.

```go
// ✅ Good
logger.InfoW("user_created",
    "user_id", user.ID,
    "action", "create",
)
logger.DebugW("request_body", "body", string(data))
logger.ErrorW("db_error", "err", err)

// ❌ Bad
fmt.Println("user created")  // Never
log.Printf("error: %v", err)  // Never
```

### 4.2 Structured Logging Keys

Log keys MUST use camelCase:

```go
// ✅ Good
logger.InfoW("order_processed",
    "order_id", order.ID,
    "user_id", order.UserID,
    "total_amount", order.Total,
)

// ❌ Bad: snake_case keys
logger.InfoW("order_processed",
    "order_id", order.ID,  // Still camelCase
    "user_id", order.ID,
)
```

### 4.3 Security

Do not print sensitive fields: tokens, access keys, secret keys, passwords.

### 4.4 Log Levels

Use appropriately:
- **Info**: Normal operations
- **Warn**: Recoverable issues
- **Error**: Failures needing attention
- **Debug**: Detailed debugging (not in production)

---

## 5. Timestamp Handling

- **Database storage**: int64 (UnixMilli)
- **Frontend-backend transmission**: int64
- **Frontend display**: Convert to local time, format as `YYYY-MM-DD HH:mm:ss`

---

## 6. Comments

### 6.1 Core Principles

> **[@CoT-required]**: When reviewing comments, execute Review Process Step 1-3 before giving conclusions.

- Comments are a remedy, not a default
- Code should express intent; comments explain **why**, not **what**
- Keep comments updated with code changes
- No outdated or misleading comments

### 6.2 Good Comments

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

### 6.3 Bad Comments

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

### 6.4 Function Documentation

Public functions must have documentation comments:

```go
// CreateUser creates a new user and saves to database.
// name cannot be empty, email must be valid format.
// Returns created user object or error.
func CreateUser(name, email string) (*User, error) { ... }
```

---

## 7. Guard Clauses

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

---

## 8. Code Formatting

### 8.1 Vertical Formatting

> **[@CoT-required]**: When reviewing code formatting, execute Review Process Step 1-3 before giving conclusions.

Top-down: high-level logic first, private helpers last:

```go
// Public methods first
func (h *Handler) HandleGetUser(w http.ResponseWriter, r *http.Request) {
    userID := r.URL.Query().Get("id")
    user, err := h.service.GetUser(userID)
    if err != nil {
        respondError(w, err)
        return
    }
    respondJSON(w, user)
}

// Private helpers last
func respondJSON(w http.ResponseWriter, data interface{}) { ... }
func respondError(w http.ResponseWriter, err error) { ... }
```

### 8.2 Horizontal Formatting

```go
// ❌ Bad: Too long
if user != nil && user.IsActive && user.HasPermission("admin") && time.Now().Before(user.ExpiryTime) {
    // ...
}

// ✅ Good: Line breaks
if user != nil &&
    user.IsActive &&
    user.HasPermission("admin") &&
    time.Now().Before(user.ExpiryTime) {
    // ...
}

// ✅ Good: Extracted conditions
isValidUser := user != nil && user.IsActive
hasPermission := user.HasPermission("admin")
isNotExpired := time.Now().Before(user.ExpiryTime)

if isValidUser && hasPermission && isNotExpired {
    // ...
}
```

### 8.3 Tools

```bash
gofmt -w .       # Format code
goimports -w .   # Format + organize imports
go vet ./...     # Static analysis
revive ./...     # Linting
```

---

## 9. Test Synchronization

### 9.1 Sync with Code Changes

> **[@CoT-required]**: When reviewing test synchronization, execute Review Process Step 1-3 before giving conclusions.

- When modifying code, update tests simultaneously
- New features require test cases before merge
- Bug fixes must include regression tests
- Refactored code must update existing tests

### 9.2 Test Naming

Use table-driven tests:

```go
func TestCreateUser(t *testing.T) {
    tests := []struct {
        name    string
        input   CreateUserRequest
        want    *User
        wantErr error
    }{
        {
            name: "valid user",
            input: CreateUserRequest{Name: "Alice", Email: "alice@example.com"},
            want:    &User{Name: "Alice", Email: "alice@example.com"},
            wantErr: nil,
        },
        {
            name:    "empty name",
            input:   CreateUserRequest{Name: "", Email: "bob@example.com"},
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

### 9.3 Test Directory Structure

```
backend/
├── internal/
│   ├── domain/
│   │   ├── user.go
│   │   └── user_test.go          # Unit tests next to code
│   └── service/
│       ├── user_service.go
│       └── user_service_test.go
└── tests/
    ├── integration/              # Multi-layer tests
    └── e2e/                      # Full API flow tests
testdata/                        # Test fixtures (Go convention)
```

### 9.4 Test Principles

- **Fast**: No external I/O
- **Independent**: Tests don't depend on each other
- **Repeatable**: Same result every time
- **Self-Validating**: Clear pass/fail

### 9.5 Coverage Requirements

> **[@CoT-required]**: When reviewing test coverage, execute Review Process Step 1-3 before giving conclusions.

#### Coverage Thresholds

| Test Type | Minimum | Target | Description |
|-----------|---------|--------|-------------|
| **Unit Tests** | 70% | 80% | Individual functions/methods |
| **Integration Tests** | 50% | 60% | Multi-component interactions |
| **E2E Tests** | 30% | 40% | Full user workflows |

#### Coverage by Code Type

| Code Type | Unit Coverage | Integration Coverage |
|-----------|---------------|----------------------|
| Core business logic | 80%+ | 60%+ |
| Service layer | 70%+ | 50%+ |
| Handler/Controller | 60%+ | 40%+ |
| Utility functions | 85%+ | N/A |
| Repository/DAO | 50%+ | 70%+ |

#### Coverage Rules

```go
// ❌ Bad: 100% coverage but meaningless test
func Add(a, b int) int { return a + b }

func TestAdd(t *testing.T) {
    Add(1, 1)  // No assertion, coverage is 100% but test is useless
}

// ✅ Good: Meaningful test with assertions
func TestAdd(t *testing.T) {
    tests := []struct {
        name     string
        a, b     int
        expected int
    }{
        {"positive", 1, 2, 3},
        {"zero", 0, 0, 0},
        {"negative", -1, 1, 0},
        {"overflow boundary", math.MaxInt, 1, math.MinInt}, // Edge case
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            if got := Add(tt.a, tt.b); got != tt.expected {
                t.Errorf("Add(%d, %d) = %d, want %d", tt.a, tt.b, got, tt.expected)
            }
        })
    }
}
```

#### Go Coverage Commands

```bash
# Generate coverage report
go test -coverprofile=coverage.out ./...

# View coverage by function
go tool cover -func=coverage.out

# View coverage in browser
go tool cover -html=coverage.out

# Check threshold (fail if < 70%)
go test -coverprofile=coverage.out ./... && \
go tool cover -func=coverage.out | grep total | \
awk '{if (gsub("%", "") && $3 < 70) {print "Coverage below 70%: " $3; exit 1}}'
```

#### CI Integration

```yaml
# .github/workflows/test.yml
- name: Run tests with coverage
  run: |
    go test -coverprofile=coverage.out ./...
    
- name: Check coverage threshold
  run: |
    COVERAGE=$(go tool cover -func=coverage.out | grep total | awk '{print $3}' | sed 's/%//')
    echo "Total coverage: ${COVERAGE}%"
    if [ $(echo "$COVERAGE < 70" | bc) -eq 1 ]; then
      echo "::error::Coverage ${COVERAGE}% is below 70% threshold"
      exit 1
    fi
```

#### Frontend Coverage (Jest/Vitest)

```bash
# Run with coverage
npm test -- --coverage --coverageThreshold='{"global":{"lines":70,"branches":60,"functions":70,"statements":70}}'

# vitest
vitest run --coverage
```

```json
// jest.config.js or package.json
{
  "jest": {
    "coverageThreshold": {
      "global": {
        "lines": 70,
        "branches": 60,
        "functions": 70,
        "statements": 70
      }
    }
  }
}
```

#### Coverage Anti-Patterns

```go
// ❌ Anti-pattern: Testing only happy path
func TestGetUser(t *testing.T) {
    user, _ := GetUser("valid-id")  // Ignoring error
    if user == nil {
        t.Error("user should not be nil")
    }
}

// ✅ Good: Test both success and failure paths
func TestGetUser(t *testing.T) {
    t.Run("success", func(t *testing.T) {
        user, err := GetUser("valid-id")
        if err != nil {
            t.Fatalf("unexpected error: %v", err)
        }
        if user == nil {
            t.Error("user should not be nil")
        }
    })

    t.Run("not found", func(t *testing.T) {
        _, err := GetUser("invalid-id")
        if !errors.Is(err, ErrUserNotFound) {
            t.Errorf("expected ErrUserNotFound, got %v", err)
        }
    })

    t.Run("empty id", func(t *testing.T) {
        _, err := GetUser("")
        if !errors.Is(err, ErrInvalidID) {
            t.Errorf("expected ErrInvalidID, got %v", err)
        }
    })
}
```

#### New vs Legacy Code

| Scenario | Requirement |
|----------|-------------|
| New code | Unit coverage ≥ 70% |
| Modified code | Coverage must not decrease |
| Bug fix | Regression test required, coverage ≥ 70% |
| Legacy code | Gradual improvement, new code follows new standards |

---

## 10. Eliminate Duplication

DRY: Don't Repeat Yourself

```go
// ❌ Bad: Duplicated logic
func ProcessUserOrder(u *User, order *Order) { ... }
func ProcessGuestOrder(g *Guest, order *Order) { ... }

// ✅ Good: Extracted
func ProcessOrder(customer Customer, order *Order) { ... }
```

---

## 11. API Field Alignment

Backend field definitions are authoritative:

```go
// ✅ Backend defines the contract
type UserResponse struct {
    UserID      int64  `json:"userId"`
    DisplayName string `json:"displayName"`
    CreatedAt   int64  `json:"createdAt"`
}

// Frontend MUST adapt to this contract
// ❌ Bad: Requesting backend change
// ✅ Good: Frontend aligns its types
```

---

## 12. Frontend Standards (Vue 3 + TypeScript)

### 12.1 No Business Logic, Pure Calculations Allowed

> **[@CoT-required]**: When reviewing frontend standards, execute Review Process Step 1-3 before giving conclusions.

Frontend must NOT contain business logic (rules, validation, complex data transformation).
Pure data calculations are allowed if data is already provided by backend
(e.g., expensive client-side computation to reduce server load).

**Business Logic = Rules/Decisions** (must stay in backend):
- "If VIP user, apply 10% discount"
- "If order > $100, free shipping"
- "Calculate tax based on user location"

**Pure Calculation = Math on Existing Data** (allowed in frontend):
- `items.reduce((sum, i) => sum + i.price * i.qty, 0)`
- Sorting a list by a field
- Filtering visible items

```typescript
// ❌ Bad: Business logic in frontend
const UserCard = ({ user, orders }) => {
  const discount = user.isVIP ? calculateVIPDiscount(orders) : 0;
  // Business rules belong in backend
};

// ✅ Good: Backend sends calculated values
const UserCard = ({ user, calculatedDiscount }) => {
  return <span>Discount: {calculatedDiscount}</span>;
};

// ✅ Good: Pure calculation on existing data
const OrderSummary = ({ items }) => {
  const subtotal = items.reduce((sum, i) => sum + i.price * i.qty, 0);
  // Math on existing data is fine
  return <span>Subtotal: {subtotal}</span>;
};
```

### 12.2 Data Display Standards

- **Timestamps**: Receive int64 from backend, format to local time
- **Numbers**: Use backend-provided formatted values, simple formatting only
- **Data Transformation**: Simple sorting/filtering allowed, complex aggregation prefers backend

### 12.3 Component Structure

- Vue 3 Composition API: Use `<script setup>` syntax
- TypeScript: All code must be strongly typed
- Props Validation: Define prop types explicitly
- Component Naming: PascalCase files

```typescript
// ✅ Good
<script setup lang="ts">
interface Props {
  userId: number;
  userName: string;
}

const props = defineProps<Props>();
</script>
```

### 12.4 State Management

- **Pinia**: Use for global state only
- **Local State**: Use `ref` and `reactive`
- **No Business Logic in Stores**: Stores manage UI state only

```typescript
// ✅ Good: Store for UI state only
export const useUserUIStore = defineStore('userUI', () => {
  const isLoading = ref(false);
  const errorMessage = ref<string | null>(null);
  return { isLoading, errorMessage };
});
```

### 12.5 API Integration

- Request Handling: Use centralized API modules
- Error Handling: Display user-friendly messages
- Loading States: Always show loading indicators

### 12.6 Code Quality Standards

- TypeScript strict mode enabled
- No `any` type — define proper types
- ESLint + Prettier for formatting

### 12.7 Guard Clauses

```typescript
// ✅ Good: Handle exceptions first
const UserProfile = ({ user }) => {
  if (!user) {
    return <EmptyState message="No user data" />;
  }
  return <div>{user.name}</div>;
};
```

### 12.8 Test Synchronization

- New components require test cases
- Bug fixes include regression tests
- Update tests when props/events change

```typescript
// ✅ Good: Component test
import { mount } from '@vue/test-utils';
import UserCard from '../UserCard.vue';

describe('UserCard', () => {
  it('displays user name', () => {
    const wrapper = mount(UserCard, {
      props: { userName: 'Alice' },
    });
    expect(wrapper.text()).toContain('Alice');
  });
});
```

### 12.9 Test Directory Structure

```
frontend/
├── src/
│   ├── components/
│   │   ├── UserCard.vue
│   │   └── __tests__/
│   │       └── UserCard.test.ts
│   ├── views/
│   │   └── __tests__/
│   │       └── Dashboard.test.ts
│   └── stores/
│       └── __tests__/
│           └── user.test.ts
└── tests/
    ├── integration/
    └── e2e/
```

### 12.10 Naming Conventions

- Component files: PascalCase (e.g., `UserCard.vue`)
- Event names: kebab-case
- CSS classes: kebab-case
- Store files: camelCase or kebab-case (e.g., `userStore.ts`)

### 12.11 Responsive Design

Support both desktop and mobile layouts. Use CSS media queries or utility classes.

```vue
<!-- ✅ Good: Responsive layout -->
<template>
  <div class="user-card">
    <div class="user-card__desktop">{{ user.name }}</div>
    <div class="user-card__mobile">{{ user.name }}</div>
  </div>
</template>

<style scoped>
.user-card__desktop { display: block; }
.user-card__mobile { display: none; }

@media (max-width: 768px) {
  .user-card__desktop { display: none; }
  .user-card__mobile { display: block; }
}
</style>
```

### 12.12 UI/UX Standards

- **Loading States**: Show loading indicators for async operations
- **Error States**: Handle and display errors gracefully
- **Empty States**: Show appropriate messages when no data available
- **Accessibility**: Follow WCAG guidelines

```vue
<!-- ✅ Good: Complete state handling -->
<template>
  <div class="user-profile">
    <div v-if="isLoading" class="loading-spinner" />
    <div v-else-if="error" class="error-message">{{ error }}</div>
    <div v-else-if="!user" class="empty-state">No user found</div>
    <div v-else class="user-content">{{ user.name }}</div>
  </div>
</template>
```
