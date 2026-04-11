# Test Coverage Requirements

## Coverage Thresholds

| Test Type | Minimum | Target | Description |
|-----------|---------|--------|-------------|
| **Unit Tests** | 70% | 80% | Individual functions/methods |
| **Integration Tests** | 50% | 60% | Multi-component interactions |
| **E2E Tests** | 30% | 40% | Full user workflows |

## Coverage by Code Type

| Code Type | Unit Coverage | Integration Coverage |
|-----------|---------------|---------------------|
| Core business logic | 80%+ | 60%+ |
| Service layer | 70%+ | 50%+ |
| Handler/Controller | 60%+ | 40%+ |
| Utility functions | 85%+ | N/A |
| Repository/DAO | 50%+ | 70%+ |

## Coverage Rules

```go
// ❌ Bad: 100% coverage but meaningless test
func Add(a, b int) int { return a + b }

func TestAdd(t *testing.T) {
    Add(1, 1)  // No assertion, coverage is 100% but test is useless
}

// ✅ Good: Meaningful test with assertions
func TestAdd(t *testing.T) {
    tests := []struct {
        name     string
        a, b     int
        expected int
    }{
        {"positive", 1, 2, 3},
        {"zero", 0, 0, 0},
        {"negative", -1, 1, 0},
        {"overflow boundary", math.MaxInt, 1, math.MinInt}, // Edge case
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            if got := Add(tt.a, tt.b); got != tt.expected {
                t.Errorf("Add(%d, %d) = %d, want %d", tt.a, tt.b, got, tt.expected)
            }
        })
    }
}
```

## Go Coverage Commands

```bash
# Generate coverage report
go test -coverprofile=coverage.out ./...

# View coverage by function
go tool cover -func=coverage.out

# View coverage in browser
go tool cover -html=coverage.out

# Check threshold (fail if < 70%)
go test -coverprofile=coverage.out ./... && \
go tool cover -func=coverage.out | grep total | \
awk '{if (gsub("%", "") && $3 < 70) {print "Coverage below 70%: " $3; exit 1}}'
```

## CI Integration

```yaml
# .github/workflows/test.yml
- name: Run tests with coverage
  run: |
    go test -coverprofile=coverage.out ./...
    
- name: Check coverage threshold
  run: |
    COVERAGE=$(go tool cover -func=coverage.out | grep total | awk '{print $3}' | sed 's/%//')
    echo "Total coverage: ${COVERAGE}%"
    if [ $(echo "$COVERAGE < 70" | bc) -eq 1 ]; then
      echo "::error::Coverage ${COVERAGE}% is below 70% threshold"
      exit 1
    fi
```

## Frontend Coverage (Jest/Vitest)

```bash
# Run with coverage
npm test -- --coverage --coverageThreshold='{"global":{"lines":70,"branches":60,"functions":70,"statements":70}}'

# vitest
vitest run --coverage
```

```json
// jest.config.js or package.json
{
  "jest": {
    "coverageThreshold": {
      "global": {
        "lines": 70,
        "branches": 60,
        "functions": 70,
        "statements": 70
      }
    }
  }
}
```

## Coverage Anti-Patterns

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

## New vs Legacy Code

| Scenario | Requirement |
|----------|-------------|
| New code | Unit coverage ≥ 70% |
| Modified code | Coverage must not decrease |
| Bug fix | Regression test required, coverage ≥ 70% |
| Legacy code | Gradual improvement, new code follows new standards |
