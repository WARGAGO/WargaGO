# Firestore Indexes Required untuk Kelola Pengguna

## Tanggal: 29 November 2025

## Error yang Muncul

```
W/Firestore: Listen for Query(target=Query(users where role==user order by -createdAt, -__name__);limitType=LIMIT_TO_FIRST) failed: 
Status{code=FAILED_PRECONDITION, description=The query requires an index.
```

## Solusi: Buat Composite Indexes

### 1. **Index untuk Query: role + createdAt**

**Query yang memerlukan:**
```dart
getUsersByRole('admin')
getUsersByRole('user')
```

**Klik link ini untuk membuat index otomatis:**
```
https://console.firebase.google.com/v1/r/project/pbl-2025-35a1c/firestore/indexes?create_composite=Ckxwcm9qZWN0cy9wYmwtMjAyNS0zNWExYy9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvdXNlcnMvaW5kZXhlcy9fEAEaCAoEcm9sZRABGg0KCWNyZWF0ZWRBdBACGgwKCF9fbmFtZV9fEAI
```

**Atau buat manual:**
- Collection: `users`
- Field 1: `role` - **Ascending**
- Field 2: `createdAt` - **Descending**
- Query scope: Collection

### 2. **Index untuk Query: status + createdAt**

**Query yang memerlukan:**
```dart
getUsersByStatus('approved')
getUsersByStatus('pending')
getUsersByStatus('unverified')
getUsersByStatus('rejected')
```

**Buat manual di Firebase Console:**
- Collection: `users`
- Field 1: `status` - **Ascending**
- Field 2: `createdAt` - **Descending**
- Query scope: Collection

### 3. **Index untuk Query: status (array-contains-any) + createdAt**

**Query yang memerlukan:**
```dart
getPendingUsers() // whereIn: ['unverified', 'pending']
```

**Buat manual di Firebase Console:**
- Collection: `users`
- Field 1: `status` - **Array-contains-any**
- Field 2: `createdAt` - **Descending**
- Query scope: Collection

## Langkah-langkah Membuat Index Manual

1. **Buka Firebase Console:**
   ```
   https://console.firebase.google.com/project/pbl-2025-35a1c/firestore/indexes
   ```

2. **Klik "Create Index"**

3. **Isi form dengan detail index:**
   - Collection ID: `users`
   - Fields to index:
     - Field 1: pilih field dan order (Ascending/Descending)
     - Field 2: pilih field dan order
   - Query scope: `Collection`

4. **Klik "Create Index"**

5. **Tunggu proses build index** (biasanya beberapa menit)

## Status Index yang Dibutuhkan

### Priority High (Wajib):

- [x] `users` - role (Ascending) + createdAt (Descending)
  - **Status:** Link tersedia, tinggal klik
  - **Digunakan di:** Filter by role di Kelola Pengguna

- [ ] `users` - status (Ascending) + createdAt (Descending)
  - **Status:** Perlu dibuat manual
  - **Digunakan di:** Filter by status di Kelola Pengguna

- [ ] `users` - status (Array-contains-any) + createdAt (Descending)
  - **Status:** Perlu dibuat manual
  - **Digunakan di:** getPendingUsers() di Kelola Pengguna

## Alternatif: Modifikasi Query (Tidak Recommended)

Jika tidak bisa buat index, bisa modifikasi query dengan cara:

### Opsi A: Hapus orderBy
```dart
// Sebelum
getUsersByRole('admin').orderBy('createdAt', descending: true)

// Sesudah (tanpa sorting)
getUsersByRole('admin')
```

### Opsi B: Fetch semua data lalu sort di client
```dart
Stream<List<UserModel>> getUsersByRole(String role) {
  return _firestore
      .collection('users')
      .where('role', isEqualTo: role)
      // Hapus .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    final users = snapshot.docs.map((doc) {
      return UserModel.fromMap(doc.data(), doc.id);
    }).toList();
    
    // Sort di client side
    users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return users;
  });
}
```

⚠️ **Warning:** Sorting di client side tidak efisien untuk data besar!

## Quick Fix Script

Jika ingin otomatis membuat index via script (perlu Firebase Admin SDK):

```javascript
// create_indexes.js
const admin = require('firebase-admin');

admin.initializeApp({
  // Your service account credentials
});

const indexes = [
  {
    collection: 'users',
    fields: [
      { fieldPath: 'role', order: 'ASCENDING' },
      { fieldPath: 'createdAt', order: 'DESCENDING' }
    ]
  },
  {
    collection: 'users',
    fields: [
      { fieldPath: 'status', order: 'ASCENDING' },
      { fieldPath: 'createdAt', order: 'DESCENDING' }
    ]
  }
];

// Note: Firebase Admin SDK tidak support create index secara programmatic
// Index harus dibuat via Console atau CLI
```

## Verifikasi Index

Setelah index dibuat, verifikasi dengan:

1. **Cek di Firebase Console:**
   - Go to Firestore > Indexes
   - Pastikan status index "Enabled" (hijau)

2. **Test di aplikasi:**
   - Buka Kelola Pengguna
   - Coba filter by role
   - Coba filter by status
   - Pastikan tidak ada error lagi

## Estimasi Waktu

- **Index Building Time:** 2-5 menit untuk data kecil, bisa sampai 30+ menit untuk data besar
- **Index Count:** 3 indexes total
- **Storage Impact:** Minimal (Firestore indexes sangat efisien)

## Troubleshooting

### Index masih error setelah dibuat?

1. **Periksa status index** - Pastikan statusnya "Enabled"
2. **Tunggu beberapa menit** - Index perlu waktu untuk sync
3. **Restart aplikasi** - Hot reload mungkin tidak cukup
4. **Clear cache Firestore** - Di aplikasi, logout lalu login lagi

### Index tidak muncul di list?

1. **Refresh halaman Firebase Console**
2. **Periksa project yang benar** - Pastikan di project `pbl-2025-35a1c`
3. **Cek quota Firestore** - Pastikan tidak exceed limit

## Best Practices

✅ **DO:**
- Buat index untuk semua query yang menggunakan `where` + `orderBy`
- Monitor index usage di Firebase Console
- Hapus index yang tidak dipakai

❌ **DON'T:**
- Membuat terlalu banyak index yang tidak perlu
- Lupa update index saat mengubah query
- Ignore warning index di development

## Resources

- [Firestore Index Documentation](https://firebase.google.com/docs/firestore/query-data/indexing)
- [Query Limitations](https://firebase.google.com/docs/firestore/query-data/queries#query_limitations)
- [Best Practices](https://firebase.google.com/docs/firestore/best-practices)

---

**Status:** ⏳ Waiting for indexes to be created
**Priority:** 🔴 High (Blocking Kelola Pengguna functionality)
**ETA:** 5-10 minutes after index creation

