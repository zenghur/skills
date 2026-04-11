# Authentication & Session Security

## 1. Password Storage

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

## 2. Session Management

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

## 3. Brute Force Protection

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

## 4. MFA (Multi-Factor Authentication)

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

## 5. Suspicious Activity Detection

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
