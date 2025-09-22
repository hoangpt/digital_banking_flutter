import 'package:flutter/material.dart';

class CardPanel extends StatelessWidget {
  final VoidCallback onSimulateTap;
  const CardPanel({super.key, required this.onSimulateTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card,
            size: 120,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Card Payment',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Pay with your credit or debit card',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: onSimulateTap,
            icon: const Icon(Icons.payment),
            label: const Text('Simulate Card Payment'),
            style: FilledButton.styleFrom(minimumSize: const Size(220, 50)),
          ),
          const SizedBox(height: 16),
          Text(
            'Demo: Online Store - \$150.00',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
