import '../domain/user.dart';

abstract class IAuthRepository {
  Future<User?> currentUser();
  Future<User> signIn(String email, String password);
  Future<User> signUp(String email, String password);
  Future<void> signOut();
}
