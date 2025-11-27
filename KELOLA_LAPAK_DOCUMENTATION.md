# KELOLA LAPAK - DOKUMENTASI LENGKAP

## 📋 Deskripsi Fitur

Fitur **Kelola Lapak** adalah sistem verifikasi dan manajemen seller/penjual di marketplace warga. Admin bertugas sebagai verifikator untuk memastikan setiap seller yang mendaftar adalah orang yang benar-benar ingin berjualan dan bukan penipu/scammer.

## 🎯 Tujuan Fitur

1. **Mencegah Penipuan**: Memverifikasi identitas seller sebelum diizinkan berjualan
2. **Meningkatkan Kepercayaan**: Memastikan semua seller terverifikasi dan terpercaya
3. **Manajemen Seller**: Admin dapat mengelola seller aktif, suspend seller bermasalah
4. **Tracking & Monitoring**: Monitor aktivitas dan performa seller

## 🔐 Sistem Verifikasi

### Kriteria Verifikasi Seller

Admin harus memeriksa hal-hal berikut sebelum menyetujui seller:

#### 1. **Dokumen Identitas** ✅
- **Foto KTP**: 
  - Harus jelas dan dapat dibaca
  - Tidak blur atau terpotong
  - NIK terlihat dengan jelas
  - Nama lengkap sesuai dengan data pendaftaran

- **Foto Selfie dengan KTP**:
  - Wajah seller terlihat jelas
  - KTP dipegang di samping wajah
  - Tidak menggunakan foto orang lain
  - Wajah dan KTP dalam 1 frame

#### 2. **Data Pribadi** ✅
- NIK valid (16 digit)
- Nama lengkap sesuai KTP
- Nomor telepon aktif dan dapat dihubungi
- Alamat jelas dan spesifik

#### 3. **Informasi Toko** ✅
- Nama toko masuk akal dan profesional
- Alamat toko jelas (bisa rumah atau tempat lain)
- RT/RW sesuai dengan alamat
- Deskripsi usaha jelas dan masuk akal

#### 4. **Kategori Produk** ✅
- Kategori yang dipilih sesuai dengan deskripsi usaha
- Tidak memilih kategori yang mencurigakan
- Fokus pada produk yang diizinkan (sayur, buah, kebutuhan pokok, dll)

#### 5. **Red Flags (Tanda Bahaya)** ❌
**TOLAK jika menemukan hal berikut:**

- Foto KTP blur atau tidak jelas
- Foto selfie menggunakan foto orang lain
- NIK tidak valid atau palsu
- Nama toko mencurigakan (mengandung kata-kata tidak pantas)
- Deskripsi usaha tidak masuk akal atau terlalu singkat
- Alamat tidak jelas atau fiktif
- Nomor telepon tidak aktif
- Riwayat komplain/masalah sebelumnya
- Kategori produk mencurigakan (narkoba, senjata, dll - TIDAK ADA DI SISTEM INI)

### Proses Verifikasi

```
1. Warga mengisi form pendaftaran seller
   ↓
2. Upload dokumen (KTP, Selfie KTP, Foto Toko)
   ↓
3. Data masuk ke sistem "Pending Sellers"
   ↓
4. Admin menerima notifikasi pendaftaran baru
   ↓
5. Admin membuka detail seller
   ↓
6. Admin memeriksa semua dokumen dan data
   ↓
7. Admin memutuskan:
   a. SETUJUI → Seller aktif dan bisa berjualan
   b. TOLAK → Seller tidak diizinkan (dengan alasan)
   ↓
8. Seller menerima notifikasi hasil verifikasi
```

## 📊 Status Seller

### 1. **Pending** 🟡
- Pendaftaran baru yang menunggu verifikasi admin
- Seller belum bisa berjualan
- Admin harus segera memverifikasi

### 2. **Approved/Aktif** 🟢
- Seller telah diverifikasi dan disetujui
- Dapat menambah produk dan berjualan
- Memiliki trust score dan rating
- Bisa menerima pesanan

### 3. **Rejected** 🔴
- Pendaftaran ditolak oleh admin
- Disertai alasan penolakan
- Seller dapat mendaftar ulang jika memperbaiki data

### 4. **Suspended** ⚫
- Seller yang sudah aktif tapi disuspend karena masalah
- Tidak bisa berjualan sementara
- Bisa diaktifkan kembali oleh admin

## 🔧 Fitur Admin

### Dashboard Kelola Lapak
- **Statistik**:
  - Jumlah seller menunggu verifikasi
  - Jumlah seller aktif
  - Jumlah seller ditolak
  - Jumlah seller disuspend

- **Tab View**:
  - Tab Pending: Lihat semua pendaftaran yang menunggu
  - Tab Aktif: Lihat semua seller yang aktif
  - Tab Ditolak: Riwayat seller yang ditolak
  - Tab Suspend: Seller yang disuspend

### Halaman Detail Seller
- **Informasi Lengkap**:
  - Header dengan nama toko dan seller
  - Data pribadi lengkap
  - Informasi toko
  - Kategori produk
  - Deskripsi usaha

- **Dokumen Verifikasi**:
  - Preview foto KTP
  - Preview foto selfie dengan KTP
  - Preview foto toko (jika ada)

- **Checklist Verifikasi**:
  - Panduan untuk admin
  - Poin-poin yang harus dicek

- **Action Buttons**:
  - Tombol SETUJUI (hijau)
  - Tombol TOLAK (merah)
  - Form catatan admin (opsional)
  - Form alasan penolakan (wajib untuk tolak)

### Fitur Tambahan
- **Suspend Seller**: Admin bisa suspend seller yang bermasalah
- **Reactivate Seller**: Admin bisa aktifkan kembali seller yang disuspend
- **Trust Score**: Sistem penilaian kepercayaan seller (0-100)
- **Complaint Tracking**: Tracking jumlah komplain terhadap seller

## 👥 Fitur Warga (Seller)

### Form Pendaftaran
1. **Data Diri**:
   - Nama lengkap (auto-fill dari data warga)
   - NIK (auto-fill)
   - Nomor telepon (auto-fill)

2. **Informasi Toko**:
   - Nama toko/lapak
   - Alamat toko
   - RT/RW
   - Deskripsi usaha

3. **Kategori Produk**:
   - Sayuran
   - Buah-buahan
   - Kebutuhan Pokok
   - Makanan & Minuman
   - Lainnya

4. **Upload Dokumen**:
   - Foto KTP (wajib)
   - Foto Selfie dengan KTP (wajib)
   - Foto Toko (opsional)

### Validasi
- Semua field wajib harus diisi
- NIK harus 16 digit
- Minimal 1 kategori produk dipilih
- Foto KTP dan Selfie KTP wajib diupload

### Status Tracking
- Warga dapat melihat status pendaftaran mereka:
  - Pending: Sedang diproses
  - Approved: Disetujui, bisa mulai berjualan
  - Rejected: Ditolak dengan alasan
  - Suspended: Akun disuspend

## 🗄️ Struktur Database

### Collection: `pending_sellers`
```
pending_sellers/{sellerId}
├── userId: string
├── nik: string
├── namaLengkap: string
├── namaToko: string
├── nomorTelepon: string
├── alamatToko: string
├── rt: string
├── rw: string
├── deskripsiUsaha: string
├── kategoriProduk: array<string>
├── fotoKTPUrl: string
├── fotoSelfieKTPUrl: string
├── fotoTokoUrl: string (optional)
├── status: string (pending/approved/rejected/suspended)
├── alasanPenolakan: string (optional)
├── catatanAdmin: string (optional)
├── createdAt: timestamp
├── updatedAt: timestamp
├── verifiedAt: timestamp (optional)
├── verifiedBy: string (optional)
├── isRTApproved: boolean (optional, untuk future)
├── isRWApproved: boolean (optional, untuk future)
├── trustScore: number (0-100)
└── complaintCount: number
```

### Collection: `approved_sellers`
```
approved_sellers/{userId}
├── userId: string
├── nik: string
├── namaLengkap: string
├── namaToko: string
├── nomorTelepon: string
├── alamatToko: string
├── rt: string
├── rw: string
├── deskripsiUsaha: string
├── kategoriProduk: array<string>
├── fotoKTPUrl: string
├── fotoSelfieKTPUrl: string
├── fotoTokoUrl: string (optional)
├── status: string (active/suspended)
├── verifiedAt: timestamp
├── verifiedBy: string
├── trustScore: number
├── complaintCount: number
├── totalProducts: number
├── totalSales: number
├── rating: number (1-5)
├── createdAt: timestamp
└── updatedAt: timestamp
```

### Update Collection: `users`
Tambahkan field:
```
users/{userId}
├── ...existing fields
├── roles: array<string> (tambah 'seller' jika approved)
└── isSeller: boolean
```

## 🔒 Firestore Security Rules

Tambahkan rules berikut ke `firestore.rules`:

```javascript
// Pending Sellers - Admin only read/write, user can create
match /pending_sellers/{sellerId} {
  // User can create their own pending seller
  allow create: if request.auth != null 
    && request.auth.uid == request.resource.data.userId
    && !exists(/databases/$(database)/documents/pending_sellers/$(request.auth.uid));
  
  // User can read their own pending seller
  allow read: if request.auth != null 
    && (request.auth.uid == resource.data.userId 
        || get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
  
  // Only admin can update/delete
  allow update, delete: if request.auth != null 
    && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
}

// Approved Sellers - Admin write, public read
match /approved_sellers/{userId} {
  allow read: if true; // Public can see approved sellers
  allow write: if request.auth != null 
    && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
}
```

## 📱 Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    WARGA (SELLER)                            │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
            ┌───────────────────────────┐
            │  Klik "Daftar Penjual"    │
            └───────────────────────────┘
                            │
                            ▼
            ┌───────────────────────────┐
            │   Isi Form Pendaftaran    │
            │  - Data Diri              │
            │  - Info Toko              │
            │  - Kategori Produk        │
            │  - Upload Dokumen         │
            └───────────────────────────┘
                            │
                            ▼
            ┌───────────────────────────┐
            │  Kirim ke Firestore       │
            │  Collection:              │
            │  pending_sellers          │
            └───────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      ADMIN                                   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
            ┌───────────────────────────┐
            │  Buka Kelola Lapak        │
            │  Lihat Tab "Pending"      │
            └───────────────────────────┘
                            │
                            ▼
            ┌───────────────────────────┐
            │  Klik Seller yang         │
            │  akan diverifikasi        │
            └───────────────────────────┘
                            │
                            ▼
            ┌───────────────────────────┐
            │  Periksa Detail:          │
            │  ✓ Foto KTP               │
            │  ✓ Foto Selfie KTP        │
            │  ✓ Data Pribadi           │
            │  ✓ Info Toko              │
            │  ✓ Deskripsi Usaha        │
            └───────────────────────────┘
                            │
                    ┌───────┴───────┐
                    │               │
                    ▼               ▼
        ┌────────────────┐  ┌────────────────┐
        │   SETUJUI      │  │    TOLAK       │
        └────────────────┘  └────────────────┘
                    │               │
                    ▼               ▼
        ┌────────────────┐  ┌────────────────┐
        │ Update status  │  │ Update status  │
        │ → approved     │  │ → rejected     │
        │                │  │ + alasan       │
        │ Pindah ke      │  │                │
        │ approved_      │  │ Tetap di       │
        │ sellers        │  │ pending_       │
        │                │  │ sellers        │
        │ Update user    │  └────────────────┘
        │ role + seller  │
        └────────────────┘
                    │
                    ▼
        ┌────────────────┐
        │ Seller AKTIF   │
        │ Bisa Berjualan │
        └────────────────┘
```

## 💡 Best Practices untuk Admin

### DO ✅
1. Periksa semua dokumen dengan teliti
2. Pastikan foto jelas dan tidak blur
3. Verifikasi kesesuaian data dengan dokumen
4. Beri catatan yang jelas jika menolak
5. Hubungi seller jika ada data yang meragukan
6. Cek riwayat warga sebelumnya di sistem
7. Monitor seller aktif secara berkala

### DON'T ❌
1. Jangan terburu-buru menyetujui tanpa cek detail
2. Jangan menyetujui jika dokumen tidak jelas
3. Jangan menolak tanpa alasan yang jelas
4. Jangan mengabaikan red flags
5. Jangan bias dalam verifikasi
6. Jangan lupa follow up setelah suspend

## 🚀 Fitur Mendatang (Future Enhancement)

### Phase 2
- [ ] Approval RT/RW sebelum admin (dual verification)
- [ ] Auto-reject jika dokumen tidak sesuai (ML/AI)
- [ ] Rating sistem untuk seller
- [ ] Verification badge untuk seller terpercaya
- [ ] Email/SMS notification untuk seller
- [ ] Dashboard analytics untuk seller

### Phase 3
- [ ] Seller performance tracking
- [ ] Auto-suspend jika banyak komplain
- [ ] Seller tier system (Bronze, Silver, Gold, Platinum)
- [ ] Reward untuk seller terbaik
- [ ] Integration dengan e-wallet untuk pembayaran

## 📞 Support & Maintenance

### Monitoring
- Cek pending sellers setiap hari
- Review suspended sellers setiap minggu
- Update trust score berdasarkan performa
- Handle komplain dalam 24 jam

### Troubleshooting
**Problem**: Warga tidak bisa upload dokumen
- **Solution**: Cek file size, format harus JPG/PNG, max 5MB

**Problem**: Admin tidak bisa approve seller
- **Solution**: Cek koneksi internet, pastikan user adalah admin

**Problem**: Seller sudah approved tapi tidak bisa upload produk
- **Solution**: Cek role 'seller' sudah ditambahkan di user document

## 📝 Changelog

### v1.0.0 (27 November 2025)
- ✅ Model PendingSellerModel dengan semua field verifikasi
- ✅ Repository PendingSellerRepository dengan CRUD lengkap
- ✅ Admin page Kelola Lapak dengan tab view
- ✅ Detail seller page dengan verifikasi lengkap
- ✅ Form pendaftaran seller untuk warga
- ✅ Upload dokumen (KTP, Selfie, Foto Toko)
- ✅ Approve/Reject functionality
- ✅ Suspend/Reactivate seller
- ✅ Trust score & complaint tracking
- ✅ Statistics dashboard

---

**Dibuat oleh**: GitHub Copilot AI  
**Tanggal**: 27 November 2025  
**Project**: PBL 2025 - Sistem Manajemen RT/RW

