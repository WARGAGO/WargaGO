// ============================================================================
// EDIT PRODUK SCREEN - Edit Product
// ============================================================================
// Screen untuk edit produk dengan pre-filled data dan update Azure Storage
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:wargago/core/models/product_model.dart';
import 'package:wargago/core/services/product_service.dart';
import 'package:wargago/core/services/azure_blob_storage_service.dart';

class EditProdukScreen extends StatefulWidget {
  final ProductModel product;

  const EditProdukScreen({super.key, required this.product});

  @override
  State<EditProdukScreen> createState() => _EditProdukScreenState();
}

class _EditProdukScreenState extends State<EditProdukScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _stokController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _beratController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  List<String> _existingImageUrls = []; // URLs dari Firestore
  List<File> _newImages = []; // New images to upload
  String? _selectedCategory;
  bool _isLoading = false;

  final List<String> _categories = [
    'Sayuran Daun',
    'Sayuran Akar',
    'Sayuran Buah',
    'Sayuran Polong',
  ];

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  void _loadProductData() {
    _namaController.text = widget.product.nama;
    _hargaController.text = widget.product.harga.toStringAsFixed(0);
    _stokController.text = widget.product.stok.toString();
    _deskripsiController.text = widget.product.deskripsi;
    _beratController.text = (widget.product.berat * 1000).toStringAsFixed(0); // kg to gram
    _selectedCategory = widget.product.kategori;
    _existingImageUrls = List.from(widget.product.imageUrls);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _stokController.dispose();
    _deskripsiController.dispose();
    _beratController.dispose();
    super.dispose();
  }

  int get _totalImages => _existingImageUrls.length + _newImages.length;

  Future<void> _pickImage(ImageSource source) async {
    if (_totalImages >= 3) {
      _showErrorSnackbar('Maksimal 3 foto');
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (image != null) {
        setState(() {
          _newImages.add(File(image.path));
        });
      }
    } catch (e) {
      _showErrorSnackbar('Gagal memilih gambar: $e');
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Pilih Sumber Gambar',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2F80ED).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Color(0xFF2F80ED),
                ),
              ),
              title: Text(
                'Kamera',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2F80ED).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF2F80ED),
                ),
              ),
              title: Text(
                'Galeri',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_totalImages == 0) {
      _showErrorSnackbar('Minimal tambahkan 1 foto produk');
      return;
    }

    if (_selectedCategory == null) {
      _showErrorSnackbar('Pilih kategori produk');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User tidak ditemukan. Silakan login kembali.');
      }

      final firebaseToken = await currentUser.getIdToken();
      if (firebaseToken == null) {
        throw Exception('Token tidak valid. Silakan login kembali.');
      }

      // Upload new images to Azure Storage
      final List<String> newImageUrls = [];
      if (_newImages.isNotEmpty) {
        final azureService = AzureBlobStorageService(firebaseToken: firebaseToken);
        final timestamp = DateTime.now().millisecondsSinceEpoch;

        for (int i = 0; i < _newImages.length; i++) {
          try {
            final fileName = 'product_${currentUser.uid}_${timestamp}_${_existingImageUrls.length + i}.jpg';
            final response = await azureService.uploadImage(
              file: _newImages[i],
              isPrivate: false,
              prefixName: 'products/', // Add trailing slash
              customFileName: fileName,
            );

            if (response != null) {
              // TEMPORARY: Keep SAS token until container is set to public
              // TODO: After setting container public, use removeSasToken()
              newImageUrls.add(response.blobUrl);
              print('✅ New image ${i + 1} uploaded: ${response.blobUrl}');
            }
          } catch (e) {
            print('❌ Error uploading new image ${i + 1}: $e');
          }
        }
      }

      // Combine existing and new image URLs
      final allImageUrls = [..._existingImageUrls, ...newImageUrls];

      if (allImageUrls.isEmpty) {
        throw Exception('Gagal mengupload gambar. Silakan coba lagi.');
      }

      // Parse berat
      double berat = 0.0;
      if (_beratController.text.isNotEmpty) {
        berat = double.tryParse(_beratController.text) ?? 0.0;
        berat = berat / 1000; // gram to kg
      }

      // Update product
      final updatedProduct = widget.product.copyWith(
        nama: _namaController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        harga: double.parse(_hargaController.text),
        stok: int.parse(_stokController.text),
        berat: berat,
        kategori: _selectedCategory!,
        imageUrls: allImageUrls,
        updatedAt: DateTime.now(),
      );

      final productService = ProductService();
      final success = await productService.updateProduct(updatedProduct);

      if (!success) {
        throw Exception('Gagal mengupdate produk ke database.');
      }

      setState(() => _isLoading = false);

      if (mounted) {
        _showSuccessSnackbar('Produk berhasil diupdate!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showErrorSnackbar('Gagal mengupdate produk: ${e.toString()}');
      }
      print('❌ Error in _submitForm: $e');
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFF59E0B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(
          'Edit Produk',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF2F80ED),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildImageSection(),
            const SizedBox(height: 24),
            _buildSectionTitle('Informasi Produk'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _namaController,
              label: 'Nama Produk',
              hint: 'Contoh: Wortel Fresh',
              icon: Icons.shopping_bag,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama produk harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildCategorySelector(),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _deskripsiController,
              label: 'Deskripsi Produk',
              hint: 'Jelaskan produk Anda...',
              icon: Icons.description,
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Deskripsi harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Harga & Stok'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _hargaController,
                    label: 'Harga',
                    hint: '0',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    prefix: Text(
                      'Rp ',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harga harus diisi';
                      }
                      if (int.parse(value) <= 0) {
                        return 'Harga harus > 0';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _stokController,
                    label: 'Stok',
                    hint: '0',
                    icon: Icons.inventory_2,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    suffix: Text(
                      'pcs',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Stok harus diisi';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _beratController,
              label: 'Berat (opsional)',
              hint: '0',
              icon: Icons.scale,
              keyboardType: TextInputType.number,
              suffix: Text(
                'gram',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildSubmitButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Foto Produk'),
        const SizedBox(height: 4),
        Text(
          'Maksimal 3 foto produk',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 12),

        // Add Image Button
        if (_totalImages < 3)
          GestureDetector(
            onTap: _showImageSourceDialog,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2F80ED).withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_photo_alternate,
                    size: 32,
                    color: Color(0xFF2F80ED),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Tap untuk menambah foto ($_totalImages/3)',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF2F80ED),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Images Preview
        if (_totalImages > 0) ...[
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: _totalImages,
            itemBuilder: (context, index) {
              final isExisting = index < _existingImageUrls.length;

              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: isExisting
                            ? NetworkImage(_existingImageUrls[index])
                            : FileImage(_newImages[index - _existingImageUrls.length]) as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        if (isExisting) {
                          _removeExistingImage(index);
                        } else {
                          _removeNewImage(index - _existingImageUrls.length);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (index == 0)
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2F80ED),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Utama',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (isExisting)
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Lama',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  if (!isExisting)
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Baru',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF2F80ED),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Widget? prefix,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: const Color(0xFF1F2937),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF2F80ED)),
        prefix: prefix,
        suffix: suffix,
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: const Color(0xFF6B7280),
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: const Color(0xFF9CA3AF),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF2F80ED),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFEF4444),
            width: 2,
          ),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildCategorySelector() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Kategori',
        prefixIcon: const Icon(Icons.category, color: Color(0xFF2F80ED)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF2F80ED),
            width: 2,
          ),
        ),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(
            category,
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedCategory = value);
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Pilih kategori produk';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2F80ED),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Update Produk',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

