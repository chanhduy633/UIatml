// ============================================
// FILE: lib/models/rescue_point.dart
// ============================================
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

// Điểm cứu trợ người dân (2 trạng thái)
class RescuePoint {
  final String id;
  final LatLng position;
  final String name;
  final String phone;
  final bool isSafe; // true: an toàn, false: cần trợ giúp
  final int adults;
  final int children;
  final int elderly;
  final String address;
  final List<String> conditions;
  final String? description;
  final DateTime reportTime;

  RescuePoint({
    required this.id,
    required this.position,
    required this.name,
    required this.phone,
    required this.isSafe,
    this.adults = 0,
    this.children = 0,
    this.elderly = 0,
    required this.address,
    this.conditions = const [],
    this.description,
    required this.reportTime,
  });

  Color get statusColor =>
      isSafe ? const Color(0xFF40C057) : const Color(0xFFFA5252);

  String get statusLabel => isSafe ? 'An toàn' : 'Cần trợ giúp';

  int get totalPeople => adults + children + elderly;
}
