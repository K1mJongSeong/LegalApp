import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;

/// 법령/판례 검색 API 서비스
///
/// - 웹: Supabase Edge Function (law-search) 호출
/// - 모바일: 국가법령정보 API 직접 호출
class LawApiService {
  /// 국가법령정보 API 키
  static const String _lawApiKey = 'jongseong.kim4124';

  /// 국가법령정보 API 베이스 URL
  static const String _lawApiBase = 'https://www.law.go.kr/DRF';

  /// Supabase Edge Function URL (웹용)
  static const String _edgeFunctionUrl =
      'https://nbzchnwqlfthzfcfkgbz.supabase.co/functions/v1/super-worker';

  /// 법령 키워드 검색
  Future<LawSearchResponse> searchLaws({
    required String query,
    int page = 1,
    int size = 5,
  }) async {
    try {
      if (kIsWeb) {
        // 웹: Supabase Edge Function 호출
        return await _searchLawsViaEdgeFunction(query, page, size);
      } else {
        // 모바일: 국가법령정보 API 직접 호출
        return await _searchLawsDirect(query, page, size);
      }
    } catch (e) {
      debugPrint('LawApiService.searchLaws error: $e');
      rethrow;
    }
  }

  /// 법령 상세 조회
  Future<LawDetail> getLawDetail(String mst) async {
    try {
      if (kIsWeb) {
        return await _getLawDetailViaEdgeFunction(mst);
      } else {
        return await _getLawDetailDirect(mst);
      }
    } catch (e) {
      debugPrint('LawApiService.getLawDetail error: $e');
      rethrow;
    }
  }

  /// 판례 키워드 검색
  Future<PrecedentSearchResponse> searchPrecedents({
    required String query,
    int page = 1,
    int size = 5,
  }) async {
    try {
      if (kIsWeb) {
        return await _searchPrecedentsViaEdgeFunction(query, page, size);
      } else {
        return await _searchPrecedentsDirect(query, page, size);
      }
    } catch (e) {
      debugPrint('LawApiService.searchPrecedents error: $e');
      rethrow;
    }
  }

  /// 판례 상세 조회
  Future<PrecedentDetail> getPrecedentDetail(String id) async {
    try {
      if (kIsWeb) {
        return await _getPrecedentDetailViaEdgeFunction(id);
      } else {
        return await _getPrecedentDetailDirect(id);
      }
    } catch (e) {
      debugPrint('LawApiService.getPrecedentDetail error: $e');
      rethrow;
    }
  }

  // =====================================================
  // 웹: Supabase Edge Function 호출
  // =====================================================

  Future<LawSearchResponse> _searchLawsViaEdgeFunction(
    String query,
    int page,
    int size,
  ) async {
    final response = await http.post(
      Uri.parse(_edgeFunctionUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'action': 'searchLaws',
        'query': query,
        'page': page,
        'size': size,
      }),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return LawSearchResponse.fromJsonEdgeFunction(data);
    } else {
      throw Exception('법령 검색 실패: ${response.statusCode}');
    }
  }

  Future<LawDetail> _getLawDetailViaEdgeFunction(String mst) async {
    final response = await http.post(
      Uri.parse(_edgeFunctionUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'action': 'getLawDetail',
        'mst': mst,
      }),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return LawDetail.fromJsonEdgeFunction(data);
    } else {
      throw Exception('법령 조회 실패: ${response.statusCode}');
    }
  }

  Future<PrecedentSearchResponse> _searchPrecedentsViaEdgeFunction(
    String query,
    int page,
    int size,
  ) async {
    final response = await http.post(
      Uri.parse(_edgeFunctionUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'action': 'searchPrecedents',
        'query': query,
        'page': page,
        'size': size,
      }),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PrecedentSearchResponse.fromJsonEdgeFunction(data);
    } else {
      throw Exception('판례 검색 실패: ${response.statusCode}');
    }
  }

  Future<PrecedentDetail> _getPrecedentDetailViaEdgeFunction(String id) async {
    final response = await http.post(
      Uri.parse(_edgeFunctionUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'action': 'getPrecedentDetail',
        'id': id,
      }),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PrecedentDetail.fromJsonEdgeFunction(data);
    } else {
      throw Exception('판례 조회 실패: ${response.statusCode}');
    }
  }

  // =====================================================
  // 모바일: 국가법령정보 API 직접 호출
  // =====================================================

  Future<LawSearchResponse> _searchLawsDirect(
    String query,
    int page,
    int size,
  ) async {
    final uri = Uri.parse('$_lawApiBase/lawSearch.do').replace(
      queryParameters: {
        'OC': _lawApiKey,
        'target': 'law',
        'type': 'JSON',
        'query': query,
        'display': size.toString(),
        'page': page.toString(),
      },
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return LawSearchResponse.fromJsonDirect(data);
    } else {
      throw Exception('법령 검색 실패: ${response.statusCode}');
    }
  }

  Future<LawDetail> _getLawDetailDirect(String mst) async {
    final uri = Uri.parse('$_lawApiBase/lawService.do').replace(
      queryParameters: {
        'OC': _lawApiKey,
        'target': 'law',
        'MST': mst,
        'type': 'JSON',
      },
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return LawDetail.fromJsonDirect(data);
    } else {
      throw Exception('법령 조회 실패: ${response.statusCode}');
    }
  }

  Future<PrecedentSearchResponse> _searchPrecedentsDirect(
    String query,
    int page,
    int size,
  ) async {
    final uri = Uri.parse('$_lawApiBase/lawSearch.do').replace(
      queryParameters: {
        'OC': _lawApiKey,
        'target': 'prec',
        'type': 'JSON',
        'query': query,
        'display': size.toString(),
        'page': page.toString(),
      },
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PrecedentSearchResponse.fromJsonDirect(data);
    } else {
      throw Exception('판례 검색 실패: ${response.statusCode}');
    }
  }

  Future<PrecedentDetail> _getPrecedentDetailDirect(String id) async {
    final uri = Uri.parse('$_lawApiBase/lawService.do').replace(
      queryParameters: {
        'OC': _lawApiKey,
        'target': 'prec',
        'ID': id,
        'type': 'JSON',
      },
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PrecedentDetail.fromJsonDirect(data);
    } else {
      throw Exception('판례 조회 실패: ${response.statusCode}');
    }
  }

  // =====================================================
  // 유틸리티 메서드
  // =====================================================

  /// 카테고리별 검색 키워드 매핑
  static String getCategoryKeyword(String category) {
    switch (category) {
      case 'civil':
        return '민법';
      case 'criminal':
        return '형법';
      case 'family':
        return '가족관계';
      case 'labor':
        return '근로기준법';
      case 'lease':
        return '주택임대차보호법';
      case 'real_estate':
        return '부동산';
      case 'corporate':
        return '상법';
      case 'traffic':
        return '도로교통법';
      case 'medical':
        return '의료법';
      case 'intellectual':
        return '저작권법';
      default:
        return '민법';
    }
  }

  /// 카테고리 이름으로 검색 키워드 추출
  static String getKeywordFromCategoryName(String categoryName) {
    if (categoryName.contains('임대차') ||
        categoryName.contains('전세') ||
        categoryName.contains('월세')) {
      return '주택임대차보호법';
    }
    if (categoryName.contains('이혼') ||
        categoryName.contains('양육') ||
        categoryName.contains('상속')) {
      return '가족관계등록';
    }
    if (categoryName.contains('근로') ||
        categoryName.contains('해고') ||
        categoryName.contains('임금')) {
      return '근로기준법';
    }
    if (categoryName.contains('교통') || categoryName.contains('사고')) {
      return '도로교통법';
    }
    if (categoryName.contains('형사') ||
        categoryName.contains('폭행') ||
        categoryName.contains('사기')) {
      return '형법';
    }
    if (categoryName.contains('부동산') || categoryName.contains('매매')) {
      return '부동산';
    }
    if (categoryName.contains('의료') || categoryName.contains('병원')) {
      return '의료법';
    }
    if (categoryName.contains('회사') || categoryName.contains('법인')) {
      return '상법';
    }
    return categoryName;
  }
}

// =====================================================
// Response Models
// =====================================================

/// 법령 검색 응답
class LawSearchResponse {
  final int total;
  final int page;
  final List<LawSummary> results;

  LawSearchResponse({
    required this.total,
    required this.page,
    required this.results,
  });

  /// Edge Function 응답 파싱
  factory LawSearchResponse.fromJsonEdgeFunction(Map<String, dynamic> json) {
    return LawSearchResponse(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      results: (json['results'] as List?)
              ?.map((e) => LawSummary.fromJsonEdgeFunction(e))
              .toList() ??
          [],
    );
  }

  /// 국가법령정보 API 직접 응답 파싱
  factory LawSearchResponse.fromJsonDirect(Map<String, dynamic> json) {
    final lawSearch = json['LawSearch'] ?? {};
    final total = int.tryParse(lawSearch['totalCnt']?.toString() ?? '0') ?? 0;

    var laws = lawSearch['law'];
    if (laws == null) {
      return LawSearchResponse(total: 0, page: 1, results: []);
    }
    if (laws is Map) {
      laws = [laws];
    }

    final results = (laws as List)
        .map((e) => LawSummary.fromJsonDirect(e as Map<String, dynamic>))
        .toList();

    return LawSearchResponse(
      total: total,
      page: int.tryParse(lawSearch['page']?.toString() ?? '1') ?? 1,
      results: results,
    );
  }
}

/// 법령 요약 정보
class LawSummary {
  final String mst;
  final String name;
  final String lawType;
  final String department;
  final String enforcementDate;

  LawSummary({
    required this.mst,
    required this.name,
    required this.lawType,
    required this.department,
    required this.enforcementDate,
  });

  factory LawSummary.fromJsonEdgeFunction(Map<String, dynamic> json) {
    return LawSummary(
      mst: json['mst'] ?? '',
      name: json['name'] ?? '',
      lawType: json['lawType'] ?? '',
      department: json['department'] ?? '',
      enforcementDate: json['enforcementDate'] ?? '',
    );
  }

  factory LawSummary.fromJsonDirect(Map<String, dynamic> json) {
    return LawSummary(
      mst: json['법령일련번호'] ?? '',
      name: json['법령명한글'] ?? '',
      lawType: json['법령구분명'] ?? '',
      department: json['소관부처명'] ?? '',
      enforcementDate: json['시행일자'] ?? '',
    );
  }
}

/// 법령 상세 정보
class LawDetail {
  final String mst;
  final String name;
  final String lawType;
  final String department;
  final String enforcementDate;
  final String promulgationDate;
  final List<LawArticle> articles;

  LawDetail({
    required this.mst,
    required this.name,
    required this.lawType,
    required this.department,
    required this.enforcementDate,
    required this.promulgationDate,
    required this.articles,
  });

  factory LawDetail.fromJsonEdgeFunction(Map<String, dynamic> json) {
    return LawDetail(
      mst: json['mst'] ?? '',
      name: json['name'] ?? '',
      lawType: json['lawType'] ?? '',
      department: json['department'] ?? '',
      enforcementDate: json['enforcementDate'] ?? '',
      promulgationDate: json['promulgationDate'] ?? '',
      articles: (json['articles'] as List?)
              ?.map((e) => LawArticle.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory LawDetail.fromJsonDirect(Map<String, dynamic> json) {
    final law = json['법령'] ?? {};
    final basicInfo = law['기본정보'] ?? {};
    final joMun = law['조문'] ?? {};
    var joList = joMun['조문단위'];

    if (joList == null) {
      joList = [];
    } else if (joList is Map) {
      joList = [joList];
    }

    final articles = (joList as List)
        .where((jo) => jo['조문여부'] == '조문')
        .map((jo) {
          String number = jo['조문번호'] ?? '';
          if (RegExp(r'^\d+$').hasMatch(number)) {
            number = '제$number조';
          }
          return LawArticle(
            number: number,
            title: jo['조문제목'] ?? '',
            content: jo['조문내용'] ?? '',
          );
        })
        .toList();

    final lawTypeValue = basicInfo['법종구분'];
    final lawType = lawTypeValue is Map
        ? (lawTypeValue['content'] ?? '')
        : (lawTypeValue?.toString() ?? '');

    return LawDetail(
      mst: (law['법령키'] ?? '').toString().length >= 6
          ? (law['법령키'] ?? '').toString().substring(0, 6)
          : (law['법령키'] ?? '').toString(),
      name: basicInfo['법령명_한글'] ?? '',
      lawType: lawType,
      department: basicInfo['소관부처명'] ?? '',
      enforcementDate: basicInfo['시행일자'] ?? '',
      promulgationDate: basicInfo['공포일자'] ?? '',
      articles: articles,
    );
  }
}

/// 법령 조문
class LawArticle {
  final String number;
  final String title;
  final String content;

  LawArticle({
    required this.number,
    required this.title,
    required this.content,
  });

  factory LawArticle.fromJson(Map<String, dynamic> json) {
    return LawArticle(
      number: json['number'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
    );
  }
}

/// 판례 검색 응답
class PrecedentSearchResponse {
  final int total;
  final List<PrecedentSummary> results;

  PrecedentSearchResponse({
    required this.total,
    required this.results,
  });

  factory PrecedentSearchResponse.fromJsonEdgeFunction(Map<String, dynamic> json) {
    return PrecedentSearchResponse(
      total: json['total'] ?? 0,
      results: (json['results'] as List?)
              ?.map((e) => PrecedentSummary.fromJsonEdgeFunction(e))
              .toList() ??
          [],
    );
  }

  factory PrecedentSearchResponse.fromJsonDirect(Map<String, dynamic> json) {
    final precSearch = json['PrecSearch'] ?? {};
    final total = int.tryParse(precSearch['totalCnt']?.toString() ?? '0') ?? 0;

    var precs = precSearch['prec'];
    if (precs == null) {
      return PrecedentSearchResponse(total: 0, results: []);
    }
    if (precs is Map) {
      precs = [precs];
    }

    final results = (precs as List)
        .map((e) => PrecedentSummary.fromJsonDirect(e as Map<String, dynamic>))
        .toList();

    return PrecedentSearchResponse(
      total: total,
      results: results,
    );
  }
}

/// 판례 요약 정보
class PrecedentSummary {
  final String id;
  final String caseNumber;
  final String caseName;
  final String court;
  final String judgmentDate;
  final String caseType;
  final String summary;

  PrecedentSummary({
    required this.id,
    required this.caseNumber,
    required this.caseName,
    required this.court,
    required this.judgmentDate,
    required this.caseType,
    required this.summary,
  });

  factory PrecedentSummary.fromJsonEdgeFunction(Map<String, dynamic> json) {
    return PrecedentSummary(
      id: json['id']?.toString() ?? '',
      caseNumber: json['caseNumber'] ?? '',
      caseName: json['caseName'] ?? '',
      court: json['court'] ?? '대법원',
      judgmentDate: json['judgmentDate'] ?? '',
      caseType: json['caseType'] ?? '',
      summary: json['summary'] ?? '',
    );
  }

  factory PrecedentSummary.fromJsonDirect(Map<String, dynamic> json) {
    return PrecedentSummary(
      id: json['판례일련번호']?.toString() ?? '',
      caseNumber: json['사건번호'] ?? '',
      caseName: json['사건명'] ?? '',
      court: json['법원명'] ?? '대법원',
      judgmentDate: json['선고일자'] ?? '',
      caseType: json['사건종류명'] ?? '',
      summary: json['판시사항'] ?? json['판결요지'] ?? '',
    );
  }
}

/// 판례 상세 정보
class PrecedentDetail {
  final String id;
  final String caseNumber;
  final String caseName;
  final String court;
  final String judgmentDate;
  final String caseType;
  final String verdict;         // 선고
  final String verdictType;     // 판결유형
  final String holding;         // 판시사항
  final String summary;         // 판결요지
  final String refArticles;     // 참조조문
  final String refCases;        // 참조판례
  final String content;         // 판례내용 (전문)

  PrecedentDetail({
    required this.id,
    required this.caseNumber,
    required this.caseName,
    required this.court,
    required this.judgmentDate,
    required this.caseType,
    required this.verdict,
    required this.verdictType,
    required this.holding,
    required this.summary,
    required this.refArticles,
    required this.refCases,
    required this.content,
  });

  factory PrecedentDetail.fromJsonEdgeFunction(Map<String, dynamic> json) {
    return PrecedentDetail(
      id: json['id']?.toString() ?? '',
      caseNumber: json['caseNumber'] ?? '',
      caseName: json['caseName'] ?? '',
      court: json['court'] ?? '대법원',
      judgmentDate: json['judgmentDate'] ?? '',
      caseType: json['caseType'] ?? '',
      verdict: json['verdict'] ?? '',
      verdictType: json['verdictType'] ?? '',
      holding: json['holding'] ?? '',
      summary: json['summary'] ?? '',
      refArticles: json['refArticles'] ?? '',
      refCases: json['refCases'] ?? '',
      content: json['content'] ?? '',
    );
  }

  factory PrecedentDetail.fromJsonDirect(Map<String, dynamic> json) {
    final prec = json['PrecService'] ?? {};
    return PrecedentDetail(
      id: prec['판례정보일련번호']?.toString() ?? '',
      caseNumber: prec['사건번호'] ?? '',
      caseName: prec['사건명'] ?? '',
      court: prec['법원명'] ?? '대법원',
      judgmentDate: prec['선고일자'] ?? '',
      caseType: prec['사건종류명'] ?? '',
      verdict: prec['선고'] ?? '',
      verdictType: prec['판결유형'] ?? '',
      holding: _cleanHtml(prec['판시사항'] ?? ''),
      summary: _cleanHtml(prec['판결요지'] ?? ''),
      refArticles: _cleanHtml(prec['참조조문'] ?? ''),
      refCases: _cleanHtml(prec['참조판례'] ?? ''),
      content: _cleanHtml(prec['판례내용'] ?? ''),
    );
  }

  /// HTML 태그 정리
  static String _cleanHtml(String text) {
    return text
        .replaceAll('<br/>', '\n')
        .replaceAll('<br>', '\n')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .trim();
  }
}
