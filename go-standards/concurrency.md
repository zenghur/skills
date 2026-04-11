# Concurrency Safety

## 1. Goroutine Safety Rules

> **[@CoT-required]**: When reviewing goroutine and concurrency safety, execute Review Process Step 1-3 before giving conclusions.

**PROHIBITED**: Never use `go` keyword directly.

**REQUIRED**: Always use `goroutine.SafeGo` or `goroutine.SafeGoWithContext`.

```go
// ❌ Bad
go func() {
    if err := process(); err != nil {
        log.Error(err)
    }
}()

// ✅ Good: Panic recovery + context propagation built-in
goroutine.SafeGo(ctx, func() {
    if err := process(); err != nil {
        logger.ErrorW("process_failed", "err", err)
    }
})
```

## 2. Prefer Channels Over Shared Memory

```go
// ❌ Bad: Shared memory + mutex
var counter int
var mu sync.Mutex

func Increment() {
    mu.Lock()
    counter++
    mu.Unlock()
}

// ✅ Good: Channel-based
func Counter(done <-chan struct{}) <-chan int {
    ch := make(chan int)
    go func() {
        defer close(ch)
        counter := 0
        for {
            select {
            case ch <- counter:
                counter++
            case <-done:
                return
            }
        }
    }()
    return ch
}
```

## 3. Avoid Goroutine Leaks

```go
// ❌ Bad: Potential leak
func Process(ch chan int) {
    go func() {
        for {
            val := <-ch
            processValue(val)
        }
    }()
}

// ✅ Good: Exit mechanism
func Process(ctx context.Context, ch chan int) {
    goroutine.SafeGo(ctx, func() {
        for {
            select {
            case val, ok := <-ch:
                if !ok {
                    return
                }
                processValue(val)
            case <-ctx.Done():
                return
            }
        }
    })
}
```

## 4. Concurrency Patterns

```go
// ✅ Fan-out: Process multiple items concurrently
func ProcessAll(ctx context.Context, items []Item) error {
    errCh := make(chan error, len(items))
    var wg sync.WaitGroup

    for _, item := range items {
        wg.Add(1)
        goroutine.SafeGo(ctx, func() {
            defer wg.Done()
            if err := processItem(item); err != nil {
                errCh <- err
            }
        })
    }

    wg.Wait()
    close(errCh)

    for err := range errCh {
        if err != nil {
            return err
        }
    }
    return nil
}

// ✅ Pipeline: Chain of processing stages
func Pipeline(ctx context.Context, input <-chan int) <-chan string {
    stage1 := Stage1(ctx, input)
    stage2 := Stage2(ctx, stage1)
    return stage3(ctx, stage2)
}
```

## 5. Memory Safety

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
