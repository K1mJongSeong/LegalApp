import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:law_decode/domain/entities/expert_post.dart';

/// ExpertPost Data Model
class ExpertPostModel extends ExpertPost {
  const ExpertPostModel({
    required super.id,
    required super.expertAccountId,
    required super.postType,
    required super.title,
    super.category,
    super.tags,
    required super.content,
    super.imageUrl,
    super.isPublished,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Firestore → Model
  factory ExpertPostModel.fromJson(Map<String, dynamic> json) {
    return ExpertPostModel(
      id: json['id'] as String? ?? '',
      expertAccountId: json['expertAccountId'] as String? ??
          json['expert_account_id'] as String? ??
          '',
      postType: json['postType'] as String? ??
          json['post_type'] as String? ??
          'guide',
      title: json['title'] as String? ?? '',
      category: json['category'] as String?,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      content: json['content'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String?,
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
      'postType': postType,
      'title': title,
      if (category != null) 'category': category,
      'tags': tags,
      'content': content,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'isPublished': isPublished,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Entity → Model
  factory ExpertPostModel.fromEntity(ExpertPost entity) {
    return ExpertPostModel(
      id: entity.id,
      expertAccountId: entity.expertAccountId,
      postType: entity.postType,
      title: entity.title,
      category: entity.category,
      tags: entity.tags,
      content: entity.content,
      imageUrl: entity.imageUrl,
      isPublished: entity.isPublished,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}




