import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/property_model.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';

class PropertyBookingsScreen extends ConsumerWidget {
  final Property property;

  const PropertyBookingsScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookings: ${property.name}'),
      ),
      body: FutureBuilder<List<Booking>>(
        future: ref.read(bookingServiceProvider).getPropertyBookings(property.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return const Center(child: Text('No bookings for this property yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'User ID: ${booking.userId.substring(0, 8)}...',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          _buildStatusChip(booking.status),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text('Dates: ${DateFormat('MMM dd').format(booking.checkIn)} - ${DateFormat('MMM dd, yyyy').format(booking.checkOut)}'),
                      const SizedBox(height: 4),
                      Text('Earnings: \$${booking.totalPrice.toStringAsFixed(2)}'),
                      const SizedBox(height: 16),
                      if (booking.status.toLowerCase() == 'pending')
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _updateStatus(context, ref, booking.id, 'cancelled'),
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('Decline'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _updateStatus(context, ref, booking.id, 'confirmed'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                child: const Text('Confirm'),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, WidgetRef ref, String bookingId, String status) async {
    try {
      await ref.read(bookingServiceProvider).updateBookingStatus(bookingId, status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking $status successfully!')),
      );
      // Refresh the UI (using a simple pop/push or provider refresh would be better)
      Navigator.pop(context); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'confirmed':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      case 'checked-in':
        color = Colors.blue;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
