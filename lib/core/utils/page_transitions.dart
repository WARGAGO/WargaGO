import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 🎨 Custom Page Transitions untuk aplikasi
/// Memberikan animasi smooth dan menarik saat berpindah halaman

class PageTransitions {
  /// Fade Transition - Smooth fade in/out
  static CustomTransitionPage fadeTransition({
    required Widget child,
    required LocalKey key,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
    );
  }

  /// Slide from Right Transition - Seperti push native iOS
  static CustomTransitionPage slideFromRight({
    required Widget child,
    required LocalKey key,
    Duration duration = const Duration(milliseconds: 350),
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        );

        return SlideTransition(
          position: tween.animate(curvedAnimation),
          child: child,
        );
      },
    );
  }

  /// Slide from Bottom Transition - Seperti modal
  static CustomTransitionPage slideFromBottom({
    required Widget child,
    required LocalKey key,
    Duration duration = const Duration(milliseconds: 350),
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return SlideTransition(
          position: tween.animate(curvedAnimation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  /// Scale Transition - Zoom in effect
  static CustomTransitionPage scaleTransition({
    required Widget child,
    required LocalKey key,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutQuart,
        );

        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.9,
            end: 1.0,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Slide and Fade Transition - Kombinasi slide + fade
  static CustomTransitionPage slideAndFade({
    required Widget child,
    required LocalKey key,
    Duration duration = const Duration(milliseconds: 350),
    Offset beginOffset = const Offset(0.3, 0.0),
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Rotate and Scale Transition - Efek putar + zoom
  static CustomTransitionPage rotateScale({
    required Widget child,
    required LocalKey key,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutQuart,
        );

        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(curvedAnimation),
          child: RotationTransition(
            turns: Tween<double>(
              begin: -0.05,
              end: 0.0,
            ).animate(curvedAnimation),
            child: FadeTransition(
              opacity: curvedAnimation,
              child: child,
            ),
          ),
        );
      },
    );
  }

  /// Shared Axis Transition - Material Design 3 style
  static CustomTransitionPage sharedAxis({
    required Widget child,
    required LocalKey key,
    Duration duration = const Duration(milliseconds: 300),
    bool isForward = true,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final begin = isForward ? 30.0 : -30.0;
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(begin / MediaQuery.of(context).size.width, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  /// No Transition - Instant tanpa animasi
  static CustomTransitionPage noTransition({
    required Widget child,
    required LocalKey key,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 1),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }

  /// Slide from Left Transition - Untuk back navigation atau secondary screens
  static CustomTransitionPage slideFromLeft({
    required Widget child,
    required LocalKey key,
    Duration duration = const Duration(milliseconds: 350),
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        );

        return SlideTransition(
          position: tween.animate(curvedAnimation),
          child: child,
        );
      },
    );
  }

  /// Slide from Top Transition - Untuk notifikasi atau overlay screens
  static CustomTransitionPage slideFromTop({
    required Widget child,
    required LocalKey key,
    Duration duration = const Duration(milliseconds: 350),
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, -1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return SlideTransition(
          position: tween.animate(curvedAnimation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  /// Bounce Transition - Playful bounce effect
  static CustomTransitionPage bounceTransition({
    required Widget child,
    required LocalKey key,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.elasticOut,
        );

        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.7,
            end: 1.0,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeIn,
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }

  /// Flip Horizontal Transition - Card flip effect
  static CustomTransitionPage flipHorizontal({
    required Widget child,
    required LocalKey key,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        );

        return AnimatedBuilder(
          animation: curvedAnimation,
          builder: (context, child) {
            final angle = curvedAnimation.value * 3.14159; // π
            final transform = Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..rotateY(angle);

            return Transform(
              transform: transform,
              alignment: Alignment.center,
              child: child,
            );
          },
          child: child,
        );
      },
    );
  }

  /// Zoom and Rotate Transition - Dramatic entrance
  static CustomTransitionPage zoomRotate({
    required Widget child,
    required LocalKey key,
    Duration duration = const Duration(milliseconds: 450),
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutBack,
        );

        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.5,
            end: 1.0,
          ).animate(curvedAnimation),
          child: RotationTransition(
            turns: Tween<double>(
              begin: -0.2,
              end: 0.0,
            ).animate(curvedAnimation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
        );
      },
    );
  }

  /// Expand Transition - Seperti expanding dari center
  static CustomTransitionPage expandTransition({
    required Widget child,
    required LocalKey key,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutQuint,
        );

        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.3, 1.0),
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }
}

