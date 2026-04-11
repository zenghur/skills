# Secure Input Validation

**Core Principle**: Validate all input at the trust boundary. Never trust external data.

## 1. Validate and Sanitize

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

    // 2. Character whitelist
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

## 2. SQL Injection Defense Patterns

| Vulnerability | Cause | Fix |
|--------------|-------|-----|
| **Classic Injection** | String concatenation in SQL | Parameterized queries |
| **Second-Order** | Stored malicious data executed later | Output encoding on read |
| **Blind Injection** | True/false responses reveal data | Strict type validation, rate limiting |

```go
// Second-order SQL injection prevention
func GetUserProfile(profileID string) (*Profile, error) {
    var profile Profile
    err := db.Where("id = ?", profileID).First(&profile).Error
    if err != nil {
        return nil, fmt.Errorf("get user profile %s: %w", profileID, err)
    }
    return &profile, nil
    // Parameterized query prevents SQL injection regardless of malicious content
}
```

## 3. NoSQL Injection

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
