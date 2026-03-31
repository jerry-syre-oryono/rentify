import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review_model.dart';
import '../utils/constants.dart';
import '../providers/appwrite_providers.dart';

class ReviewService {
  final Databases databases;

  ReviewService(this.databases);

  Future<void> addReview({
    required String propertyId,
    required String userId,
    required String userName,
    required int rating,
    required String comment,
  }) async {
    try {
      await databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.reviewsCollectionId,
        documentId: ID.unique(),
        data: {
          'propertyId': propertyId,
          'userId': userId,
          'userName': userName,
          'rating': rating,
          'comment': comment,
        },
      );
    } catch (e) {
      print('Error adding review: $e');
      rethrow;
    }
  }

  Future<List<Review>> getPropertyReviews(String propertyId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.reviewsCollectionId,
        queries: [
          Query.equal('propertyId', propertyId),
          Query.orderDesc('\$createdAt'),
        ],
      );
      return response.documents.map((doc) => Review.fromDocument(doc)).toList();
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }
}

final reviewServiceProvider = Provider<ReviewService>((ref) {
  return ReviewService(ref.watch(databasesProvider));
});
