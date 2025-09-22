import 'payment_repository.dart';
import '../domain/payment.dart';
import '../domain/payment_type.dart';
import 'dart:async';
import 'dart:math';

class MockPaymentRepository implements IPaymentRepository {
  static final MockPaymentRepository _instance =
      MockPaymentRepository._internal();
  factory MockPaymentRepository() => _instance;

  MockPaymentRepository._internal() {
    _initializeMockData();
  }

  final _payments = <Payment>[];
  final _controller = StreamController<List<Payment>>.broadcast();
  static const _defaultLimit = 20;

  void _initializeMockData() {
    if (_payments.isNotEmpty) return; // Already initialized

    final now = DateTime.now();

    // Add some mock historical transactions
    final mockPayments = [
      Payment(
        id: '1',
        type: PaymentType.topup,
        amount: 500.00,
        merchant: 'Bank Transfer',
        status: PaymentStatus.success,
        ts: now.subtract(const Duration(days: 3, hours: 2)),
      ),
      Payment(
        id: '2',
        type: PaymentType.nfc,
        amount: 4.50,
        merchant: 'Starbucks Coffee',
        status: PaymentStatus.success,
        ts: now.subtract(const Duration(days: 2, hours: 3)),
      ),
      Payment(
        id: '3',
        type: PaymentType.transfer,
        amount: 100.00,
        merchant: 'John Doe',
        status: PaymentStatus.success,
        ts: now.subtract(const Duration(days: 2, hours: 1)),
      ),
      Payment(
        id: '4',
        type: PaymentType.qr,
        amount: 12.99,
        merchant: 'McDonald\'s',
        status: PaymentStatus.success,
        ts: now.subtract(const Duration(days: 1, hours: 5)),
      ),
      Payment(
        id: '5',
        type: PaymentType.card,
        amount: 89.90,
        merchant: 'Shopee Online',
        status: PaymentStatus.success,
        ts: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      Payment(
        id: '6',
        type: PaymentType.topup,
        amount: 200.00,
        merchant: 'ATM Top-up',
        status: PaymentStatus.success,
        ts: now.subtract(const Duration(days: 1, hours: 1)),
      ),
      Payment(
        id: '7',
        type: PaymentType.nfc,
        amount: 25.00,
        merchant: 'Circle K',
        status: PaymentStatus.failed,
        ts: now.subtract(const Duration(hours: 8)),
      ),
      Payment(
        id: '8',
        type: PaymentType.qr,
        amount: 150.00,
        merchant: 'Vincom Center',
        status: PaymentStatus.success,
        ts: now.subtract(const Duration(hours: 6)),
      ),
      Payment(
        id: '9',
        type: PaymentType.transfer,
        amount: 50.00,
        merchant: 'Alice Smith',
        status: PaymentStatus.pending,
        ts: now.subtract(const Duration(hours: 4)),
      ),
      Payment(
        id: '10',
        type: PaymentType.card,
        amount: 35.75,
        merchant: 'Grab Food',
        status: PaymentStatus.success,
        ts: now.subtract(const Duration(hours: 3)),
      ),
      Payment(
        id: '11',
        type: PaymentType.topup,
        amount: 300.00,
        merchant: 'Online Banking',
        status: PaymentStatus.success,
        ts: now.subtract(const Duration(hours: 2)),
      ),
      Payment(
        id: '12',
        type: PaymentType.nfc,
        amount: 8.50,
        merchant: 'Highland Coffee',
        status: PaymentStatus.success,
        ts: now.subtract(const Duration(hours: 1)),
      ),
    ];

    _payments.addAll(mockPayments);
    _controller.add(_payments.take(_defaultLimit).toList());
  }

  @override
  Stream<List<Payment>> recentPayments({int limit = 20}) {
    // Return current payments list and then listen for updates
    final payments = _payments.take(limit).toList();
    _controller.add(payments);
    return _controller.stream;
  }

  @override
  Future<Payment> createPayment(
    PaymentType type, {
    required double amount,
    String? merchant,
  }) async {
    final payment = Payment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      amount: amount,
      merchant: merchant ?? _randomMerchant(),
      status: PaymentStatus.success,
      ts: DateTime.now(),
    );
    _payments.insert(0, payment);
    _controller.add(_payments.take(_defaultLimit).toList());
    return payment;
  }

  String _randomMerchant() {
    const merchants = [
      'Coffee Shop',
      'Supermarket',
      'Bookstore',
      'Online Store',
    ];
    return merchants[Random().nextInt(merchants.length)];
  }
}
