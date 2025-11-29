# FIX LOGIN ADMIN ISSUE

## Script PowerShell untuk fix masalah login admin

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🔧 FIX LOGIN ADMIN ISSUE" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Masalah: Admin tidak bisa login setelah edit nama`n" -ForegroundColor Yellow

Write-Host "Solusi yang akan dilakukan:" -ForegroundColor Green
Write-Host "1. Flutter clean (clear cache)" -ForegroundColor White
Write-Host "2. Clear build cache" -ForegroundColor White
Write-Host "3. Rebuild aplikasi`n" -ForegroundColor White

Write-Host "Memulai proses...`n" -ForegroundColor Cyan

# Step 1: Flutter Clean
Write-Host "[1/3] Running flutter clean..." -ForegroundColor Yellow
flutter clean
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Flutter clean berhasil`n" -ForegroundColor Green
} else {
    Write-Host "❌ Flutter clean gagal`n" -ForegroundColor Red
    exit 1
}

# Step 2: Get Dependencies
Write-Host "[2/3] Getting dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Dependencies berhasil diambil`n" -ForegroundColor Green
} else {
    Write-Host "❌ Gagal mengambil dependencies`n" -ForegroundColor Red
    exit 1
}

# Step 3: Info
Write-Host "[3/3] Ready to run`n" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ PROSES SELESAI!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "LANGKAH SELANJUTNYA:" -ForegroundColor Cyan
Write-Host "1. Jalankan aplikasi dengan: flutter run" -ForegroundColor White
Write-Host "2. Jika diminta login, gunakan kredensial:" -ForegroundColor White
Write-Host "   📧 Email: admin2@jawara.com" -ForegroundColor Yellow
Write-Host "   🔑 Password: admin123" -ForegroundColor Yellow
Write-Host "`n3. Jika masih gagal, coba:" -ForegroundColor White
Write-Host "   - Uninstall app dari device/emulator" -ForegroundColor White
Write-Host "   - Install ulang dengan: flutter run`n" -ForegroundColor White

Write-Host "========================================`n" -ForegroundColor Cyan

