import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 🎨 Demo page untuk menampilkan semua jenis page transitions
/// Gunakan halaman ini untuk preview semua transisi yang tersedia
class TransitionDemoPage extends StatelessWidget {
  const TransitionDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎨 Page Transitions Demo'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Pilih transisi untuk melihat preview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildTransitionCard(
            context,
            title: 'Fade Transition',
            description: 'Smooth fade in/out effect',
            icon: Icons.blur_on,
            color: Colors.blue,
            route: '/demo/fade',
          ),
          _buildTransitionCard(
            context,
            title: 'Slide from Right',
            description: 'iOS native push style',
            icon: Icons.arrow_forward,
            color: Colors.green,
            route: '/demo/slide-right',
          ),
          _buildTransitionCard(
            context,
            title: 'Slide from Bottom',
            description: 'Modal sheet style',
            icon: Icons.arrow_upward,
            color: Colors.orange,
            route: '/demo/slide-bottom',
          ),
          _buildTransitionCard(
            context,
            title: 'Scale Transition',
            description: 'Zoom in effect',
            icon: Icons.zoom_in,
            color: Colors.purple,
            route: '/demo/scale',
          ),
          _buildTransitionCard(
            context,
            title: 'Slide and Fade',
            description: 'Combined slide + fade',
            icon: Icons.blur_linear,
            color: Colors.teal,
            route: '/demo/slide-fade',
          ),
          _buildTransitionCard(
            context,
            title: 'Rotate Scale',
            description: '3D rotation + zoom',
            icon: Icons.rotate_right,
            color: Colors.red,
            route: '/demo/rotate-scale',
          ),
          _buildTransitionCard(
            context,
            title: 'Shared Axis',
            description: 'Material Design 3 style',
            icon: Icons.swap_horiz,
            color: Colors.indigo,
            route: '/demo/shared-axis',
          ),
          _buildTransitionCard(
            context,
            title: 'Slide from Left',
            description: 'Back navigation feel',
            icon: Icons.arrow_back,
            color: Colors.cyan,
            route: '/demo/slide-left',
          ),
          _buildTransitionCard(
            context,
            title: 'Slide from Top',
            description: 'Notification overlay style',
            icon: Icons.arrow_downward,
            color: Colors.amber,
            route: '/demo/slide-top',
          ),
          _buildTransitionCard(
            context,
            title: 'Bounce Transition',
            description: 'Playful elastic bounce',
            icon: Icons.sports_basketball,
            color: Colors.pink,
            route: '/demo/bounce',
          ),
          _buildTransitionCard(
            context,
            title: 'Flip Horizontal',
            description: '3D card flip effect',
            icon: Icons.flip,
            color: Colors.deepOrange,
            route: '/demo/flip',
          ),
          _buildTransitionCard(
            context,
            title: 'Zoom Rotate',
            description: 'Dramatic entrance',
            icon: Icons.toys,
            color: Colors.deepPurple,
            route: '/demo/zoom-rotate',
          ),
          _buildTransitionCard(
            context,
            title: 'Expand Transition',
            description: 'Expand from center',
            icon: Icons.open_in_full,
            color: Colors.lime,
            route: '/demo/expand',
          ),
          _buildTransitionCard(
            context,
            title: 'No Transition',
            description: 'Instant (for camera)',
            icon: Icons.flash_on,
            color: Colors.grey,
            route: '/demo/no-transition',
          ),
        ],
      ),
    );
  }

  Widget _buildTransitionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Navigate dengan transition yang dipilih
          context.push(route);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sample destination page untuk melihat transisi kembali
class TransitionDemoDestination extends StatelessWidget {
  final String transitionName;
  final Color color;

  const TransitionDemoDestination({
    super.key,
    required this.transitionName,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color.withValues(alpha: 0.1),
      appBar: AppBar(
        title: Text(transitionName),
        centerTitle: true,
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 120,
              color: color,
            ),
            const SizedBox(height: 24),
            Text(
              'Transition berhasil!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              transitionName,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

