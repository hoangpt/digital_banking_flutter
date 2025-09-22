import '../domain/payment.dart';
import '../domain/payment_type.dart';

abstract class IPaymentRepository {
  Stream<List<Payment>> recentPayments({int limit = 20});
  Future<Payment> createPayment(
    PaymentType type, {
    required double amount,
    String? merchant,
  });
}
