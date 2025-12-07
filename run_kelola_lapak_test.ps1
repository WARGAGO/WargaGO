# ============================================================================
# RUN & TEST KELOLA LAPAK
# ============================================================================
# Script untuk menjalankan dan testing fitur Kelola Lapak
# ============================================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RUN & TEST KELOLA LAPAK" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check Flutter
Write-Host "[1/3] Checking Flutter..." -ForegroundColor Yellow
if (!(Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Flutter tidak ditemukan!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Flutter OK" -ForegroundColor Green
Write-Host ""

# Clean & Get Dependencies
Write-Host "[2/3] Getting dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to get dependencies" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Dependencies OK" -ForegroundColor Green
Write-Host ""

# Run app
Write-Host "[3/3] Running app..." -ForegroundColor Yellow
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TESTING INSTRUCTIONS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "📱 TEST 1: WARGA - DAFTAR SELLER" -ForegroundColor Green
Write-Host "1. Login sebagai warga" -ForegroundColor White
Write-Host "2. Tap 'Profile' di bottom nav" -ForegroundColor White
Write-Host "3. Scroll ke bawah" -ForegroundColor White
Write-Host "4. Tap 'Daftar Sebagai Penjual'" -ForegroundColor White
Write-Host "5. Isi form lengkap:" -ForegroundColor White
Write-Host "   - Nama, NIK, No. Telp (auto-fill)" -ForegroundColor Gray
Write-Host "   - Nama Toko (contoh: Toko Sejahtera)" -ForegroundColor Gray
Write-Host "   - Alamat Toko" -ForegroundColor Gray
Write-Host "   - RT/RW" -ForegroundColor Gray
Write-Host "   - Deskripsi Usaha" -ForegroundColor Gray
Write-Host "   - Pilih kategori produk" -ForegroundColor Gray
Write-Host "   - Upload Foto KTP" -ForegroundColor Gray
Write-Host "   - Upload Selfie dengan KTP" -ForegroundColor Gray
Write-Host "   - (Opsional) Upload Foto Toko" -ForegroundColor Gray
Write-Host "6. Tap 'Kirim Pendaftaran'" -ForegroundColor White
Write-Host "7. ✅ Verifikasi success dialog muncul" -ForegroundColor Green
Write-Host ""

Write-Host "👨‍💼 TEST 2: ADMIN - VERIFIKASI SELLER" -ForegroundColor Green
Write-Host "1. Logout dari warga" -ForegroundColor White
Write-Host "2. Login sebagai admin" -ForegroundColor White
Write-Host "3. Tap 'Dashboard' atau menu admin" -ForegroundColor White
Write-Host "4. Tap 'Kelola Lapak'" -ForegroundColor White
Write-Host "5. Lihat statistik di atas" -ForegroundColor White
Write-Host "6. Tab 'Pending' - lihat seller tadi" -ForegroundColor White
Write-Host "7. Tap card seller" -ForegroundColor White
Write-Host "8. Review semua data & dokumen" -ForegroundColor White
Write-Host "9. Centang checklist verifikasi" -ForegroundColor White
Write-Host "10. Tap 'Setujui' (atau 'Tolak')" -ForegroundColor White
Write-Host "11. Isi catatan/alasan" -ForegroundColor White
Write-Host "12. Konfirmasi" -ForegroundColor White
Write-Host "13. ✅ Verifikasi success & kembali ke list" -ForegroundColor Green
Write-Host ""

Write-Host "🔍 TEST 3: VERIFIKASI DATABASE" -ForegroundColor Green
Write-Host "1. Buka Firebase Console" -ForegroundColor White
Write-Host "2. Pilih project" -ForegroundColor White
Write-Host "3. Firestore Database" -ForegroundColor White
Write-Host "4. Check collection 'pending_sellers'" -ForegroundColor White
Write-Host "   ✅ Verifikasi status berubah" -ForegroundColor Green
Write-Host "5. Check collection 'approved_sellers'" -ForegroundColor White
Write-Host "   ✅ Verifikasi data seller ada (jika approve)" -ForegroundColor Green
Write-Host "6. Check collection 'users'" -ForegroundColor White
Write-Host "   ✅ Verifikasi role 'seller' ditambahkan" -ForegroundColor Green
Write-Host "   ✅ Verifikasi isSeller = true" -ForegroundColor Green
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starting Flutter app..." -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

flutter run

