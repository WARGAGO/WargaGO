import 'package:flutter/material.dart';

import 'package:jawara/features/pre_auth/pre_auth_page.dart';
import 'widgets/onboarding_constants.dart';
import 'widgets/onboarding_widgets.dart';

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
      headlinePrefix: 'Selamat Datang di App',
      headlineAccent: 'Jawara',
      description:
          'Halo, Admin! Selamat datang di Jawara - mari mulai mengelola data dengan cerdas.',
      assetPath: 'assets/illustrations/onboarding_welcome.png',
    ),
    const _OnboardingData(
      headlinePrefix: 'Kelola Data dengan Lebih',
      headlineAccent: 'Mudah',
      description:
          'Pantau, ubah, dan kelola informasi langsung dari satu dashboard efisien.',
      assetPath: 'assets/illustrations/onboarding_manage.png',
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
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PreAuthPage()),
      );
      return;
    }
    _pageController.nextPage(
      duration: OnboardingDurations.pageTransition,
      curve: Curves.easeInOutCubic,
    );
  }

  // Framer-like custom easing functions
  double _customEase(double t) {
    // Ensure the input for transform is within [0,1] to avoid assertion
    final clamped = t.clamp(0.0, 1.0);
    return Curves.easeOutQuart.transform(clamped);
  }

  double _springEase(double t) {
    // Clamp to avoid invalid input to curve transform
    final clamped = t.clamp(0.0, 1.0);
    return Curves.elasticOut.transform(clamped);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: OnboardingSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: OnboardingSpacing.md),
              OnboardingBrandHeader(
                currentIndex: _currentPage,
                total: _slides.length,
                accentColor: _accentColor,
              ),
              const SizedBox(height: OnboardingSpacing.lg),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (value) => setState(() => _currentPage = value),
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    final isLast = index == _slides.length - 1;
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double pageOffset = 0.0;
                        if (_pageController.position.haveDimensions) {
                          pageOffset = (_pageController.page ?? 0) - index;
                        }

                        // Framer-like smooth animations with custom curves
                        final double progress = (-pageOffset).clamp(-1.0, 1.0);

                        // Advanced opacity with custom easing
                        final double rawOpacity = (1 - pageOffset.abs() * 0.5);
                        final double opacity = rawOpacity.clamp(0.0, 1.0);
                        final easedOpacity = _customEase(opacity);

                        // Scale with spring-like effect
                        final double rawScale = 1.0 - (pageOffset.abs() * 0.2);
                        final double clampedScale = rawScale.clamp(0.8, 1.0);
                        final easedScale = _springEase(clampedScale);

                        // 3D rotation with perspective
                        final double rotation = progress * 0.15; // More dramatic
                        final double rotationY = progress * 0.4;

                        // Parallax slide with ease
                        final double slideX = pageOffset * 120;
                        final double slideY = pageOffset.abs() * 20;

                        return Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001) // perspective
                            ..rotateZ(rotation * 0.05) // Slight Z rotation
                            ..rotateY(rotationY)
                            ..rotateX(progress * 0.05) // Slight X tilt
                            ..setTranslationRaw(slideX, slideY, 0.0),
                          alignment: Alignment.center,
                          child: Transform.scale(
                            scale: easedScale,
                            child: Opacity(
                              opacity: easedOpacity,
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: _OnboardingSlide(
                        key: ValueKey(index),
                        data: slide,
                        accentColor: _accentColor,
                        isLast: isLast,
                        onNextPressed: _handleNext,
                        pageController: _pageController,
                        pageIndex: index,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutExpo),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.elasticOut,
      ),
    );

    // Delay start for smoother entrance
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
    return AnimatedBuilder(
      animation: widget.pageController,
      builder: (context, child) {
        double parallaxOffset = 0.0;
        if (widget.pageController.position.haveDimensions) {
          final pageOffset = (widget.pageController.page ?? 0) - widget.pageIndex;
          parallaxOffset = pageOffset * 30;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animated Headline
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: OnboardingHeadline(
                  prefix: widget.data.headlinePrefix,
                  accent: widget.data.headlineAccent,
                  accentColor: widget.accentColor,
                ),
              ),
            ),
            const SizedBox(height: OnboardingSpacing.md),

            // Animated Description
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _animController,
                curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
              ),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _animController,
                    curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
                  ),
                ),
                child: const Text(
                  // ...existing code... replaced for style consistency
                  '',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: OnboardingColors.textSecondary,
                  ),
                ),
              ),
            ),
            // Replace above with real description text
            Text(
              widget.data.description,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: OnboardingColors.textSecondary,
              ),
            ),
            const SizedBox(height: OnboardingSpacing.lg),

            // Animated Button with Micro-interactions
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _animController,
                curve: const Interval(0.5, 1.0, curve: Curves.easeOutExpo),
              ),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _animController,
                    curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
                  ),
                ),
                child: OnboardingPrimaryButton(
                  color: widget.accentColor,
                  text: widget.isLast ? 'Mulai' : 'Next',
                  onPressed: widget.onNextPressed,
                ),
              ),
            ),
            const SizedBox(height: OnboardingSpacing.lg),

            // Animated Illustration with Parallax
            Expanded(
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animController,
                  curve: const Interval(0.3, 0.9, curve: Curves.easeOut),
                ),
                child: Transform.translate(
                  offset: Offset(parallaxOffset, 0),
                  child: Transform.scale(
                    scale: 1.0,
                    child: OnboardingIllustration(
                      assetPath: widget.data.assetPath,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
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

