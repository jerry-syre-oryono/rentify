import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../models/booking_model.dart';

class BookingDetailsScreen extends StatelessWidget {
  final Booking booking;

  const BookingDetailsScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final bool isConfirmed = booking.status.toLowerCase() == 'confirmed';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Booking Status',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    booking.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(booking.status),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (isConfirmed) ...[
              const Text(
                'Show this QR code to the seller on arrival',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Center(
                child: QrImageView(
                  data: booking.id,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ID: ${booking.id}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ] else if (booking.status.toLowerCase() == 'pending') ...[
              const Icon(Icons.hourglass_empty, size: 100, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'Waiting for seller to confirm your booking.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ] else ...[
              const Icon(Icons.cancel_outlined, size: 100, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'This booking is cancelled.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 24),
            _buildDetailRow('Check-in', DateFormat('EEE, MMM dd, yyyy').format(booking.checkIn)),
            const SizedBox(height: 16),
            _buildDetailRow('Check-out', DateFormat('EEE, MMM dd, yyyy').format(booking.checkOut)),
            const SizedBox(height: 16),
            _buildDetailRow('Nights', '${booking.nights}'),
            const SizedBox(height: 16),
            _buildDetailRow('Total Price', '\$${booking.totalPrice.toStringAsFixed(2)}', isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
