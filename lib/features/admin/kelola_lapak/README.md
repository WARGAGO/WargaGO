# 🏪 Kelola Lapak Feature

> Sistem verifikasi dan manajemen seller/penjual di marketplace warga

## 📋 Overview

Fitur **Kelola Lapak** memungkinkan admin untuk memverifikasi dan mengelola seller yang ingin berjualan di marketplace warga. Sistem ini dirancang untuk mencegah penipuan dan memastikan semua seller terverifikasi dengan baik.

## ✨ Features

### For Admin (Verifikator)
- ✅ Dashboard dengan statistik real-time
- ✅ Verifikasi seller dengan dokumen lengkap
- ✅ Approve/Reject seller dengan catatan
- ✅ Suspend/Reactivate seller
- ✅ Trust score & complaint tracking

### For Warga (Calon Seller)
- ✅ Form pendaftaran lengkap
- ✅ Upload dokumen (KTP, Selfie KTP, Foto Toko)
- ✅ Auto-fill data dari profil
- ✅ Status tracking pendaftaran

## 📁 File Structure

```
lib/features/admin/kelola_lapak/
├── models/
│   └── pending_seller_model.dart       # Model data seller
├── repositories/
│   └── pending_seller_repository.dart  # CRUD operations
├── pages/
│   └── detail_seller_page.dart        # Detail & verification page
└── kelola_lapak_page.dart             # Main dashboard page

lib/features/warga/marketplace/
├── pages/
│   └── seller_registration_form_page.dart  # Form pendaftaran
└── widgets/
    └── marketplace_daftar_button.dart      # Button to register
```

## 🚀 Quick Start

### 1. Setup Firebase

**Firestore Rules** (WAJIB):
```bash
# Copy rules dari file: firestore_rules_kelola_lapak.txt
# Paste ke Firebase Console > Firestore Database > Rules
```

**Firestore Indexes** (WAJIB):
```bash
# Import indexes dari: firestore_indexes_kelola_lapak.json
# Atau buat manual di Firebase Console > Firestore Database > Indexes
```

### 2. Test Fitur

**Sebagai Warga**:
1. Login sebagai warga
2. Buka Marketplace
3. Klik "Daftar sebagai Penjual"
4. Isi form dan upload dokumen
5. Submit pendaftaran

**Sebagai Admin**:
1. Login sebagai admin
2. Buka Dashboard Admin
3. Pilih "Kelola Lapak"
4. Verifikasi seller di tab Pending
5. Approve atau Reject

## 📚 Documentation

- **📖 Technical Documentation**: `KELOLA_LAPAK_DOCUMENTATION.md`
- **🚀 Quick Guide**: `KELOLA_LAPAK_QUICK_GUIDE.md`
- **📋 Testing Checklist**: `KELOLA_LAPAK_TESTING_CHECKLIST.md`
- **📊 Implementation Summary**: `KELOLA_LAPAK_IMPLEMENTATION_SUMMARY.md`

## 🔐 Verification Criteria

### ✅ APPROVE if:
- Foto KTP jelas dan valid
- Foto Selfie dengan KTP sesuai
- Data pribadi lengkap dan valid
- Deskripsi usaha masuk akal
- Tidak ada red flags

### ❌ REJECT if:
- Dokumen tidak jelas/blur
- Foto selfie palsu
- Data tidak valid
- Alamat fiktif
- Indikasi penipuan

## 🗄️ Database Collections

### `pending_sellers`
Status: pending, approved, rejected, suspended

### `approved_sellers`
Active sellers yang sudah diverifikasi

## 🔒 Security

- Role-based access control
- Document verification required
- Anti-fraud dengan selfie KTP
- Trust score tracking

## 📱 Screenshots

(Add screenshots here when available)

## 🛠️ Maintenance

### Daily Tasks:
- Check pending sellers
- Verify new registrations

### Weekly Tasks:
- Review approved sellers
- Handle complaints

### Monthly Tasks:
- Clean up rejected sellers
- Update trust scores

## 🚀 Future Enhancements

- [ ] Email/SMS notifications
- [ ] RT/RW approval workflow
- [ ] ML/AI document verification
- [ ] Rating & review system
- [ ] Product management
- [ ] Order & payment integration

## 📞 Support

For questions or issues, contact the admin team.

## 📝 License

Part of PBL 2025 - Sistem Manajemen RT/RW

---

**Version**: 1.0.0  
**Last Updated**: 27 November 2025  
**Status**: ✅ Ready for Deployment

