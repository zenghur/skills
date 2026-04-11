# CSRF Protection

```go
func CSRFGuard(handler http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        if r.Method == "POST" || r.Method == "PUT" || r.Method == "DELETE" {
            sessionID := getSessionID(r)
            token := r.FormValue("csrf_token")

            if !csrfToken.Validate(sessionID, token) {
                http.Error(w, "CSRF token invalid", http.StatusForbidden)
                return
            }
        }
        handler.ServeHTTP(w, r)
    })
}
```
