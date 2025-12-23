/// 입력 검증 유틸리티
class Validators {
  Validators._();

  /// 이메일 검증
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return '올바른 이메일 형식이 아닙니다';
    }
    return null;
  }

  /// 비밀번호 검증
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    if (value.length < 8) {
      return '비밀번호는 8자 이상이어야 합니다';
    }
    return null;
  }

  /// 필수 입력 검증
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName을(를) 입력해주세요';
    }
    return null;
  }

  /// 전화번호 검증
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return '전화번호를 입력해주세요';
    }
    final phoneRegex = RegExp(r'^01[0-9]-?[0-9]{3,4}-?[0-9]{4}$');
    if (!phoneRegex.hasMatch(value.replaceAll('-', ''))) {
      return '올바른 전화번호 형식이 아닙니다';
    }
    return null;
  }
}


