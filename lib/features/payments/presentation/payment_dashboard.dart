import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../di/providers.dart';
import '../domain/payment_type.dart';
import '../domain/payment.dart';
import 'widgets/nfc_panel.dart';
import 'widgets/qr_panel.dart';
import 'widgets/history_panel.dart';

class PaymentDashboard extends ConsumerStatefulWidget {
  const PaymentDashboard({super.key});

  @override
  ConsumerState<PaymentDashboard> createState() => _PaymentDashboardState();
}

class _PaymentDashboardState extends ConsumerState<PaymentDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _signOut() async {
    try {
      final authRepo = ref.read(authRepoProvider);
      await authRepo.signOut();
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign out failed: ${e.toString()}')),
        );
      }
    }
  }

  void _simulateNfcPayment() async {
    try {
      final paymentRepo = ref.read(paymentRepoProvider);
      await paymentRepo.createPayment(
        PaymentType.nfc,
        amount: 25.50,
        merchant: 'Coffee Shop',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('NFC Payment successful!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('NFC Payment failed: ${e.toString()}')),
        );
      }
    }
  }

  void _generateQr() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR Code generated! (TODO: Show QR)')),
    );
  }

  void _scanQr() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR Scanner opened! (TODO: Camera scan)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentRepo = ref.watch(paymentRepoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Banking'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.nfc), text: 'NFC'),
            Tab(icon: Icon(Icons.qr_code), text: 'QR Code'),
            Tab(icon: Icon(Icons.history), text: 'History'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Tab Content
          Expanded(
            flex: 2,
            child: TabBarView(
              controller: _tabController,
              children: [
                NfcPanel(onSimulateTap: _simulateNfcPayment),
                QrPanel(onGenerateQr: _generateQr, onScanQr: _scanQr),
                StreamBuilder<List<Payment>>(
                  stream: paymentRepo.recentPayments(limit: 50),
                  builder: (context, snapshot) {
                    return HistoryPanel(payments: snapshot.data ?? []);
                  },
                ),
              ],
            ),
          ),

          // Recent Transactions
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Transactions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: StreamBuilder<List<Payment>>(
                      stream: paymentRepo.recentPayments(limit: 10),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No transactions yet',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.outline,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try making a payment using NFC, QR, or Card',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.outline,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final payment = snapshot.data![index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getPaymentTypeColor(
                                    payment.type,
                                  ),
                                  child: Icon(
                                    _getPaymentTypeIcon(payment.type),
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(payment.merchant),
                                subtitle: Text(
                                  '${payment.type.name.toUpperCase()} • ${_formatDateTime(payment.ts)}',
                                ),
                                trailing: Text(
                                  '\$${payment.amount.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            payment.status ==
                                                PaymentStatus.success
                                            ? Colors.green
                                            : payment.status ==
                                                  PaymentStatus.failed
                                            ? Colors.red
                                            : Colors.orange,
                                      ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPaymentTypeColor(PaymentType type) {
    switch (type) {
      case PaymentType.nfc:
        return Colors.blue;
      case PaymentType.qr:
        return Colors.green;
      case PaymentType.card:
        return Colors.purple;
      case PaymentType.topup:
        return Colors.orange;
      case PaymentType.transfer:
        return Colors.teal;
    }
  }

  IconData _getPaymentTypeIcon(PaymentType type) {
    switch (type) {
      case PaymentType.nfc:
        return Icons.nfc;
      case PaymentType.qr:
        return Icons.qr_code;
      case PaymentType.card:
        return Icons.credit_card;
      case PaymentType.topup:
        return Icons.add_circle;
      case PaymentType.transfer:
        return Icons.send;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
