# QUICK ACTION - Buka Semua Link Firestore Index
# Jalankan script ini untuk membuka semua link sekaligus

Write-Host ""
Write-Host "🚀 OPENING ALL FIRESTORE INDEX LINKS..." -ForegroundColor Green
Write-Host ""

# Link 1: role + createdAt
Write-Host "✅ Opening Index 1: role + createdAt" -ForegroundColor Cyan
$url1 = "https://console.firebase.google.com/v1/r/project/pbl-2025-35a1c/firestore/indexes?create_composite=Ckxwcm9qZWN0cy9wYmwtMjAyNS0zNWExYy9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvdXNlcnMvaW5kZXhlcy9fEAEaCAoEcm9sZRABGg0KCWNyZWF0ZWRBdBACGgwKCF9fbmFtZV9fEAI"
Start-Process $url1

Start-Sleep -Seconds 2

# Link 2: status (whereIn) + createdAt
Write-Host "✅ Opening Index 2: status (whereIn) + createdAt" -ForegroundColor Cyan
$url2 = "https://console.firebase.google.com/v1/r/project/pbl-2025-35a1c/firestore/indexes?create_composite=Ckxwcm9qZWN0cy9wYmwtMjAyNS0zNWExYy9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvdXNlcnMvaW5kZXhlcy9fEAEaCgoGc3RhdHVzEAEaDQoJY3JlYXRlZEF0EAIaDAoIX19uYW1lX18QAg"
Start-Process $url2

Write-Host ""
Write-Host "✅ 2 browser tabs opened!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 NEXT STEPS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Di Tab 1 (role + createdAt):" -ForegroundColor Cyan
Write-Host "   → Klik tombol 'Create Index'" -ForegroundColor White
Write-Host ""
Write-Host "2. Di Tab 2 (status whereIn + createdAt):" -ForegroundColor Cyan
Write-Host "   → Klik tombol 'Create Index'" -ForegroundColor White
Write-Host ""
Write-Host "3. Create Index 3 manually:" -ForegroundColor Cyan
Write-Host "   → Buka: https://console.firebase.google.com/project/pbl-2025-35a1c/firestore/indexes" -ForegroundColor White
Write-Host "   → Klik 'Create Index'" -ForegroundColor White
Write-Host "   → Collection: users" -ForegroundColor White
Write-Host "   → Field 1: status (Ascending)" -ForegroundColor White
Write-Host "   → Field 2: createdAt (Descending)" -ForegroundColor White
Write-Host "   → Klik 'Create'" -ForegroundColor White
Write-Host ""
Write-Host "4. Wait for all indexes to be 'Enabled' (green)" -ForegroundColor Cyan
Write-Host "   → This usually takes 2-5 minutes per index" -ForegroundColor White
Write-Host ""
Write-Host "5. Restart Flutter app" -ForegroundColor Cyan
Write-Host "   → Stop the app and run: flutter run" -ForegroundColor White
Write-Host ""
Write-Host "6. Test Kelola Pengguna" -ForegroundColor Cyan
Write-Host "   → Try filtering by role and status" -ForegroundColor White
Write-Host "   → Should work without errors!" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Total time needed: ~10-15 minutes" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Read-Host "Press Enter to exit"

