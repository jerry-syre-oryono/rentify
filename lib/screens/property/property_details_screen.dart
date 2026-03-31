import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/property_model.dart';
import '../../utils/constants.dart';
import '../../config/appwrite_config.dart';

class PropertyDetailsScreen extends ConsumerWidget {
  final Property property;

  const PropertyDetailsScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(property.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            if (property.imageIds.isNotEmpty)
              SizedBox(
                height: 250,
                child: Image.network(
                  AppwriteConfig.getImageUrl(property.imageIds.first),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 250,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 60),
                  ),
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          property.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '\$${property.pricePerNight.toStringAsFixed(2)}/night',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(property.location),
                    ],
                  ),
                  
                  const Divider(height: 32),
                  
                  // Description
                  const Text('About this place', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(property.description),
                  
                  const SizedBox(height: 24),
                  
                  // Amenities
                  if (property.amenities.isNotEmpty) ...[
                    const Text('Amenities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: property.amenities.map((amenity) => Chip(
                        label: Text(amenity),
                        backgroundColor: Colors.blue[50],
                      )).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Book Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go(
                        AppConstants.routeBooking,
                        extra: {'property': property},
                      ),
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Book Now'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}