import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/property_model.dart';
import '../../services/favorite_service.dart';
import '../../services/property_service.dart';
import '../../providers/auth_providers.dart';
import '../../utils/constants.dart';
import '../../widgets/skeleton_loader.dart';
import 'widgets/property_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final userId = authState.user?.$id ?? '';

    if (userId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Please login to view favorites')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: FutureBuilder<List<Property>>(
        future: ref.read(favoriteServiceProvider).getFavoriteProperties(
          userId,
          ref.read(propertyServiceProvider),
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) => const PropertySkeleton(),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final properties = snapshot.data ?? [];

          if (properties.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No favorite properties yet.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];
              return PropertyCard(
                property: property,
                onTap: () => context.push(
                  '${AppConstants.routePropertyDetails}/${property.id}',
                  extra: property,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

