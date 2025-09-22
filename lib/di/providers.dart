import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/env.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/data/mock_auth_repository.dart';
import '../features/auth/data/firebase_auth_repository.dart';
import '../features/payments/data/payment_repository.dart';
import '../features/payments/data/mock_payment_repository.dart';
import '../features/payments/data/firebase_payment_repository.dart';

final authRepoProvider = Provider<IAuthRepository>(
  (ref) => AppEnv.isMock ? MockAuthRepository() : FirebaseAuthRepository(),
);

final paymentRepoProvider = Provider<IPaymentRepository>(
  (ref) =>
      AppEnv.isMock ? MockPaymentRepository() : FirebasePaymentRepository(),
);
