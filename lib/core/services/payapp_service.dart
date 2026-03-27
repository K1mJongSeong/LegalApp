import 'package:http/http.dart' as http;

class PayAppService {
  static const String _apiUrl = 'https://api.payapp.kr/oapi/apiLoad.html';

  /// PayApp 판매자 아이디 (PayApp 가입 후 발급)
  static const String sellerId = 'miaer789'; //테스트 아이디 : payapptest

  /// 결제 요청을 생성하고 결제 URL을 반환합니다.
  ///
  /// [goodName] 상품명
  /// [price] 결제 금액 (최소 1,000원)
  /// [recvPhone] 수신 휴대폰번호
  /// [memo] 결제 메모 (선택)
  /// [feedbackUrl] 결제 완료 피드백 URL (선택)
  /// [var1], [var2] 임의 변수 (선택)
  static Future<PayAppResult> requestPayment({
    required String goodName,
    required int price,
    required String recvPhone,
    String? memo,
    String? feedbackUrl,
    String? var1,
    String? var2,
  }) async {
    final body = <String, String>{
      'cmd': 'payrequest',
      'userid': sellerId,
      'goodname': goodName,
      'price': price.toString(),
      'recvphone': recvPhone,
    };

    if (memo != null) body['memo'] = memo;
    if (feedbackUrl != null) body['feedbackurl'] = feedbackUrl;
    if (var1 != null) body['var1'] = var1;
    if (var2 != null) body['var2'] = var2;

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        body: body,
      );

      if (response.statusCode == 200) {
        final params = Uri.splitQueryString(response.body);
        final state = params['state'];
        final mulNo = params['mul_no'];
        final payUrl = params['payurl'];
        final errorMessage = params['errorMessage'];

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
