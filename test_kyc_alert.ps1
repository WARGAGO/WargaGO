#!/usr/bin/env pwsh
# Test KYC Alert & Menu Restriction
# File: test_kyc_alert.ps1

Write-Host "🎯 Testing KYC Alert & Menu Restriction..." -ForegroundColor Cyan
Write-Host ""

Write-Host "📋 Test Scenarios:" -ForegroundColor Yellow
Write-Host "  1. New User (No KYC) - Should see alert" -ForegroundColor White
Write-Host "  2. Pending Verification - Should see pending alert" -ForegroundColor White
Write-Host "  3. KYC Verified - No alert, all features enabled" -ForegroundColor White
Write-Host "  4. Scan button restriction" -ForegroundColor White
Write-Host ""

Write-Host "✅ Implementation Checklist:" -ForegroundColor Green
Write-Host "  [✓] KYC Alert Banner" -ForegroundColor Green
Write-Host "  [✓] Real-time status updates" -ForegroundColor Green
Write-Host "  [✓] Menu restrictions" -ForegroundColor Green
Write-Host "  [✓] KYC Required Dialog" -ForegroundColor Green
Write-Host "  [✓] Scan button lock indicator" -ForegroundColor Green
Write-Host "  [✓] 5 Navigation menus" -ForegroundColor Green
Write-Host ""

Write-Host "📱 Navigation Menus:" -ForegroundColor Yellow
Write-Host "  ✅ Home (Always accessible)" -ForegroundColor Green
Write-Host "  ✅ Pengumuman (Always accessible)" -ForegroundColor Green
Write-Host "  🔒 Scan (Requires KYC)" -ForegroundColor Red
Write-Host "  ✅ Pengaduan (Always accessible)" -ForegroundColor Green
Write-Host "  ✅ Akun (Always accessible)" -ForegroundColor Green
Write-Host ""

$continue = Read-Host "Lanjut run app untuk test? (Y/n)"
if ($continue -eq "n" -or $continue -eq "N") {
    Write-Host "❌ Test dibatalkan" -ForegroundColor Red
    exit
}

Write-Host ""
Write-Host "🧹 Cleaning project..." -ForegroundColor Yellow
flutter clean

Write-Host ""
Write-Host "📦 Getting dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host ""
Write-Host "🚀 Running app..." -ForegroundColor Yellow
Write-Host "⚠️  Pastikan sudah login sebagai warga!" -ForegroundColor Yellow
Write-Host ""

flutter run

Write-Host ""
Write-Host "✅ Testing Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Manual Test Checklist:" -ForegroundColor Cyan
Write-Host "  [ ] Login sebagai warga tanpa KYC" -ForegroundColor White
Write-Host "  [ ] Lihat alert banner muncul" -ForegroundColor White
Write-Host "  [ ] Klik tombol 'Upload' di alert" -ForegroundColor White
Write-Host "  [ ] Verifikasi redirect ke KYC wizard" -ForegroundColor White
Write-Host "  [ ] Klik scan button → Dialog muncul" -ForegroundColor White
Write-Host "  [ ] Test navigasi ke Pengumuman, Pengaduan, Akun" -ForegroundColor White
Write-Host "  [ ] Upload KYC → Verifikasi alert berubah" -ForegroundColor White
Write-Host "  [ ] Admin approve KYC → Alert hilang" -ForegroundColor White
Write-Host "  [ ] Scan button aktif setelah verified" -ForegroundColor White
Write-Host ""

