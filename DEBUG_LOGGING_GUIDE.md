# 🔍 DEBUG LOGGING ADDED - TROUBLESHOOTING GUIDE

## ⚠️ **PROBLEM REPORTED:**

**Issue**: User clicks "Simpan & Selesai" tapi muncul warning:
```
"Nomor KK harus diisi"
"RT harus diisi"  
"RW harus diisi"
```

**Expected**: Data sudah AUTO-FILLED dari OCR KK

---

## 🔧 **FIX APPLIED:**

### **Added Debug Logging di 3 Files:**

**1. kyc_upload_page.dart** - Saat passing data
**2. alamat_rumah_page.dart** - Saat passing data
**3. data_keluarga_page.dart** - Saat receiving data

---

## 📊 **DEBUG OUTPUT YANG HARUS MUNCUL:**

### **Step 1: Upload KK (kyc_upload_page.dart)**
```
✅ No KK found: 3201234567890123
✅ RT/RW found: 001 / 002
📤 [KYC Upload] Passing data to Alamat Rumah:
   No KK: "3201234567890123"
   RT: "001"
   RW: "002"
   From OCR variables:
   _nomorKK: 3201234567890123
   _rtFromKK: 001
   _rwFromKK: 002
```

### **Step 2: Submit Alamat Rumah (alamat_rumah_page.dart)**
```
📤 [Alamat Rumah] Passing data to Data Keluarga:
   No KK: "3201234567890123"
   RT: "001"
   RW: "002"
   Kepala Keluarga: "John Doe"
   Jumlah Penghuni: 4
```

### **Step 3: Open Data Keluarga (data_keluarga_page.dart)**
```
🔍 [DataKeluarga] Pre-filling data...
📦 Complete data received: {userId: uid_123, nomorKK: 3201234567890123, rt: 001, rw: 002, ...}
✅ No KK from OCR: "3201234567890123"
✅ RT from OCR: "001"
✅ RW from OCR: "002"
📝 Controllers filled:
   No KK: "3201234567890123"
   RT: "001"
   RW: "002"
   Nama Keluarga: "Keluarga John Doe"
✅ keluargaId generated: KEL_3201234567890123_001002
```

---

## 🧪 **TESTING STEPS:**

### **1. Hot Restart App**
```bash
# Di terminal, tekan:
R
```

### **2. Open Flutter DevTools Console**
```bash
# Di browser, buka:
http://localhost:9100
# atau check terminal untuk link
```

### **3. Register & Upload KYC**
- Upload KTP → OCR
- Upload KK → **WATCH CONSOLE** 🔍

**Expected Console Output**:
```
✅ No KK found: 3201234567890123
✅ RT/RW found: 001 / 002
```

**If NOT appear**:
- ❌ OCR failed to extract
- Check KK image quality
- Re-upload dengan foto lebih jelas

### **4. Click "Submit Dokumen"**

**Expected Console Output**:
```
📤 [KYC Upload] Passing data to Alamat Rumah:
   No KK: "3201234567890123"  ← Should have value!
   RT: "001"                   ← Should have value!
   RW: "002"                   ← Should have value!
```

**If empty strings**:
- ❌ OCR variables not set (_nomorKK, _rtFromKK, _rwFromKK)
- Problem in _uploadKK() method

### **5. Fill Alamat Rumah & Click "Lanjutkan"**

**Expected Console Output**:
```
📤 [Alamat Rumah] Passing data to Data Keluarga:
   No KK: "3201234567890123"  ← Should STILL have value!
   RT: "001"
   RW: "002"
```

**If empty**:
- ❌ Data lost during spread operator
- Check widget.kycData

### **6. Data Keluarga Page Opens**

**Expected Console Output**:
```
🔍 [DataKeluarga] Pre-filling data...
📦 Complete data received: {nomorKK: 3201234567890123, ...}
✅ No KK from OCR: "3201234567890123"
✅ RT from OCR: "001"
✅ RW from OCR: "002"
📝 Controllers filled:
   No KK: "3201234567890123"
   RT: "001"
   RW: "002"
✅ keluargaId generated: KEL_3201234567890123_001002
```

**If controllers empty**:
- ❌ widget.completeData not received
- ❌ Controllers not set properly

### **7. Verify UI**

**Check TextFields**:
```
No KK field: [3201234567890123]  ← Should be filled!
RT field: [001]                   ← Should be filled!
RW field: [002]                   ← Should be filled!
```

**Check keluargaId Preview**:
```
┌────────────────────────────────┐
│ 🏷️  ID Keluarga Anda          │
│ KEL_3201234567890123_001002   │
└────────────────────────────────┘
```

---

## 🔍 **TROUBLESHOOTING BY CONSOLE LOG:**

### **Scenario 1: OCR Tidak Extract Data**

**Console Shows**:
```
⚠️ OCR tidak menemukan data. KK tersimpan, tapi Anda perlu input manual nanti.
```

**Cause**:
- KK image quality poor
- RegEx pattern tidak match
- KK format tidak standar

**Solution**:
1. Re-upload KK dengan foto lebih jelas
2. Pastikan KK tidak blur
3. Pastikan No KK terlihat jelas (16 digits)
4. Pastikan RT/RW terlihat jelas

---

### **Scenario 2: Data Di-Pass Tapi Kosong**

**Console Shows**:
```
📤 [KYC Upload] Passing data to Alamat Rumah:
   No KK: ""         ← EMPTY!
   RT: ""            ← EMPTY!
   RW: ""            ← EMPTY!
   From OCR variables:
   _nomorKK: null    ← NULL!
   _rtFromKK: null
   _rwFromKK: null
```

**Cause**:
- OCR ran but didn't find patterns
- Variables not set in _uploadKK()

**Solution**:
1. Check RegEx patterns in _uploadKK()
2. Test with different KK format
3. Add more RegEx patterns for edge cases

---

### **Scenario 3: Data Lost in Transit**

**Console Shows**:
```
📤 [KYC Upload] Passing data:
   No KK: "3201234567890123"  ✅ OK
   
📤 [Alamat Rumah] Passing data:
   No KK: ""  ❌ LOST!
```

**Cause**:
- Spread operator issue
- widget.kycData not received

**Solution**:
1. Check navigation: `context.push(route, extra: kycData)`
2. Check constructor: `AlamatRumahPage({required this.kycData})`
3. Verify spread operator: `{...widget.kycData, ...}`

---

### **Scenario 4: Controllers Not Filled**

**Console Shows**:
```
🔍 [DataKeluarga] Pre-filling data...
📦 Complete data received: {nomorKK: 3201234567890123, ...}
✅ No KK from OCR: "3201234567890123"
📝 Controllers filled:
   No KK: ""  ❌ EMPTY!
```

**Cause**:
- Controllers not initialized
- _prefillData() not called
- initState() issue

**Solution**:
1. Verify initState() calls _prefillData()
2. Check controller initialization
3. Try setState() after setting text

---

## 📝 **QUICK FIX CHECKLIST:**

**Before Testing**:
- [x] Hot restart app
- [x] Open console/DevTools
- [x] Clear app data (if needed)

**During Test**:
- [ ] Upload KK → Check console for "✅ No KK found"
- [ ] Submit → Check console for "📤 Passing data"
- [ ] Each page → Check console for data flow
- [ ] Data Keluarga → Check if fields filled

**If Fields Empty**:
1. Check console logs (find where data lost)
2. Re-upload KK dengan foto lebih jelas
3. Check if OCR extracted data
4. Verify data passed through all pages

---

## 🎯 **SUCCESS INDICATORS:**

**Console Logs**:
```
✅ ✅ No KK found: 3201234567890123
✅ ✅ RT/RW found: 001 / 002
✅ 📤 Data passed to Alamat Rumah with values
✅ 📤 Data passed to Data Keluarga with values
✅ 📝 Controllers filled successfully
✅ ✅ keluargaId generated
```

**UI**:
```
✅ No KK field auto-filled
✅ RT field auto-filled
✅ RW field auto-filled
✅ keluargaId preview shows
✅ No validation errors
✅ Can click "Simpan & Selesai" without errors
```

---

## 🚀 **NEXT STEPS:**

### **Test Now**:
1. **Hot Restart** (R)
2. **Watch Console** closely
3. **Upload KK** dengan foto JELAS
4. **Follow debug logs** step by step
5. **Report findings**:
   - Where did logs stop?
   - Where did data become empty?
   - Screenshot console & UI

### **If Still Not Working**:

**Share This Info**:
1. Screenshot of console logs
2. Screenshot of Data Keluarga page (fields)
3. Copy-paste ALL console output from:
   - KYC Upload
   - Alamat Rumah
   - Data Keluarga

**We'll Debug Together**! 🔍

---

## ✅ **STATUS:**

**Debug Logging**: ✅ **ADDED**  
**Ready to Test**: ✅ **YES**  
**Next**: ⏳ **USER TEST WITH CONSOLE MONITORING**  

---

**IMPORTANT**: 
- **WATCH CONSOLE** during test
- Console logs akan show **exactly where data is lost**
- Ini akan help kita find the exact problem

**Hot restart sekarang dan test dengan console terbuka!** 🔍🚀

