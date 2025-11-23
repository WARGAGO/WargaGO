// ============================================================================
// ONBOARDING REUSABLE WIDGETS
// ============================================================================
// Widget kecil yang reusable untuk Onboarding
// ============================================================================

import 'package:flutter/material.dart';
import 'onboarding_constants.dart';

class OnboardingHeadline extends StatelessWidget {
  const OnboardingHeadline({
    super.key,
    required this.prefix,
    required this.accent,
    this.accentColor = OnboardingColors.accent,
  });

  final String prefix;
  final String accent;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$prefix ',
            style: const TextStyle(
              fontSize: 32,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: OnboardingColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          TextSpan(
            text: accent,
            style: TextStyle(
              fontSize: 32,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: accentColor,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPrimaryButton extends StatefulWidget {
  const OnboardingPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = OnboardingColors.accent,
  });

  final String text;
  final VoidCallback onPressed;
  final Color color;

  @override
  State<OnboardingPrimaryButton> createState() =>
      _OnboardingPrimaryButtonState();
}

class _OnboardingPrimaryButtonState extends State<OnboardingPrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _arrowController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _arrowController = AnimationController(
      duration: OnboardingDurations.arrow,
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _arrowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.95 : 1.0,
      duration: OnboardingDurations.micro,
      curve: Curves.easeInOut,
      child: SizedBox(
        height: 44,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.color,
            foregroundColor: Colors.white,
            elevation: _isPressed ? 0 : 2,
            shadowColor: widget.color.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(OnboardingRadius.sm),
            ),
          ),
          onPressed: widget.onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.text,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 8),
              AnimatedBuilder(
                animation: _arrowController,
                builder: (context, child) {
                  final offset =
                      Curves.easeInOut.transform(_arrowController.value) * 6 -
                      3;
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: child,
                  );
                },
                child: const Icon(Icons.arrow_forward_ios, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingBrandHeader extends StatelessWidget {
  const OnboardingBrandHeader({
    super.key,
    required this.currentIndex,
    required this.total,
    this.accentColor = OnboardingColors.accent,
  });

  final int currentIndex;
  final int total;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/icon.png',
              height: 20,
              width: 20,
              color: accentColor,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.fingerprint, color: accentColor, size: 20),
            ),
            const SizedBox(width: OnboardingSpacing.sm),
            Text(
              'Jawara',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: OnboardingSpacing.md),
        Row(
          children: List.generate(total, (index) {
            final isFilled = index <= currentIndex;
            return Expanded(
              child: AnimatedContainer(
                duration: OnboardingDurations.progress,
                curve: Curves.easeInOutCubic,
                height: 6,
                margin: EdgeInsets.only(left: index == 0 ? 0 : 12),
                decoration: BoxDecoration(
                  color: isFilled
                      ? accentColor
                      : OnboardingColors.progressTrack,
                  borderRadius: BorderRadius.circular(OnboardingRadius.lg),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class OnboardingIllustration extends StatelessWidget {
  const OnboardingIllustration({super.key, required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        return SizedBox(
          width: width,
          height: height,
          child: Align(
            alignment: Alignment.bottomRight,
            child: Image.asset(
              assetPath,
              width: width,
              height: height,
              fit: BoxFit.cover,
              alignment: Alignment.bottomRight,
              errorBuilder: (_, __, ___) {
                return SizedBox(
                  width: width,
                  height: height,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(OnboardingSpacing.lg),
                      child: Text(
                        'Place your illustration at:\n$assetPath',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF5C5C5C),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
