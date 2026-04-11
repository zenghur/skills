# Defense in Depth

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
