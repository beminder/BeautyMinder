import 'package:beautyminder/dto/user_model.dart';

class ReviewModel {
  ReviewModel({
    required this.id,
    required this.content,
    required this.rating,
    required this.images,
    required this.user,
    required this.cosmetic,
    required this.createdAt,
  });

  late final String id;
  late final String content;
  late final int rating;
  late final List<String> images;
  late final User user;
  late final Cosmetic cosmetic;
  late final String createdAt;

  @override
  String toString() {
    return '''
ReviewModel {
  id: $id,
  content: $content,
  rating: $rating,
  images: $images,
  user: $user,
  cosmetic: $cosmetic,
  createdAt: $createdAt
}''';
  }

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      rating: json['rating'] ?? 0,
      images: List<String>.from(json['images'] ?? ''),
      user: User.fromJson(json['user'] ?? ''),
      cosmetic: Cosmetic.fromJson(json['cosmetic'] ?? ''),
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'rating': rating,
      'images': images,
      'user': user.toJson(),
      'cosmetic': cosmetic.toJson(),
      'createdAt': createdAt,
    };
  }
}

class Cosmetic {
  Cosmetic({
    required this.id,
    required this.name,
    required this.brand,
  });

  late final String id;
  late final String name;
  late final String brand;

  @override
  String toString() {
    return '''
Cosmetic {
  id: $id,
  name: $name,
  brand: $brand
}''';
  }

  factory Cosmetic.fromJson(Map<String, dynamic> json) {
    return Cosmetic(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
    };
  }
}
