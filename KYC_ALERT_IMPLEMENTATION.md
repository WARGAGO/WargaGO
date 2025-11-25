# 🎯 IMPLEMENTASI KYC ALERT & MENU RESTRICTION - WARGA DASHBOARD

## ✅ Yang Sudah Diimplementasikan

### 1. **KYC Alert Banner**
Alert banner otomatis muncul di dashboard warga jika:
- ❌ Belum upload KYC (KTP & KK)
- ⏳ Sudah upload tapi masih pending verifikasi

**Fitur Alert:**
- 🟡 Warning banner dengan warna kuning
- 📝 Pesan yang jelas (Upload KYC / Menunggu Verifikasi)
- 🔘 Tombol "Upload" untuk langsung ke KYC wizard
- ✨ Animasi smooth dan design modern

### 2. **Menu Restriction**

#### **Menu yang SELALU Bisa Diakses (Tanpa KYC):**
- ✅ **Home** - Dashboard utama
- ✅ **Pengumuman** - Lihat pengumuman RT/RW
- ✅ **Pengaduan** - Ajukan pengaduan/keluhan
- ✅ **Akun** - Profil & settings

#### **Fitur yang PERLU KYC Verified:**
- 🔒 **Scan Button** (QR Scanner di tengah)
  - Disabled jika belum KYC
  - Ada icon lock 🔒
  - Klik akan muncul dialog KYC requirement
- 🔒 **Marketplace** (Future)
- 🔒 **Iuran** (Future)

### 3. **KYC Required Dialog**
Dialog informatif muncul saat user klik fitur yang butuh KYC:
- 📋 Penjelasan kenapa perlu KYC
- 📄 List dokumen yang dibutuhkan (KTP & KK)
- 🔘 Tombol "Upload Sekarang" → langsung ke wizard
- 🔘 Tombol "Nanti" → tutup dialog

---

## 📱 Bottom Navigation Update

### **Layout Baru:**
```
┌─────────────────────────────────────┐
│  Home  │  Pengumuman  │ (SCAN) │  Pengaduan  │  Akun  │
└─────────────────────────────────────┘
```

**Perubahan dari sebelumnya:**
- ❌ Hapus: Marketplace, Iuran dari bottom nav
- ✅ Tambah: Pengumuman, Pengaduan (always accessible)
- 🔒 Scan button: Disabled jika belum KYC verified

---

## 🔍 Logika Verifikasi KYC

```dart
// Check KYC Status:
1. Cek apakah user sudah upload KTP
2. Cek apakah user sudah upload KK
3. Cek status kedua dokumen:
   - approved ✅ → KYC Verified
   - pending ⏳ → Show "Menunggu Verifikasi"
   - rejected ❌ → Show "Ditolak" (perlu upload ulang)
```

---

## 📝 File yang Dimodifikasi

### **`lib/features/warga/warga_main_page.dart`**

**Perubahan Major:**
1. ✅ Import provider & KYC service
2. ✅ StreamBuilder untuk real-time KYC status
3. ✅ KYC Alert Banner widget
4. ✅ Bottom navigation dengan 5 menu
5. ✅ KYC Required Dialog
6. ✅ Scan button dengan lock indicator
7. ✅ Placeholder pages (Pengumuman, Pengaduan)

**Struktur Baru:**
```dart
WargaMainPage
├── KYC Alert Banner (StreamBuilder)
├── IndexedStack (Pages)
│   ├── WargaHomePage ✅
│   ├── PengumumanPage ✅
│   ├── PengaduanPage ✅
│   ├── MarketplacePage 🔒
│   ├── IuranPage 🔒
│   └── AkunPage ✅
└── Bottom Navigation
    ├── Home ✅
    ├── Pengumuman ✅
    ├── Scan 🔒 (requires KYC)
    ├── Pengaduan ✅
    └── Akun ✅
```

---

## 🎨 UI/UX Features

### **1. KYC Alert Banner**
```
┌────────────────────────────────────────┐
│ ⚠️  Lengkapi Data KYC Anda            │
│     Upload KTP & KK untuk mengakses   │
│     semua fitur          [Upload] ───►│
└────────────────────────────────────────┘
```

**Design:**
- Gradient kuning (warning color)
- Border & shadow
- Icon warning
- CTA button menonjol

### **2. Scan Button States**

**Verified (✅):**
```
    ┌─────┐
    │ 📷  │ ← Blue gradient
    └─────┘
```

**Not Verified (🔒):**
```
    ┌─────┐
    │ 📷  │ ← Gray gradient
    │  🔒 │ ← Lock badge
    └─────┘
```

### **3. KYC Required Dialog**
```
┌──────────────────────────────────┐
│ 🔒 KYC Diperlukan               │
├──────────────────────────────────┤
│ Untuk mengakses fitur ini...    │
│                                  │
│ Dokumen yang dibutuhkan:        │
│ ✓ KTP (Kartu Tanda Penduduk)   │
│ ✓ KK (Kartu Keluarga)          │
│                                  │
│        [Nanti] [Upload Sekarang]│
└──────────────────────────────────┘
```

---

## 🧪 Testing Scenarios

### **Scenario 1: New User (No KYC)**
1. Login sebagai warga baru
2. ✅ Lihat KYC alert banner
3. ✅ Bisa akses: Home, Pengumuman, Pengaduan, Akun
4. ❌ Scan button disabled (ada lock icon)
5. Klik scan → Muncul dialog KYC required
6. Klik "Upload Sekarang" → Redirect ke KYC wizard

### **Scenario 2: Pending Verification**
1. Login setelah upload KYC
2. ✅ Lihat alert "Menunggu Verifikasi KYC"
3. ✅ Bisa akses menu dasar
4. ❌ Scan button tetap disabled
5. Alert hilang setelah admin approve

### **Scenario 3: KYC Verified**
1. Login dengan KYC approved
2. ✅ Tidak ada alert banner
3. ✅ Scan button aktif (blue, tanpa lock)
4. ✅ Bisa akses semua fitur

### **Scenario 4: KYC Rejected**
1. Login dengan KYC ditolak
2. ⚠️ Alert muncul dengan pesan berbeda
3. ❌ Scan button disabled
4. Bisa upload ulang dokumen

---

## 🚀 How to Test

### **1. Test di Emulator/Device:**
```bash
flutter run
```

### **2. Test dengan User Berbeda:**

**A. Test New User (No KYC):**
1. Register akun warga baru
2. Login
3. Verifikasi alert muncul
4. Coba klik scan button
5. Verifikasi dialog muncul

**B. Test Pending Verification:**
1. Upload KYC (KTP & KK)
2. Logout & Login
3. Verifikasi alert "Menunggu Verifikasi"
4. Scan button masih disabled

**C. Test Verified User:**
1. Login sebagai admin
2. Approve KYC dari user di atas
3. Logout, login sebagai warga
4. Verifikasi alert TIDAK muncul
5. Scan button aktif

---

## 📊 Real-time Updates

Sistem menggunakan **StreamBuilder** untuk real-time updates:
- ⚡ KYC status langsung update saat admin approve/reject
- ⚡ Alert banner otomatis hilang setelah verified
- ⚡ Scan button otomatis aktif setelah verified
- ⚡ Tidak perlu restart app

---

## 🎯 Benefits

### **Untuk Warga:**
- ✅ Jelas fitur mana yang perlu KYC
- ✅ Mudah upload KYC (1 klik dari banner)
- ✅ Tetap bisa akses fitur dasar tanpa KYC
- ✅ Real-time notification saat verified

### **Untuk Admin:**
- ✅ Kontrol akses berbasis verifikasi
- ✅ Mendorong user melengkapi KYC
- ✅ Data warga lebih lengkap & terverifikasi

### **Untuk Sistem:**
- ✅ Security lebih baik
- ✅ Compliance dengan regulasi
- ✅ Data integrity terjaga

---

## 📋 Checklist Implementation

- [x] ✅ KYC Alert Banner
- [x] ✅ StreamBuilder untuk real-time status
- [x] ✅ Menu restriction logic
- [x] ✅ KYC Required Dialog
- [x] ✅ Scan button dengan lock indicator
- [x] ✅ Navigation update (5 menu)
- [x] ✅ Pengumuman page placeholder
- [x] ✅ Pengaduan page placeholder
- [x] ✅ Error handling
- [x] ✅ No compilation errors

---

## 🔄 Next Steps (Future Enhancement)

1. **Implement Pengumuman Page**
   - List pengumuman dari admin
   - Filter by category
   - Push notification

2. **Implement Pengaduan Page**
   - Form pengaduan
   - Upload foto
   - Track status

3. **Implement Marketplace**
   - List produk warga
   - Add/Edit produk
   - Transaction history

4. **Implement Iuran**
   - Cek tagihan
   - History pembayaran
   - Payment gateway

5. **Scan Feature**
   - QR Code scanner
   - Untuk absensi/check-in
   - Untuk verifikasi identitas

---

## 💡 Tips

### **Untuk Developer:**
- KYC service sudah terintegrasi
- Gunakan StreamBuilder untuk real-time
- Alert banner responsive & adaptive
- Dialog reusable untuk fitur lain

### **Untuk Testing:**
- Test dengan multiple user states
- Verify real-time updates
- Check UI di berbagai screen size
- Test navigation flow

---

**Status:** ✅ **IMPLEMENTASI SELESAI**

**Ready to Test:** Ya, bisa langsung di-run dan test semua scenario di atas.

**Files Modified:**
1. `lib/features/warga/warga_main_page.dart` - Complete implementation

**No Breaking Changes:** ✅ Backward compatible dengan existing code.

