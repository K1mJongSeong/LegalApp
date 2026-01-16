import '../../domain/entities/publication.dart';

/// 논문/출판 모델 (Firestore JSON 변환)
class PublicationModel extends Publication {
  const PublicationModel({
    super.id,
    super.category,
    super.year,
    super.title,
    super.url,
    super.isRepresentative,
  });

  /// Firestore → Model
  factory PublicationModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return PublicationModel(
      id: id ?? json['id'] as String?,
      category: json['category'] as String?,
      year: json['year'] as int?,
      title: json['title'] as String?,
      url: json['url'] as String?,
      isRepresentative: json['isRepresentative'] as bool? ??
          json['is_representative'] as bool? ??
          false,
    );
  }

  /// Model → Firestore
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (year != null) 'year': year,
      if (title != null) 'title': title,
      if (url != null) 'url': url,
      'isRepresentative': isRepresentative,
    };
  }

  /// Entity → Model
  factory PublicationModel.fromEntity(Publication entity) {
    return PublicationModel(
      id: entity.id,
      category: entity.category,
      year: entity.year,
      title: entity.title,
      url: entity.url,
      isRepresentative: entity.isRepresentative,
    );
  }
}



