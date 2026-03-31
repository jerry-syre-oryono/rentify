import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/property_model.dart';
import '../../utils/constants.dart';
import '../../config/appwrite_config.dart';
import '../../providers/auth_providers.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rentify/services/review_service.dart';
import '../../models/review_model.dart';

class PropertyDetailsScreen extends ConsumerStatefulWidget {
  final Property property;

  const PropertyDetailsScreen({super.key, required this.property});

  @override
  ConsumerState<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends ConsumerState<PropertyDetailsScreen> {
  final PageController _pageController = PageController();
  final _commentController = TextEditingController();
  int _userRating = 5;

  @override
  void dispose() {
    _pageController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _showAddReviewDialog() async {
    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Rate your stay'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => IconButton(
                  icon: Icon(
                    index < _userRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () => setDialogState(() => _userRating = index + 1),
                )),
              ),
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: 'Write your experience...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final user = ref.read(authNotifierProvider).user;
                if (user == null) return;

                await ref.read(reviewServiceProvider).addReview(
                  propertyId: widget.property.id,
                  userId: user.$id,
                  userName: user.name,
                  rating: _userRating,
                  comment: _commentController.text,
                );
                if (mounted) {
                  Navigator.pop(context);
                  _commentController.clear();
                  setState(() {}); // Refresh reviews
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.9),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.9),
              child: IconButton(
                icon: const Icon(Icons.share, color: Colors.black),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery Carousel
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Hero(
                  tag: 'property-image-${property.id}',
                  child: SizedBox(
                    height: 400,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: property.imageIds.isEmpty ? 1 : property.imageIds.length,
                      itemBuilder: (context, index) {
                        if (property.imageIds.isEmpty) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported, size: 60),
                          );
                        }
                        return CachedNetworkImage(
                          imageUrl: AppwriteConfig.getImageUrl(property.imageIds[index]),
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Image Load Failed\n${error.toString()}',
                                    style: const TextStyle(color: Colors.red, fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (property.imageIds.length > 1)
                  Positioned(
                    bottom: 20,
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: property.imageIds.length,
                      effect: const ExpandingDotsEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        activeDotColor: Colors.white,
                        dotColor: Colors.white54,
                      ),
                    ),
                  ),
              ],
            ),
            
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
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '\$${property.pricePerNight.toStringAsFixed(0)} / night',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        property.location,
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                  
                  const Divider(height: 40),
                  
                  const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    property.description,
                    style: TextStyle(height: 1.5, color: isDark ? Colors.grey[300] : Colors.grey[800]),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  if (property.amenities.isNotEmpty) ...[
                    const Text('Amenities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: property.amenities.map((amenity) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? Colors.white12 : Colors.grey[200]!),
                        ),
                        child: Text(amenity),
                      )).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Reviews Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: _showAddReviewDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Review'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Review>>(
                    future: ref.read(reviewServiceProvider).getPropertyReviews(property.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final reviews = snapshot.data ?? [];
                      if (reviews.isEmpty) {
                        return const Text('No reviews yet. Be the first to rate!');
                      }
                      return Column(
                        children: reviews.map((review) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Row(
                            children: [
                              Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const Spacer(),
                              Row(
                                children: List.generate(5, (index) => Icon(
                                  index < review.rating ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 16,
                                )),
                              ),
                            ],
                          ),
                          subtitle: Text(review.comment),
                        )).toList(),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),

                  // Functional Interactive Map
                  const Text('Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 250,
                      width: double.infinity,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(property.latitude, property.longitude),
                          initialZoom: 13.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.rentify',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(property.latitude, property.longitude),
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: isDark ? Colors.white12 : Colors.grey[200]!)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$${property.pricePerNight.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text('total / night', style: TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.push(
                    AppConstants.routeBooking,
                    extra: {'property': property},
                  ),
                  child: const Text('Book Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}