#!/usr/bin/env pwsh

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  GET SHA-1 FINGERPRINT FOR FIREBASE" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Langkah-langkah untuk mendapatkan SHA-1 fingerprint:`n" -ForegroundColor Yellow

Write-Host "1. UNTUK DEBUG BUILD (Development):" -ForegroundColor Green
Write-Host "   Jalankan command ini di terminal:" -ForegroundColor White
Write-Host "   cd android" -ForegroundColor Cyan
Write-Host "   ./gradlew signingReport" -ForegroundColor Cyan
Write-Host ""

Write-Host "2. UNTUK RELEASE BUILD (Production):" -ForegroundColor Green
Write-Host "   Jalankan command yang sama, tapi lihat di bagian 'Release'" -ForegroundColor White
Write-Host ""

Write-Host "3. COPY SHA-1 dan SHA-256:" -ForegroundColor Green
Write-Host "   - Cari bagian 'Variant: debug' atau 'Variant: release'" -ForegroundColor White
Write-Host "   - Copy SHA-1 fingerprint" -ForegroundColor White
Write-Host "   - Copy SHA-256 fingerprint (optional tapi disarankan)" -ForegroundColor White
Write-Host ""

Write-Host "4. TAMBAHKAN KE FIREBASE CONSOLE:" -ForegroundColor Green
Write-Host "   - Buka Firebase Console (https://console.firebase.google.com)" -ForegroundColor White
Write-Host "   - Pilih project Anda" -ForegroundColor White
Write-Host "   - Masuk ke Project Settings > Your apps > Android app" -ForegroundColor White
Write-Host "   - Scroll ke bawah, klik 'Add fingerprint'" -ForegroundColor White
Write-Host "   - Paste SHA-1 dan SHA-256 yang sudah di-copy" -ForegroundColor White
Write-Host "   - Download google-services.json yang baru" -ForegroundColor White
Write-Host "   - Replace file di android/app/google-services.json" -ForegroundColor White
Write-Host ""

Write-Host "5. REBUILD APLIKASI:" -ForegroundColor Green
Write-Host "   flutter clean" -ForegroundColor Cyan
Write-Host "   flutter pub get" -ForegroundColor Cyan
Write-Host "   flutter run" -ForegroundColor Cyan
Write-Host ""

Write-Host "========================================`n" -ForegroundColor Cyan

$response = Read-Host "Apakah Anda ingin menjalankan 'gradlew signingReport' sekarang? (y/n)"

if ($response -eq "y" -or $response -eq "Y") {
    Write-Host "`nMenjalankan gradlew signingReport...`n" -ForegroundColor Yellow

    if (Test-Path "android/gradlew.bat") {
        Set-Location android
        if ($IsWindows -or $env:OS -like "*Windows*") {
            .\gradlew.bat signingReport
        } else {
            ./gradlew signingReport
        }
        Set-Location ..

        Write-Host "`n========================================" -ForegroundColor Cyan
        Write-Host "SELESAI!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "`nCopy SHA-1 dan SHA-256 dari output di atas," -ForegroundColor Yellow
        Write-Host "lalu tambahkan ke Firebase Console.`n" -ForegroundColor Yellow
    } else {
        Write-Host "Error: File android/gradlew.bat tidak ditemukan!" -ForegroundColor Red
        Write-Host "Pastikan Anda berada di root folder project Flutter.`n" -ForegroundColor Red
    }
} else {
    Write-Host "`nOK, Anda bisa menjalankan command manual:" -ForegroundColor Yellow
    Write-Host "cd android && ./gradlew signingReport`n" -ForegroundColor Cyan
}

Write-Host "CATATAN PENTING:" -ForegroundColor Red
Write-Host "- Setiap device (HP) yang berbeda memiliki SHA-1 yang berbeda" -ForegroundColor Yellow
Write-Host "- Jika teman Anda bisa login tapi Anda tidak, berarti SHA-1" -ForegroundColor Yellow
Write-Host "  fingerprint HP Anda belum terdaftar di Firebase Console" -ForegroundColor Yellow
Write-Host "- Tambahkan SHA-1 untuk semua device yang akan digunakan`n" -ForegroundColor Yellow

