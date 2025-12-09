# 🔍 TROUBLESHOOTING: Tagihan Tidak Muncul di Warga

## 📸 Problem (Dari Screenshot)

**User warga melihat:**
```
"Belum Ada Tagihan Iuran"
Saat ini Anda belum memiliki tagihan iuran yang perlu dibayar.

Kemungkinan Penyebab:
1. Admin belum membuat jenis iuran
2. Keluarga ID tidak terdaftar  
3. Semua tagihan sudah lunas
```

**Padahal:**
- ✅ Admin sudah membuat iuran
- ✅ Admin sudah generate tagihan
- ✅ User punya keluargaId

## 🔍 Root Cause Analysis

### Possible Issues:

#### 1. **Tagihan TIDAK PUNYA keluargaId**
```json
// ❌ WRONG - Tagihan tanpa keluargaId
{
  "userId": "user123",
  "keluargaId": null,  // ❌ NULL!
  "isActive": true
}
```

**Why?** Saat admin generate tagihan sebelum fix, `keluargaId` tidak ter-set karena service lama tidak include field ini.

#### 2. **Tagihan TIDAK PUNYA isActive**
```json
// ❌ WRONG - Tagihan tanpa isActive
{
  "userId": "user123",
  "keluargaId": "KEL001",
  // ❌ isActive field missing!
}
```

**Why?** Field `isActive` baru ditambahkan di update terbaru.

#### 3. **User TIDAK PUNYA keluargaId**
```json
// ❌ WRONG - User tanpa keluargaId
{
  "email": "user@email.com",
  "nama": "User Name",
  "role": "warga",
  "status": "approved",
  // ❌ keluargaId field missing!
}
```

**Why?** User belum di-assign ke keluarga.

## ✅ Solutions

### Solution 1: Check User keluargaId

**Manual Check (Firebase Console):**
```
1. Open Firebase Console
2. Go to Firestore Database
3. Collection: users
4. Find user document
5. Check if 'keluargaId' field exists
6. If missing, add field:
   - Field: keluargaId
   - Type: string  
   - Value: KEL001 (or appropriate ID)
```

**Programmatic Check:**
Run debug script `debug_tagihan_warga.dart` to check user data.

### Solution 2: Fix Existing Tagihan

**Option A: Re-generate Tagihan (Recommended)**
```
1. Admin: Delete existing tagihan
2. Admin: Create iuran again
3. System: Auto-generate with correct fields (keluargaId, isActive)
```

**Option B: Update Existing Tagihan**
Run fix script `fix_existing_tagihan.dart`:
```dart
// This will:
1. Find all tagihan without keluargaId
2. Get keluargaId from user document
3. Update tagihan with correct keluargaId
4. Set isActive = true if missing
5. Add jenisIuranName if missing
```

### Solution 3: Verify Query

**Check Warga Page Query:**
```dart
// Query should be:
FirebaseFirestore.instance
  .collection('tagihan')
  .where('keluargaId', isEqualTo: userKeluargaId)  // ✅
  .where('isActive', isEqualTo: true)              // ✅
  .snapshots()
```

**Common mistakes:**
```dart
// ❌ WRONG - Missing keluargaId
.where('userId', isEqualTo: userId)  // This won't work if tagihan uses keluargaId system

// ❌ WRONG - Missing isActive
.where('keluargaId', isEqualTo: keluargaId)  // Will get inactive tagihan too
```

## 🧪 Step-by-Step Diagnosis

### Step 1: Run Debug Script

Copy `debug_tagihan_warga.dart` and run with user ID:

```dart
await debugTagihanWarga('USER_ID_HERE');
```

**This will check:**
1. ✅ User has keluargaId
2. ✅ Tagihan exists for userId
3. ✅ Tagihan exists for keluargaId
4. ✅ Tagihan has isActive = true
5. ✅ All tagihan in database

### Step 2: Analyze Output

**Scenario A: User has no keluargaId**
```
❌ PROBLEM: User does not have keluargaId!
   Solution: Add keluargaId to user document
```

**Fix:**
```javascript
// In Firebase Console
db.collection('users').doc('USER_ID').update({
  keluargaId: 'KEL001'
});
```

**Scenario B: Tagihan missing keluargaId**
```
❌ TAGIHAN EXISTS but keluargaId DOES NOT MATCH!
   Problem: Tagihan has different/null keluargaId
   Solution: Update tagihan keluargaId
```

**Fix:** Run `fix_existing_tagihan.dart` script

**Scenario C: Tagihan not active**
```
❌ TAGIHAN EXISTS but isActive = false or missing!
   Problem: Tagihan not active
   Solution: Update tagihan isActive to: true
```

**Fix:** Run `fix_existing_tagihan.dart` script

### Step 3: Fix & Verify

After fix, verify:
```
1. Logout from warga account
2. Login again
3. Open Iuran menu
4. Pull to refresh
5. ✅ Tagihan should appear!
```

## 📋 Checklist for Each User

For user who can't see tagihan:

- [ ] **Check user document has keluargaId**
  ```
  users/{userId}/keluargaId = "KEL001"
  ```

- [ ] **Check tagihan has keluargaId**
  ```
  tagihan/{tagihanId}/keluargaId = "KEL001"
  ```

- [ ] **Check tagihan has isActive = true**
  ```
  tagihan/{tagihanId}/isActive = true
  ```

- [ ] **Check tagihan has jenisIuranName**
  ```
  tagihan/{tagihanId}/jenisIuranName = "Iuran Kebersihan"
  ```

- [ ] **Check user role = "warga" and status = "approved"**
  ```
  users/{userId}/role = "warga"
  users/{userId}/status = "approved"
  ```

## 🔧 Quick Fix Commands

### Firebase Console - Fix User
```javascript
// Add keluargaId to user
db.collection('users').doc('USER_ID').update({
  keluargaId: 'KEL001'
});
```

### Firebase Console - Fix Tagihan
```javascript
// Update single tagihan
db.collection('tagihan').doc('TAGIHAN_ID').update({
  keluargaId: 'KEL001',
  isActive: true,
  jenisIuranName: 'Iuran Kebersihan',
  updatedAt: firebase.firestore.FieldValue.serverTimestamp()
});

// Update all tagihan for a user
db.collection('tagihan')
  .where('userId', '==', 'USER_ID')
  .get()
  .then(snapshot => {
    snapshot.forEach(doc => {
      doc.ref.update({
        keluargaId: 'KEL001',
        isActive: true,
        jenisIuranName: 'Iuran Kebersihan'
      });
    });
  });
```

## 🎯 Prevention (For Future)

To prevent this issue:

1. **Always set keluargaId when creating user**
   ```dart
   await FirebaseFirestore.instance
       .collection('users')
       .doc(userId)
       .set({
         // ... other fields
         'keluargaId': keluargaId,  // ✅ REQUIRED
       });
   ```

2. **Always include all fields when generating tagihan**
   ```dart
   final tagihan = TagihanModel(
     userId: userId,
     keluargaId: keluargaId,      // ✅ REQUIRED
     isActive: true,               // ✅ REQUIRED
     jenisIuranName: iuran.judul,  // ✅ REQUIRED
     // ... other fields
   );
   ```

3. **Validate before generating**
   ```dart
   if (user.keluargaId == null) {
     throw Exception('User must have keluargaId before generating tagihan');
   }
   ```

## 📊 Expected vs Actual

### Expected (Working):
```
User Document:
{
  "userId": "user123",
  "keluargaId": "KEL001"  ✅
}

Tagihan Document:
{
  "userId": "user123",
  "keluargaId": "KEL001",  ✅
  "isActive": true,        ✅
  "jenisIuranName": "..."  ✅
}

Query:
.where('keluargaId', '==', 'KEL001')
.where('isActive', '==', true)
→ ✅ Returns tagihan
```

### Actual (Not Working):
```
User Document:
{
  "userId": "user123",
  "keluargaId": "KEL001"  ✅
}

Tagihan Document:
{
  "userId": "user123",
  "keluargaId": null,     ❌ NULL!
  "isActive": null        ❌ MISSING!
}

Query:
.where('keluargaId', '==', 'KEL001')
→ ❌ No results (keluargaId doesn't match)
```

## 🎉 Success Criteria

After fix, user should see:

```
✅ Tagihan list appears
✅ Shows iuran name
✅ Shows nominal
✅ Shows status (Belum Bayar/Lunas)
✅ Can click to pay
✅ No more "Belum Ada Tagihan"
```

## 📝 Documentation

Related files:
- `debug_tagihan_warga.dart` - Diagnosis script
- `fix_existing_tagihan.dart` - Fix script
- `iuran_service.dart` - Generate tagihan logic
- `iuran_warga_page.dart` - Warga UI

---

**Date:** December 8, 2024  
**Status:** ⏳ Needs Manual Check & Fix  
**Action:** Run debug script to identify specific issue

