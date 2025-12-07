#!/usr/bin/env pwsh
# ============================================================================
# TEST BACKEND CRUD - PowerShell Script
# ============================================================================
# Script untuk testing backend CRUD operations
# ============================================================================

Write-Host "=================================" -ForegroundColor Cyan
Write-Host "BACKEND CRUD TEST SUITE" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Navigate to project directory
$projectPath = "C:\Peyimpanan Pribadi\Data D\New folder (2)\Semester 5\PBL 2025"
Set-Location $projectPath

Write-Host "📁 Project Path: $projectPath" -ForegroundColor Yellow
Write-Host ""

# Step 1: Check Flutter
Write-Host "Step 1: Checking Flutter installation..." -ForegroundColor Green
flutter --version
Write-Host ""

# Step 2: Clean & Get Dependencies
Write-Host "Step 2: Cleaning and getting dependencies..." -ForegroundColor Green
flutter clean
flutter pub get
Write-Host ""

# Step 3: Analyze code
Write-Host "Step 3: Analyzing code..." -ForegroundColor Green
Write-Host "Analyzing ProductService..." -ForegroundColor Yellow
flutter analyze lib/core/services/product_service.dart

Write-Host "Analyzing CartService..." -ForegroundColor Yellow
flutter analyze lib/core/services/cart_service.dart

Write-Host "Analyzing CartRepository..." -ForegroundColor Yellow
flutter analyze lib/core/repositories/cart_repository.dart

Write-Host "Analyzing CartProvider..." -ForegroundColor Yellow
flutter analyze lib/core/providers/cart_provider.dart
Write-Host ""

# Step 4: Run test app
Write-Host "Step 4: Running backend CRUD test app..." -ForegroundColor Green
Write-Host "⚠️  Make sure you're logged in as a seller!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press Enter to run the test app, or Ctrl+C to cancel..."
Read-Host

flutter run -t lib/test_backend_crud.dart

Write-Host ""
Write-Host "=================================" -ForegroundColor Cyan
Write-Host "TEST COMPLETED" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

