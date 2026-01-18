import 'package:equatable/equatable.dart';

/// 전문가 포스트 엔티티
class ExpertPost extends Equatable {
  final String id; // posts document id
  final String expertAccountId; // 전문가 계정 ID
  final String postType; // 'guide', 'case', 'essay'
  final String title; // 제목
  final String? category; // 카테고리 (법률가이드, 해결사례만)
  final List<String> tags; // 태그 (법률가이드, 해결사례만)
  final String content; // 본문
  final String? imageUrl; // 대표이미지 URL
  final bool isPublished; // 발행 여부
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpertPost({
    required this.id,
    required this.expertAccountId,
    required this.postType,
    required this.title,
    this.category,
    this.tags = const [],
    required this.content,
    this.imageUrl,
    this.isPublished = false,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        expertAccountId,
        postType,
        title,
        category,
        tags,
        content,
        imageUrl,
        isPublished,
        createdAt,
        updatedAt,
      ];

  ExpertPost copyWith({
    String? id,
    String? expertAccountId,
    String? postType,
    String? title,
    String? category,
    List<String>? tags,
    String? content,
    String? imageUrl,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpertPost(
      id: id ?? this.id,
      expertAccountId: expertAccountId ?? this.expertAccountId,
      postType: postType ?? this.postType,
      title: title ?? this.title,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}









