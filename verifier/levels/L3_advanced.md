# L3: Advanced — Adversarial Probes & Visual Testing

**When**: Deep verification, finding edge cases, visual regression testing

Extends L1+L2 with adversarial testing and visual verification.

---

## Adversarial Probes

These probes try to break the system:

- **Concurrency** — parallel requests: `curl url & curl url & wait`
- **Boundary values** — 0, -1, empty string, very long strings (10KB+), unicode (中文中文), MAX_INT
- **Idempotency** — same POST twice: second should be no-op or error
- **Orphan operations** — DELETE /api/users/99999 (non-existent)
- **Error cascades** — trigger error, verify cleanup happens

---

## Spot-Check Re-verification (Critical for PASS)

When verification reports PASS, you MUST spot-check before accepting.

### Spot-Check Rules

```
1. Pick 2-3 commands from the report randomly
2. Re-run them EXACTLY as reported
3. Compare output with reported output
4. If mismatch → Resume verifier with specifics
```

### Spot-Check Examples

**Example: Report says PASS but no command block**

```
### Check: API returns user list
**Result: PASS**

❌ INVALID - No command run block
→ Resume verifier: "Your report lacks command output for this check"
```

**Example: Output mismatches**

```
### Check: curl /api/users returns 200
**Reported output:** {"users": [...]}
**Your re-run:** {"error": "unauthorized"}

❌ MISMATCH - Auth might be required
→ Resume verifier: "Output doesn't match, auth may be needed"
```

### Spot-Check Decision Tree

```
Report says PASS
    ↓
Pick 2-3 commands randomly
    ↓
Re-run each command
    ↓
Output matches?
├── YES → Accept PASS
└── NO  → "Resume verifier with mismatch details"
```

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
      path: `/tmp/screenshot-${name}-${Date.now()}.png`,
      fullPage: false
    });
  }

  await browser.close();
}
```

**With curl + wkhtmltoimage:**
```bash
wkhtmltoimage --quality 90 http://localhost:3000 /tmp/screenshot-homepage.png
```

### Screenshot Comparison

**Using Playwright + Pixel Match:**
```bash
npm install -D pixelmatch pngjs

node -e "
const { PNG } = require('pngjs');
const pixelmatch = require('pixelmatch');
const fs = require('fs');

const img1 = PNG.sync.read(fs.readFileSync('/tmp/baseline-homepage.png'));
const img2 = PNG.sync.read(fs.readFileSync('/tmp/current-homepage.png'));
const diff = new PNG(img1.width, img1.height);

const numDiffPixels = pixelmatch(img1, img2, diff, {
  threshold: 0.1,
  includeAA: true
});

fs.writeFileSync('/tmp/diff-homepage.png', PNG.sync.write(diff));

if (numDiffPixels > 0) {
  console.log('FAIL: Screenshots differ by ' + numDiffPixels + ' pixels');
} else {
  console.log('PASS: Screenshots identical');
}
"
```

**Using ImageMagick:**
```bash
compare /tmp/baseline-homepage.png /tmp/current-homepage.png /tmp/diff-homepage.png
convert /tmp/baseline.png /tmp/current.png -compose difference /tmp/diff.png
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
