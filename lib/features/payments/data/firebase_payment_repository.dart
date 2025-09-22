import 'payment_repository.dart';
import '../domain/payment.dart';
import '../domain/payment_type.dart';

class FirebasePaymentRepository implements IPaymentRepository {
  // TODO: Implement with cloud_firestore
  @override
  Stream<List<Payment>> recentPayments({int limit = 20}) {
    // TODO: Read payments from Firestore
    throw UnimplementedError();
  }

  @override
  Future<Payment> createPayment(
    PaymentType type, {
    required double amount,
    String? merchant,
  }) async {
    // TODO: Write payment to Firestore
    throw UnimplementedError();
  }
}
