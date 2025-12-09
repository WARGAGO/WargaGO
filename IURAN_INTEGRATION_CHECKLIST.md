# ✅ CHECKLIST INTEGRASI UI - IURAN WARGA

## Status: Ready for UI Integration
## Date: December 8, 2025

---

## 📋 PHASE 1: SETUP & CONFIGURATION

### 1.1 Provider Registration
- [ ] Buka `lib/main.dart`
- [ ] Tambahkan `IuranWargaProvider` ke `MultiProvider`
  ```dart
  ChangeNotifierProvider(create: (_) => IuranWargaProvider()),
  ```
- [ ] Verify provider terdaftar dengan hot restart
- [ ] Test: Print provider di widget untuk verify access

**Estimated Time**: 5 minutes

---

### 1.2 User Model Verification
- [ ] Buka model User yang sedang digunakan
- [ ] Verify field `keluargaId` exists
  ```dart
  final String? keluargaId; // atau required String keluargaId
  ```
- [ ] Jika tidak ada, tambahkan field
- [ ] Update `fromFirestore` dan `toMap` methods
- [ ] Test: Login dan print user.keluargaId

**Estimated Time**: 10 minutes

---

## 📋 PHASE 2: UPDATE IURAN WARGA PAGE

### 2.1 Initialize Provider
File: `lib/features/warga/iuran/pages/iuran_warga_page.dart`

- [ ] Convert StatelessWidget ke StatefulWidget
- [ ] Add `initState` method
- [ ] Initialize provider dengan keluargaId
  ```dart
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<IuranWargaProvider>();
      final authProvider = context.read<AuthProvider>();
      final keluargaId = authProvider.currentUser?.keluargaId;
      
      if (keluargaId != null) {
        await provider.initialize(keluargaId);
      }
    });
  }
  ```
- [ ] Test: Run app, verify initialize() called (check logs)

**Estimated Time**: 15 minutes

---

### 2.2 Replace Dummy Data with Real Data
File: `lib/features/warga/iuran/pages/iuran_warga_page.dart`

- [ ] Wrap `build` dengan `Consumer<IuranWargaProvider>`
- [ ] Add loading state
  ```dart
  if (provider.isLoading) {
    return Center(child: CircularProgressIndicator());
  }
  ```
- [ ] Add error state
  ```dart
  if (provider.errorMessage != null) {
    return ErrorWidget(message: provider.errorMessage!);
  }
  ```
- [ ] Update IuranHeaderCard dengan real data
  ```dart
  IuranHeaderCard(
    jumlahBelumDibayar: provider.totalBelumDibayar,
    countTunggakan: provider.countTunggakan,
  )
  ```
- [ ] Test: Verify data displayed correctly

**Estimated Time**: 20 minutes

---

### 2.3 Update IuranListSection
File: `lib/features/warga/iuran/widgets/iuran_list_section.dart`

- [ ] Replace dummy data dengan provider data
- [ ] Implement tabs:
  - Tab 1: Aktif → `provider.tagihanAktif`
  - Tab 2: Terlambat → `provider.tagihanTerlambat`
  - Tab 3: Lunas → `provider.historyPembayaran`
- [ ] Add ListView.builder untuk setiap tab
  ```dart
  ListView.builder(
    itemCount: provider.tagihanAktif.length,
    itemBuilder: (context, index) {
      final tagihan = provider.tagihanAktif[index];
      return IuranListItem(tagihan: tagihan);
    },
  )
  ```
- [ ] Test: Switch between tabs, verify data

**Estimated Time**: 30 minutes

---

### 2.4 Update IuranListItem
File: `lib/features/warga/iuran/widgets/iuran_list_item.dart`

- [ ] Accept `TagihanModel tagihan` parameter
- [ ] Display real data:
  ```dart
  Text(tagihan.jenisIuranName)
  Text(tagihan.formattedNominal)
  Text(tagihan.periode)
  ```
- [ ] Add status indicator based on `tagihan.status`
- [ ] Add onTap navigation to detail page
  ```dart
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IuranDetailPage(tagihan: tagihan),
      ),
    );
  }
  ```
- [ ] Test: Tap item, navigate to detail

**Estimated Time**: 20 minutes

---

## 📋 PHASE 3: UPDATE DETAIL PAGE

### 3.1 Update IuranDetailPage
File: `lib/features/warga/iuran/pages/iuran_detail_page.dart`

- [ ] Accept `TagihanModel tagihan` parameter instead of individual fields
- [ ] Update constructor
  ```dart
  const IuranDetailPage({
    super.key,
    required this.tagihan,
  });
  
  final TagihanModel tagihan;
  ```
- [ ] Update all widgets to use `tagihan` object
- [ ] Only show payment button if `tagihan.status != 'Lunas'`
  ```dart
  if (tagihan.status != 'Lunas')
    IuranPaymentButton(tagihan: tagihan),
  ```
- [ ] Test: Open detail page, verify data

**Estimated Time**: 15 minutes

---

## 📋 PHASE 4: IMPLEMENT PAYMENT FLOW

### 4.1 Update IuranPaymentButton
File: `lib/features/warga/iuran/widgets/iuran_payment_button.dart`

- [ ] Accept `TagihanModel tagihan` parameter
- [ ] Add payment processing logic
  ```dart
  Future<void> _processPayment(BuildContext context, String metode) async {
    final provider = context.read<IuranWargaProvider>();
    final authProvider = context.read<AuthProvider>();
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );
    
    // Process payment
    final success = await provider.bayarIuran(
      tagihanId: tagihan.id,
      metodePembayaran: metode,
      userId: authProvider.currentUser!.uid,
    );
    
    // Hide loading
    Navigator.pop(context);
    
    // Show result
    if (success) {
      _showSuccessDialog(context);
    } else {
      _showErrorDialog(context, provider.errorMessage);
    }
  }
  ```
- [ ] Test: Pay with Cash method

**Estimated Time**: 30 minutes

---

### 4.2 Add Image Upload for Transfer
File: `lib/features/warga/iuran/widgets/iuran_payment_button.dart`

- [ ] Add image_picker dependency
  ```yaml
  image_picker: ^1.0.7
  ```
- [ ] Implement image picking
  ```dart
  Future<String?> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    return image?.path;
  }
  ```
- [ ] If method is 'Transfer', show upload option
- [ ] Upload image and get URL
  ```dart
  String? buktiUrl;
  if (metode == 'Transfer') {
    final imagePath = await _pickImage();
    if (imagePath != null) {
      buktiUrl = await provider.uploadBuktiPembayaran(
        tagihanId: tagihan.id,
        imagePath: imagePath,
      );
    }
  }
  ```
- [ ] Pass buktiUrl to bayarIuran
- [ ] Test: Pay with Transfer method, upload image

**Estimated Time**: 45 minutes

---

### 4.3 Add Success/Error Dialogs
File: `lib/features/warga/iuran/widgets/iuran_payment_button.dart`

- [ ] Create success dialog
  ```dart
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pembayaran Berhasil'),
        content: Text('Iuran telah dibayar. Terima kasih!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close detail page
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  ```
- [ ] Create error dialog
  ```dart
  void _showErrorDialog(BuildContext context, String? error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pembayaran Gagal'),
        content: Text(error ?? 'Terjadi kesalahan'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  ```
- [ ] Test: Verify dialogs shown

**Estimated Time**: 15 minutes

---

## 📋 PHASE 5: UPDATE MENU GRID

### 5.1 Update IuranMenuGrid
File: `lib/features/warga/iuran/widgets/iuran_menu_grid.dart`

- [ ] Connect to provider for real statistics
- [ ] Update "Total Tagihan" card
  ```dart
  Consumer<IuranWargaProvider>(
    builder: (context, provider, child) {
      return MenuCard(
        title: 'Total Tagihan',
        value: 'Rp ${provider.totalTunggakan.toStringAsFixed(0)}',
        count: '${provider.countTunggakan} Tagihan',
      );
    },
  )
  ```
- [ ] Add navigation to filtered views
- [ ] Test: Verify numbers match

**Estimated Time**: 20 minutes

---

## 📋 PHASE 6: FIRESTORE RULES DEPLOYMENT

### 6.1 Backup Current Rules
- [ ] Open terminal
- [ ] Run backup command
  ```powershell
  firebase firestore:rules > firestore.rules.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')
  ```
- [ ] Verify backup file created

**Estimated Time**: 2 minutes

---

### 6.2 Update Firestore Rules
- [ ] Open `firestore.rules` file
- [ ] Copy rules from `IURAN_FIRESTORE_RULES.md`
- [ ] Paste ke firestore.rules
- [ ] Review rules carefully
- [ ] Save file

**Estimated Time**: 10 minutes

---

### 6.3 Deploy Rules
- [ ] Run deploy command
  ```powershell
  firebase deploy --only firestore:rules
  ```
- [ ] Wait for deployment success message
- [ ] Verify in Firebase Console

**Estimated Time**: 3 minutes

---

## 📋 PHASE 7: TESTING

### 7.1 Unit Testing
- [ ] Test service methods
  - [ ] `getTagihanByKeluarga()`
  - [ ] `bayarIuran()`
  - [ ] `getStatistikIuran()`
- [ ] Test provider state changes
- [ ] Test error handling

**Estimated Time**: 1 hour

---

### 7.2 Integration Testing
- [ ] Test complete flow:
  - [ ] Login as warga
  - [ ] Navigate to iuran page
  - [ ] View tagihan list
  - [ ] Filter by status
  - [ ] Open detail page
  - [ ] Pay iuran (Cash)
  - [ ] Verify status updated
  - [ ] Check keuangan record created
- [ ] Test edge cases:
  - [ ] No tagihan
  - [ ] Already paid
  - [ ] Network error
  - [ ] Permission denied

**Estimated Time**: 2 hours

---

### 7.3 Manual Testing Checklist
- [ ] **View Tagihan**
  - [ ] Data loads correctly
  - [ ] Real-time updates work
  - [ ] Loading state shows
  - [ ] Error state shows (test by disconnecting)
  
- [ ] **Filter Tabs**
  - [ ] Aktif tab shows unpaid
  - [ ] Terlambat tab shows overdue
  - [ ] Lunas tab shows paid
  
- [ ] **Statistics**
  - [ ] Total tunggakan correct
  - [ ] Count tunggakan correct
  - [ ] Updates after payment
  
- [ ] **Payment Flow - Cash**
  - [ ] Select Cash method
  - [ ] Confirm payment
  - [ ] Loading indicator shows
  - [ ] Success dialog shows
  - [ ] Tagihan status updates to Lunas
  - [ ] Navigate back works
  
- [ ] **Payment Flow - Transfer**
  - [ ] Select Transfer method
  - [ ] Upload bukti image
  - [ ] Confirm payment
  - [ ] Bukti URL saved
  - [ ] Success dialog shows
  
- [ ] **Data Consistency**
  - [ ] After payment, check Firestore:
    - [ ] tagihan.status = 'Lunas'
    - [ ] tagihan.metodePembayaran = selected method
    - [ ] tagihan.tanggalBayar = today
    - [ ] keuangan record created
    - [ ] keuangan.type = 'pemasukan'
    - [ ] keuangan.sourceType = 'iuran'
    - [ ] keuangan.sourceId = tagihanId
  
- [ ] **Security**
  - [ ] Warga only sees own keluarga tagihan
  - [ ] Warga can't see other keluarga data
  - [ ] Warga can't modify nominal
  - [ ] Admin can see all (test as admin)
  
- [ ] **Error Handling**
  - [ ] Network offline → Shows error
  - [ ] Permission denied → Shows error
  - [ ] Already paid → Shows error
  - [ ] Invalid data → Shows error

**Estimated Time**: 1 hour

---

## 📋 PHASE 8: OPTIMIZATION & POLISH

### 8.1 Performance Optimization
- [ ] Add pagination if needed
- [ ] Implement local caching
- [ ] Optimize images (compression)
- [ ] Reduce Firestore reads where possible

**Estimated Time**: 1 hour

---

### 8.2 UI/UX Improvements
- [ ] Add pull-to-refresh
- [ ] Add empty state UI
- [ ] Add skeleton loading
- [ ] Improve error messages
- [ ] Add animations

**Estimated Time**: 2 hours

---

### 8.3 Additional Features (Optional)
- [ ] Export payment receipt to PDF
- [ ] Share payment receipt
- [ ] Payment reminder notifications
- [ ] Payment history chart
- [ ] Search/filter tagihan

**Estimated Time**: 4 hours

---

## 📋 PHASE 9: DOCUMENTATION

### 9.1 Code Documentation
- [ ] Add comments to complex logic
- [ ] Document widget parameters
- [ ] Add usage examples

**Estimated Time**: 30 minutes

---

### 9.2 User Documentation
- [ ] Create user guide for warga
- [ ] Screenshot payment flow
- [ ] FAQ document

**Estimated Time**: 1 hour

---

## 📊 TOTAL TIME ESTIMATION

| Phase | Estimated Time |
|-------|---------------|
| Phase 1: Setup | 15 minutes |
| Phase 2: Update Pages | 1.5 hours |
| Phase 3: Detail Page | 15 minutes |
| Phase 4: Payment Flow | 1.5 hours |
| Phase 5: Menu Grid | 20 minutes |
| Phase 6: Firestore Rules | 15 minutes |
| Phase 7: Testing | 4 hours |
| Phase 8: Optimization | 3 hours |
| Phase 9: Documentation | 1.5 hours |
| **TOTAL** | **~12 hours** |

---

## ✅ COMPLETION CRITERIA

**Backend Integration Complete When:**
- [x] All providers registered
- [x] All pages display real data
- [x] Payment flow works end-to-end
- [x] Atomic transaction verified
- [x] Firestore rules deployed
- [x] All tests pass
- [x] No console errors
- [x] Data consistency verified
- [x] Security verified
- [x] Documentation complete

---

## 🚨 TROUBLESHOOTING COMMON ISSUES

### Issue: "Permission Denied"
**Solution**:
1. Check Firestore rules deployed
2. Verify user.keluargaId exists
3. Check Firebase Console > Firestore > Rules

### Issue: "Tagihan Not Found"
**Solution**:
1. Verify tagihan exists in Firestore
2. Check keluargaId matches
3. Ensure isActive = true

### Issue: "Payment Failed"
**Solution**:
1. Check console logs for error details
2. Verify both tagihan & keuangan rules allow operation
3. Check network connectivity
4. Verify userId is correct

### Issue: "Real-time Updates Not Working"
**Solution**:
1. Check stream subscription active
2. Verify notifyListeners() called
3. Check Consumer widget wrapping
4. Verify dispose() called properly

---

## 📞 SUPPORT

**Questions? Issues?**
1. Check detailed logs (debugPrint statements)
2. Review documentation files
3. Check Firestore Console for data
4. Review this checklist

---

**Good luck with the integration! 🚀**
