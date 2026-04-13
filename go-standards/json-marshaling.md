# JSON Marshaling

## 1. 禁止字符串拼接 JSON

**禁止使用 `fmt.Sprintf` 或字符串拼接方式构造 JSON 字符串。**

```go
// 错误
fmt.Sprintf(`{"type":"data","content":"%s"}`, escapeJSONString(resp.Content))

// 正确
json.Marshal(struct {
    Type    string `json:"type"`
    Content string `json:"content"`
}{
    Type:    "data",
    Content: resp.Content,
})
```

**Why:**
- 字符串拼接容易产生 JSON 语法错误
- 难以维护和阅读
- 没有类型安全，无法在编译期发现错误

**How to apply:** 所有 JSON 序列化必须使用 `encoding/json` 的 `Marshal` / `MarshalIndent` 函数，通过 struct 类型来定义数据结构。
