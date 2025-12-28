# ⚖️ LawDecode

> **DailyProgress Team** - 법률 상담 플랫폼 앱

일반 사용자와 법률 전문가를 연결하는 Flutter 기반 법률 상담 플랫폼입니다.

---

## 📱 주요 기능

- **회원가입/로그인**: 이메일/비밀번호 기반 Firebase 인증
- **법률 상담 등록**: 카테고리별 사건 등록 (노동, 세금, 형사, 가사, 부동산 등)
- **전문가 매칭**: 등록된 사건에 대해 법률 전문가 연결
- **상담 관리**: 진행중/대기중/완료 상태별 사건 관리
- **리뷰 시스템**: 상담 완료 후 전문가 리뷰 작성

---

## 🛠️ 기술 스택

| 분류 | 기술 |
|------|------|
| **Framework** | Flutter 3.38.x |
| **Language** | Dart 3.5.x |
| **State Management** | flutter_bloc 8.1.x |
| **Backend** | Firebase (Auth, Firestore, Storage) |
| **Architecture** | Clean Architecture |

---

## 📁 프로젝트 구조

```
lib/
├── core/                   # 공통 유틸리티
│   ├── constants/          # 앱 상수 (색상, 크기, 문자열)
│   ├── router/             # 라우팅 설정
│   ├── services/           # Firebase 서비스
│   ├── theme/              # 앱 테마
│   └── utils/              # 유틸리티 함수, 확장
├── data/                   # 데이터 레이어
│   ├── models/             # 데이터 모델 (JSON 직렬화)
│   └── repositories/       # 레포지토리 구현체
├── domain/                 # 도메인 레이어
│   ├── entities/           # 엔티티 (비즈니스 객체)
│   └── repositories/       # 레포지토리 인터페이스
├── presentation/           # UI 레이어
│   ├── blocs/              # BLoC 상태 관리
│   ├── pages/              # 화면 페이지
│   └── widgets/            # 재사용 위젯
├── firebase_options.dart   # Firebase 설정
└── main.dart               # 앱 진입점
```

---

## ⚙️ 환경 설정

### 요구사항

- Flutter SDK: 3.5.0 이상
- Dart SDK: 3.5.0 이상
- Android Studio / VS Code
- Firebase 프로젝트

### 설치

```bash
# 1. 레포지토리 클론
git clone https://github.com/K1mJongSeong/LegalApp.git
cd law_decode

# 2. 패키지 설치
flutter pub get

# 3. 앱 실행
flutter run
```

### Firebase 설정

1. [Firebase Console](https://console.firebase.google.com/)에서 프로젝트 생성
2. Android 앱 등록 (`com.dailyprogress.lawdecode`)
3. `google-services.json` 다운로드 → `android/app/` 에 배치
4. SHA-1, SHA-256 인증서 지문 등록
5. Authentication → 이메일/비밀번호 로그인 활성화
6. Firestore Database 생성

---

## 🏗️ 빌드

### 디버그 빌드

```bash
flutter run
```

### APK 빌드 (스크립트 사용)

```powershell
# 디버그 APK
.\build.bat

# 릴리즈 APK
.\build.bat -Release

# 클린 후 빌드
.\build.bat -Clean
```

### 수동 APK 빌드

```bash
flutter build apk --debug
flutter build apk --release
```

> ⚠️ APK 파일 위치: `android/app/build/outputs/flutter-apk/`

---

## 📋 Firebase 컬렉션 구조

```
users/
├── {userId}/
│   ├── email: string
│   ├── name: string
│   ├── phone: string?
│   ├── profile_image: string?
│   ├── is_expert: boolean
│   └── created_at: string

cases/
├── {caseId}/
│   ├── user_id: string
│   ├── title: string
│   ├── description: string
│   ├── category: string
│   ├── status: string (pending/inProgress/completed/cancelled)
│   ├── created_at: string
│   └── assigned_expert: reference?

experts/
├── {expertId}/
│   ├── name: string
│   ├── specialization: string[]
│   ├── rating: number
│   └── ...

reviews/
├── {reviewId}/
│   ├── case_id: string
│   ├── expert_id: string
│   ├── user_id: string
│   ├── rating: number
│   └── comment: string
```

---

## 🔧 주요 설정

| 설정 | 값 |
|------|-----|
| minSdk | 23 (Android 6.0+) |
| targetSdk | Flutter 기본값 |
| Kotlin | 2.1.0 |
| Java | 17 |
| Gradle | 8.10.2 |
| Android Gradle Plugin | 8.7.0 |

---

## 👥 팀

**DailyProgress Team**

---

## 📄 라이선스

This project is proprietary and confidential.
