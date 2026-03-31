import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/property_model.dart';
import '../../../config/appwrite_config.dart';
import '../../../utils/constants.dart';
import '../../../providers/favorite_providers.dart';
import '../../../services/favorite_service.dart';
import '../../../providers/auth_providers.dart';

class PropertyCard extends ConsumerWidget {
  final Property property;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);
    final isFavorite = favoritesAsync.value?.contains(property.id) ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image with Hero animation
            Stack(
              children: [
                Hero(
                  tag: 'property-image-${property.id}',
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: property.imageIds.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: AppwriteConfig.getImageUrl(property.imageIds.first),
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.red, size: 32),
                                  const SizedBox(height: 4),
                                  Text(
                                    error.toString(),
                                    style: const TextStyle(fontSize: 8, color: Colors.red),
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.home, size: 40, color: Colors.grey),
                          ),
                  ),
                ),
                // Price Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '\$${property.pricePerNight.toStringAsFixed(0)} / night',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                // Favorite Button
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Material(
                    color: Colors.white.withOpacity(0.9),
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.black,
                      ),
                      onPressed: () async {
                        HapticFeedback.mediumImpact();
                        final userId = ref.read(authNotifierProvider).user?.$id;
                        if (userId == null) return;

                        final service = ref.read(favoriteServiceProvider);
                        if (isFavorite) {
                          await service.removeFavorite(userId, property.id);
                        } else {
                          await service.addFavorite(userId, property.id);
                        }
                        ref.refresh(favoritesProvider);
                      },
                    ),
                  ),
                ),
                // Edit Button
                if (onEdit != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Material(
                      color: Colors.white.withOpacity(0.9),
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.black),
                        onPressed: onEdit,
                      ),
                    ),
                  ),
              ],
            ),
            
            // Property Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.red[400]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.location,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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