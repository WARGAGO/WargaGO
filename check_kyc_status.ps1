# Script untuk check KYC status di Firestore
# Usage: .\check_kyc_status.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🔍 KYC STATUS CHECKER" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Instruksi untuk debug KYC alert:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Buka Firebase Console:" -ForegroundColor White
Write-Host "   https://console.firebase.google.com/" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Pilih project Anda" -ForegroundColor White
Write-Host ""
Write-Host "3. Buka Firestore Database" -ForegroundColor White
Write-Host ""
Write-Host "4. Check collection 'kyc_documents':" -ForegroundColor White
Write-Host "   - Filter by userId = [ID user yang bermasalah]" -ForegroundColor Gray
Write-Host "   - Check field 'documentType' (harus ada 'ktp' dan 'kk')" -ForegroundColor Gray
Write-Host "   - Check field 'status' untuk setiap dokumen" -ForegroundColor Gray
Write-Host ""
Write-Host "5. Check collection 'users':" -ForegroundColor White
Write-Host "   - Cari user yang bermasalah" -ForegroundColor Gray
Write-Host "   - Check field 'status'" -ForegroundColor Gray
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Expected Status for APPROVED KYC:" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ kyc_documents (KTP):" -ForegroundColor Green
Write-Host "   - documentType: 'ktp'" -ForegroundColor Gray
Write-Host "   - status: 'approved'" -ForegroundColor Gray
Write-Host "   - verifiedBy: [admin_id]" -ForegroundColor Gray
Write-Host "   - verifiedAt: [timestamp]" -ForegroundColor Gray
Write-Host ""
Write-Host "✅ kyc_documents (KK):" -ForegroundColor Green
Write-Host "   - documentType: 'kk'" -ForegroundColor Gray
Write-Host "   - status: 'approved'" -ForegroundColor Gray
Write-Host "   - verifiedBy: [admin_id]" -ForegroundColor Gray
Write-Host "   - verifiedAt: [timestamp]" -ForegroundColor Gray
Write-Host ""
Write-Host "✅ users:" -ForegroundColor Green
Write-Host "   - status: 'approved'" -ForegroundColor Gray
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Possible Issues:" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "❌ Issue 1: Salah satu dokumen masih 'pending'" -ForegroundColor Red
Write-Host "   Solution: Admin harus approve KEDUA dokumen (KTP dan KK)" -ForegroundColor Yellow
Write-Host ""
Write-Host "❌ Issue 2: Status di database tidak ter-update" -ForegroundColor Red
Write-Host "   Solution: Check approveDocument function di kyc_service.dart" -ForegroundColor Yellow
Write-Host ""
Write-Host "❌ Issue 3: Typo di field 'status'" -ForegroundColor Red
Write-Host "   Solution: Pastikan statusnya 'approved' (lowercase, tidak ada spasi)" -ForegroundColor Yellow
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Quick Fix:" -ForegroundColor Yellow
Write-Host "Jika admin sudah approve tapi alert masih muncul:" -ForegroundColor White
Write-Host "1. Pull to refresh dashboard" -ForegroundColor Gray
Write-Host "2. Logout dan login kembali" -ForegroundColor Gray
Write-Host "3. Check console log untuk debug info" -ForegroundColor Gray
Write-Host ""

