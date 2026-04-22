import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'map_constants.dart';
import 'theme_constants.dart';

/// Marker model for FlutterMap
class MapMarker {
  final String id;
  final LatLng position;
  final String title;
  final String? subtitle;
  final MarkerType type; // property, pin, location
  final VoidCallback? onTap;

  MapMarker({
    required this.id,
    required this.position,
    required this.title,
    this.subtitle,
    this.type = MarkerType.property,
    this.onTap,
  });
}

enum MarkerType { property, pin, selectedLocation }

/// Widget for displaying map markers
class RentifyMarker extends StatelessWidget {
  final MapMarker marker;

  const RentifyMarker({super.key, required this.marker});

  Color _getMarkerColor() {
    switch (marker.type) {
      case MarkerType.property:
        return RentifyTheme.skyBlue;
      case MarkerType.pin:
        return RentifyTheme.error; // Red for pins
      case MarkerType.selectedLocation:
        return RentifyTheme.goldPrimary;
    }
  }

  IconData _getMarkerIcon() {
    switch (marker.type) {
      case MarkerType.property:
        return Icons.home_rounded;
      case MarkerType.pin:
        return Icons.location_on_rounded;
      case MarkerType.selectedLocation:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getMarkerColor(),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: marker.onTap,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                _getMarkerIcon(),
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Marker info popup for FlutterMap
class MarkerPopup extends StatelessWidget {
  final MapMarker marker;
  final VoidCallback onClose;
  final VoidCallback? onAction;
  final String actionLabel;

  const MarkerPopup({
    super.key,
    required this.marker,
    required this.onClose,
    this.onAction,
    this.actionLabel = 'View',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2A2A2A)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    marker.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (marker.subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                marker.subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (onAction != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    backgroundColor: RentifyTheme.goldPrimary,
                  ),
                  child: Text(
                    actionLabel,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Custom map controls widget
class MapControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onCenter;

  const MapControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ControlButton(
          icon: Icons.add,
          onPressed: onZoomIn,
        ),
        const SizedBox(height: 8),
        _ControlButton(
          icon: Icons.remove,
          onPressed: onZoomOut,
        ),
        const SizedBox(height: 8),
        _ControlButton(
          icon: Icons.location_searching,
          onPressed: onCenter,
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FloatingActionButton.small(
      backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      onPressed: onPressed,
      elevation: 4,
      child: Icon(
        icon,
        color: RentifyTheme.goldPrimary,
        size: 18,
      ),
    );
  }
}
