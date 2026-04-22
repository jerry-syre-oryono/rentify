import 'package:url_launcher/url_launcher.dart';

class MapHelper {
  /// Open location in Google Maps app
  static Future<void> openGoogleMaps(double latitude, double longitude, String label) async {
    // Try to open in Google Maps app first
    final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    
    try {
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(Uri.parse(googleMapsUrl));
      } else {
        // Fallback: open in browser
        final browserUrl = 'https://maps.google.com/?q=$latitude,$longitude';
        await launchUrl(Uri.parse(browserUrl), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error opening maps: $e');
    }
  }

  /// Get Google Maps URL for a location
  static String getGoogleMapsUrl(double latitude, double longitude, String label) {
    return 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
  }
}
