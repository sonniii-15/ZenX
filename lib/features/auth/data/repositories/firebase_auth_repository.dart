import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../../firebase_options.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements IAuthRepository {
  final firebase.FirebaseAuth _auth;

  FirebaseAuthRepository({firebase.FirebaseAuth? auth}) : _auth = auth ?? firebase.FirebaseAuth.instance;

  @override
  Stream<firebase.User?> authStateChanges() => _auth.authStateChanges();

  @override
  firebase.User? get currentUser => _auth.currentUser;

  @override
  Future<firebase.User?> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // TEMPORARILY DISABLED FOR PROJECT REVIEW
    // if (credential.user != null && !credential.user!.emailVerified) {
    //   await _auth.signOut();
    //   throw Exception('Please verify your email before logging in. A verification link was sent to $email');
    // }
    
    return credential.user;
  }

  @override
  Future<firebase.User?> signUp(String username, String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    if (credential.user != null) {
      final user = credential.user!;
      await user.updateDisplayName(username);
      
      // Enforce email verification
      await user.sendEmailVerification();
      
      // Create Firestore profile
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'profileImageUrl': null,
        'totalPoints': 0,
        'currentLevel': 1,
        'totalDistanceKm': 0.0,
        'totalCalories': 0.0,
        'totalCapturedCells': 0,
        'totalActivities': 0,
        'earnedBadges': [],
      });

      // Wait for propagation
      await user.reload();
      
      // Sign out immediately because they must verify their email before accessing the app
      await _auth.signOut();
      
      return null;
    }
    return null;
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    // To fix the "empty apiKey=" bug in Firebase Auth emails sent from iOS,
    // we initialize a secondary Firebase app using the Web options. 
    // This forces the backend to embed the Web API Key (which is valid for the web handler)
    // instead of the restricted iOS API Key which gets stripped out.
    FirebaseApp webApp;
    try {
      webApp = Firebase.app('webApp');
    } catch (e) {
      webApp = await Firebase.initializeApp(
        name: 'webApp',
        options: DefaultFirebaseOptions.web,
      );
    }
    
    await firebase.FirebaseAuth.instanceFor(app: webApp).sendPasswordResetEmail(email: email);
  }
}
