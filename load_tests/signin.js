import http from "k6/http";
import { check, fail, sleep } from "k6";
import { SharedArray } from "k6/data";

// Generate the users file before running:
//   rails load_test:generate_users[50] > load_tests/users.json
//
// Then run:
//   k6 run load_tests/signin.js
const users = new SharedArray("users", function () {
  return JSON.parse(open("./users.json"));
});

export const options = {
  stages: [
    { duration: "30s", target: 10 },
    { duration: "1m", target: 10 },
    { duration: "15s", target: 0 },
  ],
  thresholds: {
    http_req_duration: ["p(95)<3000"],
    http_req_failed: ["rate<0.01"],
  },
};

const BASE_URL = "http://167.233.13.197";

export default function () {
  const user = users[__VU % users.length];
  const jar = http.cookieJar();

  // Consume magic link → sets session cookie
  const magicLinkRes = http.get(
    `${BASE_URL}/users/magic_link?token=${encodeURIComponent(user.token)}`,
    { redirects: 5, jar }
  );

  const signedIn = check(magicLinkRes, {
    "magic link: redirected to app": (r) =>
      r.status === 200 || r.status === 302,
  });

  if (!signedIn) {
    fail(`Magic link failed for ${user.email}: status ${magicLinkRes.status}`);
  }

  // Visit dashboard after sign-in
  const dashRes = http.get(`${BASE_URL}/my`, { jar });
  check(dashRes, {
    "dashboard: status 200": (r) => r.status === 200,
    "dashboard: response time < 3s": (r) => r.timings.duration < 3000,
  });

  sleep(1);
}
