// ============================================
// FILE: lib/data/flood_data.dart
// ============================================
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;
import '../models/flood_zone.dart';

class FloodData {
  static List<FloodZone> getFloodZones() {
    return [
      // Vùng ngập nghiêm trọng - Mức 5
      FloodZone(
        position: const LatLng(21.0285, 105.8542),
        level: 5,
        description: 'Vùng ngập nặng Hà Nội trung tâm',
        radius: 8,
      ),
      FloodZone(
        position: const LatLng(16.0544, 108.2022),
        level: 5,
        description: 'Vùng ngập nghiêm trọng Đà Nẵng',
        radius: 10,
      ),
      FloodZone(
        position: const LatLng(10.7769, 106.7009),
        level: 5,
        description: 'Vùng ngập nặng TP.HCM',
        radius: 12,
      ),

      // Vùng ngập nặng - Mức 4
      FloodZone(
        position: const LatLng(16.4637, 107.5909),
        level: 4,
        description: 'Vùng ngập Huế',
        radius: 7,
      ),
      FloodZone(
        position: const LatLng(15.5694, 108.4800),
        level: 4,
        description: 'Vùng ngập Quảng Nam',
        radius: 9,
      ),

      // Vùng ngập cao - Mức 3
      FloodZone(
        position: const LatLng(20.8449, 106.6881),
        level: 3,
        description: 'Vùng ngập Hải Phòng',
        radius: 6,
      ),
      FloodZone(
        position: const LatLng(12.2388, 109.1967),
        level: 3,
        description: 'Vùng ngập Nha Trang',
        radius: 5,
      ),
      FloodZone(
        position: const LatLng(10.0452, 105.7469),
        level: 3,
        description: 'Vùng ngập Cần Thơ',
        radius: 7,
      ),

      // Vùng ngập vừa - Mức 2
      FloodZone(
        position: const LatLng(21.0064, 107.2926),
        level: 2,
        description: 'Vùng ngập nhẹ Quảng Ninh',
        radius: 4,
      ),
      FloodZone(
        position: const LatLng(13.7830, 109.2196),
        level: 2,
        description: 'Vùng ngập vừa Bình Định',
        radius: 5,
      ),

      // Vùng ngập nhẹ - Mức 1
      FloodZone(
        position: const LatLng(10.5215, 105.1258),
        level: 1,
        description: 'Vùng theo dõi An Giang',
        radius: 3,
      ),
      FloodZone(
        position: const LatLng(10.3460, 107.0843),
        level: 1,
        description: 'Vùng theo dõi Vũng Tàu',
        radius: 3,
      ),
    ];
  }
}
