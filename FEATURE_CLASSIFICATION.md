# 📊 KLASIFIKASI FITUR - ADMIN vs WARGA

## ✅ Status: SUDAH TERKLASIFIKASI

Tanggal: 24 November 2025

---

## 🗂️ STRUKTUR FOLDER SAAT INI

```
lib/features/
│
├── ──────────────────────────────────────────────
│   🔵 COMMON/GENERAL (Dipakai semua user)
├── ──────────────────────────────────────────────
│
├── splash/                  ✅ GENERAL
├── onboarding/              ✅ GENERAL
├── pre_auth/                ✅ GENERAL
├── auth/                    ✅ GENERAL
│   └── presentation/
│       ├── pages/
│       │   ├── admin/       (Login admin)
│       │   ├── warga/       (Register, Login, KYC warga)
│       │   └── status/      (Pending, Rejected)
│       └── widgets/
│
├── ──────────────────────────────────────────────
│   🔴 ADMIN FEATURES (Khusus admin)
├── ──────────────────────────────────────────────
│
├── admin/                   ✅ ADMIN
│   ├── pages/
│   │   ├── kyc_verification_page.dart
│   │   └── ocr_test_page.dart
│   ├── widgets/
│   └── admin_kyc_approval_page_example.dart
│
├── dashboard/               ✅ ADMIN
│   ├── dashboard_page.dart
│   ├── dashboard_detail_page.dart
│   ├── activity_detail_page.dart
│   ├── log_aktivitas_page.dart
│   ├── pesan_warga_page.dart
│   ├── penanggung_jawab_detail_page.dart
│   ├── notification_popup.dart
│   └── widgets/
│
├── agenda/                  ✅ ADMIN
│   ├── agenda_example_page.dart
│   ├── broadcast/
│   └── kegiatan/
│
├── data_warga/              ✅ ADMIN
│   ├── data_mutasi/
│   ├── data_penduduk/
│   ├── kelola_pengguna/
│   ├── terima_warga/
│   └── data_warga_main_page.dart
│
├── kelola_lapak/            ✅ ADMIN
│   └── (isi folder kelola lapak)
│
├── keuangan/                ✅ ADMIN
│   ├── kelola_pemasukan/
│   ├── kelola_pengeluaran/
│   ├── keuangan_page.dart
│   ├── detail_laporan_keuangan_page.dart
│   ├── models/
│   ├── providers/
│   └── widgets/
│
├── tagihan/                 ✅ ADMIN
│   ├── pages/
│   └── widgets/
│
├── ──────────────────────────────────────────────
│   🟢 WARGA FEATURES (Khusus warga)
├── ──────────────────────────────────────────────
│
└── warga/                   ✅ WARGA
    ├── warga_dashboard_page.dart
    └── kyc/                 ✅ MOVED!
        └── pages/
            ├── kyc_step1_ktp_page.dart
            ├── kyc_step2_kk_page.dart
            ├── kyc_step3_akte_page.dart
            ├── kyc_step4_face_page.dart
            ├── kyc_step5_review_page.dart
            ├── kyc_step6_complete_data_page.dart
            └── kyc_upload_wizard_page.dart
```

---

## 📋 KLASIFIKASI DETAIL

### **🔵 GENERAL/COMMON (4 folders)**

Fitur yang digunakan oleh **SEMUA USER** (admin & warga):

| Folder | Fungsi | Status |
|--------|--------|--------|
| `splash/` | Splash screen saat app start | ✅ Sudah benar |
| `onboarding/` | Onboarding/intro app | ✅ Sudah benar |
| `pre_auth/` | Pemilihan role (Admin/Warga) | ✅ Sudah benar |
| `auth/` | Login, Register, KYC, Status | ✅ Sudah benar |

### **🔴 ADMIN FEATURES (7 folders)**

Fitur yang **HANYA BISA DIAKSES ADMIN**:

| Folder | Fungsi | Isi | Status |
|--------|--------|-----|--------|
| `admin/` | Fitur admin khusus | KYC verification, OCR test | ✅ Sudah benar |
| `dashboard/` | Dashboard admin | Overview, activities, logs, notif | ✅ Sudah benar |
| `agenda/` | Kelola agenda & kegiatan | Broadcast, kegiatan | ✅ Sudah benar |
| `data_warga/` | Kelola data warga | Mutasi, penduduk, pengguna, terima warga | ✅ Sudah benar |
| `kelola_lapak/` | Kelola lapak/warung | Manajemen lapak warga | ✅ Sudah benar |
| `keuangan/` | Kelola keuangan | Pemasukan, pengeluaran, laporan | ✅ Sudah benar |
| `tagihan/` | Kelola tagihan | Create, edit, delete tagihan | ✅ Sudah benar |

### **🟢 WARGA FEATURES (1 folder)**

Fitur yang **HANYA BISA DIAKSES WARGA**:

| Folder | Fungsi | Isi | Status |
|--------|--------|-----|--------|
| `warga/` | Fitur warga | Dashboard, KYC upload wizard | ✅ Sudah benar |
| `warga/kyc/` | Upload dokumen KYC | Step-by-step upload KTP, KK, Akte, Face | ✅ BARU DIPINDAH! |

---

## 🔄 PERUBAHAN YANG SUDAH DILAKUKAN

### **1. Pemindahan Folder KYC** ✅
```
FROM: lib/features/kyc/
TO:   lib/features/warga/kyc/
```

**Alasan:** KYC adalah fitur untuk warga upload dokumen, bukan fitur general.

**File yang dipindah:**
- `kyc_step1_ktp_page.dart`
- `kyc_step2_kk_page.dart`
- `kyc_step3_akte_page.dart`
- `kyc_step4_face_page.dart`
- `kyc_step5_review_page.dart`
- `kyc_step6_complete_data_page.dart`
- `kyc_upload_wizard_page.dart`

**Import path update:** Tidak ada file yang mengimport dari `features/kyc/` lama, jadi tidak perlu update import.

---

## 📊 STATISTIK

| Kategori | Jumlah Folder | Status |
|----------|---------------|--------|
| 🔵 GENERAL/COMMON | 4 | ✅ Complete |
| 🔴 ADMIN FEATURES | 7 | ✅ Complete |
| 🟢 WARGA FEATURES | 1 (+kyc/) | ✅ Complete |
| **TOTAL** | **12** | **✅ 100%** |

---

## 🎯 BENEFIT STRUKTUR INI

### **Kejelasan:**
✅ Jelas mana fitur admin, mana fitur warga  
✅ Mudah mencari fitur berdasarkan role  
✅ Tidak ada fitur yang "nyasar" ke folder yang salah

### **Maintenance:**
✅ Mudah maintain per role  
✅ Mudah add fitur baru (tinggal taruh di folder yang sesuai)  
✅ Mudah debug (langsung tahu file untuk role apa)

### **Scalability:**
✅ Mudah tambah role baru (misal: RT, RW, Ketua)  
✅ Mudah split fitur jika perlu  
✅ Clean architecture

---

## 📝 NEXT STEPS (Optional)

### **Jika Mau Lebih Rapi (Advanced):**

Bisa reorganisasi jadi struktur nested:

```
lib/features/
├── common/
│   ├── splash/
│   ├── onboarding/
│   ├── pre_auth/
│   └── auth/
│
├── admin/
│   ├── core/           (rename dari admin/)
│   ├── dashboard/
│   ├── agenda/
│   ├── data_warga/
│   ├── kelola_lapak/
│   ├── keuangan/
│   └── tagihan/
│
└── warga/
    ├── dashboard/
    └── kyc/
```

**TAPI** ini akan mengubah banyak import path, jadi **NOT RECOMMENDED** kecuali memang perlu refactor besar.

---

## ✅ KESIMPULAN

### **STRUKTUR SAAT INI SUDAH BAGUS!**

- ✅ Semua fitur sudah terklasifikasi dengan benar
- ✅ Tidak ada fitur yang "nyasar"
- ✅ Mudah dipahami dan dimaintain
- ✅ Ready for production

**No further action needed!** 🎉

---

**Updated:** November 24, 2025  
**Status:** ✅ **KLASIFIKASI SELESAI**

