// ============================================
// FILE: lib/widgets/map_markers.dart
// ============================================
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../models/rescue_point.dart';
import '../models/flood_cluster.dart';

class MapMarkers {
  // Marker cho cluster
  static Marker createClusterMarker(RescueCluster cluster, VoidCallback onTap) {
    final hasNeedHelp = cluster.needHelpCount > 0;
    final color = hasNeedHelp
        ? const Color(0xFFFA5252)
        : const Color(0xFF40C057);

    return Marker(
      point: cluster.center,
      width: 100,
      height: 100,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (hasNeedHelp) ...[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
              ),
            ],
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  cluster.totalPoints.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Marker cho điểm đơn
  static Marker createSingleMarker(RescuePoint point, VoidCallback onTap) {
    final color = point.statusColor;
    final hasWarning = !point.isSafe;

    return Marker(
      point: point.position,
      width: 80,
      height: 80,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (hasWarning) ...[
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
              ),
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
              ),
            ],
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  hasWarning ? Icons.warning : Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
