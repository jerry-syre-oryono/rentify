/// Constants for Flutter Map configuration
class MapConstants {
  // Default map center (New York City)
  static const double defaultLatitude = 40.7128;
  static const double defaultLongitude = -74.0060;

  // Map zoom levels
  static const double defaultZoom = 12;
  static const double propertyZoom = 13;
  static const double selectionZoom = 15;
  static const double minZoom = 2;
  static const double maxZoom = 18;

  // Tile providers
  static const String openStreetMapTile = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String openStreetMapAttribution =
      '© OpenStreetMap contributors';

  // Map features
  static const bool enableRotation = true;
  static const bool enableMultiFingerGestureRotation = true;
  static const bool allowPanningOnScrollingParent = true;

  // Marker popup duration
  static const Duration markerPopupDuration = Duration(milliseconds: 250);
}
