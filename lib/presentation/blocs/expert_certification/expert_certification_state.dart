import 'package:equatable/equatable.dart';
import 'package:law_decode/domain/entities/expert_certification.dart';

/// ExpertCertification States
abstract class ExpertCertificationState extends Equatable {
  const ExpertCertificationState();

  @override
  List<Object?> get props => [];
}

/// 초기 상태
class CertificationInitial extends ExpertCertificationState {}

/// 제출 중
class CertificationSubmitting extends ExpertCertificationState {}

/// 제출 성공
class CertificationSuccess extends ExpertCertificationState {
  final ExpertCertification certification;

  const CertificationSuccess(this.certification);

  @override
  List<Object?> get props => [certification];
}

/// 제출 실패
class CertificationFailure extends ExpertCertificationState {
  final String message;

  const CertificationFailure(this.message);

  @override
  List<Object?> get props => [message];
}



















