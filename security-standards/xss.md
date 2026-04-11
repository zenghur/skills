# XSS Prevention

## 1. Go HTML Template Auto-Escape

```go
// ❌ Bad: Raw HTML insertion (XSS)
func RenderProfile(w http.ResponseWriter, user *User) {
    html := "<h1>" + user.Username + "</h1>"  // XSS if username = "<script>..."
    w.Write([]byte(html))
}

// ✅ Good: Use html/template
func RenderProfile(w http.ResponseWriter, user *User) error {
    tmpl, err := template.ParseFiles("templates/user.html")
    if err != nil {
        return err
    }
    return tmpl.Execute(w, user)  // Auto-escaped
}
```

## 2. JavaScript Context Encoding

```html
<!-- ❌ Bad: User input in JavaScript context without encoding -->
<script>
var username = "{{.Username}}";  // XSS if username = '"; alert(1); //
</script>

<!-- ✅ Good: JSON encoding -->
<script type="application/json">
var user = {{.Username | json}};
</script>

<!-- ✅ Good: HTML attribute encoding -->
<input value="{{.Username | htmlattr}}">
```

## 3. CSP Header

```go
func SecurityHeaders(h http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Security-Policy",
            "default-src 'self'; " +
            "script-src 'self' 'nonce-{random}'; " +
            "object-src 'none'; " +
            "base-uri 'self'; " +
            "form-action 'self'")

        w.Header().Set("X-Content-Type-Options", "nosniff")
        w.Header().Set("X-Frame-Options", "DENY")
        w.Header().Set("Referrer-Policy", "strict-origin-when-cross-origin")

        h.ServeHTTP(w, r)
    })
}
```

## 4. Frontend XSS Prevention

- **No tokens/keys in localStorage**: Use HttpOnly cookies
- **No v-html with user data**: Use v-text
- **External URLs**: Validate against allowlist

```vue
<!-- ❌ Bad: v-html with user data (XSS risk) -->
<div v-html="user.bio"></div>

<!-- ✅ Good: v-text -->
<div v-text="user.bio"></div>
```
