# 🎯 ACTION REQUIRED - Firestore Index Error

## ⚠️ Error Saat Ini

Ada **3 error** Firestore Index yang perlu diperbaiki:

```
Error 1: Query(users where role==user order by -createdAt) failed
Error 2: Query(users where statusin[unverified,pending] order by -createdAt) failed
Error 3: Query(users where status==approved order by -createdAt) failed
```

---

## ✅ KLIK 3 LINK INI UNTUK FIX CEPAT

### **Index 1: role + createdAt** (Auto-create)
```
https://console.firebase.google.com/v1/r/project/pbl-2025-35a1c/firestore/indexes?create_composite=Ckxwcm9qZWN0cy9wYmwtMjAyNS0zNWExYy9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvdXNlcnMvaW5kZXhlcy9fEAEaCAoEcm9sZRABGg0KCWNyZWF0ZWRBdBACGgwKCF9fbmFtZV9fEAI
```

### **Index 2: status (whereIn) + createdAt** (Auto-create)
```
https://console.firebase.google.com/v1/r/project/pbl-2025-35a1c/firestore/indexes?create_composite=Ckxwcm9qZWN0cy9wYmwtMjAyNS0zNWExYy9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvdXNlcnMvaW5kZXhlcy9fEAEaCgoGc3RhdHVzEAEaDQoJY3JlYXRlZEF0EAIaDAoIX19uYW1lX18QAg
```

### **Index 3: Manual Create**
Buka [Firebase Console](https://console.firebase.google.com/project/pbl-2025-35a1c/firestore/indexes) dan buat manual dengan:
- Collection: `users`
- Field 1: `status` → **Ascending**
- Field 2: `createdAt` → **Descending**

---

## 🚀 CARA TERCEPAT (Gunakan Script)

Jalankan script:
```powershell
.\create_firestore_indexes.ps1
```

---

## 📋 TODO Checklist

### Immediate (Sekarang):
- [ ] **KLIK LINK 1** → Auto-create Index: `role` + `createdAt`
  - Tunggu halaman Firebase Console terbuka
  - Klik tombol "Create Index"
  - Status akan jadi "Building..."
  
- [ ] **KLIK LINK 2** → Auto-create Index: `status` (whereIn) + `createdAt`
  - Tunggu halaman Firebase Console terbuka
  - Klik tombol "Create Index"
  - Status akan jadi "Building..."

- [ ] **MANUAL Index 3** → Create di Firebase Console:
  - Buka [Firestore Indexes](https://console.firebase.google.com/project/pbl-2025-35a1c/firestore/indexes)
  - Klik "Create Index"
  - Collection ID: `users`
  - Field 1: `status` → **Ascending** ⬆️
  - Field 2: `createdAt` → **Descending** ⬇️
  - Klik "Create"

### After Indexes Built:
- [ ] Verify semua index status = "Enabled" (hijau)
- [ ] Restart aplikasi Flutter
- [ ] Test Kelola Pengguna:
  - [ ] Filter by role (Admin/User)
  - [ ] Filter by status (Pending/Approved/Unverified)
  - [ ] Approve user
  - [ ] Reject user
  - [ ] Change role
  - [ ] Delete user

---

## ⏱️ Estimasi Waktu

- Create 3 indexes: **5 menit**
- Build indexes: **5-10 menit**
- Restart + Test: **2 menit**
- **TOTAL: ~15 menit**

---

## 📚 Dokumentasi

- **Quick Fix:** `QUICK_FIX_FIRESTORE_INDEX.md`
- **Detailed Guide:** `FIRESTORE_INDEXES_REQUIRED.md`
- **Timestamp Fix:** `FIX_KELOLA_PENGGUNA_TIMESTAMP.md`

---

## 🎯 Status

| Component | Status |
|-----------|--------|
| UserModel Timestamp Parsing | ✅ FIXED |
| detail_pengguna_page.dart | ✅ NO ERROR |
| Firestore Index 1 | ⏳ PENDING (Action Required) |
| Firestore Index 2 | ⏳ PENDING (Action Required) |
| Firestore Index 3 | ⏳ PENDING (Action Required) |
| Kelola Pengguna Functionality | ⏳ BLOCKED (Need indexes) |

---

**Priority:** 🔴 HIGH
**Blocker:** Yes (Kelola Pengguna tidak bisa digunakan tanpa indexes)
**Difficulty:** 🟢 EASY (Tinggal klik link + tunggu)

