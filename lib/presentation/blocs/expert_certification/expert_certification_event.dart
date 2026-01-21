import 'dart:io';
import 'package:equatable/equatable.dart';

/// ExpertCertification Events
abstract class ExpertCertificationEvent extends Equatable {
  const ExpertCertificationEvent();

  @override
  List<Object?> get props => [];
}

/// 서류 인증 신청
class SubmitDocumentCertification extends ExpertCertificationEvent {
  final String userId;
  final File idCardFile;
  final File licenseFile;
  final String? expertAccountId;

  const SubmitDocumentCertification({
    required this.userId,
    required this.idCardFile,
    required this.licenseFile,
    this.expertAccountId,
  });

  @override
  List<Object?> get props => [userId, idCardFile, licenseFile, expertAccountId];
}

/// 즉시 인증 신청
class SubmitInstantCertification extends ExpertCertificationEvent {
  final String userId;
  final String registrationNumber;
  final String idNumber;
  final String? expertAccountId;

  const SubmitInstantCertification({
    required this.userId,
    required this.registrationNumber,
    required this.idNumber,
    this.expertAccountId,
  });

  @override
  List<Object?> get props =>
      [userId, registrationNumber, idNumber, expertAccountId];
}



















