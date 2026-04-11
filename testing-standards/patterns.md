# Test Patterns

## 1. Table-Driven Tests

```go
func TestCreateUser(t *testing.T) {
    tests := []struct {
        name    string
        input   CreateUserRequest
        want    *User
        wantErr error
    }{
        {
            name: "valid user",
            input: CreateUserRequest{Name: "Alice", Email: "alice@example.com"},
            want:    &User{Name: "Alice", Email: "alice@example.com"},
            wantErr: nil,
        },
        {
            name:    "empty name",
            input:   CreateUserRequest{Name: "", Email: "bob@example.com"},
            want:    nil,
            wantErr: &ValidationError{Field: "name"},
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := CreateUser(tt.input)
            if !errors.Is(err, tt.wantErr) {
                t.Errorf("CreateUser() error = %v, want %v", err, tt.wantErr)
            }
            if !reflect.DeepEqual(got, tt.want) {
                t.Errorf("CreateUser() = %v, want %v", got, tt.want)
            }
        })
    }
}
```

## 2. Test Principles

- **Fast**: No external I/O
- **Independent**: Tests don't depend on each other
- **Repeatable**: Same result every time
- **Self-Validating**: Clear pass/fail

## 3. Test Directory Structure

```
backend/
├── internal/
│   ├── domain/
│   │   ├── user.go
│   │   └── user_test.go          # Unit tests next to code
│   └── service/
│       ├── user_service.go
│       └── user_service_test.go
└── tests/
    ├── integration/              # Multi-layer tests
    └── e2e/                      # Full API flow tests
testdata/                        # Test fixtures (Go convention)
```

```
frontend/
├── src/
│   ├── components/
│   │   ├── UserCard.vue
│   │   └── __tests__/
│   │       └── UserCard.test.ts
│   ├── views/
│   │   └── __tests__/
│   │       └── Dashboard.test.ts
│   └── stores/
│       └── __tests__/
│           └── user.test.ts
└── tests/
    ├── integration/
    └── e2e/
```

## 4. Frontend Component Test

```typescript
// ✅ Good: Component test
import { mount } from '@vue/test-utils';
import UserCard from '../UserCard.vue';

describe('UserCard', () => {
  it('displays user name', () => {
    const wrapper = mount(UserCard, {
      props: { userName: 'Alice' },
    });
    expect(wrapper.text()).toContain('Alice');
  });
});
```

## 5. Coverage Anti-Patterns

```go
// ❌ Anti-pattern: Testing only happy path
func TestGetUser(t *testing.T) {
    user, _ := GetUser("valid-id")  // Ignoring error
    if user == nil {
        t.Error("user should not be nil")
    }
}

// ✅ Good: Test both success and failure paths
func TestGetUser(t *testing.T) {
    t.Run("success", func(t *testing.T) {
        user, err := GetUser("valid-id")
        if err != nil {
            t.Fatalf("unexpected error: %v", err)
        }
        if user == nil {
            t.Error("user should not be nil")
        }
    })

    t.Run("not found", func(t *testing.T) {
        _, err := GetUser("invalid-id")
        if !errors.Is(err, ErrUserNotFound) {
            t.Errorf("expected ErrUserNotFound, got %v", err)
        }
    })

    t.Run("empty id", func(t *testing.T) {
        _, err := GetUser("")
        if !errors.Is(err, ErrInvalidID) {
            t.Errorf("expected ErrInvalidID, got %v", err)
        }
    })
}
```
