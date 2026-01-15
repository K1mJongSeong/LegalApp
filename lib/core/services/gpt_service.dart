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
당신은 한국 법률 전문가입니다. 다음 법률 사건을 분석해주세요.

[사건 분야]: $category
[긴급도]: $urgency${progressItems.isNotEmpty ? '\n$progressItems' : ''}${goal.isNotEmpty ? '\n[상담 목표]: $goal' : ''}
[사건 내용]: 
$description

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


