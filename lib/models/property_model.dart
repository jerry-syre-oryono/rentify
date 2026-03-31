import 'package:appwrite/models.dart';

class Property {
  final String id;
  final String name;
  final String description;
  final double pricePerNight;
  final String location;
  final List<String> imageIds;
  final List<String> amenities;

  Property({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerNight,
    required this.location,
    this.imageIds = const [],
    this.amenities = const [],
  });

  factory Property.fromDocument(Document doc) {
    final data = doc.data;
    
    List<String> parseList(dynamic value) {
      if (value == null) return [];
      if (value is List) return List<String>.from(value);
      if (value is String) {
        // Handle case where it's a comma-separated string or single value
        if (value.startsWith('[') && value.endsWith(']')) {
          // It looks like a JSON string, but we'll just treat it as a single string for safety 
          // unless we want to use a JSON decoder.
          return [value];
        }
        return value.isEmpty ? [] : [value];
      }
      return [];
    }

    return Property(
      id: doc.$id,
      name: data['name']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      pricePerNight: (data['price_per_night'] ?? 0).toDouble(),
      location: data['location']?.toString() ?? '',
      imageIds: parseList(data['image_ids']),
      amenities: parseList(data['amenities']),
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
    };
  }
}
