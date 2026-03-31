import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import '../config/appwrite_config.dart';
import '../utils/constants.dart';

// Appwrite Client Provider
final appwriteClientProvider = Provider<Client>((ref) {
  return Client()
      .setEndpoint(AppConstants.appwriteEndpoint)
      .setProject(AppConstants.appwriteProjectId)
      .setSelfSigned();
});

// Account Service Provider
final accountProvider = Provider<Account>((ref) {
  return Account(ref.watch(appwriteClientProvider));
});

// Databases Service Provider
final databasesProvider = Provider<Databases>((ref) {
  return Databases(ref.watch(appwriteClientProvider));
});

// Storage Service Provider
final storageProvider = Provider<Storage>((ref) {
  return Storage(ref.watch(appwriteClientProvider));
});

// Current User Session Provider (auto-updates)
final currentUserProvider = StreamProvider<models.User?>((ref) {
  final account = ref.watch(accountProvider);
  return account.get().asStream().map((user) => user).handleError((_) => null);
});
