# Script untuk membuka Firebase Console dan membuat Firestore Indexes
# Tanggal: 29 November 2025

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  FIRESTORE INDEX CREATOR" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "📋 Indexes yang perlu dibuat untuk Kelola Pengguna:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  1. users - role + createdAt (Descending)" -ForegroundColor White
Write-Host "  2. users - status + createdAt (Descending)" -ForegroundColor White
Write-Host "  3. users - status (whereIn) + createdAt (Descending)" -ForegroundColor White
Write-Host ""

Write-Host "🔧 Pilih aksi:" -ForegroundColor Green
Write-Host "  [1] Buka SEMUA link auto-create (RECOMMENDED!)" -ForegroundColor Yellow
Write-Host "  [2] Buka link Index 1 - role + createdAt" -ForegroundColor White
Write-Host "  [3] Buka link Index 2 - status (whereIn) + createdAt" -ForegroundColor White
Write-Host "  [4] Buka Firebase Console untuk index manual" -ForegroundColor White
Write-Host "  [5] Buka dokumentasi lengkap" -ForegroundColor White
Write-Host "  [6] Exit" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Pilih opsi (1-6)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "✅ Membuka SEMUA link auto-create..." -ForegroundColor Green
        Write-Host ""

        Write-Host "📝 Index 1: role + createdAt" -ForegroundColor Cyan
        $url1 = "https://console.firebase.google.com/v1/r/project/pbl-2025-35a1c/firestore/indexes?create_composite=Ckxwcm9qZWN0cy9wYmwtMjAyNS0zNWExYy9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvdXNlcnMvaW5kZXhlcy9fEAEaCAoEcm9sZRABGg0KCWNyZWF0ZWRBdBACGgwKCF9fbmFtZV9fEAI"
        Start-Process $url1

        Write-Host "⏳ Tunggu 2 detik..." -ForegroundColor Yellow
        Start-Sleep -Seconds 2

        Write-Host "📝 Index 2: status (whereIn) + createdAt" -ForegroundColor Cyan
        $url2 = "https://console.firebase.google.com/v1/r/project/pbl-2025-35a1c/firestore/indexes?create_composite=Ckxwcm9qZWN0cy9wYmwtMjAyNS0zNWExYy9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvdXNlcnMvaW5kZXhlcy9fEAEaCgoGc3RhdHVzEAEaDQoJY3JlYXRlZEF0EAIaDAoIX19uYW1lX18QAg"
        Start-Process $url2

        Write-Host ""
        Write-Host "✅ 2 tab browser telah dibuka!" -ForegroundColor Green
        Write-Host ""
        Write-Host "📌 Langkah selanjutnya:" -ForegroundColor Cyan
        Write-Host "   1. Di masing-masing tab, klik 'Create Index'" -ForegroundColor White
        Write-Host "   2. Buat Index 3 secara manual (lihat dokumentasi)" -ForegroundColor White
        Write-Host "   3. Tunggu semua index status = 'Enabled'" -ForegroundColor White
        Write-Host "   4. Restart aplikasi Flutter" -ForegroundColor White
        Write-Host ""
    }
    "2" {
        Write-Host ""
        Write-Host "✅ Membuka link auto-create untuk Index 1..." -ForegroundColor Green
        Write-Host ""
        Write-Host "📝 Detail Index 1:" -ForegroundColor Cyan
        Write-Host "   Collection: users" -ForegroundColor White
        Write-Host "   Field 1: role (Ascending)" -ForegroundColor White
        Write-Host "   Field 2: createdAt (Descending)" -ForegroundColor White
        Write-Host ""

        $url = "https://console.firebase.google.com/v1/r/project/pbl-2025-35a1c/firestore/indexes?create_composite=Ckxwcm9qZWN0cy9wYmwtMjAyNS0zNWExYy9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvdXNlcnMvaW5kZXhlcy9fEAEaCAoEcm9sZRABGg0KCWNyZWF0ZWRBdBACGgwKCF9fbmFtZV9fEAI"
        Start-Process $url

        Write-Host "⏳ Tunggu halaman terbuka di browser..." -ForegroundColor Yellow
        Write-Host ""
    }
    "3" {
        Write-Host ""
        Write-Host "✅ Membuka link auto-create untuk Index 2..." -ForegroundColor Green
        Write-Host ""
        Write-Host "📝 Detail Index 2:" -ForegroundColor Cyan
        Write-Host "   Collection: users" -ForegroundColor White
        Write-Host "   Field 1: status (whereIn - untuk pending query)" -ForegroundColor White
        Write-Host "   Field 2: createdAt (Descending)" -ForegroundColor White
        Write-Host ""

        $url = "https://console.firebase.google.com/v1/r/project/pbl-2025-35a1c/firestore/indexes?create_composite=Ckxwcm9qZWN0cy9wYmwtMjAyNS0zNWExYy9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvdXNlcnMvaW5kZXhlcy9fEAEaCgoGc3RhdHVzEAEaDQoJY3JlYXRlZEF0EAIaDAoIX19uYW1lX18QAg"
        Start-Process $url

        Write-Host "⏳ Tunggu halaman terbuka di browser..." -ForegroundColor Yellow
        Write-Host ""
    }
    "4" {
        Write-Host ""
        Write-Host "✅ Membuka Firebase Console - Firestore Indexes..." -ForegroundColor Green
        Write-Host ""

        $url = "https://console.firebase.google.com/project/pbl-2025-35a1c/firestore/indexes"
        Start-Process $url

        Write-Host "📝 Cara membuat index manual:" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Index 3: status + createdAt (MANUAL)" -ForegroundColor Yellow
        Write-Host "  - Klik 'Create Index'" -ForegroundColor White
        Write-Host "  - Collection ID: users" -ForegroundColor White
        Write-Host "  - Field 1: status (Ascending)" -ForegroundColor White
        Write-Host "  - Field 2: createdAt (Descending)" -ForegroundColor White
        Write-Host "  - Query scope: Collection" -ForegroundColor White
        Write-Host "  - Klik 'Create'" -ForegroundColor White
        Write-Host ""
    }
    "5" {
        Write-Host ""
        Write-Host "✅ Membuka dokumentasi lengkap..." -ForegroundColor Green
        Write-Host ""

        $docPath = "FIRESTORE_INDEXES_REQUIRED.md"
        if (Test-Path $docPath) {
            code $docPath
            Write-Host "📖 Dokumentasi dibuka di editor" -ForegroundColor Green
        } else {
            Write-Host "❌ File dokumentasi tidak ditemukan: $docPath" -ForegroundColor Red
            Write-Host "   Pastikan file ada di: $(Get-Location)\$docPath" -ForegroundColor Yellow
        }
        Write-Host ""
    }
    "6" {
        Write-Host ""
        Write-Host "👋 Keluar dari script. Jangan lupa buat indexes ya!" -ForegroundColor Yellow
        Write-Host ""
        exit
    }
    default {
        Write-Host ""
        Write-Host "❌ Pilihan tidak valid!" -ForegroundColor Red
        Write-Host ""
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CHECKLIST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "[ ] Index 1: users - role + createdAt (Auto-create)" -ForegroundColor White
Write-Host "[ ] Index 2: users - status (whereIn) + createdAt (Auto-create)" -ForegroundColor White
Write-Host "[ ] Index 3: users - status + createdAt (Manual)" -ForegroundColor White
Write-Host "[ ] Verify semua index status = 'Enabled'" -ForegroundColor White
Write-Host "[ ] Restart aplikasi Flutter" -ForegroundColor White
Write-Host "[ ] Test Kelola Pengguna (filter role & status)" -ForegroundColor White
Write-Host ""

Write-Host "💡 Tips:" -ForegroundColor Green
Write-Host "   - Pilih opsi 1 untuk buka semua link sekaligus!" -ForegroundColor Yellow
Write-Host "   - Index building time: 2-5 menit per index" -ForegroundColor White
Write-Host "   - Refresh Firebase Console untuk cek status" -ForegroundColor White
Write-Host "   - Jika masih error, restart aplikasi" -ForegroundColor White
Write-Host ""

Write-Host "📄 Dokumentasi lengkap: FIRESTORE_INDEXES_REQUIRED.md" -ForegroundColor Cyan
Write-Host "📄 Fix summary: FIX_KELOLA_PENGGUNA_TIMESTAMP.md" -ForegroundColor Cyan
Write-Host ""

Read-Host "Tekan Enter untuk keluar"

