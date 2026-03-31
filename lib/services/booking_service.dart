import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking_model.dart';
import '../utils/constants.dart';
import '../providers/appwrite_providers.dart';

class BookingService {
  final Databases databases;

  BookingService(this.databases);

  Future<Booking> createBooking({
    required String userId,
    required String propertyId,
    required DateTime checkIn,
    required DateTime checkOut,
    required double totalPrice,
  }) async {
    try {
      final doc = await databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.bookingsCollectionId,
        documentId: ID.unique(),
        data: {
          'userId': userId,
          'propertyId': propertyId,
          'checkInDate': checkIn.toIso8601String(),
          'checkOutDate': checkOut.toIso8601String(),
          'check_in': checkIn.toIso8601String(),
          'check_out': checkOut.toIso8601String(),
          'totalPrice': totalPrice,
          'total_price': totalPrice,
          'status': 'pending',
          'bookingStatus': 'pending',
        },
      );
      return Booking.fromDocument(doc);
    } catch (e) {
      print('Error creating booking: $e');
      rethrow;
    }
  }

  Future<List<Booking>> getUserBookings(String userId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.bookingsCollectionId,
        queries: [
          Query.equal('userId', userId),
          Query.orderDesc('\$createdAt'),
        ],
      );
      return response.documents.map((doc) => Booking.fromDocument(doc)).toList();
    } catch (e) {
      print('Error fetching bookings: $e');
      rethrow;
    }
  }
}

// Riverpod providers
final bookingServiceProvider = Provider<BookingService>((ref) {
  return BookingService(ref.watch(databasesProvider));
});
