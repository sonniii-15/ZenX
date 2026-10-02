import 'package:firebase_auth/firebase_auth.dart' as firebase;

abstract class IAuthRepository {
  Stream<firebase.User?> authStateChanges();
  firebase.User? get currentUser;
  Future<firebase.User?> signIn(String email, String password);
  Future<firebase.User?> signUp(String username, String email, String password);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
}
