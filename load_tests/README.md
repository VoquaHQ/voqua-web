# Baseline Load Test: Voting Flow

## Goal

Determine whether the app can handle **30,000–50,000 users voting over a 2-week period**, with traffic moderately spread and peaks around launch. The primary question: **how many people can open a ballot and submit votes simultaneously?**

---

## What We're Testing

The anonymous (unauthenticated) voting flow — the most common path:

| Step | Request | What happens server-side |
|------|---------|--------------------------|
| 1 | `GET /ballots/:slug` | Loads ballot + options from DB, renders HTML with CSRF token |
| 2 | `POST /ballots/:slug/submit_votes` | Validates quadratic vote data, creates a `Vote` record (pending), creates `BallotMembership` |

No login is required. Users arrive via a shared link, see the ballot, and submit votes.

### Why These Endpoints Matter

- **`GET /ballots/:slug`** — Does a `Ballot.includes(:options).find_by(slug:)` query + HTML render. Read-heavy, should scale well.
- **`POST /ballots/:slug/submit_votes`** — The bottleneck. Each submission: validates vote data, inserts a `Vote` row, inserts a `BallotMembership` row. Two DB writes per vote. With **SQLite in production** (single-writer lock), concurrent writes will serialize.

---

## Traffic Model & Concurrency Estimates

| Parameter | Value |
|-----------|-------|
| Total users over 2 weeks | 30,000 – 50,000 |
| Active hours per day | ~12h (8am–8pm) |
| Average daily users | ~2,150 – 3,571 |
| Average users per hour | ~180 – 298 |
| **Peak day (launch)** | **~15,000 users (30% of total)** |
| **Peak hour on launch day** | **~3,750 users** |
| **Peak concurrent sessions** | **~200–500 simultaneous users** |

> **Key insight:** Each user makes 2 HTTP requests (view ballot + submit vote). At peak, that's ~7,500 requests/hour or **~125 requests/minute** — but the real question is how many *concurrent* write operations the SQLite DB can handle.

---

## Tool: k6

We recommend [k6](https://grafana.com/docs/k6/latest/) — it's open source, scriptable in JavaScript, and designed for this kind of HTTP load testing.

### Install k6

```bash
# macOS
brew install k6

# Linux (Debian/Ubuntu)
sudo gpg -k
sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D68
echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
sudo apt-get update && sudo apt-get install k6

# Docker
docker run --rm -i grafana/k6 run - <script.js
```

---

## Test Setup

### 1. Prepare the Target Environment

You need a running instance of the app with a ballot that:
- Is **public** (not private) — so no auth check in `check_ballot_permissions`
- Has an `ends_at` in the future — otherwise users get redirected to results
- Has **multiple options** (e.g., 10) — to match realistic ballot size

You can use the production environment or a staging copy. If testing against production, be aware that the votes created will be real (pending) votes.

### 2. Get the Ballot Slug and Option IDs

Visit the ballot page in a browser. Note:
- The **ballot slug** from the URL: `/ballots/<slug>`
- The **option IDs** from the page source — look for `data-option-id="123"` attributes, or query the DB:
  ```ruby
  Ballot.find_by(slug: "your-slug").options.pluck(:id)
  ```

---

## Test Scenarios

### Scenario 1: Smoke Test (sanity check)

Quick check that the script works and endpoints respond correctly.

```bash
k6 run \
  --vus 5 \
  --duration 1m \
  -e BASE_URL=https://your-app.example.com \
  -e BALLOT_SLUG=your-ballot-slug \
  -e OPTION_IDS=1,2,3,4,5,6,7,8,9,10 \
  load_tests/vote_flow.js
```

**Expected:** All requests succeed, response times < 500ms.

### Scenario 2: Normal Day (~50 concurrent users)

Simulates a typical day with moderate traffic.

```bash
k6 run \
  --stage 2m:10,5m:30,5m:50,5m:30,2m:10,1m:0 \
  -e BASE_URL=https://your-app.example.com \
  -e BALLOT_SLUG=your-ballot-slug \
  -e OPTION_IDS=1,2,3,4,5,6,7,8,9,10 \
  load_tests/vote_flow.js
```

**Expected:** p95 response times under 2s, < 1% error rate.

### Scenario 3: Launch Day Peak (~500 concurrent users)

Simulates the announcement going live and a surge of voters.

```bash
k6 run \
  --stage 1m:50,2m:200,3m:500,5m:500,3m:200,2m:50,2m:0 \
  -e BASE_URL=https://your-app.example.com \
  -e BALLOT_SLUG=your-ballot-slug \
  -e OPTION_IDS=1,2,3,4,5,6,7,8,9,10 \
  load_tests/vote_flow.js
```

**Expected:** This is the key test. Watch for:
- Response time degradation (especially on `submit_votes`)
- SQLite `SQLITE_BUSY` errors surfacing as 500s
- Connection timeouts

### Scenario 4: Stress Test — Find the Breaking Point

Ramp up until things break to find the ceiling.

```bash
k6 run \
  --stage 2m:100,3m:300,3m:600,3m:1000,2m:1000,2m:0 \
  -e BASE_URL=https://your-app.example.com \
  -e BALLOT_SLUG=your-ballot-slug \
  -e OPTION_IDS=1,2,3,4,5,6,7,8,9,10 \
  load_tests/vote_flow.js
```

**What to watch:** At what VU count do you start seeing > 5% error rate? What's the max throughput (successful requests/sec)?

---

## The k6 Test Script

Create `load_tests/vote_flow.js`:

```javascript
import http from "k6/http";
import { check, group, sleep } from "k6";
import { Rate, Trend, Counter } from "k6/metrics";

// ---------------------------------------------------------------------------
// Configuration (passed via -e flags)
// ---------------------------------------------------------------------------
const BASE_URL = __ENV.BASE_URL || "http://localhost:3000";
const BALLOT_SLUG = __ENV.BALLOT_SLUG || "test-ballot";
const OPTION_IDS = __ENV.OPTION_IDS
  ? __ENV.OPTION_IDS.split(",").map((id) => parseInt(id.trim()))
  : [];
const CREDITS_PER_BALLOT = 99;

// ---------------------------------------------------------------------------
// Custom Metrics
// ---------------------------------------------------------------------------
const voteSuccess = new Rate("vote_submit_success");
const ballotLoadTime = new Trend("ballot_page_duration", true);
const voteSubmitTime = new Trend("vote_submit_duration", true);
const votesSubmitted = new Counter("votes_submitted_total");
const votesFailed = new Counter("votes_failed_total");

// ---------------------------------------------------------------------------
// Thresholds
// ---------------------------------------------------------------------------
export const options = {
  thresholds: {
    http_req_duration: ["p(95)<2000", "p(99)<5000"],
    vote_submit_duration: ["p(95)<3000"],
    vote_submit_success: ["rate>0.95"],
    http_req_failed: ["rate<0.05"],
  },
  insecureSkipTLSVerify: true,
};

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/** Extract Rails CSRF token from HTML */
function extractCsrfToken(html) {
  const m =
    html.match(/name="csrf-token"\s+content="([^"]+)"/) ||
    html.match(/name="authenticity_token"\s+value="([^"]+)"/) ||
    html.match(/value="([^"]+)"\s+name="authenticity_token"/);
  return m ? m[1] : null;
}

/** Extract option IDs from page HTML (fallback if not provided via env) */
function extractOptionIdsFromHtml(html) {
  const ids = [];
  const re = /data-option-id="(\d+)"/g;
  let m;
  while ((m = re.exec(html)) !== null) ids.push(parseInt(m[1]));
  return ids;
}

/**
 * Generate a random quadratic vote payload.
 * Distributes votes randomly across options, respecting the 99-credit budget.
 * Each option gets either `for` or `against` votes (never both).
 * Cost per option = (number_of_votes)^2.
 */
function generateVotes(optionIds) {
  const votes = {};
  let remaining = CREDITS_PER_BALLOT;

  // Initialize all options to 0
  for (const id of optionIds) {
    votes[id] = { for: 0, against: 0 };
  }

  // Shuffle and vote on a random subset
  const shuffled = [...optionIds].sort(() => Math.random() - 0.5);
  const count = Math.floor(Math.random() * Math.min(5, shuffled.length)) + 1;

  for (let i = 0; i < count && remaining > 0; i++) {
    const id = shuffled[i];
    const dir = Math.random() > 0.3 ? "for" : "against";
    const maxVotes = Math.floor(Math.sqrt(remaining));
    if (maxVotes === 0) break;
    const n = Math.floor(Math.random() * maxVotes) + 1;
    votes[id][dir] = n;
    remaining -= n * n;
  }

  return votes;
}

/** Build URL-encoded form body matching Rails form format */
function buildFormData(votes, csrfToken) {
  const data = { authenticity_token: csrfToken };
  for (const [id, v] of Object.entries(votes)) {
    data[`votes[${id}][for]`] = String(v.for);
    data[`votes[${id}][against]`] = String(v.against);
  }
  return data;
}

// ---------------------------------------------------------------------------
// Main Flow: every VU iteration = one anonymous user voting
// ---------------------------------------------------------------------------
export default function () {
  const ballotUrl = `${BASE_URL}/ballots/${BALLOT_SLUG}`;

  // Step 1: Load the ballot page
  const page = http.get(ballotUrl);
  ballotLoadTime.add(page.timings.duration);

  const pageOk = check(page, {
    "ballot page loaded": (r) => r.status === 200,
    "page has vote form": (r) => r.body.includes("submit_votes"),
  });

  if (!pageOk) return; // skip this iteration if page didn't load

  const csrf = extractCsrfToken(page.body);
  if (!csrf) {
    console.warn("CSRF token not found — skipping vote");
    return;
  }

  // Use provided option IDs or extract from HTML
  const ids = OPTION_IDS.length > 0 ? OPTION_IDS : extractOptionIdsFromHtml(page.body);
  if (ids.length === 0) {
    console.warn("No option IDs found — skipping vote");
    return;
  }

  // Think time: user reads ballot (3–15s)
  sleep(Math.random() * 12 + 3);

  // Step 2: Submit votes
  const votes = generateVotes(ids);
  const formData = buildFormData(votes, csrf);

  const res = http.post(`${ballotUrl}/submit_votes`, formData, {
    redirects: 0, // Rails 302-redirects on success; don't follow
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
  });

  voteSubmitTime.add(res.timings.duration);

  const ok = check(res, {
    "vote accepted (302 or 200)": (r) => r.status === 302 || r.status === 200,
    "no server error": (r) => r.status < 500,
  });

  if (ok) {
    voteSuccess.add(1);
    votesSubmitted.add(1);
  } else {
    voteSuccess.add(0);
    votesFailed.add(1);
  }

  // Brief pause before next iteration
  sleep(Math.random() * 2 + 1);
}

// ---------------------------------------------------------------------------
// Setup: verify target is reachable
// ---------------------------------------------------------------------------
export function setup() {
  console.log(`Target: ${BASE_URL} | Ballot: ${BALLOT_SLUG}`);
  const health = http.get(`${BASE_URL}/up`);
  check(health, { "app is reachable": (r) => r.status === 200 });
}
```

> **Tip:** You can paste this script directly or save it as `load_tests/vote_flow.js` in the repo.

---

## How to Read the Results

After a k6 run, you'll see output like:

```
  scenarios: (100.00%) 1 scenario, 500 max VUs, ...

     ✓ ballot page loaded
     ✓ vote accepted (302 or 200)
     ✗ no server error
      ↳  92% — ✓ 4600 / ✗ 400

     ballot_page_duration.......: avg=245ms  p(95)=890ms
     vote_submit_duration.......: avg=1200ms p(95)=3500ms  ← WATCH THIS
     http_req_duration..........: avg=723ms  p(95)=2100ms
     http_req_failed............: 8.00%                     ← AND THIS
     vote_submit_success........: 92.00%
     votes_submitted_total......: 4600
     votes_failed_total.........: 400
```

### Key Metrics to Focus On

| Metric | What it means | Target |
|--------|--------------|--------|
| `vote_submit_duration p(95)` | 95th percentile latency for vote submission | < 3 seconds |
| `vote_submit_success` | % of votes that were accepted | > 95% |
| `http_req_failed` | % of all HTTP requests that returned errors | < 5% |
| `ballot_page_duration p(95)` | How fast the ballot page loads under load | < 2 seconds |
| `http_req_duration p(95)` | Overall request latency | < 2 seconds |

### What to Look For

1. **SQLite write contention:** If `vote_submit_duration` spikes dramatically as VUs increase but `ballot_page_duration` stays stable, the bottleneck is SQLite's single-writer lock. This is the most likely failure mode.

2. **Error rate vs VU count:** Note at what concurrency level the error rate crosses 5%. That's effectively the app's ceiling.

3. **Puma thread saturation:** The app runs Puma (see `Gemfile`). Default thread pool is 5 (`RAILS_MAX_THREADS`). If all threads are blocked waiting on SQLite writes, new requests queue up. Check if response times suddenly jump — that's thread exhaustion.

4. **Timeout errors:** If you see connection timeouts, the server's request queue is full. The app is overwhelmed.

---

## Known Concerns & Predictions

### SQLite is the bottleneck

The app uses **SQLite in production** (`database.yml` → `storage/production.sqlite3`). SQLite uses a single-writer lock — only one write transaction can execute at a time. Every vote submission does:
1. `INSERT INTO votes` (create vote record)
2. `INSERT INTO ballot_memberships` (create membership if not exists)

With the default `timeout: 5000` (5 seconds) in `database.yml`, concurrent writers will wait up to 5 seconds for the lock. Beyond that, they'll get `SQLITE_BUSY` errors.

**Rough estimate:** If each write takes ~5–20ms, SQLite can handle ~50–200 writes/sec. At 500 concurrent users all submitting within a few seconds, you'd need ~500 writes in a short burst, which will likely cause queuing and some failures.

### Puma thread pool

Default `RAILS_MAX_THREADS` is 5. Each vote submission holds a thread while waiting for the SQLite write lock. With 5 threads and a 5-second lock timeout, the server can only process 5 concurrent vote submissions. **This is likely too low for launch-day traffic.**

Check what `RAILS_MAX_THREADS` and Puma's worker count are set to in the deployment.

---

## Recommendations Based on Results

Depending on what the tests show, here are likely next steps:

| Finding | Recommendation |
|---------|---------------|
| SQLite write contention (high p95 on writes, errors at > 50 VUs) | Migrate to PostgreSQL, or use SQLite WAL mode + increase busy_timeout |
| Puma thread exhaustion | Increase `RAILS_MAX_THREADS` and add Puma workers (processes) |
| Everything fine up to 200 VUs | App can likely handle the expected load with modest tuning |
| Failures at < 50 VUs | Serious architectural concern — consider caching, async writes, or DB migration |

---

## Quick Reference: Useful Commands

```bash
# Run smoke test against local dev server
k6 run --vus 5 --duration 1m -e BASE_URL=http://localhost:3000 -e BALLOT_SLUG=my-ballot -e OPTION_IDS=1,2,3 load_tests/vote_flow.js

# Run launch-day simulation against staging
k6 run --stage 1m:50,2m:200,3m:500,5m:500,3m:200,2m:50,2m:0 -e BASE_URL=https://staging.example.com -e BALLOT_SLUG=test-ballot -e OPTION_IDS=1,2,3,4,5,6,7,8,9,10 load_tests/vote_flow.js

# Output results as JSON for further analysis
k6 run --out json=results.json --stage ... load_tests/vote_flow.js

# Run with Grafana Cloud k6 (if you have an account)
k6 cloud load_tests/vote_flow.js
```
