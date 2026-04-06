# L3: Advanced — Adversarial Probes & Visual Testing

**When**: Deep verification, finding edge cases, visual regression testing

Extends L1+L2 with adversarial testing and visual verification.

---

## Adversarial Probes

These probes try to break the system:

- **Concurrency** — parallel requests: `curl url & curl url & wait`; Go: run `go test -race ./...` to detect race conditions
- **Go-specific probes**: `go vet ./...`, `staticcheck ./...` (if available), check for goroutine leaks with `-race` flag
- **Boundary values** — 0, -1, empty string, very long strings (10KB+), unicode (中文中文), MAX_INT
- **Idempotency** — same POST twice: second should be no-op or error
- **Orphan operations** — DELETE /api/users/99999 (non-existent)
- **Error cascades** — trigger error, verify cleanup happens

---

## Spot-Check Re-verification (Mandatory Self-Check)

After reporting verification results, you MUST perform a self-spot-check before issuing final VERDICT.

### Why This Matters

LLMs can fabricate outputs. The spot-check forces you to prove you actually ran the commands.

### Mandatory Spot-Check Protocol

**Step 1: Identify the most critical check**
- The check that proves the feature works
- Usually an API response, UI screenshot, or test output

**Step 2: Re-run the exact command**

```bash
# Example: If you verified an API endpoint
mkdir -p ./tmp
date && curl -s http://localhost:3000/api/users > ./tmp/spotcheck-retry.json
cat ./tmp/spotcheck-retry.json
```

**Step 3: Compare with original output**

```markdown
### Spot-Check: Self-Verification

**Original output (from Step 3):**
```
Mon Apr  6 18:45:23 CST 2026
{"users": [{"id": 1, "name": "Alice"}]}
```

**Re-run output (just now):**
```
Mon Apr  6 18:50:15 CST 2026
{"users": [{"id": 1, "name": "Alice"}]}
```

**Evidence files:**
- Original: ./tmp/verify-api.json
- Spot-check: ./tmp/spotcheck-retry.json

**Comparison:**
- Timestamp: Different (expected - different run times)
- Content: **MATCH** ✅
- Result: Spot-check PASSED

If mismatch → Investigate why, may need to report FAIL.
```

### Spot-Check Failure Examples

**Example 1: Output doesn't match**
```markdown
### Spot-Check: FAILED
**Original:** {"users": [...]}
**Re-run:** {"error": "unauthorized"}
→ The endpoint requires auth, but original check was done with cached credentials
→ Report: FAIL - authentication inconsistency detected
```

**Example 2: File doesn't exist**
```markdown
### Spot-Check: FAILED
**Original evidence file:** ./tmp/verify-api.json
**Read attempt:** File not found
→ The file was never created, output was fabricated
→ Report: FAIL - evidence file missing, verification was incomplete
```

### Anti-Patterns (Will Be Detected)

| Anti-Pattern | Detection Method |
|--------------|-----------------|
| Fabricated output | Re-run command, compare results |
| Reused old output | Timestamp mismatch or no timestamp |
| Skipped steps | Evidence file missing |
| Didn't read logs | Cannot quote specific lines |

---

## Visual Screenshot Comparison

### Screenshot Capture

**With Playwright:**
```javascript
const { chromium } = require('@playwright/test');

async function captureScreenshots() {
  const browser = await chromium.launch();
  const page = await browser.newPage();

  const pages = ['homepage', 'dashboard', 'settings'];
  for (const name of pages) {
    await page.goto(`http://localhost:3000/${name}`);
    await page.screenshot({
      path: `./tmp/screenshot-${name}-${Date.now()}.png`,
      fullPage: false
    });
  }

  await browser.close();
}
```

**With curl + wkhtmltoimage:**
```bash
wkhtmltoimage --quality 90 http://localhost:3000 ./tmp/screenshot-homepage.png
```

### Screenshot Comparison

**Using Playwright + Pixel Match:**
```bash
npm install -D pixelmatch pngjs

node -e "
const { PNG } = require('pngjs');
const pixelmatch = require('pixelmatch');
const fs = require('fs');

const img1 = PNG.sync.read(fs.readFileSync('./tmp/baseline-homepage.png'));
const img2 = PNG.sync.read(fs.readFileSync('./tmp/current-homepage.png'));
const diff = new PNG(img1.width, img1.height);

const numDiffPixels = pixelmatch(img1, img2, diff, {
  threshold: 0.1,
  includeAA: true
});

fs.writeFileSync('./tmp/diff-homepage.png', PNG.sync.write(diff));

if (numDiffPixels > 0) {
  console.log('FAIL: Screenshots differ by ' + numDiffPixels + ' pixels');
} else {
  console.log('PASS: Screenshots identical');
}
"
```

**Using ImageMagick:**
```bash
compare ./tmp/baseline-homepage.png ./tmp/current-homepage.png ./tmp/diff-homepage.png
convert ./tmp/baseline.png ./tmp/current.png -compose difference ./tmp/diff.png
```

### Visual Diff Checklist

```
[ ] Capture baseline screenshot (before change)
[ ] Capture current screenshot (after change)
[ ] Run pixel comparison
[ ] If >0 pixels differ, FAIL
[ ] Review diff image manually
[ ] Distinguish expected vs unexpected changes
[ ] Update baseline if change is intentional
```

---

## PARTIAL vs UNCERTAIN (Strict Rules)

## PARTIAL is ONLY for ENVIRONMENTAL LIMITATIONS

| Situation | Valid PARTIAL? | Reason |
|-----------|--------------|--------|
| Playwright can't install | ✅ YES | Environment issue |
| Dev server won't start | ✅ YES | Environment issue |
| API timeout but functionality works | ✅ YES | Environment issue |
| "I'm not sure if this is a bug" | ❌ NO | Uncertainty |
| "This might be expected behavior" | ❌ NO | Uncertainty |
| "The test seems flaky" | ❌ NO | Uncertainty |

## PARTIAL Must Include

```markdown
## PARTIAL: [What couldn't be verified]

### Verified
- [x] Build passes
- [x] Tests pass (mostly)

### Could Not Verify
- [ ] Auth flow - Playwright not installed

### Next Steps
- Install Playwright: npm install -D @playwright/test
- Re-run verification after setup
```

## UNCERTAIN is NOT PARTIAL

If you're unsure whether something is a bug:
- Do MORE investigation
- Run more probes
- Check documentation
- Try to break it differently

**Uncertainty ≠ PARTIAL**

---

## Self-Update

If verification fails because this skill's instructions are outdated:
- Wrong dev server command → update dev server command
- Wrong port → update port
- Wrong ready signal → update ready signal
- New auth flow → add auth method

Make minimal targeted fixes only. Don't rewrite the whole skill.
