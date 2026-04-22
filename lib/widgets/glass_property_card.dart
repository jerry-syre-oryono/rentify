import 'package:flutter/material.dart';
import 'dart:ui';
import '../utils/theme_constants.dart';
import '../utils/animations.dart';

/// Premium Glass-Morphism Property Card
class GlassPropertyCard extends StatefulWidget {
  final String? imageUrl;
  final String title;
  final String location;
  final double price;
  final double rating;
  final int reviewCount;
  final VoidCallback onTap;
  final Duration delay;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  const GlassPropertyCard({
    this.imageUrl,
    required this.title,
    required this.location,
    required this.price,
    this.rating = 4.5,
    this.reviewCount = 0,
    required this.onTap,
    this.delay = Duration.zero,
    this.isFavorite = false,
    this.onFavoriteTap,
    super.key,
  });

  @override
  State<GlassPropertyCard> createState() => _GlassPropertyCardState();
}

class _GlassPropertyCardState extends State<GlassPropertyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: AnimationDurations.quick,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHover(bool value) {
    _isHovered = value;
    if (value) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedCardEntrance(
      delay: widget.delay,
      child: MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.02).animate(
              CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: _isHovered ? 24 : 12,
                    spreadRadius: _isHovered ? 4 : 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: _isHovered ? 15 : 10,
                    sigmaY: _isHovered ? 15 : 10,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.1)),
                      border: Border.all(
                        color: RentifyTheme.goldPrimary.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Section
                        Stack(
                          children: [
                            Container(
                              height: 180,
                              width: double.infinity,
                              color: isDark
                                  ? Colors.grey[800]
                                  : Colors.grey[200],
                              child: widget.imageUrl != null
                                  ? Image.network(
                                      widget.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey[400],
                                          size: 40,
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Icon(
                                        Icons.home,
                                        color: Colors.grey[400],
                                        size: 50,
                                      ),
                                    ),
                            ),
                            // Gradient Overlay
                            Container(
                              height: 180,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.3),
                                  ],
                                ),
                              ),
                            ),
                            // Favorite Button
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: widget.onFavoriteTap,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      widget.isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: widget.isFavorite
                                          ? RentifyTheme.error
                                          : Colors.grey[600],
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Content Section
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                widget.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                  color: isDark ? Colors.white : RentifyTheme.deepSlate,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Location
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 16,
                                    color: RentifyTheme.goldPrimary,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      widget.location,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Rating & Price Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Rating
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        size: 16,
                                        color: RentifyTheme.goldPrimary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${widget.rating}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? Colors.white
                                              : RentifyTheme.deepSlate,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '(${widget.reviewCount})',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Price
                                  Text(
                                    '\$${widget.price.toStringAsFixed(0)}/nt',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: RentifyTheme.goldPrimary,
                                      letterSpacing: 0.5,
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
