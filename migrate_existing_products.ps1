# ============================================================================
# MIGRATE EXISTING PRODUCTS - ADD isDeleted FIELD
# ============================================================================
# Add isDeleted=false to all existing products that don't have this field
# ============================================================================

Write-Host "================================" -ForegroundColor Cyan
Write-Host "MIGRATE EXISTING PRODUCTS" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "⚠️  WARNING!" -ForegroundColor Yellow
Write-Host "This script will update ALL products in Firestore" -ForegroundColor Yellow
Write-Host "to add 'isDeleted: false' field if they don't have it." -ForegroundColor Yellow
Write-Host ""

Write-Host "Why is this needed?" -ForegroundColor Cyan
Write-Host "- Old products don't have 'isDeleted' field" -ForegroundColor White
Write-Host "- Queries filter by 'isDeleted = false'" -ForegroundColor White
Write-Host "- Old products won't appear without this field" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "Do you want to continue? (yes/no)"

if ($confirm -ne "yes") {
    Write-Host "Migration cancelled." -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "Starting migration..." -ForegroundColor Green
Write-Host ""

# Create Node.js migration script
$migrationScript = @"
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function migrateProducts() {
  try {
    console.log('📊 Fetching all products...');

    const productsRef = db.collection('products');
    const snapshot = await productsRef.get();

    console.log('Found', snapshot.size, 'products');

    let updatedCount = 0;
    let skippedCount = 0;

    const batch = db.batch();

    snapshot.forEach((doc) => {
      const data = doc.data();

      // Check if isDeleted field exists
      if (data.isDeleted === undefined) {
        // Add isDeleted: false
        batch.update(doc.ref, { isDeleted: false });
        updatedCount++;
        console.log('✅ Will update:', doc.id, '-', data.nama || 'No name');
      } else {
        skippedCount++;
        console.log('⏭️  Skipped:', doc.id, '- already has isDeleted field');
      }
    });

    if (updatedCount > 0) {
      console.log('');
      console.log('💾 Committing batch update...');
      await batch.commit();
      console.log('✅ Migration complete!');
    } else {
      console.log('');
      console.log('✅ No products need migration');
    }

    console.log('');
    console.log('📊 Summary:');
    console.log('   Total products:', snapshot.size);
    console.log('   Updated:', updatedCount);
    console.log('   Skipped:', skippedCount);

  } catch (error) {
    console.error('❌ Migration failed:', error);
    process.exit(1);
  }
}

migrateProducts().then(() => {
  console.log('');
  console.log('🎉 Done!');
  process.exit(0);
});
"@

# Save migration script
$migrationScript | Out-File -FilePath "migrate_products.js" -Encoding UTF8

Write-Host "📝 Migration script created: migrate_products.js" -ForegroundColor Green
Write-Host ""

# Check if Node.js is installed
Write-Host "Checking Node.js..." -ForegroundColor Yellow
$nodejs = Get-Command node -ErrorAction SilentlyContinue

if (-not $nodejs) {
    Write-Host "❌ Node.js not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Node.js first:" -ForegroundColor Yellow
    Write-Host "https://nodejs.org/" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "After installing Node.js, run this script again." -ForegroundColor White
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

Write-Host "✅ Node.js found" -ForegroundColor Green
Write-Host ""

# Check if firebase-admin is installed
Write-Host "Checking firebase-admin package..." -ForegroundColor Yellow

if (-not (Test-Path "node_modules/firebase-admin")) {
    Write-Host "⚠️  firebase-admin not installed" -ForegroundColor Yellow
    Write-Host "Installing firebase-admin..." -ForegroundColor Cyan
    npm install firebase-admin
    Write-Host ""
}

Write-Host "✅ firebase-admin ready" -ForegroundColor Green
Write-Host ""

# Check for service account key
if (-not (Test-Path "serviceAccountKey.json")) {
    Write-Host "❌ serviceAccountKey.json not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please download your Firebase service account key:" -ForegroundColor Yellow
    Write-Host "1. Go to Firebase Console" -ForegroundColor White
    Write-Host "2. Project Settings > Service Accounts" -ForegroundColor White
    Write-Host "3. Click 'Generate new private key'" -ForegroundColor White
    Write-Host "4. Save as 'serviceAccountKey.json' in this folder" -ForegroundColor White
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

Write-Host "✅ Service account key found" -ForegroundColor Green
Write-Host ""

# Run migration
Write-Host "================================" -ForegroundColor Cyan
Write-Host "RUNNING MIGRATION" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

node migrate_products.js

Write-Host ""
Write-Host "================================" -ForegroundColor Green
Write-Host "MIGRATION COMPLETE!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""

Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Hot restart your Flutter app" -ForegroundColor White
Write-Host "2. Test Kelola Produk - products should appear now!" -ForegroundColor White
Write-Host ""

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

