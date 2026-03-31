import 'package:appwrite/models.dart';

class Property {
  final String id;
  final String name;
  final String description;
  final double pricePerNight;
  final String location;
  final List<String> imageIds;
  final List<String> amenities;
  final String sellerId;
  final double latitude;
  final double longitude;

  Property({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerNight,
    required this.location,
    this.imageIds = const [],
    this.amenities = const [],
    this.sellerId = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  factory Property.fromDocument(Document doc) {
    final data = doc.data;
    
    List<String> parseList(dynamic value) {
      if (value == null) return [];
      if (value is List) return List<String>.from(value);
      return [];
    }

    return Property(
      id: doc.$id,
      name: data['name']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      pricePerNight: (data['price_per_night'] ?? data['pricePerNight'] ?? 0).toDouble(),
      location: data['location']?.toString() ?? '',
      imageIds: parseList(data['image_ids'] ?? data['imageIds']),
      amenities: parseList(data['amenities']),
      sellerId: data['sellerId']?.toString() ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price_per_night': pricePerNight,
      'location': location,
      'image_ids': imageIds,
      'amenities': amenities,
      'sellerId': sellerId,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
