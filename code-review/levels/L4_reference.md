# Level 4: Reference § Checklists & Security Standards

> **When to read**: Code review, security audits, deep-dive scenarios
> **Extends**: Level 1 + 2 + 3 rules
> **Scope**: All checklists, complete Security Standards

---

# Part A: Checklists

## Backend Checklist (Summary)

> **Note**: This checklist summarizes rules from L1/L2/L3. Each item links to its canonical source.

| Category | Rule | Canonical Source |
|----------|------|-----------------|
| Business logic | Backend owns ALL business logic | [L1 Rule 1](../levels/L1_minimal.md#1-backend-owns-business-logic-cot-required) |
| Goroutines | Never use `go` keyword directly | [L3 §2.1](../levels/L3_advanced.md#21-goroutine-safety-rules) |
| Errors | Use `errors.Is()` and `errors.As()` | [L1 Rule 4](../levels/L1_minimal.md#4-use-errorsis-for-error-comparison-cot-required) |
| Zero-value | Functions returning error follow zero-value pattern | [L2 §2.1](../levels/L2_common.md#21-zero-value-pattern) |
| GORM | Explicit `gorm:"column:field_name"` tags | [L1 Rule 9](../levels/L1_minimal.md#9-gorm-explicit-column-tags-cot-required) |
| GORM | No index/uniqueIndex tags, NOT NULL constraints | [L2 §3](../levels/L2_common.md#3-database-standards-gorm) |
| GORM | Use struct for updates, not map[string]interface{} | [L1 Rule 5](../levels/L1_minimal.md#5-prefer-struct-over-map-cot-required) |
| Logging | Structured logging (InfoW/WarnW/ErrorW/DebugW) | [L2 §4](../levels/L2_common.md#4-logging-standards) |
| Logging | No fmt.Sprintf in log messages | [L2 §4](../levels/L2_common.md#4-logging-standards) |
| Timestamps | int64 UnixMilli for DB and API | [L2 §5](../levels/L2_common.md#5-timestamp-handling) |
| Naming | camelCase, verb prefix, no magic values | [L1 Rule 2](../levels/L1_minimal.md#2-function-naming-verb-prefix-cot-required) |
| Nil checks | No redundant nil checks for initialized deps | [L2 §2.4](../levels/L2_common.md#24-no-redundant-nil-checks) |
| Refactoring | Preserve all features, incremental steps | [L3 §4](../levels/L3_advanced.md#4-refactoring) |
| Code quality | Single responsibility, cyclomatic complexity §15 | [L3 §3.1](../levels/L3_advanced.md#31-control-complexity) |
| Code quality | No mock data, TODO/FIXME in production | [L1 Rule 11](../levels/L1_minimal.md#11-production-grade-code-cot-required) |
| Tests | Unit tests for new code, regression tests for bug fixes | [L2 §9](../levels/L2_common.md#9-test-synchronization) |
| Tests | Unit coverage §70%, Integration §50%, E2E §30% | [L2 §9.5](../levels/L2_common.md#95-coverage-requirements) |
| Tests | Modified code must not decrease coverage | [L2 §9.5](../levels/L2_common.md#95-coverage-requirements) |
| Comments | Comments explain "why" not "how" | [L2 §6](../levels/L2_common.md#6-comments) |
| Format | gofmt + goimports + go vet before commit | [L1 Rule 10](../levels/L1_minimal.md#10-pre-commit-format-lint-vet-cot-required) |

> **[@CoT-required]**: Before checking items, execute Review Process Step 1 (Rule Localization) to identify which checklist items apply to this review.

---

## Frontend Checklist (Summary)

> **Note**: This checklist summarizes rules from L1/L2. Each item links to its canonical source.

| Category | Rule | Canonical Source |
|----------|------|-----------------|
| Business logic | No business logic in frontend | [L1 Rule 1](../levels/L1_minimal.md#1-backend-owns-business-logic-cot-required) |
| Business logic | No complex calculations or data aggregation | [L1 Rule 8](../levels/L1_minimal.md#8-frontend-no-business-logic-pure-calculations-ok-cot-required) |
| Vue | Vue 3 Composition API with `<script setup>` | [L2 §12](../levels/L2_common.md#12-frontend-standards-vue-3--typescript) |
| TypeScript | Strict mode, no `any` types | [L2 §12](../levels/L2_common.md#12-frontend-standards-vue-3--typescript) |
| Pinia | Global state only, no business logic | [L2 §12](../levels/L2_common.md#12-frontend-standards-vue-3--typescript) |
| Data | Timestamps formatted via utility, not computed | [L2 §5](../levels/L2_common.md#5-timestamp-handling) |
| Production | No mock data, TODO/FIXME placeholders | [L1 Rule 11](../levels/L1_minimal.md#11-production-grade-code-cot-required) |
| Security | No tokens/keys in localStorage (use HttpOnly cookies) | [L4 §5 (XSS)](../levels/L4_reference.md#5-xss-prevention) |
| Security | No v-html with user data (use v-text) | [L4 §5 (XSS)](../levels/L4_reference.md#5-xss-prevention) |
| Security | External URLs validated against allowlist | [L4 §5 (XSS)](../levels/L4_reference.md#5-xss-prevention) |
| Security | CSP headers configured | [L4 §5 (CSP)](../levels/L4_reference.md#5-xss-prevention) |

> **[@CoT-required]**: Before checking items, execute Review Process Step 1 (Rule Localization) to identify which checklist items apply to this review.

---

## Code Review Checklist (Summary)

> **Note**: This checklist summarizes review checkpoints. Apply the Review Operation Flow (three-phase: Full Blind Scan → Structured Grouping → Rule-Anchored Analysis) for systematic review.

| Review Type | Key Questions | Canonical Source |
|-------------|---------------|-----------------|
| General | Readable? Obvious bugs? Better approach? | [L3 §3](../levels/L3_advanced.md#3-function-design) |
| Error handling | Complete? Follows zero-value pattern? | [L2 §2](../levels/L2_common.md#2-error-handling) |
| Security | Input validation? Injection protected? AuthZ? | [L4 Part B](../levels/L4_reference.md#part-b-security-standards) |
| Business logic | Logic in backend only? | [L1 Rule 1](../levels/L1_minimal.md#1-backend-owns-business-logic-cot-required) |
| Performance | Cyclomatic complexity ≤15? No hidden allocations? | [L3 §3.1](../levels/L3_advanced.md#31-control-complexity) |
| Tests | Coverage adequate? Regression tests for bug fixes? | [L2 §9](../levels/L2_common.md#9-test-synchronization) |
| Refactoring | Features preserved? Incremental steps? | [L3 §4](../levels/L3_advanced.md#4-refactoring) |

> **[@CoT-required]**: Before checking items, execute Review Process Step 1 (Rule Localization) to identify which checklist items apply to this review.

---

## Daily Development Checklist (Summary)

> **Note**: Daily items for quick self-check before commit. See L1/L2 for detailed rules.

| Check | Canonical Source |
|-------|-----------------|
| Naming: verb prefix, camelCase, no magic values | [L1 Rule 2, Rule 6](../levels/L1_minimal.md) |
| Error handling: errors.Is(), zero-value pattern | [L1 Rule 4](../levels/L1_minimal.md#4-use-errorsis-for-error-comparison-cot-required), [L2 §2.1](../levels/L2_common.md#21-zero-value-pattern) |
| Business logic in backend only | [L1 Rule 1](../levels/L1_minimal.md#1-backend-owns-business-logic-cot-required) |
| gofmt + go vet + revive before commit | [L1 Rule 10](../levels/L1_minimal.md#10-pre-commit-format-lint-vet-cot-required) |
| Comments explain "why" not "how" | [L2 §4](../levels/L2_common.md#6-comments) |
| Functions: single responsibility, ≤15 complexity | [L3 §3.1](../levels/L3_advanced.md#31-control-complexity) |
| No mock data, TODO/FIXME placeholders | [L1 Rule 11](../levels/L1_minimal.md#11-production-grade-code-cot-required) |

> **[@CoT-required]**: Before checking items, execute Review Process Step 1 (Rule Localization) to identify which checklist items apply to this review.

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
