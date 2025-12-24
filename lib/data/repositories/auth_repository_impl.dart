import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

/// 인증 레포지토리 구현체 (Firebase)
class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Firestore 사용자 컬렉션 참조
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  @override
  Future<User?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    try {
      final doc = await _usersCollection.doc(firebaseUser.uid).get();
      if (!doc.exists) return null;

      return UserModel.fromJson({
        'id': firebaseUser.uid,
        ...doc.data()!,
      });
    } catch (e) {
      return null;
    }
  }

  @override
  Future<User> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('로그인에 실패했습니다');
      }

      // Firestore에서 사용자 정보 가져오기
      final doc = await _usersCollection.doc(user.uid).get();
      
      // Firestore에 사용자 정보가 없으면 자동 생성
      if (!doc.exists) {
        final userData = {
          'email': email,
          'name': email.split('@').first, // 이메일에서 이름 추출
          'phone': null,
          'profile_image': null,
          'is_expert': false,
          'created_at': DateTime.now().toIso8601String(),
        };
        await _usersCollection.doc(user.uid).set(userData);
        
        return UserModel.fromJson({
          'id': user.uid,
          ...userData,
        });
      }

      return UserModel.fromJson({
        'id': user.uid,
        ...doc.data()!,
      });
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<User> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
    bool isExpert = false,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('회원가입에 실패했습니다');
      }

      // Firestore에 사용자 정보 저장
      final userData = {
        'email': email,
        'name': name,
        'phone': phone,
        'profile_image': null,
        'is_expert': isExpert,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _usersCollection.doc(user.uid).set(userData);

      return UserModel.fromJson({
        'id': user.uid,
        ...userData,
      });
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        final doc = await _usersCollection.doc(firebaseUser.uid).get();
        if (!doc.exists) return null;

        return UserModel.fromJson({
          'id': firebaseUser.uid,
          ...doc.data()!,
        });
      } catch (e) {
        return null;
      }
    });
  }

  /// Firebase Auth 예외 처리
  Exception _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('등록되지 않은 이메일입니다');
      case 'wrong-password':
        return Exception('비밀번호가 올바르지 않습니다');
      case 'email-already-in-use':
        return Exception('이미 사용 중인 이메일입니다');
      case 'weak-password':
        return Exception('비밀번호가 너무 약합니다');
      case 'invalid-email':
        return Exception('유효하지 않은 이메일 형식입니다');
      case 'user-disabled':
        return Exception('비활성화된 계정입니다');
      case 'too-many-requests':
        return Exception('너무 많은 요청이 있었습니다. 잠시 후 다시 시도해주세요');
      default:
        return Exception('인증 오류가 발생했습니다: ${e.message}');
    }
  }
}
