import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/property_service.dart';
import '../../providers/auth_providers.dart';
import 'package:rentify/providers/location_providers.dart';
import 'package:geocoding/geocoding.dart';

class AddPropertyScreen extends ConsumerStatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  ConsumerState<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends ConsumerState<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final List<String> _selectedAmenities = [];
  final List<XFile> _images = [];
  LatLng? _pickedLocation;
  bool _isLoading = false;
  final MapController _mapController = MapController();

  final List<String> _availableAmenities = [
    'WiFi', 'Kitchen', 'Pool', 'Free Parking', 'AC', 'TV', 'Workspace', 'Gym'
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await ref.read(locationServiceProvider).getCurrentLocation();
      final newLocation = LatLng(position.latitude, position.longitude);
      setState(() {
        _pickedLocation = newLocation;
      });
      _mapController.move(newLocation, 15);
      _updateAddress(newLocation);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location error: $e')),
        );
      }
    }
  }

  Future<void> _updateAddress(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = "${place.street}, ${place.locality}, ${place.country}";
        setState(() {
          _locationController.text = address;
        });
      }
    } catch (e) {
      debugPrint("Geocoding error: $e");
    }
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _images.addAll(images);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _images.isEmpty || _pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields, add images, and pick a location on the map')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final propertyService = ref.read(propertyServiceProvider);
      final userId = ref.read(authNotifierProvider).user!.$id;

      // 1. Upload Images
      final imageIds = await propertyService.uploadImages(_images.map((e) => e.path).toList());

      // 2. Create Property
      await propertyService.createProperty(
        name: _nameController.text,
        description: _descriptionController.text,
        pricePerNight: double.parse(_priceController.text),
        location: _locationController.text,
        imageIds: imageIds,
        amenities: _selectedAmenities,
        sellerId: userId,
        latitude: _pickedLocation!.latitude,
        longitude: _pickedLocation!.longitude,
        sellerPhone: _phoneController.text,
        sellerEmail: _emailController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property added successfully!')),
        );
        Navigator.pop(context);
        ref.refresh(propertiesListProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Property')),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Property Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Property Name', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(labelText: 'Address/Location Name', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Map Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        TextButton.icon(
                          onPressed: _getCurrentLocation,
                          icon: const Icon(Icons.my_location),
                          label: const Text('Current Location'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 250,
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _pickedLocation ?? const LatLng(40.7128, -74.0060),
                            initialZoom: 13.0,
                            onTap: (tapPosition, point) {
                              setState(() {
                                _pickedLocation = point;
                              });
                              _updateAddress(point);
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:  'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                              subdomains: const ['a', 'b', 'c'],
                            ),
                            if (_pickedLocation != null)
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: _pickedLocation!,
                                    width: 40,
                                    height: 40,
                                    child: Icon(Icons.location_on, color: Colors.red[700]),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (_pickedLocation == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text('Please select location on the map', style: TextStyle(color: Colors.red, fontSize: 12)),
                      ),

                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price per Night (\$)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final price = double.tryParse(v);
                        if (price == null) return 'Enter a valid number';
                        if (price <= 0) return 'Price must be greater than 0';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                      maxLines: 3,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    
                    const SizedBox(height: 24),
                    const Text('Contact Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)),
                      keyboardType: TextInputType.phone,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    const Text('Images', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          GestureDetector(
                            onTap: _pickImages,
                            child: Container(
                              width: 100,
                              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.add_a_photo, color: Colors.grey),
                            ),
                          ),
                          ..._images.map((img) => Container(
                            margin: const EdgeInsets.only(left: 8),
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(image: FileImage(File(img.path)), fit: BoxFit.cover),
                            ),
                          )),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text('Amenities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _availableAmenities.map((amenity) {
                        final isSelected = _selectedAmenities.contains(amenity);
                        return FilterChip(
                          label: Text(amenity),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) _selectedAmenities.add(amenity);
                              else _selectedAmenities.remove(amenity);
                            });
                          },
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: const Text('List Property'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
