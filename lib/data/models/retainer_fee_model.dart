import '../../domain/entities/retainer_fee.dart';

/// 수임료 정보 모델 (Firestore JSON 변환)
class RetainerFeeModel extends RetainerFee {
  const RetainerFeeModel({
    super.id,
    super.lawsuitType,
    super.retainerFeeAmount,
    super.retainerFeeRange,
    super.successFeeUnit,
    super.successFeeValue,
    super.successFeeRange,
  });

  /// Firestore → Model
  factory RetainerFeeModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return RetainerFeeModel(
      id: id ?? json['id'] as String?,
      lawsuitType: json['lawsuitType'] as String? ??
          json['lawsuit_type'] as String?,
      retainerFeeAmount: json['retainerFeeAmount'] as int? ??
          json['retainer_fee_amount'] as int?,
      retainerFeeRange: json['retainerFeeRange'] as String? ??
          json['retainer_fee_range'] as String?,
      successFeeUnit: json['successFeeUnit'] as String? ??
          json['success_fee_unit'] as String?,
      successFeeValue: json['successFeeValue'] as String? ??
          json['success_fee_value'] as String?,
      successFeeRange: json['successFeeRange'] as String? ??
          json['success_fee_range'] as String?,
    );
  }

  /// Model → Firestore
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (lawsuitType != null) 'lawsuitType': lawsuitType,
      if (retainerFeeAmount != null) 'retainerFeeAmount': retainerFeeAmount,
      if (retainerFeeRange != null) 'retainerFeeRange': retainerFeeRange,
      if (successFeeUnit != null) 'successFeeUnit': successFeeUnit,
      if (successFeeValue != null) 'successFeeValue': successFeeValue,
      if (successFeeRange != null) 'successFeeRange': successFeeRange,
    };
  }

  /// Entity → Model
  factory RetainerFeeModel.fromEntity(RetainerFee entity) {
    return RetainerFeeModel(
      id: entity.id,
      lawsuitType: entity.lawsuitType,
      retainerFeeAmount: entity.retainerFeeAmount,
      retainerFeeRange: entity.retainerFeeRange,
      successFeeUnit: entity.successFeeUnit,
      successFeeValue: entity.successFeeValue,
      successFeeRange: entity.successFeeRange,
    );
  }
}







