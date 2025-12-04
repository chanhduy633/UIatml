// ============================================
// FILE: lib/screens/safety_dashboard.dart
// ============================================
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import '../models/rescue_point.dart';
import '../models/flood_zone.dart';
import '../data/rescue_data.dart';
import '../data/flood_data.dart';
import '../widgets/custom_header.dart';
import '../widgets/stats_grid.dart';
import '../widgets/forecast_tabs.dart';
import '../widgets/flood_map.dart';
import 'rescue_form_screen.dart';

class SafetyDashboard extends StatefulWidget {
  const SafetyDashboard({super.key});

  @override
  State<SafetyDashboard> createState() => _SafetyDashboardState();
}

class _SafetyDashboardState extends State<SafetyDashboard> {
  int selectedTab = 0;
  final MapController mapController = MapController();
  Location location = Location();
  LatLng? currentLocation;
  double currentZoom = 5.5;

  late List<RescuePoint> allRescuePoints;
  late List<FloodZone> allFloodZones;

  @override
  void initState() {
    super.initState();
    allRescuePoints = RescueData.getSampleData();
    allFloodZones = FloodData.getFloodZones();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    final locationData = await location.getLocation();
    if (mounted) {
      setState(() {
        currentLocation = LatLng(
          locationData.latitude!,
          locationData.longitude!,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeCount = allRescuePoints.where((p) => p.isSafe).length;
    final needHelpCount = allRescuePoints.where((p) => !p.isSafe).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(safeCount: safeCount, needHelpCount: needHelpCount),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    StatsGrid(rescuePoints: allRescuePoints),
                    const SizedBox(height: 8),
                    ForecastTabs(
                      selectedTab: selectedTab,
                      onTabSelected: (index) {
                        setState(() => selectedTab = index);
                      },
                    ),
                    FloodMap(
                      mapController: mapController,
                      currentZoom: currentZoom,
                      rescuePoints: allRescuePoints,
                      floodZones: allFloodZones,
                      currentLocation: currentLocation,
                      onZoomChanged: (zoom) {
                        setState(() => currentZoom = zoom);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildLocationInfo(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RescueFormScreen()),
          );
        },
        backgroundColor: const Color(0xFFFA5252),
        icon: const Icon(Icons.add_alert),
        label: const Text('Yêu Cầu Cứu Trợ'),
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4FD),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF3B5BDB), size: 18),
          const SizedBox(width: 8),
          Text(
            'Đang theo dõi ${allRescuePoints.length} điểm • ${allFloodZones.length} vùng ngập',
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
        ],
      ),
    );
  }
}
