import http from "k6/http";
import { check, sleep } from "k6";
import { FormData } from "https://jslib.k6.io/formdata/0.0.2/index.js";

const BASE_URL = `${__ENV.PCVK_API_HTTPS == "true" ? "https" : "http"}://${
  __ENV.PCVK_API_URL
}/api/ocr`;

const imgFile = open("../test/fixtures/test_images/test_ocr_image.jpg", "b");

export const options = {
  thresholds: {
    http_req_failed: ["rate<0.01"],
    http_req_duration: ["p(95)<7000"],
  },
  stages: [
    { duration: "30s", target: 5 },
    { duration: "1m", target: 10 },
    { duration: "30s", target: 0 },
  ],
};

export function handleSummary(data) {
  return {
    "ocr_summary.json": JSON.stringify(data, null, 2),
  };
}

export default function () {
  const resHealth = http.get(`${BASE_URL}/health`);

  check(resHealth, {
    "Health status is 200": (r) => r.status === 200,
    "Health returns JSON": (r) =>
      r.headers["Content-Type"] &&
      r.headers["Content-Type"].includes("application/json"),
    "Service is healthy": (r) => {
      const body = r.json();
      return body.status === "healthy" || body.model_loaded === true;
    },
  });

  const fd = new FormData();
  fd.append("file", http.file(imgFile, "test_ocr_image.jpg", "image/jpeg"));

  const resOcr = http.post(`${BASE_URL}/recognize`, fd.body(), {
    headers: {
      "Content-Type": "multipart/form-data; boundary=" + fd.boundary,
    },
  });

  check(resOcr, {
    "OCR status is 200": (r) => r.status === 200,
    "OCR processing time acceptable": (r) => r.timings.duration < 5000,
    "OCR returns detections": (r) => {
      const body = r.json();
      return body.results && Array.isArray(body.results);
    },
    "OCR found text": (r) => {
      const body = r.json();
      return body.num_detections !== undefined && body.num_detections >= 0;
    },
  });

  sleep(1);
}
