# 🚀 KELOLA IURAN - Quick Start Guide

## ✅ Fitur Lengkap Sudah Dibuat!

Fitur Kelola Iuran dengan UI modern dan backend CRUD lengkap sudah selesai 100%!

---

## 📦 Files Created

```
✅ lib/core/models/iuran_model.dart
✅ lib/core/services/iuran_service.dart
✅ lib/features/admin/iuran/kelola_iuran_page.dart
✅ lib/features/admin/iuran/tambah_iuran_page.dart
✅ lib/features/admin/iuran/detail_iuran_page.dart
```

---

## 🎯 How to Test

### Step 1: Navigate to Kelola Iuran

Tambahkan menu di dashboard admin atau data warga menu:

```dart
// Example: Di data_warga_main_page.dart atau navigation menu
ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const KelolaIuranPage(),
      ),
    );
  },
  icon: const Icon(Icons.account_balance_wallet_rounded),
  label: const Text('Kelola Iuran'),
)
```

### Step 2: Buat Iuran Baru

1. **Buka Kelola Iuran** → Klik FAB "Tambah Iuran"
2. **Isi Form:**
   - Judul: "Iuran Kebersihan Bulanan"
   - Deskripsi: "Iuran untuk kebersihan lingkungan RT"
   - Nominal: 50000
   - Tipe: Bulanan
   - Kategori: Kebersihan
   - Tanggal Jatuh Tempo: Pilih tanggal
3. **Klik "Buat Iuran & Generate Tagihan"**
4. **System akan:**
   - ✅ Buat iuran baru
   - ✅ Generate tagihan untuk semua warga (role=warga, status=approved)
   - ✅ Show success message dengan jumlah tagihan yang dibuat

### Step 3: Lihat & Kelola Tagihan

1. **Tap card iuran** yang baru dibuat
2. **Lihat:**
   - Statistik pembayaran (total, sudah bayar, belum bayar, %)
   - List tagihan per warga
3. **Filter tagihan:** Semua / Belum Bayar / Sudah Bayar / Terlambat
4. **Tandai sebagai lunas:** Klik "Tandai Lunas" di card tagihan
5. **Edit/Hapus:** Via menu (⋮) di header

---

## 🎨 Features Overview

### ✅ CRUD Operations:
- **Create** - Tambah iuran baru + auto-generate tagihan
- **Read** - List iuran dengan filter & search
- **Update** - Edit data iuran
- **Delete** - Hapus iuran & cascade delete tagihan

### ✅ UI Features:
- Modern gradient header
- Card-based layout
- Color-coded categories
- Status badges
- Interactive filters
- Search functionality
- Statistics dashboard
- Progress bar pembayaran
- Empty states
- Loading indicators

### ✅ Backend Features:
- Auto-generate tagihan untuk semua warga
- Real-time updates (StreamBuilder)
- Status management (aktif/nonaktif)
- Payment tracking
- Statistics calculation
- Cascade delete

---

## 📊 Test Scenarios

### Scenario 1: Create Iuran
```
✅ Buat iuran "Iuran Kebersihan - Rp 50,000"
✅ System auto-generate 10 tagihan (jika ada 10 warga approved)
✅ Semua tagihan status = "belum_bayar"
```

### Scenario 2: View & Filter
```
✅ List iuran tampil di halaman utama
✅ Filter "Aktif" → Hanya iuran aktif yang tampil
✅ Search "Kebersihan" → Iuran yang sesuai muncul
```

### Scenario 3: Manage Tagihan
```
✅ Tap card iuran → Detail page terbuka
✅ Statistik tampil: 0/10 lunas (0%)
✅ Filter "Belum Bayar" → 10 tagihan tampil
✅ Tandai 1 tagihan lunas → Status berubah
✅ Statistik update: 1/10 lunas (10%)
```

### Scenario 4: Edit & Delete
```
✅ Menu (⋮) → Edit → Form pre-filled
✅ Ubah nominal Rp 75,000 → Save → Success
✅ Menu (⋮) → Hapus → Confirm → Deleted
✅ Semua tagihan terkait juga terhapus
```

---

## 🔧 Firestore Setup

### Collections Needed:
```
✅ iuran          (for iuran data)
✅ tagihan        (for tagihan per warga)
✅ users          (already exists - for warga data)
```

### Firestore Rules:
```javascript
// Add to firestore.rules
match /iuran/{iuranId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null && 
    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
}

match /tagihan/{tagihanId} {
  allow read: if request.auth != null && 
    (get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin' ||
     resource.data.userId == request.auth.uid);
  allow write: if request.auth != null && 
    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
}
```

### Deploy Rules:
```bash
firebase deploy --only firestore:rules
```

---

## 📱 Screenshots Expected

### 1. Kelola Iuran Page
```
┌─────────────────────────────────────────┐
│ 🎯 Kelola Iuran                        │
│ Manajemen iuran & tagihan warga        │
│                                         │
│ [Semua] [Aktif] [Nonaktif]            │
│ 🔍 Cari iuran...                       │
│                                         │
│ ┌───────────────────────────────────┐  │
│ │ [Kebersihan] [Aktif]              │  │
│ │ Iuran Kebersihan Bulanan          │  │
│ │ Untuk kebersihan lingkungan...    │  │
│ │ Rp 50,000 | Bulanan               │  │
│ │ 📅 Jatuh Tempo: 31 Des 2024       │  │
│ └───────────────────────────────────┘  │
│                                         │
│            [+ Tambah Iuran]            │
└─────────────────────────────────────────┘
```

### 2. Tambah Iuran Page
```
┌─────────────────────────────────────────┐
│ ➕ Tambah Iuran Baru                   │
│ Isi form di bawah dengan lengkap       │
│                                         │
│ Judul Iuran *                          │
│ [Iuran Kebersihan Bulanan_____________]│
│                                         │
│ Deskripsi *                            │
│ [Untuk kebersihan lingkungan RT_______]│
│                                         │
│ Nominal (Rp) *                         │
│ [Rp 50000____________________________]│
│                                         │
│ Tipe Iuran *                           │
│ [Bulanan] [Tahunan] [Insidental]       │
│                                         │
│ Kategori *                             │
│ [Umum] [Kebersihan✓] [Keamanan]       │
│                                         │
│ [Buat Iuran & Generate Tagihan]        │
└─────────────────────────────────────────┘
```

### 3. Detail Iuran Page
```
┌─────────────────────────────────────────┐
│ Iuran Kebersihan Bulanan          [⋮]  │
│ Untuk kebersihan lingkungan RT         │
│ [Rp 50,000] [Bulanan]                  │
│                                         │
│ ┌─────────────────────────────────────┐│
│ │ Total: 10 | Lunas: 3 | Belum: 7    ││
│ │ Progress: ██████░░░░░░░░░░ 30%     ││
│ └─────────────────────────────────────┘│
│                                         │
│ [Semua][Belum Bayar][Sudah Bayar]      │
│                                         │
│ ┌────���──────────────────────────────┐  │
│ │ 👤 Budi Santoso                   │  │
│ │ Rp 50,000     [Belum Bayar]       │  │
│ │                [Tandai Lunas]     │  │
│ └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

---

## ⚡ Quick Actions

### Admin Actions:
- ✅ Buat iuran → Auto-generate tagihan
- ✅ Edit nominal iuran
- ✅ Nonaktifkan iuran (tidak aktif lagi)
- ✅ Hapus iuran + tagihan
- ✅ Tandai tagihan lunas
- ✅ Lihat statistik pembayaran

### Warga Actions (Future):
- 📋 Lihat tagihan saya
- 💰 Upload bukti pembayaran
- 📊 History pembayaran
- 🔔 Notifikasi tagihan baru

---

## 🎉 Success Criteria

✅ Admin bisa buat iuran baru  
✅ System auto-generate tagihan untuk semua warga  
✅ Admin bisa lihat list tagihan per iuran  
✅ Admin bisa tandai tagihan lunas  
✅ Statistik pembayaran akurat  
✅ Filter & search berfungsi  
✅ Edit & delete berfungsi  
✅ UI modern & responsive  
✅ No errors in console  
✅ Real-time updates work  

---

## 🐛 Common Issues & Solutions

### Issue 1: "No tagihan generated"
**Cause:** Tidak ada user dengan role='warga' dan status='approved'  
**Solution:** Pastikan ada user warga yang sudah approved

### Issue 2: "Permission denied"
**Cause:** Firestore rules belum di-setup  
**Solution:** Deploy firestore rules seperti di atas

### Issue 3: "Import errors"
**Cause:** File path salah  
**Solution:** Pastikan semua file di folder yang benar

---

## 📞 Need Help?

Check documentation:
- `KELOLA_IURAN_COMPLETE.md` - Full documentation
- `KELOLA_IURAN_QUICK_START.md` - This file

---

**Status:** ✅ Ready to Test  
**Next:** Test semua fitur sesuai test scenarios di atas! 🚀

