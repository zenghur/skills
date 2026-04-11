# Security Logging & Audit

## 1. Security Event Logging

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

## 2. Audit Trail

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

## 3. Social Engineering Defense

### 3.1 Phishing-Resistant Authentication

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

### 3.2 Suspicious Activity Detection

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
