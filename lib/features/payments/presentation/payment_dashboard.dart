import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../di/providers.dart';
import '../domain/payment_type.dart';
import '../domain/payment.dart';
import 'widgets/nfc_panel.dart';
import 'widgets/qr_panel.dart';
import 'widgets/history_panel.dart';
import 'widgets/balance_card.dart';
import '../../auth/domain/user.dart';

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
    final authRepo = ref.watch(authRepoProvider);

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
          // Balance Card
          FutureBuilder<User?>(
            future: authRepo.currentUser(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return BalanceCard(user: snapshot.data!);
              }
              return const SizedBox.shrink();
            },
          ),
          // Tab Content
          Expanded(
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
        ],
      ),
    );
  }
}
