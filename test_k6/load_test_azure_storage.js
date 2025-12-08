import http from "k6/http";
import { check, sleep, fail } from "k6";
import { FormData } from "https://jslib.k6.io/formdata/0.0.2/index.js";
import { getAuthToken } from "./utils.js";

const BASE_URL = `${__ENV.PCVK_API_HTTPS == "true" ? "https" : "http"}://${
  __ENV.PCVK_API_URL
}/api`;
var FIREBASE_TOKEN = "";
const imgFile = open("../test/fixtures/test_images/1.jpg", "b");

export const options = {
  thresholds: {
    http_req_failed: ["rate<0.01"], // Error rate harus di bawah 1%
    http_req_duration: ["p(95)<5000"], // 95% request selesai di bawah 5 detik
  },
  stages: [
    { duration: "30s", target: 5 },
    { duration: "1m", target: 50 },
    { duration: "30s", target: 0 },
  ],
};

export function handleSummary(data) {
  return {
    "storage_summary.json": JSON.stringify(data, null, 2),
  };
}

export function setup() {
  FIREBASE_TOKEN = getAuthToken();
  console.log(`Token Firebase obtained: ${FIREBASE_TOKEN ? 'Yes' : 'No'}`);
  // console.log(`Token length: ${FIREBASE_TOKEN ? FIREBASE_TOKEN.length : 0}`);
  // console.log(`Token preview: ${FIREBASE_TOKEN ? FIREBASE_TOKEN.substring(0, 20) + '...' : 'N/A'}`);
  
  if (!FIREBASE_TOKEN) {
    console.error("Failed to obtain Firebase token in setup");
    return { token: "" };
  }
  
  // Wait a bit for Firebase token to propagate
  sleep(2);
  
  // Verify token works by making a test request with retries
  const testUrl = `${BASE_URL}/storage/private/get-images?filename_prefix=test`;
  let testRes;
  let retries = 3;
  
  for (let i = 0; i < retries; i++) {
    testRes = http.get(testUrl, {
      headers: { Authorization: `Bearer ${FIREBASE_TOKEN}` }
    });
    
    if (testRes.status !== 401) {
      console.log(`Token validated successfully on attempt ${i + 1} (status: ${testRes.status})`);
      break;
    }
    
    if (i < retries - 1) {
      console.log(`Token validation attempt ${i + 1} failed with 401, retrying...`);
      sleep(2);
    } else {
      console.error(`Token validation failed after ${retries} attempts: ${testRes.body}`);
    }
  }
  
  return { token: FIREBASE_TOKEN };
}

function getHeaders(data) {
  return {
    Authorization: `Bearer ${data.token}`,
  };
}

export default function (data) {
  if (!data.token) {
    console.error(
      "ERROR: Token Firebase tidak ditemukan. Gunakan -e TOKEN=..."
    );
    fail("Token missing");
  }

  let uploadedBlobName = null;
  const isPrivate = true;
  const uniqueId = `k6-${Date.now()}-${__VU}-${__ITER}`; 

  const uploadEndpoint = isPrivate
    ? "storage/private/upload"
    : "storage/public/upload";

  // Membangun URL dengan Query Params manual
  const uploadUrl = `${BASE_URL}/${uploadEndpoint}?prefix_name=loadtest&custom_name=${uniqueId}.jpg`;

  const fd = new FormData();
  fd.append("file", http.file(imgFile, "1.jpg", "image/jpeg"));

  // Header content-type multipart + boundary digabung dengan Header Auth
  const uploadHeaders = Object.assign({}, getHeaders(data), {
    "Content-Type": "multipart/form-data; boundary=" + fd.boundary,
  });

  const resUpload = http.post(uploadUrl, fd.body(), { headers: uploadHeaders });

  check(resUpload, {
    "Upload status is 200/201": (r) => r.status === 200 || r.status === 201,
    "Upload returns blob_name": (r) => {
      const json = r.json();
      if (json && json.blob_name) {
        uploadedBlobName = json.blob_name;
        return true;
      }
      return false;
    },
  });

  // Jika upload gagal, kita tidak bisa lanjut ke delete
  if (!uploadedBlobName) {
    console.log(
      `Upload failed for VU ${__VU}, status: ${resUpload.status} body: ${resUpload.body}`
    );
    sleep(1);
    return;
  }

  const getEndpoint = isPrivate
    ? "storage/private/get-images"
    : "storage/public/get-images";

  // Filter berdasarkan prefix file yang baru kita upload
  const getUrl = `${BASE_URL}/${getEndpoint}?filename_prefix=loadtest${uniqueId}`;

  const resGet = http.get(getUrl, { headers: getHeaders(data) });

  check(resGet, {
    "Get Images status is 200": (r) => r.status === 200,
    "Get Images returns correct UserID": (r) => r.json("user_id") !== undefined,
    "Get Images contains uploaded file": (r) => {
      const data = r.json();
      // Pastikan array images ada dan mengandung blobName yang baru diupload
      return data.images && data.images.length > 0;
    },
  });

  const deleteEndpoint = isPrivate
    ? "storage/private/image"
    : "storage/public/image";
  const deleteUrl = `${BASE_URL}/${deleteEndpoint}/${uploadedBlobName}`;

  const resDelete = http.del(deleteUrl, null, { headers: getHeaders(data) });

  check(resDelete, {
    "Delete status is 200": (r) => r.status === 200,
  });

  sleep(1);
}
