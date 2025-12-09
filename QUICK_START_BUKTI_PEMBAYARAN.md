# 🚀 QUICK START - Upload Bukti Pembayaran Iuran

## ⚡ Cara Menggunakan (5 Menit)

### 1️⃣ Import Service (Sudah Terintegrasi)

File `bayar_iuran_simple_page.dart` sudah diupdate menggunakan **Azure Blob Storage**.  
✅ Tidak perlu import tambahan!

### 2️⃣ Navigasi ke Halaman Bayar

**Dari List Tagihan atau Detail Iuran:**

```dart
// ✅ Pass tagihan ID untuk proses pembayaran
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BayarIuranSimplePage(
      tagihanId: tagihan.id,  // ⭐ WAJIB: Tagihan ID
      namaIuran: tagihan.jenisIuranName,
      nominal: tagihan.nominal,
      tanggal: DateFormat('dd MMM yyyy', 'id_ID').format(tagihan.periodeTanggal),
    ),
  ),
);
```

### 3️⃣ ✅ File Sudah Diupdate

**File yang sudah diupdate:**
- ✅ `bayar_iuran_simple_page.dart` - Menggunakan Azure Blob Storage
- ✅ `iuran_detail_page.dart` - Pass tagihanId dengan benar
- ✅ `iuran_list_item.dart` - Pass tagihanId dari list
- ✅ `iuran_header_card.dart` - Pass tagihanId dari header

**Tidak perlu update import!** Semua file sudah menggunakan yang benar.

### 4️⃣ Test Flow

1. ✅ **Hot Restart** aplikasi (WAJIB!)
   ```bash
   flutter clean
   flutter run
   ```
2. ✅ Buka halaman iuran warga
3. ✅ Tap tagihan yang belum dibayar
4. ✅ Tap tombol "Bayar Sekarang"
5. ✅ Pilih metode pembayaran
6. ✅ Upload bukti dari gallery
7. ✅ Tap "Kirim Bukti Pembayaran"
8. ✅ Konfirmasi → Success!

---

## 🎯 Perubahan dari Firebase Storage ke Azure

| Aspect | ❌ Firebase Storage (OLD) | ✅ Azure Blob Storage (NEW) |
|--------|--------------------------|----------------------------|
| **File** | bayar_iuran_simple_page.dart | bayar_iuran_simple_page.dart (UPDATED) |
| **Import** | firebase_storage | bukti_pembayaran_service |
| **Upload** | Firebase Storage | Azure Blob Storage |
| **URL** | Signed URL (expired) | Permanent URL |
| **Tagihan ID** | Query by name | Direct by ID |
| **Service** | Manual upload + update | Atomic transaction |

---

## 📋 Checklist Before Use

- [x] Azure Blob Storage configured (public container)
- [x] Backend API endpoints ready (`/storage/public/upload`)
- [x] Firebase Authentication working
- [x] Files sudah diupdate (no `_new` files)
- [ ] Test upload gambar berhasil
- [ ] Test URL bukti tidak expired
- [ ] Test tagihan status updated ke "Lunas"
- [ ] Test keuangan record created

---

## 🔥 Key Features

✅ **Azure Blob Storage** - URL permanen, tidak expired  
✅ **CRUD Complete** - Update tagihan + Create keuangan  
✅ **Atomic Transaction** - Data consistency guaranteed  
✅ **Modern UI** - Clean, user-friendly  
✅ **Image Preview** - Lihat gambar sebelum upload  
✅ **Confirmation** - Dialog konfirmasi sebelum submit  
✅ **Error Handling** - User-friendly error messages  
✅ **Loading State** - Clear feedback saat upload  

---

## 💡 Tips

### Performance:
- Image di-compress otomatis (quality 85%)
- Max size 1920x1920 untuk balance quality/size

### Security:
- Firebase token untuk autentikasi
- Backend validate sebelum upload
- Public container (read public, write authenticated)

### User Experience:
- Loading indicator saat upload
- Konfirmasi dialog sebelum submit
- Clear success/error messages
- Auto redirect + refresh setelah success

---

## 🚨 Troubleshooting

### Error: "Gagal mengirim: [firebase_storage/object-not-found]"
**Solution:** File sudah diupdate, lakukan **Hot Restart** (bukan hot reload!)

### Error: "Undefined name '_buktiService'"
**Solution:** File tidak terupdate dengan benar, pastikan menggunakan file terbaru

### Error: "tagihanId is required"
**Solution:** Pastikan pass `tagihanId` saat navigasi ke BayarIuranSimplePage

---

## 📞 Need Help?

Baca dokumentasi lengkap di: `IMPLEMENTASI_UPLOAD_BUKTI_PEMBAYARAN_AZURE.md`

**Happy Coding! 🚀**

