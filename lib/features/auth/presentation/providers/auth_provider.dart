import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/firebase_auth_repository.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return FirebaseAuthRepository();
});

final authStateProvider = StreamProvider<firebase.User?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges();
});

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<firebase.User?>>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

class AuthController extends StateNotifier<AsyncValue<firebase.User?>> {
  final IAuthRepository _authRepository;

  AuthController(this._authRepository) : super(const AsyncValue.data(null));

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signIn(email, password);
      state = AsyncValue.data(user);
    } on firebase.FirebaseException catch (e) {
      String message = 'An error occurred during login.';
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Incorrect email or password.';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email.';
      } else if (e.code == 'network-request-failed' || e.code == 'network_error' || e.plugin == 'firebase_auth') {
        message = 'Network connection problem. Please try again.';
      } else if (e.code == 'too-many-requests') {
        message = 'Too many attempts. Please try again later.';
      }
      state = AsyncValue.error(message, StackTrace.current);
    } on Exception catch (e, st) {
      state = AsyncValue.error(e.toString().replaceAll('Exception: ', ''), st);
    } catch (e, st) {
      state = AsyncValue.error('An unexpected error occurred: $e', st);
    }
  }

  Future<void> signUp(String username, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signUp(username, email, password);
      state = AsyncValue.data(user);
    } on firebase.FirebaseException catch (e) {
      String message = 'An error occurred during registration.';
      if (e.code == 'email-already-in-use') {
        message = 'This email is already in use.';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email.';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak. Please use a stronger password.';
      } else if (e.code == 'network-request-failed' || e.code == 'network_error') {
        message = 'Network connection problem. Please try again.';
      }
      state = AsyncValue.error(message, StackTrace.current);
    } on Exception catch (e, st) {
      state = AsyncValue.error(e.toString().replaceAll('Exception: ', ''), st);
    } catch (e, st) {
      state = AsyncValue.error('An unexpected error occurred: $e', st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authRepository.sendPasswordResetEmail(email);
    } on firebase.FirebaseException catch (e) {
      String message = 'An error occurred while resetting password.';
      if (e.code == 'user-not-found') {
        message = 'No user found with this email.';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email.';
      } else if (e.code == 'network-request-failed' || e.code == 'network_error') {
        message = 'Network connection problem. Please try again.';
      }
      throw Exception(message);
    } on Exception catch (e) {
      throw e;
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
