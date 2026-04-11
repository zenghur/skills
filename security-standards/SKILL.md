---
name: security-standards
description: Security standards covering defense in depth, input validation, authentication, authorization, XSS/CSRF prevention, cryptography, and TLS. Use for security audits and security-related code.
---

# Security Standards

> "Security is not a product, but a process." — Bruce Schneier

## Modules

| Module | Description |
|--------|-------------|
| [Defense in Depth](defense-in-depth.md) | Layered defense principles |
| [Input Validation](input-validation.md) | Input validation and SQL/NoSQL injection prevention |
| [Authentication](authentication.md) | Password storage, session management |
| [Authorization](authorization.md) | RBAC access control |
| [XSS Prevention](xss.md) | XSS prevention and CSP |
| [CSRF Protection](csrf.md) | CSRF protection |
| [TLS Configuration](tls.md) | TLS best practices |
| [Cryptography](cryptography.md) | Cryptographic algorithms and key management |
| [Security Logging](logging.md) | Security logging and audit |

## Core Principles (Summary)

| Principle | Canonical Location |
|-----------|-------------------|
| Defense in depth | [Defense in Depth](defense-in-depth.md) |
| Validate all input | [Input Validation](input-validation.md) |
| Parameterized queries | [Input Validation](input-validation.md#2-sql-injection-defense-patterns) |
| bcrypt password hashing | [Authentication](authentication.md#1-password-storage) |
| HttpOnly cookies | [Authentication](authentication.md#2-session-management) |
| RBAC | [Authorization](authorization.md) |
| XSS prevention | [XSS Prevention](xss.md) |
| CSRF tokens | [CSRF Protection](csrf.md) |
| TLS 1.3 | [TLS Configuration](tls.md) |

## File Structure

```
security-standards/
├── SKILL.md                   # Main entry
├── defense-in-depth.md        # Layered defense principles
├── input-validation.md        # Input validation and injection defense
├── authentication.md          # Password storage, session management
├── authorization.md           # RBAC access control
├── xss.md                    # XSS prevention and CSP
├── csrf.md                   # CSRF protection
├── tls.md                    # TLS configuration
├── cryptography.md           # Cryptographic algorithms
└── logging.md               # Security logging and audit
```
