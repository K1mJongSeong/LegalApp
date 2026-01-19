import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// GPT API
///
/// - 모바일(Android/iOS): .env 에서 OPENAI_API_KEY를 읽어 OpenAI API를 직접 호출
/// - 웹(Flutter Web): Supabase Edge Function / 서버 프록시 엔드포인트로만 호출
class GptService {
  /// 모바일에서 사용할 OpenAI API Key (.env)
  static String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';

  /// OpenAI Chat Completions 엔드포인트
  static const String _openAiBaseUrl =
      'https://api.openai.com/v1/chat/completions';

  /// 웹에서 사용할 서버(또는 Supabase Edge Function) 프록시 엔드포인트
  ///
  /// 예: https://<project>.supabase.co/functions/v1/analyze-legal-case
  /// 실제 URL은 프로젝트에 맞게 수정 필요
  static const String _webProxyUrl =
      'https://nbzchnwqlfthzfcfkgbz.supabase.co/functions/v1/ai-proxy';

  Future<CaseSummaryResult> analyzeLegalCase({
    required String category,
    required String description,
    required String urgency,
    String progressItems = '',
    String goal = '',
  }) async {
    final prompt = '''
당신은 법률 판단이나 조언을 하지 않는 "사건 정리 및 요약 AI"입니다.
당신의 역할은 사용자가 입력한 내용을 바탕으로 사실관계와 상황을
이해하기 쉽게 정리하는 것입니다.

⚠️ 반드시 지켜야 할 규칙
1. 법률적 판단, 결론, 조언을 하지 마세요.
2. "위법이다", "처벌된다", "승소 가능성"과 같은 표현을 사용하지 마세요.
3. 특정 행동을 권유하거나 방향을 제시하지 마세요.
4. 변호사, 노무사, 법무사의 역할을 대신하지 마세요.
5. 단정적인 표현 대신 중립적이고 설명적인 문장을 사용하세요.
6. 모든 내용은 설명·정리 목적이며, 판단을 내리지 마세요.
---
📌 입력 정보
아래는 사용자가 자신의 사건에 대해 입력한 내용입니다.
[사건 분야]: $category
[긴급도]: $urgency${progressItems.isNotEmpty ? '\n$progressItems' : ''}${goal.isNotEmpty ? '\n[상담 목표]: $goal' : ''}
[사건 내용]: 
$description
---

📌 당신이 해야 할 일

사용자의 입력 내용을 바탕으로, **아래 항목에 맞게 사건을 정리하세요.**

#### 1️⃣ 사건 개요
- 언제, 어디서, 누구 사이에서 발생한 일인지
- 사용자가 겪고 있는 상황을 사실 중심으로 요약
- 판단이나 평가 없이 서술

#### 2️⃣ 핵심 사실 정리
- 사건에서 중요해 보이는 사실을 항목별로 정리
- 감정적 표현이 포함된 경우, 사실과 구분하여 정리

#### 3️⃣ 현재 사용자가 느끼는 주요 고민
- 사용자의 서술에서 드러나는 걱정, 혼란, 불확실성 요소를 정리
- "~로 보입니다", "~에 대해 고민하고 있는 것으로 보입니다"와 같은 추정형 표현 사용

#### 4️⃣ 쟁점으로 보일 수 있는 부분 (판단 없이)
- 법률적 결론을 내리지 말 것
- "일반적으로 쟁점이 될 수 있는 부분으로는 다음과 같은 요소들이 있습니다"라는 형식으로 작성
- 해당 사건에 실제로 적용된다고 단정하지 말 것

---

📌 출력 형식 (반드시 JSON)
다음 형식으로 JSON 응답해주세요:
{
  "summary": "사건 요약 (2-3문장)",
  "relatedLaws": [
    {
      "lawName": "관련 법률명",
      "article": "조항 (예: 제43조)",
      "title": "조항 제목",
      "content": "조항 내용 요약"
    }
  ],
  "similarCases": [
    {
      "caseNumber": "판례 번호 (예: 2020다123456)",
      "court": "법원 (예: 대법원)",
      "summary": "판례 요약"
    }
  ],
  "expertCount": 추천 전문가 수 (숫자),
  "expertDescription": "전문가 추천 설명"
}

반드시 유효한 JSON 형식으로만 응답하세요.
''';
    try {
      final response = kIsWeb
          ? await _callWebProxy(
              category: category,
              description: description,
              urgency: urgency,
              progressItems: progressItems,
              goal: goal,
            )
          : await _callOpenAiDirect(prompt);

      if (response.statusCode == 200) {
        final body = response.body;
        final data = jsonDecode(body);

        // 웹 프록시에서는 바로 JSON을 반환한다고 가정
        if (kIsWeb) {
          return CaseSummaryResult.fromJson(data as Map<String, dynamic>);
        }

        // 모바일(OpenAI 직접 호출) 응답 파싱
        final content = data['choices'][0]['message']['content'] as String;

        // JSON 파싱
        final jsonStart = content.indexOf('{');
        final jsonEnd = content.lastIndexOf('}') + 1;
        final jsonStr = content.substring(jsonStart, jsonEnd);
        final result = jsonDecode(jsonStr);

        return CaseSummaryResult.fromJson(result);
      } else if (response.statusCode == 429) {
        // Rate Limit 초과 - 크레딧 부족 또는 요청 한도 초과
        throw Exception(
            'API 요청 한도 초과 (429): OpenAI 크레딧을 확인하세요. https://platform.openai.com/usage');
      } else {
        throw Exception(
            'API 요청 실패: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // 오류 디버깅
      print('GPT API Error: $e');
      if (!kIsWeb) {
        print(
            'API Key loaded: ${_apiKey.isNotEmpty ? "Yes (${_apiKey.substring(0, 10)}...)" : "No - EMPTY!"}');
      }

      // 오류 시 기본 응답 반환
      return CaseSummaryResult(
        summary: '사용자 설명에 따르면 법률적 검토가 필요한 상황입니다. 전문가와 상담을 권장합니다.',
        relatedLaws: [
          RelatedLaw(
            lawName: '관련 법률',
            article: '해당 조항',
            title: '(분석 중 오류 발생)',
            content: '전문가와 상담하여 정확한 법률 정보를 확인하세요.',
          ),
        ],
        similarCases: [
          SimilarCase(
            caseNumber: '관련 판례',
            court: '법원',
            summary: '유사 판례 분석이 필요합니다.',
          ),
        ],
        expertCount: 10,
        expertDescription: '해당 분야를 전문으로 하는 전문가가 있습니다.',
      );
    }
  }

  /// 모바일에서 OpenAI API를 직접 호출
  Future<http.Response> _callOpenAiDirect(String prompt) {
    return http.post(
      Uri.parse(_openAiBaseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.7,
        'max_tokens': 2000,
      }),
    );
  }

  /// 웹에서 Supabase Edge Function / 서버 프록시를 호출
  Future<http.Response> _callWebProxy({
    required String category,
    required String description,
    required String urgency,
    required String progressItems,
    required String goal,
  }) {
    // 서버/프록시에서는 category, description 등만 받아서
    // 서버 쪽에서 OpenAI Prompt를 구성하도록 위임하는 것이 이상적이지만,
    // 현재는 클라이언트와 동일한 필드를 전달하는 형태로 구현
    return http.post(
      Uri.parse(_webProxyUrl),
      headers: const {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'category': category,
        'description': description,
        'urgency': urgency,
        'progressItems': progressItems,
        'goal': goal,
      }),
    );
  }
}

/// 사건 요약 결과
class CaseSummaryResult {
  final String summary;
  final List<RelatedLaw> relatedLaws;
  final List<SimilarCase> similarCases;
  final int expertCount;
  final String expertDescription;

  CaseSummaryResult({
    required this.summary,
    required this.relatedLaws,
    required this.similarCases,
    required this.expertCount,
    required this.expertDescription,
  });

  factory CaseSummaryResult.fromJson(Map<String, dynamic> json) {
    return CaseSummaryResult(
      summary: json['summary'] ?? '',
      relatedLaws: (json['relatedLaws'] as List?)
              ?.map((e) => RelatedLaw.fromJson(e))
              .toList() ??
          [],
      similarCases: (json['similarCases'] as List?)
              ?.map((e) => SimilarCase.fromJson(e))
              .toList() ??
          [],
      expertCount: json['expertCount'] ?? 0,
      expertDescription: json['expertDescription'] ?? '',
    );
  }
}

/// 관련 법령
class RelatedLaw {
  final String lawName;
  final String article;
  final String title;
  final String content;

  RelatedLaw({
    required this.lawName,
    required this.article,
    required this.title,
    required this.content,
  });

  factory RelatedLaw.fromJson(Map<String, dynamic> json) {
    return RelatedLaw(
      lawName: json['lawName'] ?? '',
      article: json['article'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
    );
  }
}

/// 유사 판례
class SimilarCase {
  final String caseNumber;
  final String court;
  final String summary;

  SimilarCase({
    required this.caseNumber,
    required this.court,
    required this.summary,
  });

  factory SimilarCase.fromJson(Map<String, dynamic> json) {
    return SimilarCase(
      caseNumber: json['caseNumber'] ?? '',
      court: json['court'] ?? '',
      summary: json['summary'] ?? '',
    );
  }
}