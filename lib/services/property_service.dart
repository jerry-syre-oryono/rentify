import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/property_model.dart';
import '../utils/constants.dart';
import '../providers/appwrite_providers.dart';

class PropertyService {
  final Databases databases;
  final Storage storage;

  PropertyService(this.databases, this.storage);

  Future<List<Property>> getAllProperties() async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.propertiesCollectionId,
        queries: [Query.orderDesc('\$createdAt')],
      );
      
      return response.documents.map((doc) => Property.fromDocument(doc)).toList();
    } catch (e) {
      print('Error fetching properties: $e');
      rethrow;
    }
  }

  Future<List<Property>> getSellerProperties(String sellerId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.propertiesCollectionId,
        queries: [
          Query.equal('sellerId', sellerId),
          Query.orderDesc('\$createdAt'),
        ],
      );
      return response.documents.map((doc) => Property.fromDocument(doc)).toList();
    } catch (e) {
      print('Error fetching seller properties: $e');
      rethrow;
    }
  }

  Future<List<String>> uploadImages(List<String> filePaths) async {
    List<String> uploadedIds = [];
    for (var path in filePaths) {
      try {
        final file = await storage.createFile(
          bucketId: AppConstants.imagesBucketId,
          fileId: ID.unique(),
          file: InputFile.fromPath(path: path),
        );
        uploadedIds.add(file.$id);
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
    return uploadedIds;
  }

  Future<Property> createProperty({
    required String name,
    required String description,
    required double pricePerNight,
    required String location,
    required List<String> imageIds,
    required List<String> amenities,
    required String sellerId,
    double latitude = 0.0,
    double longitude = 0.0,
    String sellerPhone = '',
    String sellerEmail = '',
  }) async {
    try {
      final doc = await databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.propertiesCollectionId,
        documentId: ID.unique(),
        data: {
          'name': name,
          'description': description,
          'price_per_night': pricePerNight,
          'location': location,
          'image_ids': imageIds,
          'amenities': amenities,
          'sellerId': sellerId,
          'latitude': latitude,
          'longitude': longitude,
          'seller_phone': sellerPhone,
          'seller_email': sellerEmail,
        },
      );
      return Property.fromDocument(doc);
    } catch (e) {
      print('Error creating property: $e');
      rethrow;
    }
  }

  Future<Property> updateProperty({
    required String id,
    required String name,
    required String description,
    required double pricePerNight,
    required String location,
    required List<String> imageIds,
    required List<String> amenities,
    double latitude = 0.0,
    double longitude = 0.0,
    String sellerPhone = '',
    String sellerEmail = '',
  }) async {
    try {
      final doc = await databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.propertiesCollectionId,
        documentId: id,
        data: {
          'name': name,
          'description': description,
          'price_per_night': pricePerNight,
          'location': location,
          'image_ids': imageIds,
          'amenities': amenities,
          'latitude': latitude,
          'longitude': longitude,
          'seller_phone': sellerPhone,
          'seller_email': sellerEmail,
        },
      );
      return Property.fromDocument(doc);
    } catch (e) {
      print('Error updating property: $e');
      rethrow;
    }
  }

  Future<Property?> getPropertyById(String propertyId) async {
    try {
      final doc = await databases.getDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.propertiesCollectionId,
        documentId: propertyId,
      );
      return Property.fromDocument(doc);
    } catch (e) {
      print('Error fetching property: $e');
      return null;
    }
  }
}

// Riverpod provider for PropertyService
final propertyServiceProvider = Provider<PropertyService>((ref) {
  return PropertyService(
    ref.watch(databasesProvider),
    ref.watch(storageProvider),
  );
});

// Provider for fetching properties list
final propertiesListProvider = FutureProvider<List<Property>>((ref) async {
  final service = ref.watch(propertyServiceProvider);
  return await service.getAllProperties();
});
