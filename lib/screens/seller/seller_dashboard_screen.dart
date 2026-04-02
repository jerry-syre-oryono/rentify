import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/property_model.dart';
import '../../services/property_service.dart';
import '../../providers/auth_providers.dart';
import '../../utils/constants.dart';
import '../home/widgets/property_card.dart';

class SellerDashboardScreen extends ConsumerWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final sellerId = authState.user?.$id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Properties'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => context.push(AppConstants.routeScanBooking),
            tooltip: 'Scan Booking QR',
          ),
        ],
      ),
      body: sellerId.isEmpty
          ? const Center(child: Text('Please login to view dashboard'))
          : FutureBuilder<List<Property>>(
              future: ref.read(propertyServiceProvider).getSellerProperties(sellerId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final properties = snapshot.data ?? [];

                if (properties.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.home_work_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('You haven\'t listed any properties yet.'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.push(AppConstants.routeAddProperty),
                          child: const Text('List Your First Property'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: properties.length,
                  itemBuilder: (context, index) {
                    final property = properties[index];
                    return Column(
                      children: [
                        PropertyCard(
                          property: property,
                          onTap: () {
                            context.push('${AppConstants.routePropertyDetails}/${property.id}', extra: property);
                          },
                          onEdit: () {
                            context.push(AppConstants.routeEditProperty, extra: property);
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => context.push(AppConstants.routePropertyBookings, extra: property),
                                icon: const Icon(Icons.list_alt, size: 18),
                                label: const Text('Manage Bookings'),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                      ],
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppConstants.routeAddProperty),
        label: const Text('Add Property'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
