import 'package:flutter/material.dart';

/// BuildContext 확장
extension ContextExtension on BuildContext {
  /// 화면 크기
  Size get screenSize => MediaQuery.of(this).size;

  /// 화면 너비
  double get screenWidth => screenSize.width;

  /// 화면 높이
  double get screenHeight => screenSize.height;

  /// 테마
  ThemeData get theme => Theme.of(this);

  /// 텍스트 테마
  TextTheme get textTheme => theme.textTheme;

  /// 컬러 스키마
  ColorScheme get colorScheme => theme.colorScheme;

  /// 스낵바 표시
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }
}

/// String 확장
extension StringExtension on String {
  /// 첫 글자 대문자
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// 카테고리 한글 변환
  String get categoryToKorean {
    switch (toLowerCase()) {
      case 'labor':
        return '노동/근로';
      case 'tax':
        return '세금/조세';
      case 'criminal':
        return '형사';
      case 'family':
        return '가사/이혼';
      case 'real':
        return '부동산';
      default:
        return this;
    }
  }

  /// 긴급도 한글 변환
  String get urgencyToKorean {
    switch (toLowerCase()) {
      case 'simple':
        return '간단 상담';
      case 'normal':
        return '일반';
      case 'urgent':
        return '긴급';
      default:
        return this;
    }
  }
}

/// DateTime 확장
extension DateTimeExtension on DateTime {
  /// 한국식 날짜 포맷
  String get toKoreanDate {
    return '$year년 $month월 $day일';
  }

  /// 한국식 날짜시간 포맷
  String get toKoreanDateTime {
    return '$year년 $month월 $day일 $hour:${minute.toString().padLeft(2, '0')}';
  }
}


