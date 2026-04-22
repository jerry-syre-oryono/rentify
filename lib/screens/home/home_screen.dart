import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_providers.dart';
import '../../services/property_service.dart';
import '../../utils/constants.dart';
import 'widgets/property_card.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/rentify_logo.dart';

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
    final userName = authState.user?.name ?? 'Guest';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const RentifyLogo(size: 32),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none_rounded, 
              color: isDark ? Colors.white : const Color(0xFF1E293B)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $userName! 👋',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Find your next stay',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by location or name...',
                  hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0066FF)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0066FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
                        ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
          ),
          
          Expanded(
            child: propertiesAsync.when(
              loading: () => ListView.builder(
                padding: const EdgeInsets.only(top: 8),
                itemCount: 3,
                itemBuilder: (context, index) => const PropertySkeleton(),
              ),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Oops! Something went wrong',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 8),
                    Text(err.toString(), textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500])),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => ref.refresh(propertiesListProvider),
                      child: const Text('Try Again'),
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
                        Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No results found',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 8),
                        Text('Try adjusting your search query.', style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }
                
                return RefreshIndicator(
                  color: const Color(0xFF0066FF),
                  onRefresh: () async => ref.refresh(propertiesListProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 20),
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
