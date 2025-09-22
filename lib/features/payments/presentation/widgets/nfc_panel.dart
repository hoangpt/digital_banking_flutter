import 'package:flutter/material.dart';

class NfcPanel extends StatelessWidget {
  final VoidCallback onSimulateTap;
  const NfcPanel({super.key, required this.onSimulateTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.nfc,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'NFC Payment',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap your phone to a NFC-enabled payment terminal',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onSimulateTap,
              icon: const Icon(Icons.tap_and_play),
              label: const Text('Simulate NFC Tap'),
              style: FilledButton.styleFrom(minimumSize: const Size(200, 50)),
            ),
            const SizedBox(height: 12),
            Text(
              'Demo: Coffee Shop - \$25.50',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
