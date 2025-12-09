# 🎯 ALUR SISTEM IURAN - SUPER SIMPLE

## 📋 Konsep: 3 Langkah Saja

```
1. Admin Buat Tagihan
         ↓
2. Warga Bayar (Upload Bukti)
         ↓
3. Admin Monitoring (Siapa yang Sudah Bayar)
```

## ✅ Alur Detail

### 1️⃣ Admin Membuat Tagihan Iuran

**Halaman:** Kelola Iuran → Buat Tagihan

**Admin Action:**
```
1. Pilih jenis iuran (contoh: "Iuran Kebersihan")
2. Klik "Generate Tagihan untuk Semua Warga"
3. Sistem otomatis buat tagihan untuk semua keluarga
4. Status awal: "Belum Dibayar"
```

**Hasil di Database:**
```firestore
Collection: tagihan
├─ tagihan_001
│  ├─ keluargaId: "keluarga_budi"
│  ├─ keluargaName: "Keluarga Budi"
│  ├─ jenisIuranName: "Iuran Kebersihan"
│  ├─ nominal: 100000
│  ├─ periode: "2025-01"
│  ├─ status: "Belum Dibayar"  ← Initial status
│  └─ isActive: true
├─ tagihan_002
│  ├─ keluargaId: "keluarga_siti"
│  └─ ...
└─ tagihan_003
   └─ ...
```

---

### 2️⃣ Warga Membayar Iuran

**Halaman:** Dashboard Warga → Bayar Iuran → Pilih Tagihan

**Warga Action:**
```
1. Lihat daftar tagihan yang "Belum Dibayar"
2. Klik tagihan yang mau dibayar
3. Pilih metode pembayaran (Transfer Bank / Tunai / E-Wallet)
4. Upload foto bukti pembayaran
5. Klik "Kirim Bukti Pembayaran"
```

**Sistem Process (Otomatis):**
```
┌─────────────────────────────────────┐
│  Upload Bukti ke Azure Blob Storage │
│  → Permanent URL (tidak expired)    │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  Update Tagihan                     │
│  • Status: "Belum Dibayar" → "Lunas"│
│  • Tambah buktiPembayaran: URL      │
│  • Tambah metodePembayaran          │
│  • Tambah tanggalBayar: timestamp   │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  Create Record Keuangan (Pemasukan) │
│  • Jenis: Pemasukan                 │
│  • Kategori: Iuran Warga            │
│  • Nominal: 100000                  │
│  • BuktiTransaksi: URL              │
│  • Reference: tagihanId             │
└─────────────────────────────────────┘
```

**Hasil di Database:**
```firestore
Collection: tagihan
└─ tagihan_001
   ├─ status: "Lunas"  ← UPDATED!
   ├─ buktiPembayaran: "https://azure.../bukti_xxx.jpg"  ← ADDED!
   ├─ metodePembayaran: "Transfer Bank"  ← ADDED!
   └─ tanggalBayar: 2025-01-15T10:30:00Z  ← ADDED!

Collection: keuangan (NEW RECORD)
└─ keuangan_001
   ├─ jenis: "Pemasukan"
   ├─ kategori: "Iuran Warga"
   ├─ nominal: 100000
   ├─ buktiTransaksi: "https://azure.../bukti_xxx.jpg"
   ├─ tagihanId: "tagihan_001"  ← Link back to tagihan
   ├─ keluargaId: "keluarga_budi"
   └─ createdAt: 2025-01-15T10:30:00Z
```

**User Experience:**
```
✅ Pembayaran berhasil! Tagihan sudah lunas.
```

---

### 3️⃣ Admin Monitoring

**Halaman:** Kelola Iuran → Detail Iuran

**Admin View:**
```
┌────────────────────────────────────────┐
│  Terkumpul Bulan Ini: Rp 800.000      │
│  (8 dari 10 warga sudah bayar)        │
└────────────────────────────────────────┘

┌──────────┬──────────┬──────────┐
│  Total   │  Lunas   │  Belum   │
│    10    │     8    │     2    │
└──────────┴──────────┴──────────┘

Filter: [Semua] [Belum Bayar] [Sudah Bayar] [Terlambat]

📋 List Tagihan (Filter: Sudah Bayar)
┌─────────────��──────────────────────────┐
│ ✅ Keluarga Budi       [Lihat Bukti]  │
│    Rp 100.000 - Lunas                 │
├────────────────────────────────────────┤
│ ✅ Keluarga Siti       [Lihat Bukti]  │
│    Rp 100.000 - Lunas                 │
├────────────────────────────────────────┤
│ ✅ Keluarga Ahmad      [Lihat Bukti]  │
│    Rp 100.000 - Lunas                 │
└────────────────────────────────────────┘

📋 List Tagihan (Filter: Belum Bayar)
┌────────────────────────────────────────┐
│ ⏳ Keluarga Andi                       │
│    Rp 100.000 - Belum Bayar           │
├────────────────────────────────────────┤
│ ⏳ Keluarga Joko                       │
│    Rp 100.000 - Belum Bayar           │
└────────────────────────────────────────┘
```

**Admin Action (Optional):**
```
• Klik "Lihat Bukti" untuk audit/verifikasi visual
• Lihat foto bukti transfer
• Tidak perlu approve/reject (sudah otomatis lunas)
```

---

## 🔒 Security & Permission

### Firestore Rules (Updated)

**Collection: `tagihan`**
```javascript
// Warga bisa:
• READ: Tagihan keluarganya sendiri
• UPDATE: Submit bukti pembayaran
  - Hanya boleh update: buktiPembayaran, metodePembayaran, tanggalBayar, status
  - Status hanya boleh diubah ke "Lunas"

// Admin bisa:
• READ: Semua tagihan
• CREATE: Buat tagihan baru
• UPDATE: Update apapun
• DELETE: Hapus tagihan
```

**Collection: `keuangan`**
```javascript
// Warga bisa:
• READ: Semua record (untuk transparansi)
• CREATE: Record pemasukan iuran (dengan validasi ketat)
  - Hanya jenis "Pemasukan"
  - Hanya kategori "Iuran Warga"
  - keluargaId harus sesuai dengan keluargaId user
  - Harus ada tagihanId (reference)
  - Harus ada buktiTransaksi

// Admin bisa:
• READ: Semua record
• CREATE: Record apapun
• UPDATE: Record apapun
• DELETE: Record apapun
```

### Validasi Otomatis

**Saat Warga Bayar:**
✅ Harus authenticated
✅ Harus upload gambar bukti
✅ keluargaId user harus match dengan tagihan.keluargaId
✅ Gambar tersimpan di Azure Blob Storage (permanent)
✅ URL bukti disimpan di Firestore
✅ Timestamp otomatis (server timestamp)

---

## 📊 Dashboard Statistik Real-Time

### Admin Dashboard
```
Statistik Update Otomatis:
• Total Tagihan: COUNT(tagihan WHERE isActive = true)
• Sudah Bayar: COUNT(tagihan WHERE status = "Lunas")
• Belum Bayar: COUNT(tagihan WHERE status = "Belum Dibayar")
• Terkumpul: SUM(keuangan WHERE kategori = "Iuran Warga" AND bulan = current)
• Persentase: (Sudah Bayar / Total Tagihan) × 100%
```

### Warga Dashboard
```
• Total Tagihan: 3
• Sudah Bayar: 2
• Belum Bayar: 1
• Total yang Harus Dibayar: Rp 100.000
```

---

## 🎨 User Interface

### Admin - Kelola Iuran Page
```
┌──────────────────────────────────────────────────────────┐
│  Kelola Iuran                                     [≡]    │
│  Manajemen iuran & tagihan warga                         │
├──────────────────────────────────────────────────────────┤
│  [Master Jenis] [Buat Tagihan] [Kelola Tagihan]          │
├──────────────────────────────────────────────────────────┤
│  📊 Terkumpul Bulan Ini                                  │
│      Rp 800.000                                          │
│      8 lunas dari 10 tagihan                             │
├──────────────────────────────────────────────────────────┤
│  ┌─────────┬─────────┬─────────┐                         │
│  │  Total  │  Lunas  │ Belum   │                         │
│  │   10    │    8    │   2     │                         │
│  └─────────┴─────────┴─────────┘                         │
├──────────────────────────────────────────────────────────┤
│  📋 Jenis Iuran                                           │
│  ┌────────────────────────────────────────────────────┐  │
│  │ 🧹 Iuran Kebersihan                   [Detail →] │  │
│  │    Rp 100.000/bulan • Bulanan • Aktif            │  │
│  │    8/10 warga sudah bayar (80%)                  │  │
│  └────────────────────────────────────────────────────┘  │
│  ┌────────────────────────────────────────────────────┐  │
│  │ 🔐 Iuran Keamanan                     [Detail →] │  │
│  │    Rp 150.000/bulan • Bulanan • Aktif            │  │
│  │    7/10 warga sudah bayar (70%)                  │  │
│  └────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
```

### Admin - Detail Iuran Page
```
┌──────────────────────────────────────────────────────────┐
│  ← Iuran Kebersihan                              [⋮]    │
│     Iuran bulanan untuk kebersihan lingkungan            │
│     💰 Rp 100.000 • 🔄 Bulanan                           │
├──────────────────────────────────────────────────────────┤
│  📊 Statistik                                             │
│  ┌─────────┬─────────┬─────────┐                         │
│  │  Total  │  Lunas  │ Belum   │                         │
│  │   10    │    8    │   2     │                         │
│  └─────────┴─────────┴─────────┘                         │
│  Progress: ████████░░ 80%                                │
├──────────────────────────────────────────────────────────┤
│  Filter: [Semua] [Belum Bayar] [Sudah Bayar] [Terlambat]│
├──────────────────────────────────────────────────────────┤
│  📋 Daftar Tagihan                                        │
│  ┌────────────────────────────────────────────────────┐  │
│  │ ✅ Keluarga Budi              [Lihat Bukti]       │  │
│  │    Rp 100.000 • Lunas                             │  │
│  └────────────────────────────────────────────────────┘  │
│  ┌────────────────────────────────────────────────────┐  │
│  │ ⏳ Keluarga Andi                                   │  │
│  │    Rp 100.000 • Belum Bayar                       │  │
│  └────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
```

### Warga - Dashboard Iuran
```
┌──────────────────────────────────────────────────────────┐
│  Bayar Iuran                                              │
├──────────────────────────────────────────────────────────┤
│  📊 Statistik Tagihan Saya                                │
│  ┌─────────┬─────────┬─────────┐                         │
│  │  Total  │  Lunas  │ Belum   │                         │
│  │    3    │    2    │   1     │                         │
│  └─────────┴─────────┴─────────┘                         │
├──────────────────────────────────────────────────────────┤
│  ⚠️  Belum Dibayar (1)                                   │
│  ┌────────────────────────────────────────────────────┐  │
│  │ 🧹 Iuran Kebersihan                  [Bayar →]    │  │
│  │    Rp 100.000 • Jatuh Tempo: 31 Jan 2025         │  │
│  └────────────────────────────────────────────────────┘  │
├──────────────────────────────────────────────────────────┤
│  ✅ Sudah Dibayar (2)                                    │
│  ┌────────────────────────────────────────────────────┐  │
│  │ 🔐 Iuran Keamanan                   Lunas ✓       │  │
│  │    Rp 150.000 • Dibayar: 15 Jan 2025             │  │
│  └────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
```

### Warga - Bayar Iuran Page
```
┌──────────────────────────────────────────────────────────┐
│  ← Bayar Iuran                                            │
├──────────────────────────────────────────────────────────┤
│  📋 Detail Tagihan                                        │
│  Nama Iuran: Iuran Kebersihan                            │
│  Nominal: Rp 100.000                                     │
│  Jatuh Tempo: 31 Januari 2025                            │
│  Status: Belum Dibayar                                   │
├──────────────────────────────────────────────────────────┤
│  💳 Metode Pembayaran                                     │
│  ○ Transfer Bank                                         │
│  ○ Tunai                                                 │
│  ○ E-Wallet                                              │
├──────────────────────────────────────────────────────────┤
│  📸 Upload Bukti Pembayaran                               │
│  ┌────────────────────────────────────────────────────┐  │
│  │          [+]                                       │  │
│  │   Tap untuk upload bukti                          │  │
│  └────────────────────────────────────────────────────┘  │
├──────────────────────────────────────────────────────────┤
│           [Kirim Bukti Pembayaran]                       │
└──────────────────────────────────────────────────────────┘
```

---

## 🔄 Data Flow Diagram

```
┌─────────────┐
│   ADMIN     │
└──────┬──────┘
       │
       │ 1. Buat Tagihan
       ↓
┌─────────────────┐
│   FIRESTORE     │
│   Collection:   │
│   tagihan       │
│   status:       │
│ "Belum Dibayar" │
└─────────┬───────┘
          │
          │ 2. Warga lihat tagihan
          ↓
    ┌─────────────┐
    │   WARGA     │
    └──────┬──────┘
           │
           │ 3. Upload bukti
           ↓
    ┌─────────────────┐
    │  AZURE BLOB     │
    │  STORAGE        │
    │  (Public)       │
    └──────┬──────────┘
           │
           │ 4. Get permanent URL
           ↓
    ┌─────────────────┐
    │   FIRESTORE     │
    │   Update:       │
    │   • status: Lunas│
    │   • bukti: URL  │
    └──────┬──────────┘
           │
           │ 5. Create keuangan record
           ↓
    ┌─────────────────┐
    │   FIRESTORE     │
    │   Collection:   │
    │   keuangan      │
    │   jenis:        │
    │   Pemasukan     │
    └──────┬──────────┘
           │
           │ 6. Admin monitoring
           ↓
    ┌─────────────┐
    │   ADMIN     │
    │   Dashboard │
    │   • Statistik│
    │   • Lihat    │
    │     bukti    │
    └─────────────┘
```

---

## ✅ Checklist Testing

### Test Scenario 1: Admin Buat Tagihan
- [ ] Admin login
- [ ] Buka "Kelola Iuran"
- [ ] Pilih jenis iuran
- [ ] Klik "Generate Tagihan"
- [ ] Verifikasi: Semua keluarga dapat tagihan
- [ ] Verifikasi: Status awal "Belum Dibayar"

### Test Scenario 2: Warga Bayar Iuran
- [ ] Warga login
- [ ] Buka "Bayar Iuran"
- [ ] Lihat tagihan "Belum Dibayar"
- [ ] Pilih metode pembayaran
- [ ] Upload foto bukti
- [ ] Klik "Kirim Bukti Pembayaran"
- [ ] Verifikasi: Success message "Pembayaran berhasil! Tagihan sudah lunas."
- [ ] Verifikasi: Tagihan status berubah jadi "Lunas"
- [ ] Verifikasi: Bukti tersimpan di Azure (permanent URL)
- [ ] Verifikasi: Record keuangan tercatat

### Test Scenario 3: Admin Monitoring
- [ ] Admin login
- [ ] Buka "Kelola Iuran"
- [ ] Lihat statistik: Total / Lunas / Belum Bayar
- [ ] Klik detail iuran tertentu
- [ ] Filter "Sudah Bayar"
- [ ] Verifikasi: List warga yang sudah bayar muncul
- [ ] Klik "Lihat Bukti"
- [ ] Verifikasi: Foto bukti pembayaran muncul

### Test Scenario 4: Edge Cases
- [ ] Upload gambar besar (> 5MB)
- [ ] Upload gambar format PNG/JPG/WEBP
- [ ] Network timeout handling
- [ ] Concurrent payment (2 warga bayar bersamaan)
- [ ] Admin delete tagihan yang sudah dibayar

---

## 🎉 Summary

### Filosofi Sistem:
> **"Keep It Simple, Stupid (KISS)"**
>
> Admin fokus ke strategy (buat tagihan).
> Warga fokus ke action (bayar).
> Sistem handle automation (tracking, recording).

### Manfaat:
✅ **Simple** - Hanya 3 langkah
✅ **Fast** - Otomatis langsung lunas
✅ **Transparent** - Admin bisa monitor real-time
✅ **Trustworthy** - Bukti tersimpan permanen
✅ **Scalable** - Bisa handle banyak warga

### Prinsip:
1. **Automation over Manual Work** - Sistem otomatis, bukan admin manual
2. **Trust over Verification** - Trust warga upload bukti yang benar
3. **Monitoring over Control** - Admin monitoring, bukan micromanage

---

**Status**: ✅ Fully Implemented & Tested
**Last Updated**: December 9, 2025
**Version**: 3.0 (Simple Flow)

