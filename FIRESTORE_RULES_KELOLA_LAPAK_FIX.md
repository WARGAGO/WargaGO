# ✅ FIRESTORE RULES - KELOLA LAPAK FIXED!

## 🔴 ERROR YANG TERJADI

```
[cloud_firestore/permission-denied] 
The caller does not have permission to execute the specified operation.
```

**Root Cause**: Collection `pending_sellers` dan `approved_sellers` tidak ada rules di Firestore Security Rules.

---

## ✅ SOLUSI - FIRESTORE RULES DITAMBAHKAN

Saya telah menambahkan rules untuk:

### 1. **pending_sellers** Collection

```javascript
match /pending_sellers/{sellerId} {
  // Read: Admin bisa read semua, user bisa read data sendiri
  allow read: if isSignedIn() && 
                 (isAdmin() || request.auth.uid == resource.data.userId);
  
  // Create: Warga yang login bisa daftar sebagai seller
  allow create: if isSignedIn() &&
                   hasValidData() &&
                   'userId' in request.resource.data &&
                   request.auth.uid == request.resource.data.userId &&
                   // ... validation fields
                   request.resource.data.status == 'pending';
  
  // Update: Admin bisa approve/reject, User bisa re-submit
  allow update: if isAdmin() ||
                   (isSignedIn() && 
                    request.auth.uid == resource.data.userId &&
                    request.resource.data.status == 'pending');
  
  // Delete: Hanya admin
  allow delete: if isAdmin();
}
```

### 2. **approved_sellers** Collection

```javascript
match /approved_sellers/{sellerId} {
  // Read: Semua authenticated user (untuk marketplace)
  allow read: if isSignedIn();
  
  // Create: Hanya admin (saat approve)
  allow create: if isAdmin();
  
  // Update: Admin atau seller owner
  allow update: if isAdmin() ||
                   (isSignedIn() && request.auth.uid == resource.data.userId);
  
  // Delete: Hanya admin
  allow delete: if isAdmin();
}
```

---

## 🚀 CARA DEPLOY FIRESTORE RULES

### **Option 1: Via Firebase Console (RECOMMENDED)** ✅

1. **Buka Firebase Console**:
   ```
   https://console.firebase.google.com
   ```

2. **Pilih Project** Anda (PBL 2025 / jawara-e6f40)

3. **Go to Firestore Database**:
   - Sidebar → **Firestore Database**
   - Tab → **Rules**

4. **Copy-Paste Rules**:
   - Buka file: `firestore.rules`
   - Copy seluruh isi file
   - Paste ke editor di Firebase Console

5. **Publish**:
   - Klik tombol **"Publish"**
   - Tunggu sampai selesai (~5-10 detik)

6. **Verify**:
   - Rules akan aktif langsung
   - Coba refresh app

---

### **Option 2: Via Firebase CLI** 

```bash
# 1. Login ke Firebase (jika belum)
firebase login

# 2. Deploy rules
firebase deploy --only firestore:rules

# 3. Tunggu sampai selesai
# Output: ✔ Deploy complete!
```

---

### **Option 3: Via VS Code Firebase Extension**

1. Install **Firebase Extension** di VS Code
2. Open Command Palette (Ctrl+Shift+P)
3. Type: `Firebase: Deploy Firestore Rules`
4. Enter

---

## 📋 FIRESTORE RULES SECURITY FEATURES

### Admin Privileges:
- ✅ Read all pending sellers
- ✅ Read all approved sellers
- ✅ Approve/Reject seller applications
- ✅ Suspend/Reactivate sellers
- ✅ Delete sellers

### Warga/User Privileges:
- ✅ Register sebagai seller (create)
- ✅ Read status pendaftaran sendiri
- ✅ Update/re-submit pendaftaran (jika masih pending)
- ✅ Read approved sellers list (marketplace)
- ✅ Update info toko sendiri (jika sudah approved)

### Security:
- ✅ Authentication required (`isSignedIn()`)
- ✅ Role-based access (`isAdmin()`)
- ✅ Owner validation (`request.auth.uid == userId`)
- ✅ Data validation (required fields check)
- ✅ Status validation (prevent unauthorized status change)

---

## 🧪 TEST SETELAH DEPLOY

### 1. Test Read (Admin)
```dart
// Ini seharusnya SUKSES jika user adalah admin
final sellers = await FirebaseFirestore.instance
    .collection('pending_sellers')
    .where('status', isEqualTo: 'pending')
    .get();
```

### 2. Test Read (Warga)
```dart
// Ini seharusnya SUKSES - bisa read data sendiri
final userId = FirebaseAuth.instance.currentUser!.uid;
final mySeller = await FirebaseFirestore.instance
    .collection('pending_sellers')
    .where('userId', isEqualTo: userId)
    .get();
```

### 3. Test Create (Warga)
```dart
// Ini seharusnya SUKSES
await FirebaseFirestore.instance
    .collection('pending_sellers')
    .add({
      'userId': currentUser.uid,
      'nik': '1234567890123456',
      'namaLengkap': 'John Doe',
      'namaToko': 'Toko ABC',
      'status': 'pending',
      // ... other fields
    });
```

---

## ⚠️ TROUBLESHOOTING

### Error Masih Muncul Setelah Deploy?

**1. Clear Cache**:
```bash
flutter clean
flutter pub get
```

**2. Restart App** (Full Restart):
```bash
flutter run
```

**3. Wait ~1 minute**:
- Firestore rules kadang perlu waktu propagate
- Tunggu 1-2 menit setelah deploy

**4. Check Rules di Console**:
- Pastikan rules sudah ter-publish
- Cek timestamp "Last deployed"

**5. Check Auth State**:
```dart
// Pastikan user sudah login
final user = FirebaseAuth.instance.currentUser;
print('User: ${user?.uid}'); // Should not be null

// Check user role
final userDoc = await FirebaseFirestore.instance
    .collection('users')
    .doc(user!.uid)
    .get();
print('Role: ${userDoc.data()?['role']}'); // Should be 'admin' or 'warga'
```

---

## 📝 IMPORTANT NOTES

### Default Status Must Be 'pending':
```dart
// ✅ CORRECT
'status': 'pending'

// ❌ WRONG
'status': 'approved' // User tidak bisa langsung approved
```

### UserId Must Match Auth UID:
```dart
// ✅ CORRECT
'userId': FirebaseAuth.instance.currentUser!.uid

// ❌ WRONG
'userId': 'other-user-id' // Security violation
```

### Required Fields:
```dart
{
  'userId': String,        // Required
  'nik': String,           // Required
  'namaLengkap': String,   // Required
  'namaToko': String,      // Required
  'nomorTelepon': String,  // Required
  'alamatToko': String,    // Required
  'fotoKTPUrl': String,    // Required
  'fotoSelfieKTPUrl': String, // Required
  'status': 'pending',     // Required, must be 'pending'
  // ... other fields
}
```

---

## ✅ VERIFICATION CHECKLIST

Setelah deploy rules, verify:

- [ ] Rules ter-publish di Firebase Console
- [ ] Timestamp "Last deployed" updated
- [ ] App di-restart (full restart)
- [ ] User sudah login
- [ ] User memiliki role 'admin' atau 'warga'
- [ ] Collection name benar: `pending_sellers` (bukan `pending_seller`)
- [ ] Error `PERMISSION_DENIED` hilang
- [ ] Statistics cards muncul
- [ ] List sellers muncul

---

## 🎊 KESIMPULAN

**Status**: ✅ **FIRESTORE RULES FIXED!**

**Next Steps**:
1. ✅ Deploy rules via Firebase Console atau CLI
2. ✅ Restart app
3. ✅ Test fitur Kelola Lapak
4. ✅ Verify no permission errors

---

**Fixed**: 27 November 2025  
**Issue**: Missing Firestore Security Rules  
**Solution**: Added rules for pending_sellers & approved_sellers  
**Deploy**: Via Firebase Console or CLI

