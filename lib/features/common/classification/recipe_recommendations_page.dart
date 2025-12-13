// ============================================================================
// ASISTEN SAYUR AI - AI-Powered Vegetable Assistant
// ============================================================================
// Fitur:
// 1. ✅ Rekomendasi Resep (Current)
// 2. 🔜 Nutrisi & Kesehatan
// 3. 🔜 Chatbot Konsultasi
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wargago/core/services/gemini_service.dart';
import 'package:wargago/core/services/recipe_web_service.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:remixicon/remixicon.dart';
import 'package:url_launcher/url_launcher.dart';

class VegetableAIAssistantPage extends StatefulWidget {
  final String vegetableName;
  final String? imagePath; // Tambahkan parameter foto (optional)

  const VegetableAIAssistantPage({
    super.key,
    required this.vegetableName,
    this.imagePath, // Optional - jika null pakai text-only
  });

  @override
  State<VegetableAIAssistantPage> createState() => _VegetableAIAssistantPageState();
}

class _VegetableAIAssistantPageState extends State<VegetableAIAssistantPage> with SingleTickerProviderStateMixin {
  final GeminiService _geminiService = GeminiService();
  final RecipeWebService _webService = RecipeWebService();
  VegetableRecipeResponse? _response;
  List<ExternalRecipe> _externalRecipes = [];
  bool _isLoading = true;
  bool _isLoadingExternal = true;
  String? _errorMessage;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRecipes();
    _loadExternalRecipes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final VegetableRecipeResponse response;

      // Jika ada foto, gunakan Gemini Vision
      // Jika tidak ada foto, gunakan text-only
      if (widget.imagePath != null && widget.imagePath!.isNotEmpty) {
        response = await _geminiService.getRecipeRecommendationsFromPhoto(
          imagePath: widget.imagePath!,
          vegetableName: widget.vegetableName,
          recipeCount: 3,
        );
      } else {
        response = await _geminiService.getRecipeRecommendations(
          vegetableName: widget.vegetableName,
          recipeCount: 3,
        );
      }

      if (mounted) {
        setState(() {
          _response = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadExternalRecipes() async {
    setState(() {
      _isLoadingExternal = true;
    });

    try {
      final recipes = await _webService.getAllRecipes(widget.vegetableName);

      if (mounted) {
        setState(() {
          _externalRecipes = recipes;
          _isLoadingExternal = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingExternal = false;
        });
      }
    }
  }

  Future<void> _openExternalUrl(String url) async {
    try {
      if (kDebugMode) {
        print('🔗 Attempting to open URL: $url');
      }

      final uri = Uri.parse(url);

      if (kDebugMode) {
        print('📍 Parsed URI: $uri');
        print('🔍 Checking if can launch URL...');
      }

      if (await canLaunchUrl(uri)) {
        if (kDebugMode) {
          print('✅ URL can be launched, opening...');
        }

        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (kDebugMode) {
          print('📱 Launch result: $launched');
        }

        if (!launched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal membuka browser. Coba lagi.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (kDebugMode) {
          print('❌ URL cannot be launched!');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tidak dapat membuka link: $url'),
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error opening URL: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Header Section
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          MingCuteIcons.mgc_ai_fill,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Asisten Sayur AI',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                widget.vegetableName,
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tab Bar
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.white,
                      indicatorWeight: 3,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: const [
                        Tab(
                          icon: Icon(Remix.restaurant_line, size: 20),
                          text: 'Resep',
                        ),
                        Tab(
                          icon: Icon(Remix.heart_pulse_line, size: 20),
                          text: 'Nutrisi',
                        ),
                        Tab(
                          icon: Icon(Remix.chat_smile_3_line, size: 20),
                          text: 'Konsultasi',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Resep (Current Feature)
                _buildRecipeTab(),
                // Tab 2: Nutrisi (Coming Soon)
                _buildComingSoonTab(
                  icon: Remix.heart_pulse_line,
                  title: 'Nutrisi & Kesehatan',
                  description: 'Informasi nutrisi lengkap dan manfaat kesehatan dari sayuran',
                ),
                // Tab 3: Chatbot (Coming Soon)
                _buildComingSoonTab(
                  icon: Remix.chat_smile_3_line,
                  title: 'Chatbot Konsultasi',
                  description: 'Tanya jawab seputar sayuran, resep, dan tips memasak',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeTab() {
    if (_isLoading) {
      return _buildLoadingState();
    }
    if (_errorMessage != null) {
      return _buildErrorState();
    }
    return _buildRecipeList();
  }

  Widget _buildComingSoonTab({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Remix.time_line, size: 16, color: Colors.orange),
                  const SizedBox(width: 6),
                  Text(
                    'Segera Hadir',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Icon(
                  MingCuteIcons.mgc_ai_fill,
                  size: 36,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'AI sedang menganalisis...',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mencari resep terbaik untuk ${widget.vegetableName}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Remix.information_line,
                        size: 16,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Proses bisa memakan waktu',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sistem akan otomatis mencoba ulang jika server sibuk',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.blue[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Remix.sparkling_line,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Powered by Gemini AI',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    // Check if it's a server overload error
    final errorText = _errorMessage?.toLowerCase() ?? '';
    final isServerBusy = errorText.contains('503') ||
                        errorText.contains('overloaded') ||
                        errorText.contains('unavailable') ||
                        errorText.contains('sibuk');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isServerBusy
                    ? Colors.orange.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isServerBusy ? Remix.time_line : Remix.emotion_sad_line,
                size: 64,
                color: isServerBusy ? Colors.orange[400] : Colors.red[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isServerBusy
                  ? 'Server Sedang Sibuk'
                  : 'Oops! Terjadi Kesalahan',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            if (isServerBusy) ...[
              Text(
                'Server Gemini AI sedang mengalami beban tinggi.\nSistem sudah mencoba beberapa kali tetapi masih gagal.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Remix.lightbulb_line,
                          size: 16,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Saran:',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Tunggu 30-60 detik\n• Coba lagi dengan tombol di bawah\n• Atau coba lagi nanti',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.blue[600],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ] else ...[
              Text(
                _errorMessage ?? 'Tidak dapat memuat resep',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadRecipes,
              icon: const Icon(Icons.refresh),
              label: Text(
                'Coba Lagi',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isServerBusy
                    ? Colors.orange
                    : Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeList() {
    if (_response == null || !_response!.hasRecipes) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Remix.restaurant_line,
                  size: 64,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Tidak ada resep ditemukan',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Coba lagi dengan sayur yang berbeda',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor.withValues(alpha: 0.1),
                Theme.of(context).primaryColor.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  MingCuteIcons.mgc_ai_fill,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ditemukan ${_response!.recipes.length} resep',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      'Rekomendasi khusus untuk ${widget.vegetableName}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Section 1: AI Generated Recipes
        _buildSectionHeader(
          icon: MingCuteIcons.mgc_ai_fill,
          title: 'Rekomendasi AI',
          subtitle: 'Disesuaikan dengan foto sayuran Anda',
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 12),
        ..._response!.recipes.asMap().entries.map((entry) {
          final index = entry.key;
          final recipe = entry.value;
          return _buildAIRecipeCard(recipe, index);
        }),

        // Section 2: Verified from Web
        if (_externalRecipes.isNotEmpty || _isLoadingExternal) ...[
          const SizedBox(height: 24),
          _buildSectionHeader(
            icon: Remix.checkbox_circle_fill,
            title: 'Resep Verified',
            subtitle: 'Dari sumber terpercaya',
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          if (_isLoadingExternal)
            _buildLoadingExternalCard()
          else if (_externalRecipes.isEmpty)
            _buildNoExternalRecipesCard()
          else
            ..._externalRecipes.map((recipe) => _buildExternalRecipeCard(recipe)),
        ],

        const SizedBox(height: 80), // Extra space for bottom
      ],
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIRecipeCard(RecipeRecommendation recipe, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showRecipeDetail(recipe),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      MingCuteIcons.mgc_ai_fill,
                      size: 14,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'AI Generated',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Number badge
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Recipe name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.name,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        if (recipe.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            recipe.description,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Info chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    icon: Remix.timer_line,
                    label: recipe.cookingTime,
                    color: Colors.blue,
                  ),
                  _buildInfoChip(
                    icon: Remix.group_line,
                    label: recipe.servings,
                    color: Colors.green,
                  ),
                  _buildInfoChip(
                    icon: Remix.star_line,
                    label: recipe.difficulty,
                    color: _getDifficultyColor(recipe.difficulty),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Preview info
              Row(
                children: [
                  Icon(Remix.restaurant_line, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    '${recipe.ingredients.length} bahan',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Remix.list_check, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    '${recipe.steps.length} langkah',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // View button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _showRecipeDetail(recipe),
                  icon: const Icon(Remix.arrow_right_s_line, size: 20),
                  label: Text(
                    'Lihat Detail',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExternalRecipeCard(ExternalRecipe recipe) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _openExternalUrl(recipe.url),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Verified badge icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Remix.checkbox_circle_fill,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Recipe info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            recipe.source,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• Tap untuk buka',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Remix.external_link_line,
                size: 20,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingExternalCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              'Mencari resep dari website terpercaya...',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoExternalRecipesCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Remix.information_line, size: 20, color: Colors.grey[400]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tidak ada resep verified ditemukan untuk sayuran ini',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'mudah':
        return Colors.green;
      case 'sedang':
        return Colors.orange;
      case 'sulit':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showRecipeDetail(RecipeRecommendation recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RecipeDetailSheet(recipe: recipe),
    );
  }
}

class _RecipeDetailSheet extends StatelessWidget {
  final RecipeRecommendation recipe;

  const _RecipeDetailSheet({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  children: [
                    // Title
                    Text(
                      recipe.name,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    if (recipe.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        recipe.description,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    // Info
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildInfoChip(
                          icon: Remix.timer_line,
                          label: recipe.cookingTime,
                          color: Colors.blue,
                        ),
                        _buildInfoChip(
                          icon: Remix.group_line,
                          label: recipe.servings,
                          color: Colors.green,
                        ),
                        _buildInfoChip(
                          icon: Remix.star_line,
                          label: recipe.difficulty,
                          color: _getDifficultyColor(recipe.difficulty),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Bahan-bahan
                    _buildSectionTitle('Bahan-bahan', Remix.restaurant_line),
                    const SizedBox(height: 12),
                    ...recipe.ingredients.map((ingredient) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              ingredient,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 24),
                    // Langkah-langkah
                    _buildSectionTitle('Langkah-langkah', Remix.list_check),
                    const SizedBox(height: 12),
                    ...recipe.steps.asMap().entries.map((entry) {
                      final index = entry.key;
                      final step = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  step,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    // Tips
                    if (recipe.tips.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildSectionTitle('Tips & Trik', Remix.lightbulb_line),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.amber[200]!,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: recipe.tips.map((tip) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Remix.checkbox_circle_fill,
                                  size: 16,
                                  color: Colors.amber[700],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    tip,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'mudah':
        return Colors.green;
      case 'sedang':
        return Colors.orange;
      case 'sulit':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

