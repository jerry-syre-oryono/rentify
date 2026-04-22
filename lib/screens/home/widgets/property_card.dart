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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image
            Stack(
              children: [
                Hero(
                  tag: 'property-image-${property.id}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: AspectRatio(
                      aspectRatio: 1.2,
                      child: property.imageIds.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: AppwriteConfig.getImageUrl(property.imageIds.first),
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: isDark ? Colors.grey[800] : Colors.grey[100],
                                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: isDark ? Colors.grey[800] : Colors.grey[100],
                                child: const Icon(Icons.broken_image_outlined, color: Colors.grey, size: 40),
                              ),
                            )
                          : Container(
                              color: isDark ? Colors.grey[800] : Colors.grey[100],
                              child: const Icon(Icons.home_outlined, size: 48, color: Colors.grey),
                            ),
                    ),
                  ),
                ),
                // Floating Price
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\$${property.pricePerNight.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          ' / night',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Favorite Button
                Positioned(
                  top: 16,
                  right: 16,
                  child: Material(
                    color: (isDark ? Colors.black : Colors.white).withOpacity(0.8),
                    shape: const CircleBorder(),
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : (isDark ? Colors.white : const Color(0xFF0F172A)),
                        size: 20,
                      ),
                      onPressed: () async {
                        HapticFeedback.lightImpact();
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
                // Edit Button for Sellers
                if (onEdit != null)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Material(
                      color: (isDark ? Colors.black : Colors.white).withOpacity(0.8),
                      shape: const CircleBorder(),
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(Icons.edit_outlined, 
                          color: isDark ? Colors.white : const Color(0xFF0F172A), 
                          size: 20),
                        onPressed: onEdit,
                      ),
                    ),
                  ),
              ],
            ),
            
            // Property Info
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          property.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '4.8', // Placeholder for rating
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.grey[300] : Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.location,
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[500],
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Amenities summary tags (just showing first 2-3)
                  if (property.amenities.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: property.amenities.take(3).map((amenity) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          amenity,
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.grey[300] : const Color(0xFF475569),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )).toList(),
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
