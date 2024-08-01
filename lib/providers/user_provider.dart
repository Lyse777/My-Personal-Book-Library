import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/logging_service.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get user => _user;

  UserProvider() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      LoggingService.logInfo('User signed in with email: ${_user?.email}');
      notifyListeners();
    } catch (e, stackTrace) {
      LoggingService.logError('Failed to sign in with email and password', e, stackTrace);
      rethrow;
    }
  }

  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      LoggingService.logInfo('User signed up with email: ${_user?.email}');
      notifyListeners();
    } catch (e, stackTrace) {
      LoggingService.logError('Failed to sign up with email and password', e, stackTrace);
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      }
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      _user = userCredential.user;
      LoggingService.logInfo('User signed in with Google: ${_user?.email}');
      notifyListeners();
    } catch (e, stackTrace) {
      LoggingService.logError('Failed to sign in with Google', e, stackTrace);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      LoggingService.logInfo('User signed out');
      notifyListeners();
    } catch (e, stackTrace) {
      LoggingService.logError('Failed to sign out', e, stackTrace);
      rethrow;
    }
  }

  bool get isAdmin => _user?.email == 'umuhirelise22@gmail.com';
}
