# ============================================================================
# TEST TAMBAH PRODUK - END TO END
# ============================================================================
# Test complete flow: Upload foto → Save to Firestore → Verify
# ============================================================================

Write-Host "================================" -ForegroundColor Cyan
Write-Host "TEST TAMBAH PRODUK" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "📋 Test Checklist:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1️⃣  PERSIAPAN" -ForegroundColor Cyan
Write-Host "   [ ] Firebase project sudah aktif" -ForegroundColor White
Write-Host "   [ ] PCVK API sudah running (Azure Storage)" -ForegroundColor White
Write-Host "   [ ] Firestore rules sudah di-deploy" -ForegroundColor White
Write-Host "   [ ] Firestore indexes sudah di-deploy" -ForegroundColor White
Write-Host ""

Write-Host "2️⃣  LOGIN & AUTHENTICATION" -ForegroundColor Cyan
Write-Host "   [ ] Login sebagai warga/penjual" -ForegroundColor White
Write-Host "   [ ] Verify Firebase token valid" -ForegroundColor White
Write-Host "   [ ] Check user role dan status" -ForegroundColor White
Write-Host ""

Write-Host "3️⃣  UPLOAD FOTO" -ForegroundColor Cyan
Write-Host "   [ ] Test pilih 1 foto dari galeri" -ForegroundColor White
Write-Host "   [ ] Test pilih 2 foto dari galeri" -ForegroundColor White
Write-Host "   [ ] Test pilih 3 foto dari galeri" -ForegroundColor White
Write-Host "   [ ] Test ambil foto dari kamera" -ForegroundColor White
Write-Host "   [ ] Test hapus foto yang sudah dipilih" -ForegroundColor White
Write-Host "   [ ] Test maksimal 3 foto (block upload ke-4)" -ForegroundColor White
Write-Host ""

Write-Host "4️⃣  FORM VALIDATION" -ForegroundColor Cyan
Write-Host "   [ ] Test submit tanpa foto (should error)" -ForegroundColor White
Write-Host "   [ ] Test submit tanpa nama produk (should error)" -ForegroundColor White
Write-Host "   [ ] Test submit tanpa kategori (should error)" -ForegroundColor White
Write-Host "   [ ] Test submit tanpa deskripsi (should error)" -ForegroundColor White
Write-Host "   [ ] Test submit tanpa harga (should error)" -ForegroundColor White
Write-Host "   [ ] Test submit tanpa stok (should error)" -ForegroundColor White
Write-Host "   [ ] Test submit harga = 0 (should error)" -ForegroundColor White
Write-Host "   [ ] Test submit harga negatif (should error)" -ForegroundColor White
Write-Host ""

Write-Host "5️⃣  AZURE STORAGE UPLOAD" -ForegroundColor Cyan
Write-Host "   [ ] Test upload ke Azure Storage" -ForegroundColor White
Write-Host "   [ ] Verify foto tersimpan di container 'public'" -ForegroundColor White
Write-Host "   [ ] Verify prefix 'products/'" -ForegroundColor White
Write-Host "   [ ] Verify filename format: product_{uid}_{timestamp}_{index}.jpg" -ForegroundColor White
Write-Host "   [ ] Verify blob URL returned" -ForegroundColor White
Write-Host "   [ ] Test handle upload failure" -ForegroundColor White
Write-Host ""

Write-Host "6️⃣  FIRESTORE SAVE" -ForegroundColor Cyan
Write-Host "   [ ] Test save product ke Firestore" -ForegroundColor White
Write-Host "   [ ] Verify document ID auto-generated" -ForegroundColor White
Write-Host "   [ ] Verify sellerId = current user UID" -ForegroundColor White
Write-Host "   [ ] Verify sellerName dari AuthProvider" -ForegroundColor White
Write-Host "   [ ] Verify imageUrls array (max 3)" -ForegroundColor White
Write-Host "   [ ] Verify timestamps (createdAt, updatedAt)" -ForegroundColor White
Write-Host "   [ ] Verify isActive = true" -ForegroundColor White
Write-Host "   [ ] Verify terjual = 0" -ForegroundColor White
Write-Host ""

Write-Host "7️⃣  SUCCESS FEEDBACK" -ForegroundColor Cyan
Write-Host "   [ ] Success snackbar muncul" -ForegroundColor White
Write-Host "   [ ] Auto navigate back ke previous screen" -ForegroundColor White
Write-Host "   [ ] Return true untuk indicate success" -ForegroundColor White
Write-Host ""

Write-Host "8️⃣  ERROR HANDLING" -ForegroundColor Cyan
Write-Host "   [ ] Test no internet connection" -ForegroundColor White
Write-Host "   [ ] Test Firebase token expired" -ForegroundColor White
Write-Host "   [ ] Test Azure upload failure" -ForegroundColor White
Write-Host "   [ ] Test Firestore permission denied" -ForegroundColor White
Write-Host "   [ ] Test Firestore network error" -ForegroundColor White
Write-Host "   [ ] Error snackbar muncul dengan message jelas" -ForegroundColor White
Write-Host ""

Write-Host "9️⃣  LOADING STATES" -ForegroundColor Cyan
Write-Host "   [ ] Loading indicator muncul saat upload" -ForegroundColor White
Write-Host "   [ ] Button disabled saat loading" -ForegroundColor White
Write-Host "   [ ] Form tidak bisa di-edit saat loading" -ForegroundColor White
Write-Host ""

Write-Host "🔟 VERIFY DATA" -ForegroundColor Cyan
Write-Host "   [ ] Check Firebase Console > Firestore" -ForegroundColor White
Write-Host "   [ ] Check collection 'products'" -ForegroundColor White
Write-Host "   [ ] Check document data lengkap" -ForegroundColor White
Write-Host "   [ ] Check Azure Storage container 'public'" -ForegroundColor White
Write-Host "   [ ] Check folder 'products/'" -ForegroundColor White
Write-Host "   [ ] Verify images accessible via URL" -ForegroundColor White
Write-Host ""

Write-Host "================================" -ForegroundColor Cyan
Write-Host "QUICK START COMMANDS" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Deploy Firestore Rules:" -ForegroundColor Yellow
Write-Host "   .\deploy_product_rules.ps1" -ForegroundColor White
Write-Host ""
Write-Host "2. Deploy Firestore Indexes:" -ForegroundColor Yellow
Write-Host "   .\deploy_product_indexes.ps1" -ForegroundColor White
Write-Host ""
Write-Host "3. Start PCVK API (for Azure Storage):" -ForegroundColor Yellow
Write-Host "   cd PCVK" -ForegroundColor White
Write-Host "   npm start" -ForegroundColor White
Write-Host ""
Write-Host "4. Run Flutter App:" -ForegroundColor Yellow
Write-Host "   flutter run" -ForegroundColor White
Write-Host ""

Write-Host "================================" -ForegroundColor Green
Write-Host "SAMPLE TEST DATA" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""
Write-Host "Nama Produk: Wortel Organik Fresh" -ForegroundColor White
Write-Host "Kategori: Sayuran Akar" -ForegroundColor White
Write-Host "Deskripsi: Wortel segar dari kebun organik, kaya vitamin A" -ForegroundColor White
Write-Host "Harga: 15000" -ForegroundColor White
Write-Host "Stok: 50" -ForegroundColor White
Write-Host "Berat: 500 (gram)" -ForegroundColor White
Write-Host "Foto: 3 gambar wortel" -ForegroundColor White
Write-Host ""

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

