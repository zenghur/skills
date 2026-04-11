# Cryptography Best Practices

## 1. Algorithm Selection

| Use Case | Recommended | Avoid |
|----------|------------|-------|
| Password hashing | bcrypt, scrypt, argon2 | MD5, SHA1, plain SHA256 |
| Symmetric encryption | AES-256-GCM, ChaCha20-Poly1305 | DES, AES-ECB |
| Asymmetric encryption | X25519, ECIES | RSA-1024, RSA-512 |
| Data in transit | TLS 1.3 | SSL, TLS 1.0, TLS 1.1 |
| Digital signatures | Ed25519, ECDSA (P-256+) | RSA-512, DSA |
| Key derivation (password) | argon2, scrypt, bcrypt | PBKDF2 (with < 100k iterations) |
| Key derivation (material) | HKDF | direct hash of secret |

## 2. Encryption Example

```go
type EncryptedData struct {
    Ciphertext []byte
    Nonce     []byte  // GCM nonce, not secret
}

// Encrypt uses AES-256-GCM (authenticated encryption)
func Encrypt(plaintext, key []byte) (*EncryptedData, error) {
    block, err := aes.NewCipher(key)
    if err != nil {
        return nil, fmt.Errorf("create cipher: %w", err)
    }

    gcm, err := cipher.NewGCM(block)
    if err != nil {
        return nil, fmt.Errorf("create GCM: %w", err)
    }

    nonce := make([]byte, gcm.NonceSize())
    if _, err := rand.Read(nonce); err != nil {
        return nil, fmt.Errorf("generate nonce: %w", err)
    }

    ciphertext := gcm.Seal(nonce, nonce, plaintext, nil)
    nonceSize := gcm.NonceSize()

    return &EncryptedData{
        Ciphertext: ciphertext[nonceSize:],
        Nonce:     nonce,
    }, nil
}

// Decrypt verifies authentication tag before returning plaintext
func (e *EncryptedData) Decrypt(key []byte) ([]byte, error) {
    block, err := aes.NewCipher(key)
    if err != nil {
        return nil, fmt.Errorf("create cipher: %w", err)
    }

    gcm, err := cipher.NewGCM(block)
    if err != nil {
        return nil, fmt.Errorf("create GCM: %w", err)
    }

    if len(e.Ciphertext) < gcm.Overhead() {
        return nil, ErrCiphertextTooShort
    }

    plaintext, err := gcm.Open(nil, e.Nonce, e.Ciphertext, nil)
    if err != nil {
        return nil, fmt.Errorf("decrypt: %w", err)
    }
    return plaintext, nil
}
```

## 3. Key Management

```go
// ❌ Bad: Hardcoded keys
const API_KEY = "sk-1234567890abcdef"

// ✅ Good: Environment-based key loading
type Config struct {
    APIKey    string
    DBKey     []byte
}

func LoadConfig() (*Config, error) {
    apiKey := os.Getenv("API_KEY")
    if apiKey == "" {
        return nil, errors.New("API_KEY environment variable required")
    }

    dbKeyB64 := os.Getenv("DB_ENCRYPTION_KEY")
    if dbKeyB64 == "" {
        return nil, errors.New("DB_ENCRYPTION_KEY environment variable required")
    }

    dbKey, err := base64.StdEncoding.DecodeString(dbKeyB64)
    if err != nil || len(dbKey) != 32 {
        return nil, errors.New("DB_ENCRYPTION_KEY must be 32-byte base64")
    }

    return &Config{
        APIKey: apiKey,
        DBKey:  dbKey,
    }, nil
}
```
