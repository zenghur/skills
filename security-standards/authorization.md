# Access Control (RBAC)

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
