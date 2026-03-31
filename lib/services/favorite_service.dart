import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/property_model.dart';
import '../utils/constants.dart';
import '../providers/appwrite_providers.dart';
import 'property_service.dart';

class FavoriteService {
  final Databases databases;

  FavoriteService(this.databases);

  Future<void> addFavorite(String userId, String propertyId) async {
    try {
      await databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.favoritesCollectionId,
        documentId: ID.unique(),
        data: {
          'userId': userId,
          'propertyId': propertyId,
        },
      );
    } catch (e) {
      print('Error adding favorite: $e');
      rethrow;
    }
  }

  Future<void> removeFavorite(String userId, String propertyId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.favoritesCollectionId,
        queries: [
          Query.equal('userId', userId),
          Query.equal('propertyId', propertyId),
        ],
      );

      for (var doc in response.documents) {
        await databases.deleteDocument(
          databaseId: AppConstants.databaseId,
          collectionId: AppConstants.favoritesCollectionId,
          documentId: doc.$id,
        );
      }
    } catch (e) {
      print('Error removing favorite: $e');
      rethrow;
    }
  }

  Future<bool> isFavorite(String userId, String propertyId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.favoritesCollectionId,
        queries: [
          Query.equal('userId', userId),
          Query.equal('propertyId', propertyId),
        ],
      );
      return response.documents.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<List<Property>> getFavoriteProperties(String userId, PropertyService propertyService) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.favoritesCollectionId,
        queries: [
          Query.equal('userId', userId),
        ],
      );

      List<Property> properties = [];
      for (var doc in response.documents) {
        final propertyId = doc.data['propertyId']?.toString();
        if (propertyId != null) {
          final property = await propertyService.getPropertyById(propertyId);
          if (property != null) {
            properties.add(property);
          }
        }
      }
      return properties;
    } catch (e) {
      print('Error fetching favorite properties: $e');
      return [];
    }
  }
}

final favoriteServiceProvider = Provider<FavoriteService>((ref) {
  return FavoriteService(ref.watch(databasesProvider));
});
