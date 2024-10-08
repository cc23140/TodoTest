import 'dart:async';


import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';
import 'package:cache/cache.dart';
import 'package:authentication_repository/authentication_repository.dart';

class SignUpWithEmailAndPasswordFailure implements Exception {

  const SignUpWithEmailAndPasswordFailure([
    this.message = 'An unknown exception occurred',
  ]);


  factory SignUpWithEmailAndPasswordFailure.fromCode(String code){
    switch (code){
      case 'invalid-email':
        return const SignUpWithEmailAndPasswordFailure(
          'Email is not valid or badly formatted.'
        );
      case 'user-disable':
        return const SignUpWithEmailAndPasswordFailure(
          'This user has been disabled. Please contact support for help.'
        );

      case 'email-already-in-use':
        return const SignUpWithEmailAndPasswordFailure(
          'An account already exists for that email.'
        );

      case 'operation-not-allowed':
        return const SignUpWithEmailAndPasswordFailure(
          'Operation is not allowed. Please contact support'
        );

      case 'weak-password':
        return const SignUpWithEmailAndPasswordFailure(
          'Please enter a stronger password'
        );

      default:
        return const SignUpWithEmailAndPasswordFailure();
    }
  }

  final String message;
}

class LoginWithEmailAndPasswordFailure implements Exception{
  const LoginWithEmailAndPasswordFailure([
    this.message = 'An unknown exception occurred.'
  ]);

  factory LoginWithEmailAndPasswordFailure.fromCode(String code){
    switch(code){
      case 'invalid-email':
        return const LoginWithEmailAndPasswordFailure(
          'Email is not valid or badly formatted.'
        );

      case 'user-disabled':
        return const LoginWithEmailAndPasswordFailure(
          'This user has been disabled. Please contact support for help.'
        );

      case 'user-not-found':
        return const LoginWithEmailAndPasswordFailure(
          'Incorrect password, please try again.'
        );

      case 'wrong-password':
        return const LoginWithEmailAndPasswordFailure(
          'Incorrect password, please try again.'
        );
      default:
        return const LoginWithEmailAndPasswordFailure();
    }
  }

  final String message;
}

class LogInWithGoogleFailure implements Exception{

  final String message;

  const LogInWithGoogleFailure([
    this.message = 'An unknown exception occurred.'
  ]);

  factory LogInWithGoogleFailure.fromCode(String code){
    switch(code){
      case 'account-exists-with-different-credential':
        return const LogInWithGoogleFailure(
          'Account exists with different credentials.',
        );
      case 'invalid-credential':
        return const LogInWithGoogleFailure(
          'The credential received is malformed or has expired.',
        );
      case 'operation-not-allowed':
        return const LogInWithGoogleFailure(
          'Operation is not allowed.  Please contact support.',
        );
      case 'user-disabled':
        return const LogInWithGoogleFailure(
          'This user has been disabled. Please contact support for help.',
        );
      case 'user-not-found':
        return const LogInWithGoogleFailure(
          'Email is not found, please create an account.',
        );
      case 'wrong-password':
        return const LogInWithGoogleFailure(
          'Incorrect password, please try again.',
        );
      case 'invalid-verification-code':
        return const LogInWithGoogleFailure(
          'The credential verification code received is invalid.',
        );
      case 'invalid-verification-id':
        return const LogInWithGoogleFailure(
          'The credential verification ID received is invalid.',
        );
      default:
        return const LogInWithGoogleFailure();
    }
  }
}

class LogOutFailure implements Exception {}

class AuthenticationRepository {

  AuthenticationRepository({
    CacheClient? cache,
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _cache = cache ?? CacheClient(),
      _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn.standard();

  final CacheClient _cache;
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  @visibleForTesting
  bool isWeb = kIsWeb;

  @visibleForTesting
  static const userCacheKey = '__user_cache_key__';

  Stream<User> get user{
    return _firebaseAuth.authStateChanges().map((firebaseUser){
      final user = firebaseUser == null ? User.empty : firebaseUser.toUser;
      _cache.write(key: userCacheKey, value: user);

      return user;
    });
  }

  User get currentUser {
    return _cache.read<User>(key: userCacheKey) ?? User.empty;
  }


  Future<void> signUp({required String email, required String password}) async {
    try{
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    } on firebase_auth.FirebaseAuthException catch(e){
      throw SignUpWithEmailAndPasswordFailure.fromCode(e.code);
    }catch (_){
      throw const SignUpWithEmailAndPasswordFailure();
    }
  }

  Future<void> logInWithGoogle() async {
    try{
      late final firebase_auth.AuthCredential credential;
      if(isWeb){
        final googleProvider = firebase_auth.GoogleAuthProvider();
        final userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
        credential = userCredential.credential!;
      }
      else{
        final googleUser = await _googleSignIn.signIn();
        final googleAuth = await googleUser!.authentication;
        credential = firebase_auth.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken
        );

      }

      await _firebaseAuth.signInWithCredential(credential);

    } on firebase_auth.FirebaseAuthException catch(e){
      throw LogInWithGoogleFailure(e.code);
    } catch (_) {
      throw const LogInWithGoogleFailure();
    }
  }

  Future<void> logInWithEmailAndPassword({
    required String email,
    required String password
  }) async {
    try{
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on firebase_auth.FirebaseException catch(e) {
      throw LoginWithEmailAndPasswordFailure(e.code);
    }catch(_){
      throw LoginWithEmailAndPasswordFailure();
    }
  }

  Future<void> logOut() async {
    try{
      await Future.wait([
          _firebaseAuth.signOut(),
          _googleSignIn.signOut()
      ]);
    }catch(_){
      throw LogOutFailure();
    }
  }
}

extension on firebase_auth.User {
  //Transforma firebase_auth.User no model User

  User get toUser {
    final User user = User.empty;
    return user.copyWith(id: uid, email: email, name: displayName, photo: photoURL);
  }
}