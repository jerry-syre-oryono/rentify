import 'package:appwrite/models.dart';

class Booking {
  final String id;
  final String userId;
  final String propertyId;
  final DateTime checkIn;
  final DateTime checkOut;
  final double totalPrice;
  final String status; // 'pending', 'confirmed', 'cancelled'

  Booking({
    required this.id,
    required this.userId,
    required this.propertyId,
    required this.checkIn,
    required this.checkOut,
    required this.totalPrice,
    this.status = 'pending',
  });

  factory Booking.fromDocument(Document doc) {
    final data = doc.data;
    return Booking(
      id: doc.$id,
      userId: data['user_id']?.toString() ?? '',
      propertyId: data['property_id']?.toString() ?? '',
      checkIn: DateTime.tryParse(data['check_in']?.toString() ?? '') ?? DateTime.now(),
      checkOut: DateTime.tryParse(data['check_out']?.toString() ?? '') ?? DateTime.now(),
      totalPrice: (data['total_price'] ?? 0).toDouble(),
      status: data['status']?.toString() ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'property_id': propertyId,
      'check_in': checkIn.toIso8601String(),
      'check_out': checkOut.toIso8601String(),
      'total_price': totalPrice,
      'status': status,
    };
  }

  int get nights => checkOut.difference(checkIn).inDays;
}
