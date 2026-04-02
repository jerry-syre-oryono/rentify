import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/booking_service.dart';
import '../../models/booking_model.dart';

class ScanBookingScreen extends ConsumerStatefulWidget {
  const ScanBookingScreen({super.key});

  @override
  ConsumerState<ScanBookingScreen> createState() => _ScanBookingScreenState();
}

class _ScanBookingScreenState extends ConsumerState<ScanBookingScreen> {
  bool _isScanning = true;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? bookingId = barcodes.first.rawValue;
      if (bookingId != null) {
        setState(() => _isScanning = false);
        _verifyBooking(bookingId);
      }
    }
  }

  Future<void> _verifyBooking(String bookingId) async {
    try {
      final bookingService = ref.read(bookingServiceProvider);
      final booking = await bookingService.getBookingById(bookingId);

      if (booking == null) {
        _showError('Invalid QR Code. Booking not found.');
        return;
      }

      if (booking.status.toLowerCase() == 'checked-in') {
        _showError('This booking is already checked-in.');
        return;
      }

      if (booking.status.toLowerCase() != 'confirmed') {
        _showError('Booking is not confirmed. Current status: ${booking.status}');
        return;
      }

      // Show booking details and confirm check-in
      _showConfirmationDialog(booking);
    } catch (e) {
      _showError('Error verifying booking: $e');
    }
  }

  void _showConfirmationDialog(Booking booking) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Check-in'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Booking ID: ${booking.id}'),
            const SizedBox(height: 8),
            Text('Status: ${booking.status.toUpperCase()}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Verify user identity and confirm check-in?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isScanning = true);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _confirmCheckIn(booking.id);
            },
            child: const Text('Confirm Check-in'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCheckIn(String bookingId) async {
    try {
      await ref.read(bookingServiceProvider).updateBookingStatus(bookingId, 'checked-in');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check-in successful!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Return to dashboard
      }
    } catch (e) {
      _showError('Failed to confirm check-in: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isScanning = true);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Booking QR')),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _onDetect,
          ),
          // Scanner Overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Text(
              'Align QR code within the frame',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16, backgroundColor: Colors.black45),
            ),
          ),
        ],
      ),
    );
  }
}
