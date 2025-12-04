// ============================================
// FILE: lib/models/flood_zone.dart
// ============================================
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

// Vùng ngập lụt (5 mức độ - do backend trả về)
class FloodZone {
  final LatLng position;
  final int level; // 1-5: Mức độ ngập lụt
  final String description;
  final double radius; // Bán kính vùng ảnh hưởng (km)

  FloodZone({
    required this.position,
    required this.level,
    required this.description,
    this.radius = 5.0,
  });

  Color get color {
    switch (level) {
      case 1:
        return const Color(0xFF40C057); // Xanh lá - Mức 1
      case 2:
        return const Color(0xFF82C91E); // Xanh vàng - Mức 2
      case 3:
        return const Color(0xFFFFB020); // Vàng cam - Mức 3
      case 4:
        return const Color(0xFFFF6B6B); // Cam đỏ - Mức 4
      case 5:
        return const Color(0xFFFA5252); // Đỏ - Mức 5
      default:
        return Colors.grey;
    }
  }

  String get levelLabel {
    switch (level) {
      case 1:
        return 'Mức 1 - Ngập nhẹ';
      case 2:
        return 'Mức 2 - Ngập vừa';
      case 3:
        return 'Mức 3 - Ngập cao';
      case 4:
        return 'Mức 4 - Ngập nặng';
      case 5:
        return 'Mức 5 - Ngập nghiêm trọng';
      default:
        return 'Không xác định';
    }
  }
}
