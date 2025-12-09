# 🚨 TROUBLESHOOTING: KYC Alert Masih "Menunggu Persetujuan Admin"

## 📸 Screenshot Issue
Alert menampilkan: **"Menunggu Persetujuan Admin"** (warna kuning/orange)
Padahal admin sudah verifikasi.

## 🔍 ROOT CAUSE ANALYSIS

Berdasarkan kode di `warga_home_page.dart`, alert kuning muncul ketika:
```dart
bool isKycPending = (hasKTPDocument || hasKKDocument) && 
                   !isKycComplete &&
                   (ktpStatus != KYCStatus.rejected && kkStatus != KYCStatus.rejected);
```

Artinya:
- ✅ User sudah upload dokumen (KTP atau KK atau keduanya)
- ❌ Tapi TIDAK SEMUA dokumen approved
- ❌ Dan tidak ada yang rejected

## 🎯 KEMUNGKINAN PENYEBAB

### Penyebab #1: Admin Hanya Approve SATU Dokumen ⚠️
**Kemungkinan tertinggi!**

Kondisi:
- Admin approve KTP ✅
- Admin BELUM approve KK ❌ (masih pending)

Atau sebaliknya:
- Admin approve KK ✅
- Admin BELUM approve KTP ❌ (masih pending)

**Cara Check:**
1. Login sebagai admin
2. Buka halaman verifikasi KYC
3. Check user yang bermasalah
4. Pastikan **KEDUA** dokumen (KTP dan KK) sudah di-approve

### Penyebab #2: Delay Update Firestore ⏱️

Kondisi:
- Admin sudah approve kedua dokumen
- Tapi data di Firestore belum ter-update
- Stream belum menerima update terbaru

**Cara Fix:**
1. User pull-to-refresh di dashboard
2. Logout dan login kembali
3. Tunggu 5-10 detik untuk stream update

### Penyebab #3: Status String Tidak Match 📝

Kondisi:
- Status di database bukan "approved" (lowercase)
- Bisa jadi "Approved" (capital) atau format lain

**Sudah diperbaiki di kode dengan:**
```dart
ktpStatus = KYCStatus.values.firstWhere(
  (e) => e.toString().split('.').last.toLowerCase() == statusStr?.toLowerCase(),
  orElse: () => KYCStatus.pending,
);
```

### Penyebab #4: Function approveDocument Tidak Jalan ❌

Kondisi:
- Admin klik approve tapi ada error
- Status dokumen tidak berubah
- Check console log admin untuk error

## 🔧 SOLUTION

### Solution 1: Pastikan Admin Approve KEDUA Dokumen

**Langkah:**
1. Login sebagai **ADMIN**
2. Buka **KYC Verification Page**
3. Cari user yang bermasalah
4. **Check status dokumen:**
   - KTP: harus "approved" ✅
   - KK: harus "approved" ✅
5. Jika salah satu masih "pending":
   - Klik tombol **Approve** pada dokumen tersebut
   - Tunggu konfirmasi success

### Solution 2: Re-approve Dokumen

Jika kedua dokumen sudah approved tapi alert masih muncul:

1. Admin **reject** salah satu dokumen
2. User **re-upload** dokumen
3. Admin **approve** lagi
4. Sistem akan re-check semua dokumen

### Solution 3: Manual Update Firestore (Emergency)

⚠️ **Hanya jika solusi lain tidak berhasil**

1. Buka Firebase Console
2. Masuk ke **Firestore Database**
3. Collection `kyc_documents`:
   - Filter by userId
   - Pastikan **ada 2 dokumen** (KTP dan KK)
   - Update field `status` menjadi `"approved"` untuk kedua dokumen
   - Update field `verifiedAt` dengan timestamp sekarang
   - Update field `verifiedBy` dengan admin ID

4. Collection `users`:
   - Cari user tersebut
   - Update field `status` menjadi `"approved"`
   - Update field `updatedAt` dengan timestamp sekarang

5. User **pull-to-refresh** atau **logout-login**

## 📊 Expected Database Structure

### Collection: `kyc_documents`

**Document 1 (KTP):**
```json
{
  "userId": "user123",
  "documentType": "ktp",
  "status": "approved",  ← HARUS "approved"
  "verifiedAt": "2024-12-08T10:30:00Z",
  "verifiedBy": "admin456",
  "blobName": "user123/kyc_ktp.webp",
  "uploadedAt": "2024-12-08T09:00:00Z"
}
```

**Document 2 (KK):**
```json
{
  "userId": "user123",
  "documentType": "kk",
  "status": "approved",  ← HARUS "approved"
  "verifiedAt": "2024-12-08T10:35:00Z",
  "verifiedBy": "admin456",
  "blobName": "user123/kyc_kk.webp",
  "uploadedAt": "2024-12-08T09:05:00Z"
}
```

### Collection: `users`

```json
{
  "id": "user123",
  "email": "user@example.com",
  "nama": "User Name",
  "status": "approved",  ← HARUS "approved"
  "role": "user",
  "updatedAt": "2024-12-08T10:35:00Z"
}
```

## 🧪 Testing Steps

### Test 1: Check Console Log
1. Buka browser DevTools (F12)
2. Tab Console
3. Login sebagai user
4. Buka dashboard
5. Cari log dengan format:
   ```
   🔍 ========== KYC STATUS CHECK ==========
   📦 Document count: 2
   📄 Document ID: xxx
      Type: ktp
      Status: approved
   📄 Document ID: yyy
      Type: kk
      Status: approved
   🎯 ========== FINAL STATUS ==========
      ✅ isKycComplete: true
      ⏳ isKycPending: false
   ```

### Test 2: Verify Alert Behavior
| KTP Status | KK Status | User Status | Expected Alert |
|------------|-----------|-------------|----------------|
| pending | - | pending | "Menunggu..." (Yellow) |
| approved | pending | pending | "Menunggu..." (Yellow) |
| approved | approved | approved | No Alert ✅ |
| rejected | - | unverified | "Lengkapi KYC" (Red) |

## 🎬 Quick Fix Checklist

Untuk admin:
- [ ] Login ke admin panel
- [ ] Buka KYC verification
- [ ] Cari user yang komplain
- [ ] Check KTP status → harus "approved"
- [ ] Check KK status → harus "approved"
- [ ] Jika salah satu pending, klik approve
- [ ] Konfirmasi success message

Untuk user:
- [ ] Pull-to-refresh dashboard
- [ ] Check apakah alert hilang
- [ ] Jika masih muncul, logout
- [ ] Login kembali
- [ ] Check dashboard lagi

## 📞 Support

Jika masalah masih berlanjut:
1. Screenshot console log (F12 → Console)
2. Screenshot Firestore data (`kyc_documents` collection)
3. Screenshot user status di Firestore (`users` collection)
4. Kirim ke developer

---
**Last Updated:** December 8, 2024  
**Status:** ✅ Enhanced logging added for debugging

