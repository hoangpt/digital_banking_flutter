import 'auth_repository.dart';
import '../domain/user.dart';

class MockAuthRepository implements IAuthRepository {
  static const demoEmail = 'demo@bank.app';
  static const demoPassword = 'Demo@1234';
  User? _user;

  @override
  Future<User?> currentUser() async => _user;

  @override
  Future<User> signIn(String email, String password) async {
    if (email == demoEmail && password == demoPassword) {
      _user = User(id: 'demo', email: demoEmail);
      return _user!;
    }
    throw Exception('Invalid credentials');
  }

  @override
  Future<User> signUp(String email, String password) async {
    // Mock: always succeed, assign demo user
    _user = User(id: 'demo', email: email);
    return _user!;
  }

  @override
  Future<void> signOut() async {
    _user = null;
  }
}
