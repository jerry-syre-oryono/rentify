import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import '../../utils/map_constants.dart';
import '../../utils/flutter_map_widgets.dart';
import '../../utils/theme_constants.dart';

/// Reusable map selection widget for property location selection
class LocationMapSelector extends StatefulWidget {
  final LatLng? initialLocation;
  final ValueChanged<LatLng> onLocationSelected;
  final ValueChanged<String> onAddressChanged;
  final VoidCallback? onCurrentLocationPressed;
  final double height;

  const LocationMapSelector({
    super.key,
    this.initialLocation,
    required this.onLocationSelected,
    required this.onAddressChanged,
    this.onCurrentLocationPressed,
    this.height = 300,
  });

  @override
  State<LocationMapSelector> createState() => _LocationMapSelectorState();
}

class _LocationMapSelectorState extends State<LocationMapSelector> {
  final MapController _mapController = MapController();
  late LatLng _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation ??
        LatLng(MapConstants.defaultLatitude,
            MapConstants.defaultLongitude);
  }

  Future<void> _updateAddress(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address =
            "${place.street}, ${place.locality}, ${place.country}";
        widget.onAddressChanged(address);
      }
    } catch (e) {
      debugPrint("Geocoding error: $e");
    }
  }

  void _onMapTap(LatLng point) {
    setState(() => _selectedLocation = point);
    widget.onLocationSelected(point);
    _updateAddress(point);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SizedBox(
              height: widget.height,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _selectedLocation,
                  initialZoom: MapConstants.propertyZoom,
                  minZoom: MapConstants.minZoom,
                  maxZoom: MapConstants.maxZoom,
                  onTap: (tapPosition, point) =>
                      _onMapTap(point),
                ),
                children: [
                  // Tile Layer
                  TileLayer(
                    urlTemplate:
                        MapConstants.openStreetMapTile,
                    tileProvider: NetworkTileProvider(
                      headers: {
                        'User-Agent': 'RentifyApp/1.0 (Flutter)',
                        'Referer': 'https://rentify.app',
                      },
                    ),
                    tileBuilder: (context, widget, tile) {
                      if (isDark) {
                        return Container(
                          color: Colors.grey[850],
                          child: ColorFiltered(
                            colorFilter:
                                const ColorFilter.matrix([
                              0.5,
                              0,
                              0,
                              0,
                              20,
                              0,
                              0.5,
                              0,
                              0,
                              20,
                              0,
                              0,
                              0.5,
                              0,
                              20,
                              0,
                              0,
                              0,
                              1,
                              0,
                            ]),
                            child: widget,
                          ),
                        );
                      }
                      return widget;
                    },
                  ),
                  // Selected Location Marker
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedLocation,
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        child: RentifyMarker(
                          marker: MapMarker(
                            id: 'selected',
                            position: _selectedLocation,
                            title: 'Property Location',
                            type: MarkerType.selectedLocation,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        // Map Controls
        Positioned(
          right: 12,
          bottom: 12,
          child: MapControls(
            onZoomIn: () => _mapController.move(
              _mapController.camera.center,
              _mapController.camera.zoom + 1,
            ),
            onZoomOut: () => _mapController.move(
              _mapController.camera.center,
              _mapController.camera.zoom - 1,
            ),
            onCenter: () => _mapController.move(
              _selectedLocation,
              MapConstants.propertyZoom,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
