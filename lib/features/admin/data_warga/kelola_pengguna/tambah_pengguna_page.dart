import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TambahPenggunaPage extends StatefulWidget {
  const TambahPenggunaPage({super.key});

  @override
  State<TambahPenggunaPage> createState() => _TambahPenggunaPageState();
}

class _TambahPenggunaPageState extends State<TambahPenggunaPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _namaLengkapController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nomorHpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _konfirmasiPasswordController = TextEditingController();

  // Dropdown
  String? _selectedRole;

  // Password visibility
  bool _isPasswordVisible = false;
  bool _isKonfirmasiPasswordVisible = false;

  // List data untuk dropdown
  final List<String> _roleList = [
    'Admin',
    'Ketua RW',
    'Ketua RT',
    'Sekretaris',
    'Bendahara',
  ];

  @override
  void dispose() {
    _namaLengkapController.dispose();
    _emailController.dispose();
    _nomorHpController.dispose();
    _passwordController.dispose();
    _konfirmasiPasswordController.dispose();
    super.dispose();
  }

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _konfirmasiPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Password dan Konfirmasi Password tidak sama!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // TODO: Implement data submission logic
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Berhasil',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Akun pengguna berhasil ditambahkan.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(
                'OK',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF2988EA),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _namaLengkapController.clear();
    _emailController.clear();
    _nomorHpController.clear();
    _passwordController.clear();
    _konfirmasiPasswordController.clear();
    setState(() {
      _selectedRole = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F1F1F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tambah Akun Pengguna',
          style: GoogleFonts.poppins(
            color: const Color(0xFF1F1F1F),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama Lengkap
                    _buildTextField(
                      controller: _namaLengkapController,
                      label: 'Nama Lengkap',
                      hint: 'Masukkan nama lengkap',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Masukkan email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan Email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Nomor HP
                    _buildTextField(
                      controller: _nomorHpController,
                      label: 'Nomor HP',
                      hint: 'Masukkan nomor HP',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan Nomor HP';
                        }
                        if (value.length < 10) {
                          return 'Nomor HP minimal 10 digit';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password
                    _buildPasswordField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Masukkan password',
                      isVisible: _isPasswordVisible,
                      onToggleVisibility: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan Password';
                        }
                        if (value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Konfirmasi Password
                    _buildPasswordField(
                      controller: _konfirmasiPasswordController,
                      label: 'Konfirmasi Password',
                      hint: 'Masukkan konfirmasi password',
                      isVisible: _isKonfirmasiPasswordVisible,
                      onToggleVisibility: () {
                        setState(() {
                          _isKonfirmasiPasswordVisible = !_isKonfirmasiPasswordVisible;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan Konfirmasi Password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Role
                    _buildDropdownField(
                      label: 'Role',
                      hint: 'Pilih role',
                      value: _selectedRole,
                      items: _roleList,
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F1F1F),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
            ),
            prefixIcon: Icon(icon, color: const Color(0xFF6B7280), size: 20),
            filled: true,
            fillColor: const Color(0xFFF8F9FC),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8EAF2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8EAF2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2988EA), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
          validator: validator ?? (value) {
            if (value == null || value.isEmpty) {
              return 'Masukkan $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F1F1F),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
            ),
            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6B7280), size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: const Color(0xFF6B7280),
                size: 20,
              ),
              onPressed: onToggleVisibility,
            ),
            filled: true,
            fillColor: const Color(0xFFF8F9FC),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8EAF2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8EAF2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2988EA), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F1F1F),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                hint,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF9E9E9E),
                ),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF757575),
                size: 24,
              ),
              isExpanded: true,
              dropdownColor: Colors.white,
              menuMaxHeight: 300,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF1F1F1F),
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF1F1F1F),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        // Validation message
        if (value == null && _formKey.currentState?.validate() == false)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              'Pilih $label',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Tombol Reset
          Expanded(
            child: OutlinedButton(
              onPressed: _resetForm,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6B7280),
                side: const BorderSide(color: Color(0xFFE0E0E0)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Reset',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Tombol Simpan
          Expanded(
            child: ElevatedButton(
              onPressed: _submitData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2988EA),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Simpan',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

