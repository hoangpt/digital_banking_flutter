import 'package:flutter/material.dart';
import '../../domain/payment.dart';
import '../../domain/payment_type.dart';

class HistoryPanel extends StatelessWidget {
  final List<Payment> payments;
  const HistoryPanel({super.key, required this.payments});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          const SizedBox(height: 16),

          if (payments.isEmpty)
            Expanded(
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
                      'No transactions yet',
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
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: payments.length,
                itemBuilder: (context, index) {
                  final payment = payments[index];
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
                },
              ),
            ),
        ],
      ),
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
      // Success
      return payment.type == PaymentType.topup ? Colors.green : Colors.black87;
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
