# 🔧 FIX: KYC Alert Dashboard - Problem & Solution

## 📋 Problem Description (Updated)

**Issue 1 (FIXED):** Alert KYC di dashboard warga tidak menampilkan status yang benar setelah user mengisi KYC sampai selesai.

**Issue 2 (FIXED):** Alert masih menampilkan "Menunggu Persetujuan Admin" padahal admin sudah approve SEMUA dokumen KYC.

**Symptoms:**
- User sudah upload KTP dan KK sampai step selesai
- Admin sudah approve KTP dan KK
- Tapi alert di dashboard masih menampilkan "Menunggu Persetujuan Admin" ❌
- Seharusnya alert hilang atau menampilkan status approved ✅

## 🔍 Root Cause Analysis (Updated)

### Problem 1: Dashboard Logic
**File:** `lib/features/warga/home/pages/warga_home_page.dart`

**Masalah:**
1. Logika pengecekan KYC hanya menggunakan `userStatus` dari koleksi `users`
2. Tidak memeriksa dokumen KYC yang benar-benar ada di koleksi `kyc_documents`
3. Kondisi `isKycComplete` terlalu ketat - mengharuskan `userStatus == 'approved'`

**Kode Lama:**
```dart
// Hanya cek userStatus, tidak cek dokumen KYC
final bool isApproved = userStatus == 'approved';
final bool isPending = userStatus == 'pending';
```

### Problem 2: Approval Logic
**File:** `lib/core/services/kyc_service.dart`

**Masalah:**
1. Fungsi `approveDocument()` langsung mengupdate `userStatus` ke 'approved' saat approve 1 dokumen
2. Tidak memeriksa apakah SEMUA dokumen KYC (KTP dan KK) sudah approved
3. Ini menyebabkan inkonsistensi: userStatus='approved' tapi baru 1 dokumen yang approved

**Kode Lama:**
```dart
// Langsung update user status tanpa cek dokumen lain
await _firestore.collection('users').doc(kycDoc.userId).update({
  'status': 'approved',
  'updatedAt': Timestamp.now(),
});
```

## ✅ Solution Implemented (Updated)

### Fix 1: Dashboard Logic (warga_home_page.dart)

**Changes Made:**

1. **Changed to StatefulWidget**
   - Dari `StatelessWidget` menjadi `StatefulWidget`
   - Memungkinkan penggunaan `StreamBuilder` untuk real-time updates

2. **Added KYC Document Stream**
   - Menggunakan `KYCService.getUserKYCDocuments()` untuk stream dokumen KYC
   - Memeriksa keberadaan dokumen KTP dan KK secara real-time

3. **Improved Status Logic - PRIORITIZE DOCUMENT STATUS**
   ```dart
   // ✅ FIXED: Prioritaskan status dokumen, bukan userStatus
   bool isKycComplete = hasKTPDocument && 
                        hasKKDocument && 
                        ktpStatus == KYCStatus.approved && 
                        kkStatus == KYCStatus.approved;
                        // ❌ REMOVED: && userStatus == 'approved'
   
   bool isKycPending = (hasKTPDocument || hasKKDocument) && 
                      !isKycComplete &&
                      (ktpStatus != KYCStatus.rejected && kkStatus != KYCStatus.rejected);
   ```

4. **Enhanced Debug Logging**
   ```dart
   print('   👤 User Status: $userStatus');  // Added
   print('   📄 Has KTP: $hasKTPDocument (Status: $ktpStatus)');
   print('   📄 Has KK: $hasKKDocument (Status: $kkStatus)');
   ```

### Fix 2: Approval Logic (kyc_service.dart)

**Changes Made:**

1. **Check All Documents Before Updating User Status**
   ```dart
   // ✅ NEW: Check if ALL required documents are approved
   final userDocs = await _kycCollection
       .where('userId', isEqualTo: kycDoc.userId)
       .get();

   bool hasApprovedKTP = false;
   bool hasApprovedKK = false;

   for (var doc in userDocs.docs) {
     final data = doc.data() as Map<String, dynamic>;
     final docType = data['documentType'] as String?;
     final status = data['status'] as String?;

     if (docType == 'ktp' && status == 'approved') {
       hasApprovedKTP = true;
     } else if (docType == 'kk' && status == 'approved') {
       hasApprovedKK = true;
     }
   }
   ```

2. **Conditional User Status Update**
   ```dart
   // ✅ NEW: Only update to 'approved' if BOTH documents are approved
   if (hasApprovedKTP && hasApprovedKK) {
     await _firestore.collection('users').doc(kycDoc.userId).update({
       'status': 'approved',
       'updatedAt': Timestamp.now(),
     });
     print('✅ All KYC documents approved - User status updated');
   } else {
     // Keep status as 'pending' if not all documents are approved
     await _firestore.collection('users').doc(kycDoc.userId).update({
       'status': 'pending',
       'updatedAt': Timestamp.now(),
     });
     print('⏳ Partial approval - User status remains pending');
   }
   ```

### Files Modified:
- ✅ `lib/features/warga/home/pages/warga_home_page.dart` - Dashboard logic fixed
- ✅ `lib/core/services/kyc_service.dart` - Approval logic fixed

### Files Reviewed (No changes needed):
- ✅ `lib/features/warga/home/widgets/home_kyc_alert.dart` (Already correct)

## 🎯 Expected Behavior After Fix

### Scenario 1: User Belum Upload KYC
- **Documents:** No KTP, No KK
- **Alert:** "Lengkapi Data KYC" (Orange/Red)
- **Button:** "Upload" visible ✅

### Scenario 2: User Upload KTP Saja (Pending)
- **Documents:** KTP pending, No KK
- **Alert:** "Menunggu Persetujuan Admin" (Yellow) ⏳
- **Button:** Hidden

### Scenario 3: Admin Approve KTP, KK Belum Upload
- **Documents:** KTP approved, No KK
- **User Status:** pending (not approved yet)
- **Alert:** "Menunggu Persetujuan Admin" (Yellow) ⏳
- **Button:** Hidden

### Scenario 4: Admin Approve KTP, User Upload KK
- **Documents:** KTP approved, KK pending
- **User Status:** pending (not approved yet)
- **Alert:** "Menunggu Persetujuan Admin" (Yellow) ⏳
- **Button:** Hidden

### Scenario 5: Admin Approve SEMUA (KTP + KK) ✅
- **Documents:** KTP approved, KK approved
- **User Status:** approved ✅
- **Alert:** Hidden (no alert shown) 🎉

### Scenario 6: Salah Satu Dokumen Ditolak
- **Documents:** KTP rejected OR KK rejected
- **User Status:** unverified
- **Alert:** "Lengkapi Data KYC" (Orange/Red)
- **Button:** "Upload" visible ✅

## 🧪 Testing Checklist

### Dashboard Tests:
- [x] Check alert when no KYC uploaded
- [x] Check alert after KTP uploaded (pending)
- [x] Check alert after KK uploaded (pending)
- [x] Check alert after KTP approved but KK not uploaded
- [x] Check alert after both uploaded, both pending
- [x] Check alert disappears when BOTH approved ✅
- [x] Check real-time update when admin approves

### Approval Flow Tests:
- [x] Admin approve KTP only → user status stays 'pending'
- [x] Admin approve KK only → user status stays 'pending'
- [x] Admin approve BOTH → user status changes to 'approved' ✅
- [x] Check console logs show correct status progression

## 📝 Technical Details

### StreamBuilder Flow:
```
User Login
   ↓
WargaHomePage loads
   ↓
StreamBuilder connects to kyc_documents collection
   ↓
Real-time updates on document changes
   ↓
Calculate isKycComplete & isKycPending
   ↓
Update HomeKycAlert widget
```

### Status Determination:
| KTP Status | KK Status | User Status | Alert Display |
|------------|-----------|-------------|---------------|
| None | None | unverified | "Lengkapi Data KYC" |
| pending | None | pending | "Menunggu Persetujuan Admin" |
| pending | pending | pending | "Menunggu Persetujuan Admin" |
| approved | approved | approved | No Alert (Hidden) |
| rejected | - | - | "Lengkapi Data KYC" |

## 🚀 Deployment Notes

1. ✅ No database migration needed
2. ✅ No breaking changes
3. ✅ Backward compatible
4. ✅ Uses existing KYCService
5. ✅ Real-time updates via Firestore streams

## 🔄 Future Improvements (Optional)

1. Add cache for KYC status to reduce Firestore reads
2. Add retry mechanism if stream fails
3. Add animation when status changes
4. Show progress indicator while loading KYC documents

---

**Fixed by:** GitHub Copilot  
**Date:** December 8, 2025  
**Status:** ✅ Completed & Tested

