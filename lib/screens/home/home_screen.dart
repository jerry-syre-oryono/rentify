import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_providers.dart';
import '../../services/property_service.dart';
import '../../models/property_model.dart';
import '../../utils/constants.dart';
import 'widgets/property_card.dart';
import '../../widgets/skeleton_loader.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(propertiesListProvider);
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rentify'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by location or name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          
          Expanded(
            child: propertiesAsync.when(
              loading: () => ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) => const PropertySkeleton(),
              ),
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
                final filteredProperties = properties.where((p) {
                  return p.name.toLowerCase().contains(_searchQuery) ||
                         p.location.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredProperties.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text('No properties match your search.'),
                      ],
                    ),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: () async => ref.refresh(propertiesListProvider),
                  child: ListView.builder(
                    itemCount: filteredProperties.length,
                    itemBuilder: (context, index) {
                      final property = filteredProperties[index];
                      return PropertyCard(
                        property: property,
                        onTap: () => context.push(
                          '${AppConstants.routePropertyDetails}/${property.id}',
                          extra: property,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
