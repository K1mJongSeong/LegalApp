import 'package:equatable/equatable.dart';

/// 전문가 동영상 엔티티
class ExpertVideo extends Equatable {
  final String id; // videos document id
  final String expertAccountId; // 전문가 계정 ID
  final String videoUrl; // 동영상 URL (YouTube, Vimeo 등)
  final String category; // 카테고리
  final String? title; // 제목 (동영상에서 추출)
  final String? thumbnailUrl; // 썸네일 URL (동영상에서 추출)
  final bool isPublished; // 발행 여부
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpertVideo({
    required this.id,
    required this.expertAccountId,
    required this.videoUrl,
    required this.category,
    this.title,
    this.thumbnailUrl,
    this.isPublished = false,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        expertAccountId,
        videoUrl,
        category,
        title,
        thumbnailUrl,
        isPublished,
        createdAt,
        updatedAt,
      ];

  ExpertVideo copyWith({
    String? id,
    String? expertAccountId,
    String? videoUrl,
    String? category,
    String? title,
    String? thumbnailUrl,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpertVideo(
      id: id ?? this.id,
      expertAccountId: expertAccountId ?? this.expertAccountId,
      videoUrl: videoUrl ?? this.videoUrl,
      category: category ?? this.category,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}















