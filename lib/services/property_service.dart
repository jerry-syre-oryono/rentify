import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/property_model.dart';
import '../utils/constants.dart';
import '../providers/appwrite_providers.dart';

class PropertyService {
  final Databases databases;

  PropertyService(this.databases);

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
  return PropertyService(ref.watch(databasesProvider));
});

// Provider for fetching properties list
final propertiesListProvider = FutureProvider<List<Property>>((ref) async {
  final service = ref.watch(propertyServiceProvider);
  return await service.getAllProperties();
});
