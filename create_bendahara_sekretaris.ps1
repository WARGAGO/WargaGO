# Script untuk membuat akun Bendahara dan Sekretaris di Firebase
# Cara menggunakan: Run script ini di PowerShell

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "CREATE BENDAHARA & SEKRETARIS ACCOUNTS" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "📋 KREDENSIAL AKUN:" -ForegroundColor Yellow
Write-Host ""
Write-Host "🏦 BENDAHARA:" -ForegroundColor Green
Write-Host "   Email:    bendahara@bendahara.jawara.com" -ForegroundColor White
Write-Host "   Password: bendahara123" -ForegroundColor White
Write-Host "   Role:     bendahara" -ForegroundColor White
Write-Host ""
Write-Host "📝 SEKRETARIS:" -ForegroundColor Green
Write-Host "   Email:    sekretaris@sekretaris.jawara.com" -ForegroundColor White
Write-Host "   Password: sekretaris123" -ForegroundColor White
Write-Host "   Role:     sekretaris" -ForegroundColor White
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Fungsi untuk menampilkan instruksi Firestore
function Show-FirestoreInstructions {
    param(
        [string]$Role,
        [string]$Email,
        [string]$Nama,
        [string]$Nik,
        [string]$NoTelepon
    )

    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "CARA MEMBUAT DOCUMENT DI FIRESTORE - $Role" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Di Firebase Console, klik 'Firestore Database' di menu kiri" -ForegroundColor White
    Write-Host ""
    Write-Host "2. Cari atau buat collection bernama: " -NoNewline -ForegroundColor White
    Write-Host "users" -ForegroundColor Green
    Write-Host ""
    Write-Host "3. Klik tombol 'Add document' atau '+ Start collection'" -ForegroundColor White
    Write-Host ""
    Write-Host "4. Di field 'Document ID', PASTE UID yang sudah dicopy dari Authentication" -ForegroundColor Yellow
    Write-Host "   ⚠️  PENTING: Document ID HARUS SAMA dengan UID!" -ForegroundColor Red
    Write-Host ""
    Write-Host "5. Tambahkan field-field berikut (klik '+ Add field' untuk setiap field):" -ForegroundColor White
    Write-Host ""
    Write-Host "   ┌─────────────────────────────────────────────────────┐" -ForegroundColor Gray
    Write-Host "   │ Field Name     │ Type      │ Value                 │" -ForegroundColor Gray
    Write-Host "   ├─────────────────────────────────────────────────────┤" -ForegroundColor Gray
    Write-Host "   │ uid            │ string    │ " -NoNewline -ForegroundColor Gray
    Write-Host "[paste UID yang sama]" -ForegroundColor Yellow -NoNewline
    Write-Host " │" -ForegroundColor Gray
    Write-Host "   │ email          │ string    │ $Email" -ForegroundColor Gray
    Write-Host "   │ nama           │ string    │ $Nama" -ForegroundColor Gray
    Write-Host "   │ nik            │ string    │ $Nik" -ForegroundColor Gray
    Write-Host "   │ noTelepon      │ string    │ $NoTelepon" -ForegroundColor Gray
    Write-Host "   │ role           │ string    │ " -NoNewline -ForegroundColor Gray
    Write-Host "$Role" -ForegroundColor Green -NoNewline
    Write-Host "                      │" -ForegroundColor Gray
    Write-Host "   │ status         │ string    │ " -NoNewline -ForegroundColor Gray
    Write-Host "active" -ForegroundColor Green -NoNewline
    Write-Host "                    │" -ForegroundColor Gray
    Write-Host "   │ createdAt      │ timestamp │ [klik icon jam]           │" -ForegroundColor Gray
    Write-Host "   │ updatedAt      │ timestamp │ [klik icon jam]           │" -ForegroundColor Gray
    Write-Host "   └─────────────────────────────────────────────────────┘" -ForegroundColor Gray
    Write-Host ""
    Write-Host "6. Setelah semua field ditambahkan, klik tombol 'Save'" -ForegroundColor White
    Write-Host ""
}

Write-Host "⚠️  PANDUAN LENGKAP MEMBUAT AKUN:" -ForegroundColor Yellow
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "STEP 1: BUAT USER DI FIREBASE AUTHENTICATION" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Buka Firebase Console → Authentication → Users" -ForegroundColor White
Write-Host ""
Write-Host "2. Klik tombol 'Add User'" -ForegroundColor White
Write-Host ""
Write-Host "3. UNTUK BENDAHARA, masukkan:" -ForegroundColor Green
Write-Host "   Email:    bendahara@bendahara.jawara.com" -ForegroundColor White
Write-Host "   Password: bendahara123" -ForegroundColor White
Write-Host ""
Write-Host "4. Klik 'Add User'" -ForegroundColor White
Write-Host ""
Write-Host "5. ⚠️  COPY UID yang muncul (contoh: abc123xyz456)" -ForegroundColor Yellow
Write-Host "   UID ini akan digunakan sebagai Document ID di Firestore!" -ForegroundColor Red
Write-Host ""
Write-Host "6. Ulangi langkah 2-5 untuk SEKRETARIS:" -ForegroundColor Green
Write-Host "   Email:    sekretaris@sekretaris.jawara.com" -ForegroundColor White
Write-Host "   Password: sekretaris123" -ForegroundColor White
Write-Host ""

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "STEP 2: BUAT DOCUMENT DI FIRESTORE" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

# Tampilkan instruksi untuk Bendahara
Show-FirestoreInstructions -Role "bendahara" `
    -Email "bendahara@bendahara.jawara.com" `
    -Nama "Bendahara Jawara" `
    -Nik "1234567890123456" `
    -NoTelepon "081234567890"

Write-Host "Press any key to see SEKRETARIS instructions..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Tampilkan instruksi untuk Sekretaris
Show-FirestoreInstructions -Role "sekretaris" `
    -Email "sekretaris@sekretaris.jawara.com" `
    -Nama "Sekretaris Jawara" `
    -Nik "6543210987654321" `
    -NoTelepon "081234567891"

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "TIPS PENTING" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ Document ID di Firestore HARUS SAMA dengan UID dari Authentication" -ForegroundColor Green
Write-Host "✅ Field 'role' harus lowercase: 'bendahara' atau 'sekretaris'" -ForegroundColor Green
Write-Host "✅ Field 'status' harus 'active' agar bisa login" -ForegroundColor Green
Write-Host "✅ Untuk timestamp, klik icon jam/clock di sebelah field" -ForegroundColor Green
Write-Host ""
Write-Host "❌ JANGAN gunakan email selain domain yang sudah ditentukan" -ForegroundColor Red
Write-Host "❌ JANGAN lupa copy UID dari Authentication" -ForegroundColor Red
Write-Host "❌ JANGAN sampai Document ID berbeda dengan UID" -ForegroundColor Red
Write-Host ""

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "STEP 3: TEST LOGIN" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "Setelah membuat akun di Firebase, test login dengan:" -ForegroundColor White
Write-Host ""
Write-Host "BENDAHARA:" -ForegroundColor Green
Write-Host "• Buka aplikasi → Login" -ForegroundColor White
Write-Host "• Email: bendahara@bendahara.jawara.com" -ForegroundColor White
Write-Host "• Password: bendahara123" -ForegroundColor White
Write-Host "• ✅ Harusnya redirect ke Dashboard Bendahara" -ForegroundColor Green
Write-Host ""
Write-Host "SEKRETARIS:" -ForegroundColor Green
Write-Host "• Email: sekretaris@sekretaris.jawara.com" -ForegroundColor White
Write-Host "• Password: sekretaris123" -ForegroundColor White
Write-Host "• ✅ Harusnya redirect ke Dashboard Sekretaris" -ForegroundColor Green
Write-Host ""

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "📚 Untuk informasi lebih detail, baca file:" -ForegroundColor Yellow
Write-Host "   • TROUBLESHOOTING_LOGIN.md - Panduan troubleshooting" -ForegroundColor White
Write-Host "   • DIAGRAM_PEMBUATAN_AKUN.md - Diagram visual" -ForegroundColor White
Write-Host "   • AUTH_BENDAHARA_SEKRETARIS.md - Dokumentasi lengkap" -ForegroundColor White
Write-Host "   • CREDENTIALS.txt - Quick reference" -ForegroundColor White
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Tanya apakah user ingin membuka Firebase Console
$response = Read-Host "Apakah Anda ingin membuka Firebase Console sekarang? (Y/N)"
if ($response -eq "Y" -or $response -eq "y") {
    Write-Host ""
    Write-Host "🌐 Membuka Firebase Console..." -ForegroundColor Green
    Write-Host ""
    Write-Host "Setelah Firebase Console terbuka:" -ForegroundColor Yellow
    Write-Host "1. Klik 'Authentication' untuk membuat user" -ForegroundColor White
    Write-Host "2. Copy UID yang dibuat" -ForegroundColor White
    Write-Host "3. Klik 'Firestore Database' untuk membuat document" -ForegroundColor White
    Write-Host "4. Ikuti instruksi di atas" -ForegroundColor White
    Write-Host ""
    Start-Process "https://console.firebase.google.com"
} else {
    Write-Host ""
    Write-Host "✅ Silakan buka Firebase Console secara manual" -ForegroundColor Green
    Write-Host "   https://console.firebase.google.com" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

