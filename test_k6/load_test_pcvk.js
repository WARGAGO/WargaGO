import http from "k6/http";
import { check, sleep, group } from "k6";
import { FormData } from "https://jslib.k6.io/formdata/0.0.2/index.js";

const BASE_URL = `${__ENV.PCVK_API_HTTPS == "true" ? "https" : "http"}://${
  __ENV.PCVK_API_URL
}/api/pcvk`;
const imgFile = open("../test/fixtures/test_images/1.jpg", "b");

export const options = {
  thresholds: {
    http_req_failed: ["rate<0.01"], // Error rate harus di bawah 1%
    http_req_duration: ["p(95)<7000"], // 95% request harus selesai di bawah 7 detik
  },
  stages: [
    { duration: "30s", target: 5 },
    { duration: "1m", target: 25 },
    { duration: "30s", target: 0 },
  ],
};

const defaultParams = {
  use_segmentation: "true",
  seg_method: "u2netp",
  model_type: "mlpv2_auto-clahe",
  apply_brightness_contrast: "true",
};

function buildQueryString(params) {
  return Object.keys(params)
    .map(
      (key) => `${encodeURIComponent(key)}=${encodeURIComponent(params[key])}`
    )
    .join("&");
}

export function handleSummary(data) {
  return {
    "pcvk_summary.json": JSON.stringify(data, null, 2),
  };
}

export default function () {
  group("General Endpoints", () => {
    // GET Health
    const resHealth = http.get(`${BASE_URL}/health`);
    check(resHealth, {
      "Health is 200": (r) => r.status === 200,
      "Health has status field": (r) => r.json("status") !== undefined,
    });

    // GET Classes
    const resClasses = http.get(`${BASE_URL}/classes`);
    check(resClasses, {
      "Classes is 200": (r) => r.status === 200,
      "Classes list not empty": (r) => r.json("classes").length > 0,
    });

    // GET Models
    const resModels = http.get(`${BASE_URL}/models`);
    check(resModels, {
      "Models is 200": (r) => r.status === 200,
      "Total models > 0": (r) => r.json("total_models") > 0,
    });
  });

  // 2. Test Endpoint Predict (Single File Upload)
  group("Prediction Endpoint", () => {
    const queryString = buildQueryString(defaultParams);
    const url = `${BASE_URL}/predict?${queryString}`;

    const fd = new FormData();
    fd.append("file", http.file(imgFile, "1.jpg", "image/jpeg"));

    const resPredict = http.post(url, fd.body(), {
      headers: {
        "Content-Type": "multipart/form-data; boundary=" + fd.boundary,
      },
    });

    check(resPredict, {
      "Predict is 200": (r) => r.status === 200,
      "Predict returns filename": (r) => r.json("filename") !== undefined,
    });
  });

  // 3. Test Endpoint Batch Predict (Multiple File Upload)
  group("Batch Prediction Endpoint", () => {
    const queryString = buildQueryString(defaultParams);
    const url = `${BASE_URL}/batch-predict?${queryString}`;

    const fd = new FormData();
    fd.append("files", http.file(imgFile, "img1.jpg", "image/jpeg"));
    fd.append("files", http.file(imgFile, "img2.jpg", "image/jpeg"));

    const resBatch = http.post(url, fd.body(), {
      headers: {
        "Content-Type": "multipart/form-data; boundary=" + fd.boundary,
      },
    });

    check(resBatch, {
      "Batch Predict is 200": (r) => r.status === 200,
      "Batch returns predictions array": (r) => r.json("results") !== undefined,
    });
  });

  sleep(1);
}
