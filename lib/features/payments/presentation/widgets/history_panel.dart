import 'package:flutter/material.dart';
import '../../domain/payment.dart';
import '../../domain/payment_type.dart';

enum TransactionFilter { all, payments, received }

class HistoryPanel extends StatefulWidget {
  final List<Payment> payments;
  const HistoryPanel({super.key, required this.payments});

  @override
  State<HistoryPanel> createState() => _HistoryPanelState();
}

class _HistoryPanelState extends State<HistoryPanel> {
  TransactionFilter _selectedFilter = TransactionFilter.all;

  List<Payment> get _filteredPayments {
    switch (_selectedFilter) {
      case TransactionFilter.payments:
        // Payments are outgoing transactions (nfc, qr, card, transfer to others)
        return widget.payments
            .where((p) => p.type != PaymentType.topup)
            .toList();
      case TransactionFilter.received:
        // Received are incoming transactions (topup, received transfers)
        return widget.payments
            .where((p) => p.type == PaymentType.topup)
            .toList();
      case TransactionFilter.all:
        return widget.payments;
    }
  }

  double get _totalSpent {
    return widget.payments
        .where(
          (p) =>
              p.type != PaymentType.topup && p.status == PaymentStatus.success,
        )
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  double get _totalReceived {
    return widget.payments
        .where(
          (p) =>
              p.type == PaymentType.topup && p.status == PaymentStatus.success,
        )
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  int get _totalTransactions => widget.payments.length;

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  title: 'Total Spent',
                  amount: _totalSpent,
                  color: Colors.red,
                  icon: Icons.arrow_upward,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SummaryItem(
                  title: 'Total Received',
                  amount: _totalReceived,
                  color: Colors.green,
                  icon: Icons.arrow_downward,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '$_totalTransactions Total Transactions',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _FilterChip(
            label: 'All',
            isSelected: _selectedFilter == TransactionFilter.all,
            onTap: () =>
                setState(() => _selectedFilter = TransactionFilter.all),
            count: widget.payments.length,
          ),
          _FilterChip(
            label: 'Payed',
            isSelected: _selectedFilter == TransactionFilter.payments,
            onTap: () =>
                setState(() => _selectedFilter = TransactionFilter.payments),
            count: widget.payments
                .where((p) => p.type != PaymentType.topup)
                .length,
          ),
          _FilterChip(
            label: 'Received',
            isSelected: _selectedFilter == TransactionFilter.received,
            onTap: () =>
                setState(() => _selectedFilter = TransactionFilter.received),
            count: widget.payments
                .where((p) => p.type == PaymentType.topup)
                .length,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Transaction History',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Summary Card
        if (widget.payments.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildSummaryCard(),
            ),
          ),

        // Filter Chips
        if (widget.payments.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildFilterChips(),
            ),
          ),

        // Transaction List
        if (_filteredPayments.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
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
                      _selectedFilter == TransactionFilter.all
                          ? 'No transactions yet'
                          : _selectedFilter == TransactionFilter.payments
                          ? 'No payments yet'
                          : 'No received transactions yet',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try making a payment using NFC or QR',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final payment = _filteredPayments[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getPaymentTypeColor(payment.type),
                      child: Icon(
                        _getPaymentTypeIcon(payment.type),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      payment.merchant,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getTransactionTypeLabel(payment.type),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _formatDateTime(payment.ts),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getAmountText(payment),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _getAmountColor(payment),
                              ),
                        ),
                        Icon(
                          payment.status == PaymentStatus.success
                              ? Icons.check_circle
                              : payment.status == PaymentStatus.failed
                              ? Icons.error
                              : Icons.pending,
                          size: 16,
                          color: payment.status == PaymentStatus.success
                              ? Colors.green
                              : payment.status == PaymentStatus.failed
                              ? Colors.red
                              : Colors.orange,
                        ),
                      ],
                    ),
                  ),
                );
              }, childCount: _filteredPayments.length),
            ),
          ),

        // Add some bottom padding
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }

  String _getTransactionTypeLabel(PaymentType type) {
    switch (type) {
      case PaymentType.nfc:
        return 'NFC Payment';
      case PaymentType.qr:
        return 'QR Payment';
      case PaymentType.card:
        return 'Card Payment';
      case PaymentType.topup:
        return 'Top-up';
      case PaymentType.transfer:
        return 'Transfer';
    }
  }

  String _getAmountText(Payment payment) {
    final isPositive = payment.type == PaymentType.topup;
    final prefix = isPositive ? '+' : '-';
    return '$prefix\$${payment.amount.toStringAsFixed(2)}';
  }

  Color _getAmountColor(Payment payment) {
    if (payment.status == PaymentStatus.failed) {
      return Colors.red;
    } else if (payment.status == PaymentStatus.pending) {
      return Colors.orange;
    } else {
      // Success - show red for negative amounts (outgoing payments), green for positive (topup)
      return payment.type == PaymentType.topup ? Colors.green : Colors.red;
    }
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
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

class _SummaryItem extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryItem({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int count;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.2)
                    : Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
