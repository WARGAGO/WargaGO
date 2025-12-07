# ============================================================================
# DEPLOY FIRESTORE RULES
# ============================================================================
# Script untuk deploy Firestore security rules ke Firebase
# ============================================================================

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "DEPLOY FIRESTORE RULES" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Check if firebase command exists
try {
    $firebaseVersion = firebase --version 2>&1
    Write-Host "✅ Firebase CLI detected: $firebaseVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Firebase CLI not found. Installing..." -ForegroundColor Red
    npm install -g firebase-tools
}

Write-Host ""
Write-Host "🚀 Deploying Firestore rules..." -ForegroundColor Yellow
Write-Host ""

# Deploy firestore rules
firebase deploy --only firestore:rules

Write-Host ""
Write-Host "✅ Deployment complete!" -ForegroundColor Green
Write-Host ""

