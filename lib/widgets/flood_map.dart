// ============================================
// FILE: lib/widgets/flood_map.dart
// ============================================
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/rescue_point.dart';
import '../models/flood_zone.dart';
import '../models/flood_cluster.dart';
import '../utils/clustering_utils.dart';
import 'map_markers.dart';

class FloodMap extends StatelessWidget {
  final MapController mapController;
  final double currentZoom;
  final List<RescuePoint> rescuePoints;
  final List<FloodZone> floodZones;
  final LatLng? currentLocation;
  final Function(double) onZoomChanged;

  const FloodMap({
    super.key,
    required this.mapController,
    required this.currentZoom,
    required this.rescuePoints,
    required this.floodZones,
    required this.currentLocation,
    required this.onZoomChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 350,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: const LatLng(14.0583, 108.2772),
                initialZoom: 5.5,
                minZoom: 4,
                maxZoom: 18,
                onPositionChanged: (position, hasGesture) {
                  if (hasGesture && position.zoom != null) {
                    onZoomChanged(position.zoom!);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.safety_dashboard',
                ),
                // Vẽ vùng ngập lụt (CircleLayer)
                CircleLayer(
                  circles: floodZones.map((zone) {
                    return CircleMarker(
                      point: zone.position,
                      radius: zone.radius * 1000, // Convert km to meters
                      color: zone.color.withValues(alpha: 0.3),
                      borderColor: zone.color,
                      borderStrokeWidth: 2,
                      useRadiusInMeter: true,
                    );
                  }).toList(),
                ),
                // Markers người dân
                MarkerLayer(markers: _buildMarkers(context)),
              ],
            ),
            _buildLegend(),
            _buildZoomInfo(),
            _buildLocationButton(context),
            _buildExpandButton(),
          ],
        ),
      ),
    );
  }

  List<Marker> _buildMarkers(BuildContext context) {
    var clusters = ClusteringUtils.buildClusters(rescuePoints, currentZoom);
    return clusters.map((cluster) {
      if (cluster.totalPoints > 1) {
        return MapMarkers.createClusterMarker(
          cluster,
          () => _showClusterInfo(context, cluster),
        );
      } else {
        return MapMarkers.createSingleMarker(
          cluster.points.first,
          () => _showPointInfo(context, cluster.points.first),
        );
      }
    }).toList();
  }

  void _showClusterInfo(BuildContext context, RescueCluster cluster) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cluster.hasNeedHelp
                    ? const Color(0xFFFA5252)
                    : const Color(0xFF40C057),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  cluster.totalPoints.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cụm điểm cứu trợ',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    '${cluster.totalPoints} người • ${cluster.needHelpCount} cần trợ giúp',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cần trợ giúp: ${cluster.needHelpCount}',
                style: const TextStyle(
                  color: Color(0xFFFA5252),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'An toàn: ${cluster.safeCount}',
                style: const TextStyle(
                  color: Color(0xFF40C057),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Chi tiết:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...cluster.points
                  .take(5)
                  .map(
                    (p) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            p.isSafe ? Icons.check_circle : Icons.warning,
                            color: p.statusColor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '${p.totalPeople} người - ${p.statusLabel}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              if (cluster.points.length > 5)
                Text(
                  '... và ${cluster.points.length - 5} người khác',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              mapController.move(cluster.center, currentZoom + 2);
            },
            child: const Text('Phóng to xem'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showPointInfo(BuildContext context, RescuePoint point) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: point.statusColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                point.isSafe ? Icons.check : Icons.warning,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(point.name, style: const TextStyle(fontSize: 16)),
                  Text(
                    point.statusLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: point.statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(Icons.phone, 'Điện thoại', point.phone),
              _buildInfoRow(
                Icons.people,
                'Số người',
                '${point.totalPeople} người (${point.adults} người lớn, ${point.children} trẻ em, ${point.elderly} người già)',
              ),
              _buildInfoRow(Icons.location_on, 'Địa chỉ', point.address),
              if (point.conditions.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Tình trạng:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: point.conditions
                      .map(
                        (c) => Chip(
                          label: Text(c, style: const TextStyle(fontSize: 11)),
                          backgroundColor: Colors.orange.shade100,
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      )
                      .toList(),
                ),
              ],
              if (point.description != null &&
                  point.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Mô tả: ${point.description}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Báo cáo: ${_formatTime(point.reportTime)}',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        actions: [
          if (!point.isSafe)
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Gọi cứu trợ
              },
              icon: const Icon(Icons.phone, size: 16),
              label: const Text('Liên hệ'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFA5252),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                Text(value, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} giờ trước';
    } else {
      return '${diff.inDays} ngày trước';
    }
  }

  Widget _buildLegend() {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Mức 1', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 8),
            Container(
              width: 60,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF40C057),
                    Color(0xFF82C91E),
                    Color(0xFFFFB020),
                    Color(0xFFFF6B6B),
                    Color(0xFFFA5252),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Mức 5', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomInfo() {
    return Positioned(
      top: 50,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
            ),
          ],
        ),
        child: Text(
          'Zoom: ${currentZoom.toStringAsFixed(1)}',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildLocationButton(BuildContext context) {
    return Positioned(
      bottom: 12,
      right: 12,
      child: GestureDetector(
        onTap: () {
          if (currentLocation != null) {
            mapController.move(currentLocation!, 12);
          }
        },
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
              ),
            ],
          ),
          child: const Icon(Icons.my_location, color: Color(0xFF3B5BDB)),
        ),
      ),
    );
  }

  Widget _buildExpandButton() {
    return Positioned(
      bottom: 12,
      right: 64,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
            ),
          ],
        ),
        child: const Icon(Icons.fullscreen, color: Color(0xFF3B5BDB)),
      ),
    );
  }
}
