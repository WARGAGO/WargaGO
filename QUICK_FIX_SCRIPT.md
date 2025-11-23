# 🔧 QUICK FIX SCRIPT - Import Path Fixer

## PowerShell Script untuk Fix Semua Import Errors

Jalankan script ini di PowerShell untuk fix semua remaining import errors sekaligus!

### **Script 1: Fix ../../core/ imports**
```powershell
cd "C:\Peyimpanan Pribadi\Data D\New folder (2)\Semester 5\PBL 2025"

Get-ChildItem -Path "lib/features/admin" -Recurse -Filter "*.dart" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $newContent = $content -replace "import '\.\.\/\.\.\/core\/", "import 'package:jawara/core/"
    if ($content -ne $newContent) {
        Set-Content -Path $_.FullName -Value $newContent -NoNewline
        Write-Host "Fixed: $($_.Name)" -ForegroundColor Green
    }
}
```

### **Script 2: Fix ../../../core/ imports**
```powershell
cd "C:\Peyimpanan Pribadi\Data D\New folder (2)\Semester 5\PBL 2025"

Get-ChildItem -Path "lib/features/admin" -Recurse -Filter "*.dart" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $newContent = $content -replace "import '\.\.\/\.\.\/\.\.\/core\/", "import 'package:jawara/core/"
    if ($content -ne $newContent) {
        Set-Content -Path $_.FullName -Value $newContent -NoNewline
        Write-Host "Fixed: $($_.Name)" -ForegroundColor Green
    }
}
```

### **Script 3: Fix ../../../../core/ imports**
```powershell
cd "C:\Peyimpanan Pribadi\Data D\New folder (2)\Semester 5\PBL 2025"

Get-ChildItem -Path "lib/features/admin" -Recurse -Filter "*.dart" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $newContent = $content -replace "import '\.\.\/\.\.\/\.\.\/\.\.\/core\/", "import 'package:jawara/core/"
    if ($content -ne $newContent) {
        Set-Content -Path $_.FullName -Value $newContent -NoNewline
        Write-Host "Fixed: $($_.Name)" -ForegroundColor Green
    }
}
```

### **Script 4: Fix ../admin/ imports**
```powershell
cd "C:\Peyimpanan Pribadi\Data D\New folder (2)\Semester 5\PBL 2025"

Get-ChildItem -Path "lib/features/admin/data_warga" -Recurse -Filter "*.dart" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $newContent = $content -replace "import '\.\.\/admin\/", "import 'package:jawara/features/admin/"
    if ($content -ne $newContent) {
        Set-Content -Path $_.FullName -Value $newContent -NoNewline
        Write-Host "Fixed: $($_.Name)" -ForegroundColor Green
    }
}
```

### **ALL-IN-ONE SCRIPT** ⭐ RECOMMENDED

```powershell
# ============================================================
# JAWARA APP - IMPORT PATH FIXER
# ============================================================
# This script fixes all relative import paths to absolute paths
# Run this in PowerShell to fix all remaining import errors!
# ============================================================

cd "C:\Peyimpanan Pribadi\Data D\New folder (2)\Semester 5\PBL 2025"

Write-Host "Starting Import Path Fixer..." -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

$fixed = 0

# Fix ../../core/ patterns
Write-Host "`nFixing ../../core/ imports..." -ForegroundColor Yellow
Get-ChildItem -Path "lib/features/admin" -Recurse -Filter "*.dart" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $newContent = $content -replace "import '\.\.\/\.\.\/core\/", "import 'package:jawara/core/"
    if ($content -ne $newContent) {
        Set-Content -Path $_.FullName -Value $newContent -NoNewline
        Write-Host "  ✓ $($_.Name)" -ForegroundColor Green
        $fixed++
    }
}

# Fix ../../../core/ patterns
Write-Host "`nFixing ../../../core/ imports..." -ForegroundColor Yellow
Get-ChildItem -Path "lib/features/admin" -Recurse -Filter "*.dart" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $newContent = $content -replace "import '\.\.\/\.\.\/\.\.\/core\/", "import 'package:jawara/core/"
    if ($content -ne $newContent) {
        Set-Content -Path $_.FullName -Value $newContent -NoNewline
        Write-Host "  ✓ $($_.Name)" -ForegroundColor Green
        $fixed++
    }
}

# Fix ../../../../core/ patterns
Write-Host "`nFixing ../../../../core/ imports..." -ForegroundColor Yellow
Get-ChildItem -Path "lib/features/admin" -Recurse -Filter "*.dart" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $newContent = $content -replace "import '\.\.\/\.\.\/\.\.\/\.\.\/core\/", "import 'package:jawara/core/"
    if ($content -ne $newContent) {
        Set-Content -Path $_.FullName -Value $newContent -NoNewline
        Write-Host "  ✓ $($_.Name)" -ForegroundColor Green
        $fixed++
    }
}

# Fix ../admin/ patterns
Write-Host "`nFixing ../admin/ imports..." -ForegroundColor Yellow
Get-ChildItem -Path "lib/features/admin" -Recurse -Filter "*.dart" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $newContent = $content -replace "import '\.\.\/admin\/", "import 'package:jawara/features/admin/"
    if ($content -ne $newContent) {
        Set-Content -Path $_.FullName -Value $newContent -NoNewline
        Write-Host "  ✓ $($_.Name)" -ForegroundColor Green
        $fixed++
    }
}

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "DONE! Fixed $fixed files." -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Run: flutter analyze --no-pub" -ForegroundColor White
Write-Host "2. Run: flutter run" -ForegroundColor White
Write-Host "`n" -ForegroundColor White
```

---

## 📝 HOW TO USE

### **Step 1: Open PowerShell**
```powershell
# Right-click on PowerShell and "Run as Administrator"
```

### **Step 2: Copy ALL-IN-ONE Script**
Copy the entire "ALL-IN-ONE SCRIPT" above

### **Step 3: Paste & Run**
Paste in PowerShell and press Enter

### **Step 4: Wait**
Script will process all files and show progress

### **Step 5: Verify**
```powershell
flutter analyze --no-pub
```

---

## ✅ EXPECTED RESULTS

**Before Script:**
- 200+ import errors

**After Script:**
- ~50 import errors (only missing providers/models)
- Main app should compile & run!

---

## 🎯 AFTER RUNNING SCRIPT

Run these commands:

```powershell
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Analyze
flutter analyze --no-pub

# Run app
flutter run
```

---

**Created:** November 24, 2025  
**Purpose:** Fix all import path errors in one go  
**Status:** ✅ Ready to use

