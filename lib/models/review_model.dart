import 'package:appwrite/models.dart';

class Review {
  final String id;
  final String propertyId;
  final String userId;
  final String userName;
  final int rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.propertyId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromDocument(Document doc) {
    final data = doc.data;
    return Review(
      id: doc.$id,
      propertyId: data['propertyId']?.toString() ?? '',
      userId: data['userId']?.toString() ?? '',
      userName: data['userName']?.toString() ?? 'Anonymous',
      rating: (data['rating'] ?? 0) as int,
      comment: data['comment']?.toString() ?? '',
      createdAt: DateTime.tryParse(doc.$createdAt) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
    };
  }
}
