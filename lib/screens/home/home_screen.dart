import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_providers.dart';
import '../../services/property_service.dart';
import '../../models/property_model.dart';
import '../../utils/constants.dart';
import 'widgets/property_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertiesAsync = ref.watch(propertiesListProvider);
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rentify'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) {
                context.go(AppConstants.routeLogin);
              }
            },
          ),
        ],
      ),
      body: propertiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text('Error: ${err.toString()}', textAlign: TextAlign.center),
              TextButton(
                onPressed: () => ref.refresh(propertiesListProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (properties) {
          if (properties.isEmpty) {
            return const Center(
              child: Text('No properties found. Add some in Appwrite console!'),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(propertiesListProvider),
            child: ListView.builder(
              itemCount: properties.length,
              itemBuilder: (context, index) {
                final property = properties[index];
                return PropertyCard(
                  property: property,
                  onTap: () => context.go(
                    '${AppConstants.routePropertyDetails}/${property.id}',
                    extra: property,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
