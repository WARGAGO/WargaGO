# 📋 Rencana Restrukturisasi Alur Autentikasi

## 🎯 Tujuan
Membuat struktur autentikasi yang **RAPI, JELAS, dan MUDAH DIPAHAMI** untuk 2 tipe user:
- **Admin** (sudah ada akun)
- **Warga** (harus daftar & diverifikasi)

---

## 📊 Alur Lengkap (Flow Diagram)

### **ALUR BERSAMA (Semua User)**
```
┌─────────────────┐
│  Splash Screen  │ ← Semua user mulai di sini
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Onboarding     │ ← Pengenalan aplikasi (bisa skip jika sudah pernah)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Pre-Auth      │ ← Pilihan: "Masuk sebagai Admin" atau "Daftar sebagai Warga"
└────────┬────────┘
         │
         ├──────────────────┬─────────────────┐
         │                  │                 │
    [ADMIN]           [WARGA BARU]      [WARGA SUDAH TERDAFTAR]
```

### **ALUR ADMIN**
```
┌─────────────────┐
│  Admin Login    │
└────────┬────────┘
         │
    [Cek Status]
         │
         ├─── Approved ────▶ ┌──────────────────┐
         │                   │  Admin Dashboard │
         │                   └──────────────────┘
         │
         ├─── Pending ─────▶ Halaman "Menunggu Persetujuan"
         │
         └─── Rejected ────▶ Halaman "Akun Ditolak"
```

### **ALUR WARGA**
```
┌─────────────────────┐
│  Warga Registration │ ← Daftar akun baru
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│    KYC Upload       │ ← Upload foto KTP, selfie
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Menunggu Verifikasi│ ← Tampilan pending approval
│   (Pending Screen)  │   User tidak bisa masuk dashboard
└──────────┬──────────┘
           │
      [Admin Verifikasi]
           │
           ├─── Approved ────▶ ┌──────────────────┐
           │                   │  Warga Dashboard │
           │                   └──────────────────┘
           │
           └─── Rejected ────▶ Halaman "Registrasi Ditolak"
```

---

## 🗂️ Struktur Direktori (ACTUAL - Yang Sudah Ada)

```
lib/
├── app/
│   ├── app.dart                          # ✅ Main app dengan routes
│   └── routes.dart                       # ✅ Semua named routes terpusat
│
├── core/
│   ├── constants/
│   │   └── app_routes.dart               # ✅ Konstanta nama route
│   ├── enums/
│   │   └── user_status.dart              # ✅ Enum: unverified, pending, approved, rejected
│   ├── models/
│   │   ├── user_model.dart               # (existing)
│   │   └── agenda_model.dart             # (existing)
│   └── providers/
│       └── auth_provider.dart            # (existing) State management autentikasi
│
├── features/
│   │
│   ├── splash/
│   │   └── splash_page.dart              # ✅ Screen pertama (updated)
│   │
│   ├── onboarding/
│   │   └── onboarding_page.dart          # ✅ Intro app (updated)
│   │
│   ├── pre_auth/
│   │   └── pre_auth_page.dart            # ✅ Pilih role: Admin/Warga (updated)
│   │
│   ├── auth/                             # ← FOLDER AUTENTIKASI
│   │   │
│   │   ├── presentation/pages/           # ✅ STRUKTUR BARU
│   │   │   ├── admin/
│   │   │   │   └── admin_login_page.dart # ✅ Login admin
│   │   │   │
│   │   │   ├── warga/
│   │   │   │   ├── warga_register_page.dart  # ✅ Register warga
│   │   │   │   ├── warga_login_page.dart     # ✅ Login warga
│   │   │   │   └── kyc_upload_page.dart      # ✅ Upload KYC
│   │   │   │
│   │   │   └── status/
│   │   │       ├── pending_approval_page.dart  # ✅ Halaman pending
│   │   │       └── rejected_page.dart          # ✅ Halaman rejected
│   │   │
│   │   ├── widgets/                      # (existing) Shared auth widgets
│   │   │   ├── auth_constants.dart
│   │   │   └── auth_widgets.dart
│   │   │
│   │   ├── login_page.dart               # (old) Will be deprecated
│   │   ├── register_page.dart            # (old) Admin register
│   │   ├── warga_register_page.dart      # (old) Moved to presentation/
│   │   ├── kyc_upload_page.dart          # (old) Moved to presentation/
│   │   └── warga_dashboard_page.dart     # Warga dashboard
│   │
│   ├── dashboard/                        # ⚠️ INI ADMIN DASHBOARD!
│   │   ├── dashboard_page.dart           # Admin Dashboard utama
│   │   ├── dashboard_detail_page.dart
│   │   ├── activity_detail_page.dart
│   │   ├── log_aktivitas_page.dart
│   │   └── widgets/                      # Dashboard widgets
│   │
│   ├── admin/                            # ⚠️ FITUR-FITUR ADMIN LAINNYA
│   │   ├── pages/
│   │   │   ├── kyc_verification_page.dart
│   │   │   └── ocr_test_page.dart
│   │   └── widgets/
│   │
│   ├── agenda/                           # Fitur agenda (admin & warga)
│   ├── data_warga/                       # Fitur data warga (admin)
│   ├── keuangan/                         # Fitur keuangan (admin)
│   ├── tagihan/                          # Fitur tagihan
│   └── ... (fitur lainnya)
│
└── main.dart
```

**CATATAN PENTING:**
- ✅ `features/dashboard/` = **ADMIN DASHBOARD** (bukan warga!)
- ✅ `features/admin/` = **FITUR TAMBAHAN ADMIN** (verifikasi KYC, dll)
- ✅ `features/auth/presentation/` = **STRUKTUR BARU yang sudah dibuat**
- ⚠️ File lama di `features/auth/` akan deprecated setelah migrasi selesai

---

## 🔄 Status User yang Konsisten

**Sebelumnya**: Ada 2 sistem berbeda untuk admin & warga (membingungkan!)

**Sekarang**: **1 ENUM untuk semua user**

```dart
enum UserStatus {
  unverified,  // Baru daftar, belum upload KYC
  pending,     // Sudah upload KYC, menunggu admin approve
  approved,    // Sudah disetujui, bisa akses penuh
  rejected,    // Ditolak admin
}
```

---

## 🛤️ Named Routes (Terpusat)

File: `lib/core/constants/app_routes.dart`
```dart
class AppRoutes {
  // Common
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const preAuth = '/pre-auth';
  
  // Admin
  static const adminLogin = '/admin/login';
  static const adminDashboard = '/admin/dashboard';
  
  // Warga
  static const wargaRegister = '/warga/register';
  static const wargaLogin = '/warga/login';
  static const wargaKYC = '/warga/kyc';
  static const wargaDashboard = '/warga/dashboard';
  
  // Status screens
  static const pending = '/pending';
  static const rejected = '/rejected';
}
```

---

## ✅ Keuntungan Struktur Baru

1. **Jelas & Terpisah**: Admin dan Warga punya folder sendiri
2. **Mudah Ditemukan**: File dikelompokkan berdasarkan fungsi (presentation/domain/data)
3. **Konsisten**: Semua user pakai status enum yang sama
4. **Navigasi Terpusat**: Named routes, tidak ada Navigator.push berserakan
5. **Mudah Maintenance**: Mau ubah flow? Tinggal lihat routes.dart
6. **Scalable**: Mau tambah role baru? Tinggal buat folder baru

---

## 🚀 Langkah Implementasi

### **FASE 1: Persiapan** (30 menit)
- [x] Buat dokumen ini
- [ ] Buat enum `UserStatus`
- [ ] Buat konstanta `AppRoutes`
- [ ] Setup named routes di `app.dart`

### **FASE 2: Reorganisasi File** (1 jam)
- [ ] Pindahkan file ke struktur baru
- [ ] Update import paths
- [ ] Test compile (pastikan tidak ada error)

### **FASE 3: Implementasi Logic** (2 jam)
- [ ] Update `AuthProvider` untuk pakai `UserStatus` enum
- [ ] Update navigation logic ke named routes
- [ ] Buat halaman pending/rejected
- [ ] Integrasikan flow lengkap

### **FASE 4: Testing** (1 jam)
- [ ] Test alur admin login
- [ ] Test alur warga register → KYC → pending → approved
- [ ] Test alur warga rejected
- [ ] Test semua edge cases

---

## 📝 Catatan Penting

### **Keputusan yang Perlu Diskusi:**

1. **Pre-Auth Page**: Apakah warga sudah terdaftar bisa login dari sini? Atau harus buat tombol terpisah?
   - **Rekomendasi**: Tambah tombol "Sudah punya akun warga? Login di sini"

2. **KYC Verification**: Sekarang KYC ada di `features/auth/`. Apakah mau dipisah jadi `features/kyc/`?
   - **Rekomendasi**: Tetap di `auth/` karena bagian dari registrasi

3. **Onboarding**: Apakah wajib ditampilkan setiap kali atau sekali saja?
   - **Rekomendasi**: Skip otomatis jika sudah pernah lihat (simpan flag di SharedPreferences)

---

## 🎨 Mockup Flow (Simplified)

```
[SPLASH] 
   ↓ (2 detik)
[ONBOARDING] (skip jika sudah pernah)
   ↓
[PRE-AUTH]
   ├─ [Masuk sebagai Admin] → [Admin Login] → [Admin Dashboard]
   └─ [Daftar sebagai Warga] → [Warga Register] → [KYC Upload] → [Pending] → (menunggu) → [Warga Dashboard]
```

---

**Apakah struktur ini sudah sesuai dengan kebutuhan Anda?**
Jika iya, saya akan langsung implementasikan! 🚀

