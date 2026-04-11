# Database Standards (GORM)

## 1. Field Tags

> **[@CoT-required]**: When reviewing database standards, execute Review Process Step 1-3 before giving conclusions.

Every field must have explicit `gorm:"column:field_name"`.

```go
// ✅ Good
type User struct {
    ID        uint   `gorm:"column:id"`
    Name      string `gorm:"column:name"`
    CreatedAt int64  `gorm:"column:created_at"`
}

// ❌ Bad: Implicit column names, index tags
type User struct {
    ID        uint   `gorm:"primaryKey"`
    Name      string `gorm:"index"`
}
```

**Key Rule**: Never use `index` or `uniqueIndex` tags.

## 2. DDL Principles

- Write DDL explicitly, never use `AutoMigrate`
- All fields must have `NOT NULL` constraint
- Never check `IS NULL` / `IS NOT NULL` in code

## 3. Update Operations

Use struct model, not `map[string]interface{}`:

```go
// ❌ Bad
db.Model(&user).Updates(map[string]interface{}{
    "name": "new name",
})

// ✅ Good: Type-safe, IDE support
db.Model(&user).Updates(&User{Name: "new name"})
```

## 4. CRUD Operations

- **Create**: `db.Create()`
- **Update**: `db.Save()`, `db.Updates()`
- **Delete**: `db.Delete()`
- **Query**: Use gorm methods, not raw SQL

Raw SQL allowed only for:
- Complex queries gorm cannot express
- DDL operations (`CREATE TABLE`, `ALTER TABLE`)

## 5. Timestamp Handling

- **Database storage**: int64 (UnixMilli)
- **Frontend-backend transmission**: int64
- **Frontend display**: Convert to local time, format as `YYYY-MM-DD HH:mm:ss`

## 6. Backend Owns Business Logic [@CoT-required]

Backend handles ALL business logic and complex calculations.
Frontend can do pure data calculations on data already received (e.g., expensive client-side computations to reduce server load), but must NOT contain business logic.

```go
// ❌ Bad: Frontend doing business calculation
func UserCard({ user }) {
  const discount = user.orders.reduce((sum, o) => sum + o.total, 0);
  // Frontend aggregations are forbidden
}

// ✅ Good: Backend sends pre-calculated data
func UserCard({ user, totalOrderAmount }) {
  // Just display what backend provides
}
```
