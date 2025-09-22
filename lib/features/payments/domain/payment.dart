import 'payment_type.dart';

enum PaymentStatus { success, failed, pending }

class Payment {
  final String id;
  final PaymentType type;
  final double amount;
  final String merchant;
  final PaymentStatus status;
  final DateTime ts;

  Payment({
    required this.id,
    required this.type,
    required this.amount,
    required this.merchant,
    required this.status,
    required this.ts,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json['id'],
    type: PaymentType.values.firstWhere((e) => e.name == json['type']),
    amount: json['amount'],
    merchant: json['merchant'],
    status: PaymentStatus.values.firstWhere((e) => e.name == json['status']),
    ts: DateTime.parse(json['ts']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'amount': amount,
    'merchant': merchant,
    'status': status.name,
    'ts': ts.toIso8601String(),
  };
}
