import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> loginWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail(String email, String password);
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithFacebook();
  Future<UserModel> signInWithApple();
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
  });

  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    try {
      final result = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user == null) {
        throw ServerException('User not found after login');
      }
      return UserModel.fromFirebaseUser(result.user!);
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException Code: ${e.code}');
      String message = 'An unknown error occurred';
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential' ||
          e.code == 'invalid-email') {
        message = 'Invalid ID or password';
      } else {
        message = e.message ?? message;
      }
      throw ServerException(message);
    } catch (e) {
      debugPrint('DataSource Exception: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmail(String email, String password) async {
    try {
      final result = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user == null) {
        throw ServerException('User creation failed');
      }
      return UserModel.fromFirebaseUser(result.user!);
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.message}');
      throw ServerException(
          e.message ?? 'An unknown error occurred during sign up');
    } catch (e) {
      debugPrint('DataSource Exception: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      await googleSignIn.initialize(); // Required in GoogleSignIn v7+
      final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();

      if (googleUser == null) {
        throw ServerException('Google Sign-In cancelled by user');
      }

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final result = await firebaseAuth.signInWithCredential(credential);
      if (result.user == null) {
        throw ServerException('Firebase sign-in with Google failed');
      }
      return UserModel.fromFirebaseUser(result.user!);
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.message}');
      throw ServerException(
          e.message ?? 'An unknown error occurred during Google Sign-In');
    } catch (e) {
      debugPrint('DataSource Exception: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signInWithFacebook() async {
    // Placeholder as package not included
    throw ServerException();
  }

  @override
  Future<UserModel> signInWithApple() async {
    // Placeholder as package not included
    throw ServerException();
  }

  @override
  Future<void> signOut() async {
    await firebaseAuth.signOut();
    try {
      await googleSignIn.initialize();
    } catch (_) {} // best effort or already initialized?
    await googleSignIn.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      return UserModel.fromFirebaseUser(user);
    }
    return null;
  }
}
