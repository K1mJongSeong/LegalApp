/// 수임료 정보 엔티티
class RetainerFee {
  final String? id; // Firestore document ID (optional for new entries)
  final String? lawsuitType; // 소송 종류
  final int? retainerFeeAmount; // 착수금 금액
  final String? retainerFeeRange; // 착수금 요금범위 ('fixed', 'from', 'range', 'negotiable')
  final String? successFeeUnit; // 성공보수 단위 ('amount' or 'percentage')
  final String? successFeeValue; // 성공보수 금액 또는 백분율
  final String? successFeeRange; // 성공보수 요금범위 ('fixed', 'from', 'range', 'negotiable')

  const RetainerFee({
    this.id,
    this.lawsuitType,
    this.retainerFeeAmount,
    this.retainerFeeRange,
    this.successFeeUnit,
    this.successFeeValue,
    this.successFeeRange,
  });

  RetainerFee copyWith({
    String? id,
    String? lawsuitType,
    int? retainerFeeAmount,
    String? retainerFeeRange,
    String? successFeeUnit,
    String? successFeeValue,
    String? successFeeRange,
  }) {
    return RetainerFee(
      id: id ?? this.id,
      lawsuitType: lawsuitType ?? this.lawsuitType,
      retainerFeeAmount: retainerFeeAmount ?? this.retainerFeeAmount,
      retainerFeeRange: retainerFeeRange ?? this.retainerFeeRange,
      successFeeUnit: successFeeUnit ?? this.successFeeUnit,
      successFeeValue: successFeeValue ?? this.successFeeValue,
      successFeeRange: successFeeRange ?? this.successFeeRange,
    );
  }
}







