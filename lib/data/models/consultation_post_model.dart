import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:law_decode/domain/entities/consultation_post.dart';

/// ConsultationPost Data Model
class ConsultationPostModel extends ConsultationPost {
  const ConsultationPostModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.content,
    required super.incidentDate,
    super.category,
    required super.createdAt,
    required super.updatedAt,
    super.views,
    super.comments,
  });

  /// Firestore → Model
  factory ConsultationPostModel.fromJson(Map<String, dynamic> json) {
    return ConsultationPostModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      incidentDate: (json['incidentDate'] as Timestamp?)?.toDate() ??
          (json['incident_date'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      category: json['category'] as String?,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ??
          (json['created_at'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ??
          (json['updated_at'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      views: json['views'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
    );
  }

  /// Model → Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'incidentDate': Timestamp.fromDate(incidentDate),
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'views': views,
      'comments': comments,
    };
  }
}










