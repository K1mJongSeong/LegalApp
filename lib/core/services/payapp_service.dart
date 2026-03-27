import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class PayAppService {
  static const String _apiUrl = 'https://api.payapp.kr/oapi/apiLoad.html';

  /// 웹에서 CORS 우회를 위한 Supabase Edge Function 프록시 URL
  static const String _webProxyUrl =
      'https://nbzchnwqlfthzfcfkgbz.supabase.co/functions/v1/payapp-proxy';

  /// PayApp 판매자 아이디 (PayApp 가입 후 발급)
  static const String sellerId = 'miaer789'; //테스트 아이디 : payapptest

  /// 결제 요청을 생성하고 결제 URL을 반환합니다.
  static Future<PayAppResult> requestPayment({
    required String goodName,
    required int price,
    required String recvPhone,
    String? memo,
    String? feedbackUrl,
    String? var1,
    String? var2,
  }) async {
    final params = <String, String>{
      'cmd': 'payrequest',
      'userid': sellerId,
      'goodname': goodName,
      'price': price.toString(),
      'recvphone': recvPhone,
    };

    if (memo != null) params['memo'] = memo;
    if (feedbackUrl != null) params['feedbackurl'] = feedbackUrl;
    if (var1 != null) params['var1'] = var1;
    if (var2 != null) params['var2'] = var2;

    try {
      final response = kIsWeb
          ? await _callViaProxy(params)
          : await http.post(Uri.parse(_apiUrl), body: params);

      if (response.statusCode == 200) {
        // 웹 프록시는 JSON, 모바일은 query string 응답
        if (kIsWeb) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final state = data['state']?.toString();
          final mulNo = data['mul_no']?.toString();
          final payUrl = data['payurl']?.toString();
          final errorMessage = data['errorMessage']?.toString();

          if (state == '1' && payUrl != null) {
            return PayAppResult(
              success: true,
              mulNo: mulNo ?? '',
              payUrl: Uri.decodeFull(payUrl),
            );
          } else {
            return PayAppResult(
              success: false,
              errorMessage: errorMessage ?? '결제 요청에 실패했습니다.',
            );
          }
        } else {
          final result = Uri.splitQueryString(response.body);
          final state = result['state'];
          final mulNo = result['mul_no'];
          final payUrl = result['payurl'];
          final errorMessage = result['errorMessage'];

          if (state == '1' && payUrl != null) {
            return PayAppResult(
              success: true,
              mulNo: mulNo ?? '',
              payUrl: Uri.decodeFull(payUrl),
            );
          } else {
            return PayAppResult(
              success: false,
              errorMessage: errorMessage ?? '결제 요청에 실패했습니다.',
            );
          }
        }
      } else {
        return PayAppResult(
          success: false,
          errorMessage: '서버 오류가 발생했습니다. (${response.statusCode})',
        );
      }
    } catch (e) {
      return PayAppResult(
        success: false,
        errorMessage: '네트워크 오류: $e',
      );
    }
  }

  /// 웹에서 Supabase Edge Function 프록시를 통해 PayApp API 호출
  static Future<http.Response> _callViaProxy(Map<String, String> params) {
    return http.post(
      Uri.parse(_webProxyUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(params),
    );
  }

  // TODO: 추후 Firebase Cloud Functions + feedbackUrl 웹훅으로 서버 기반 결제 검증 구현
}

class PayAppResult {
  final bool success;
  final String mulNo;
  final String payUrl;
  final String? errorMessage;

  PayAppResult({
    required this.success,
    this.mulNo = '',
    this.payUrl = '',
    this.errorMessage,
  });
}
