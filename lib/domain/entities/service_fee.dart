/// 서비스 요금 엔티티
class ServiceFee {
  final String? id; // Firestore document ID (optional for new entries)
  final String? serviceType; // 제공서비스 종류
  final String? unit; // 단위 ('원' or other)
  final int? amount; // 금액
  final String? feeRange; // 요금범위 ('고정금액', '~부터', '범위', '협의')

  const ServiceFee({
    this.id,
    this.serviceType,
    this.unit,
    this.amount,
    this.feeRange,
  });

  ServiceFee copyWith({
    String? id,
    String? serviceType,
    String? unit,
    int? amount,
    String? feeRange,
  }) {
    return ServiceFee(
      id: id ?? this.id,
      serviceType: serviceType ?? this.serviceType,
      unit: unit ?? this.unit,
      amount: amount ?? this.amount,
      feeRange: feeRange ?? this.feeRange,
    );
  }
}
