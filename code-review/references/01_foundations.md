# Foundations: The Philosophy Behind the Standards

> "The laws of physics are thin gruel for the growing child of the spirit."
> — Eric S. Raymond, The Art of Unix Programming

> **Note**: This is **supplementary reading** for deeper understanding.
> For quick reference and LLM usage, see `02_guidelines.md`.

This document traces the philosophical foundations of our coding standards back to five seminal works.
Understanding *why* these rules exist transforms them from arbitrary conventions into guiding principles.

---

## The Five Pillars

| Book | Core Theme | Primary Application |
|------|------------|---------------------|
| **Clean Code** (Robert C. Martin) | Craftsmanship, readable code | Naming, functions, comments, SOLID |
| **The Pragmatic Programmer** (Hunt & Thomas) | Professional thinking | DRY, orthogonality, minimalism, testing philosophy |
| **Refactoring** (Martin Fowler) | Improving structure | Code smells, refactoring patterns, test-first |
| **Domain-Driven Design** (Eric Evans) | Model complexity | Architecture, bounded contexts, value objects, aggregates |
| **The Art of Unix Programming** (Eric S. Raymond) | Clarity, simplicity | Transparency, composition, Rule of Clarity |

---

## Part I: Clean Code — The Art of Writing Code Others Can Maintain

*Robert C. Martin, 2008*

---

### 1. Meaningful Names — Names Reveal Intent

The single most important skill in programming is choosing good names.
Names appear everywhere: variables, functions, classes, packages, files, databases.
Every name is an opportunity to communicate intent.

#### 1.1 Use Intent-Revealing Names

A name should answer three questions:
- **Why it exists** (what problem does it solve?)
- **What it does** (how is it used?)
- **How it is used** (what are the constraints?)

```go
// ❌ Bad: Names reveal nothing
var d int
var data map[string]interface{}
func getUser() { ... }
const max = 100

// ✅ Good: Names are self-documenting
var elapsedTimeInSeconds int
var userProfiles map[string]*User
func GetUserByID(userID string) (*User, error)
const MaxConnectionsPerHost = 100
```

**Why this matters**: Code is read far more often than it is written.
When you return to code six months later, meaningful names jog your memory.
When a colleague reads your code, meaningful names reduce questions.

#### 1.2 Avoid Disinformation

Names should not lie. A name that means one thing in one context should not mean something else elsewhere.

```go
// ❌ Bad: Misleading name
var userList map[string]*User  // It's a map, not a list. List implies ordered collection.

var accountData *Account  // "Data" is meaningless. What kind of data?

func GetUsers() *User  // Returns single user, not multiple.

// ✅ Good: Accurate description
var userMap map[string]*User
var account *Account
func GetUserByID(id string) (*User, error)
```

**Principle from Clean Code**: "Avoid words whose meaning varies from our intent."
Names should mean exactly what they say, nothing more, nothing less.

#### 1.3 Make Meaningful Distinctions

Don't use names that differ only in ways that are not meaningful.

```go
// ❌ Bad: Distinction without meaning
func CopyCharacters(charArray1 []rune, charArray2 []rune) { ... }
// The names charArray1 and charArray2 are meaningless distinctions

// ❌ Bad: Noise words that add nothing
var userInfo *UserInfo        // "Info" is noise
var accountData *AccountData  // "Data" is noise
func UserHelper() { ... }     // "Helper" is noise

// ✅ Good: Distinctive, meaningful names
func CopyCharacters(source []rune, destination []rune) { ... }
var user *User
var account *Account
```

#### 1.4 Use Pronounceable and Searchable Names

```go
// ❌ Bad: Unpronounceable, hard to search
type DtaRcrd102 struct {
    Genymdhms time.Time  // "Generation Year Month Day Hour Minute Second"
    Modymdhms time.Time
    PszIntstID string
}

// ✅ Good: Pronounceable, searchable
type TransactionRecord struct {
    CreatedAt time.Time
    ModifiedAt time.Time
    MerchantID string
}
```

**Why this matters**: You'll say "D-T-A-R-C-R-D-one-oh-two" in meetings.
You'll search for "Genymdhms" when debugging at 2am. Don't do that to yourself.

#### 1.5 Go/golangci-lint Conventions for Abbreviations

The code review guidelines specify these naming conventions:

- **Interface data**: camelCase (e.g., `userID`, `sessionID`, `orderID`)
- **Abbreviations in camelCase**: Keep them uppercase when internal (e.g., `userID`, not `userId`)
- **Package names**: lowercase, no underscores, short
- **Function names**: camelCase, start with a verb

```go
// ✅ Correct: ID and URL stay uppercase in camelCase
userID string      // ✓
sessionID string    // ✓
apiKey string       // ✓
httpRequest *http.Request  // ✓
httpResponse *http.Response  // ✓

// ❌ Incorrect: Lowercasing abbreviations
userId string      // ✗
sessionId string   // ✗
ApiKey string      // ✗ (exported but using wrong casing)
```

#### 1.6 Avoid Mental Mapping

Readers shouldn't have to translate names in their heads.
If a name requires explanation, it's a bad name.

```go
// ❌ Bad: Requires mental mapping
// Reader thinks: "What does r mean? What about c?"
for r := 0; r < len(rows); r++ {
    for c := 0; c < len(cols); c++ {
        matrix[r][c] = 0
    }
}

// ✅ Good: Self-explanatory
for row := 0; row < len(rows); row++ {
    for col := 0; col < len(cols); col++ {
        matrix[row][col] = 0
    }
}
```

**Clean Code principle**: "Clarity is king. Write code for others to read."

---

### 2. Functions — The Building Blocks of Programs

Functions are the first line of organization in any program.
They are where your logic lives. Bad functions create bad programs.

#### 2.1 The First Rule: Keep Them Small

Functions should be small. Very small.

> "Functions should do one thing. They should do it well. They should do it only."
> — Robert C. Martin

**How small is small?**
- Clean Code suggests 20 lines maximum
- Some advocate for 5-10 lines
- The standard we follow: aim for under 20 lines, use judgment

```go
// ❌ Bad: 50+ lines, doing multiple things
func ProcessOrder(order *Order) error {
    // Validation (thing 1)
    if order == nil {
        return errors.New("order is nil")
    }
    if order.UserID == "" {
        return errors.New("user ID required")
    }
    if len(order.Items) == 0 {
        return errors.New("order has no items")
    }

    // Calculation (thing 2)
    var total float64
    for _, item := range order.Items {
        total += item.Price * float64(item.Quantity)
    }
    if order.Discount > 0 {
        total = total * (1 - order.Discount)
    }
    if total < 0 {
        total = 0
    }

    // Persistence (thing 3)
    order.TotalAmount = total
    order.Status = StatusPending
    if err := db.Save(order).Error; err != nil {
        return err
    }

    // Notification (thing 4)
    if err := SendOrderConfirmation(order); err != nil {
        log.Printf("failed to send confirmation: %v", err)  // Ignored error!
    }

    // Audit (thing 5)
    if err := WriteAuditLog("order_processed", order.ID); err != nil {
        return err
    }

    return nil
}

// ✅ Good: Each function does one thing
func ProcessOrder(order *Order) error {
    if err := validateOrder(order); err != nil {
        return fmt.Errorf("validate order: %w", err)
    }

    total := calculateTotal(order.Items)
    total = applyDiscount(total, order.Discount)

    if err := updateOrderAmount(order, total); err != nil {
        return fmt.Errorf("update amount: %w", err)
    }

    if err := persistOrder(order); err != nil {
        return fmt.Errorf("persist: %w", err)
    }

    return nil
}
```

#### 2.2 Do One Thing — Levels of Abstraction

A function should contain statements at the same level of abstraction.
Mixing high-level and low-level details in one function creates confusion.

```go
// ❌ Bad: Mixed levels of abstraction
func PayForOrder(order *Order) error {
    // High-level: what we're trying to do
    if !order.IsPaid {
        // Low-level: HOW we validate payment
        cc := order.CreditCard
        if cc == nil {
            return errors.New("no credit card")
        }
        if cc.Expiry.Before(time.Now()) {
            return errors.New("card expired")
        }
        if cc.Number == "" {
            return errors.New("invalid card number")
        }

        // Back to high-level
        err := paymentGateway.Charge(cc, order.Total)
        if err != nil {
            return fmt.Errorf("charge failed: %w", err)
        }

        order.IsPaid = true
    }
    return nil
}

// ✅ Good: Separate levels
func PayForOrder(order *Order) error {
    if order.IsPaid {
        return nil  // Already paid, nothing to do
    }

    if err := validatePaymentMethod(order.CreditCard); err != nil {
        return fmt.Errorf("validate payment: %w", err)
    }

    if err := chargePaymentGateway(order); err != nil {
        return fmt.Errorf("charge: %w", err)
    }

    order.MarkAsPaid()
    return nil
}
```

#### 2.3 The Stepdown Rule

Code should read like a newspaper: headlines first, details later.
Arrange functions so they read top-down, from high-level to low-level.

```go
// ✅ Good: Top-down organization
// This is how a reader should understand the code:
// 1. Read the top function to understand the high-level flow
// 2. Dig into any step for details

// READER START HERE: This function tells the whole story at one level
func OnboardNewCustomer(ctx context.Context, req *OnboardRequest) (*Customer, error) {
    if err := validateRequest(req); err != nil {
        return nil, fmt.Errorf("validation: %w", err)
    }

    customer, err := createCustomerRecord(ctx, req)
    if err != nil {
        return nil, fmt.Errorf("create customer: %w", err)
    }

    if err := initializeCustomerAccounts(ctx, customer); err != nil {
        return nil, fmt.Errorf("initialize accounts: %w", err)
    }

    if err := sendWelcomeCommunications(ctx, customer); err != nil {
        logger.G().WarnW("failed to send welcome", "customerID", customer.ID, "err", err)
        // Non-fatal: continue onboarding even if welcome fails
    }

    return customer, nil
}

// SUPPORTING FUNCTIONS: Readers drill down only if they want details
// All at one level of abstraction below the top function

func validateRequest(req *OnboardRequest) error {
    if req.Email == "" {
        return ErrEmailRequired
    }
    if !isValidEmailFormat(req.Email) {
        return ErrInvalidEmailFormat
    }
    if req.PlanID == "" {
        return ErrPlanRequired
    }
    return nil
}

func createCustomerRecord(ctx context.Context, req *OnboardRequest) (*Customer, error) {
    customer := NewCustomer(req.Email, req.Name)
    if err := customerRepo.Save(ctx, customer); err != nil {
        return nil, err
    }
    return customer, nil
}

func initializeCustomerAccounts(ctx context.Context, customer *Customer) error {
    // ...
    return nil
}

func sendWelcomeCommunications(ctx context.Context, customer *Customer) error {
    // ...
    return nil
}
```

#### 2.4 Function Arguments — Minimize Them

**Ideal**: 0-2 arguments
**Acceptable**: 3 arguments (with justification)
**Suspicious**: 4+ arguments (refactor with struct or configuration)

```go
// ❌ Bad: Too many arguments
func SendEmail(to, cc, bcc, subject, body, smtpHost, smtpPort, username, password string) error

// ✅ Good: Related arguments grouped into structs
type EmailMessage struct {
    To      string
    CC      string
    BCC     string
    Subject string
    Body    string
}

type SMTPConfig struct {
    Host     string
    Port     int
    Username string
    Password string
}

func SendEmail(msg *EmailMessage, cfg *SMTPConfig) error
```

**When you have many arguments, consider**:
1. If they're related, group into a struct
2. If some are optional, use functional options
3. If the function needs too much context, it may be doing too much

#### 2.5 No Side Effects — Predictable Behavior

A function should not hide modifications to state outside itself.

```go
// ❌ Bad: Hidden side effect
var globalState struct {
    requestCount int
    lastRequest  time.Time
}

func HandleRequest(req *Request) (*Response, error) {
    // Hidden: modifies global state
    globalState.requestCount++
    globalState.lastRequest = time.Now()

    return process(req), nil
}

// ✅ Good: Explicit about what changes
type RequestHandler struct {
    requestCount int
    lastRequest  time.Time
}

func (h *RequestHandler) HandleRequest(req *Request) (*Response, error) {
    h.requestCount++
    h.lastRequest = time.Now()
    return h.process(req), nil
}
```

#### 2.6 Separate Commands from Queries

Functions should either:
- **DO** something (command) — modify state, return error
- **ASK** something (query) — return information, no side effects

Not both.

```go
// ❌ Bad: Command and query mixed
func SetAndReturnUserAge(user *User, age int) (int, error) {
    if age < 0 || age > 150 {
        return 0, errors.New("invalid age")
    }
    user.Age = age
    return user.Age, nil  // Returning value AND modifying
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

func GetUserAge(user *User) int {
    return user.Age
}
```

#### 2.7 Prefer Errors Over Exceptions for Expected Conditions

```go
// ❌ Bad: Using exceptions for flow control
func FindUser(id string) *User {
    user := db.Find(id)
    if user == nil {
        throw UserNotFoundException  // Exception for expected condition!
    }
    return user
}

// ✅ Good: Error for expected condition
func FindUser(id string) (*User, error) {
    user := db.Find(id)
    if user == nil {
        return nil, ErrUserNotFound  // Expected, handled gracefully
    }
    return user, nil
}
```

---

### 3. Comments — The Enemy of Clean Code?

The relationship between comments and clean code is nuanced.

> "Comments are, at best, a necessary evil. If our programming languages were expressive enough, we would not need comments."
> — Robert C. Martin

**The truth**: Bad comments are worse than no comments. Good comments are rare and precious.

#### 3.1 Comments Do Not Make Up for Bad Code

```go
// ❌ Bad: Comment trying to explain confusing code
// This loop goes through the array and checks if each element
// is greater than the previous one. If so, it increments the counter.
for i := 1; i < len(arr); i++ {
    if arr[i] > arr[i-1] {
        count++
    }
}

// ✅ Good: Clean code needs no comment
increasingCount := countIncreasingSequences(arr)

// ✅ Or: If you must explain, use a comment that explains WHY
// Count increasing sequences: O(n²) worst case
// For sorted input, use binary search variant instead
for i := 1; i < len(arr); i++ {
    if arr[i] > arr[i-1] {
        count++
    }
}
```

#### 3.2 Good Comments — Explain Why, Not What

```go
// ✅ Good: Explains WHY (the non-obvious reasoning)
// Use binary search because the slice is guaranteed to be sorted by timestamp.
// Linear search would be O(n); binary search is O(log n).
func FindEventByTimestamp(events []Event, target time.Time) *Event {
    // implementation
}

// ✅ Good: TODO with context
// TODO(zheng): After profiling, consider caching frequent queries.
// See: github.com/org/project/issues/1234
func GetUserByEmail(email string) (*User, error)

// ✅ Good: Warning about limitations
// Note: This function is not thread-safe.
// Caller must ensure no concurrent access to the shared state.
func ParseWithSharedBuffer(buf []byte) (*Result, error)

// ✅ Good: Documentation for public API
// CreateUser creates a new user in the system with the provided details.
// The email must be unique; returns ErrEmailAlreadyExists if duplicate.
// The user is not active until ActivateUser is called.
func CreateUser(ctx context.Context, req *CreateUserRequest) (*User, error)
```

#### 3.3 Bad Comments — Avoid These

```go
// ❌ Bad: Redundant - states the obvious
// Increment counter by 1
counter++

// Returns the user name
func (u *User) GetName() string { return u.Name }

// Constructor
func NewUser() *User { return &User{} }

// ❌ Bad: Commented-out code (use git history!)
// func oldProcess() {
//     doSomething()
//     doSomethingElse()
// }

// ❌ Bad: Journal comments (use git!)
// 2023-03-16: Fixed null pointer
// 2023-03-17: Optimized performance
// 2023-03-18: Added new feature
func Process() { ... }

// ❌ Bad: Misleading comments
// Always returns true (comment lies!)
// Check if user is admin (doesn't check!)
func IsAdmin(user *User) bool {
    return user != nil  // Just checks for nil, not admin status!
}
```

---

### 4. Error Handling — Fail Fast, Fail Clearly

Error handling is one of the most important aspects of robust code.
It is not optional or secondary; it is fundamental.

#### 4.1 Return Errors, Don't Throw Exceptions

Go uses error returns, not exceptions. Respect this design.

```go
// ❌ Bad: Pretending Go has exceptions
func GetUser(id string) *User {
    user := db.Find(id)
    if user == nil {
        panic("user not found")  // Never do this!
    }
    return user
}

// ✅ Good: Explicit error return
func GetUser(id string) (*User, error) {
    user := db.Find(id)
    if user == nil {
        return nil, ErrUserNotFound
    }
    return user, nil
}
```

#### 4.2 Fail Fast — Catch Problems Early

```go
// ❌ Bad: Deferred failure - corrupts state before detecting problem
func Process(order *Order) {
    calculateTotals(order)      // Uses potentially invalid data
    validateOrder(order)       // Too late to validate!
    persistOrder(order)        // Persisted invalid order!
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

#### 4.3 Return Zero Values on Error

When a function returns multiple values including error, the non-error values must be zero values when error is not nil.

```go
// ✅ Good: Zero values on error
func GetUser(id string) (*User, error) {
    user := db.Find(id)
    if err != nil {
        return nil, err  // Return nil (zero value for *User)
    }
    return user, nil
}

// ✅ Good: All non-error returns are zero values on error
func GetUserInfo(id string) (name string, age int, err error) {
    user := db.Find(id)
    if err != nil {
        return "", 0, err  // All zero values
    }
    return user.Name, user.Age, nil
}
```

#### 4.4 Use errors.Is and errors.As — Never == for Errors

```go
// ❌ Bad: Comparing errors with ==
if err == ErrUserNotFound { ... }  // Won't work if error is wrapped!

// ✅ Good: errors.Is traverses wrapped errors
if errors.Is(err, ErrUserNotFound) { ... }

// ❌ Bad: Type assertion for error types
if e, ok := err.(ValidationError); ok { ... }  // Won't work if error is wrapped!

// ✅ Good: errors.As traverses wrapped errors chain
var validationErr ValidationError
if errors.As(err, &validationErr) {
    // Handle validation error
}
```

#### 4.5 Wrap Errors with Context

```go
// ❌ Bad: Lost context - where did the error originate?
func Process(order *Order) error {
    if err := db.Create(order).Error; err != nil {
        return err  // What operation failed? What order?
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

### 5. Formatting — Team Agreement and Readability

Code formatting is not personal preference; it is communication.

> "Coding style is about consistency. It's not about one style being better than another—it's about choosing one and applying it consistently."
> — Clean Code

#### 5.1 Use gofmt — Non-Negotiable

```bash
gofmt -w .
goimports -w .
```

These tools enforce consistent formatting. Never fight them.

#### 5.2 Vertical Formatting — Related Things Together

**The Newspaper Metaphor**: Think of a file like a newspaper article.
The headline (package, main types) tells you what it contains.
Details come later. Top-down reading.

```go
// ✅ Good: Top-down, high-level first
package handler

// Public types first
type Handler struct {
    service *Service
}

// Constructor
func NewHandler(service *Service) *Handler {
    return &Handler{service: service}
}

// Public methods — what the type does
func (h *Handler) HandleGetUser(w http.ResponseWriter, r *http.Request) {
    userID := h.extractUserID(r)
    user, err := h.service.GetUser(userID)
    if err != nil {
        writeError(w, err)
        return
    }
    writeJSON(w, user)
}

// Private helpers — how it does it
func (h *Handler) extractUserID(r *http.Request) string {
    return r.URL.Query().Get("id")
}

func writeError(w http.ResponseWriter, err error) {
    // ...
}

func writeJSON(w http.ResponseWriter, v interface{}) {
    // ...
}
```

#### 5.3 Horizontal Formatting — Line Length

Aim for lines under 100 characters. Break long lines thoughtfully.

```go
// ❌ Bad: Too long, requires horizontal scroll
if user != nil && user.IsActive && user.HasPermission("admin") && time.Now().Before(user.SessionExpiry) {

// ✅ Good: Broken into readable pieces
isActive := user != nil && user.IsActive
hasPermission := user.HasPermission("admin")
isSessionValid := time.Now().Before(user.SessionExpiry)

if isActive && hasPermission && isSessionValid {

// ✅ Good: Aligned with operator continuation
totalPrice := basePrice +
    quantity*unitPrice -
    discount +
    tax
```

---

### 6. The SOLID Principles

SOLID is an acronym for five design principles that make software more understandable, flexible, and maintainable.

#### 6.1 SRP — Single Responsibility Principle (SKILL.md §14.2)

> "A class should have only one reason to change."

```go
// ❌ Bad: Multiple reasons to change
class User {
    saveToDatabase() { ... }      // Changes if DB changes
    sendEmail() { ... }            // Changes if email requirements change
    generateReport() { ... }        // Changes if reporting needs change
    calculateDiscount() { ... }     // Changes if pricing logic changes
}

// ✅ Good: Each class has one reason to change
class User { ... }                         // User data model
class UserRepository { saveToDatabase() }  // Database persistence
class EmailService { sendEmail() }         // Email sending
class ReportGenerator { generateReport() } // Report generation
class PricingService { calculateDiscount() } // Pricing logic
```

#### 6.2 OCP — Open/Closed Principle

> "You should be able to extend a class's behavior without modifying it."

```go
// ❌ Bad: Adding new behavior requires modifying existing code
func CalculateDiscount(order *Order) float64 {
    if order.Type == "premium" {
        return order.Total * 0.2
    }
    if order.Type == "standard" {
        return order.Total * 0.1
    }
    // Adding "enterprise" requires modifying this function
    return 0
}

// ✅ Good: Extend by adding new types, not modifying existing code
type DiscountStrategy interface {
    Calculate(order *Order) float64
}

type PremiumDiscount struct{}
func (d PremiumDiscount) Calculate(order *Order) float64 {
    return order.Total * 0.2
}

type StandardDiscount struct{}
func (d StandardDiscount) Calculate(order *Order) float64 {
    return order.Total * 0.1
}

// New discount types added as new implementations
// Existing code unchanged
```

#### 6.3 LSP — Liskov Substitution Principle

> "Objects of a superclass should be replaceable with objects of its subclasses without breaking the application."

```go
// ❌ Bad: Violating LSP
type Rectangle struct {
    Width  float64
    Height float64
}

type Square struct {
    Rectangle  // Embedding, but width == height always
}

func (s *Square) SetWidth(w float64) {
    s.Width = w
    s.Height = w  // Breaks Rectangle's contract!
}

func (s *Square) SetHeight(h float64) {
    s.Width = h
    s.Height = h  // Breaks Rectangle's contract!
}

// If code expects Rectangle and receives Square, behavior differs!
func area(r *Rectangle) float64 {
    return r.Width * r.Height
}

// ✅ Good: Proper inheritance or composition
// Square should not inherit from Rectangle if their behaviors differ
```

#### 6.4 ISP — Interface Segregation Principle

> "Clients should not be forced to depend on methods they do not use."

Our standard already follows this: interfaces should be small and focused.

```go
// ❌ Bad: Fat interface with unused methods
type UserService interface {
    CreateUser(user *User) error
    DeleteUser(id string) error
    GetUserByID(id string) (*User, error)
    GetUserByEmail(email string) (*User, error)
    UpdatePassword(id string, newPass string) error
    UpdateEmail(id string, newEmail string) error
    SendWelcomeEmail(user *User) error  // Many implementers don't need this
}

// ✅ Good: Segregated interfaces
type UserCreator interface {
    CreateUser(user *User) error
}

type UserGetter interface {
    GetUserByID(id string) (*User, error)
    GetUserByEmail(email string) (*User, error)
}

type UserUpdater interface {
    UpdatePassword(id string, newPass string) error
    UpdateEmail(id string, newEmail string) error
}
```

#### 6.5 DIP — Dependency Inversion Principle

> "Depend on abstractions, not on concretions."

```go
// ❌ Bad: Depending on concrete implementation
type UserService struct {
    db *MySQLDB  // High-level depends on low-level detail
}

// ✅ Good: Depending on abstraction
type UserService struct {
    repo UserRepository  // Interface, not concrete type
}

// ✅ Good: Infrastructure implements interface
type MySQLUserRepository struct {
    db *gorm.DB
}

func (r *MySQLUserRepository) FindByID(id string) (*User, error) {
    // ...
}
```

---

### 7. Tell, Don't Ask — Object-Oriented Heuristic

Don't query an object for its state, then make decisions based on that state.
Tell the object what to do; let it decide.

```go
// ❌ Bad: Tell, Don't Ask violation
func ProcessUser(user *User) {
    // Querying state, then deciding
    if user.IsActive && user.HasPermission("admin") && user.IsVerified {
        grantFullAccess()
    } else if user.IsActive && user.HasPermission("read") {
        grantReadAccess()
    } else {
        denyAccess()
    }
}

// ✅ Good: Tell the object to handle it
func ProcessUser(user *User) error {
    return user.GrantAccess()  // User knows its own state and rules
}
```

**Why this matters**: Logic scattered across callers vs. logic encapsulated in the object.
When requirements change (new role, new permission), you change one place, not many.

---

### 8. Law of Demeter — The Principle of Least Knowledge

> "Only talk to your immediate friends."

Avoid chained calls like `a.GetB().GetC().GetD()` — this creates tight coupling.

```go
// ❌ Bad: Law of Demeter violation
func GetCityName(order *Order) string {
    return order.GetUser().GetAccount().GetProfile().GetAddress().GetCity()
    // How many classes must this function know about?
    // If any intermediate method changes, this breaks!
}

// ✅ Good: Ask for what you need from your friend
func GetCityName(order *Order) string {
    return order.GetCity()  // Order encapsulates the traversal
}

// Or inject a service that knows how to look it up
type AddressService struct {}
func (s *AddressService) GetCityForOrder(order *Order) string { ... }
```

---

### 9. Clean Classes — Related Things Together

Classes should group related state and behavior.

```go
// ❌ Bad: Unrelated variables grouped
type User struct {
    Name    string
    DB      *gorm.DB        // Unrelated: infrastructure
    Cache   *redis.Client   // Unrelated: infrastructure
    Mailer  *smtp.Server    // Unrelated: infrastructure
}

// ✅ Good: Domain model separate from infrastructure
// domain/model/user.go
type User struct {
    Name  string
    Email string
    // Only domain fields
}

// infrastructure/persistence/user_repository.go
type UserRepository interface {
    FindByID(id string) (*User, error)
    Save(user *User) error
}
```

---

## Part II: The Pragmatic Programmer — Professional Philosophy

*Andrew Hunt & David Thomas, 1999*

---

### 1. Care About Your Craft

> "It's not about being the best. It's about being someone who takes pride in their work and is willing to learn and improve."

This manifests in:
- Not shipping known-bad code
- Writing tests before you ship
- Reading code review guidelines and following them
- Keeping skills current

### 2. Think! About Your Work

Don't code on autopilot. Constantly ask:
- Is there a better way?
- What am I not seeing?
- What might break?
- What will this look like in 6 months?

### 3. Provide Options, Not Excuses

When something goes wrong, don't explain why you can't. Say what you *can* do.

```go
// ❌ Bad: Excuses
// "I can't add that feature because the architecture doesn't support it."
// "The API doesn't let me do that."

// ✅ Good: Options
// "I can add that feature by refactoring X, which will take Y time."
// "The API doesn't support it directly, but I can work around it by doing Z."
```

### 4. DRY — Don't Repeat Yourself (SKILL.md §6.2)

> "Every piece of knowledge must have a single, authoritative representation in the system."

This is different from "don't copy-paste code." DRY is about *knowledge* duplication.

**Knowledge duplication examples**:

```go
// ❌ Bad: Knowledge in two places
// Validation logic duplicated
func ValidateEmail(email string) error {
    if !strings.Contains(email, "@") {
        return errors.New("invalid email")
    }
    return nil
}

func RegisterUser(email string) error {
    if !strings.Contains(email, "@") {  // Same knowledge!
        return errors.New("invalid email")
    }
    // ...
}

// ✅ Good: Single authoritative representation
// ValidateEmail is the one place this logic lives
func ValidateEmail(email string) error {
    if !strings.Contains(email, "@") {
        return errors.New("invalid email")
    }
    return nil
}

func RegisterUser(email string) error {
    if err := ValidateEmail(email); err != nil {
        return err
    }
    // ...
}
```

**DRY violations to watch for**:
- Duplicate validation logic
- Duplicate field names (name in struct tag vs. constant)
- Duplicate business rules
- Duplicate error messages

### 5. Orthogonality — Change One Thing, Affect One Place

**Principle**: Design so that what you do in one area doesn't affect other areas.

**Benefits**:
- Faster development (teams work independently)
- Easier testing (components in isolation)
- Lower risk (change in A doesn't break B)
- Reusability (components are independent)

```go
// ❌ Bad: Tight coupling — change in one affects the other
type Order struct {
    items []Item
    total float64  // Derived: calculated from items
}

func (o *Order) AddItem(item Item) {
    o.items = append(o.items, item)
    o.total += item.Price  // Order must manage its own total
}

// If total calculation changes, Order must change
// If we want to calculate totals differently in reports, we modify Order

// ✅ Good: Orthogonal design — separation of concerns
type Order struct {
    items []Item
}

func (o *Order) AddItem(item Item) {
    o.items = append(o.items, item)
}

// Total calculation is separate — belongs to pricing service or calculator
type OrderTotalCalculator struct{}

func (c OrderTotalCalculator) Calculate(order *Order) float64 {
    var total float64
    for _, item := range order.Items {
        total += item.Price * float64(item.Quantity)
    }
    return total
}

// If calculation changes, we change Calculator, not Order
// If we need different calculations, we inject different calculators
```

**Testing orthogonal code**: Each component tested in isolation, easier to verify.

### 6. Tracer Bullets Development — Start Small, Iterate

> "The tracer bullet approach: get something working end-to-end immediately, then refine."

**Tracer Bullets vs. Big Bang**:
- Big Bang: Integrate everything at once, hope it works
- Tracer Bullets: Thin vertical slice through all layers, iterate

```go
// ❌ Bad: Big Bang
// Build entire user module: validation, persistence, API, tests, etc.
// Then integrate. Many things can go wrong at once.

// ✅ Good: Tracer Bullets
// Step 1: User struct with basic fields
// Step 2: Repository interface + in-memory implementation
// Step 3: API endpoint that uses repository
// Step 4: Real database implementation
// Step 5: Validation
// Step 6: Error handling
// Step 7: Tests
// Each step is working code.
```

**This aligns with Boy Scout Rule** (SKILL.md §46): commit small improvements frequently.

### 7. Prototype to Learn — Build to Throw Away

> "Prototypes are meant to discover the unknown."

Prototypes are for learning, not for production. Use them to:
- Explore architecture decisions
- Test integration points
- Validate performance characteristics

```go
// ✅ Good: Prototyping with explicit intent
// prototype_order_service.go — marked as prototype, will be rewritten
// Explore: Which model fits the problem better?
// Prototype code is not production code!
```

### 8. No Primitive Obsession — Use Types for Domain Concepts

**Primitive obsession**: Using language primitives (string, int, float64) where domain types would be clearer.

```go
// ❌ Bad: Primitive obsession
func CreateOrder(
    customerID string,  // What kind of string? UUID? Internal ID?
    totalPrice float64, // What currency? What precision?
    orderDate int64,   // Unix timestamp? Milliseconds?
) error {
    if totalPrice < 0 {  // Validation duplicated elsewhere?
        return errors.New("price cannot be negative")
    }
    // ...
}

// ✅ Good: Domain types
type CustomerID string
type Price struct {
    Amount   float64
    Currency string
}
type OrderDate int64

func (p Price) IsNegative() bool {
    return p.Amount < 0
}

func CreateOrder(customerID CustomerID, totalPrice Price, orderDate OrderDate) error {
    if totalPrice.IsNegative() {
        return errors.New("price cannot be negative")
    }
    // ...
}
```

**Value objects (DDD)**:
- Immutable after creation
- Equal by value, not identity
- Self-validating
- No side effects

### 9. Estimation to Avoid Surprises

**Estimation is not commitment**. Estimate to:
- Understand scale
- Identify risks early
- Make informed decisions

```go
// If it takes 2 weeks to build, and you estimate 3 days...
// Problem: You don't understand the complexity yet.
// Action: Prototype first.
```

### 10. Use Exceptions for Exceptional Cases

> "Exceptions should be reserved for unexpected events."

```go
// ❌ Bad: Using exceptions for flow control
try {
    user = userService.FindByID(id);
    if (user == null) {
        throw new UserNotFoundException();
    }
} catch (UserNotFoundException e) {
    // Handle by doing nothing
}

// ✅ Good: Errors for expected cases, exceptions for unexpected
user, err := userService.FindByID(id)
if err != nil {
    if errors.Is(err, ErrUserNotFound) {
        return nil  // Expected case handled
    }
    return nil, err  // Unexpected error propagates
}
```

---

## Part III: Refactoring — Improving Structure Without Changing Behavior

*Martin Fowler, 2018 (Second Edition)*

---

### 1. What Is Refactoring?

**Refactoring** (noun): A change made to the internal structure of software to make it easier to understand and cheaper to modify **without changing its observable behavior**.

**Key points**:
- The program works the same before and after
- Purpose is to improve structure, not add features
- Small steps, each verified by tests

**NOT refactoring**:
- Adding features while changing structure (that's "refactoring AND adding features")
- Rewriting from scratch
- Fixing bugs at the same time

### 2. Code Smells — When to Refactor

Smells are indicators that something might be wrong. They don't guarantee problems, just suspicion.

#### 2.1 The Original Smells (Fowler)

| Smell | Description | Typical Fix |
|-------|-------------|-------------|
| **Mysterious Name** | Unclear function/variable names | Rename |
| **Duplicate Code** | Same logic in multiple places | Extract to one place |
| **Long Function** | Functions doing too much | Extract method |
| **Long Parameter List** | Too many parameters | Introduce parameter object |
| **Divergent Change** | One class changes for multiple reasons | Split along responsibilities |
| **Shotgun Surgery** | One change requires changes across many classes | Move features together |
| **Feature Envy** | Method uses another class's data more than its own | Move method |
| **Data Clumps** | Same 3-4 data items appear together | Extract class |
| **Primitive Obsession** | Using primitives instead of types | Introduce value object |
| **Switch Statements** | Type-checking conditionals | Polymorphism |
| **Parallel Inheritance** | Parallel class hierarchies | Merge |
| **Lazy Class** | Class doing too little | Inline or delete |
| **Speculative Generality** | "Just in case" code | Delete |
| **Temporary Field** | Field only sometimes used | Extract class |
| **Message Chains** | `a.GetB().GetC().GetD()` | Hide delegation |
| **Middle Man** | Class just delegates | Remove middle man |
| **Inappropriate Intimacy** | Classes coupled to each other's internals | Split |
| **Alternative Classes with Different Interfaces** | Same behavior, different names | Rename / adapt |

#### 2.2 Extended Smells

| Smell | Description |
|-------|-------------|
| **Revealing Subtype** | Interface exposing implementation detail |
| **Lost Intent** | Code does not reveal its purpose |
| **Accumulation** | Helpers accumulate beyond usefulness |
| **Observer Overuse** | Too many objects observing changes |

### 3. The Refactoring Process

#### 3.1 Before Refactoring — Prerequisite

**You must have tests.** Without tests, you cannot verify that behavior hasn't changed.

From Fowler: "If you want to refactor, the essential precondition is having solid tests."

This aligns with SKILL.md §11: Test Synchronization.

#### 3.2 The Refactoring Loop

1. Identify "smell" — something that could be better
2. Verify existing tests pass
3. Make tiny change
4. Run tests — they should still pass
5. Repeat

#### 3.3 Small Steps — The Key to Safe Refactoring

> "When you refactor, the steps should be so small that they're almost trivial."

```go
// Example: Extracting a variable (one step at a time)

// BEFORE:
if (order.Customer.IsPremium && order.Total > 1000) ||
   (order.Customer.IsNew && order.Total > 500) {
    applyDiscount(order, 0.1)
}

// STEP 1: Extract first condition
isPremiumLargeOrder := order.Customer.IsPremium && order.Total > 1000
if isPremiumLargeOrder ||
   (order.Customer.IsNew && order.Total > 500) {
    applyDiscount(order, 0.1)
}

// STEP 2: Extract second condition
isNewMediumOrder := order.Customer.IsNew && order.Total > 500
if isPremiumLargeOrder || isNewMediumOrder {
    applyDiscount(order, 0.1)
}

// STEP 3: Final extraction
eligibleForDiscount := isPremiumLargeOrder || isNewMediumOrder
if eligibleForDiscount {
    applyDiscount(order, 0.1)
}
```

Each step compiles and runs. If anything breaks, you know exactly which tiny step caused it.

### 4. Key Refactoring Patterns

#### 4.1 Extract Method — Reduce Complexity

```go
// BEFORE:
func PrintInvoice(order *Order) {
    // Print header...
    fmt.Println("INVOICE")
    fmt.Println("========")

    // Print customer info (mixed with invoice details)
    fmt.Printf("Customer: %s\n", order.Customer.Name)
    fmt.Printf("Email: %s\n", order.Customer.Email)

    // Print items
    for _, item := range order.Items {
        fmt.Printf("%s x%d @ %.2f\n", item.Name, item.Quantity, item.Price)
    }

    // Print total
    fmt.Printf("Total: %.2f\n", order.Total)
}

// AFTER:
func PrintInvoice(order *Order) {
    PrintInvoiceHeader()
    PrintCustomerInfo(order.Customer)
    PrintLineItems(order.Items)
    PrintTotal(order.Total)
}
```

#### 4.2 Rename Method — Reveal Intent

```go
// BEFORE: Name doesn't reveal purpose
func calc(o *Order) float64 { ... }

// AFTER: Name reveals purpose
func CalculateOrderDiscount(o *Order) float64 { ... }
```

#### 4.3 Introduce Parameter Object — Reduce Long Parameter Lists

```go
// BEFORE:
func CreateMonthlyReport(
    startDate time.Time,
    endDate time.Time,
    department string,
    manager string,
    includeCharts bool,
    includeTables bool,
    format string,
) error { ... }

// AFTER:
type ReportConfig struct {
    StartDate   time.Time
    EndDate     time.Time
    Department  string
    Manager     string
    IncludeCharts bool
    IncludeTables bool
    Format      string
}

func CreateMonthlyReport(cfg *ReportConfig) error { ... }
```

#### 4.4 Replace Conditional with Polymorphism

```go
// BEFORE: Type-checking conditionals that will grow
func CalculateShipping(order *Order) float64 {
    switch order.ShippingMethod {
    case "standard":
        return order.Weight * 0.5
    case "express":
        return order.Weight * 1.5
    case "overnight":
        return order.Weight * 3.0
    default:
        return order.Weight * 0.5
    }
}

// Adding a new shipping method requires modifying this function

// AFTER: Polymorphic approach
type ShippingCalculator interface {
    Calculate(weight float64) float64
}

type StandardShipping struct{}
func (s StandardShipping) Calculate(weight float64) float64 {
    return weight * 0.5
}

type ExpressShipping struct{}
func (s ExpressShipping) Calculate(weight float64) float64 {
    return weight * 1.5
}

type OvernightShipping struct{}
func (s OvernightShipping) Calculate(weight float64) float64 {
    return weight * 3.0
}

// Adding new method: just add new implementation
// Existing code doesn't change
```

#### 4.5 Move Method — Feature Envy

```go
// BEFORE: Method uses another class's data more than its own
type Order struct {
    Customer *Customer
    Items    []Item
    Discount float64
}

func CalculatePoints(order *Order) int {
    // This function envies Customer's data
    if order.Customer.IsPremium {
        return len(order.Items) * 20
    }
    return len(order.Items) * 10
}

// AFTER: Move to where the data lives
type Customer struct {
    IsPremium bool
}

func (c *Customer) CalculatePoints(itemCount int) int {
    if c.IsPremium {
        return itemCount * 20
    }
    return itemCount * 10
}

// Now called as:
points := order.Customer.CalculatePoints(len(order.Items))
```

### 5. Feature Inventory — Before Refactoring (SKILL.md §13.1)

**Critical step before any significant refactoring**:

1. **List every feature** the code currently has
2. **Document expected behaviors** for each
3. **Create test cases** covering each behavior
4. **Refactor**
5. **Verify each feature** still works

This prevents "refactoring" that accidentally removes functionality.

### 6. Bad Refactorings — What to Avoid

1. **Big bang refactoring**: Changing everything at once
2. **Refactoring without tests**: "I'll add tests later" (later never comes)
3. **Refactoring and adding features together**: Different mindsets, different focus
4. **Refactoring to "improve" without knowing what better means**: Measure before optimizing
5. **Design by committee during refactoring**: One person should own the session

---

## Part IV: Domain-Driven Design — Taming Complex Domains

*Eric Evans, 2003*

---

### 1. Ubiquitous Language — One Language Everywhere

The same terms, concepts, and rules should appear in:
- Code (class names, method names)
- Documentation
- Team discussions
- User stories
- Database schemas

**Without ubiquitous language**:
- Domain experts and developers talk past each other
- Code doesn't reflect the domain
- Changes in the domain don't propagate to code

```go
// ❌ Bad: Language mismatch
// Domain says: "Customer subscribes to a Plan"
// Code says: "User buys Package"
user.BuyPackage(packageID)  // Wrong language!

// ✅ Good: Ubiquitous language
customer.SubscribeTo(plan)  // Matches how the business talks
```

### 2. Bounded Contexts — Explicit Boundaries

A model is only valid within a certain boundary. Outside that boundary, the same term may mean something different.

```
┌─────────────────────────────────────────────────────────────────┐
│                      Order Context                              │
│                                                                 │
│  Order ────────> LineItem                                        │
│    │                                                            │
│    └── CustomerID (only an ID, not full Customer)                │
│                                                                 │
│  [Within this context, Customer means "customer reference"]      │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                       User Context                               │
│                                                                 │
│  User ─────────> Permission ─────────> Role                    │
│    │                                                            │
│    └── Profile ─────────> Address                                │
│                                                                 │
│  [Within this context, we know the full details of User]        │
└─────────────────────────────────────────────────────────────────┘
```

**Key insight**: Don't try to have one "User" object used everywhere. Different contexts need different views.

### 3. Aggregates — Transaction Boundaries

An aggregate is a cluster of related objects treated as a unit for data changes.

**Rules**:
1. **Aggregate root**: One entity is the root; external objects hold references only to the root
2. **Invariant enforcement**: The root ensures all internal objects satisfy invariants
3. **External changes**: Outside code cannot change objects inside the aggregate directly

```go
// ❌ Bad: No aggregate boundary
type LineItem struct {
    ProductID string
    Quantity  int
    Price     float64
}

type Order struct {
    ID        string
    Items     []LineItem
    CustomerID string
}

// External code can corrupt state!
item := order.Items[0]
item.Quantity = 9999  // Order doesn't know!

// ✅ Good: Aggregate with root enforcing invariants
type Order struct {
    id        string
    customer  CustomerID
    items     []LineItem  // private
}

func (o *Order) AddItem(product ProductID, quantity int) error {
    if quantity <= 0 {
        return errors.New("quantity must be positive")
    }
    if len(o.items) >= 100 {
        return errors.New("maximum 100 items per order")
    }
    // Validate product exists (maybe via injected service)
    // ...
    o.items = append(o.items, newLineItem(product, quantity))
    return nil
}

// External code cannot bypass AddItem
// All modifications go through the root
```

**Why this matters**:
- Consistent state always maintained
- No partial updates
- Clear transaction boundaries for persistence

### 4. Value Objects — Immutable, Value-Based

Value objects have no identity; they are defined entirely by their attributes.

**Characteristics**:
- Immutable after creation
- Equal by value, not by reference
- Self-validating
- No side effects

```go
// ❌ Bad: Mutable value-like object
type Price struct {
    Amount   float64
    Currency string
}

func (p *Price) SetAmount(amount float64) {
    p.Amount = amount  // Mutation breaks value semantics!
}

// ✅ Good: Immutable value object
type Price struct {
    amount   float64  // unexported = immutable
    currency string
}

func NewPrice(amount float64, currency string) (Price, error) {
    if amount < 0 {
        return Price{}, errors.New("price cannot be negative")
    }
    if currency == "" {
        return Price{}, errors.New("currency required")
    }
    return Price{amount: amount, currency: currency}, nil
}

func (p Price) Amount() float64 { return p.amount }
func (p Price) Currency() string { return p.currency }

// Value objects can be copied freely
func applyDiscount(price Price, discount float64) Price {
    newAmount := price.Amount() * (1 - discount)
    return Price{amount: newAmount, currency: price.Currency()}
}
```

### 5. Domain Events — Capturing State Changes

Domain events capture significant occurrences that other parts of the system might care about.

```go
// ❌ Bad: Side effects hidden in the command
func (s *OrderService) PlaceOrder(order *Order) error {
    if err := s.repo.Save(order); err != nil {
        return err
    }
    // Hidden side effect!
    go func() {
        s.emailService.SendOrderConfirmation(order.CustomerEmail)
    }()
    return nil
}

// ✅ Good: Explicit domain event
type OrderPlaced struct {
    OrderID     OrderID
    CustomerID  CustomerID
    Total       Price
    OccurredAt  time.Time
}

func (s *OrderService) PlaceOrder(order *Order) error {
    if err := s.repo.Save(order); err != nil {
        return err
    }

    // Publish domain event — decoupled from handlers
    s.eventBus.Publish(OrderPlaced{
        OrderID:    order.ID(),
        CustomerID: order.CustomerID(),
        Total:      order.Total(),
        OccurredAt: time.Now(),
    })

    return nil
}

// Handler(s) elsewhere — can be added, removed, tested independently
type EmailNotifier struct{}
func (n *EmailNotifier) HandleOrderPlaced(event OrderPlaced) error {
    // Send email
    return nil
}
```

**Benefits**:
- Decoupling: Publisher doesn't know subscribers
- Audit trail: Events can be stored
- Multiple handlers: Email, logging, analytics, etc.
- Recovery: Events can be replayed

### 6. Repositories — Access to Aggregates

Repositories provide the illusion of an in-memory collection of aggregates.

```go
// ❌ Bad: Repository returns database details
type UserRepository struct {
    db *gorm.DB
}

func (r *UserRepository) Find(id string) *gorm.DB {
    return r.db.Where("id = ?", id)  // Returns GORM object!
}

// Caller has to know about GORM, database schema, etc.

// ✅ Good: Repository returns domain objects
type UserRepository interface {
    FindByID(ctx context.Context, id UserID) (*User, error)
    FindByEmail(ctx context.Context, email Email) (*User, error)
    Save(ctx context.Context, user *User) error
    Delete(ctx context.Context, id UserID) error
}

// Implementation details hidden
type MySQLUserRepository struct {
    db *gorm.DB
}

func (r *MySQLUserRepository) FindByID(ctx context.Context, id UserID) (*User, error) {
    // GORM details hidden in implementation
    var user UserEntity
    if err := r.db.WithContext(ctx).Where("id = ?", string(id)).First(&user).Error; err != nil {
        return nil, err
    }
    return toDomain(&user), nil
}
```

### 7. Anti-Corruption Layer — Translating External Models

When integrating with external systems, translate their model into your domain rather than letting their concepts leak in.

```go
// ❌ Bad: External model in domain
type User struct {
    ID                 string
    StripeCustomerID   string  // External concept!
    SalesforceContactID string  // External concept!
    MailchimpSubscriberID string  // External concept!
}

// Domain now depends on 3 external systems!

// ✅ Good: Anti-corruption layer
// domain/model/user.go — Pure domain
type User struct {
    ID        UserID
    Email     Email
    Name      string
    // Only domain concepts
}

// infrastructure/integration/stripe_adapter.go
type StripeCustomer struct {
    CustomerID string
    Email      string
    Name       string
}

type StripeAdapter struct{}

func (a *StripeAdapter) ToDomain(stripeCustomer *StripeCustomer) *User {
    return &User{
        Email: NewEmail(stripeCustomer.Email),
        Name:  stripeCustomer.Name,
        // Translation happens here, not in domain
    }
}
```

### 8. Domain Services — When an Operation Doesn't Belong

Some operations don't fit in an entity or value object. Use a domain service.

```go
// ❌ Bad: Operation that doesn't belong to any entity
// "Calculate risk score" spans multiple entities

// ✅ Good: Domain service
type RiskCalculationService struct {
    userRepo  UserRepository
    orderRepo OrderRepository
}

func (s *RiskCalculationService) CalculateRiskScore(userID UserID) (RiskScore, error) {
    // Coordinates between User and Order aggregates
    // Logic that doesn't fit in User or Order alone
}
```

### 9. Distillation — Finding the Core Domain

In complex systems, not all parts are equally important.

- **Core Domain**: The heart of the business, what makes it unique
- **Supporting Subdomains**: Needed but not differentiating
- **Generic Subdomains**: Off-the-shelf solutions exist

```go
// Example: E-commerce platform
// Core Domain: Pricing engine (what makes this company unique)
// Supporting: Inventory management
// Generic: User authentication (use external provider)
```

---

## Part V: The Art of Unix Programming — Clarity in Design

*Eric S. Raymond, 2003*

---

### 1. Rule of Clarity — Clarity Over Cleverness

> "Clarity is better than cleverness. Because maintenance is so hard and so expensive, write programs as if the most important communication was to the developer who will maintain your code in two years."

**This is the unifying principle behind all our standards.**

Every naming convention, every formatting rule, every architectural choice should be evaluated against this rule:
- Would a new developer understand this in two years?
- Does this make the code easier to maintain?

```go
// ❌ Bad: Clever but unclear
// Bit manipulation, compressed logic
result := (x>>7&1<<5|bitset[3]^mask)&0xff

// ✅ Good: Clear intent
// Straightforward logic, self-documenting
isHighPriority := priorityFlag == PriorityHigh
needsEscalation := !isAcknowledged && time.Since(lastUpdate) > escalationThreshold
if isHighPriority && needsEscalation {
    result = StatusEscalated
}
```

### 2. Rule of Composition — Design for Connection

Design programs so they can work with other programs.

```go
// ❌ Bad: Hard to compose
func ProcessAndSave(data []byte) {
    result := internalProcess(data)
    saveToDatabase(result)
}

// ✅ Good: Composable
func Process(data []byte) ([]byte, error) {
    return internalProcess(data), nil
}

// Now can be composed in a pipeline:
// Read -> Process -> Validate -> Transform -> Write
```

### 3. Rule of Parsimony — Small is Beautiful

> "Write programs that do one thing and do it well."

Every line of code you write is a line you (or someone else) will maintain.

**Implications**:
- Delete dead code (git has history)
- Don't add "just in case" features
- Remove functionality that isn't used
- Keep functions small

```go
// ❌ Bad: Overly general "just in case"
func ProcessUser(user *User, options *UserProcessingOptions) error {
    if options.IncludeAuditLog {
        // ... 50 lines of audit logging
    }
    if options.SendEmail {
        // ... 30 lines of email handling
    }
    if options.GenerateReport {
        // ... 40 lines of report generation
    }
    // Function does many things, most not needed
}

// ✅ Good: Separate, composable functions
func ProcessUser(user *User) error { ... }
func AuditUserAction(user *User, action string) error { ... }
func SendUserEmail(user *User) error { ... }
func GenerateUserReport(user *User) ([]byte, error) { ... }
```

### 4. Rule of Least Surprise — Predictable Behavior

> "Do the expected thing. Programs should do the least surprising thing."

```go
// ❌ Bad: Surprising behavior
func GetUser(id string) *User {
    user := findUser(id)
    if user == nil {
        return &User{Name: "Unknown"}  // Returns fake user, not obviously "not found"
    }
    return user
}

// ✅ Good: Predictable behavior
func GetUser(id string) (*User, error) {
    user := findUser(id)
    if user == nil {
        return nil, ErrUserNotFound  // Obvious: caller must handle not found
    }
    return user, nil
}
```

### 5. Rule of Transparency — Make Behavior Obvious

Design so that the behavior is obvious from looking at the code.

```go
// ❌ Bad: Hidden state modification
func Process(order *Order) {
    // What side effects happen here?
    go sendEmail(order)       // Hidden async side effect
    updateMetrics(order)      // Hidden external effect
    maybeLog(order)           // Conditional logging
}

// ✅ Good: Obvious side effects
func (s *OrderService) Place(order *Order) error {
    if err := s.repo.Save(order); err != nil {
        return fmt.Errorf("save order: %w", err)
    }

    // Explicit event publication
    s.eventBus.Publish(OrderPlaced{OrderID: order.ID})

    return nil
}

// Reading the code shows all effects
```

### 6. Silence is Golden — Don't Over-Log

> "A program should not output anything unless there's a good reason."

Logging is important for debugging and audit, but verbose logging obscures important information.

```go
// ❌ Bad: Excessive logging
func FindUser(id string) (*User, error) {
    log.Printf("FindUser called with id=%s", id)
    user := db.Find(id)
    if user != nil {
        log.Printf("FindUser: found user %s", user.Name)
    } else {
        log.Printf("FindUser: user not found")
    }
    return user, nil
}

// ✅ Good: Log significant events only
func FindUser(id string) (*User, error) {
    user := db.Find(id)
    if err != nil {
        logger.G().WarnW("user lookup failed", "userID", id, "err", err)
    }
    return user, nil  // Successful lookups don't need logging
}
```

### 7. Rule of Representation — Structure Data Well

> "Fold knowledge into data so program logic can be stupid and robust."

```go
// ❌ Bad: Logic scattered, data structure weak
func CalculatePay(employeeType string, hours float64) float64 {
    if employeeType == "hourly" {
        return hours * 50
    } else if employeeType == "salary" {
        return 5000
    } else if employeeType == "contractor" {
        return hours * 100
    }
    return 0
}

// Logic and data mixed; adding new types requires changing logic

// ✅ Good: Knowledge in data
type PayRate struct {
    name         string
    hourlyRate   float64
    monthlySalary float64
}

var payRates = []PayRate{
    {"hourly", 50, 0},
    {"salary", 0, 5000},
    {"contractor", 100, 0},
}

func CalculatePay(employeeType string, hours float64) float64 {
    for _, rate := range payRates {
        if rate.name == employeeType {
            if rate.hourlyRate > 0 {
                return hours * rate.hourlyRate
            }
            return rate.monthlySalary
        }
    }
    return 0
}
```

### 8. Rule of Modular Design — Isolation

> "Design for modularity. Each section of code is isolated."

Modularity in Go:
- Packages provide isolation
- Interfaces provide abstraction
- Keep related things together, unrelated things apart

```go
// ✅ Good: Clear module boundaries
// domain/model/ — Domain entities and value objects
// domain/service/ — Domain services
// domain/event/ — Domain events
// infrastructure/persistence/ — Database implementations
// infrastructure/email/ — Email implementations
// handler/ — HTTP handlers
```

---

## Synthesis: How These Books Inform Our Standards

### Mapping: Standard Area → Primary Source → Supporting Sources

| Standard Area | Primary Book | Supporting Books |
|---------------|-------------|------------------|
| Meaningful names | Clean Code | Pragmatic (clarity), Unix (clarity) |
| Small functions, SRP | Clean Code | Refactoring (extract), Unix (small) |
| Comments (explain why) | Clean Code | Unix (clarity) |
| Error handling (fail fast) | Clean Code | Pragmatic, Unix (transparency) |
| Formatting (gofmt) | Clean Code | Unix (team consistency) |
| DRY / no duplication | Pragmatic | Clean Code, Refactoring |
| Orthogonality | Pragmatic | Unix (composition), DDD (bounded contexts) |
| Value objects | Pragmatic, DDD | Clean Code (meaningful types) |
| Test-first | Pragmatic | Refactoring |
| DDD layers | DDD | Clean Code (SRP), Unix (modularity) |
| Bounded contexts | DDD | Pragmatic (orthogonality) |
| Aggregates | DDD | Clean Code (encapsulation) |
| Domain events | DDD | Pragmatic (decoupling) |
| Code smells | Refactoring | Clean Code (SOLID) |
| Refactoring process | Refactoring | Pragmatic (tracer bullets), Clean Code (boy scout) |
| SOLID principles | Clean Code | Pragmatic (orthogonality) |
| Logging / transparency | Unix | Clean Code (comments) |
| Boy Scout Rule | Clean Code | Pragmatic (care about craft) |

---

## Key Additions: Concepts Not Currently in Code Review Guidelines

Based on this deep analysis, the following concepts could strengthen our standards:

### Must Add

1. **Tell, Don't Ask**
   - Warn against querying state then deciding in caller
   - Encourage pushing behavior into objects

2. **Law of Demeter**
   - Discourage chained calls: `a.GetB().GetC().GetD()`
   - Encourage asking for what you need from your friend

3. **Orthogonality**
   - Explicit principle that changes should be localized
   - Design so that changes in A don't require changes in B

4. **Aggregates**
   - Transaction boundaries
   - Aggregate root enforcement
   - Invariants maintained internally

5. **Bounded Contexts**
   - Explicit boundaries for domain models
   - Don't share models across context boundaries

6. **Domain Events**
   - Capture state changes as events
   - Decouple event producers from consumers

7. **Anti-Corruption Layer**
   - Translating external models
   - Don't let foreign concepts leak into domain

### Should Consider

8. **OCP — Open/Closed Principle**
   - Open for extension, closed for modification
   - Add new behavior via new types, not modifying existing

9. **LSP — Liskov Substitution**
   - Subclasses substitutable for base types
   - Inheritance contracts must be respected

10. **Tracer Bullets Development**
    - Start with minimal working end-to-end
    - Iterate and refine

11. **Refactoring Catalog**
    - Extract Method, Move Method, Rename Method
    - Concrete patterns with examples

12. **Rule of Least Surprise**
    - Programs should do the expected thing
    - Predictable behavior

13. **Silence is Golden**
    - Don't log successful operations verbosely
    - Log significant events only

14. **Composition over Inheritance**
    - In Go specifically, prefer composition
    - (Go has no inheritance)

---

## References

1. Martin, R. C. (2008). *Clean Code: A Handbook of Agile Software Craftsmanship*. Prentice Hall.

2. Hunt, A., & Thomas, D. (1999). *The Pragmatic Programmer: From Journeyman to Master*. Addison-Wesley.

3. Fowler, M. (2018). *Refactoring: Improving the Design of Existing Code* (2nd ed.). Addison-Wesley.

4. Evans, E. (2003). *Domain-Driven Design: Tackling Complexity in the Heart of Software*. Addison-Wesley.

5. Raymond, E. S. (2003). *The Art of Unix Programming*. Addison-Wesley.
