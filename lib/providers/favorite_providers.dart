import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/favorite_service.dart';
import 'auth_providers.dart';

final favoritesProvider = FutureProvider<List<String>>((ref) async {
  final authState = ref.watch(authNotifierProvider);
  final userId = authState.user?.$id;
  
  if (userId == null) return [];
  
  final service = ref.watch(favoriteServiceProvider);
  // We just need the IDs for the icons on cards
  final response = await service.databases.listDocuments(
    databaseId: '69c7c496001cc7881cd0',
    collectionId: 'favorites',
    queries: [
      Query.equal('userId', userId),
    ],
  );
  
  return response.documents.map((doc) => doc.data['propertyId'].toString()).toList();
});
