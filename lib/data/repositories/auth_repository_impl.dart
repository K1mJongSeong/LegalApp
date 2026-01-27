import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
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

  /// 구글 로그인
  Future<User> loginWithGoogle({bool isExpert = false}) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('구글 로그인이 취소되었습니다');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw Exception('구글 로그인에 실패했습니다');
      }

      // Firestore에서 사용자 정보 확인 또는 생성
      final doc = await _usersCollection.doc(user.uid).get();

      if (!doc.exists) {
        // 신규 사용자 - Firestore에 정보 저장
        final userData = {
          'email': user.email ?? '',
          'name': user.displayName ?? user.email?.split('@').first ?? '사용자',
          'phone': user.phoneNumber,
          'profile_image': user.photoURL,
          'is_expert': isExpert,
          'created_at': DateTime.now().toIso8601String(),
          'login_provider': 'google',
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
    } catch (e) {
      if (e.toString().contains('취소')) {
        rethrow;
      }
      throw Exception('구글 로그인 중 오류가 발생했습니다: $e');
    }
  }

  /// 카카오 로그인
  Future<User> loginWithKakao({bool isExpert = false}) async {
    try {
      // 웹 환경이거나 카카오톡 설치 여부 확인 실패 시 카카오 계정 로그인 사용
      bool useKakaoTalk = false;
      if (!kIsWeb) {
        try {
          useKakaoTalk = await kakao.isKakaoTalkInstalled();
        } catch (e) {
          // MissingPluginException 등 네이티브 플러그인 에러 발생 시
          // 카카오 계정 로그인으로 폴백
          debugPrint('⚠️ 카카오톡 설치 여부 확인 실패, 카카오 계정 로그인 사용: $e');
          useKakaoTalk = false;
        }
      }

      if (useKakaoTalk) {
        await kakao.UserApi.instance.loginWithKakaoTalk();
      } else {
        await kakao.UserApi.instance.loginWithKakaoAccount();
      }

      // 카카오 사용자 정보 가져오기
      final kakaoUser = await kakao.UserApi.instance.me();

      // Firebase Custom Token으로 로그인하거나 이메일 기반 로그인 사용
      // 여기서는 카카오 이메일로 Firebase에 로그인하는 방식 사용
      final email = kakaoUser.kakaoAccount?.email;
      if (email == null || email.isEmpty) {
        throw Exception('카카오 계정에 이메일이 등록되어 있지 않습니다.\n카카오 계정 설정에서 이메일을 등록해주세요.');
      }

      // 카카오 ID를 기반으로 고유한 비밀번호 생성 (항상 동일한 값)
      final kakaoPassword = 'kakao_secure_${kakaoUser.id}';

      firebase_auth.UserCredential userCredential;

      try {
        // 먼저 기존 계정으로 로그인 시도
        userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: kakaoPassword,
        );
      } on firebase_auth.FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          // 신규 사용자 - 계정 생성
          userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
            email: email,
            password: kakaoPassword,
          );
        } else if (e.code == 'wrong-password') {
          // 기존 이메일/비밀번호 사용자 - 카카오 연동 불가
          throw Exception('이미 이메일로 가입된 계정입니다.\n이메일과 비밀번호로 로그인해주세요.');
        } else {
          rethrow;
        }
      }

      final user = userCredential.user;
      if (user == null) {
        throw Exception('카카오 로그인에 실패했습니다');
      }

      // Firestore에 사용자 정보 저장/업데이트
      final doc = await _usersCollection.doc(user.uid).get();

      if (!doc.exists) {
        final userData = {
          'email': email,
          'name': kakaoUser.kakaoAccount?.profile?.nickname ?? email.split('@').first,
          'phone': kakaoUser.kakaoAccount?.phoneNumber,
          'profile_image': kakaoUser.kakaoAccount?.profile?.profileImageUrl,
          'is_expert': isExpert,
          'created_at': DateTime.now().toIso8601String(),
          'login_provider': 'kakao',
          'kakao_id': kakaoUser.id.toString(),
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
    } catch (e) {
      if (e.toString().contains('취소') || e.toString().contains('cancelled')) {
        throw Exception('카카오 로그인이 취소되었습니다');
      }
      rethrow;
    }
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
