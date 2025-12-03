# ============================================================================
# TEST MARKETPLACE AZURE BLOB STORAGE
# ============================================================================
# Script untuk test upload gambar produk ke Azure Blob Storage
# ============================================================================

Write-Host ""
Write-Host "🧪 ========== TEST MARKETPLACE AZURE BLOB STORAGE ==========" -ForegroundColor Cyan
Write-Host ""

Write-Host "📋 Prerequisites:" -ForegroundColor Yellow
Write-Host "   1. User test sudah terdaftar di Firebase Auth" -ForegroundColor White
Write-Host "   2. Azure Blob Storage backend sudah running" -ForegroundColor White
Write-Host "   3. File test image sudah disiapkan" -ForegroundColor White
Write-Host ""

Write-Host "🔧 Edit file test_marketplace_azure_storage.dart:" -ForegroundColor Yellow
Write-Host "   - Ganti email & password test user" -ForegroundColor White
Write-Host "   - Ganti testImagePath dengan path gambar test yang valid" -ForegroundColor White
Write-Host ""

$continue = Read-Host "Lanjutkan test? (y/n)"

if ($continue -ne "y" -and $continue -ne "Y") {
    Write-Host "❌ Test dibatalkan" -ForegroundColor Red
    exit 0
}

Write-Host ""
Write-Host "🚀 Running test..." -ForegroundColor Cyan
Write-Host ""

# Run test
flutter run -d windows lib/test_marketplace_azure_storage.dart

Write-Host ""
Write-Host "✅ Test selesai!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Check hasil test di atas:" -ForegroundColor Yellow
Write-Host "   ✅ Upload to Azure: SUCCESS" -ForegroundColor White
Write-Host "   ✅ Image URLs contain 'blob.core.windows.net' atau 'azurewebsites.net'" -ForegroundColor White
Write-Host "   ✅ Delete from Azure: SUCCESS" -ForegroundColor White
Write-Host ""

