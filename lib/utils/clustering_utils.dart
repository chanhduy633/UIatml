// ============================================
// FILE: lib/utils/clustering_utils.dart
// ============================================
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;
import '../models/rescue_point.dart';
import '../models/flood_cluster.dart';

class ClusteringUtils {
  static double calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371;
    double dLat = _toRadians(point2.latitude - point1.latitude);
    double dLon = _toRadians(point2.longitude - point1.longitude);

    double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(point1.latitude)) *
            math.cos(_toRadians(point2.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degree) {
    return degree * math.pi / 180;
  }

  static List<RescueCluster> buildClusters(
    List<RescuePoint> points,
    double currentZoom,
  ) {
    if (currentZoom >= 12) {
      return points
          .map(
            (p) => RescueCluster(
              center: p.position,
              points: [p],
              totalPoints: 1,
              needHelpCount: p.isSafe ? 0 : 1,
              safeCount: p.isSafe ? 1 : 0,
            ),
          )
          .toList();
    }

    double clusterDistance;
    if (currentZoom < 6) {
      clusterDistance = 150;
    } else if (currentZoom < 8) {
      clusterDistance = 80;
    } else if (currentZoom < 10) {
      clusterDistance = 40;
    } else {
      clusterDistance = 15;
    }

    List<RescueCluster> clusters = [];
    List<RescuePoint> remainingPoints = List.from(points);

    while (remainingPoints.isNotEmpty) {
      RescuePoint center = remainingPoints.first;
      List<RescuePoint> nearbyPoints = [];

      for (var point in remainingPoints) {
        if (calculateDistance(center.position, point.position) <=
            clusterDistance) {
          nearbyPoints.add(point);
        }
      }

      if (nearbyPoints.length > 1) {
        double avgLat =
            nearbyPoints.fold(0.0, (sum, p) => sum + p.position.latitude) /
            nearbyPoints.length;
        double avgLng =
            nearbyPoints.fold(0.0, (sum, p) => sum + p.position.longitude) /
            nearbyPoints.length;
        int needHelp = nearbyPoints.where((p) => !p.isSafe).length;
        int safe = nearbyPoints.where((p) => p.isSafe).length;

        clusters.add(
          RescueCluster(
            center: LatLng(avgLat, avgLng),
            points: nearbyPoints,
            totalPoints: nearbyPoints.length,
            needHelpCount: needHelp,
            safeCount: safe,
          ),
        );
      } else {
        clusters.add(
          RescueCluster(
            center: center.position,
            points: [center],
            totalPoints: 1,
            needHelpCount: center.isSafe ? 0 : 1,
            safeCount: center.isSafe ? 1 : 0,
          ),
        );
      }

      remainingPoints.removeWhere((p) => nearbyPoints.contains(p));
    }

    return clusters;
  }
}
