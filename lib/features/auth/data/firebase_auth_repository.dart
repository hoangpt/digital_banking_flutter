import 'auth_repository.dart';
import '../domain/user.dart';

class FirebaseAuthRepository implements IAuthRepository {
  // TODO: Implement with firebase_auth
  @override
  Future<User?> currentUser() async {
    // TODO: Get current user from FirebaseAuth
    throw UnimplementedError();
  }

  @override
  Future<User> signIn(String email, String password) async {
    // TODO: Sign in with FirebaseAuth
    throw UnimplementedError();
  }

  @override
  Future<User> signUp(String email, String password) async {
    // TODO: Sign up with FirebaseAuth
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {
    // TODO: Sign out with FirebaseAuth
    throw UnimplementedError();
  }
}
