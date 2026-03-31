import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/property_model.dart';
import '../../models/booking_model.dart';
import '../../providers/auth_providers.dart';
import '../../services/booking_service.dart';
import '../../utils/constants.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final Property property;

  const BookingScreen({super.key, required this.property});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime? _checkIn;
  DateTime? _checkOut;
  bool _isBooking = false;

  int get _nights => _checkIn != null && _checkOut != null 
      ? _checkOut!.difference(_checkIn!).inDays 
      : 0;
      
  double get _totalPrice => _nights * widget.property.pricePerNight;

  Future<void> _selectDate(bool isCheckIn) async {
    final initialDate = isCheckIn ? _checkIn ?? DateTime.now() : _checkOut ?? DateTime.now().add(const Duration(days: 1));
    final firstDate = isCheckIn ? DateTime.now() : (_checkIn ?? DateTime.now());
    final lastDate = DateTime.now().add(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: isCheckIn ? 'Select Check-in Date' : 'Select Check-out Date',
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkIn = picked;
          // Auto-set check-out to next day if not set or before check-in
          if (_checkOut == null || _checkOut!.isBefore(_checkIn!)) {
            _checkOut = picked.add(const Duration(days: 1));
          }
        } else {
          _checkOut = picked;
        }
      });
    }
  }

  Future<void> _confirmBooking() async {
    if (_checkIn == null || _checkOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both check-in and check-out dates')),
      );
      return;
    }

    if (_checkOut!.isBefore(_checkIn!) || _checkOut!.difference(_checkIn!).inDays < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-out must be after check-in')),
      );
      return;
    }

    final authState = ref.read(authNotifierProvider);
    if (authState.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to book')),
      );
      return;
    }

    setState(() => _isBooking = true);

    try {
      final bookingService = ref.read(bookingServiceProvider);
      
      await bookingService.createBooking(
        userId: authState.user!.$id,
        propertyId: widget.property.id,
        checkIn: _checkIn!,
        checkOut: _checkOut!,
        totalPrice: _totalPrice,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking confirmed! 🎉')),
        );
        context.go(AppConstants.routeHome);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Booking'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.property.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.property.location,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const Divider(height: 24),
                    Text(
                      '\$${widget.property.pricePerNight.toStringAsFixed(2)} per night',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Date Selection
            const Text('Select Dates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            Row(
              children: [
                // Check-in
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(true),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Check-in',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      child: Text(
                        _checkIn == null 
                          ? 'Select date' 
                          : DateFormat('MMM dd, yyyy').format(_checkIn!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Check-out
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(false),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Check-out',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      child: Text(
                        _checkOut == null 
                          ? 'Select date' 
                          : DateFormat('MMM dd, yyyy').format(_checkOut!),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Price Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('\$${widget.property.pricePerNight.toStringAsFixed(2)} x $_nights nights'),
                        Text('\$${(_nights * widget.property.pricePerNight).toStringAsFixed(2)}'),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          '\$$_totalPrice',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isBooking ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isBooking
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Confirm Booking'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}