import 'package:flutter/material.dart';
import 'dart:async';

class NfcPanel extends StatefulWidget {
  final VoidCallback onSimulateTap;
  const NfcPanel({super.key, required this.onSimulateTap});

  @override
  State<NfcPanel> createState() => _NfcPanelState();
}

class _NfcPanelState extends State<NfcPanel> with TickerProviderStateMixin {
  bool isPosMode = false;
  bool isNfcActive = false;
  bool isConnecting = false;
  bool isPaymentProcessing = false;
  String? paymentResult;

  late AnimationController _pulseController;
  late AnimationController _tapController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _tapAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _tapAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _tapController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  void _toggleNfc() {
    setState(() {
      isNfcActive = !isNfcActive;
      paymentResult = null;
    });

    if (isNfcActive) {
      _pulseController.repeat(reverse: true);
      // Simulate NFC activation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isPosMode
                ? 'NFC POS Terminal ready - Waiting for payment...'
                : 'NFC Payment ready - Tap to pay terminal...',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  Future<void> _simulateNfcPayment() async {
    if (!isNfcActive || isPaymentProcessing) return;

    setState(() {
      isConnecting = true;
      isPaymentProcessing = true;
      paymentResult = null;
    });

    // Stop pulse animation and start tap animation
    _pulseController.stop();
    await _tapController.forward();
    await _tapController.reverse();

    // Show connecting phase
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Connecting to receiver...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    // Simulate connection delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isConnecting = false;
    });

    // Show processing phase
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Processing payment...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Show success
    final amount = isPosMode ? '\$50.00' : '\$25.50';
    final merchant = isPosMode ? 'Customer Payment' : 'Coffee Shop';

    setState(() {
      isPaymentProcessing = false;
      isNfcActive = false;
      paymentResult = 'Payment of $amount to $merchant completed successfully!';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[300]),
            const SizedBox(width: 12),
            Expanded(child: Text('Payment successful: $amount')),
          ],
        ),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 4),
      ),
    );

    // Auto-clear result after 5 seconds
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          paymentResult = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mode Toggle
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ModeButton(
                    icon: Icons.payment,
                    label: 'Pay',
                    isSelected: !isPosMode,
                    onTap: () => setState(() => isPosMode = false),
                  ),
                  _ModeButton(
                    icon: Icons.point_of_sale,
                    label: 'Receive',
                    isSelected: isPosMode,
                    onTap: () => setState(() => isPosMode = true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // NFC Icon with animation
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: isNfcActive ? _pulseAnimation.value : 1.0,
                  child: GestureDetector(
                    onTap: isNfcActive ? _simulateNfcPayment : null,
                    child: AnimatedBuilder(
                      animation: _tapAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _tapAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isNfcActive
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline,
                                width: 2,
                              ),
                              boxShadow: isNfcActive
                                  ? [
                                      BoxShadow(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary.withOpacity(0.3),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ]
                                  : null,
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  isPosMode ? Icons.point_of_sale : Icons.nfc,
                                  size: 60,
                                  color: isNfcActive
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                ),
                                if (isConnecting || isPaymentProcessing)
                                  SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            Text(
              isPosMode ? 'NFC POS Terminal' : 'NFC Payment',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Status and Instructions
            if (isNfcActive && !isPaymentProcessing && !isConnecting)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app,
                      size: 20,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Tap the NFC icon to simulate payment',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (isConnecting)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Connecting to receiver...',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )
            else if (isPaymentProcessing)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Processing payment...',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )
            else
              Text(
                isPosMode
                    ? 'Turn your phone into a payment terminal.\nCustomers can tap their cards or devices to pay.'
                    : 'Pay with your phone like Apple Pay or Google Pay.\nTap your phone to any NFC payment terminal.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 24),

            // Payment Result
            if (paymentResult != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[700],
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Payment Successful!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      paymentResult!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.green[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Main Action Button
            FilledButton.icon(
              onPressed: (isConnecting || isPaymentProcessing)
                  ? null
                  : _toggleNfc,
              icon: Icon(isNfcActive ? Icons.stop : Icons.tap_and_play),
              label: Text(
                (isConnecting || isPaymentProcessing)
                    ? 'Processing...'
                    : isNfcActive
                    ? 'Stop NFC'
                    : isPosMode
                    ? 'Start POS Terminal'
                    : 'Ready to Pay',
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size(200, 50),
                backgroundColor: isNfcActive
                    ? Theme.of(context).colorScheme.error
                    : null,
              ),
            ),

            if (!isPosMode) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: widget.onSimulateTap,
                icon: const Icon(Icons.credit_card),
                label: const Text('Simulate Card Payment'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(200, 45),
                ),
              ),
            ],

            const SizedBox(height: 12),
            Text(
              (isConnecting || isPaymentProcessing)
                  ? (isPosMode
                        ? 'Processing customer payment...'
                        : 'Connecting to merchant...')
                  : paymentResult != null
                  ? 'Transaction completed'
                  : isPosMode
                  ? 'Demo: Ready to receive \$50.00'
                  : 'Demo: Coffee Shop - \$25.50',
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

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
