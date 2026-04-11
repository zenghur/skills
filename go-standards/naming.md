# Naming Conventions

## 1. Basic Naming Rules

> **[@CoT-required]**: When reviewing naming conventions, execute Review Process Step 1-3 before giving conclusions.

- **Internal interface data**: Use camelCase
- **External system integration**: Use field names as-is from external system
- **Comments**: Use English, follow Google conventions
- **Package names**: lowercase, avoid underscores
- **Function names**: camelCase, start with verb

## 2. Meaningful Names

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

## 3. Function Naming: Verb Prefix [@CoT-required]

Function names use camelCase and start with a verb.

```go
// ❌ Bad
func get(u *User) error { ... }
func processData(d Data) { ... }

// ✅ Good
func GetUserByID(userID string) (*User, error) { ... }
func ValidateUserPermissions(user *User) error { ... }
```

## 4. Interface Naming

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

## 5. Avoid Misleading Names

```go
// ❌ Bad
var userList map[string]*User  // It's a map, not a list
var accountData *Account        // "Data" is meaningless

// ✅ Good
var userMap map[string]*User
var account *Account
```

## 6. Consistent Terminology

```go
// ❌ Bad: Mixed
func fetchUser() { ... }
func getUserData() { ... }

// ✅ Good: Unified
func GetUser() { ... }
func GetUserData() { ... }
```

## 7. No Magic Values [@CoT-required]

No magic numbers or strings. Define meaningful constants.

```go
// ❌ Bad
if user.Status == 1 { ... }

// ✅ Good
const (
    StatusActive   = 1
    StatusInactive = 2
    StatusDeleted  = 3
)
if user.Status == StatusActive { ... }
```
