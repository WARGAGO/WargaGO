# 📊 PANDUAN: Melihat Data Warga yang Sudah Di-Approve

## 🎯 SOLUSI CEPAT

### Untuk Melihat User yang Sudah Di-Approve:

1. **Login sebagai Admin**
2. **Buka "Kelola Pengguna"** (bukan "Data Penduduk")
3. **Klik tab "Semua"** atau **"Warga"** (JANGAN "Pending")
4. **User yang sudah approved akan muncul** dengan badge hijau "Approved"

---

## 🔍 Penjelasan Lengkap

### Sistem Kerja Tab Filter:

| Tab | Menampilkan | Status User |
|-----|-------------|-------------|
| **Semua** | Semua user (admin + warga) | Semua status |
| **Admin** | Hanya admin | Semua status |
| **Warga** | Hanya warga | Semua status (termasuk approved) ✅ |
| **Pending** | User yang menunggu approval | Status: pending/unverified |

### Alur Status User:

```
1. User Register
   ↓
   Status: "unverified"
   Tab: "Pending"

2. User Upload KYC (KTP + KK)
   ↓
   Status: "pending"
   Tab: "Pending"

3. Admin Approve Dokumen KYC
   ↓
   Status: "approved" ✅
   Tab: "Semua" atau "Warga" (BUKAN "Pending")
```

---

## ⚠️ MASALAH UMUM

### Problem: "Tidak Melihat User Setelah Di-Approve"

**Penyebab:**
- Admin masih di tab **"Pending"**
- User yang sudah approved otomatis **pindah dari tab "Pending"**
- User sekarang ada di tab **"Semua"** atau **"Warga"**

**Solusi:**
1. Klik tab **"Semua"** atau **"Warga"**
2. Scroll untuk cari user yang sudah di-approve
3. User akan memiliki badge hijau **"Approved"**

---

## 🎨 Visual Guide

### Tab "Pending" (SEBELUM Approve):
```
┌─────────────────────────────────────┐
│ 👤 User A                      🟡   │
│    user.a@email.com                 │
│    Status: Menunggu                 │
└─────────────────────────────────────┘
```

### Tab "Warga" (SETELAH Approve):
```
┌─────────────────────────────────────┐
│ 👤 User A                      🟢   │
│    user.a@email.com                 │
│    Status: Approved ✅              │
└─────────────────────────────────────┘
```

---

## 📋 Checklist untuk Admin

Saat approve user:
- [ ] Approve KTP dokumen
- [ ] Approve KK dokumen
- [ ] Verifikasi status berubah jadi "approved"
- [ ] **Pindah ke tab "Warga"** untuk lihat user
- [ ] Konfirmasi badge berubah jadi hijau "Approved"

---

## 🔧 ENHANCEMENT (Opsional)

### Menambahkan Tab "Approved"

Untuk memudahkan admin melihat user yang sudah approved, kita bisa menambahkan tab baru.

**Perubahan di `kelola_pengguna_page.dart`:**

```dart
// Tambahkan di _filterOptions
final List<String> _filterOptions = [
  'Semua', 
  'Admin', 
  'Warga', 
  'Pending',
  'Approved'  // ⭐ NEW
];

// Tambahkan di filter logic
else if (_selectedFilter == 'Approved') {
  users = users.where((user) {
    final status = user.status.toLowerCase();
    return status == 'approved';
  }).toList();
}
```

**Manfaat:**
- ✅ Admin bisa langsung lihat semua user yang approved
- ✅ Tidak perlu scroll di tab "Semua"
- ✅ Lebih jelas dan organized

---

## 💡 FAQ

### Q: Kenapa user hilang dari tab "Pending"?
**A:** User tidak hilang, mereka pindah ke tab "Warga" karena status berubah dari "pending" → "approved"

### Q: Bagaimana cara lihat semua user yang sudah approved?
**A:** Klik tab "Semua" atau "Warga", cari user dengan badge hijau "Approved"

### Q: Apakah user bisa kembali ke "Pending"?
**A:** Ya, jika admin reject dokumen KYC, status kembali ke "unverified" dan muncul di tab "Pending"

### Q: Berapa total user yang sudah di-approve?
**A:** Lihat di tab "Warga", hitung jumlah user dengan badge hijau "Approved"

---

## 🎯 KESIMPULAN

**PENTING:**
- Tab "Pending" = User yang **BELUM** approved
- Tab "Warga" = User warga (termasuk yang **SUDAH** approved) ✅
- Tab "Semua" = SEMUA user (admin + warga approved)

**Untuk melihat user yang sudah approved:**
👉 **Klik tab "WARGA"** atau **"SEMUA"** 👈

---

**Last Updated:** December 8, 2024  
**Status:** ✅ Dokumentasi Complete

