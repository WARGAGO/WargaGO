# 📊 STRUKTUR FOLDER FINAL - JAWARA APP

## 🎯 KLASIFIKASI LENGKAP

---

## 🔵 **GENERAL/COMMON** (Semua User Lewat Sini)

Folder-folder ini adalah bagian dari alur umum yang **WAJIB** dilalui oleh semua user (admin maupun warga):

### **1. Splash**
```
lib/features/splash/
└── splash_page.dart
```
**Fungsi:** Screen pertama saat app dibuka, animasi logo

### **2. Onboarding**
```
lib/features/onboarding/
├── onboarding_page.dart
└── widgets/
```
**Fungsi:** Pengenalan aplikasi untuk user baru

### **3. Pre-Auth**
```
lib/features/pre_auth/
└── pre_auth_page.dart
```
**Fungsi:** Halaman pemilihan role - "Login Admin" atau "Daftar/Login Warga"

### **4. Auth (Autentikasi)**
```
lib/features/auth/
├── presentation/pages/
│   ├── admin/
│   │   └── admin_login_page.dart        # Login admin
│   │
│   ├── warga/
│   │   ├── warga_register_page.dart     # Register warga baru
│   │   ├── warga_login_page.dart        # Login warga
│   │   └── kyc_upload_page.dart         # Upload KYC (KTP, Selfie)
│   │
│   └── status/
│       ├── pending_approval_page.dart   # Status menunggu approval
│       └── rejected_page.dart           # Status ditolak
│
├── widgets/                             # Shared auth widgets
│   ├── auth_constants.dart
│   └── auth_widgets.dart
│
└── [old files...]                       # File lama (akan deprecated)
```
**Fungsi:** Semua yang berhubungan dengan autentikasi (login, register, verifikasi)

---

## 🔴 **FITUR ADMIN** (Khusus Admin)

Folder-folder ini hanya bisa diakses oleh **ADMIN** setelah login:

### **1. Dashboard Admin**
```
lib/features/dashboard/                  ⚠️ INI ADMIN DASHBOARD!
├── dashboard_page.dart                  # Dashboard utama admin
├── dashboard_detail_page.dart
├── activity_detail_page.dart
├── log_aktivitas_page.dart
├── pesan_warga_page.dart
└── widgets/                             # Dashboard widgets
```
**Fungsi:** Dashboard utama untuk admin, overview semua data

### **2. Admin (Fitur Khusus)**
```
lib/features/admin/
├── pages/
│   ├── kyc_verification_page.dart       # Verifikasi KYC warga
│   └── ocr_test_page.dart
└── widgets/
```
**Fungsi:** Fitur-fitur khusus admin (verifikasi, approval, dll)

### **3. Agenda**
```
lib/features/agenda/
```
**Fungsi:** Kelola agenda & kegiatan RT/RW

### **4. Data Warga**
```
lib/features/data_warga/
```
**Fungsi:** Kelola data penduduk, CRUD warga

### **5. Kelola Lapak**
```
lib/features/kelola_lapak/
```
**Fungsi:** Manajemen lapak/warung warga

### **6. Keuangan**
```
lib/features/keuangan/
```
**Fungsi:** Kelola keuangan RT/RW (pemasukan, pengeluaran, mutasi)

### **7. Tagihan**
```
lib/features/tagihan/
```
**Fungsi:** Kelola tagihan warga (iuran, dll)

---

## 🟢 **FITUR WARGA** (Khusus Warga)

Folder-folder ini hanya bisa diakses oleh **WARGA** setelah login & approved:

### **1. Dashboard Warga**
```
lib/features/warga/
└── warga_dashboard_page.dart            ✅ SUDAH DIPINDAH!
```
**Fungsi:** Dashboard untuk warga, lihat tagihan, agenda, dll

### **2. (Future) Fitur Warga Lainnya**
```
lib/features/warga/
├── warga_dashboard_page.dart
├── warga_tagihan_page.dart              # (Future) Lihat tagihan
├── warga_agenda_page.dart               # (Future) Lihat agenda
└── warga_lapak_page.dart                # (Future) Kelola lapak sendiri
```
**Note:** Fitur-fitur ini bisa ditambahkan nanti sesuai kebutuhan

---

## 🏗️ **CORE** (Infrastructure)

```
lib/core/
├── constants/
│   ├── app_routes.dart                  # Route constants
│   └── ...
│
├── enums/
│   ├── user_status.dart                 # Status user enum
│   └── ...
│
├── models/
│   ├── user_model.dart
│   ├── agenda_model.dart
│   └── ...
│
├── providers/
│   ├── auth_provider.dart               # State management auth
│   └── ...
│
├── services/
│   ├── kyc_service.dart
│   └── ...
│
└── theme/
    └── app_theme.dart
```

---

## 📱 **APP** (Configuration)

```
lib/app/
├── app.dart                             # MaterialApp configuration
└── routes.dart                          # Route generator
```

---

## 🎨 **VISUALISASI FOLDER TREE**

```
lib/
│
├── 🔵 GENERAL/COMMON ──────────────────────────
│   ├── features/splash/
│   ├── features/onboarding/
│   ├── features/pre_auth/
│   └── features/auth/
│
├── 🔴 ADMIN FEATURES ──────────────────────────
│   ├── features/dashboard/         ⚠️ Admin Dashboard
│   ├── features/admin/
│   ├── features/agenda/
│   ├── features/data_warga/
│   ├── features/kelola_lapak/
│   ├── features/keuangan/
│   └── features/tagihan/
│
├── 🟢 WARGA FEATURES ──────────────────────────
│   └── features/warga/
│
├── 🏗️ CORE ────────────────────────────────────
│   └── core/
│       ├── constants/
│       ├── enums/
│       ├── models/
│       ├── providers/
│       ├── services/
│       └── theme/
│
└── 📱 APP ─────────────────────────────────────
    └── app/
        ├── app.dart
        └── routes.dart
```

---

## 🚦 **ALUR NAVIGASI**

### **User Flow:**
```
[App Start]
    ↓
[🔵 Splash] ← GENERAL
    ↓
[🔵 Onboarding] ← GENERAL
    ↓
[🔵 PreAuth] ← GENERAL - Pilih Role
    ↓
    ├──────────────────┬──────────────────┐
    │                  │                  │
[ADMIN]          [WARGA BARU]      [WARGA LOGIN]
    ↓                  ↓                  ↓
[🔵 Admin Login]  [🔵 Warga Register] [🔵 Warga Login]
    ↓                  ↓                  ↓
[🔴 Admin          [🔵 KYC Upload]   [Status Check]
 Dashboard]            ↓                  ↓
                  [🔵 Pending]      [🟢 Warga
                       ↓             Dashboard]
                  [Admin Approve]
                       ↓
                  [🟢 Warga
                   Dashboard]
```

**Legenda:**
- 🔵 = GENERAL/COMMON (semua user)
- 🔴 = ADMIN ONLY
- 🟢 = WARGA ONLY

---

## ✅ **STATUS IMPLEMENTASI**

| Kategori | Status | Keterangan |
|----------|--------|------------|
| 🔵 General/Common | ✅ 100% | Splash, Onboarding, PreAuth, Auth |
| 🔴 Admin Features | ✅ 100% | Sudah ada & berjalan |
| 🟢 Warga Features | ✅ 90% | Dashboard sudah dipindah, fitur lain masih di-develop |
| 🏗️ Core Infrastructure | ✅ 100% | Routes, Enums, Models, Services |
| 📱 App Config | ✅ 100% | Named routes configured |

---

## 📝 **CATATAN PENTING**

### **Pemisahan yang Jelas:**
1. **GENERAL/COMMON** = Dipakai semua user (admin & warga)
2. **ADMIN** = Hanya admin (dashboard, agenda, keuangan, dll)
3. **WARGA** = Hanya warga (dashboard warga, lihat tagihan, dll)

### **File yang Sudah Dipindah:**
- ✅ `warga_dashboard_page.dart` dari `features/auth/` → `features/warga/`
- ✅ Semua import path sudah diupdate (7 files)

### **File yang Masih di Auth (Old):**
File-file ini masih ada untuk backward compatibility, bisa dihapus nanti:
- `lib/features/auth/login_page.dart`
- `lib/features/auth/register_page.dart`
- `lib/features/auth/warga_register_page.dart`
- `lib/features/auth/kyc_upload_page.dart`

---

**Last Updated:** November 24, 2025  
**Status:** ✅ **STRUKTUR FINAL - CLEAR & ORGANIZED**

