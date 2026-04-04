# Level 4: Reference — Checklists & Security Standards

> **When to read**: Code review, security audits, deep-dive scenarios
> **Extends**: Level 1 + 2 + 3 rules
> **Scope**: All checklists, complete Security Standards

---

# Part A: Checklists

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

## Code Review Checklist

### General
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

---

# Part B: Security Standards

> "Security is not a product, but a process." — Bruce Schneier

---

## 1. Defense in Depth

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
    // Layer 1: Authentication
    requester, err := auth.GetCurrentUser(ctx)
    if err != nil {
        return ErrUnauthenticated
    }

    // Layer 2: Authorization
    if requester.ID != userID && !requester.IsAdmin {
        return ErrForbidden
    }

    // Layer 3: Audit logging
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

## 2. Secure Input Validation

**Core Principle**: Validate all input at the trust boundary. Never trust external data.

### 2.1 Validate and Sanitize

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

### 2.2 SQL Injection Defense Patterns

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

### 2.3 NoSQL Injection

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

---

## 3. Authentication & Session Security

### 3.1 Password Storage

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

### 3.2 Session Management

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

### 3.3 Brute Force Protection

```go
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
```

---

## 4. Cryptography Best Practices

### 4.1 Algorithm Selection

| Use Case | Recommended | Avoid |
|----------|------------|-------|
| Password hashing | bcrypt, scrypt, argon2 | MD5, SHA1, plain SHA256 |
| Symmetric encryption | AES-256-GCM, ChaCha20-Poly1305 | DES, AES-ECB |
| Asymmetric encryption | X25519, ECIES | RSA-1024, RSA-512 |
| Data in transit | TLS 1.3 | SSL, TLS 1.0, TLS 1.1 |
| Digital signatures | Ed25519, ECDSA (P-256+) | RSA-512, DSA |
| Key derivation (password) | argon2, scrypt, bcrypt | PBKDF2 (with < 100k iterations) |
| Key derivation (material) | HKDF | direct hash of secret |

### 4.2 Encryption Example

```go
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

    plaintext, err := gcm.Open(nil, e.Nonce, e.Ciphertext, nil)
    if err != nil {
        return nil, fmt.Errorf("decrypt: %w", err)
    }
    return plaintext, nil
}
```

### 4.3 Key Management

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

## 5. XSS Prevention

### 5.1 Go HTML Template Auto-Escape

```go
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

### 5.2 JavaScript Context Encoding

```html
<!-- ❌ Bad: User input in JavaScript context without encoding -->
<script>
var username = "{{.Username}}";  // XSS if username = '"; alert(1); //
</script>

<!-- ✅ Good: JSON encoding -->
<script type="application/json">
var user = {{.Username | json}};
</script>

<!-- ✅ Good: HTML attribute encoding -->
<input value="{{.Username | htmlattr}}">
```

### 5.3 CSP Header

```go
func SecurityHeaders(h http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Security-Policy",
            "default-src 'self'; " +
            "script-src 'self' 'nonce-{random}'; " +
            "object-src 'none'; " +
            "base-uri 'self'; " +
            "form-action 'self'")

        w.Header().Set("X-Content-Type-Options", "nosniff")
        w.Header().Set("X-Frame-Options", "DENY")
        w.Header().Set("Referrer-Policy", "strict-origin-when-cross-origin")

        h.ServeHTTP(w, r)
    })
}
```

---

## 6. CSRF Protection

```go
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

## 7. Access Control (RBAC)

```go
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
        return true
    case "admin":
        return perm != PermissionAdminManage
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

---

## 8. TLS Configuration

```go
// ❌ Bad: Weak TLS configuration
&tls.Config{
    MinVersion: tls.VersionTLS10,
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

---

## 9. Memory Safety

```go
// ❌ Bad: Data race
var sharedMap = make(map[string]string)

func AppendToMap(key, value string) {
    sharedMap[key] = value  // Data race!
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

// ❌ Bad: Escaping sensitive data to heap
func BadExample() string {
    password := "secret-token-12345"
    return password  // May persist in memory
}

// ✅ Good: Use crypto/subtle for constant-time operations
func SecureCompare(a, b string) bool {
    return subtle.ConstantTimeCompare([]byte(a), []byte(b)) == 1
}
```

---

## 10. Security Logging & Audit

### 10.1 Security Event Logging

```go
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

### 10.2 Audit Trail

```go
type AuditLog struct {
    ID         string `gorm:"column:id"`
    Timestamp  int64  `gorm:"column:timestamp"`
    ActorID    string `gorm:"column:actor_id"`
    Action     string `gorm:"column:action"`
    Resource   string `gorm:"column:resource"`
    ResourceID string `gorm:"column:resource_id"`
    Result     string `gorm:"column:result"`
    IP         string `gorm:"column:ip"`
    UserAgent  string `gorm:"column:user_agent"`
}

func (a *AuditLogger) Log(ctx context.Context, entry *AuditLog) error {
    entry.ID = generateID()
    entry.Timestamp = time.Now().UnixMilli()
    return a.db.WithContext(ctx).Create(entry).Error
}
```

---

## 11. Social Engineering Defense

### 11.1 Phishing-Resistant Authentication

```go
type MFAMethod string

const (
    MFAMethodTOTP    MFAMethod = "totp"
    MFAMethodWebAuthn MFAMethod = "webauthn"
    MFAMethodSMS     MFAMethod = "sms"  // Less secure, fallback only
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
        return a.verifyWebAuthn(ctx, user.WebAuthnCredential, code)
    case MFAMethodSMS:
        logger.WarnW("sms_mfa_used", "user_id", userID, "warning", "SMS MFA is vulnerable to SIM swap")
        return a.verifySMS(user.Phone, code)
    }
}
```

### 11.2 Suspicious Activity Detection

```go
func (s *SecurityService) DetectAnomalousLogin(ctx context.Context, attempt *LoginAttempt) bool {
    // New device?
    if !s.isKnownDevice(attempt.UserID, attempt.IP, attempt.UserAgent) {
        logger.WarnW("new_device_login",
            "user_id", attempt.UserID,
            "ip", attempt.IP,
            "user_agent", attempt.UserAgent)
        s.notifyUser(attempt.UserID, "new_device_login", attempt.IP)
    }

    // Impossible travel
    if s.impossibleTravel(attempt.UserID, attempt.IP) {
        logger.WarnW("impossible_travel_detected",
            "user_id", attempt.UserID,
            "ip", attempt.IP)
        return true
    }

    // Rate limiting
    if s.isRateLimited(attempt.UserID) {
        return true
    }

    return false
}
```
