# ============================================================================
# TEST MARKETPLACE SYNC - VERIFICATION SCRIPT
# ============================================================================
# Verify that products from penjual appear in warga marketplace
# ============================================================================

Write-Host "================================" -ForegroundColor Cyan
Write-Host "TEST MARKETPLACE SYNC" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "🔍 VERIFYING IMPLEMENTATION..." -ForegroundColor Yellow
Write-Host ""

# Check 1: Collection name
Write-Host "1️⃣  Checking collection name in MarketplaceService..." -ForegroundColor Cyan
$serviceFile = "lib\core\services\marketplace_service.dart"
$content = Get-Content $serviceFile -Raw
if ($content -match "_productsCollection = 'products'") {
    Write-Host "   ✅ Collection name correct: 'products'" -ForegroundColor Green
} else {
    Write-Host "   ❌ Collection name WRONG!" -ForegroundColor Red
    Write-Host "   Expected: 'products'" -ForegroundColor Yellow
}
Write-Host ""

# Check 2: Factory method exists
Write-Host "2️⃣  Checking factory method in MarketplaceProductModel..." -ForegroundColor Cyan
$modelFile = "lib\core\models\marketplace_product_model.dart"
$content = Get-Content $modelFile -Raw
if ($content -match "fromProductCollection") {
    Write-Host "   ✅ Factory method exists: fromProductCollection()" -ForegroundColor Green
} else {
    Write-Host "   ❌ Factory method MISSING!" -ForegroundColor Red
}
Write-Host ""

# Check 3: Field mappings
Write-Host "3️⃣  Checking field mappings..." -ForegroundColor Cyan
$mappings = @(
    @{Old="productName"; New="nama"},
    @{Old="description"; New="deskripsi"},
    @{Old="price"; New="harga"},
    @{Old="stock"; New="stok"},
    @{Old="category"; New="kategori"},
    @{Old="soldCount"; New="terjual"}
)

foreach ($mapping in $mappings) {
    if ($content -match "data\['$($mapping.New)'\]") {
        Write-Host "   ✅ $($mapping.Old) ← $($mapping.New)" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Missing mapping: $($mapping.New)" -ForegroundColor Red
    }
}
Write-Host ""

# Check 4: Popular products widget
Write-Host "4️⃣  Checking Popular Products widget..." -ForegroundColor Cyan
$widgetFile = "lib\features\warga\marketplace\widgets\marketplace_popular_products.dart"
$content = Get-Content $widgetFile -Raw
if ($content -match "collection\('products'\)") {
    Write-Host "   ✅ Using 'products' collection" -ForegroundColor Green
} else {
    Write-Host "   ❌ Still using old collection!" -ForegroundColor Red
}

if ($content -match "orderBy\('terjual'") {
    Write-Host "   ✅ Ordering by 'terjual' field" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Check orderBy field" -ForegroundColor Yellow
}
Write-Host ""

# Check 5: Service methods updated
Write-Host "5️⃣  Checking service methods..." -ForegroundColor Cyan
$serviceContent = Get-Content $serviceFile -Raw
$methodCount = ([regex]::Matches($serviceContent, "fromProductCollection")).Count
Write-Host "   Found $methodCount uses of fromProductCollection()" -ForegroundColor White

if ($methodCount -ge 5) {
    Write-Host "   ✅ All methods updated!" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Some methods may still use old factory" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "================================" -ForegroundColor Cyan
Write-Host "MANUAL TESTING STEPS" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "📋 STEP 1: ADD PRODUCT (as Penjual)" -ForegroundColor Yellow
Write-Host "   1. Run: flutter run" -ForegroundColor White
Write-Host "   2. Login as penjual" -ForegroundColor White
Write-Host "   3. Go to Dashboard Penjual" -ForegroundColor White
Write-Host "   4. Tap 'Kelola Produk'" -ForegroundColor White
Write-Host "   5. Tap FAB '+Tambah Produk'" -ForegroundColor White
Write-Host "   6. Upload 1-3 photos" -ForegroundColor White
Write-Host "   7. Fill form:" -ForegroundColor White
Write-Host "      - Nama: Wortel Test Marketplace" -ForegroundColor Gray
Write-Host "      - Kategori: Sayuran Akar" -ForegroundColor Gray
Write-Host "      - Deskripsi: Test produk untuk marketplace" -ForegroundColor Gray
Write-Host "      - Harga: 10000" -ForegroundColor Gray
Write-Host "      - Stok: 100" -ForegroundColor Gray
Write-Host "   8. Tap 'Simpan Produk'" -ForegroundColor White
Write-Host "   9. ✅ Should see success message" -ForegroundColor Green
Write-Host ""

Write-Host "📋 STEP 2: CHECK FIRESTORE" -ForegroundColor Yellow
Write-Host "   1. Open Firebase Console" -ForegroundColor White
Write-Host "   2. Go to Firestore Database" -ForegroundColor White
Write-Host "   3. Open 'products' collection" -ForegroundColor White
Write-Host "   4. ✅ Should see new document with:" -ForegroundColor Green
Write-Host "      - nama: 'Wortel Test Marketplace'" -ForegroundColor Gray
Write-Host "      - harga: 10000" -ForegroundColor Gray
Write-Host "      - stok: 100" -ForegroundColor Gray
Write-Host "      - kategori: 'Sayuran Akar'" -ForegroundColor Gray
Write-Host "      - isActive: true" -ForegroundColor Gray
Write-Host "      - sellerId: (firebase uid)" -ForegroundColor Gray
Write-Host "      - imageUrls: [array of URLs]" -ForegroundColor Gray
Write-Host ""

Write-Host "📋 STEP 3: VIEW IN MARKETPLACE (as Warga)" -ForegroundColor Yellow
Write-Host "   1. Logout from penjual (or use different device)" -ForegroundColor White
Write-Host "   2. Login as warga" -ForegroundColor White
Write-Host "   3. Go to Marketplace tab" -ForegroundColor White
Write-Host "   4. Scroll to 'Popular Products' section" -ForegroundColor White
Write-Host "   5. ✅ Should see 'Wortel Test Marketplace'" -ForegroundColor Green
Write-Host "   6. ✅ Price: 'Rp 10.000/kg'" -ForegroundColor Green
Write-Host "   7. ✅ Image displays correctly" -ForegroundColor Green
Write-Host "   8. Tap on product card" -ForegroundColor White
Write-Host "   9. ✅ Product detail opens" -ForegroundColor Green
Write-Host ""

Write-Host "================================" -ForegroundColor Cyan
Write-Host "TROUBLESHOOTING" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "❌ PROBLEM: Product tidak muncul di marketplace" -ForegroundColor Red
Write-Host ""
Write-Host "Solutions:" -ForegroundColor Yellow
Write-Host "  1. Check console for errors:" -ForegroundColor White
Write-Host "     - Look for Firestore errors" -ForegroundColor Gray
Write-Host "     - Check collection name" -ForegroundColor Gray
Write-Host "     - Verify field mappings" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Verify Firestore rules:" -ForegroundColor White
Write-Host "     - Run: .\deploy_product_rules.ps1" -ForegroundColor Gray
Write-Host "     - Check read permission for 'products'" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Check indexes:" -ForegroundColor White
Write-Host "     - Run: .\deploy_product_indexes.ps1" -ForegroundColor Gray
Write-Host "     - Wait for indexes to build (2-5 mins)" -ForegroundColor Gray
Write-Host ""
Write-Host "  4. Verify data in Firestore:" -ForegroundColor White
Write-Host "     - Collection name: 'products' (lowercase)" -ForegroundColor Gray
Write-Host "     - Field 'isActive' = true" -ForegroundColor Gray
Write-Host "     - Fields use Indonesian names (nama, harga, etc)" -ForegroundColor Gray
Write-Host ""
Write-Host "  5. Hot restart app:" -ForegroundColor White
Write-Host "     - Press 'R' in terminal" -ForegroundColor Gray
Write-Host "     - Or restart completely" -ForegroundColor Gray
Write-Host ""

Write-Host "❌ PROBLEM: Images tidak muncul" -ForegroundColor Red
Write-Host ""
Write-Host "Solutions:" -ForegroundColor Yellow
Write-Host "  1. Check Azure Storage URLs accessible" -ForegroundColor Gray
Write-Host "  2. Verify PCVK API running (for uploads)" -ForegroundColor Gray
Write-Host "  3. Check network connection" -ForegroundColor Gray
Write-Host ""

Write-Host "================================" -ForegroundColor Green
Write-Host "EXPECTED CONSOLE OUTPUT" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""
Write-Host "When marketplace loads:" -ForegroundColor White
Write-Host "  ✅ Query success: X products loaded" -ForegroundColor Green
Write-Host ""
Write-Host "When adding product:" -ForegroundColor White
Write-Host "  ✅ Image 1 uploaded: (Azure URL)" -ForegroundColor Green
Write-Host "  ✅ Product created successfully with ID: (doc-id)" -ForegroundColor Green
Write-Host ""

Write-Host "================================" -ForegroundColor Cyan
Write-Host "QUICK VERIFICATION" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Run this Firebase query in console:" -ForegroundColor Yellow
Write-Host ""
Write-Host "db.collection('products')" -ForegroundColor White
Write-Host "  .where('isActive', '==', true)" -ForegroundColor White
Write-Host "  .orderBy('createdAt', 'desc')" -ForegroundColor White
Write-Host "  .limit(10)" -ForegroundColor White
Write-Host "  .get()" -ForegroundColor White
Write-Host ""
Write-Host "Should return products with Indonesian field names!" -ForegroundColor Green
Write-Host ""

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

