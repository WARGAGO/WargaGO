# Script untuk Clean Build dan Test Profile Warga

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CLEAN BUILD & TEST PROFILE WARGA" -ForegroundColor Cyan
Write-Host "  ✨ WITH NEW MODERN UI! ✨" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Navigate to project directory
Set-Location "C:\Peyimpanan Pribadi\Data D\New folder (2)\Semester 5\PBL 2025"

# Step 1: Clean
Write-Host "[1/4] Cleaning Flutter cache..." -ForegroundColor Yellow
flutter clean
Write-Host "✅ Clean completed!" -ForegroundColor Green
Write-Host ""

# Step 2: Get dependencies
Write-Host "[2/4] Getting dependencies..." -ForegroundColor Yellow
flutter pub get
Write-Host "✅ Dependencies updated!" -ForegroundColor Green
Write-Host ""

# Step 3: Analyze
Write-Host "[3/4] Analyzing code..." -ForegroundColor Yellow
flutter analyze lib/features/warga/warga_main_page.dart lib/features/warga/profile/
Write-Host "✅ Analysis completed!" -ForegroundColor Green
Write-Host ""

# Step 4: Run
Write-Host "[4/4] Running application..." -ForegroundColor Yellow
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  INSTRUCTIONS:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "1. Wait for app to load on device/emulator" -ForegroundColor White
Write-Host "2. Login as WARGA (not admin)" -ForegroundColor White
Write-Host "3. Click 'Akun' tab (person icon)" -ForegroundColor White
Write-Host ""
Write-Host "✨ NEW UI FEATURES TO TEST:" -ForegroundColor Magenta
Write-Host "  🎨 Gradient header (blue)" -ForegroundColor Gray
Write-Host "  ✨ Avatar with glow effect" -ForegroundColor Gray
Write-Host "  💳 Modern menu cards with gradient icons" -ForegroundColor Gray
Write-Host "  🔴 Gradient logout button" -ForegroundColor Gray
Write-Host "  🌊 Smooth fade & slide animations" -ForegroundColor Gray
Write-Host "  📝 Modern form fields in Edit Profile" -ForegroundColor Gray
Write-Host ""
Write-Host "4. CHECK CONSOLE for debug logs:" -ForegroundColor White
Write-Host "   - 🔴 Navbar clicked! Index: 4, Label: Akun" -ForegroundColor Gray
Write-Host "   - 🟢 _currentIndex updated to: 4" -ForegroundColor Gray
Write-Host "   - 📍 Navigation Index: 4 → Page Index: 3 (Page: AkunScreen)" -ForegroundColor Gray
Write-Host "   - 🟢 AkunScreen LOADED - Profile Warga Connected" -ForegroundColor Gray
Write-Host "   - 🔵 AkunScreen building..." -ForegroundColor Gray
Write-Host "   - User data: [nama], Email: [email]" -ForegroundColor Gray
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

flutter run

