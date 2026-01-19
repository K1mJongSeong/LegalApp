import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:law_decode/domain/entities/expert_video.dart';

/// ExpertVideo Data Model
class ExpertVideoModel extends ExpertVideo {
  const ExpertVideoModel({
    required super.id,
    required super.expertAccountId,
    required super.videoUrl,
    required super.category,
    super.title,
    super.thumbnailUrl,
    super.isPublished,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Firestore → Model
  factory ExpertVideoModel.fromJson(Map<String, dynamic> json) {
    return ExpertVideoModel(
      id: json['id'] as String? ?? '',
      expertAccountId: json['expertAccountId'] as String? ??
          json['expert_account_id'] as String? ??
          '',
      videoUrl: json['videoUrl'] as String? ??
          json['video_url'] as String? ??
          '',
      category: json['category'] as String? ?? '',
      title: json['title'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String? ??
          json['thumbnail_url'] as String?,
      isPublished: json['isPublished'] as bool? ??
          json['is_published'] as bool? ??
          false,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ??
          (json['created_at'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ??
          (json['updated_at'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }

  /// Model → Firestore
  Map<String, dynamic> toJson() {
    return {
      'expertAccountId': expertAccountId,
      'videoUrl': videoUrl,
      'category': category,
      if (title != null) 'title': title,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      'isPublished': isPublished,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Entity → Model
  factory ExpertVideoModel.fromEntity(ExpertVideo entity) {
    return ExpertVideoModel(
      id: entity.id,
      expertAccountId: entity.expertAccountId,
      videoUrl: entity.videoUrl,
      category: entity.category,
      title: entity.title,
      thumbnailUrl: entity.thumbnailUrl,
      isPublished: entity.isPublished,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}










