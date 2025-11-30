import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wargago/core/constants/app_routes.dart';
import 'widgets/onboarding_constants.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _accentColor = OnboardingColors.accent;

  static final List<_OnboardingData> _slides = [
    const _OnboardingData(
      headlinePrefix: 'Selamat Datang di',
      headlineAccent: 'WargaGO',
      description:
          'Platform digital untuk mempermudah komunikasi dan kolaborasi dalam komunitas Anda.',
      assetPath: 'assets/illustrations/onboarding slide 1.jpg',
    ),
    const _OnboardingData(
      headlinePrefix: 'Semua dalam Satu',
      headlineAccent: 'Aplikasi',
      description:
          'Akses informasi, pengumuman, dan berbagai layanan komunitas kapan saja, di mana saja.',
      assetPath: 'assets/illustrations/IMG00012.jpg',
    ),
    const _OnboardingData(
      headlinePrefix: 'Tetap',
      headlineAccent: 'Terhubung',
      description:
          'Dapatkan update terbaru dan tetap terhubung dengan komunitas Anda setiap saat.',
      assetPath: 'assets/illustrations/1.jpg',
    ),
  ];


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleNext() {
    final isLast = _currentPage == _slides.length - 1;
    if (isLast) {
      context.go(AppRoutes.preAuth);
      return;
    }
    _pageController.nextPage(
      duration: OnboardingDurations.pageTransition,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [
          // PageView dengan fullscreen background
          PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (value) => setState(() => _currentPage = value),
            itemBuilder: (context, index) {
              final slide = _slides[index];
              final isLast = index == _slides.length - 1;

              return _OnboardingSlide(
                key: ValueKey(index),
                data: slide,
                accentColor: _accentColor,
                isLast: isLast,
                onNextPressed: _handleNext,
                pageController: _pageController,
                pageIndex: index,
              );
            },
          ),

          // Header dengan logo dan close button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: OnboardingSpacing.lg,
                  vertical: OnboardingSpacing.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo dan nama app
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/icons/icon.png',
                            height: 24,
                            width: 24,
                            errorBuilder: (_, __, ___) =>
                                Icon(Icons.fingerprint, color: _accentColor, size: 24),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'WargaGO',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Close button
                    IconButton(
                      onPressed: () => context.go(AppRoutes.preAuth),
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.3),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Page indicators di bawah
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(OnboardingSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, (index) {
                    return AnimatedContainer(
                      duration: OnboardingDurations.progress,
                      curve: Curves.easeInOutCubic,
                      width: _currentPage == index ? 32 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide extends StatefulWidget {
  const _OnboardingSlide({
    super.key,
    required this.data,
    required this.accentColor,
    required this.isLast,
    required this.onNextPressed,
    required this.pageController,
    required this.pageIndex,
  });

  final _OnboardingData data;
  final Color accentColor;
  final bool isLast;
  final VoidCallback onNextPressed;
  final PageController pageController;
  final int pageIndex;

  @override
  State<_OnboardingSlide> createState() => _OnboardingSlideState();
}

class _OnboardingSlideState extends State<_OnboardingSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: OnboardingDurations.slideEntrance,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutExpo),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Auto start animation
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _animController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image fullscreen
        Positioned.fill(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Image.asset(
              widget.data.assetPath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                // Fallback gradient background jika gambar tidak ada
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.accentColor,
                        widget.accentColor.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 120,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Gradient overlay untuk readability teks
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.5),
                  Colors.black.withValues(alpha: 0.8),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // Content di bawah
        Positioned(
          bottom: 80, // Space untuk page indicators
          left: 0,
          right: 0,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: OnboardingSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Headline dengan animasi
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${widget.data.headlinePrefix} ',
                              style: const TextStyle(
                                fontSize: 28,
                                height: 1.2,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            TextSpan(
                              text: widget.data.headlineAccent,
                              style: TextStyle(
                                fontSize: 28,
                                height: 1.2,
                                fontWeight: FontWeight.w700,
                                color: widget.accentColor,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: OnboardingSpacing.md),

                  // Description dengan animasi
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _animController,
                      curve: const Interval(0.3, 0.9, curve: Curves.easeOut),
                    ),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _animController,
                          curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic),
                        ),
                      ),
                      child: Text(
                        widget.data.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: Colors.white.withValues(alpha: 0.9),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),

                  // Tombol "Mulai" hanya di slide terakhir
                  if (widget.isLast) ...[
                    const SizedBox(height: OnboardingSpacing.xl),
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _animController,
                        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: widget.onNextPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.accentColor,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: widget.accentColor.withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Mulai Sekarang',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.headlinePrefix,
    required this.headlineAccent,
    required this.description,
    required this.assetPath,
  });

  final String headlinePrefix;
  final String headlineAccent;
  final String description;
  final String assetPath;
}
