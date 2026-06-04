import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../theme/paalvandi_theme.dart';
import '../../core/widgets/responsive_helper.dart';
import '../../core/services/haptic_service.dart';

class RouteMapView extends StatefulWidget {
  const RouteMapView({super.key});

  @override
  State<RouteMapView> createState() => _RouteMapViewState();
}

class _RouteMapViewState extends State<RouteMapView> {
  final MapController _mapController = MapController();
  double _currentZoom = 13.0;

  // Selected stop details
  Map<String, dynamic>? _selectedStop;

  // Mock markers around Coimbatore
  final List<Map<String, dynamic>> _stops = [
    {
      'id': 'stop_current',
      'name': 'Ravi Kumar (You)',
      'role': 'Driver',
      'type': 'Current Location',
      'latlng': const LatLng(11.0168, 76.9558),
      'color': PaalvandiTheme.primaryBlue,
      'icon': Icons.my_location,
      'address': 'Current Location, RS Puram, Coimbatore',
      'phone': '9361051718',
    },
    {
      'id': 'stop_order_1',
      'name': 'Nandha Prabhu',
      'role': 'Customer',
      'type': 'Daily Order',
      'latlng': const LatLng(11.0230, 76.9600),
      'color': PaalvandiTheme.outForDeliveryOrange,
      'icon': Icons.inventory_2,
      'address': '14, Cross Cut Road, Gandhipuram, Coimbatore',
      'phone': '9361051718',
    },
    {
      'id': 'stop_order_2',
      'name': 'Anjali Sharma',
      'role': 'Customer',
      'type': 'Daily Order',
      'latlng': const LatLng(11.0110, 76.9420),
      'color': PaalvandiTheme.outForDeliveryOrange,
      'icon': Icons.inventory_2,
      'address': 'SF-4, Green Meadows Apartments, Saravanampatti',
      'phone': '9443210987',
    },
    {
      'id': 'stop_sub_1',
      'name': 'Rajesh Kumar',
      'role': 'Subscriber',
      'type': 'Subscription Delivery',
      'latlng': const LatLng(11.0310, 76.9720),
      'color': PaalvandiTheme.deliveredGreen,
      'icon': Icons.autorenew,
      'address': '102, Shanthi Colony, Peelamedu, Coimbatore',
      'phone': '8870123456',
    },
    {
      'id': 'stop_bulk_1',
      'name': 'Grand Kalyana Mandapam',
      'role': 'Wedding Event',
      'type': 'Bulk Order',
      'latlng': const LatLng(10.9990, 76.9580),
      'color': PaalvandiTheme.statusError,
      'icon': Icons.business,
      'address': '12, Mettupalayam Road, Coimbatore',
      'phone': '9443567890',
    },
    {
      'id': 'stop_bottle_1',
      'name': 'Meena Lakshmi',
      'role': 'Customer',
      'type': 'Bottle Collection',
      'latlng': const LatLng(11.0080, 76.9690),
      'color': PaalvandiTheme.statusPending,
      'icon': Icons.recycling,
      'address': '45, Nehru Nagar, RS Puram, Coimbatore',
      'phone': '9087654321',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final scaleF =
        (num val) => ResponsiveHelper.scaledValue(context, val.toDouble());
    final fs =
        (num size) => ResponsiveHelper.scaledFontSize(context, size.toDouble());
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Live Flutter Map Layer
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(11.0168, 76.9558),
              initialZoom: _currentZoom,
              minZoom: 10.0,
              maxZoom: 18.0,
              onTap: (tapPosition, point) {
                if (_selectedStop != null) {
                  setState(() {
                    _selectedStop = null;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.paalvandi.delivery',
              ),
              MarkerLayer(
                markers: _stops.map((stop) {
                  final isSelected = _selectedStop != null && _selectedStop!['id'] == stop['id'];
                  final markerSize = isSelected ? scaleF(48) : scaleF(38);

                  return Marker(
                    point: stop['latlng'],
                    width: markerSize,
                    height: markerSize,
                    child: GestureDetector(
                      onTap: () {
                        HapticService.light();
                        setState(() {
                          _selectedStop = stop;
                        });
                        _mapController.move(stop['latlng'], 14.5);
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (stop['id'] == 'stop_current')
                            Container(
                              width: markerSize,
                              height: markerSize,
                              decoration: BoxDecoration(
                                color: stop['color'].withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : stop['color'],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? stop['color'] : Colors.white,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              stop['icon'],
                              size: isSelected ? scaleF(20) : scaleF(16),
                              color: isSelected ? stop['color'] : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // 2. Custom Branded Top Bar overlay
          Positioned(
            top: scaleF(44),
            left: hPadding,
            right: hPadding,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: scaleF(12), vertical: scaleF(10)),
              decoration: PaalvandiTheme.cardDecoration.copyWith(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: PaalvandiTheme.textDark),
                    onPressed: () {
                      HapticService.light();
                      context.pop();
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Route Navigation',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(14),
                            fontWeight: FontWeight.bold,
                            color: PaalvandiTheme.textDark,
                          ),
                        ),
                        Text(
                          '${_stops.length - 1} stops remaining today',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(10),
                            color: PaalvandiTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.directions_outlined,
                    color: PaalvandiTheme.primaryBlue,
                    size: scaleF(24),
                  ),
                ],
              ),
            ),
          ),

          // 3. Zoom Controllers
          Positioned(
            right: scaleF(16),
            top: scaleF(130),
            child: Column(
              children: [
                _zoomButton(Icons.add, () {
                  HapticService.light();
                  setState(() {
                    _currentZoom = (_currentZoom + 1).clamp(10.0, 18.0);
                    _mapController.move(_mapController.camera.center, _currentZoom);
                  });
                }, scaleF),
                SizedBox(height: scaleF(8)),
                _zoomButton(Icons.remove, () {
                  HapticService.light();
                  setState(() {
                    _currentZoom = (_currentZoom - 1).clamp(10.0, 18.0);
                    _mapController.move(_mapController.camera.center, _currentZoom);
                  });
                }, scaleF),
              ],
            ),
          ),

          // 4. Detail overlay bottom card
          if (_selectedStop != null)
            Positioned(
              bottom: scaleF(16),
              left: hPadding,
              right: hPadding,
              child: Container(
                padding: EdgeInsets.all(scaleF(16)),
                decoration: PaalvandiTheme.cardDecoration.copyWith(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: scaleF(8), vertical: scaleF(4)),
                          decoration: PaalvandiTheme.statusBadgeDecoration(_selectedStop!['color']),
                          child: Text(
                            _selectedStop!['type'].toUpperCase(),
                            style: GoogleFonts.montserrat(
                              fontSize: fs(8),
                              fontWeight: FontWeight.bold,
                              color: _selectedStop!['color'],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: scaleF(16), color: PaalvandiTheme.textMuted),
                          onPressed: () {
                            HapticService.light();
                            setState(() {
                              _selectedStop = null;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: scaleF(4)),
                    Text(
                      _selectedStop!['name'],
                      style: GoogleFonts.montserrat(
                        fontSize: fs(14),
                        fontWeight: FontWeight.bold,
                        color: PaalvandiTheme.textDark,
                      ),
                    ),
                    if (_selectedStop!['role'].isNotEmpty) ...[
                      SizedBox(height: scaleF(2)),
                      Text(
                        _selectedStop!['role'],
                        style: GoogleFonts.montserrat(
                          fontSize: fs(10),
                          color: PaalvandiTheme.textSecondary,
                        ),
                      ),
                    ],
                    SizedBox(height: scaleF(12)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_outlined, color: PaalvandiTheme.primaryBlue, size: scaleF(16)),
                        SizedBox(width: scaleF(8)),
                        Expanded(
                          child: Text(
                            _selectedStop!['address'],
                            style: GoogleFonts.montserrat(
                              fontSize: fs(11),
                              color: PaalvandiTheme.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (_selectedStop!['id'] != 'stop_current') ...[
                      SizedBox(height: scaleF(16)),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.phone_outlined, size: 16),
                              label: const Text('Call'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: PaalvandiTheme.accentGreen,
                                side: const BorderSide(color: PaalvandiTheme.accentGreen),
                                padding: EdgeInsets.symmetric(vertical: scaleF(10)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                HapticService.light();
                                final uri = Uri.parse('tel:${_selectedStop!['phone']}');
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              },
                            ),
                          ),
                          SizedBox(width: scaleF(12)),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.navigation_outlined, size: 16),
                              label: const Text('Navigate'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PaalvandiTheme.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: scaleF(10)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                HapticService.light();
                                final encoded = Uri.encodeComponent(_selectedStop!['address']);
                                launchUrl(
                                  Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded'),
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _zoomButton(IconData icon, VoidCallback onTap, Function scaleF) {
    return Container(
      width: scaleF(40),
      height: scaleF(40),
      decoration: BoxDecoration(
        color: PaalvandiTheme.cardWhite,
        shape: BoxShape.circle,
        border: Border.all(color: PaalvandiTheme.cardBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: scaleF(18), color: PaalvandiTheme.textDark),
        onPressed: onTap,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
