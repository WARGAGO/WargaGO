import 'package:flutter/material.dart';

class KYCStep3AktePage extends StatelessWidget {
  final Function(Map<String, dynamic>?) onNext;
  final VoidCallback onSkip;

  const KYCStep3AktePage({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Step 3: Upload Akte Kelahiran (Optional)'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onSkip,
            child: const Text('Lewati'),
          ),
        ],
      ),
    );
  }
}
