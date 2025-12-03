// ============================================================================
// ADD/EDIT PRODUCT PAGE
// ============================================================================
// Halaman untuk menambah atau mengedit produk marketplace
// dengan support upload multiple images ke cloud storage
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/marketplace_provider.dart';
import '../../../../core/models/marketplace_product_model.dart';

class AddEditProductPage extends StatefulWidget {
  final MarketplaceProductModel? product; // null = add mode, not null = edit mode

  const AddEditProductPage({super.key, this.product});

  @override
  State<AddEditProductPage> createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends State<AddEditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _unitController = TextEditingController();

  final List<File> _newImages = [];
  final List<String> _existingImageUrls = [];
  final List<String> _imagesToRemove = [];

  String _selectedCategory = 'Sayuran';
  final List<String> _categoryOptions = [
    'Sayuran',
    'Buah',
    'Sembako',
    'Bumbu',
    'Lainnya',
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _initializeEditMode();
    } else {
      _unitController.text = 'kg';
    }
  }

  void _initializeEditMode() {
    final product = widget.product!;
    _nameController.text = product.productName;
    _descriptionController.text = product.description;
    _priceController.text = product.price.toString();
    _stockController.text = product.stock.toString();
    _unitController.text = product.unit;
    _selectedCategory = product.category;
    _existingImageUrls.addAll(product.imageUrls);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        for (var file in pickedFiles) {
          if (_newImages.length + _existingImageUrls.length - _imagesToRemove.length < 5) {
            _newImages.add(File(file.path));
          }
        }
      });
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  void _markExistingImageForRemoval(String url) {
    setState(() {
      if (_imagesToRemove.contains(url)) {
        _imagesToRemove.remove(url);
      } else {
        _imagesToRemove.add(url);
      }
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final totalImages = _newImages.length + _existingImageUrls.length - _imagesToRemove.length;

    if (totalImages == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal 1 gambar produk diperlukan')),
      );
      return;
    }

    if (totalImages > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maksimal 5 gambar produk')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final provider = Provider.of<MarketplaceProvider>(context, listen: false);

    bool success;
    if (widget.product == null) {
      // Add mode
      success = await provider.createProduct(
        productName: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        category: _selectedCategory,
        images: _newImages,
        unit: _unitController.text.trim(),
      );
    } else {
      // Edit mode
      success = await provider.updateProduct(
        productId: widget.product!.id,
        productName: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        category: _selectedCategory,
        newImages: _newImages.isEmpty ? null : _newImages,
        removeImageUrls: _imagesToRemove.isEmpty ? null : _imagesToRemove,
        unit: _unitController.text.trim(),
      );
    }

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product == null
                ? 'Produk berhasil ditambahkan'
                : 'Produk berhasil diupdate'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Terjadi kesalahan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Produk' : 'Tambah Produk'),
        backgroundColor: const Color(0xFF2F80ED),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Images Section
                    _buildImagesSection(),
                    const SizedBox(height: 24),

                    // Product Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Produk *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama produk tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi *',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Deskripsi tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Kategori *',
                        border: OutlineInputBorder(),
                      ),
                      items: _categoryOptions.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Price & Stock
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                              labelText: 'Harga *',
                              border: OutlineInputBorder(),
                              prefixText: 'Rp ',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Harga wajib diisi';
                              }
                              final price = double.tryParse(value);
                              if (price == null || price <= 0) {
                                return 'Harga tidak valid';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _stockController,
                            decoration: const InputDecoration(
                              labelText: 'Stok *',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Stok wajib diisi';
                              }
                              final stock = int.tryParse(value);
                              if (stock == null || stock < 0) {
                                return 'Stok tidak valid';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Unit
                    TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(
                        labelText: 'Satuan *',
                        border: OutlineInputBorder(),
                        hintText: 'kg, pcs, ikat, dll',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Satuan tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F80ED),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          isEditMode ? 'Update Produk' : 'Tambah Produk',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Gambar Produk *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Tambah Foto'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Maksimal 5 gambar',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 12),
        _buildImageGrid(),
      ],
    );
  }

  Widget _buildImageGrid() {
    final displayImages = <Widget>[];

    // Existing images (from edit mode)
    for (var url in _existingImageUrls) {
      final isMarkedForRemoval = _imagesToRemove.contains(url);
      displayImages.add(
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isMarkedForRemoval ? Colors.red : Colors.grey,
                  width: 2,
                ),
                image: DecorationImage(
                  image: NetworkImage(url),
                  fit: BoxFit.cover,
                  opacity: isMarkedForRemoval ? 0.5 : 1.0,
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _markExistingImageForRemoval(url),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isMarkedForRemoval ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isMarkedForRemoval ? Icons.refresh : Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // New images (from add/edit mode)
    for (int i = 0; i < _newImages.length; i++) {
      displayImages.add(
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green, width: 2),
                image: DecorationImage(
                  image: FileImage(_newImages[i]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removeNewImage(i),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            const Positioned(
              bottom: 4,
              left: 4,
              child: Chip(
                label: Text(
                  'Baru',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
                backgroundColor: Colors.green,
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      );
    }

    if (displayImages.isEmpty) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image, size: 40, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Belum ada gambar',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: displayImages,
    );
  }
}

