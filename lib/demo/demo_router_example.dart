// filepath: c:\Peyimpanan Pribadi\Data D\New folder (2)\Semester 5\PBL 2025\lib\demo\demo_router_example.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wargago/core/utils/page_transitions.dart';
import 'package:wargago/demo/transition_demo_page.dart';

/// 🎨 CONTOH PENGGUNAAN SEMUA PAGE TRANSITIONS
/// Copy & paste code ini ke router.dart Anda untuk implementasi

/*

// ========== DEMO ROUTES - PAGE TRANSITIONS SHOWCASE ==========

// Demo List Page
GoRoute(
  path: '/demo/transitions',
  name: 'transitionsDemo',
  pageBuilder: (context, state) => PageTransitions.fadeTransition(
    key: state.pageKey,
    child: const TransitionDemoPage(),
  ),
),

// 1. Fade Transition Demo
GoRoute(
  path: '/demo/fade',
  name: 'demoFade',
  pageBuilder: (context, state) => PageTransitions.fadeTransition(
    key: state.pageKey,
    child: const TransitionDemoDestination(
      transitionName: 'Fade Transition',
      color: Colors.blue,
    ),
  ),
),

// 2. Slide from Right Demo
GoRoute(
  path: '/demo/slide-right',
  name: 'demoSlideRight',
  pageBuilder: (context, state) => PageTransitions.slideFromRight(
    key: state.pageKey,
    child: const TransitionDemoDestination(
      transitionName: 'Slide from Right',
      color: Colors.green,
    ),
  ),
),

// 3. Slide from Bottom Demo
GoRoute(
  path: '/demo/slide-bottom',
  name: 'demoSlideBottom',
  pageBuilder: (context, state) => PageTransitions.slideFromBottom(
    key: state.pageKey,
    child: const TransitionDemoDestination(
      transitionName: 'Slide from Bottom',
      color: Colors.orange,
    ),
  ),
),

// 4. Scale Transition Demo
GoRoute(
  path: '/demo/scale',
  name: 'demoScale',
  pageBuilder: (context, state) => PageTransitions.scaleTransition(
    key: state.pageKey,
    child: const TransitionDemoDestination(
      transitionName: 'Scale Transition',
      color: Colors.purple,
    ),
  ),
),

// 5. Slide and Fade Demo
GoRoute(
  path: '/demo/slide-fade',
  name: 'demoSlideFade',
  pageBuilder: (context, state) => PageTransitions.slideAndFade(
    key: state.pageKey,
    child: const TransitionDemoDestination(
      transitionName: 'Slide and Fade',
      color: Colors.teal,
    ),
  ),
),

// 6. Rotate Scale Demo
GoRoute(
  path: '/demo/rotate-scale',
  name: 'demoRotateScale',
  pageBuilder: (context, state) => PageTransitions.rotateScale(
    key: state.pageKey,
    child: const TransitionDemoDestination(
      transitionName: 'Rotate Scale',
      color: Colors.red,
    ),
  ),
),

// 7. Shared Axis Demo
GoRoute(
  path: '/demo/shared-axis',
  name: 'demoSharedAxis',
  pageBuilder: (context, state) => PageTransitions.sharedAxis(
    key: state.pageKey,
    child: const TransitionDemoDestination(
      transitionName: 'Shared Axis',
      color: Colors.indigo,
    ),
  ),
),

// 8. Slide from Left Demo
GoRoute(
  path: '/demo/slide-left',
  name: 'demoSlideLeft',
  pageBuilder: (context, state) => PageTransitions.slideFromLeft(
    key: state.pageKey,
    child: const TransitionDemoDestination(
      transitionName: 'Slide from Left',
      color: Colors.cyan,
    ),
  ),
),

// 9. Slide from Top Demo
GoRoute(
  path: '/demo/slide-top',
  name: 'demoSlideTop',
  pageBuilder: (context, state) => PageTransitions.slideFromTop(
    key: state.pageKey,
    child: const TransitionDemoDestination(
      transitionName: 'Slide from Top',
      color: Colors.amber,
    ),
  ),
),

// 10. Bounce Transition Demo
GoRoute(
  path: '/demo/bounce',
  name: 'demoBounce',
  pageBuilder: (context, state) => PageTransitions.bounceTransition(
    key: state.pageKey,
    child: const TransitionDemoDestination(
      transitionName: 'Bounce Transition',
      color: Colors.pink,
    ),
  ),
),

// 11. Flip Horizontal Demo
GoRoute(
  path: '/demo/flip',
  name: 'demoFlip',
  pageBuilder: (context, state) => PageTransitions.flipHorizontal(
    key: state.pageKey,
    child: const TransitionDemoDestination(
      transitionName: 'Flip Horizontal',
      color: Colors.deepOrange,
    ),
  ),
),

// 12. Zoom Rotate Demo
GoRoute(
  path: '/demo/zoom-rotate',
  name: 'demoZoomRotate',
  pageBuilder: (context, state) => PageTransitions.zoomRotate(
    key: state.pageKey,
    child: const TransitionDemoDestination(
      transitionName: 'Zoom Rotate',
      color: Colors.deepPurple,
    ),
  ),
),

// 13. Expand Transition Demo
GoRoute(
  path: '/demo/expand',
  name: 'demoExpand',
  pageBuilder: (context, state) => PageTransitions.expandTransition(
    key: state.pageKey,
    child: const TransitionDemoDestination(
      transitionName: 'Expand Transition',
      color: Colors.lime,
    ),
  ),
),

// 14. No Transition Demo
GoRoute(
  path: '/demo/no-transition',
  name: 'demoNoTransition',
  pageBuilder: (context, state) => PageTransitions.noTransition(
    key: state.pageKey,
    child: const TransitionDemoDestination(
      transitionName: 'No Transition',
      color: Colors.grey,
    ),
  ),
),

*/

/// 📋 PANDUAN PENGGUNAAN:
///
/// 1. Import file page_transitions.dart:
///    import 'package:wargago/core/utils/page_transitions.dart';
///
/// 2. Gunakan pageBuilder instead of builder:
///    GoRoute(
///      path: '/your-route',
///      name: 'yourRoute',
///      pageBuilder: (context, state) => PageTransitions.fadeTransition(
///        key: state.pageKey,
///        child: const YourPage(),
///      ),
///    ),
///
/// 3. Pilih transisi yang sesuai dengan use case:
///    - Auth/Login → slideFromRight
///    - Modal/Dialog → slideFromBottom atau expandTransition
///    - Success → bounceTransition
///    - Back navigation → slideFromLeft
///    - Notification → slideFromTop
///    - Special effect → flipHorizontal, zoomRotate
///    - Dashboard → sharedAxis
///    - Camera/Scanner → noTransition
///
/// 4. Semua transisi support custom duration:
///    PageTransitions.fadeTransition(
///      key: state.pageKey,
///      child: const YourPage(),
///      duration: const Duration(milliseconds: 500), // Custom
///    )

class DemoRouterGuide {
  // This class is just documentation, no implementation needed
}

