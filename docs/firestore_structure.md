# Firestore Collection 구조 설계

## 📋 전체 Collection 목록

1. **users** - 사용자 정보
2. **cases** - 법률 사건 정보
3. **experts** - 전문가 정보
4. **reviews** - 리뷰 정보

---

## 1️⃣ Collection: `users`

### Document ID
- Firebase Auth의 `uid` 사용 (자동 생성)

### Document 구조
```json
{
  "id": "string",              // Firebase Auth uid
  "email": "string",           // 이메일
  "name": "string",            // 이름
  "phone": "string | null",    // 전화번호 (선택)
  "profile_image": "string | null",  // 프로필 이미지 URL (선택)
  "is_expert": "boolean",      // 전문가 여부 (기본값: false)
  "created_at": "timestamp"    // 생성일시
}
```

### 인덱스
- `email` (단일 필드 인덱스) - 이메일로 사용자 검색 시 사용

---

## 2️⃣ Collection: `cases`

### Document ID
- Firestore 자동 생성 ID 사용

### Document 구조
```json
{
  "id": "string",                    // Document ID
  "user_id": "string",               // 사용자 ID (users 컬렉션 참조)
  "category": "string",              // 카테고리: "labor", "tax", "criminal", "family", "real"
  "urgency": "string",                // 긴급도: "simple", "normal", "urgent"
  "title": "string",                 // 제목
  "description": "string",           // 설명
  "status": "string",                 // 상태: "pending", "inProgress", "completed", "cancelled"
  "assigned_expert": {               // 할당된 전문가 정보 (중첩 객체)
    "id": "number",                  // 전문가 ID
    "name": "string",                // 전문가 이름
    "profile_image": "string | null", // 프로필 이미지
    "specialty": "string"            // 전문 분야
  } | null,
  "created_at": "timestamp",         // 생성일시
  "updated_at": "timestamp | null"   // 수정일시 (선택)
}
```

### 인덱스
- `user_id` (단일 필드 인덱스) - 사용자별 사건 조회
- `status` (단일 필드 인덱스) - 상태별 사건 조회
- `category` (단일 필드 인덱스) - 카테고리별 사건 조회
- 복합 인덱스: `user_id` + `status` - 사용자별 상태별 조회
- 복합 인덱스: `category` + `status` - 카테고리별 상태별 조회

---

## 3️⃣ Collection: `experts`

### Document ID
- Firestore 자동 생성 ID 사용 (또는 숫자 ID를 문자열로 변환)

### Document 구조
```json
{
  "id": "string",                    // 전문가 ID (문자열로 저장)
  "name": "string",                  // 이름
  "profile_image": "string | null",  // 프로필 이미지 URL (선택)
  "specialty": "string",             // 전문 분야
  "categories": ["string"],          // 담당 카테고리 배열
  "experience_years": "number",      // 경력 연수
  "rating": "number",                // 평점 (0.0 ~ 5.0)
  "review_count": "number",          // 리뷰 수
  "consultation_count": "number",    // 상담 건수
  "introduction": "string | null",   // 자기소개 (선택)
  "law_firm": "string | null",       // 소속 법무법인 (선택)
  "certifications": ["string"] | null, // 자격증 배열 (선택)
  "is_available": "boolean"          // 상담 가능 여부 (기본값: true)
}
```

### 인덱스
- `specialty` (단일 필드 인덱스) - 전문 분야별 조회
- `is_available` (단일 필드 인덱스) - 상담 가능한 전문가 조회
- `rating` (단일 필드 인덱스) - 평점순 정렬
- 복합 인덱스: `specialty` + `is_available` - 전문 분야별 상담 가능한 전문가 조회
- 복합 인덱스: `categories` (배열) + `is_available` - 카테고리별 상담 가능한 전문가 조회

---

## 4️⃣ Collection: `reviews`

### Document ID
- Firestore 자동 생성 ID 사용

### Document 구조
```json
{
  "id": "string",              // Document ID
  "user_id": "string",         // 작성자 ID (users 컬렉션 참조)
  "expert_id": "string",       // 전문가 ID (experts 컬렉션 참조)
  "case_id": "string",         // 사건 ID (cases 컬렉션 참조)
  "rating": "number",          // 평점 (1.0 ~ 5.0)
  "content": "string",         // 리뷰 내용
  "created_at": "timestamp"    // 작성일시
}
```

### 인덱스
- `expert_id` (단일 필드 인덱스) - 전문가별 리뷰 조회
- `user_id` (단일 필드 인덱스) - 사용자별 리뷰 조회
- `case_id` (단일 필드 인덱스) - 사건별 리뷰 조회
- 복합 인덱스: `expert_id` + `created_at` - 전문가별 최신 리뷰 조회

---

## 🔗 Collection 간 관계

```
users (1) ──< (N) cases
              └── user_id 참조

experts (1) ──< (N) cases
              └── assigned_expert.id 참조

experts (1) ──< (N) reviews
              └── expert_id 참조

cases (1) ──< (1) reviews
              └── case_id 참조

users (1) ──< (N) reviews
              └── user_id 참조
```

---

## 📝 필드명 규칙

- **snake_case** 사용 (기존 모델과 일관성 유지)
- 예: `user_id`, `created_at`, `profile_image`

## 🗓️ 날짜 필드

- Firestore의 `Timestamp` 타입 사용
- Flutter에서는 `DateTime`과 자동 변환됨

## 🔢 ID 타입

- **users**: String (Firebase Auth uid)
- **cases**: String (Firestore 자동 생성)
- **experts**: String (숫자 ID를 문자열로 변환하여 저장)
- **reviews**: String (Firestore 자동 생성)

---

## ✅ 다음 단계

이 구조를 기반으로 Repository 구현을 진행합니다.






































