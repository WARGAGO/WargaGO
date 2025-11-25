# 🚀 QUICK START - KYC Alert & Menu Restriction

## ✅ Implementasi Selesai!

Sistem KYC Alert dan pembatasan menu sudah berhasil diterapkan di dashboard warga.

---

## 🎯 Fitur Utama

### 1. **KYC Alert Banner**
- Muncul otomatis jika warga belum upload/verify KYC
- Real-time update (StreamBuilder)
- Tombol "Upload" langsung ke KYC wizard

### 2. **Menu Navigation**
```
Home | Pengumuman | [SCAN] | Pengaduan | Akun
 ✅       ✅         🔒        ✅        ✅
```

**Akses Tanpa KYC:**
- ✅ Home
- ✅ Pengumuman  
- ✅ Pengaduan
- ✅ Akun

**Perlu KYC Verified:**
- 🔒 Scan Button (disabled + lock icon)
- 🔒 Fitur lanjutan (future)

---

## 🧪 Cara Test

### **Opsi 1: Run dengan Script**
```powershell
.\test_kyc_alert.ps1
```

### **Opsi 2: Manual**
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📋 Test Checklist

### **Test 1: New User (No KYC)**
1. ✅ Login sebagai warga baru
2. ✅ Alert banner muncul dengan pesan "Lengkapi Data KYC"
3. ✅ Klik tombol "Upload" → Redirect ke KYC wizard
4. ✅ Scan button disabled (abu-abu + lock icon)
5. ✅ Klik scan button → Dialog "KYC Diperlukan" muncul
6. ✅ Bisa navigasi ke Home, Pengumuman, Pengaduan, Akun

### **Test 2: Pending Verification**
1. ✅ Upload KYC (KTP & KK)
2. ✅ Alert berubah: "Menunggu Verifikasi KYC"
3. ✅ Scan button masih disabled
4. ✅ Menu dasar tetap bisa diakses

### **Test 3: KYC Verified**
1. ✅ Login sebagai admin → Approve KYC
2. ✅ Login kembali sebagai warga
3. ✅ Alert banner HILANG
4. ✅ Scan button AKTIF (biru, tanpa lock)
5. ✅ Semua fitur accessible

---

## 📱 UI Preview

### **Alert Banner (No KYC)**
```
┌────────────────────────────────────────┐
│ ⚠️  Lengkapi Data KYC Anda            │
│     Upload KTP & KK untuk mengakses   │
│     semua fitur          [Upload] ───►│
└────────────────────────────────────────┘
```

### **Alert Banner (Pending)**
```
┌────────────────────────────────────────┐
│ ⚠️  Menunggu Verifikasi KYC           │
│     Data Anda sedang diverifikasi     │
│     admin                              │
└────────────────────────────────────────┘
```

### **Scan Button**
**Before KYC:**
```
  [📷] ← Gray, ada lock badge 🔒
```

**After KYC:**
```
  [📷] ← Blue, aktif ✅
```

---

## 🔧 File yang Dimodifikasi

**`lib/features/warga/warga_main_page.dart`**
- ✅ Import KYC service & provider
- ✅ StreamBuilder untuk real-time status
- ✅ KYC Alert Banner widget
- ✅ 5 navigation menus (bukan 4)
- ✅ Scan button dengan lock logic
- ✅ KYC Required Dialog
- ✅ Pengumuman & Pengaduan pages

---

## ⚡ Real-time Updates

Sistem menggunakan **Firebase StreamBuilder**:
- Status KYC update otomatis tanpa refresh
- Alert hilang langsung setelah admin approve
- Scan button aktif otomatis
- Tidak perlu logout/login

---

## 🎨 Design Features

### **Alert Banner:**
- Gradient kuning (warning)
- Icon peringatan
- Text yang jelas & informatif
- CTA button menonjol

### **Scan Button:**
- Blue gradient (verified)
- Gray gradient (not verified)
- Lock badge (🔒) untuk status locked
- Smooth animation

### **Dialog:**
- Clean & modern design
- List requirements
- 2 action buttons (Nanti / Upload Sekarang)

---

## 💡 Tips Development

### **Tambah Menu yang Perlu KYC:**
```dart
// Di _buildBottomNav()
_buildNavItem(
  index: X,
  icon: Icons.your_icon,
  activeIcon: Icons.your_active_icon,
  label: 'Menu Name',
  enabled: isKYCVerified, // ← Add this
),
```

### **Show Dialog untuk Fitur Lain:**
```dart
if (!isKYCVerified) {
  _showKYCRequiredDialog();
  return;
}
// Your feature code
```

### **Custom Alert Message:**
```dart
// Edit di _buildKYCAlertBanner()
Text(
  'Your custom message',
  style: GoogleFonts.poppins(...),
)
```

---

## 🐛 Troubleshooting

### **Alert tidak muncul:**
- Check Firebase connection
- Verify user login
- Check KYC service

### **Scan button selalu disabled:**
- Check KYC status di Firestore
- Verify both KTP & KK status = 'approved'
- Check StreamBuilder data

### **Error navigation:**
- Verify all pages imported
- Check IndexedStack index mapping

---

## 📞 Support

**Dokumentasi:**
- `KYC_ALERT_IMPLEMENTATION.md` - Detail lengkap
- `test_kyc_alert.ps1` - Test script

**Test:**
```bash
.\test_kyc_alert.ps1
```

---

## ✨ Summary

**Yang Sudah Jalan:**
- ✅ KYC Alert Banner (real-time)
- ✅ Menu restriction (5 menus)
- ✅ Scan button lock/unlock
- ✅ KYC Required Dialog
- ✅ Pengumuman & Pengaduan pages
- ✅ No errors, ready to test

**Yang Perlu Dilakukan:**
1. Test di device/emulator
2. Verify semua scenarios
3. Test real-time updates
4. Check UI di berbagai screen size

---

**Status:** ✅ **READY TO TEST**

**Run Now:**
```powershell
flutter run
```

Atau gunakan script:
```powershell
.\test_kyc_alert.ps1
```

**Selamat mencoba! 🎉**

