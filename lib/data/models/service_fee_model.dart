import '../../domain/entities/service_fee.dart';

/// 서비스 요금 모델 (Firestore JSON 변환)
class ServiceFeeModel extends ServiceFee {
  const ServiceFeeModel({
    super.id,
    super.serviceType,
    super.unit,
    super.amount,
    super.feeRange,
  });

  /// Firestore → Model
  factory ServiceFeeModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return ServiceFeeModel(
      id: id ?? json['id'] as String?,
      serviceType: json['serviceType'] as String? ??
          json['service_type'] as String?,
      unit: json['unit'] as String?,
      amount: json['amount'] as int?,
      feeRange: json['feeRange'] as String? ??
          json['fee_range'] as String?,
    );
  }

  /// Model → Firestore
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (serviceType != null) 'serviceType': serviceType,
      if (unit != null) 'unit': unit,
      if (amount != null) 'amount': amount,
      if (feeRange != null) 'feeRange': feeRange,
    };
  }

  /// Entity → Model
  factory ServiceFeeModel.fromEntity(ServiceFee entity) {
    return ServiceFeeModel(
      id: entity.id,
      serviceType: entity.serviceType,
      unit: entity.unit,
      amount: entity.amount,
      feeRange: entity.feeRange,
    );
  }
}










