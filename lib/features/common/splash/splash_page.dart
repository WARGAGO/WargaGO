import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:jawara/core/constants/app_routes.dart';

const _wordmarkText = 'Jawara';

const TextStyle _wordmarkStyle = TextStyle(
  fontSize: 36,
  letterSpacing: 1.15,
  fontFamily: 'Fendysa',
  fontWeight: FontWeight.w600,
  color: Color(0xFF2F80ED),
);

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  // TIMELINE (ms)
  // 0–650   : big bounce logo
  // 650–750 : hold 100ms
  // 750–1200: radial wipe (remove gray)
  // 1250-1650: "Jawara" appears & slides in from the right
  // 1550–1950: re-center as ROW -> logo to left, text to right
  // 1950–2300: (optional) swipe-up (disabled here; enable if you want)

  static const totalMs = 2300.0;
  static const _logoSize = 96.0;
  static const _spacing = 16.0;
  static const _entryOvershoot = 32.0;

  late final AnimationController c;

  // F1 - logo bounce
  late final Animation<double> logoScale; // strong bounce
  late final Animation<double> logoOpacity;
  late final Animation<double> logoTilt; // tiny settle tilt

  // F2 — gray removal (radial wipe)
  late final Animation<double> radialReveal;

  // F3 - text show + slide
  late final Animation<double> jawaraOpacity;
  late final Animation<double> jawaraScale;
  // 0 -> 1 normalized horizontal reveal
  late final Animation<double> jawaraSlide;

  // F4 - pair alignment (become a centered row)
  // 0 -> 1 normalized shift to the left
  late final Animation<double> logoSlide;

  // Layout metrics for positioning logo & text within the stack
  late final double _wordmarkWidth;
  late final double _wordmarkHeight;
  late final double _pairWidth;
  late final double _pairHeight;
  late final double _logoStartX;
  late final double _logoTop;
  late final double _textStartX;
  late final double _textEndX;
  late final double _textTop;

  // (Optional) exit
  // late final Animation<Offset> swipeUp;

  @override
  void initState() {
    super.initState();
    c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalMs.toInt()),
    );

    final textPainter = TextPainter(
      text: const TextSpan(text: _wordmarkText, style: _wordmarkStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    _wordmarkWidth = textPainter.width;
    _wordmarkHeight = textPainter.height;
    _pairWidth = _logoSize + _spacing + _wordmarkWidth;
    _pairHeight = math.max(_logoSize, _wordmarkHeight);
    _logoStartX = (_pairWidth - _logoSize) / 2;
    _logoTop = (_pairHeight - _logoSize) / 2;
    _textStartX = _pairWidth + _entryOvershoot; // start off-stage to the right
    _textEndX = _logoSize + _spacing;
    _textTop = (_pairHeight - _wordmarkHeight) / 2;

    // ===== F1: BIG bounce (visible bouncy) 0–650ms =====
    final f1 = CurvedAnimation(
      parent: c,
      curve: const Interval(0.0, 650 / totalMs), // 0..~0.283
    );

    // Overshoot -> undershoot -> rebound -> settle
    logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.60,
          end: 1.18,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.18,
          end: 0.92,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 22,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.92,
          end: 1.06,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 18,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.06,
          end: 1.00,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 20,
      ),
    ]).animate(f1);

    logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: c,
        curve: const Interval(0.0, 0.20, curve: Curves.easeOut),
      ),
    );

    logoTilt = Tween<double>(begin: -2 * math.pi / 180, end: 0).animate(
      CurvedAnimation(
        parent: c,
        curve: const Interval(0.15, 650 / totalMs, curve: Curves.easeOut),
      ),
    );

    // ===== F2: gray removal via radial wipe (starts 100ms after F1) 750–1200ms =====
    radialReveal = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: c,
        curve: Interval(
          750 / totalMs,
          1200 / totalMs,
          curve: Curves.fastOutSlowIn,
        ),
      ),
    );

    // ===== F3: text appear & slide in from right 1250-1950ms =====
    jawaraOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: c,
        curve: Interval(
          1250 / totalMs,
          1500 / totalMs,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
    jawaraScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: c,
        curve: Interval(
          1250 / totalMs,
          1650 / totalMs,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    // Normalized slide progress used to lerp absolute positions for the text.
    jawaraSlide = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: c,
        curve: Interval(
          1250 / totalMs,
          1950 / totalMs,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    // Logo waits a bit longer, then glides left so the pair becomes a row.
    logoSlide = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: c,
        curve: Interval(
          1550 / totalMs,
          1950 / totalMs,
          curve: Curves.easeInOutCubic,
        ),
      ),
    );

    // Optional: swipe up (disabled by default)
    // swipeUp = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1))
    //   .animate(CurvedAnimation(parent: c, curve: Interval(1950/totalMs, 1.0, curve: Curves.easeInOutCubic)));

    c.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
    });

    c.forward();
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final maxRadius =
        math.sqrt(size.width * size.width + size.height * size.height) / 2 + 24;

    return AnimatedBuilder(
      animation: c,
      builder: (_, __) {
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: Colors.white),

              // GRAY layer removed by expanding white circle from logo center
              CustomPaint(
                painter: _RadialWipePainter(
                  gray: const Color(0xFFF3F3F3),
                  center: Offset(size.width / 2, size.height / 2),
                  radius: radialReveal.value * maxRadius,
                ),
              ),

              // Content
              Center(
                child: SizedBox(
                  width: _pairWidth,
                  height: _pairHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: ui.lerpDouble(
                          _textStartX,
                          _textEndX,
                          jawaraSlide.value,
                        )!,
                        top: _textTop,
                        child: Opacity(
                          opacity: jawaraOpacity.value,
                          child: Transform.scale(
                            scale: jawaraScale.value,
                            child: const _JawaraWordmark(),
                          ),
                        ),
                      ),

                      // LOGO (on top)
                      Positioned(
                        left: ui.lerpDouble(_logoStartX, 0, logoSlide.value)!,
                        top: _logoTop,
                        child: FadeTransition(
                          opacity: logoOpacity,
                          child: Transform.rotate(
                            angle: logoTilt.value,
                            child: Transform.scale(
                              scale: logoScale.value,
                              child: Image.asset(
                                'assets/icons/icon.png',
                                width: _logoSize,
                                height: _logoSize,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback to fingerprint icon if image fails to load
                                  return Icon(
                                    Icons.fingerprint,
                                    size: _logoSize,
                                    color: const Color(0xFF2F80ED),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ), // If you want the exit, wrap above Center with SlideTransition(swipeUp)
            ],
          ),
        );
      },
    );
  }
}

/// Paints full gray and "removes" it with an expanding white circle from [center].
class _RadialWipePainter extends CustomPainter {
  final Color gray;
  final Offset center;
  final double radius;
  const _RadialWipePainter({
    required this.gray,
    required this.center,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final grayPaint = Paint()..color = gray;
    canvas.drawRect(rect, grayPaint);

    final holePaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius, holePaint);
  }

  @override
  bool shouldRepaint(covariant _RadialWipePainter old) =>
      old.radius != radius || old.gray != gray || old.center != center;
}

class _JawaraWordmark extends StatelessWidget {
  const _JawaraWordmark();

  @override
  Widget build(BuildContext context) {
    return const Text(_wordmarkText, style: _wordmarkStyle);
  }
}
