# ✅ TESTING CHECKLIST - KELOLA LAPAK

## 📋 Pre-Testing Setup

### Setup Firebase (WAJIB sebelum testing):
- [ ] Update Firestore Rules (copy dari `firestore_rules_kelola_lapak.txt`)
- [ ] Create Firestore Indexes (sesuai `firestore_indexes_kelola_lapak.json`)
- [ ] Setup Firebase Storage rules untuk upload image
- [ ] Test user sudah ada (minimal 1 admin, 1 warga)

### Setup App:
- [ ] Run `flutter pub get`
- [ ] Build & run app (`flutter run`)
- [ ] No compilation errors
- [ ] App berhasil connect ke Firebase

---

## 🧪 TESTING SCENARIOS

### A. WARGA - PENDAFTARAN SELLER ✅

#### 1. Access Form Pendaftaran
- [ ] Login sebagai warga
- [ ] Buka menu Marketplace
- [ ] Ada tombol "Daftar sebagai Penjual"
- [ ] Klik tombol berhasil buka form

#### 2. Auto-Fill Data
- [ ] Nama Lengkap ter-fill otomatis dari profil
- [ ] NIK ter-fill otomatis
- [ ] Nomor Telepon ter-fill otomatis
- [ ] Alamat ter-fill otomatis
- [ ] RT/RW ter-fill otomatis

#### 3. Isi Form - Data Diri
- [ ] Field Nama Lengkap dapat diedit
- [ ] Field NIK validasi 16 digit
- [ ] Field Nomor Telepon bisa diisi
- [ ] Validasi form berjalan (required fields)

#### 4. Isi Form - Info Toko
- [ ] Field Nama Toko dapat diisi
- [ ] Field Alamat Toko dapat diisi
- [ ] Field RT/RW dapat diisi
- [ ] Field Deskripsi Usaha (multi-line) bisa diisi
- [ ] Validasi required berjalan

#### 5. Pilih Kategori Produk
- [ ] Tampil list kategori: Sayuran, Buah-buahan, Kebutuhan Pokok, Makanan & Minuman, Lainnya
- [ ] Bisa pilih multiple kategori
- [ ] Selected kategori ter-highlight
- [ ] Bisa unselect kategori

#### 6. Upload Dokumen - Foto KTP
- [ ] Tombol "Kamera" berfungsi
- [ ] Tombol "Galeri" berfungsi
- [ ] Foto ter-preview setelah pilih
- [ ] Bisa hapus foto (tombol X)
- [ ] Bisa ganti foto

#### 7. Upload Dokumen - Foto Selfie KTP
- [ ] Tombol "Kamera" berfungsi
- [ ] Tombol "Galeri" berfungsi
- [ ] Foto ter-preview setelah pilih
- [ ] Bisa hapus foto
- [ ] Bisa ganti foto

#### 8. Upload Dokumen - Foto Toko (Opsional)
- [ ] Tombol "Kamera" berfungsi
- [ ] Tombol "Galeri" berfungsi
- [ ] Foto ter-preview jika diupload
- [ ] Bisa skip (opsional)

#### 9. Validasi Form
- [ ] Submit tanpa isi Nama → error muncul
- [ ] Submit tanpa isi NIK → error muncul
- [ ] Submit NIK tidak 16 digit → error muncul
- [ ] Submit tanpa Nama Toko → error muncul
- [ ] Submit tanpa Alamat → error muncul
- [ ] Submit tanpa Deskripsi → error muncul
- [ ] Submit tanpa pilih kategori → error muncul
- [ ] Submit tanpa upload KTP → error muncul
- [ ] Submit tanpa upload Selfie → error muncul

#### 10. Submit Pendaftaran
- [ ] Klik "Kirim Pendaftaran"
- [ ] Loading indicator muncul
- [ ] Upload foto berhasil ke Firebase Storage
- [ ] Data tersimpan ke Firestore (collection: pending_sellers)
- [ ] Dialog sukses muncul
- [ ] Kembali ke halaman sebelumnya
- [ ] Status = 'pending'

#### 11. Cek Pendaftaran Ulang
- [ ] Klik lagi "Daftar sebagai Penjual"
- [ ] Muncul dialog "Anda sudah terdaftar"
- [ ] Menampilkan status pendaftaran
- [ ] Tidak bisa daftar lagi

---

### B. ADMIN - KELOLA LAPAK ✅

#### 1. Access Dashboard
- [ ] Login sebagai admin
- [ ] Buka Dashboard Admin
- [ ] Ada menu "Kelola Lapak"
- [ ] Klik menu berhasil buka halaman

#### 2. Dashboard Kelola Lapak
- [ ] Header "Kelola Lapak" tampil
- [ ] Statistik cards tampil (Menunggu, Disetujui, Ditolak, Suspend)
- [ ] Angka statistik sesuai dengan data
- [ ] Tab bar tampil (Pending, Aktif, Ditolak, Suspend)
- [ ] Refresh button berfungsi

#### 3. Tab Pending
- [ ] Tampil list seller dengan status pending
- [ ] Urutkan dari terbaru
- [ ] Card seller tampil lengkap:
  - [ ] Nama toko
  - [ ] Nama seller
  - [ ] Kategori produk
  - [ ] Alamat
  - [ ] Nomor telepon
  - [ ] Tanggal daftar
  - [ ] Badge status "Pending"

#### 4. Detail Seller
- [ ] Klik card seller → buka detail
- [ ] Header dengan nama toko tampil
- [ ] Foto icon/avatar tampil
- [ ] NIK tampil

#### 5. Section Informasi Toko
- [ ] Kategori produk tampil
- [ ] Nomor telepon tampil
- [ ] Alamat toko tampil
- [ ] RT/RW tampil
- [ ] Deskripsi usaha tampil lengkap

#### 6. Section Dokumen Verifikasi
- [ ] Preview foto KTP tampil
- [ ] Foto KTP dapat di-zoom/fullscreen
- [ ] Preview foto Selfie KTP tampil
- [ ] Foto Selfie dapat di-zoom
- [ ] Preview foto Toko tampil (jika ada)
- [ ] Loading state saat load image
- [ ] Error state jika image gagal load

#### 7. Checklist Verifikasi
- [ ] Tampil list 8 checklist verifikasi
- [ ] Checkmark icon tampil
- [ ] Text checklist jelas dan lengkap

#### 8. Action - Approve Seller
- [ ] Tombol "SETUJUI" (hijau) tampil
- [ ] Klik tombol → dialog konfirmasi muncul
- [ ] Dialog menampilkan nama toko
- [ ] Field catatan opsional bisa diisi
- [ ] Tombol "Batal" berfungsi
- [ ] Tombol "Setujui" berfungsi

#### 9. Proses Approve
- [ ] Loading indicator muncul
- [ ] Status updated ke 'approved' di pending_sellers
- [ ] Data pindah ke collection approved_sellers
- [ ] User role updated (tambah role 'seller')
- [ ] Field isSeller di users = true
- [ ] SnackBar sukses muncul
- [ ] Kembali ke list
- [ ] Seller hilang dari tab Pending
- [ ] Seller muncul di tab Aktif

#### 10. Action - Reject Seller
- [ ] Tombol "TOLAK" (merah) tampil
- [ ] Klik tombol → dialog konfirmasi muncul
- [ ] Field alasan penolakan WAJIB
- [ ] Submit tanpa alasan → error
- [ ] Isi alasan → submit berhasil

#### 11. Proses Reject
- [ ] Loading indicator muncul
- [ ] Status updated ke 'rejected'
- [ ] Alasan penolakan tersimpan
- [ ] SnackBar sukses muncul
- [ ] Kembali ke list
- [ ] Seller hilang dari tab Pending
- [ ] Seller muncul di tab Ditolak

#### 12. Tab Aktif
- [ ] Tampil seller dengan status approved/active
- [ ] Card seller aktif tampil:
  - [ ] Nama toko
  - [ ] Trust score
  - [ ] Rating
  - [ ] Total produk
  - [ ] Badge "Aktif" (hijau)

#### 13. Tab Ditolak
- [ ] Tampil seller dengan status rejected
- [ ] Card seller ditolak tampil
- [ ] Badge "Ditolak" (merah)
- [ ] Alasan penolakan bisa dilihat

#### 14. Tab Suspend
- [ ] Tampil seller dengan status suspended
- [ ] Badge "Suspend" (abu-abu)
- [ ] Empty state jika belum ada yang disuspend

#### 15. Pull to Refresh
- [ ] Swipe down pada list → refresh
- [ ] Data ter-update
- [ ] Statistik ter-update

---

### C. FIRESTORE - DATABASE ✅

#### 1. Collection: pending_sellers
- [ ] Document ID = sellerId (auto-generated)
- [ ] Field userId tersimpan
- [ ] Field nik tersimpan (16 digit)
- [ ] Field namaLengkap tersimpan
- [ ] Field namaToko tersimpan
- [ ] Field kategoriProduk (array) tersimpan
- [ ] Field fotoKTPUrl tersimpan (URL)
- [ ] Field fotoSelfieKTPUrl tersimpan (URL)
- [ ] Field status = 'pending' saat pertama kali
- [ ] Field createdAt (timestamp) tersimpan
- [ ] Field updatedAt (timestamp) tersimpan

#### 2. Collection: approved_sellers
- [ ] Document ID = userId
- [ ] Semua field dari pending_sellers tersalin
- [ ] Field status = 'active'
- [ ] Field verifiedAt tersimpan
- [ ] Field verifiedBy tersimpan (admin UID)
- [ ] Field trustScore = 100 (default)
- [ ] Field complaintCount = 0 (default)
- [ ] Field totalProducts = 0 (default)
- [ ] Field rating = 5.0 (default)

#### 3. Collection: users (update)
- [ ] Field roles ditambah 'seller' (array)
- [ ] Field isSeller = true
- [ ] Field updatedAt ter-update

---

### D. FIREBASE STORAGE ✅

#### 1. Upload Images
- [ ] Folder seller_documents/{userId} dibuat
- [ ] File ktp_*.jpg tersimpan
- [ ] File selfie_*.jpg tersimpan
- [ ] File toko_*.jpg tersimpan (jika ada)
- [ ] File size ter-compress (< 5MB)
- [ ] Image quality bagus (tidak terlalu blur)

#### 2. Security
- [ ] User hanya bisa upload ke folder mereka sendiri
- [ ] File type restricted (hanya JPG/PNG)
- [ ] File size max 5MB

---

### E. SECURITY RULES ✅

#### 1. pending_sellers
- [ ] User dapat create hanya 1x
- [ ] User dapat read data mereka sendiri
- [ ] Admin dapat read semua data
- [ ] Hanya admin yang bisa update
- [ ] Hanya admin yang bisa delete

#### 2. approved_sellers
- [ ] Public dapat read (untuk marketplace)
- [ ] Hanya admin yang bisa create
- [ ] Admin dapat update semua field
- [ ] Seller dapat update limited fields
- [ ] Hanya admin yang bisa delete

#### 3. users
- [ ] User dapat read data sendiri
- [ ] Admin dapat read semua
- [ ] User tidak bisa ubah role sendiri
- [ ] Hanya admin yang bisa update role

---

### F. EDGE CASES & ERROR HANDLING ✅

#### 1. Network Issues
- [ ] Submit saat offline → error message jelas
- [ ] Loading image saat koneksi lambat → loading indicator
- [ ] Timeout handling berfungsi

#### 2. Invalid Data
- [ ] NIK < 16 digit → validation error
- [ ] Empty required fields → validation error
- [ ] Invalid format → error message

#### 3. User Already Registered
- [ ] Daftar 2x → dialog info sudah terdaftar
- [ ] Status pending ditampilkan
- [ ] Status approved ditampilkan
- [ ] Status rejected + alasan ditampilkan

#### 4. Image Issues
- [ ] Image terlalu besar → compress atau error
- [ ] Image format salah → error message
- [ ] Failed upload → retry atau error

#### 5. Permission Issues
- [ ] Non-admin akses admin page → redirect
- [ ] Warga coba approve → permission denied
- [ ] User coba update seller lain → permission denied

---

### G. UI/UX TESTING ✅

#### 1. Layout & Design
- [ ] Responsive di berbagai ukuran layar
- [ ] Semua text terbaca jelas
- [ ] Color scheme konsisten
- [ ] Icons jelas dan sesuai
- [ ] Spacing & padding proporsional

#### 2. Navigation
- [ ] Back button berfungsi
- [ ] Navigation flow jelas
- [ ] Deep link handling (jika ada)

#### 3. Feedback
- [ ] Loading indicator tampil saat proses
- [ ] Success message jelas
- [ ] Error message informatif
- [ ] Confirmation dialog muncul saat action penting

#### 4. Performance
- [ ] List seller load cepat (< 3 detik)
- [ ] Image load progressive
- [ ] Scroll smooth tanpa lag
- [ ] Real-time update cepat

---

## 📊 TESTING RESULTS

### Summary:
- **Total Test Cases**: ~150+
- **Must Pass**: All critical paths
- **Nice to Have**: Edge cases handling

### Critical Paths:
1. ✅ Warga dapat daftar sebagai seller
2. ✅ Admin dapat verifikasi seller
3. ✅ Approve seller berhasil → user dapat berjualan
4. ✅ Reject seller berhasil → alasan jelas
5. ✅ Security rules berfungsi dengan baik

---

## 🐛 BUG TRACKING

### Format Bug Report:
```
BUG #001
Title: [Deskripsi singkat bug]
Severity: [Critical/High/Medium/Low]
Steps to Reproduce:
1. ...
2. ...
Expected: ...
Actual: ...
Screenshot: [attach if needed]
Status: [Open/In Progress/Fixed]
```

---

## ✅ SIGN-OFF

### Tested By:
- **Name**: _________________
- **Role**: _________________
- **Date**: _________________
- **Signature**: _________________

### Test Environment:
- **Device**: _________________
- **OS Version**: _________________
- **App Version**: _________________
- **Flutter Version**: _________________

### Overall Status:
- [ ] ✅ PASS - Ready for production
- [ ] ⚠️ PASS with minor issues - Can deploy with notes
- [ ] ❌ FAIL - Major issues, need fixing

### Notes:
```
_________________________________________________
_________________________________________________
_________________________________________________
```

---

**Testing Checklist Version**: 1.0.0  
**Last Updated**: 27 November 2025  
**Project**: PBL 2025 - Kelola Lapak Feature

