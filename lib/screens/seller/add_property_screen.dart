import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/property_service.dart';
import '../../providers/auth_providers.dart';

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
  final List<String> _selectedAmenities = [];
  final List<XFile> _images = [];
  LatLng? _pickedLocation;
  bool _isLoading = false;

  final List<String> _availableAmenities = [
    'WiFi', 'Kitchen', 'Pool', 'Free Parking', 'AC', 'TV', 'Workspace', 'Gym'
  ];

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
                    const Text('Map Location (Tap to pick)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 250,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: const LatLng(40.7128, -74.0060), // Default to NYC
                            initialZoom: 13.0,
                            onTap: (tapPosition, point) {
                              setState(() {
                                _pickedLocation = point;
                              });
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.rentify',
                            ),
                            if (_pickedLocation != null)
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: _pickedLocation!,
                                    width: 40,
                                    height: 40,
                                    child: const Icon(Icons.location_on, color: Colors.red, size: 40),
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
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                      maxLines: 3,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
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
