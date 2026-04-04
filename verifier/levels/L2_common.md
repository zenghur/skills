# L2: Common — Daily Verification Scenarios

**When**: Normal verification tasks (frontend apps, backend APIs, CLI tools, auth flows)

Extends L1 with common verification patterns.

---

## Browser Automation (Required)

Frontend verification requires Playwright and Chromium:

```bash
# Install Playwright
npm install -D @playwright/test

# Install Chromium browser
npx playwright install chromium
```

**If Playwright or Chromium is missing, verification cannot proceed — report this and stop.**

---

## Frontend Verification Flow

### Step 1: Start Dev Server

```bash
# Detect dev server command from package.json
cat package.json | jq -r '.scripts.dev // .scripts.start // .scripts.serve'

# Common patterns:
npm run dev &
npm run serve &
python manage.py runserver &
rails server &

# Wait for READY SIGNAL (example for Next.js):
until curl -s http://localhost:3000 | grep -q "DOCTYPE\|<html"; do sleep 2; done
```

### Step 2: Critical Path Verification

Test in this order:

```bash
# 2a. Homepage loads
curl -s http://localhost:3000 | grep -q "<html" && echo "PASS: Homepage loads"

# 2b. Static assets (CSS/JS)
curl -I http://localhost:3000/static/main.js 2>/dev/null | grep "HTTP"
curl -I http://localhost:3000/static/main.css 2>/dev/null | grep "HTTP"

# 2c. API routes
curl -s http://localhost:3000/api/health | jq '.'
curl -s http://localhost:3000/api/users | jq 'length'

# 2d. Images (especially Next.js image optimizer)
curl -I http://localhost:3000/_next/image?url=/hero.png 2>/dev/null | grep "HTTP"
```

### Step 3: Browser Automation

```javascript
const { chromium } = require('@playwright/test');

async function verify() {
  const browser = await chromium.launch();
  const page = await browser.newPage();

  // 1. Navigation
  await page.goto('http://localhost:3000');

  // 2. Console errors
  const errors = [];
  page.on('console', msg => {
    if (msg.type() === 'error') errors.push(msg.text());
  });

  // 3. Screenshot
  await page.screenshot({ path: '/tmp/homepage.png', fullPage: false });

  // 4. Fill form
  await page.fill('input[name="email"]', 'test@example.com');
  await page.fill('input[name="password"]', 'password123');

  // 5. Click
  await page.click('button[type="submit"]');

  // 6. Execute JS
  const result = await page.evaluate(() => document.title);

  // 7. Wait for network idle
  await page.waitForLoadState('networkidle');

  if (errors.length > 0) {
    console.log('FAIL: Console errors found:', errors);
  }

  await browser.close();
}
```

**Operations:**

| Operation | Method |
|-----------|--------|
| Navigate | `page.goto(url)` |
| Screenshot | `page.screenshot({ path, fullPage })` |
| Click | `page.click(selector)` |
| Fill form | `page.fill(selector, text)` |
| Execute JS | `page.evaluate(fn)` |
| Console logs | `page.on('console', callback)` |

### Step 4: Subresource Checklist

| Resource | Check | Command |
|----------|-------|---------|
| HTML | doctype present | `curl -s url \| grep -q "<!DOCTYPE"` |
| CSS | 200 OK | `curl -I url \| grep "HTTP.*200"` |
| JS | 200 OK, size > 0 | `curl -sI url \| grep "Content-Length.*[1-9]"` |
| Images | 200 OK | `curl -I url \| grep "HTTP.*200"` |
| Fonts | 200 OK | `curl -I url \| grep "HTTP.*200"` |
| API JSON | valid JSON | `curl -s url \| jq '.'` |
| WebSocket | connects | `wscat -c ws://localhost:3000/ws` |

---

## Backend/API Verification

### Response Shape Verification (not just status codes!)

```bash
# WRONG: just checking status
curl -o /dev/null -s -w "%{http_code}\n" http://localhost:8080/api/users

# RIGHT: checking actual structure
curl -s http://localhost:8080/api/users | jq '.users[0].id, .users[0].name, .users[0].email'

# If structure wrong, FAIL immediately
EXPECTED='{"id": 1, "name": "string", "email": "string@domain.com"}'
ACTUAL=$(curl -s http://localhost:8080/api/users | jq '.users[0]')
if [ "$ACTUAL" != "$EXPECTED" ]; then
  echo "FAIL: Response shape mismatch"
fi
```

### Error Handling Verification

```bash
curl -s -o /dev/null -w "%{http_code}" -X POST http://localhost:8080/api/users \
  -H 'Content-Type: application/json' \
  -d '{}'
# Should return 400 (bad request), not 200
```

---

## CLI/Terminal Verification

```bash
# Test with representative inputs
./my-cli --help
./my-cli --input data/sample.json

# Edge cases
./my-cli --input ""              # empty
./my-cli --input /nonexistent   # file not found
./my-cli --input "{}"           # malformed JSON

# Exit codes
./my-cli invalid 2>&1; echo "Exit: $?"
# Expected: non-zero exit code
```

---

## Authentication Flow Verification (CRITICAL)

If the app requires login, you MUST verify authenticated routes.

### Login Method Detection

```bash
ls -la src/auth* routes/auth* 2>/dev/null
cat src/contexts/Auth* 2>/dev/null | grep -i "provider\|method"
```

### Login Types & Verification

#### Form-Based Login
```javascript
await page.goto('http://localhost:3000/login');
await page.fill('input[name="email"]', process.env.TEST_EMAIL);
await page.fill('input[name="password"]', process.env.TEST_PASSWORD);
await page.click('button[type="submit"]');
await page.waitForURL('**/dashboard', { timeout: 10000 });
const userText = await page.textContent('.user-name');
if (!userText) throw new Error('Login failed');
```

#### Token-Based API
```bash
TOKEN=$(curl -s -X POST http://localhost:3000/api/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"test@example.com","password":"test"}' | jq -r '.token')
curl -H "Authorization: Bearer $TOKEN" http://localhost:3000/api/profile
```

#### OAuth/SSO
```javascript
await page.click('button:has-text("Login with Google")');
await page.waitForURL('**/oauth/callback**');
```

#### Cookie/Session-Based
```bash
COOKIE=$(curl -s -c - -X POST http://localhost:3000/login \
  -d 'username=test&password=test' | grep session | awk '{print $7}')
curl -H "Cookie: session=$COOKIE" http://localhost:3000/api/profile
```

### Auth Verification Checklist

```
[ ] Login page loads
[ ] Invalid credentials rejected (400/401)
[ ] Valid credentials accepted (200/redirect)
[ ] Token/cookie set correctly
[ ] Authenticated route accessible WITH auth
[ ] Authenticated route BLOCKED without auth
[ ] Logout clears session/token
[ ] Expired token rejected
```

---

## Infrastructure Verification

```bash
# Terraform
terraform plan -out=tfplan
terraform apply tfplan
terraform show tfplan | grep -A5 "Changes:"

# Kubernetes
kubectl apply --dry-run=server -f k8s/
kubectl get pods -o wide

# Docker
docker build -t myapp .
docker run --dry-run myapp
docker image inspect myapp
```

---

## Database Migration Verification

```bash
# Run UP
alembic upgrade head

# Verify schema
psql -c "\dt"
psql -c "\\d table_name"

# Run DOWN (reversibility)
alembic downgrade -1

# Verify rollback
psql -c "\\d table_name"  # should fail or show old schema
```
