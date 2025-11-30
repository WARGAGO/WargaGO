# 🔥 QUICK FIX - Tambah Data Pengumuman via Firebase Console

## ⚡ Langkah Cepat (Manual - Paling Mudah!)

### 1. Buka Firebase Console
https://console.firebase.google.com/project/pbl-2025-35a1c/firestore/databases/-default-/data

### 2. Klik "Start collection" atau "+ Start collection"

### 3. Collection ID: `pengumuman`

### 4. Tambahkan Document Pertama

**Auto-ID:** (biarkan auto-generate)

**Fields:**

| Field Name | Type | Value |
|------------|------|-------|
| `judul` | string | `Gotong Royong Minggu Depan` |
| `konten` | string | `Diinformasikan kepada seluruh warga bahwa akan diadakan gotong royong bersama pada hari Minggu, 8 Desember 2025 mulai pukul 07.00 WIB. Diharapkan semua kepala keluarga dapat hadir. Terima kasih.` |
| `prioritas` | string | `tinggi` |
| `tanggal` | timestamp | **December 1, 2025 at 8:00:00 AM UTC+7** |
| `createdAt` | timestamp | **(klik timestamp sekarang)** |
| `createdBy` | string | `Admin RT` |

**Klik Save**

---

### 5. Tambahkan Document Kedua (Ulangi langkah 4)

| Field | Value |
|-------|-------|
| `judul` | `Pembayaran Iuran Bulan Desember` |
| `konten` | `Batas pembayaran iuran RT bulan Desember adalah tanggal 15 Desember 2025. Mohon untuk segera melakukan pembayaran melalui bendahara RT atau transfer ke rekening yang telah ditentukan.` |
| `prioritas` | `menengah` |
| `tanggal` | **November 28, 2025 at 10:00:00 AM UTC+7** |
| `createdAt` | **(timestamp sekarang)** |
| `createdBy` | `Admin RT` |

---

### 6. Document Ketiga

| Field | Value |
|-------|-------|
| `judul` | `Pemadaman Listrik Terjadwal` |
| `konten` | `PLN akan melakukan pemadaman listrik terjadwal pada tanggal 5 Desember 2025 dari pukul 09.00 - 15.00 WIB untuk maintenance. Harap persiapkan diri dengan baik.` |
| `prioritas` | `tinggi` |
| `tanggal` | **November 27, 2025 at 2:00:00 PM UTC+7** |
| `createdAt` | **(timestamp sekarang)** |
| `createdBy` | `Admin RT` |

---

### 7. Document Keempat

| Field | Value |
|-------|-------|
| `judul` | `Rapat Koordinasi RT` |
| `konten` | `Akan diadakan rapat koordinasi RT pada hari Rabu, 4 Desember 2025 pukul 19.30 WIB di rumah Ketua RT. Diharapkan hadir semua ketua RW dan ketua RT.` |
| `prioritas` | `menengah` |
| `tanggal` | **November 26, 2025 at 4:00:00 PM UTC+7** |
| `createdAt` | **(timestamp sekarang)** |
| `createdBy` | `Admin RT` |

---

### 8. Document Kelima

| Field | Value |
|-------|-------|
| `judul` | `Jadwal Posyandu Balita` |
| `konten` | `Posyandu balita akan dilaksanakan pada tanggal 10 Desember 2025 di Balai RT mulai pukul 08.00 WIB. Diharapkan ibu-ibu yang memiliki balita untuk hadir.` |
| `prioritas` | `rendah` |
| `tanggal` | **November 24, 2025 at 11:00:00 AM UTC+7** |
| `createdAt` | **(timestamp sekarang)** |
| `createdBy` | `Admin RT` |

---

## ✅ Setelah Menambahkan Data

### 1. Restart Flutter App
```bash
# Stop app (Ctrl+C di terminal)
flutter run
```

### 2. Atau Hot Restart
Press `R` di terminal Flutter atau klik tombol hot restart

### 3. Check Home Page
- Scroll ke bawah ke section **"Pengumuman Terbaru"**
- Harusnya muncul 5 pengumuman yang baru ditambahkan
- Setiap pengumuman menampilkan:
  - 🔴 Icon merah untuk prioritas tinggi
  - 🟡 Icon orange untuk prioritas menengah  
  - 🟢 Icon hijau untuk prioritas rendah

### 4. Test Tombol "Lihat Semua Pengumuman"
- Klik tombol di bawah list
- Harusnya navigasi ke halaman semua pengumuman

---

## 🎨 Tips Menambahkan Timestamp di Firebase Console

1. Klik **"Add field"**
2. Field name: `tanggal`
3. Type: **timestamp**
4. Klik icon kalender
5. Pilih tanggal dan waktu
6. **PENTING:** Pastikan timezone UTC+7 (WIB)

---

## 📸 Screenshot Helper

### Cara Input Timestamp:
```
Field: tanggal
Type: timestamp
Value: (klik kalender icon)
  → Pilih: December 1, 2025
  → Waktu: 08:00:00
  → Timezone: UTC+7
```

### Cara Input String:
```
Field: judul
Type: string
Value: Gotong Royong Minggu Depan
```

---

## 🚨 Troubleshooting

### Data Tidak Muncul?
1. ✅ Pastikan Firestore rules sudah di-deploy
2. ✅ Pastikan user sudah login di app
3. ✅ Pastikan data di collection `pengumuman` (lowercase, tanpa spasi)
4. ✅ Pastikan field names persis sama (case-sensitive)
5. ✅ Restart app (bukan hot reload, tapi stop & run lagi)

### Masih Error Permission Denied?
- Logout dan login lagi di app
- Check apakah user role = 'warga' atau 'admin' di collection `users`

---

**Cukup tambahkan 5 data dulu untuk testing!** 

Kalau sudah berhasil muncul, bisa tambahkan lebih banyak data lagi nanti. 😊

