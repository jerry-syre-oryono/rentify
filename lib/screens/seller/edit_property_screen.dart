import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/property_model.dart';
import '../../services/property_service.dart';
import '../../providers/auth_providers.dart';
import 'package:url_launcher/url_launcher.dart';

class EditPropertyScreen extends ConsumerStatefulWidget {
  final Property property;
  const EditPropertyScreen({super.key, required this.property});

  @override
  ConsumerState<EditPropertyScreen> createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends ConsumerState<EditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _locationController;
  late List<String> _selectedAmenities;
  final List<XFile> _newImages = [];
  late List<String> _existingImageIds;
  LatLng? _pickedLocation;
  bool _isLoading = false;

  final List<String> _availableAmenities = [
    'WiFi', 'Kitchen', 'Pool', 'Free Parking', 'AC', 'TV', 'Workspace', 'Gym'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.property.name);
    _descriptionController = TextEditingController(text: widget.property.description);
    _priceController = TextEditingController(text: widget.property.pricePerNight.toString());
    _locationController = TextEditingController(text: widget.property.location);
    _selectedAmenities = List.from(widget.property.amenities);
    _existingImageIds = List.from(widget.property.imageIds);
    _pickedLocation = LatLng(widget.property.latitude, widget.property.longitude);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _newImages.addAll(images);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || (_existingImageIds.isEmpty && _newImages.isEmpty) || _pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields, add images, and pick a location')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final propertyService = ref.read(propertyServiceProvider);

      // 1. Upload New Images if any
      List<String> uploadedIds = [];
      if (_newImages.isNotEmpty) {
        uploadedIds = await propertyService.uploadImages(_newImages.map((e) => e.path).toList());
      }

      // 2. Update Property
      await propertyService.updateProperty(
        id: widget.property.id,
        name: _nameController.text,
        description: _descriptionController.text,
        pricePerNight: double.parse(_priceController.text),
        location: _locationController.text,
        imageIds: [..._existingImageIds, ...uploadedIds],
        amenities: _selectedAmenities,
        latitude: _pickedLocation!.latitude,
        longitude: _pickedLocation!.longitude,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property updated successfully!')),
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
      appBar: AppBar(title: const Text('Edit Property')),
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
                      decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    
                    const SizedBox(height: 24),
                    const Text('Map Location (Tap to change)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 250,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: _pickedLocation ?? const LatLng(40.7128, -74.0060),
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
                            RichAttributionWidget(
                              attributions: [
                                TextSourceAttribution(
                                  'OpenStreetMap contributors',
                                  onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                                ),
                              ],
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
                          // Show existing images (simplified, just counts)
                          ...List.generate(_existingImageIds.length, (index) => Container(
                            margin: const EdgeInsets.only(left: 8),
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.withOpacity(0.3)),
                            ),
                            child: Stack(
                              children: [
                                const Center(child: Icon(Icons.image, color: Colors.blue)),
                                Positioned(
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.remove_circle, color: Colors.red, size: 20),
                                    onPressed: () => setState(() => _existingImageIds.removeAt(index)),
                                  ),
                                )
                              ],
                            ),
                          )),
                          // Show new picked images
                          ..._newImages.map((img) => Container(
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
                        child: const Text('Update Property'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
