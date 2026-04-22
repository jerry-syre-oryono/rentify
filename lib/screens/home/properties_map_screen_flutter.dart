import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../models/property_model.dart';
import '../../utils/constants.dart';
import '../../utils/map_helper.dart';
import '../../utils/map_constants.dart';
import '../../utils/flutter_map_widgets.dart';
import '../../utils/theme_constants.dart';

class PropertiesMapScreenFlutter extends ConsumerStatefulWidget {
  final List<Property> properties;
  final LatLng? initialLocation;
  final bool showProperties;

  const PropertiesMapScreenFlutter({
    super.key,
    required this.properties,
    this.initialLocation,
    this.showProperties = true,
  });

  @override
  ConsumerState<PropertiesMapScreenFlutter> createState() =>
      _PropertiesMapScreenFlutterState();
}

class _PropertiesMapScreenFlutterState
    extends ConsumerState<PropertiesMapScreenFlutter> {
  final MapController _mapController = MapController();
  List<MapMarker> _markers = [];
  MapMarker? _selectedMarker;

  @override
  void initState() {
    super.initState();
    _buildMarkers(widget.properties);
  }

  @override
  void didUpdateWidget(PropertiesMapScreenFlutter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.properties != widget.properties) {
      _buildMarkers(widget.properties);
    }
  }

  void _buildMarkers(List<Property> properties) {
    List<MapMarker> newMarkers = [];

    // Add property markers
    if (widget.showProperties) {
      for (var property in properties) {
        newMarkers.add(
          MapMarker(
            id: 'property_${property.id}',
            position: LatLng(property.latitude, property.longitude),
            title: property.name,
            subtitle:
                '\$${property.pricePerNight.toStringAsFixed(0)} / night',
            type: MarkerType.property,
            onTap: () => setState(() {
              if (_selectedMarker?.id == 'property_${property.id}') {
                _selectedMarker = null;
              } else {
                _selectedMarker = newMarkers.firstWhere(
                  (m) => m.id == 'property_${property.id}',
                );
              }
            }),
          ),
        );
      }
    }

    setState(() {
      _markers = newMarkers;
    });
  }

  void _onMarkerAction() {
    if (_selectedMarker == null) return;

    if (_selectedMarker!.type == MarkerType.property) {
      // Navigate to property details
      final propertyId =
          _selectedMarker!.id.replaceFirst('property_', '');
      final property = widget.properties
          .firstWhere((p) => p.id == propertyId);
      context.push(
        '${AppConstants.routePropertyDetails}/$propertyId',
        extra: property,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final initialLocation = widget.initialLocation ??
        LatLng(MapConstants.defaultLatitude,
            MapConstants.defaultLongitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Locations'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Flutter Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialLocation,
              initialZoom: MapConstants.propertyZoom,
              minZoom: MapConstants.minZoom,
              maxZoom: MapConstants.maxZoom,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
                  // Tile Layer (OSM)
                  TileLayer(
                    urlTemplate:
                        MapConstants.openStreetMapTile,
                    userAgentPackageName:
                        'com.example.rentify',
                    /* Coloring */
                    tileBuilder: (context, widget, tile) {
                      if (isDark) {
                        return Container(
                          color: Colors.grey[850],
                          child: ColorFiltered(
                            colorFilter: const ColorFilter.matrix([
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
                  // Markers
                  MarkerLayer(
                    markers: _markers
                        .map(
                          (marker) => Marker(
                            point: marker.position,
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            child: RentifyMarker(marker: marker),
                          ),
                        )
                        .toList(),
                  ),
                  // Selected Marker Info Popup
                  if (_selectedMarker != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedMarker!.position,
                          width: 280,
                          height: 180,
                          alignment: Alignment.topCenter,
                          child: Transform.translate(
                            offset: const Offset(0, -90),
                            child: MarkerPopup(
                              marker: _selectedMarker!,
                              onClose: () => setState(
                                () =>
                                    _selectedMarker = null,
                              ),
                              onAction: _onMarkerAction,
                              actionLabel: _selectedMarker!
                                          .type ==
                                      MarkerType
                                          .property
                                  ? 'View Details'
                                  : 'Open Maps',
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              // Map Controls
              Positioned(
                right: 16,
                bottom: 16,
                child: MapControls(
                  onZoomIn: () =>
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom + 1,
                      ),
                  onZoomOut: () =>
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom - 1,
                      ),
                  onCenter: () => _mapController.move(
                    _selectedMarker?.position ??
                        LatLng(
                          MapConstants
                              .defaultLatitude,
                          MapConstants
                              .defaultLongitude,
                        ),
                    MapConstants.propertyZoom,
                  ),
                ),
              ),
            ],
          ),
        );
    }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
