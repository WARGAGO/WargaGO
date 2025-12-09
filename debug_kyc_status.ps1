# 🔍 DEBUG SCRIPT - Check KYC Status in Firestore

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🔍 KYC STATUS DEBUGGER" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Prompt for user email
$userEmail = Read-Host "Enter user email untuk debug"

Write-Host ""
Write-Host "📋 CHECKLIST MANUAL (Firebase Console):" -ForegroundColor Yellow
Write-Host ""

Write-Host "1. Buka Firebase Console" -ForegroundColor White
Write-Host "   https://console.firebase.google.com/" -ForegroundColor Gray
Write-Host ""

Write-Host "2. Pilih Collection: 'users'" -ForegroundColor White
Write-Host "   - Cari user dengan email: $userEmail" -ForegroundColor Gray
Write-Host "   - Copy 'id' (Document ID) user tersebut" -ForegroundColor Gray
Write-Host ""

$userId = Read-Host "Paste User ID di sini"

Write-Host ""
Write-Host "3. Pilih Collection: 'kyc_documents'" -ForegroundColor White
Write-Host "   - Klik 'Filter' atau 'Query'" -ForegroundColor Gray
Write-Host "   - Field: 'userId'" -ForegroundColor Gray
Write-Host "   - Operator: '=='" -ForegroundColor Gray
Write-Host "   - Value: '$userId'" -ForegroundColor Gray
Write-Host ""

Write-Host "4. Check SEMUA dokumen yang muncul:" -ForegroundColor White
Write-Host ""

# KTP Check
Write-Host "   📄 Dokumen KTP:" -ForegroundColor Cyan
Write-Host "      ┌─────────────────────────────────────┐" -ForegroundColor Gray
Write-Host "      │ Field             │ Expected Value  │" -ForegroundColor Gray
Write-Host "      ├─────────────────────────────────────┤" -ForegroundColor Gray
Write-Host "      │ documentType      │ 'ktp'           │" -ForegroundColor Gray
Write-Host "      │ status            │ 'approved'      │" -ForegroundColor Green
Write-Host "      │ verifiedBy        │ [admin_id]      │" -ForegroundColor Gray
Write-Host "      │ verifiedAt        │ [timestamp]     │" -ForegroundColor Gray
Write-Host "      └─────────────────────────────────────┘" -ForegroundColor Gray
Write-Host ""

$ktpExists = Read-Host "   Apakah dokumen KTP ada? (y/n)"
if ($ktpExists -eq 'y') {
    $ktpStatus = Read-Host "   Status KTP"
    if ($ktpStatus -ne 'approved') {
        Write-Host "   ❌ MASALAH: KTP status bukan 'approved', melainkan '$ktpStatus'" -ForegroundColor Red
    } else {
        Write-Host "   ✅ KTP status correct: approved" -ForegroundColor Green
    }
} else {
    Write-Host "   ❌ MASALAH: Dokumen KTP TIDAK ADA!" -ForegroundColor Red
}

Write-Host ""

# KK Check
Write-Host "   📄 Dokumen KK:" -ForegroundColor Cyan
Write-Host "      ┌─────────────────────────────────────┐" -ForegroundColor Gray
Write-Host "      │ Field             │ Expected Value  │" -ForegroundColor Gray
Write-Host "      ├─────────────────────────────────────┤" -ForegroundColor Gray
Write-Host "      │ documentType      │ 'kk'            │" -ForegroundColor Gray
Write-Host "      │ status            │ 'approved'      │" -ForegroundColor Green
Write-Host "      │ verifiedBy        │ [admin_id]      │" -ForegroundColor Gray
Write-Host "      │ verifiedAt        │ [timestamp]     │" -ForegroundColor Gray
Write-Host "      └─────────────────────────────────────┘" -ForegroundColor Gray
Write-Host ""

$kkExists = Read-Host "   Apakah dokumen KK ada? (y/n)"
if ($kkExists -eq 'y') {
    $kkStatus = Read-Host "   Status KK"
    if ($kkStatus -ne 'approved') {
        Write-Host "   ❌ MASALAH: KK status bukan 'approved', melainkan '$kkStatus'" -ForegroundColor Red
    } else {
        Write-Host "   ✅ KK status correct: approved" -ForegroundColor Green
    }
} else {
    Write-Host "   ❌ MASALAH: Dokumen KK TIDAK ADA!" -ForegroundColor Red
}

Write-Host ""
Write-Host "5. Check Collection: 'users'" -ForegroundColor White
Write-Host "   - Document ID: $userId" -ForegroundColor Gray

$userStatus = Read-Host "   User status"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "📊 DIAGNOSIS RESULT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$allGood = $true

Write-Host "Dokumen yang ditemukan:" -ForegroundColor White
Write-Host "  KTP: $ktpExists" -ForegroundColor $(if ($ktpExists -eq 'y') { 'Green' } else { 'Red' })
Write-Host "  KK: $kkExists" -ForegroundColor $(if ($kkExists -eq 'y') { 'Green' } else { 'Red' })
Write-Host ""

if ($ktpExists -eq 'y' -and $kkExists -eq 'y') {
    Write-Host "Status Dokumen:" -ForegroundColor White
    Write-Host "  KTP: $ktpStatus" -ForegroundColor $(if ($ktpStatus -eq 'approved') { 'Green' } else { 'Red' })
    Write-Host "  KK: $kkStatus" -ForegroundColor $(if ($kkStatus -eq 'approved') { 'Green' } else { 'Red' })
    Write-Host ""

    if ($ktpStatus -eq 'approved' -and $kkStatus -eq 'approved') {
        Write-Host "✅ KEDUA DOKUMEN APPROVED!" -ForegroundColor Green
        Write-Host ""

        if ($userStatus -eq 'approved') {
            Write-Host "✅ User status juga 'approved'" -ForegroundColor Green
            Write-Host ""
            Write-Host "🎯 KESIMPULAN: Semua data BENAR!" -ForegroundColor Green
            Write-Host "   Alert seharusnya TIDAK muncul." -ForegroundColor Green
            Write-Host ""
            Write-Host "⚠️ JIKA ALERT MASIH MUNCUL:" -ForegroundColor Yellow
            Write-Host "   1. User perlu LOGOUT dan LOGIN kembali" -ForegroundColor White
            Write-Host "   2. Pull-to-refresh di dashboard" -ForegroundColor White
            Write-Host "   3. Clear cache browser (Ctrl+Shift+Del)" -ForegroundColor White
            Write-Host "   4. Check console log browser (F12)" -ForegroundColor White
        } else {
            Write-Host "❌ User status: '$userStatus' (bukan 'approved')" -ForegroundColor Red
            Write-Host ""
            Write-Host "🔧 SOLUSI: Update user status secara manual" -ForegroundColor Yellow
            Write-Host "   1. Buka Firestore → users → $userId" -ForegroundColor White
            Write-Host "   2. Edit field 'status' → ubah ke 'approved'" -ForegroundColor White
            Write-Host "   3. Save" -ForegroundColor White
        }
    } else {
        Write-Host "❌ Salah satu atau kedua dokumen BELUM approved!" -ForegroundColor Red
        Write-Host ""
        Write-Host "🔧 SOLUSI:" -ForegroundColor Yellow
        if ($ktpStatus -ne 'approved') {
            Write-Host "   - Admin harus approve dokumen KTP" -ForegroundColor White
        }
        if ($kkStatus -ne 'approved') {
            Write-Host "   - Admin harus approve dokumen KK" -ForegroundColor White
        }
    }
} else {
    Write-Host "❌ Tidak ada dokumen KTP atau KK!" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 SOLUSI:" -ForegroundColor Yellow
    Write-Host "   - User harus upload dokumen yang kurang" -ForegroundColor White
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "💡 NEXT STEPS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Login sebagai user warga di aplikasi" -ForegroundColor White
Write-Host "2. Buka browser console (F12)" -ForegroundColor White
Write-Host "3. Refresh dashboard" -ForegroundColor White
Write-Host "4. Lihat output log yang dimulai dengan:" -ForegroundColor White
Write-Host "   '🔍 ========== KYC STATUS CHECK ==========' " -ForegroundColor Gray
Write-Host ""
Write-Host "5. Screenshot log tersebut dan kirim ke developer" -ForegroundColor White
Write-Host ""

