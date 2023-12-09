// // API요청으로 받아오는 모델
class Cosmetic {
  final String id;
  final String name;
  final String? brand;
  final List<String> images;
  final String? glowpickUrl;
  final DateTime? expirationDate;
  final DateTime createdAt;
  final DateTime? purchasedDate;
  final String category;
  late final int? favCount;
  double averageRating;
  int reviewCount;
  int totalRating;
  final List<String> keywords;

  Cosmetic({
    required this.id,
    required this.name,
    this.brand,
    required this.images,
    this.glowpickUrl,
    this.expirationDate,
    required this.createdAt,
    this.purchasedDate,
    required this.category,
    required this.averageRating,
    required this.reviewCount,
    required this.totalRating,
    required this.keywords,
    this.favCount,
  });

  factory Cosmetic.fromJson(Map<String, dynamic> json) {
    return Cosmetic(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'],
      images: List<String>.from(json['images'] ?? []),
      glowpickUrl: json['glowpickUrl'],
      expirationDate: json['expirationDate'] != null
          ? DateTime.tryParse(json['expirationDate'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      purchasedDate: json['purchasedDate'] != null
          ? DateTime.tryParse(json['purchasedDate'])
          : null,
      category: json['category'] ?? 'Unknown',
      averageRating: json['averageRating'] ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      totalRating: json['totalRating'] as int? ?? 0,
      keywords: List<String>.from(json['keywords'] ?? []),
      favCount: json['favCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'images': images,
      'glowpickUrl': glowpickUrl,
      'expirationDate': expirationDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'purchasedDate': purchasedDate?.toIso8601String(),
      'category': category,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'totalRating': totalRating,
      'keywords': keywords,
      'favCount': favCount,
    };
  }

  void updateAverageRating(int newRating) {
    reviewCount++;
    totalRating += newRating;
    averageRating = totalRating / reviewCount;
    averageRating = (averageRating * 100).roundToDouble() /
        100; // Round to 2 decimal places
  }

  @override
  String toString() {
    return 'CosmeticModel{id: $id, name: $name, brand: $brand, images: ${images?.join(', ')}, category: $category, keywords: ${keywords?.join(', ')}, favCount: ${favCount}, averageRating: ${averageRating}';
  }
}
