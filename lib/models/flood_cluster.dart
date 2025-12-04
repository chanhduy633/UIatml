// ============================================
// FILE: lib/models/flood_cluster.dart
// ============================================
import 'package:latlong2/latlong.dart';
import 'rescue_point.dart';

class RescueCluster {
  final LatLng center;
  final List<RescuePoint> points;
  final int totalPoints;
  final int needHelpCount;
  final int safeCount;

  RescueCluster({
    required this.center,
    required this.points,
    required this.totalPoints,
    required this.needHelpCount,
    required this.safeCount,
  });

  bool get hasNeedHelp => needHelpCount > 0;
}
