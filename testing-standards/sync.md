# Test Synchronization

## 1. Sync with Code Changes

> **[@CoT-required]**: When reviewing test synchronization, execute Review Process Step 1-3 before giving conclusions.

- When modifying code, update tests simultaneously
- New features require test cases before merge
- Bug fixes must include regression tests
- Refactored code must update existing tests

## 2. Test Naming

Use table-driven tests:

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

## 3. Frontend Test Synchronization

- New components require test cases
- Bug fixes include regression tests
- Update tests when props/events change

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

## 4. Test Synchronization Checklist

| Scenario | Requirement |
|----------|-------------|
| New feature | Unit tests before merge |
| Bug fix | Regression test required |
| Refactoring | Update existing tests |
| Modified code | Coverage must not decrease |
