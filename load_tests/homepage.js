import http from "k6/http";
import { check, sleep } from "k6";

export const options = {
  stages: [
    { duration: "30s", target: 10 }, // ramp up to 10 users
    { duration: "1m", target: 10 },  // hold
    { duration: "15s", target: 0 },  // ramp down
  ],
  thresholds: {
    http_req_duration: ["p(95)<2000"], // 95% of requests under 2s
    http_req_failed: ["rate<0.01"],    // less than 1% errors
  },
};

// const BASE_URL = "https://sprind.voqua.io";
const BASE_URL = "http://167.233.13.197";

export default function () {
  const res = http.get(BASE_URL + "/");

  check(res, {
    "status is 200": (r) => r.status === 200,
    "response time < 2s": (r) => r.timings.duration < 2000,
  });

  sleep(1);
}
